import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../services/calibration_profile.dart';
import '../services/car_detection_service.dart';
import '../utils/fft.dart';

/// Экран калибровки детектора машин: live-визуализация спектра, запись
/// пользовательских эталонов (5 сек), список эталонов с удалением, загрузка
/// демо-эталонов и сброс.
///
/// Создаёт **свой собственный** [CarDetectionService] для live-визуализации и
/// записи — отдельный от сервиса плеера. После любого изменения эталонов
/// (запись/удаление/сброс/демо) вызывается
/// [CarDetectionService.reloadProfilesInAllActive] — обновятся и этот экран,
/// и активный сервис плеера (если запущен).
class CarCalibrationScreen extends StatefulWidget {
  const CarCalibrationScreen({super.key});

  @override
  State<CarCalibrationScreen> createState() => _CarCalibrationScreenState();
}

class _CarCalibrationScreenState extends State<CarCalibrationScreen> {
  /// Собственный сервис для live-визуализации и записи (НЕ плееровский).
  late final CarDetectionService _detService;

  /// Список сохранённых эталонов (read from SharedPreferences).
  List<CalibrationProfile> _profiles = const <CalibrationProfile>[];

  /// Текущий live-кадр признаков для визуализации (обновляется по Timer).
  SpectrumFeatures? _liveFeatures;

  /// Timer poll-а сервиса на 20 Гц (50 мс) — достаточно и для визуализации,
  /// и для записи (~100 семплов за 5 сек).
  Timer? _pollTimer;

  // ---- Состояние записи эталона ----
  bool _isRecording = false;
  int _recordCountdown = 0;
  ProfileClass _selectedClass = ProfileClass.carClose;
  final TextEditingController _nameController = TextEditingController();
  final List<SpectrumFeatures> _recordSamples = <SpectrumFeatures>[];
  Timer? _countdownTimer;

  static const String _profilesPrefsKey =
      CarDetectionService.profilesPrefsKey;

  @override
  void initState() {
    super.initState();
    _detService = CarDetectionService();
    _detService.addListener(_onServiceChanged);
    _loadProfiles();
    // Старт live-захвата после первого frame — нужен context для l10n/permission
    // диалогов (если понадобятся).
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLiveCapture());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _nameController.dispose();
    _detService.removeListener(_onServiceChanged);
    _detService.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle helpers
  // ---------------------------------------------------------------------------

