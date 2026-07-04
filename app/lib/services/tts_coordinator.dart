import 'dart:async';

import 'package:flutter/foundation.dart';

import 'tts/offline_tts_engine.dart';
import 'tts/system_tts_engine.dart';
import 'tts/tts_engine.dart';

/// Приоритет TTS-запроса. Определяет поведение при конфликте.
///
/// Причина введения (в версии 5.3.2): разные источники TTS (study mode и
/// alert детекции машин) не должны перебивать друг друга. Координатор хранит
/// единую очередь запросов с приоритетами и маршрутизирует их в активный
/// [TtsEngine].
enum TtsPriority {
  /// Озвучка перевода в study mode. Высший приоритет.
  ///
  /// Если в момент запроса уже звучит alert — он прерывается.
  study,

  /// Голосовое предупреждение детекции машин. Низший приоритет.
  ///
  /// Если в момент запроса звучит перевод (study) — alert **пропускается**
  /// (Future завершается сразу, без фактического вызова speak). Это
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
/// Архитектура (с версии 5.5.0): координатор держит **полиморфный**
/// [TtsEngine] (`SystemTtsEngine` или `OfflineTtsEngine`), выбираемый по
/// настройке `ttsSource`. Все запросы речи упорядочены по приоритету:
/// study-mode перевод всегда доминирует над alert-голосом детекции машин.
///
/// Источник движка меняется через [setTtsSource]. Координатор отвечает за:
/// 1. Создание/утилизацию `TtsEngine` (free нативной памяти при смене).
/// 2. Приоритетную очередь ([speak] / [stop]).
/// 3. Проксирование диагностических геттеров ([activeEngine], ...) наружу.
///
/// Конфигурация языка и движка делегируется в активный `TtsEngine`.
class TtsCoordinator extends ChangeNotifier {
  TtsCoordinator._();
  static final TtsCoordinator instance = TtsCoordinator._();

  TtsEngine? _engine;

  /// Текущий активный запрос (для приоритетной очереди). null = ничего не
  /// говорится.
  _TtsRequest? _current;

  /// Выбранный источник (соответствует `_engine.source` когда engine создан).
  TtsSource _source = TtsSource.offline;

  /// Текущий язык перевода ('ru', 'en', ...). Сохраняется между сменами
  /// движка, чтобы новый engine применял тот же язык.
  String _languageCode = 'ru';

  bool _initialized = false;

  /// Сериализует [setTtsSource] / [setLanguage]. При холодном старте их
  /// одновременно дёргают `StudyModeService._initTts` (через
  /// [ensureInitialized]) и `PlayerScreen._applyTtsSource` (post-frame). Без
  /// очереди оба видели `_initialized=false` и создавали по
  /// `OfflineTtsEngine` (со своим `OfflineTtsIsolate`), грузя 63 МБ модель
  /// дважды; «проигравший» гонку движок оставался с незагруженной моделью →
  /// `_langAvailable=false` → вечный fallback на системный TTS (симптом
  /// «после полного выхода офлайн слетал на систему»). Очередь гарантирует
  /// один движок/изолятор, второй вызов уходит в no-op ветку.
  Future<void>? _sourceLock;

  // -------------------------------------------------------------------
  // Engine management
  // -------------------------------------------------------------------

  /// Текущий движок (или null до первого [ensureInitialized]).
  TtsEngine? get engine => _engine;

  /// Текущий источник (offline/system). Может меняться через [setTtsSource].
  TtsSource get currentSource => _source;

  /// Текущий язык перевода.
  String get languageCode => _languageCode;

  /// Переключает источник TTS. Создаёт новый [TtsEngine] соответствующего
  /// типа, инициализирует его и применяет текущий язык. Старый engine
  /// останавливается (с прерыванием активной речи) и dispose'ится.
  ///
  /// Если новый source совпадает с текущим — no-op (engine уже корректен).
  Future<void> setTtsSource(
    TtsSource source, {
    String? languageCode,
  }) async {
    // Сериализация: ждём завершения предыдущего setTtsSource/setLanguage,
    // иначе при холодном старте два concurrent-вызова создавали два движка.
    final prev = _sourceLock;
    final done = Completer<void>();
    _sourceLock = done.future;
    try {
      if (prev != null) await prev;
      await _setTtsSourceInner(source, languageCode: languageCode);
    } finally {
      if (identical(_sourceLock, done.future)) _sourceLock = null;
      if (!done.isCompleted) done.complete();
    }
  }

