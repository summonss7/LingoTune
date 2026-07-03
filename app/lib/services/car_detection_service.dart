import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/fft.dart';
import 'calibration_profile.dart';

/// Уровень уверенности детекции автомобиля.
enum CarDetectionLevel { low, medium, high }

/// Результат одного срабатывания детектора.
class CarDetection {
  final DateTime timestamp;
  final CarDetectionLevel level;
  final double score;
  final SpectrumFeatures features;
  final String reason;

  const CarDetection({
    required this.timestamp,
    required this.level,
    required this.score,
    required this.features,
    required this.reason,
  });

  String get levelLabel => switch (level) {
        CarDetectionLevel.low => 'LOW',
        CarDetectionLevel.medium => 'MED',
        CarDetectionLevel.high => 'HIGH',
      };
}

/// Сервис захвата звука с микрофона и детекции приближающегося автомобиля
/// на основе спектрального анализа (низкочастотный гул двигателя/шин).
///
/// Не использует ML-модель: чистый Dart FFT, поэтому работает на любом
/// устройстве без дополнительных ассетов и не нагружает батарею.
///
/// Слушатели [ChangeNotifier] оповещаются при каждом подтверждённом
/// срабатывании ([lastDetection] обновляется).
class CarDetectionService extends ChangeNotifier {
  // B (v5.4.0): реестр активных инстанций. Экран калибровки после изменения
  // эталонов в SharedPreferences дёргает reloadProfilesInAllActive() —
  // обновятся и сервис плеера, и live-сервис самого экрана калибровки.
  static final Set<CarDetectionService> _activeInstances =
      <CarDetectionService>{};

  /// Перезагружает эталоны во всех активных сервисах (плеер + калибровочный
  /// экран). Безопасно вызывать когда нет активных — no-op.
  static Future<void> reloadProfilesInAllActive() async {
    for (final s in _activeInstances) {
      await s.loadCalibrationProfiles();
    }
  }

  static const int _sampleRate = 16000;
  static const int _fftSize = 512; // 32 ms @ 16 kHz
  // A2: hop 512 → анализ каждые 32 мс вместо 16 мс (было 256). Снижает
  // нагрузку на main isolate в ~2 раза, что критично для нормальной работы
  // study-таймеров (segmentTimer 150мс, positionTimer 50мс) и TTS handlers.
  static const int _hopSize = 512;

  // Пороги детекции — НЕ const: настраиваются через [_applySensitivity]
  // в зависимости от значения sensitivity (0..1) из настроек. Раньше были
  // const и sensitivity-слайдер в Настройках вообще ни на что не влиял.
  double _minRms = 0.014;
  double _lowDominanceRatio = 2.0;
  double _scoreThresholdLow = 0.45;
  double _scoreThresholdMedium = 0.6;
  double _scoreThresholdHigh = 0.78;
  // Максимальная плоскостность спектра для детекции машины (ниже → больше
  // «пиков», выше → шум/ветер). Настраивается sensitivity.
  double _maxFlatnessForCar = 0.4;
  // Максимальный спектральный центроид (Гц). Настраивается sensitivity.
  double _maxCentroidHz = 800.0;
  // B (v5.4.0): максимальное Mahalanobis distance для классификации кадра
  // как «похожего на профиль». Меньше → строже (нужно очень близко к эталону).
  // Масштабируется от sensitivity: sens=0 → 2.0, sens=1 → 6.0.
  double _maxDistance = 4.0;
  // Фильтр ветра/шагов (A4): если flatness высокая и НЧ доминирование слабое
  // — это шум, а не машина. Если очень громко (rms) и центроид умеренно-низкий
  // — это удар/шаг (например телефон трясётся в кармане при беге).
  static const double _windFlatnessThreshold = 0.35;
  static const double _windLowDomThreshold = 2.0;
  static const double _stepRmsThreshold = 0.08;
  static const double _stepCentroidThreshold = 600.0;

  // Throttle между подтверждёнными срабатываниями (базовый).
  static const Duration _minAlertInterval = Duration(seconds: 2);
  // A5: при активном TTS study mode интервал больше, чтобы не «молотить»
  // alert'ами поверх перевода. Используется только если [isStudySpeaking]
  // колбэк установлен и возвращает true.
  static const Duration _minAlertIntervalDuringStudy = Duration(seconds: 5);

