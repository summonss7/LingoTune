import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Приоритет TTS-запроса. Определяет поведение при конфликте.
///
/// Причина введения: `flutter_tts` использует единый `MethodChannel('flutter_tts')`
/// на всё приложение — два экземпляра `FlutterTts` перетирают друг другу
/// `setCompletionHandler`/`setErrorHandler`, из-за чего TTS study mode
/// «зависал» после срабатывания детекции машин (watchdog убивал озвучку
/// перевода на всю сессию).
///
/// [TtsCoordinator] — единственный держатель `FlutterTts` в приложении;
/// все запросы на речь идут через [speak] с приоритетом.
enum TtsPriority {
  /// Озвучка перевода в study mode. Высший приоритет.
  ///
  /// Если в момент запроса уже звучит alert — он прерывается (completer
  /// alert-запроса завершается немедленно, чтобы alert-логика не ждала).
  study,

  /// Голосовое предупреждение детекции машин. Низший приоритет.
  ///
  /// Если в момент запроса звучит перевод (study) — alert **пропускается**
  /// (completer завершается сразу, без фактического вызова speak). Это
  /// гарантирует, что детекция никогда не перебивает перевод.
  alert,
}

class _TtsRequest {
  final String text;
  final TtsPriority priority;
  final String? locale;
  final double? rate;
  final double? pitch;
  final double? volume;
  final Completer<void> completer;

  const _TtsRequest({
    required this.text,
    required this.priority,
    required this.completer,
    this.locale,
    this.rate,
    this.pitch,
    this.volume,
  });
}

/// Единый координатор синтеза речи для всего приложения.
///
/// Один `FlutterTts`, одна пара `setCompletionHandler`/`setErrorHandler`.
/// Запросы [speak] упорядочены по приоритету: study-mode перевод всегда
/// доминирует над alert-голосом детекции машин (см. [TtsPriority]).
///
/// Конфигурационные методы (`setLanguage`, `isLanguageAvailable`, `setEngine`,
/// `getVoices`, `setVoice` и т.д.) делегируются через геттер [tts] — StudyMode
/// вызывает их напрямую для настройки движка/языка, а речь — через [speak].
class TtsCoordinator {
  TtsCoordinator._();
  static final TtsCoordinator instance = TtsCoordinator._();

  final FlutterTts _tts = FlutterTts();
  _TtsRequest? _current;
  bool _initialized = false;

  // Engine/language state (для диагностики и для applyConfiguredEngine).
  List<String> _availableEngines = const [];
  String? _activeEngine;
  String? _selectedEngine;

  /// Прямой доступ к underlying FlutterTts — ТОЛЬКО для конфигурации
  /// (setLanguage, isLanguageAvailable, setEngine, getVoices, setVoice,
  /// getDefaultEngine, setPitch/setVolume когда нет речи). Речь —
  /// ИСКЛЮЧИТЕЛЬНО через [speak] / [stop], чтобы приоритеты соблюдались.
  FlutterTts get tts => _tts;

  bool get isInitialized => _initialized;
  bool get isSpeaking => _current != null;
  List<String> get availableEngines => List.unmodifiable(_availableEngines);
  String? get activeEngine => _activeEngine;
  String? get selectedEngine => _selectedEngine;

  /// Ленивая инициализация (идемпотентная). Должна вызываться до первого
  /// speak(). Handlers ставятся ОДИН раз — повторная установка не нужна,
  /// т.к. _tts инстанс единственный на приложение.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final result = await _tts.getEngines;
      _availableEngines = (result as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      debugPrint('🎧 TtsCoordinator: engines = $_availableEngines');
    } catch (e) {
      debugPrint('⚠ TtsCoordinator: getEngines error: $e');
    }

    await _applyConfiguredEngine();

    // ЕДИНСТВЕННОЕ место установки handlers на всё приложение.
    _tts.setCompletionHandler(_handleCompletion);
    _tts.setErrorHandler((e) => _handleError(e));

