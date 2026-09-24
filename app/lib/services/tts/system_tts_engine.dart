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
  /// НЕ final (v5.8.11): после долгого простоя приложения Android отвязывает
  /// TTS-сервис, и единственный способ перебиндиться — создать НОВЫЙ
  /// FlutterTts (см. [reset]).
  FlutterTts _tts = FlutterTts();
  Completer<void>? _speakCompleter;

  /// v5.8.11: после таймаута platform-вызова speak() выговор «брошен», но
  /// flutter_tts об этом не знает — его поздний completion/cancel может
  /// прийти, когда `_speakCompleter` уже принадлежит СЛЕДУЮЩЕЙ фразе →
  /// фальшивый успех и ранний переход строки. По таймауту вызываем _tts.stop()
  /// и выставляем флаг: ровно одно ближайшее событие съедается.
  bool _dropNextCompletion = false;

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
      // v5.8.11: исключение платформенного вызова ≠ «язык недоступен». После
      // звонка/beep'а уведомления/долгого простоя TTS-сервис переподключается
      // и вызовы падают/висят — раньше это лочило available=false, и study
      // молчал до конца песни («пробы бессмысленны»). Лочим недоступность
      // ТОЛЬКО при честном ответе «нет голосов» (ветки выше).
      debugPrint('⚠ SystemTtsEngine: setLanguage($locale) transient error '
          '(service rebinding?), keeping availability: $e');
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

    // Применяем параметры речи прямо перед speak (как в координаторе 5.4.0),
    // но с таймаутом (v5.8.8): после звонка/beep'а уведомления системный
    // TTS-сервис переподключается, и platform-вызов может зависнуть НАВСЕГДА.
    // Раньше speak вис на param-шаге до study-watchdog, и один инцидент
    // дважды набивал _ttsFailStreak → перевод замолкал до конца песни.
    // По таймауту просто идём дальше — следующий шаг либо заработает, либо
    // честно засчитается одной ошибкой.
    await _safeParam(_tts.setLanguage(_ttsLanguage), 'setLanguage');
    await _safeParam(_tts.setSpeechRate(rate), 'setSpeechRate');
    if (pitch != null) {
      await _safeParam(_tts.setPitch(pitch), 'setPitch');
    }
    await _safeParam(_tts.setVolume(_lastVolume), 'setVolume');

    final completer = Completer<void>();
    _speakCompleter = completer;
    dynamic result;
    try {
      result = await _tts.speak(text).timeout(const Duration(seconds: 3));
      // flutter_tts возвращает 1 при успехе, 0 при неудаче; при неудаче ни
      // completion-, ни error-handler не придёт → completer висел бы вечно.
      // Явной неудачей считаем ТОЛЬКО 0/false: нестандартные значения некоторых
      // ROM не должны завершать ожидание раньше конца фразы (речь бы
      // обрывалась следующим stop). v5.8.11: неудача завершает completer
      // ОШИБКОЙ — study должен засчитать сбой в стринг, иначе перевод после
      // переподключения TTS-сервиса молчал бы «успешно» до конца песни.
      if (result == 0 || result == '0' || result == false) {
        debugPrint('⚠ SystemTtsEngine: speak() returned $result (failure)');
        _speakCompleter = null;
        if (!completer.isCompleted) {
          completer.completeError(StateError('tts speak refused (result=$result)'));
        }
        return;
      }
    } on TimeoutException {
      // Сам platform-вызов speak завис (переподключение TTS-сервиса после
      // звонка/уведомления/долгого простоя приложения). v5.8.11: завершаем
      // ОШИБКОЙ, а не «успехом» (раньше study сбрасывал стринг — тишина без
      // единого сбоя жила вечно); отменяем брошенный выговор и съедаем его
      // поздний completion (см. [_dropNextCompletion]).
      debugPrint('⚠ SystemTtsEngine: speak() platform call timed out');
      _speakCompleter = null;
      _dropNextCompletion = true;
      try {
        await _tts.stop().timeout(const Duration(seconds: 2));
      } catch (_) {}
      if (!completer.isCompleted) {
        completer.completeError(
            TimeoutException('tts speak platform call hung',
                const Duration(seconds: 3)));
      }
      return;
    } catch (e) {
      debugPrint('✗ SystemTtsEngine: speak() error: $e');
      _speakCompleter = null;
      if (!completer.isCompleted) {
        completer.completeError(StateError('tts speak error: $e'));
      }
      return;
    }
    return completer.future;
  }

  /// Полный пересбор подключения к системному TTS-сервису (v5.8.11). После
  /// долгого простоя приложения в памяти Android отвязывает сервис, а
  /// идемпотентный [initialize] (_isReady залип) связь не чинит — вызовы
  /// виснут до таймаутов. Создаём НОВЫЙ FlutterTts (свежий bind), заново
  /// ставим handlers/движок/язык. Поздние события СТАРОГО инстанса до нового
  /// completer не дотягиваются (handlers — per-instance).
  @override
  Future<void> reset() async {
    debugPrint('🎧 SystemTtsEngine: reset (rebinding system TTS service)');
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
    final lang = _ttsLanguage;
    try {
      await _tts.stop().timeout(const Duration(seconds: 2));
    } catch (_) {}
    _tts = FlutterTts();
    _dropNextCompletion = false;
    _isReady = false;
    await initialize();
    await setLanguage(lang);
    notifyListeners();
  }

  /// Применяет параметр речи с таймаутом: зависший platform-вызов (TTS-сервис
  /// переподключается после звонка/уведомления) не должен вешать speak()
  /// целиком (v5.8.8).
  Future<void> _safeParam(Future<dynamic> param, String what) async {
    try {
      await param.timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('⚠ SystemTtsEngine: $what timed out/failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
    try {
      // Таймаут (v5.8.5): зависший stop() блокирует TtsCoordinator.
      // _interruptCurrent → каждый следующий speak виснет до study-watchdog.
      await _tts.stop().timeout(const Duration(seconds: 2));
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
    if (_dropNextCompletion) {
      // Позднее событие брошенного по таймауту выговора (v5.8.11): без этого
      // оно закрывало бы completer СЛЕДУЮЩЕЙ фразы → фальшивый успех и
      // ранний переход строки.
      _dropNextCompletion = false;
      debugPrint('🎧 SystemTtsEngine: stale completion of abandoned '
          'utterance dropped');
      return;
    }
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
  }

  void _handleError(Object e) {
    if (_dropNextCompletion) {
      _dropNextCompletion = false;
      debugPrint('🎧 SystemTtsEngine: stale error of abandoned '
          'utterance dropped');
      return;
    }
    debugPrint('✗ SystemTtsEngine error: $e');
    final c = _speakCompleter;
    _speakCompleter = null;
    // Ошибка движка — genuine-сбой (v5.8.11): завершаем ОШИБКОЙ, чтобы study
    // засчитал стринг и запустил cooldown-восстановление, а не молчал
    // «успешно» до конца песни.
    if (c != null && !c.isCompleted) {
      c.completeError(StateError('tts engine error: $e'));
    }
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