  // Подтверждение: нужно _confirmMinHits срабатываний ПОДРЯД (любой miss
  // сбрасывает счётчик), чтобы избежать ложных на одиночных всплесках.
  // A1 (v5.4.0): 5 кадров × 32 мс = 160 мс непрерывного сигнала достаточно
  // для отсева ветра/шагов, но ловит большинство машин (компромисс между
  // «строго по плану» 8/256 мс и прежним 3/96 мс).
  static const int _confirmMinHits = 5;
  // A2 (v5.4.0): размер окна для moving average score (сглаживание всплесков).
  static const int _scoreWindowSize = 8;
  // A5 (v5.4.0): сколько кадров копить для adaptive noise floor (~3 сек
  // при hop 32 мс). После набора — порог low band = средний фон × 3.
  static const int _noiseFloorFrames = 90;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _streamSub;
  bool _isListening = false;

  late final SpectrumAnalyzer _analyzer;
  final Queue<int> _sampleBuffer = Queue<int>(); // int16 PCM
  // A1 (v5.4.0): счётчик ПОСЛЕДОВАТЕЛЬНЫХ hits — любой miss сбрасывает в 0.
  // Заменяет Queue<bool> _confirmQueue, которая считала hits в окне.
  int _consecutiveHits = 0;
  // A2 (v5.4.0): moving average score — сглаживает всплески на N кадрах.
  final Queue<double> _scoreWindow = Queue<double>();
  // A4+A5 (v5.4.0): абсолютный порог lowBandEnergy. Alert только если low
  // band громче фонового шума. Фон оценивается в первые ~3 сек после start.
  double _minLowBandEnergy = 0.0;
  bool _noiseFloorCalibrated = false;
  final Queue<double> _noiseFloorSamples = Queue<double>();
  DateTime? _lastAlertAt;

  // ---- B (v5.4.0): калибровочные профили + классификатор Mahalanobis ----
  // Сохранённые пользователем эталоны. Если есть ≥1 car + ≥1 noise —
  // детектор переключается с пороговой логики на классификацию по nearest
  // profile (Mahalanobis distance).
  List<CalibrationProfile> _profiles = const <CalibrationProfile>[];
  // true если есть ≥1 car-профиль И ≥1 noise-профиль → используем
  // _classifyFrame; иначе — _thresholdFrame (улучшенная пороговая логика).
  bool _useClassification = false;
  // Кеш последнего результата классификации (для UI калибровки и оверлея).
  ProfileClass? _nearestClass;
  double _nearestDistance = double.infinity;

  CarDetection? _lastDetection;
  CarDetection? get lastDetection => _lastDetection;

  bool _isActive = false;
  bool get isActive => _isActive;

  /// Служебная диагностика для оверлея (последний проанализированный кадр).
  SpectrumFeatures? _lastFeatures;
  SpectrumFeatures? get lastFeatures => _lastFeatures;

  /// Текущая «уверенность» в детекции (0..1), экспоненциально затухает.
  double _currentScore = 0.0;
  double get currentScore => _currentScore;

  String _statusLine = 'idle';
  String get statusLine => _statusLine;

  // ---- B (v5.4.0): публичные геттеры для UI калибровки ----
  /// Сохранённые эталоны (read-only).
  List<CalibrationProfile> get profiles =>
      List<CalibrationProfile>.unmodifiable(_profiles);

  /// Используется ли Mahalanobis-классификация (≥1 car + ≥1 noise профиль).
  bool get useClassification => _useClassification;

  /// Ближайший класс для последнего кадра (null если профилей нет или кадр
  /// далеко от всех). Только для диагностики/UI — не влияет на alert.
  ProfileClass? get nearestClass => _nearestClass;

  /// Mahalanobis distance до ближайшего профиля для последнего кадра.
  double get nearestDistance => _nearestDistance;

  /// Адаптивный порог «похожести» для классификации (для отображения в UI).
  double get maxDistance => _maxDistance;

  /// A5: колбэк «сейчас ли звучит TTS study mode». Устанавливается извне
  /// (PlayerScreen-ом), чтобы детектор мог увеличить throttle при активном
  /// переводе и не «молотить» alert'ами поверх речи.
  bool Function()? isStudySpeaking;

