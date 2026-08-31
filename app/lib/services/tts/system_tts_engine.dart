import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tts_engine.dart';

/// Системный TTS-движок — обёртка над `FlutterTts`.
///
/// Это **точная копия** TTS-логики `TtsCoordinator` + `_initTts`/`_setTtsLanguage`
/// версии 5.4.0. Поведение 1-в-1, без изменений — это наш надёжный fallback,
/// если что-то пойдёт не так с офлайн-движком (переключи `ttsSource='system'`).
///
/// Источник: перенос логики из `tts_coordinator.dart` (engine-config, handlers,
/// speak-via-completer) и `study_mode_service.dart:370-534` (init, setLanguage,
/// voice-fallback, locale mapping).
class SystemTtsEngine extends TtsEngine {
  final FlutterTts _tts = FlutterTts();
  Completer<void>? _speakCompleter;

  bool _isReady = false;
  bool _langAvailable = true;
  String _ttsLanguage = 'ru-RU';
  List<String> _engines = const [];
  String? _selectedEngineValue;
  String? _activeEngineValue;
  int _genMsValue = 0;

  // Кеш последнего применённого значения speech rate (для повторного
  // применения после setEngine / setLanguage, как в 5.4.0).
  double _lastRate = 0.5;
  // Кеш последнего применённого значения громкости речи (0.0–1.0).
  double _lastVolume = 1.0;

  SystemTtsEngine();

  @override
  bool get isReady => _isReady;

  @override
  bool get isLanguageAvailable => _langAvailable;

  @override
  String? get activeEngine => _activeEngineValue;

  @override
  String? get selectedEngine => _selectedEngineValue;

  @override
  List<String> get availableEngines => List.unmodifiable(_engines);

  @override
  int get lastGenerationMs => _genMsValue;

  @override
  TtsSource get source => TtsSource.system;