  Future<void> _setTtsSourceInner(
    TtsSource source, {
    String? languageCode,
  }) async {
    if (languageCode != null) _languageCode = languageCode;

    if (_initialized && _source == source && _engine != null) {
      // Тот же источник — только перер_apply язык если нужно.
      try {
        await _engine!.setLanguage(_languageCode);
      } catch (e) {
        debugPrint('⚠ TtsCoordinator: setLanguage on existing engine: $e');
      }
      return;
    }

    debugPrint('🔄 TtsCoordinator: switching source → $source');

    // Останавливаем активную речь и текущий engine.
    await _interruptCurrent();
    final oldEngine = _engine;
    _engine = null;
    if (oldEngine != null) {
      oldEngine.removeListener(_onEngineChanged);
      try {
        oldEngine.dispose();
      } catch (e) {
        debugPrint('⚠ TtsCoordinator: old engine dispose: $e');
      }
    }

    // Создаём новый engine.
    final TtsEngine newEngine;
    switch (source) {
      case TtsSource.offline:
        newEngine = OfflineTtsEngine();
        break;
      case TtsSource.system:
        newEngine = SystemTtsEngine();
        break;
    }
    newEngine.addListener(_onEngineChanged);

    try {
      await newEngine.initialize();
      await newEngine.setLanguage(_languageCode);
    } catch (e, st) {
      debugPrint('✗ TtsCoordinator: new engine init failed: $e\n$st');
      // Fallback: если offline не смог — попробуем system.
      if (source == TtsSource.offline) {
        debugPrint('↩ TtsCoordinator: fallback to SystemTtsEngine');
        newEngine.removeListener(_onEngineChanged);
        try {
          newEngine.dispose();
        } catch (_) {}
        final fb = SystemTtsEngine();
        fb.addListener(_onEngineChanged);
        try {
          await fb.initialize();
          await fb.setLanguage(_languageCode);
          _engine = fb;
          _source = TtsSource.system;
        } catch (e2) {
          debugPrint('✗ TtsCoordinator: even system engine failed: $e2');
          fb.removeListener(_onEngineChanged);
        }
      } else {
        newEngine.removeListener(_onEngineChanged);
      }
      _initialized = _engine != null;
      notifyListeners();
      return;
    }

    _engine = newEngine;
    _source = source;
    _initialized = true;
    debugPrint('✓ TtsCoordinator: source=$source ready');
    notifyListeners();
  }

  void _onEngineChanged() {
    notifyListeners();
  }

  // -------------------------------------------------------------------
  // Initialization / language / engine config
  // -------------------------------------------------------------------

  /// Ленивая идемпотентная инициализация. Если source уже задан —
  /// создаёт engine. Безопасна для повторных вызовов.
  Future<void> ensureInitialized() async {
    if (_initialized && _engine != null) return;
    await setTtsSource(_source, languageCode: _languageCode);
  }

  /// Сменить язык перевода (делегирует в engine). Сериализован общей очередью
  /// с [setTtsSource], чтобы не вызвать `setLanguage` на движке, который в
  /// этот момент утилизируется/пересоздаётся.
  Future<void> setLanguage(String languageCode) async {
    final prev = _sourceLock;
    final done = Completer<void>();
    _sourceLock = done.future;
    try {
      if (prev != null) await prev;
      _languageCode = languageCode;
      if (_engine != null) {
        try {
          await _engine!.setLanguage(languageCode);
        } catch (e) {
          debugPrint('⚠ TtsCoordinator: setLanguage($languageCode): $e');
        }
      }
    } finally {
      if (identical(_sourceLock, done.future)) _sourceLock = null;
      if (!done.isCompleted) done.complete();
    }
  }

  /// Повторно применяет сконфигурированный в настройках движок (для системы
  /// — `setEngine`, для офлайна — no-op). Делегируется из StudyModeService.
  Future<void> applyConfiguredEngine() async {
    if (_engine == null) return;
    try {
      await _engine!.applyConfiguredEngine();
    } catch (e) {
      debugPrint('⚠ TtsCoordinator: applyConfiguredEngine: $e');
    }
  }

  // -------------------------------------------------------------------
  // Speak / Stop — приоритетная очередь
  // -------------------------------------------------------------------

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
    if (_engine == null) {
      debugPrint('✗ TtsCoordinator: no engine after init, dropping speak');
      return;
    }

    // Alert во время study → сразу отказываем (без прерывания перевода).
    if (priority == TtsPriority.alert &&
        _current != null &&
        _current!.priority == TtsPriority.study) {
      debugPrint('⏭ TtsCoordinator: alert suppressed (study is speaking)');
      return;
    }

    // Прерываем текущий запрос, завершая его completer.
    await _interruptCurrent();

    final completer = Completer<void>();
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

    // Применяем язык если передан (например alert с другим locale).
    if (locale != null && locale.isNotEmpty) {
      try {
        await _engine!.setLanguage(locale);
      } catch (_) {}
    }

    // Запускаем engine.speak без await; completion / interrupt
    // синхронизируются с _current через identical-проверку.
    _engine!.speak(
      text,
      rate: rate ?? 0.5,
      pitch: pitch,
      volume: volume,
    ).then((_) {
      // Engine закончил говорить. Завершаем completer только если это всё
      // ещё наш запрос (не вытеснен новым speak / stop).
      if (identical(_current, req)) {
        _current = null;
        if (!completer.isCompleted) completer.complete();
      }
    }).catchError((Object e) {
      debugPrint('✗ TtsCoordinator: engine.speak() error: $e');
      if (identical(_current, req)) {
        _current = null;
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  /// Полная остановка речи. Завершает текущий completer (если есть).
  Future<void> stop() async {
    await _interruptCurrent();
  }

  Future<void> _interruptCurrent() async {
    final cur = _current;
    _current = null;
    if (cur != null && !cur.completer.isCompleted) {
      cur.completer.complete();
    }
    if (_engine != null) {
      try {
        await _engine!.stop();
      } catch (_) {}
    }
  }

  // -------------------------------------------------------------------
  // Диагностика (для overlay в player_screen)
  // -------------------------------------------------------------------

  bool get isInitialized => _initialized;
  bool get isSpeaking => _current != null;
  bool get isLanguageAvailable => _engine?.isLanguageAvailable ?? true;
  List<String> get availableEngines => _engine?.availableEngines ?? const [];
  String? get activeEngine => _engine?.activeEngine;
  String? get selectedEngine => _engine?.selectedEngine;
  int get lastGenerationMs => _engine?.lastGenerationMs ?? 0;
}