  /// Применяет значение sensitivity (0..1) к порогам детекции.
  ///
  /// Карта (линейная интерполяция между крайними значениями):
  /// - sensitivity = 0.0 → очень строгие пороги (мало срабатываний, только
  ///   уверенные близкие машины)
  /// - sensitivity = 0.5 → средние (стартовая рекомендованная)
  /// - sensitivity = 1.0 → мягкие (много срабатываний, возможны ложные)
  void _applySensitivity(double sensitivity) {
    final s = sensitivity.clamp(0.0, 1.0);
    // Вспомогательная линейная интерполяция.
    double lerp(double low, double high) => low + (high - low) * s;
    // Порог score: при sens=0 нужно 0.60, при sens=1 нужно 0.30.
    _scoreThresholdLow = lerp(0.60, 0.30);
    _scoreThresholdMedium = (_scoreThresholdLow + 0.15).clamp(0.0, 1.0);
    _scoreThresholdHigh = (_scoreThresholdLow + 0.32).clamp(0.0, 1.0);
    // НЧ-доминирование: при sens=0 нужно 2.8x, при sens=1 нужно 1.4x.
    _lowDominanceRatio = lerp(2.8, 1.4);
    // Минимальная громкость: при sens=0 нужно 0.020, при sens=1 нужно 0.008.
    _minRms = lerp(0.020, 0.008);
    // Плоскостность: при sens=0 максимум 0.30 (строгий пик), при sens=1
    // максимум 0.50 (терпимее к шуму).
    _maxFlatnessForCar = lerp(0.30, 0.50);
    // Центроид: при sens=0 максимум 600 Гц, при sens=1 максимум 1000 Гц.
    _maxCentroidHz = lerp(600.0, 1000.0);
    // B (v5.4.0): Mahalanobis _maxDistance. sens=0 → 2.0 (строгий, нужно
    // очень близко к эталону), sens=1 → 6.0 (мягкий, терпимее к отклонениям).
    _maxDistance = lerp(2.0, 6.0);
    debugPrint('🎚 CarDetection: sensitivity=$s → '
        'scoreLow=${_scoreThresholdLow.toStringAsFixed(2)} '
        'lowDom=${_lowDominanceRatio.toStringAsFixed(1)} '
        'rms=${_minRms.toStringAsFixed(3)} '
        'flat=${_maxFlatnessForCar.toStringAsFixed(2)} '
        'cent=${_maxCentroidHz.toStringAsFixed(0)}Hz');
  }

  CarDetectionService() {
    _analyzer = SpectrumAnalyzer(
      fftSize: _fftSize,
      sampleRate: _sampleRate,
      lowBandHi: 300.0,
      midBandHi: 2000.0,
    );
  }

  // ---------------------------------------------------------------------------
  // Запуск / остановка
  // ---------------------------------------------------------------------------

  /// Запрашивает разрешение и запускает захват микрофона + анализ.
  Future<bool> start({double sensitivity = 0.4}) async {
    if (_isActive) return true;
    _statusLine = 'requesting mic';

    // A3: реально применяем sensitivity к порогам — раньше параметр
    // принимался, но ни на что не влиял.
    _applySensitivity(sensitivity);

    try {
      // Используем permission_handler для запроса доступа к микрофону
      // (record 5.x не имеет отдельного метода запроса — только hasPermission).
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          _statusLine = 'no permission';
          debugPrint('✗ CarDetection: microphone permission denied');
          return false;
        }
      }