  /// Идемпотентная инициализация. Перенос ensureInitialized() из
  /// TtsCoordinator версии 5.4.0.
  @override
  Future<void> initialize() async {
    if (_isReady) return;
    _isReady = true;
    try {
      final result = await _tts.getEngines;
      _engines = (result as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      debugPrint('🎧 SystemTtsEngine: engines = $_engines');
    } catch (e) {
      debugPrint('⚠ SystemTtsEngine: getEngines error: $e');
    }
    await _applyConfiguredEngine();

    // ЕДИНСТВЕННОЕ место установки handlers (как в координаторе 5.4.0).
    _tts.setCompletionHandler(_handleCompletion);
    _tts.setErrorHandler((e) => _handleError(e));
    // Отменённая фраза (потеря аудиофокуса / звонок) БЕЗ cancel-handler не
    // порождает ни completion-, ни error-событие → completer висел бы вечно.
    // stop() зануляет _speakCompleter до вызова движка, так что повторное
    // завершение здесь безопасно.
    _tts.setCancelHandler(_handleCompletion);

    // Применяем дефолтные параметры речи (как _initTts в 5.4.0).
    try {
      await _tts.setSpeechRate(_lastRate);
    } catch (_) {}
    try {
      await _tts.setPitch(1.0);
    } catch (_) {}
    try {
      await _tts.setVolume(_lastVolume);
    } catch (_) {}

    debugPrint('✓ SystemTtsEngine: initialized (engine=$_selectedEngineValue)');
    notifyListeners();
  }

  /// Перенос _setTtsLanguage + _trySetVoiceByLocale из StudyModeService 5.4.0.
  /// Проверяет доступность языка (isLanguageAvailable → getVoices/setVoice
  /// fallback для китайских ROM).
  @override
  Future<void> setLanguage(String languageCode) async {
    if (!_isReady) await initialize();
    final locale = _mapLanguageToLocale(languageCode);
    _ttsLanguage = locale;
    bool available = true;
    try {
      final res = await _tts.isLanguageAvailable(locale);
      available = res == true;
      if (available) {
        await _tts.setLanguage(locale);
        debugPrint('✓ SystemTtsEngine: language set to $locale');
      } else {
        // Fallback: китайские ROM лгут в isLanguageAvailable.
        final voiceFound = await _trySetVoiceByLocale(locale);
        if (voiceFound) {
          available = true;
          debugPrint(
              '✓ SystemTtsEngine: $locale unavailable per API, voice set via setVoice');
        } else {
          debugPrint(
              '⚠ SystemTtsEngine: language $locale NOT available (no voice)');
        }
      }
    } catch (e) {
      available = false;
      debugPrint('⚠ SystemTtsEngine: setLanguage($locale) error: $e');
    }
    final changed = _langAvailable != available;
    _langAvailable = available;
    if (changed) notifyListeners();
  }

  /// Перенос speak() из TtsCoordinator 5.4.0: параметры применяются прямо
  /// перед _tts.speak, completer resolves по completion/error handler.
  @override
  Future<void> speak(
    String text, {
    required double rate,
    double? pitch,
    double? volume,
  }) async {
    if (!_isReady) await initialize();

    // Завершаем любой активный speak (если остался) — safety.
    if (_speakCompleter != null && !_speakCompleter!.isCompleted) {
      _speakCompleter!.complete();
      _speakCompleter = null;
      try {
        await _tts.stop();
      } catch (_) {}
    }

    _lastRate = rate;
    if (volume != null) {
      _lastVolume = volume.clamp(0.0, 1.0);
    }

    // Применяем параметры речи прямо перед speak (как в координаторе 5.4.0).
    try {
      await _tts.setLanguage(_ttsLanguage);
    } catch (_) {}
    try {
      await _tts.setSpeechRate(rate);
    } catch (_) {}
    if (pitch != null) {
      try {
        await _tts.setPitch(pitch);
      } catch (_) {}
    }
    try {
      await _tts.setVolume(_lastVolume);
    } catch (_) {}

    final completer = Completer<void>();
    _speakCompleter = completer;
    try {
      final result = await _tts.speak(text);
      // flutter_tts возвращает 1 при успехе, 0 при неудаче; при неудаче ни
      // completion-, ни error-handler не придёт → completer висел бы вечно.
      // Явной неудачей считаем ТОЛЬКО 0/false: нестандартные значения некоторых
      // ROM не должны завершать ожидание раньше конца фразы (речь бы
      // обрывалась следующим stop).
      if (result == 0 || result == '0' || result == false) {
        debugPrint('⚠ SystemTtsEngine: speak() returned $result (failure)');
        _speakCompleter = null;
        if (!completer.isCompleted) completer.complete();
        return;
      }
    } catch (e) {
      debugPrint('✗ SystemTtsEngine: speak() error: $e');
      _speakCompleter = null;
      if (!completer.isCompleted) completer.complete();
      return;
    }
    return completer.future;
  }

  @override
  Future<void> stop() async {
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Перенос _applyConfiguredEngine + applyConfiguredEngine из TtsCoordinator
  /// 5.4.0. Читает prefs['ttsEngine'], приоритет Google TTS, иначе дефолт.
  @override
  Future<void> applyConfiguredEngine() async {
    if (!_isReady) return;
    await _applyConfiguredEngine();
    // Повторно применяем rate/pitch/volume после смены движка (как в 5.4.0).
    try {
      await _tts.setSpeechRate(_lastRate);
    } catch (_) {}
    try {
      await _tts.setPitch(1.0);
    } catch (_) {}
    try {
      await _tts.setVolume(_lastVolume);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _applyConfiguredEngine() async {
    String? configured;
    try {
      final prefs = await SharedPreferences.getInstance();
      configured = prefs.getString('ttsEngine');
    } catch (_) {}

    String? desired;
    if (configured != null &&
        configured.isNotEmpty &&
        _engines.contains(configured)) {
      desired = configured;
    } else if (_engines.contains('com.google.android.tts')) {
      desired = 'com.google.android.tts';
    }

    String? def;
    try {
      def = (await _tts.getDefaultEngine)?.toString();
    } catch (_) {}

    if (desired != null && desired != def) {
      try {
        final res = await _tts.setEngine(desired);
        if (res == 1) {
          _selectedEngineValue = desired;
          debugPrint('🎧 SystemTtsEngine: switched engine -> $desired');
        } else {
          _selectedEngineValue = def;
        }
      } catch (e) {
        _selectedEngineValue = def;
        debugPrint('⚠ SystemTtsEngine: setEngine($desired) error: $e');
      }
    } else {
      _selectedEngineValue = def;
    }
    _activeEngineValue = _selectedEngineValue ?? def;
  }

  // -------------------------------------------------------------------
  // Handlers — завершают активный completer.
  // -------------------------------------------------------------------

  void _handleCompletion() {
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
  }

  void _handleError(Object e) {
    debugPrint('✗ SystemTtsEngine error: $e');
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
  }

  // -------------------------------------------------------------------
  // Локаль-маппинг (перенос из StudyModeService 5.4.0)
  // -------------------------------------------------------------------

  /// Tries to find and apply a voice matching [locale] via getVoices/setVoice.
  /// Workaround для движков, лгущих в isLanguageAvailable (китайские ROM).
  /// Перенос 1-в-1 из StudyModeService 5.4.0.
  Future<bool> _trySetVoiceByLocale(String locale) async {
    try {
      final voices = await _tts.getVoices;
      if (voices == null) return false;
      final norm = locale.toLowerCase().replaceAll('_', '-');
      final langPrefix = norm.split('-').first;
      for (final v in voices) {
        if (v is! Map) continue;
        final rawLocale = (v['locale'] ?? '').toString();
        final vLocale = rawLocale.toLowerCase().replaceAll('_', '-');
        if (vLocale == norm ||
            vLocale.startsWith('$langPrefix-') ||
            vLocale == langPrefix) {
          final name = v['name'];
          if (name != null) {
            final res = await _tts.setVoice({'name': name, 'locale': rawLocale});
            return res == 1;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠ SystemTtsEngine: getVoices/setVoice fallback error: $e');
    }
    return false;
  }

  String _mapLanguageToLocale(String code) {
    const map = {
      'ru': 'ru-RU',
      'en': 'en-US',
      'ro': 'ro-RO',
      'fr': 'fr-FR',
      'de': 'de-DE',
      'es': 'es-ES',
      'it': 'it-IT',
      'pt': 'pt-PT',
      'zh': 'zh-CN',
      'ar': 'ar-SA',
      'uk': 'uk-UA',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'trans': 'ru-RU',
    };
    // Поддержка как 'ru', так и 'ru-RU' на входе.
    final lc = code.toLowerCase();
    if (map.containsKey(lc)) return map[lc]!;
    final key = lc.split('-').first;
    return map[key] ?? 'en-US';
  }

  @override
  void dispose() {
    // Завершаем активный completer, чтобы awaiter (TtsCoordinator.speak /
    // StudyModeService._speak) не висел вечно. Раньше здесь было
    // `_speakCompleter = null` без complete — если dispose звался во время
    // речи, awaiter зависал навсегда.
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
    // FlutterTts не имеет явного dispose в API 4.2.0; stop достаточно.
    try {
      _tts.stop();
    } catch (_) {}
    _isReady = false;
    super.dispose();
  }
}