    debugPrint('✓ TtsCoordinator: initialized (engine=$_selectedEngine)');
  }

  // -------------------------------------------------------------------------
  // Speak / Stop — единственный путь речи в приложении
  // -------------------------------------------------------------------------

  /// Произносит [text] с заданным [priority]. Future завершается, когда речь
  /// закончена, либо когда запрос был пропущен/вытеснен.
  ///
  /// Поведение при конфликте (см. [TtsPriority]):
  /// - priority=study + текущий=alert → текущий прерывается, study звучит
  /// - priority=study + текущий=study   → текущий прерывается (новая строка)
  /// - priority=alert + текущий=study   → **alert пропускается** (завершается
  ///   сразу), перевод не прерывается
  /// - priority=alert + нет речи        → alert звучит
  /// - priority=alert + текущий=alert   → текущий прерывается, новый звучит
  Future<void> speak(
    String text, {
    TtsPriority priority = TtsPriority.study,
    String? locale,
    double? rate,
    double? pitch,
    double? volume,
  }) async {
    await ensureInitialized();
    final completer = Completer<void>();

    // Alert во время study → сразу отказываем (без прерывания перевода).
    if (priority == TtsPriority.alert &&
        _current != null &&
        _current!.priority == TtsPriority.study) {
      debugPrint('⏭ TtsCoordinator: alert suppressed (study is speaking)');
      return;
    }

    // Прерываем текущий запрос (если есть), завершая его completer.
    await _interruptCurrent();

    final req = _TtsRequest(
      text: text,
      priority: priority,
      completer: completer,
      locale: locale,
      rate: rate,
      pitch: pitch,
      volume: volume,
    );
    _current = req;

    // Применяем параметры речи прямо перед speak — минимизирует гонки.
    if (locale != null) {
      try {
        await _tts.setLanguage(locale);
      } catch (e) {
        debugPrint('⚠ TtsCoordinator: setLanguage($locale) error: $e');
      }
    }
    if (rate != null) {
      try {
        await _tts.setSpeechRate(rate);
      } catch (_) {}
    }
    if (pitch != null) {
      try {
        await _tts.setPitch(pitch);
      } catch (_) {}
    }
    if (volume != null) {
      try {
        await _tts.setVolume(volume);
      } catch (_) {}
    }

    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('✗ TtsCoordinator: speak() error: $e');
      _current = null;
      if (!completer.isCompleted) completer.complete();
    }
    return completer.future;
  }

  /// Полная остановка речи. Завершает текущий completer (если есть).
  Future<void> stop() async {
    await _interruptCurrent();
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> _interruptCurrent() async {
    final cur = _current;
    _current = null;
    if (cur != null && !cur.completer.isCompleted) {
      cur.completer.complete();
    }
    if (cur != null) {
      try {
        await _tts.stop();
      } catch (_) {}
    }
  }

  void _handleCompletion() {
    final cur = _current;
    _current = null;
    if (cur != null && !cur.completer.isCompleted) {
      cur.completer.complete();
    }
  }

  void _handleError(Object e) {
    debugPrint('✗ TtsCoordinator error: $e');
    final cur = _current;
    _current = null;
    if (cur != null && !cur.completer.isCompleted) {
      cur.completer.complete();
    }
  }

  // -------------------------------------------------------------------------
  // Engine configuration (делегируется из StudyModeService)
  // -------------------------------------------------------------------------

  /// Применяет выбранный движок: пользовательский (из prefs 'ttsEngine'),
  /// иначе Google TTS если доступен, иначе системный дефолт.
  Future<void> _applyConfiguredEngine() async {
    String? configured;
    try {
      final prefs = await SharedPreferences.getInstance();
      configured = prefs.getString('ttsEngine');
    } catch (_) {}

    String? desired;
    if (configured != null &&
        configured.isNotEmpty &&
        _availableEngines.contains(configured)) {
      desired = configured;
    } else if (_availableEngines.contains('com.google.android.tts')) {
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
          _selectedEngine = desired;
          debugPrint('🎧 TtsCoordinator: switched engine -> $desired');
        } else {
          _selectedEngine = def;
        }
      } catch (e) {
        _selectedEngine = def;
        debugPrint('⚠ TtsCoordinator: setEngine($desired) error: $e');
      }
    } else {
      _selectedEngine = def;
    }
    _activeEngine = _selectedEngine ?? def;
  }

  /// Повторно применяет выбранный движок (например, после смены в Настройках).
  /// Делегируется из StudyModeService.applyConfiguredEngine.
  Future<void> applyConfiguredEngine() async {
    if (!_initialized) return;
    await _applyConfiguredEngine();
  }
}