      // ВАЖНО: audioInterruption: none → НЕ запрашивать Android audio focus.
      // Иначе record_android вызывает requestAudioFocus(AUDIOFOCUS_GAIN), что
      // заставляет BackgroundAudioHandler.pause() (через interruptionEventStream)
      // и блокирует TTS study-mode. manageBluetooth: false → не переключать
      // наушники на Bluetooth SCO (ломает A2DP routing). audioManagerMode:
      // modeNormal → НЕ уходить в IN_COMMUNICATION (нарушает TTS).
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
        audioInterruption: AudioInterruptionMode.none,
        androidConfig: AndroidRecordConfig(
          useLegacy: false,
          muteAudio: false,
          manageBluetooth: false,
          audioSource: AndroidAudioSource.mic,
          speakerphone: false,
          audioManagerMode: AudioManagerMode.modeNormal,
        ),
      ));

      _streamSub = stream.listen(_onAudioData, onError: (Object e) {
        debugPrint('✗ CarDetection stream error: $e');
        _statusLine = 'stream err';
      });

      _isActive = true;
      _isListening = true;
      _currentScore = 0.0;
      _sampleBuffer.clear();
      _consecutiveHits = 0;
      _scoreWindow.clear();
      _minLowBandEnergy = 0.0;
      _noiseFloorCalibrated = false;
      _noiseFloorSamples.clear();
      _nearestClass = null;
      _nearestDistance = double.infinity;
      _statusLine = 'listening';
      _activeInstances.add(this);
      // B (v5.4.0): подгружаем эталоны при старте — если ≥1 car + ≥1 noise,
      // включится Mahalanobis-классификация; иначе — пороговая логика.
      unawaited(loadCalibrationProfiles());
      debugPrint('✓ CarDetection: started (sensitivity=$sensitivity)');
      notifyListeners();
      return true;
    } on PlatformException catch (e) {
      debugPrint('✗ CarDetection start PlatformException: ${e.code} ${e.message}');
      _statusLine = 'err: ${e.code}';
      return false;
    } catch (e) {
      debugPrint('✗ CarDetection start error: $e');
      _statusLine = 'err';
      return false;
    }
  }

  Future<void> stop() async {
    if (!_isActive) return;
    _isActive = false;
    _isListening = false;
    _statusLine = 'stopped';
    _activeInstances.remove(this);
    try {
      await _streamSub?.cancel();
    } catch (_) {}
    _streamSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    _currentScore = 0.0;
    debugPrint('✓ CarDetection: stopped');
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Обработка аудио
  // ---------------------------------------------------------------------------

  // ---- B (v5.4.0): управление калибровочными профилями ----

  /// Ключ SharedPreferences для JSON-массива сохранённых эталонов.
  static const String profilesPrefsKey = 'carCalibrationProfiles';

  /// Загружает эталоны из SharedPreferences и обновляет [_profiles] /
  /// [_useClassification]. Вызывать после старта сервиса и после каждой
  /// операции с эталонами (добавление/удаление) на экране калибровки.
  Future<void> loadCalibrationProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(profilesPrefsKey);
      if (raw == null || raw.isEmpty) {
        setProfiles(const <CalibrationProfile>[]);
        return;
      }
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<CalibrationProfile> loaded = <CalibrationProfile>[];
      for (final dynamic item in decoded) {
        final p = CalibrationProfile.fromJson(item as Map<String, dynamic>);
        if (p != null) {
          loaded.add(p);
        }
      }
      setProfiles(loaded);
    } catch (e) {
      debugPrint('✗ CarDetection.loadCalibrationProfiles: $e');
      setProfiles(const <CalibrationProfile>[]);
    }
  }

  /// Заменяет текущий набор эталонов. Автоматически пересчитывает
  /// [_useClassification] (нужно ≥1 car + ≥1 noise). Потокобезопасно: можно
  /// вызывать во время активной сессии — ветвление _classifyFrame /
  /// _thresholdFrame переключится на следующем кадре.
  void setProfiles(List<CalibrationProfile> profiles) {
    _profiles = List<CalibrationProfile>.of(profiles);
    _recomputeClassificationFlag();
    debugPrint('🎚 CarDetection: ${_profiles.length} profiles loaded, '
        'useClassification=$_useClassification');
  }

  void _recomputeClassificationFlag() {
    bool hasCar = false;
    bool hasNoise = false;
    for (final p in _profiles) {
      if (p.cls.isCar) {
        hasCar = true;
      } else {
        hasNoise = true;
      }
      if (hasCar && hasNoise) break;
    }
    _useClassification = hasCar && hasNoise;
  }

  void _onAudioData(Uint8List bytes) {
    if (!_isListening) return;

    // PCM 16-bit LE → int16 samples.
    final int frameCount = bytes.length ~/ 2;
    final ByteData byteData = bytes.buffer.asByteData(bytes.offsetInBytes, frameCount * 2);
    for (int i = 0; i < frameCount; i++) {
      _sampleBuffer.addLast(byteData.getInt16(i * 2, Endian.little));
    }

    // Извлекаем окна фиксированного размера с перекрытием (hop).
    while (_sampleBuffer.length >= _fftSize) {
      // Берём первые _fftSize семплов.
      final Float32List frame = Float32List(_fftSize);
      final Iterator<int> it = _sampleBuffer.iterator;
      for (int i = 0; i < _fftSize && it.moveNext(); i++) {
        frame[i] = it.current / 32768.0;
      }

      _analyzeFrame(frame);

      // Сдвигаем буфер на hopSize (оставляем overlap).
      for (int i = 0; i < _hopSize && _sampleBuffer.isNotEmpty; i++) {
        _sampleBuffer.removeFirst();
      }
    }
  }

  void _analyzeFrame(Float32List frame) {
    final SpectrumFeatures f = _analyzer.analyze(frame);
    _lastFeatures = f;

    // Релаксация текущей уверенности (экспоненциальный спад).
    _currentScore *= 0.85;

    // ---- A5: Adaptive noise floor (первые ~3 сек после start) ----
    // Копим значения lowBandEnergy в тишине/фоне, потом ставим порог
    // в 3× от среднего. Пока не откалибровано — алерты не выдаем
    // (звук в этот момент всё равно фоновый).
    if (!_noiseFloorCalibrated) {
      _noiseFloorSamples.addLast(f.lowBandEnergy);
      if (_noiseFloorSamples.length >= _noiseFloorFrames) {
        double sum = 0.0;
        for (final double v in _noiseFloorSamples) {
          sum += v;
        }
        final double avg = sum / _noiseFloorSamples.length;
        _minLowBandEnergy = avg * 3.0;
        _noiseFloorCalibrated = true;
        debugPrint('🔇 CarDetection: noise floor calibrated '
            '($_noiseFloorFrames frames), _minLowBandEnergy='
            '${_minLowBandEnergy.toStringAsFixed(0)}');
      }
      _pushConfirm(false);
      _statusLine = 'noise floor ${_noiseFloorSamples.length}/'
          '$_noiseFloorFrames';
      return;
    }

    if (f.rms < _minRms) {
      // Тишина — пропускаем, обновляем только диагностику.
      _pushConfirm(false);
      _statusLine = 'silent rms=${(f.rms * 1000).toStringAsFixed(1)}m';
      return;
    }

    // ---- фильтр шума ветра ----
    // Ветер/шорох дают равномерный (высокий flatness) спектр с небольшим
    // уклоном в НЧ. Машина же даёт явный пик в НЧ → низкий flatness И сильное
    // доминирование НЧ над средними. Если flatness высокая и НЧ-доминирование
    // умеренное (< 2× mid) — это шум, а не машина.
    final double lowOverMid =
        f.midBandEnergy > 1e-9 ? f.lowBandEnergy / f.midBandEnergy : 999.0;
    if (f.spectralFlatness > _windFlatnessThreshold &&
        lowOverMid < _windLowDomThreshold) {
      _pushConfirm(false);
      _statusLine = 'wind filt flat=${f.spectralFlatness.toStringAsFixed(2)} '
          'lo/mid=${lowOverMid.toStringAsFixed(1)}';
      return;
    }

    // ---- фильтр шагов/ударов ----
    // Шаги/удары телефона (бег в кармане) дают очень громкий (rms высокий)
    // широкополосный всплеск с умеренно-низким центроидом. Настоящая машина
    // звучит «гулом» с центроидом < 600 Гц. Если очень громко и центроид выше
    // порога — это удар, не машина.
    if (f.rms > _stepRmsThreshold &&
        f.spectralCentroid > _stepCentroidThreshold) {
      _pushConfirm(false);
      _statusLine = 'step filt rms=${(f.rms * 1000).toStringAsFixed(0)}m '
          'cent=${f.spectralCentroid.toStringAsFixed(0)}';
      return;
    }

    // ---- A4 (v5.4.0): абсолютный порог low band ----
    // Даже при правильном соотношении частот тихий шум с лёгким НЧ-уклоном
    // не должен триггерить alert. Порог вычислен адаптивно в первые 3 сек.
    if (f.lowBandEnergy < _minLowBandEnergy) {
      _pushConfirm(false);
      _statusLine = 'below floor low=${f.lowBandEnergy.toStringAsFixed(0)} '
          '< ${_minLowBandEnergy.toStringAsFixed(0)}';
      return;
    }

    // ---- B (v5.4.0): выбор ветки decision logic ----
    // Все общие пред-фильтры (silence/wind/step/noise floor) уже пройдены.
    // Если есть ≥1 car + ≥1 noise профиль — Mahalanobis-классификация,
    // иначе — улучшенная пороговая логика (Часть A).
    if (_useClassification) {
      _classifyFrame(f);
    } else {
      _thresholdFrame(f);
    }
  }

  /// Пороговая decision logic (Часть A v5.4.0). Используется, когда нет
  /// достаточно эталонов для Mahalanobis-классификации (нет car или нет
  /// noise профиля).
  void _thresholdFrame(SpectrumFeatures f) {
    // ---- Decision logic ----
    // 1. Доминирование НЧ: low должна быть больше mid и high с запасом.
    final bool lowDom = f.lowBandEnergy > f.midBandEnergy * _lowDominanceRatio &&
        f.lowBandEnergy > f.highBandEnergy * _lowDominanceRatio;

    // 2. Низкий центроид (преобладают НЧ).
    final bool lowCentroid = f.spectralCentroid < _maxCentroidHz;

    // 3. Низкая плоскостность (есть пики, не белый шум/ветер).
    final bool peaked = f.spectralFlatness < _maxFlatnessForCar;

    // Нормированная сила НЧ относительно общего спектра (0..1).
    final double totalE = f.lowBandEnergy + f.midBandEnergy + f.highBandEnergy + 1e-9;
    final double lowFrac = (f.lowBandEnergy / totalE).clamp(0.0, 1.0);

    double score = 0.0;
    final List<String> reasons = <String>[];
    if (lowDom) {
      score += 0.4;
      reasons.add('lowDom');
    }
    if (lowCentroid) {
      score += 0.25;
      reasons.add('lowCentroid');
    }
    if (peaked) {
      score += 0.2;
      reasons.add('peaked');
    }
    // A3 (v5.4.0): бонус за высокую долю НЧ — только если НЧ действительно
    // доминирует (lowFrac > 0.6). Раньше давался всегда, и шум с лёгким
    // НЧ-уклоном мог добрать score до порога.
    if (lowFrac > 0.6) {
      score += lowFrac * 0.15;
      reasons.add('lowFrac');
    }
    score = score.clamp(0.0, 1.0);

    // A2 (v5.4.0): moving average score вместо мгновенного — сглаживает
    // короткие всплески (удар, щелчок) на N кадрах.
    _scoreWindow.addLast(score);
    while (_scoreWindow.length > _scoreWindowSize) {
      _scoreWindow.removeFirst();
    }
    double avgScore = 0.0;
    if (_scoreWindow.isNotEmpty) {
      double sum = 0.0;
      for (final double v in _scoreWindow) {
        sum += v;
      }
      avgScore = sum / _scoreWindow.length;
    }

    final bool isHit = avgScore >= _scoreThresholdLow;
    _pushConfirm(isHit);

    // Текущая «сглаженная» уверенность — максимум из релаксированной и avg.
    if (avgScore > _currentScore) {
      _currentScore = avgScore;
    }

    // В пороговом режиме классификация неизвестна.
    _nearestClass = null;
    _nearestDistance = double.infinity;

    _statusLine = 'score=${avgScore.toStringAsFixed(2)} '
        'low=${(f.lowBandEnergy).toStringAsFixed(0)} '
        'cent=${f.spectralCentroid.toStringAsFixed(0)} '
        'flat=${f.spectralFlatness.toStringAsFixed(2)} '
        'streak=$_consecutiveHits';

    // Подтверждение: N hits ПОДРЯД → триггер.
    if (isHit) {
      _maybeFireAlert(avgScore, f, reasons.join('+'));
    }
  }

  /// Mahalanobis-классификация (Часть B v5.4.0). Используется при наличии
  /// ≥1 car + ≥1 noise эталона: для каждого профиля вычисляется distance, и
  /// кадр считается «hit», если ближайший профиль — машина и distance меньше
  /// адаптивного порога [_maxDistance] (масштабируется от sensitivity).
  void _classifyFrame(SpectrumFeatures f) {
    if (_profiles.isEmpty) {
      // Защита: не должно случаться, т.к. _useClassification=false при пустом.
      _pushConfirm(false);
      return;
    }

    CalibrationProfile? nearest;
    double minDist = double.infinity;
    for (final p in _profiles) {
      final double d = p.distanceTo(f);
      if (d < minDist) {
        minDist = d;
        nearest = p;
      }
    }
    _nearestClass = nearest?.cls;
    _nearestDistance = minDist;

    // Hit только если ближайший класс — машина И расстояние меньше порога.
    final bool isCar = nearest != null && nearest.cls.isCar;
    final bool isHit = isCar && minDist < _maxDistance;
    _pushConfirm(isHit);

    // Текущая уверенность: нормируем distance обратно в 0..1 для UI/оверлея.
    // d=0 → 1.0 (точно эталон), d=_maxDistance → 0.0 (на границе срабатывания),
    // d>_maxDistance → clamp в 0.
    if (isHit) {
      final double norm = (1.0 - minDist / _maxDistance).clamp(0.0, 1.0);
      if (norm > _currentScore) {
        _currentScore = norm;
      }
    }

    final String clsLabel = _nearestClass?.name ?? '?';
    _statusLine = 'cls=$clsLabel d=${minDist.toStringAsFixed(1)}/'
        '${_maxDistance.toStringAsFixed(1)} '
        'low=${(f.lowBandEnergy).toStringAsFixed(0)} '
        'streak=$_consecutiveHits';

    if (isHit) {
      _maybeFireAlert(
        _currentScore,
        f,
        '${clsLabel}@${minDist.toStringAsFixed(2)}',
      );
    }
  }

  void _pushConfirm(bool hit) {
    // A1 (v5.4.0): считаем ПОСЛЕДОВАТЕЛЬНЫЕ hits — любой miss сбрасывает.
    if (hit) {
      _consecutiveHits++;
    } else {
      _consecutiveHits = 0;
    }
  }

  void _maybeFireAlert(double score, SpectrumFeatures f, String reason) {
    // A1 (v5.4.0): подтверждение — _confirmMinHits hits ПОДРЯД.
    final bool enoughHits = _consecutiveHits >= _confirmMinHits;
    if (!enoughHits) return;

    // A5: адаптивный throttle. Если study mode сейчас озвучивает перевод,
    // увеличиваем интервал между alert'ами до 5 сек (вместо 2) — даём
    // переводу говорить, не перебивая каждые 2 сек.
    final bool studySpeaking = isStudySpeaking?.call() ?? false;
    final Duration interval =
        studySpeaking ? _minAlertIntervalDuringStudy : _minAlertInterval;

    final DateTime now = DateTime.now();
    final DateTime? last = _lastAlertAt;
    if (last != null && now.difference(last) < interval) {
      return; // throttle
    }

    _lastAlertAt = now;

    final CarDetectionLevel level;
    if (score >= _scoreThresholdHigh) {
      level = CarDetectionLevel.high;
    } else if (score >= _scoreThresholdMedium) {
      level = CarDetectionLevel.medium;
    } else {
      level = CarDetectionLevel.low;
    }

    _lastDetection = CarDetection(
      timestamp: now,
      level: level,
      score: score,
      features: f,
      reason: reason,
    );

    debugPrint('🚗 CarDetection ALERT: ${level.name} score=${score.toStringAsFixed(2)} '
        'reason=$reason rms=${(f.rms * 1000).toStringAsFixed(1)}m '
        'cent=${f.spectralCentroid.toStringAsFixed(0)}Hz flat=${f.spectralFlatness.toStringAsFixed(2)}');

    // Сбрасываем серию подтверждения, чтобы следующее срабатывание
    // требовало нового набора попаданий.
    _consecutiveHits = 0;

    notifyListeners();
  }

  /// Сериализация последней детекции для диагностического оверлея.
  String debugDump() {
    final f = _lastFeatures;
    final buf = StringBuffer();
    buf.writeln('CAR detect ${_isActive ? "ON" : "OFF"}');
    buf.writeln('status: $_statusLine');
    if (f != null) {
      buf.writeln('low=${f.lowBandEnergy.toStringAsFixed(0)} '
          'mid=${f.midBandEnergy.toStringAsFixed(0)} '
          'hi=${f.highBandEnergy.toStringAsFixed(0)}');
      buf.writeln('centroid=${f.spectralCentroid.toStringAsFixed(0)}Hz '
          'flat=${f.spectralFlatness.toStringAsFixed(2)} '
          'rms=${(f.rms * 1000).toStringAsFixed(1)}m');
    }
    buf.writeln('streak=$_consecutiveHits/$_confirmMinHits '
        'score=${_currentScore.toStringAsFixed(2)} '
        'floor=${_noiseFloorCalibrated ? _minLowBandEnergy.toStringAsFixed(0) : "calib"}');
    final d = _lastDetection;
    if (d != null) {
      buf.writeln('last: ${d.levelLabel} ${d.score.toStringAsFixed(2)} '
          '@${d.timestamp.toIso8601String().substring(11, 19)}');
    }
    return buf.toString().trimRight();
  }
}