  Future<void> _startLiveCapture() async {
    final bool ok = await _detService.start(sensitivity: 0.4);
    if (!ok && mounted) {
      // Показываем SnackBar — нет доступа к микрофону или иная ошибка.
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.carCalibrationMicDenied ?? 'Microphone denied'),
        ),
      );
    }
    if (mounted) {
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        final SpectrumFeatures? f = _detService.lastFeatures;
        if (f != null) {
          setState(() {
            _liveFeatures = f;
            if (_isRecording) {
              _recordSamples.add(f);
            }
          });
        }
      });
    }
  }

  void _onServiceChanged() {
    // Сервис вызывает notifyListeners() при alert — нам это не критично, но
    // синхронизируем UI на всякий случай.
    if (!mounted) return;
    setState(() {});
  }

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  Future<void> _loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_profilesPrefsKey);
      if (raw == null || raw.isEmpty) {
        setState(() => _profiles = const <CalibrationProfile>[]);
        return;
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<CalibrationProfile> loaded = <CalibrationProfile>[];
      for (final dynamic item in decoded) {
        final p = CalibrationProfile.fromJson(item as Map<String, dynamic>);
        if (p != null) loaded.add(p);
      }
      setState(() => _profiles = loaded);
    } catch (e) {
      debugPrint('✗ CarCalibrationScreen._loadProfiles: $e');
    }
  }

  /// Сохраняет текущий [_profiles] в SharedPreferences + обновляет все активные
  /// сервисы детектора (этот экран + плеер) через [setProfiles] / reload.
  Future<void> _persistAndSync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _profilesPrefsKey,
        jsonEncode(_profiles.map((p) => p.toJson()).toList()),
      );
      // Глобально перезагружаем профили во всех активных сервисах.
      await CarDetectionService.reloadProfilesInAllActive();
    } catch (e) {
      debugPrint('✗ CarCalibrationScreen._persistAndSync: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Запись эталона
  // ---------------------------------------------------------------------------

  Future<void> _startRecording() async {
    if (_isRecording) return;
    if (!await Permission.microphone.request().isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.carCalibrationMicDenied ??
              'Microphone denied'),
        ),
      );
      return;
    }

    final String name = _nameController.text.trim().isEmpty
        ? _classLabel(_selectedClass)
        : _nameController.text.trim();

    setState(() {
      _isRecording = true;
      _recordSamples.clear();
      _recordCountdown = 5;
    });

    // Обратный отсчёт 5→0, каждую секунду. Семплы пишутся в pollTimer.
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _recordCountdown--);
      if (_recordCountdown <= 0) {
        t.cancel();
        _finishRecording(name);
      }
    });
  }

  Future<void> _finishRecording(String name) async {
    final List<SpectrumFeatures> samples =
        List<SpectrumFeatures>.of(_recordSamples);
    setState(() {
      _isRecording = false;
      _recordSamples.clear();
      _recordCountdown = 0;
    });

    if (samples.length < 10) {
      // Слишком мало семплов — что-то пошло не так (mic не успел/не запустился).
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)?.carCalibrationEmpty ?? 'No data')),
      );
      return;
    }

    final CalibrationProfile profile = CalibrationProfile.fromSamples(
      name,
      _selectedClass,
      samples,
    );
    setState(() => _profiles = [..._profiles, profile]);
    await _persistAndSync();
    _nameController.clear();
    debugPrint('✓ CarCalibration: recorded ${samples.length} samples '
        'as ${profile.cls.name} "$name"');
  }

  Future<void> _deleteProfile(String id) async {
    final l10n = AppLocalizations.of(context);
    final CalibrationProfile? p =
        _profiles.firstWhereOrNull((p) => p.id == id);
    if (p == null) return;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.carCalibrationReset ?? 'Delete'),
        content: Text(l10n?.carCalibrationDeleteConfirm(p.name) ??
            'Delete "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.carCalibrationCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.carCalibrationConfirm ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _profiles = _profiles.where((p) => p.id != id).toList());
    await _persistAndSync();
  }

  Future<void> _resetAll() async {
    final l10n = AppLocalizations.of(context);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.carCalibrationReset ?? 'Reset'),
        content: Text(l10n?.carCalibrationResetConfirm ??
            'Delete all calibration profiles?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.carCalibrationCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.carCalibrationConfirm ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _profiles = const <CalibrationProfile>[]);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profilesPrefsKey);
    } catch (_) {}
    await CarDetectionService.reloadProfilesInAllActive();
  }

  // ---------------------------------------------------------------------------
  // Демо-эталоны
  // ---------------------------------------------------------------------------

  Future<void> _loadDemo() async {
    final l10n = AppLocalizations.of(context);
    try {
      final String raw =
          await rootBundle.loadString('assets/calibration/default_profiles.json');
      final Map<String, dynamic> data = jsonDecode(raw) as Map<String, dynamic>;
      final List<dynamic> list = data['profiles'] as List<dynamic>;
      final List<CalibrationProfile> demo = <CalibrationProfile>[];
      final Random rnd = Random();
      final int now = DateTime.now().millisecondsSinceEpoch;
      int i = 0;
      for (final dynamic item in list) {
        final p = CalibrationProfile.fromJson(item as Map<String, dynamic>);
        if (p == null) continue;
        // Перегенерируем id + фиксим имя на локализованное, чтобы избежать
        // конфликтов с уже добавленными эталонами и демо других запусков.
        final ProfileClass cls = p.cls;
        demo.add(CalibrationProfile(
          id: 'demo-$now-${i++}-${rnd.nextInt(0xFFFFFF).toRadixString(16)}',
          name: '${l10n?.carCalibrationDemoPrefix ?? "Demo"}: ${_classLabel(cls)}',
          cls: cls,
          createdAt: DateTime.now(),
          lowMean: p.lowMean,
          lowStd: p.lowStd,
          midMean: p.midMean,
          midStd: p.midStd,
          highMean: p.highMean,
          highStd: p.highStd,
          centroidMean: p.centroidMean,
          centroidStd: p.centroidStd,
          flatnessMean: p.flatnessMean,
          flatnessStd: p.flatnessStd,
          rmsMean: p.rmsMean,
          rmsStd: p.rmsStd,
        ));
      }
      if (demo.isEmpty) return;
      setState(() => _profiles = [..._profiles, ...demo]);
      await _persistAndSync();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.carCalibrationDemoLoaded(demo.length) ??
              'Loaded ${demo.length} demo profiles'),
        ),
      );
    } catch (e) {
      debugPrint('✗ CarCalibration._loadDemo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  /// Локализованное название класса.
  String _classLabel(ProfileClass cls) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return cls.name;
    return switch (cls) {
      ProfileClass.carClose => l10n.profileClassCarClose,
      ProfileClass.carFar => l10n.profileClassCarFar,
      ProfileClass.carTruck => l10n.profileClassCarTruck,
      ProfileClass.carMotorcycle => l10n.profileClassCarMotorcycle,
      ProfileClass.wind => l10n.profileClassWind,
      ProfileClass.steps => l10n.profileClassSteps,
      ProfileClass.voice => l10n.profileClassVoice,
      ProfileClass.street => l10n.profileClassStreet,
      ProfileClass.music => l10n.profileClassMusic,
      ProfileClass.other => l10n.profileClassOther,
    };
  }

  /// Нормирует энергию полосы в высоту bar 0..1 (лог-шкала, clamp).
  double _bandToHeight(double energy) {
    if (energy <= 0) return 0.0;
    // log-шкала: energy 0.1 → ~0.16, energy 1.0 → 0.5, energy 10 → 0.83.
    final double v = (log(energy + 1.0) / log(50.0)).clamp(0.0, 1.0);
    return v;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.carCalibrationTitle ?? 'Calibration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLiveCard(l10n, theme),
            const SizedBox(height: 12),
            _buildRecordCard(l10n, theme),
            const SizedBox(height: 12),
            _buildProfilesHeader(l10n, theme),
            const SizedBox(height: 6),
            _buildProfilesList(l10n, theme),
            const SizedBox(height: 12),
            _buildActionButtons(l10n, theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---- Live-визуализация ----
  Widget _buildLiveCard(AppLocalizations? l10n, ThemeData theme) {
    final SpectrumFeatures? f = _liveFeatures;
    final bool classifying = _detService.useClassification;
    final ProfileClass? nearest = _detService.nearestClass;
    final double dist = _detService.nearestDistance;

    final double lowH = f != null ? _bandToHeight(f.lowBandEnergy) : 0.0;
    final double midH = f != null ? _bandToHeight(f.midBandEnergy) : 0.0;
    final double highH = f != null ? _bandToHeight(f.highBandEnergy) : 0.0;

    String statusText;
    if (f == null) {
      statusText = _detService.statusLine;
    } else if (classifying && nearest != null && dist.isFinite) {
      statusText = l10n?.carCalibrationNearest(
              _classLabel(nearest), dist.toStringAsFixed(1)) ??
          'Nearest: ${_classLabel(nearest)} (d=${dist.toStringAsFixed(1)})';
    } else if (classifying) {
      statusText = l10n?.carCalibrationNoMatch ?? 'No match';
    } else {
      statusText = l10n?.carCalibrationThresholdScore(
              _detService.currentScore.toStringAsFixed(2)) ??
          'Score: ${_detService.currentScore.toStringAsFixed(2)}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.graphic_eq, size: 18),
                const SizedBox(width: 6),
                Text(l10n?.carCalibrationLive ?? 'Live spectrum',
                    style: theme.textTheme.titleSmall),
                const Spacer(),
                Icon(
                  classifying ? Icons.category : Icons.tune,
                  size: 14,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  classifying
                      ? (l10n?.carCalibrationModeClassify ?? 'Mode: classify')
                      : (l10n?.carCalibrationModeThreshold ??
                          'Mode: threshold'),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 3 spectrum bars.
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _SpectrumBar(
                      label: 'low',
                      value: lowH,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SpectrumBar(
                      label: 'mid',
                      value: midH,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SpectrumBar(
                      label: 'high',
                      value: highH,
                      color: Colors.lightBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (f != null)
              Wrap(
                spacing: 10,
                runSpacing: 4,
                children: [
                  _MetricChip(
                      label: 'flat', value: f.spectralFlatness.toStringAsFixed(2)),
                  _MetricChip(
                      label: 'cent',
                      value: '${f.spectralCentroid.toStringAsFixed(0)}Hz'),
                  _MetricChip(
                      label: 'rms',
                      value: (f.rms * 1000).toStringAsFixed(1)),
                  _MetricChip(
                      label: 'low/mid',
                      value: f.midBandEnergy > 1e-9
                          ? (f.lowBandEnergy / f.midBandEnergy)
                              .toStringAsFixed(1)
                          : '∞'),
                ],
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(statusText,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ])),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Запись эталона ----
  Widget _buildRecordCard(AppLocalizations? l10n, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fiber_manual_record, size: 18,
                    color: Colors.red),
                const SizedBox(width: 6),
                Text(l10n?.carCalibrationRecordTitle ?? 'Record sample',
                    style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            // Класс.
            Row(
              children: [
                Text(l10n?.carCalibrationClass ?? 'Class'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<ProfileClass>(
                    value: _selectedClass,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        isDense: true, border: OutlineInputBorder()),
                    items: ProfileClass.values.map((cls) {
                      return DropdownMenuItem(
                        value: cls,
                        child: Row(
                          children: [
                            Icon(cls.icon, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_classLabel(cls),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isRecording
                        ? null
                        : (v) {
                            if (v != null) {
                              setState(() => _selectedClass = v);
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Имя.
            TextField(
              controller: _nameController,
              enabled: !_isRecording,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                labelText: l10n?.carCalibrationName ?? 'Sample name',
                hintText: _classLabel(_selectedClass),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isRecording ? null : _startRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                label: Text(_isRecording
                    ? (l10n?.carCalibrationRecording(_recordCountdown) ??
                        'Recording... ${_recordCountdown}s')
                    : (l10n?.carCalibrationRecord ?? 'Record 5 sec')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Список эталонов ----
  Widget _buildProfilesHeader(AppLocalizations? l10n, ThemeData theme) {
    return Row(
      children: [
        Text(
          l10n?.carCalibrationProfilesCount(_profiles.length) ??
              'Profiles (${_profiles.length})',
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _buildProfilesList(AppLocalizations? l10n, ThemeData theme) {
    if (_profiles.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Center(
            child: Text(
              l10n?.carCalibrationEmpty ?? 'No samples yet',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        ),
      );
    }
    final List<CalibrationProfile> sorted =
        List<CalibrationProfile>.of(_profiles)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Card(
      child: Column(
        children: [
          for (final p in sorted) ...[
            ListTile(
              leading: Icon(p.cls.icon, color: p.cls.isCar ? Colors.red : null),
              title: Text(p.name),
              subtitle: Text(
                '${_classLabel(p.cls)} · ${p.createdAt.toLocal().toString().substring(0, 16)}',
                style: theme.textTheme.bodySmall,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n?.carCalibrationDelete ?? 'Delete',
                onPressed: _isRecording ? null : () => _deleteProfile(p.id),
              ),
            ),
            if (p != sorted.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  // ---- Кнопки действий ----
  Widget _buildActionButtons(AppLocalizations? l10n, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isRecording ? null : _loadDemo,
            icon: const Icon(Icons.download_outlined),
            label: Text(l10n?.carCalibrationLoadDemo ?? 'Load demo'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: (_isRecording || _profiles.isEmpty)
                ? null
                : _resetAll,
            icon: const Icon(Icons.delete_sweep_outlined),
            label: Text(l10n?.carCalibrationReset ?? 'Reset all'),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Helpers (private widgets)
// =============================================================================

/// Один spectrum bar (low/mid/high) с подписью.
class _SpectrumBar extends StatelessWidget {
  final String label;
  final double value; // 0..1
  final Color color;

  const _SpectrumBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxH = constraints.maxHeight;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              height: (maxH - 18).clamp(0.0, double.infinity) * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    )),
          ],
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('$label=$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              )),
    );
  }
}

/// Extension для firstWhereOrNull (нет в dart:core до Dart 3.0 без collection).
extension _IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final T e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
