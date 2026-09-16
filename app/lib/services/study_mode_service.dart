import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_service.dart';
import 'lyrics_service.dart';
import 'translation_service.dart';
import 'tts/tts_engine.dart' show TtsSource;
import 'tts_coordinator.dart';

enum StudyPhase { idle, speaking, playingSegment }

/// Order of translation vs. original inside one study line.
enum StudyModeOrder {
  /// Speak translation first, then play the song segment.
  translationFirst,

  /// Play the song segment first, then speak the translation.
  originalFirst,

  /// Speak the translation over a ducked (quiet) song segment simultaneously.
  overlay,
}

/// When to speak the translation in overlay (continuous) mode.
enum OverlayTiming { start, end, both }

/// Coordinates "study mode" playback. For each lyric line it speaks the
/// translation (TTS) and plays the corresponding segment of the song, in the
/// order defined by [order].
///
/// Line segment = [line.startTime, nextLine.startTime).
/// For the last line the segment plays until the song completes.
class StudyModeService extends ChangeNotifier {
  final AudioService _audio;
  final LyricsService _lyrics;
  final TranslationService _translations;
  // Все вызовы речи идут через единый TtsCoordinator, который с v5.5.0 держит
  // полиморфный TtsEngine (SystemTtsEngine или OfflineTtsEngine). Конфигурация
  // языка/движка делегируется координатору (setLanguage, applyConfiguredEngine,
  // setTtsSource). Скорость речи (_speechRate) передаётся через speak —
  // прямой FlutterTts API больше не используется.
  final TtsCoordinator _ttsCoordinator = TtsCoordinator.instance;

  bool _isActive = false;
  bool _isUserPaused = false;
  bool _isSpeaking = false;
  StudyPhase _phase = StudyPhase.idle;
  int _currentIndex = -1;
  bool _disposed = false;
  bool _ttsReady = false;
  String _ttsLanguage = 'ru-RU';

  StudyModeOrder _order = StudyModeOrder.translationFirst;
  double _speechRate = 0.5;
  double _speechVolume = 1.0;
  double _duckVolume = 0.3;
  // Смещение момента озвучки относительно меток строк (сек; только overlay).
  // Положительное — говорить позже (задержка), отрицательное — раньше.
  double _ttsOffset = 0.0;
  OverlayTiming _overlayTiming = OverlayTiming.start;
  double _savedVolume = 1.0;
  bool _isDucked = false;

  // Per-song override: когда [_perSongOverride] == true, значения выше
  // (order/speechRate/speechVolume/overlayTiming/duckVolume/ttsOffset)
  // относятся к конкретной песне [_perSongSongId], а сеттеры пишут в
  // `song_{id}_*` ключи. Иначе работают глобальные настройки (`studyMode*`).
  // enabledPersist остаётся глобальным.
  bool _perSongOverride = false;
  String? _perSongSongId;

  // Persisted "study mode enabled" flag. Lets the user toggle study mode once
  // and have it automatically restart on every subsequent song and after app
  // restart, instead of re-enabling it per song.
  bool _enabledPersist = false;

  StreamSubscription? _playerStateSub;
  Completer<bool>? _segmentCompleter;

  /// Invoked when study mode reaches the END of the song naturally (all lines
  /// processed / song completed). If set, the player is NOT paused here — the
  /// callback is expected to trigger the normal song-completion flow (loop /
  /// next), which respects the loop mode and restarts study mode (persist) for
  /// the next song. If null, falls back to [stop] (pause).
  VoidCallback? onStudyCompleted;

  // Future активного kick-цикла (_kickPlaybackAsync). Хранится, чтобы stop() и
  // pauseSession() могли его дождаться: иначе цикл-«зомби» от старой песни
  // просыпается после stop(), видит _isActive=true (поднятый новым start() при
  // смене песни) и продолжает делать play()/seek() над новым плеером —
  // накладывающийся звук и рассинхрон (симптом «звук идёт параллельно»).
  Future<void>? _kickPlaybackFuture;

  // Хвост незавершённой pauseSession и его generation-токен (v5.8.5). Короткое
  // прерывание (звук SMS ~1-2с) может закончиться, пока pauseSession ещё
  // дренирует kick-цикл (до 2с): resumeSession ДОЖИДАЕТСЯ этот future перед
  // запуском нового runner'а, а если пауза зависла дольше таймаута — инкремент
  // генерации останавливает её хвост до разрушительного re-pause плеера
  // (иначе хвост гасил только что возобновлённое воспроизведение).
  Future<void>? _pauseSessionFuture;
  int _pauseGen = 0;

  // Токен «поколения» активной study-сессии. Инкрементируется в stop() — это
  // инвалидирует все висящие fire-and-forget колбэки _speakOver().then: они
  // захватывают токен при старте и выходят, если токен сменился. Иначе .then
  // от старой песни доживает до нового start() (смена песни) и вызывает
  // _kickPlayback(), создавая зомби-kick поверх свежего цикла новой песни
  // (симптом «несколько секунд каши» в начале воспроизведения).
  int _sessionToken = 0;

  // Токен активного speak-вызова в overlay (_speakOver). Инкрементируется при
  // каждом новом speak и в stop()/pauseSession(). Это решает два бага:
  //  1. Потеря перевода строки в overlay: раньше _speakOver skip'ал триггер
  //     новой строки, пока TTS был занят (if (_isSpeaking) return) → подсветка
  //     уходила на новую строку, а перевод новой строки вообще не звучал.
  //     Теперь мы прерываем старый перевод и запускаем новый — координатор сам
  //     делает _interruptCurrent в speak(). А _speakToken гарантирует, что
  //     .then-колбэк ПРЕРВАННОГО speak не сбросит _isSpeaking поверх нового.
  //  2. Защита от race: прерванный speak завершает свой completer сразу, его
  //     .then мог бы выполниться после того, как новый speak уже поставил
  //     _isSpeaking=true. Проверка токена отсекает устаревшие колбэки.
  int _speakToken = 0;

  // Polling timers for segment/line boundary detection. We poll
  // _audio.position (kept fresh by AudioService's own reliable positionStream
  // subscription) instead of subscribing to just_audio's positionStream
  // directly: dynamic subscriptions on that broadcast stream proved unreliable
  // right after the TTS audio-session handoff and never fired the boundary
  // callback, which stalled all three study modes.
  Timer? _segmentTimer;
  Timer? _overlayTimer;

  /// Watchdog-таймер сегмента в TF/OF-режимах. Защищает от зависания
  /// `_segmentCompleter` при zombie-state `just_audio` (processingState !=
  /// completed, но позиция не двигается): по истечении `(длина сегмента + 10с)`
  /// форсит `_cancelSegmentAwait(true)`, и study-цикл продолжает переходить
  /// по строкам вместо вечного await'а. Раньше такое зависание намертво
  /// останавливало сессию (watchdog был только на TTS speak, не на сегменте).
  Timer? _segmentWatchdog;

  // === DEBUG fields (temporary diagnostic) ===
  double? _currentSegmentEnd;
  int _debugSegmentTicks = 0;
  bool _debugResuming = false;

  // Whether the current translation language is actually speakable by the
  // system TTS engine (checked via isLanguageAvailable). On some devices
  // (e.g. Chinese ROMs without Google/Russian voices) this is false, and
  // speaking would otherwise hang in silence for a long time.
  bool _langAvailable = true;
  // The system TTS engine in use (for diagnostics).
  String? _activeEngine;
  // When true, _speak() is a no-op (resolves immediately) so study mode runs
  // in "segments only" mode. Set automatically by the fail-fast watchdog when
  // TTS repeatedly fails to produce speech, or manually from the UI ("continue
  // without voice").
  bool _speakDisabled = false;
  // Consecutive TTS watchdog timeouts. The session-wide _speakDisabled is only
  // armed after 2 in a row, so a single transient hang (typically the first
  // speak after a phone call) doesn't silence the rest of the song.
  int _ttsFailStreak = 0;
  // Cooldown самовосстановления речи (v5.8.5). Раньше после 2 подряд зависаний
  // watchdog глушил перевод ДО КОНЦА песни: внутри песни сброса не было, речь
  // возвращал только _ensureTtsReady на следующей (симптом «звук сообщения
  // выключил голос обучения до конца трека, на следующей песне включился»).
  // Теперь отключение временное: по истечении cooldown _speak() делает пробу,
  // и если движок ожил — речь продолжает звучать в той же песне. Каждая
  // повторная неудача удваивает паузу (backoff, до капа).
  Duration _speakCooldown = const Duration(seconds: 20);
  DateTime? _speakCooldownUntil;
  static const Duration _speakCooldownInitial = Duration(seconds: 20);
  static const Duration _speakCooldownMax = Duration(seconds: 120);

  // All TTS engines reported by the system (via getEngines). Populated in
  // _initTts(). On Android 11+ requires the TTS_SERVICE <queries> declaration
  // in AndroidManifest, otherwise this stays empty (the engine is "invisible").
  List<String> _availableEngines = const [];
  // The engine actually in use (after applying user choice / auto-prefer).
  String? _selectedEngine;

  bool get isActive => _isActive;
  bool get isUserPaused => _isUserPaused;
  bool get isSpeaking => _isSpeaking;
  bool get isPlayingSegment => _phase == StudyPhase.playingSegment;
  StudyPhase get phase => _phase;
  int get currentIndex => _currentIndex;
  StudyModeOrder get order => _order;
  double get speechRate => _speechRate;
  double get speechVolume => _speechVolume;
  OverlayTiming get overlayTiming => _overlayTiming;
  double get duckVolume => _duckVolume;

  /// Смещение озвучки перевода (сек, −5..+5): плюс — позже, минус — раньше.
  double get ttsOffset => _ttsOffset;

  /// Активно ли per-song переопределение для текущей песни.
  bool get perSongOverride => _perSongOverride;

  // === DEBUG getters (temporary diagnostic) ===
  double? get debugSegmentEnd => _currentSegmentEnd;
  int get debugSegmentTicks => _debugSegmentTicks;
  bool get debugResuming => _debugResuming;

  /// Whether the current translation language is installed/speakable on this
  /// device's TTS engine.
  bool get isLanguageAvailable => _langAvailable;

  /// Whether TTS speech is currently being skipped (segments-only mode).
  bool get speakDisabled => _speakDisabled;

  /// The active system TTS engine name (for diagnostics), or null if unknown.
  String? get activeEngine => _activeEngine;

  /// All TTS engines discovered on the system (package names).
  List<String> get availableEngines => List.unmodifiable(_availableEngines);

  /// The engine currently selected/in use (after auto-prefer or user choice).
  String? get selectedEngine => _selectedEngine;

  /// Enables/disables "segments only" mode (no TTS). Used by the UI when the
  /// user chooses to continue without a voice, and by the fail-fast watchdog
  /// when TTS keeps hanging.
  void setSpeakDisabled(bool value) {
    if (_speakDisabled == value) return;
    _speakDisabled = value;
    if (value) {
      // Отключение watchdog'ом — всегда временное (пробы в _speak гейтятся на
      // _langAvailable): планируем следующую пробу и удваиваем паузу на
      // случай повторной неудачи (backoff, до капа).
      _speakCooldownUntil = DateTime.now().add(_speakCooldown);
      _speakCooldown = _speakCooldown * 2 > _speakCooldownMax
          ? _speakCooldownMax
          : _speakCooldown * 2;
    } else {
      // Явное включение (UI / resumeSession / новая песня) — backoff сброшен.
      _speakCooldown = _speakCooldownInitial;
      _speakCooldownUntil = null;
    }
    debugPrint(
        '🎧 StudyModeService: TTS speech ${value ? 'DISABLED' : 'enabled'}');
    notifyListeners();
  }

  /// Whether study mode should stay enabled across songs / app restarts.
  bool get enabledPersist => _enabledPersist;

  StudyModeService(this._audio, this._lyrics, this._translations) {
    _init();
  }

  Future<void> _init() async {
    await _loadSettings();
    await _initTts();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _loadValuesFromPrefs(prefs, perSong: false);
      _enabledPersist = prefs.getBool('studyModeEnabled') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('✗ StudyModeService loadSettings error: $e');
    }
  }

  /// Грузит study-значения (order/speechRate/speechVolume/overlayTiming/
  /// duckVolume/ttsOffset) либо из глобальных ключей, либо из per-song. При
  /// perSong=true и отсутствии per-song ключа поле НЕ сбрасывается —
  /// сохраняется текущее значение (что позволяет наследовать глобальные
  /// значения при первом включении override).
  Future<void> _loadValuesFromPrefs(SharedPreferences prefs,
      {required bool perSong, String? songId}) async {
    if (perSong && songId != null) {
      final orderIdx = prefs.getInt('song_${songId}_order');
      if (orderIdx != null) {
        _order = StudyModeOrder
            .values[orderIdx.clamp(0, StudyModeOrder.values.length - 1)];
      }
      final sr = prefs.getDouble('song_${songId}_speechRate');
      if (sr != null) _speechRate = sr;
      final sv = prefs.getDouble('song_${songId}_speechVolume');
      if (sv != null) _speechVolume = sv.clamp(0.0, 3.0);
      final ti = prefs.getInt('song_${songId}_overlayTiming');
      if (ti != null) {
        _overlayTiming = OverlayTiming
            .values[ti.clamp(0, OverlayTiming.values.length - 1)];
      }
      final dv = prefs.getDouble('song_${songId}_duckVolume');
      if (dv != null) _duckVolume = dv.clamp(0.0, 1.0);
      final to = prefs.getDouble('song_${songId}_ttsOffset');
      if (to != null) _ttsOffset = to.clamp(-5.0, 5.0);
    } else {
      final orderIdx = prefs.getInt('studyModeOrder') ?? 0;
      _order = StudyModeOrder
          .values[orderIdx.clamp(0, StudyModeOrder.values.length - 1)];
      _speechRate = prefs.getDouble('studyModeSpeechRate') ?? 0.5;
      _speechVolume =
          (prefs.getDouble('studyModeSpeechVolume') ?? 1.0).clamp(0.0, 3.0);
      final ti = prefs.getInt('studyModeOverlayTiming') ?? 0;
      _overlayTiming =
          OverlayTiming.values[ti.clamp(0, OverlayTiming.values.length - 1)];
      _duckVolume = prefs.getDouble('studyModeDuckVolume') ?? 0.3;
      _ttsOffset =
          (prefs.getDouble('studyModeTtsOffset') ?? 0.0).clamp(-5.0, 5.0);
    }
  }

  bool get _usePerSong => _perSongOverride && _perSongSongId != null;

  /// Применяет per-song настройки для указанной песни. Читает флаг
  /// `song_{id}_override` и грузит 4 значения (order/speechRate/overlayTiming/
  /// duckVolume) из per-song или глобальных ключей. Должен вызываться при
  /// смене/открытии песни (до старта study mode), чтобы новый цикл работал с
  /// корректными значениями. enabledPersist остаётся глобальным.
  Future<void> applyPerSongSettings(String songId) async {
    try {
      _perSongSongId = songId;
      final prefs = await SharedPreferences.getInstance();
      _perSongOverride = prefs.getBool('song_${songId}_override') ?? false;
      await _loadValuesFromPrefs(prefs,
          perSong: _perSongOverride, songId: songId);
      // rate применяется при следующем speak через координатор (как параметр).
      debugPrint(
          '🎧 StudyModeService: applyPerSongSettings($songId) override=$_perSongOverride order=$_order rate=$_speechRate');
      notifyListeners();
    } catch (e) {
      debugPrint('✗ StudyModeService applyPerSongSettings error: $e');
    }
  }

  /// Включает/выключает per-song переопределение для текущей песни. При
  /// первом включении наследует текущие (глобальные) значения как стартовые
  /// per-song — чтобы пользователь не начинал с чистого листа. При выключении
  /// откатывается к глобальным.
  Future<void> setPerSongOverride(bool value) async {
    if (_perSongOverride == value) return;
    _perSongOverride = value;
    final id = _perSongSongId;
    if (id == null) {
      notifyListeners();
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('song_${id}_override', value);
      if (value) {
        // Наследуем текущие значения как стартовые per-song (только если
        // пользователь ещё не задавал свои).
        if (prefs.getInt('song_${id}_order') == null) {
          await prefs.setInt('song_${id}_order', _order.index);
        }
        if (prefs.getDouble('song_${id}_speechRate') == null) {
          await prefs.setDouble('song_${id}_speechRate', _speechRate);
        }
        if (prefs.getDouble('song_${id}_speechVolume') == null) {
          await prefs.setDouble('song_${id}_speechVolume', _speechVolume);
        }
        if (prefs.getInt('song_${id}_overlayTiming') == null) {
          await prefs.setInt('song_${id}_overlayTiming', _overlayTiming.index);
        }
        if (prefs.getDouble('song_${id}_duckVolume') == null) {
          await prefs.setDouble('song_${id}_duckVolume', _duckVolume);
        }
        if (prefs.getDouble('song_${id}_ttsOffset') == null) {
          await prefs.setDouble('song_${id}_ttsOffset', _ttsOffset);
        }
      }
      // Перезагрузить значения (per-song если включили, global если выключили).
      await _loadValuesFromPrefs(prefs, perSong: value, songId: id);
      // rate применяется при следующем speak через координатор (как параметр).
      debugPrint('🎧 StudyModeService: setPerSongOverride($value)');
      notifyListeners();
    } catch (e) {
      debugPrint('✗ StudyModeService setPerSongOverride error: $e');
    }
  }

  Future<void> setOrder(StudyModeOrder order) async {
    if (_order == order) return;
    _order = order;
    debugPrint('✓ StudyModeService: order set to $order');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_usePerSong) {
        await prefs.setInt('song_${_perSongSongId!}_order', order.index);
      } else {
        await prefs.setInt('studyModeOrder', order.index);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    // rate применяется при следующем speak через координатор (как параметр).
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_usePerSong) {
        await prefs.setDouble('song_${_perSongSongId!}_speechRate', rate);
      } else {
        await prefs.setDouble('studyModeSpeechRate', rate);
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Громкость генерируемой речи (0.0–3.0). До 1.0 — attenuation плеера, выше
  /// 1.0 — буст сэмплов (офлайн). Применяется при следующем speak.
  Future<void> setSpeechVolume(double volume) async {
    _speechVolume = volume.clamp(0.0, 3.0);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_usePerSong) {
        await prefs
            .setDouble('song_${_perSongSongId!}_speechVolume', _speechVolume);
      } else {
        await prefs.setDouble('studyModeSpeechVolume', _speechVolume);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setOverlayTiming(OverlayTiming timing) async {
    if (_overlayTiming == timing) return;
    _overlayTiming = timing;
    debugPrint('✓ StudyModeService: overlay timing set to $timing');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_usePerSong) {
        await prefs.setInt('song_${_perSongSongId!}_overlayTiming', timing.index);
      } else {
        await prefs.setInt('studyModeOverlayTiming', timing.index);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setDuckVolume(double volume) async {
    _duckVolume = volume.clamp(0.0, 1.0);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_usePerSong) {
        await prefs.setDouble('song_${_perSongSongId!}_duckVolume', _duckVolume);
      } else {
        await prefs.setDouble('studyModeDuckVolume', _duckVolume);
      }
    } catch (_) {}
    notifyListeners();
  }

  /// Смещение момента озвучки перевода относительно меток строк (сек,
  /// −5..+5). Плюс — говорить позже (задержка), минус — раньше (опережение).
  /// Действует только в режиме overlay: сдвигает определение границы строки
  /// в опросе позиции (точность — интервал опроса 150 мс). Сегментные режимы
  /// (сначала перевод/сначала оригинал) последовательны по построению и
  /// смещение не используют.
  Future<void> setTtsOffset(double offset) async {
    _ttsOffset = offset.clamp(-5.0, 5.0);
    debugPrint('✓ StudyModeService: tts offset set to $_ttsOffset s');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_usePerSong) {
        await prefs.setDouble('song_${_perSongSongId!}_ttsOffset', _ttsOffset);
      } else {
        await prefs.setDouble('studyModeTtsOffset', _ttsOffset);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _initTts() async {
    try {
      // Координатор держит полиморфный TtsEngine. Здесь убеждаемся что он
      // готов и применяем язык перевода. Rate/pitch/volume больше не
      // выставляются напрямую — они применяются в speak() через параметры.
      await _ttsCoordinator.ensureInitialized();
      _availableEngines = _ttsCoordinator.availableEngines;
      _selectedEngine = _ttsCoordinator.selectedEngine;
      _activeEngine = _ttsCoordinator.activeEngine;

      await _setTtsLanguage(_ttsLanguage);
      _ttsReady = true;
      debugPrint(
          '✓ StudyModeService: TTS initialized (rate=$_speechRate, engine=$_selectedEngine)');
    } catch (e) {
      debugPrint('✗ StudyModeService: TTS init error: $e');
    }
  }

  /// Re-applies the configured engine at runtime. Делегируется в координатор
  /// (для system — setEngine на FlutterTts, для offline — no-op).
  Future<void> _applyConfiguredEngine() async {
    await _ttsCoordinator.applyConfiguredEngine();
    _selectedEngine = _ttsCoordinator.selectedEngine;
    _activeEngine = _ttsCoordinator.activeEngine;
  }

  /// Re-applies the configured engine at runtime (e.g. after the user changes
  /// the engine in Settings while a study session is active).
  Future<void> applyConfiguredEngine() async {
    if (!_ttsReady) return;
    await _applyConfiguredEngine();
    await _setTtsLanguage(_ttsLanguage);
    notifyListeners();
  }

  /// Speaks [text] and resolves when speech finishes, errors out, or is stopped.
  Future<void> _speak(String text) async {
    // Segments-only mode: skip TTS entirely so the runner keeps advancing
    // (used when no voice is installed, or after TTS repeatedly hung).
    if (_speakDisabled) {
      // Язык реально недоступен (нет голосов) — пробы бессмысленны, молчим до
      // конца сессии. Иначе — self-healing (v5.8.5): после истечения cooldown
      // пробуем заговорить снова В ЭТОЙ ЖЕ песне, чтобы одно прерывание (звук
      // SMS/уведомления) не глушило перевод до конца трека.
      if (!_langAvailable) return;
      final until = _speakCooldownUntil;
      if (until != null && DateTime.now().isBefore(until)) return;
      debugPrint(
          '🎧 StudyMode: TTS probe after cooldown — re-enabling speech in this song');
      setSpeakDisabled(false);
      _ttsFailStreak = 0;
    }

    // Запрос через координатор: единая очередь с приоритетом study. Alert
    // детекции машин НЕ прервёт этот speak (координатор сам отложит/пропустит
    // alert).
    final estSeconds = (text.length / 8).ceil().clamp(4, 9);
    final watchdogSeconds = (estSeconds + 3).clamp(5, 12);

    var timedOut = false;
    try {
      await _ttsCoordinator
          .speak(
            text,
            priority: TtsPriority.study,
            locale: _ttsLanguage,
            rate: _speechRate,
            volume: _speechVolume,
          )
          .timeout(Duration(seconds: watchdogSeconds), onTimeout: () {
        timedOut = true;
        debugPrint('⚠ StudyMode TTS watchdog (${watchdogSeconds}s) — hang');
        // Останавливаем координатор — он завершит completer и вызовет
        // engine.stop() (FlutterTts.stop или остановка AudioPlayer у офлайна).
        _ttsCoordinator.stop();
      });
    } catch (e) {
      debugPrint('✗ StudyMode TTS speak error: $e');
    }
    if (timedOut) {
      // Авто-отключение TTS на cooldown — но только после 2 ПОДРЯД зависаний,
      // чтобы не висеть на каждой строке. Единичный сбой (типично первый speak
      // после прерывания на деактивированной аудиосессии) не должен лишать
      // перевода всю оставшуюся часть песни. Повторные неудачи — backoff
      // (см. setSpeakDisabled), но не «до конца песни»: через cooldown _speak
      // снова пробует заговорить (v5.8.5).
      _ttsFailStreak++;
      if (_ttsFailStreak >= 2) {
        debugPrint('⚠ StudyMode: TTS hung $_ttsFailStreak times in a row '
            '— disabling TTS for ${_speakCooldown.inSeconds}s (cooldown)');
        setSpeakDisabled(true);
      }
    } else {
      _ttsFailStreak = 0;
      // Успешная речь сбрасывает backoff: если TTS снова «умрёт», первая пауза
      // снова будет короткой.
      _speakCooldown = _speakCooldownInitial;
    }
  }

  Future<void> _setTtsLanguage(String languageCode) async {
    final locale = _mapLanguageToLocale(languageCode);
    _ttsLanguage = locale;
    // Делегируем в координатор — он сам проверит доступность языка через
    // активный TtsEngine (SystemTtsEngine: isLanguageAvailable + getVoices
    // fallback; OfflineTtsEngine: наличие модели).
    await _ttsCoordinator.setLanguage(languageCode);
    final available = _ttsCoordinator.isLanguageAvailable;
    _activeEngine = _ttsCoordinator.activeEngine;
    _selectedEngine = _ttsCoordinator.selectedEngine;
    debugPrint(
        available
            ? '✓ StudyModeService: TTS language set to $locale (engine=$_activeEngine)'
            : '⚠ StudyModeService: TTS language $locale NOT available');
    final changed = _langAvailable != available;
    _langAvailable = available;
    if (changed) notifyListeners();
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
    return map[code.toLowerCase()] ?? 'en-US';
  }

  String? _getTranslationText(int index) {
    final lines = _lyrics.lyricLines;
    if (index < 0 || index >= lines.length) return null;
    final line = lines[index];
    if (line.translatedText != null && line.translatedText!.trim().isNotEmpty) {
      return line.translatedText;
    }
    return _translations.getTranslationForLine(line.startTime);
  }

  int _findLineIndexForPosition(double pos) {
    final lines = _lyrics.lyricLines;
    int result = -1;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].startTime <= pos) {
        result = i;
      } else {
        break;
      }
    }
    return result;
  }

  Future<void> _setDuckVolume() async {
    if (_isDucked) return;
    try {
      _savedVolume = _audio.player.volume;
      await _audio.player.setVolume(_duckVolume);
      _isDucked = true;
    } catch (e) {
      debugPrint('⚠ StudyModeService: setVolume(duck) error: $e');
    }
  }

  Future<void> _restoreVolume() async {
    if (!_isDucked) return;
    try {
      await _audio.player.setVolume(_savedVolume);
    } catch (e) {
      debugPrint('⚠ StudyModeService: setVolume(restore) error: $e');
    }
    _isDucked = false;
  }

  /// Checks whether the system TTS engine can speak [languageCode] and caches
  /// the result (also exposed via [isLanguageAvailable]). Used by the UI as a
  /// pre-flight check before starting study mode, so we can warn the user and
  /// offer "continue without voice" instead of hanging in silence.
  Future<bool> checkLanguageAvailable(String languageCode) async {
    await _setTtsLanguage(languageCode);
    return _langAvailable;
  }

  /// Starts study mode from the line closest to the current playback position.
  Future<bool> start() async {
    if (_isActive) return true;
    final lines = _lyrics.lyricLines;
    if (lines.isEmpty) {
      debugPrint('⚠ StudyModeService: no lyrics, cannot start');
      return false;
    }

    // Re-apply the configured engine in case the user changed it in Settings
    // since this service was constructed (engine choice is read from prefs).
    await applyConfiguredEngine();

    final current = _translations.currentTranslation;
    if (current != null) {
      await _setTtsLanguage(current.language);
    }
    // rate применяется при следующем speak через координатор (как параметр).

    final posSec = _audio.position.inMilliseconds / 1000.0;
    int idx = _findLineIndexForPosition(posSec);
    if (idx < 0) idx = 0;

    _isActive = true;
    _isUserPaused = false;
    _currentIndex = idx;
    _phase = StudyPhase.idle;
    notifyListeners();

    debugPrint(
        '▶ StudyModeService: started from line $idx (${lines.length} lines, order=$_order)');
    _startRunner();
    _persistEnabled(true);
    return true;
  }

  /// Persists the "study mode enabled" flag so the mode can be automatically
  /// restored on the next song / app restart.
  Future<void> _persistEnabled(bool value) async {
    if (_enabledPersist == value) return;
    _enabledPersist = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('studyModeEnabled', value);
    } catch (_) {}
  }

  /// Public toggle for the persisted flag only (does not start the runner).
  /// Used by the UI to remember the user's choice across songs.
  Future<void> setEnabledPersist(bool value) async {
    await _persistEnabled(value);
  }

  void _startRunner() {
    if (_order == StudyModeOrder.overlay) {
      _runContinuousOverlay();
    } else {
      _runLoop();
    }
  }

  Future<void> _runLoop() async {
    debugPrint('↪ StudyModeService: loop started');
    try {
      while (_isActive && !_isUserPaused && !_disposed) {
        final lines = _lyrics.lyricLines;
        if (_currentIndex < 0 || _currentIndex >= lines.length) {
          break;
        }

        final text = _getTranslationText(_currentIndex);
        bool reachedEnd;

        switch (_order) {
          case StudyModeOrder.originalFirst:
            reachedEnd = await _handleOriginalFirst(_currentIndex, text);
            break;
          case StudyModeOrder.overlay:
            reachedEnd = await _handleOverlay(_currentIndex, text);
            break;
          case StudyModeOrder.translationFirst:
            reachedEnd = await _handleTranslationFirst(_currentIndex, text);
            break;
        }

        if (!_isActive || _isUserPaused || _disposed) return;
        if (!reachedEnd) return;

        _currentIndex++;
        notifyListeners();
      }

      if (_isActive && !_isUserPaused && !_disposed) {
        debugPrint('✓ StudyModeService: reached end of song');
        if (onStudyCompleted != null) {
          onStudyCompleted!();
        } else {
          await stop();
        }
      }
    } catch (e) {
      debugPrint('✗ StudyModeService loop error: $e');
      await stop();
    }
  }

  Future<bool> _handleTranslationFirst(int index, String? text) async {
    final lines = _lyrics.lyricLines;
    final lineStartMs = (lines[index].startTime * 1000).round();
    // Don't rewind if we're already at/inside this line (e.g. study just
    // (re)started mid-line after a song switch) — that would replay already-
    // heard audio. Only seek when we're before the line start.
    if (_audio.position.inMilliseconds < lineStartMs) {
      try {
        await _audio.seek(Duration(milliseconds: lineStartMs));
      } catch (_) {}
    }
    if (text != null && text.trim().isNotEmpty && _ttsReady) {
      _isSpeaking = true;
      _phase = StudyPhase.speaking;
      notifyListeners();
      try {
        await _audio.systemPause();
      } catch (_) {}
      try {
        await _speak(text);
      } catch (e) {
        debugPrint('✗ StudyMode TTS speak error: $e');
      }
      _isSpeaking = false;
      if (!_isActive || _isUserPaused || _disposed) return false;
      notifyListeners();
    } else {
      debugPrint(
          '⏭ StudyModeService: line $index has no translation, playing segment only');
    }
    if (!_isActive || _isUserPaused || _disposed) return false;
    _phase = StudyPhase.playingSegment;
    notifyListeners();
    return _playSegmentAndAwait(index);
  }

  Future<bool> _handleOriginalFirst(int index, String? text) async {
    _phase = StudyPhase.playingSegment;
    notifyListeners();
    final reachedEnd = await _playSegmentAndAwait(index);
    if (!_isActive || _isUserPaused || _disposed) return false;
    if (!reachedEnd) return false;
    if (text != null && text.trim().isNotEmpty && _ttsReady) {
      _isSpeaking = true;
      _phase = StudyPhase.speaking;
      notifyListeners();
      try {
        await _audio.systemPause();
      } catch (_) {}
      try {
        await _speak(text);
      } catch (e) {
        debugPrint('✗ StudyMode TTS speak error: $e');
      }
      _isSpeaking = false;
      if (!_isActive || _isUserPaused || _disposed) return false;
      notifyListeners();
    } else {
      debugPrint(
          '⏭ StudyModeService: line $index has no translation, skipping TTS');
    }
    return true;
  }

  Future<bool> _handleOverlay(int index, String? text) async {
    _phase = StudyPhase.playingSegment;
    notifyListeners();

    final bool hasText = text != null && text.trim().isNotEmpty && _ttsReady;

    if (!hasText) {
      // Nothing to speak over — play the segment at full volume.
      return _playSegmentAndAwait(index);
    }

    await _setDuckVolume();
    final Future<void> speakFuture = _speak(text);
    _isSpeaking = true;
    notifyListeners();

    final bool segReachedEnd = await _playSegmentAndAwait(index);

    if (_isActive && !_isUserPaused && !_disposed) {
      try {
        await speakFuture;
      } catch (e) {
        debugPrint('✗ StudyMode overlay speak await error: $e');
      }
    }
    _isSpeaking = false;
    await _restoreVolume();
    return segReachedEnd;
  }

  /// Continuous overlay: the song plays non-stop; TTS is triggered over it at
  /// line boundaries according to [_overlayTiming].
  Future<void> _runContinuousOverlay() async {
    debugPrint('↪ StudyModeService: continuous overlay started');
    final lines = _lyrics.lyricLines;
    if (lines.isEmpty) {
      await stop();
      return;
    }

    // Граница строки для триггера речи ищется по смещённой позиции:
    // pos − offset (offset > 0 = задержка → граница «наступает» позже,
    // offset < 0 = опережение → раньше). _ttsOffset действует только здесь
    // (режим overlay); сегментные режимы последовательны по построению.
    int curLine = _findLineIndexForPosition(
        _audio.position.inMilliseconds / 1000.0 - _ttsOffset);
    if (curLine < 0) curLine = 0;
    _currentIndex = curLine;
    _phase = StudyPhase.playingSegment;
    notifyListeners();

    try {
      _kickPlayback();
    } catch (e) {
      debugPrint('✗ StudyMode continuous play error: $e');
    }

    // Speak at the start of the current line immediately (if timing start/both).
    if (_overlayTiming != OverlayTiming.end) {
      _speakOver(_getTranslationText(curLine));
    }

    int lastLine = curLine;
    // Защита от двойных таймеров/подписок при повторном входе (например,
    // resumeSession после нештатной ситуации).
    _overlayTimer?.cancel();
    _playerStateSub?.cancel();
    _overlayTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (!_isActive || _isUserPaused || _disposed) {
        _cancelSegmentAwait(false);
        return;
      }
      if (_audio.player.processingState == ProcessingState.completed) {
        debugPrint('✓ StudyMode continuous: song completed (poll)');
        if (onStudyCompleted != null) {
          onStudyCompleted!();
        } else {
          stop();
        }
        return;
      }
      final posSec = _audio.position.inMilliseconds / 1000.0;
      final newLine = _findLineIndexForPosition(posSec - _ttsOffset);
      if (newLine == lastLine || newLine < 0) return;
      debugPrint(
          '↔ StudyMode continuous: line $lastLine -> $newLine @ ${posSec}s');
      if (_overlayTiming == OverlayTiming.end ||
          _overlayTiming == OverlayTiming.both) {
        _speakOver(_getTranslationText(lastLine));
      }
      if (_overlayTiming == OverlayTiming.start ||
          _overlayTiming == OverlayTiming.both) {
        _speakOver(_getTranslationText(newLine));
      }
      _currentIndex = newLine;
      lastLine = newLine;
      notifyListeners();
    });

    _playerStateSub = _audio.player.playerStateStream.listen((state) {
      if (!_isActive || _isUserPaused || _disposed) return;
      if (state.processingState == ProcessingState.completed) {
        debugPrint('✓ StudyMode continuous: song completed');
        if (onStudyCompleted != null) {
          onStudyCompleted!();
        } else {
          stop();
        }
      }
    });
  }

  /// Fire-and-forget speak used by continuous overlay.
  ///
  /// ВАЖНО (фикс v5.6.2): метод НЕ skip'ает, когда TTS уже занят. Раньше здесь
  /// было `if (_isSpeaking) return` — и при коротких строках / длинных
  /// переводах перевод НОВОЙ строки терялся: подсветка уходила на новую строку
  /// (по позиции аудио), а TTS продолжал говорить перевод ПРЕДЫДУЩЕЙ. Теперь
  /// мы прерываем предыдущий перевод и запускаем новый — `TtsCoordinator.speak`
  /// сам делает `_interruptCurrent` предыдущего запроса. `_speakToken`
  /// гарантирует, что `.then`-колбэк прерванного speak не сбросит `_isSpeaking`
  /// поверх только что запущенного нового speak.
  void _speakOver(String? text) {
    if (text == null || text.trim().isEmpty || !_ttsReady) return;
    final myToken = ++_speakToken;
    // Захватываем токен сессии, чтобы .then-колбэк мог определить, что
    // study-сессия уже остановлена (и, возможно, перезапущена для новой песни)
    // — в этом случае колбэк должен молча выйти, не вызывая _kickPlayback и
    // не создавая зомби-kick поверх нового цикла.
    final token = _sessionToken;
    _isSpeaking = true;
    _phase = StudyPhase.speaking;
    notifyListeners();
    _setDuckVolume();
    _speak(text).then((_) async {
      // Прерванный предыдущий speak не должен трогать состояние нового.
      if (myToken != _speakToken) return;
      if (token != _sessionToken) return; // сессия сменилась — выходим
      _isSpeaking = false;
      await _restoreVolume();
      if (token != _sessionToken) return; // повторная проверка после await
      if (myToken != _speakToken) return;
      if (_isActive && !_isUserPaused && !_disposed) {
        _phase = StudyPhase.playingSegment;
        notifyListeners();
        // While TTS spoke, Android's audio focus likely paused the song.
        // Resume it so the song keeps playing under/after the translation.
        final before = _audio.position;
        await Future.delayed(const Duration(milliseconds: 150));
        if (token != _sessionToken) return; // и здесь — после delay
        if (myToken != _speakToken) return;
        if (_disposed || !_isActive || _isUserPaused) return;
        if (!_audio.player.playing || _audio.position == before) {
          debugPrint('▶ StudyMode overlay: song stalled during TTS, resuming');
          _kickPlayback();
        }
      }
    });
  }

  /// Plays the segment for [index] and completes when the segment ends
  /// (next line boundary or end of song).
  /// Returns true if the segment reached its natural end, false if interrupted.
  Future<bool> _playSegmentAndAwait(int index) async {
    final lines = _lyrics.lyricLines;
    if (index < 0 || index >= lines.length) return false;

    final startMs = (lines[index].startTime * 1000).round();
    final endSec =
        (index + 1 < lines.length) ? lines[index + 1].startTime : null;

    try {
      // Only seek back to the segment start if we're BEFORE it. If we're
      // already inside the segment (e.g. study just (re)started mid-line
      // right after a song switch, where the song has been playing for ~1-2s
      // while study was spinning up), seeking back would replay already-heard
      // audio ("первая фраза повторяется"). Continue from the current position
      // instead. On normal line-to-line transitions the position is already at
      // startMs, so this guard changes nothing there.
      if (_audio.position.inMilliseconds < startMs) {
        await _audio.seek(Duration(milliseconds: startMs));
      }
    } catch (e) {
      debugPrint('✗ StudyMode seek error: $e');
    }
    debugPrint(
        '▶ StudyMode segment[$index]: play (start=${startMs}ms end=${endSec}s)');

    final completer = Completer<bool>();
    // На всякий случай отменяем ресурсы предыдущей итерации — защищает от
    // двойных таймеров/подписок при нештатных перезапусках runner'а.
    _segmentTimer?.cancel();
    _segmentWatchdog?.cancel();
    _playerStateSub?.cancel();
    _segmentCompleter = completer;
    _currentSegmentEnd = endSec;
    _debugSegmentTicks = 0;
    notifyListeners();

    // Set up boundary detection FIRST, then kick playback in the background
    // (non-blocking). This decouples detection from resume: previously a
    // hanging play() (just_audio zombie after TTS audio-session takeover)
    // blocked timer creation, so the boundary was never detected and only the
    // first phrase played. Now the timer polls position independently and
    // catches the boundary the moment playback actually advances.
    _kickPlayback();

    if (endSec != null) {
      _segmentTimer =
          Timer.periodic(const Duration(milliseconds: 150), (_) {
        _debugSegmentTicks++;
        if (!_isActive || _isUserPaused || _disposed) {
          _cancelSegmentAwait(false);
          return;
        }
        if (_audio.player.processingState == ProcessingState.completed) {
          debugPrint(
              '⏹ StudyMode segment[$index]: song completed (poll fallback)');
          _cancelSegmentAwait(true);
          return;
        }
        if (_audio.position.inMilliseconds / 1000.0 >= endSec) {
          debugPrint('⏹ StudyMode segment[$index]: reached end ${endSec}s');
          // Don't fire-and-forget pause here (it races with the next
          // iteration's seek). The next handler call seeks to this boundary
          // and pauses explicitly, which is race-free.
          _cancelSegmentAwait(true);
        }
      });
      // Fallback: song ended before the lyric boundary (prevents stall).
      _playerStateSub = _audio.player.playerStateStream.listen((state) {
        if (!_isActive || _isUserPaused || _disposed) {
          _cancelSegmentAwait(false);
          return;
        }
        if (state.processingState == ProcessingState.completed) {
          debugPrint('⏹ StudyMode segment[$index]: song completed (fallback)');
          _cancelSegmentAwait(true);
        }
      });
    } else {
      _playerStateSub = _audio.player.playerStateStream.listen((state) {
        if (!_isActive || _isUserPaused || _disposed) {
          _cancelSegmentAwait(false);
          return;
        }
        if (state.processingState == ProcessingState.completed) {
          _cancelSegmentAwait(true);
        }
      });
    }

    // Watchdog: при zombie-state just_audio (processingState != completed, но
    // позиция не двигается) ни _segmentTimer, ни _playerStateSub не завершат
    // completer → _playSegmentAndAwait висит вечно, study-сессия намертво
    // останавливается. Watchdog форсит advance через (длина сегмента + 10с).
    final double segLenSec = endSec != null
        ? (endSec - lines[index].startTime).clamp(1.0, 30.0)
        : 5.0;
    _segmentWatchdog =
        Timer(Duration(seconds: (segLenSec + 10).round()), () {
      if (completer.isCompleted) return;
      // Страховка внешней паузы (v5.8.6): плеер стоит, kick не активен,
      // звонковой паузы нет — значит, воспроизведение остановили мимо всех
      // известных путей (ROM-специфичный media-button и т.п.). Это НЕ зомби:
      // форсировать advance и перезапускать песню значило бы перебить паузу
      // пользователя («нажимаю паузу — само играет дальше»). Ставим сессию на
      // паузу честным путём. Зомби-случай (playing=true, позиция замерла)
      // форсирует advance как раньше.
      if (!_audio.player.playing &&
          !_debugResuming &&
          !(_audio.backgroundHandler?.isPausedForCall ?? false)) {
        debugPrint('⏰ StudyMode segment[$index]: WATCHDOG — player paused '
            'externally (no kick, no call) → pauseSession');
        _cancelSegmentAwait(false);
        pauseSession();
        return;
      }
      debugPrint(
          '⏰ StudyMode segment[$index]: WATCHDOG (zombie just_audio?) — forcing advance');
      _cancelSegmentAwait(true);
    });

    return completer.future;
  }

  /// Non-blocking wrapper that kicks playback in the background after a TTS
  /// pause. Must NOT be awaited by callers — boundary detection (the segment
  /// timer) is set up before this runs and polls position independently, so
  /// detection no longer depends on how long recovery takes.
  void _kickPlayback() {
    _kickPlaybackFuture = _kickPlaybackAsync();
  }

  /// Async implementation of [_kickPlayback]. On Android the audio session is
  /// deactivated while FlutterTts speaks, so a plain play() right after TTS
  /// often does nothing or even hangs without resolving. We:
  ///   - reactivate the audio session,
  ///   - call play() (with a timeout so a hanging Future can't block us),
  ///   - verify the position is ACTUALLY advancing (not the `playing` flag,
  ///     which lies true in the just_audio zombie state),
  ///   - if still stuck after a couple of attempts, nudge the player with a
  ///     seek to the current position — this forces just_audio to re-buffer and
  ///     escapes the zombie state (playing=true, ready, but no motion).
  Future<void> _kickPlaybackAsync() async {
    _debugResuming = true;
    notifyListeners();
    const stepTimeout = Duration(seconds: 1);
    final beforeStart = _audio.position;

    for (int attempt = 1; attempt <= 6; attempt++) {
      if (!_isActive || _isUserPaused || _disposed) break;
      // Начался звонок/прерывание и плеер уже поставлен на паузу — НЕ боремся
      // с ней (иначе ~1-2с музыки поверх рингтона; пауза дренируется
      // pauseSession'ом самого прерывания) (v5.8.5).
      if (_audio.backgroundHandler?.isPausedForCall ?? false) {
        debugPrint(
            '⚠ StudyMode: kick aborted (call/interruption in progress)');
        break;
      }
      try {
        final session = await AudioSession.instance;
        await session.setActive(true).timeout(stepTimeout);
      } catch (e) {
        debugPrint('⚠ StudyMode: session setActive error (attempt $attempt): $e');
      }
      // Проверка НЕПОСРЕДСТВЕННО перед play(): от верхней проверки цикла до
      // этого места проходит до ~1.4с, и pauseSession мог выставить
      // _isUserPaused уже после неё — запущенный сейчас play() приземлился бы
      // ПОСЛЕ паузы и воскресил бы песню (гонка kick vs пауза, v5.8.6).
      if (!_isActive || _isUserPaused || _disposed) break;
      try {
        await _audio.systemPlay().timeout(stepTimeout);
      } catch (e) {
        debugPrint('✗ StudyMode: play() error/timeout (attempt $attempt): $e');
      }
      final Duration before = _audio.position;
      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed || !_isActive || _isUserPaused) break;
      if (_audio.backgroundHandler?.isPausedForCall ?? false) break;
      final Duration after = _audio.position;
      if (after != before) {
        debugPrint(
            '✓ StudyMode: playback kicked on attempt $attempt (${before.inMilliseconds}→${after.inMilliseconds}ms)');
        break;
      }
      debugPrint(
          '⚠ StudyMode: kick attempt $attempt — position stuck at ${after.inMilliseconds}ms');
      // Zombie-state escape: seek to current position to force a re-buffer.
      if (attempt >= 2) {
        try {
          await _audio.seek(after).timeout(stepTimeout);
        } catch (e) {
          debugPrint('⚠ StudyMode: zombie-nudge seek error (attempt $attempt): $e');
        }
      }
    }
    _debugResuming = false;
    notifyListeners();
  }

  void _cancelSegmentAwait(bool result) {
    _segmentTimer?.cancel();
    _segmentTimer = null;
    _segmentWatchdog?.cancel();
    _segmentWatchdog = null;
    _overlayTimer?.cancel();
    _overlayTimer = null;
    _playerStateSub?.cancel();
    _playerStateSub = null;
    _currentSegmentEnd = null;
    final c = _segmentCompleter;
    _segmentCompleter = null;
    if (c != null && !c.isCompleted) {
      c.complete(result);
    }
  }

  /// Pauses the current study session (stops TTS and song, keeps position).
  ///
  /// [forCall]: установить в `true`, когда пауза вызвана прерыванием звонка
  /// (вызывается из `BackgroundAudioHandler.onPlaybackInterrupted`). В этом
  /// случае финальная пауза плеера делается сырым `_audio.player.pause()` (в
  /// обход `BackgroundAudioHandler.pause`) — это и safety-net re-pause после
  /// дренирования kick-цикла (kick мог реактивировать воспроизведение), и
  /// защита от ложного `_userPausedDuringCall` (иначе заблокировала бы честный
  /// авто-resume study после звонка). Для обычной пользовательской паузы (FAB) —
  /// `false` (паузит через handler, обновляя уведомление).
  Future<void> pauseSession({bool forCall = false}) async {
    if (!_isActive || _isUserPaused) return;
    _isUserPaused = true;
    _speakToken++; // инвалидировать pending _speakOver().then
    // Тело вынесено в _pauseSessionInner, а future сохраняется: resumeSession
    // ДОЖИДАЕТСЯ его перед запуском нового runner'а (гонка коротких
    // прерываний: interruption-end приходит, пока пауза ещё дренирует kick).
    final gen = _pauseGen;
    final future = _pauseSessionInner(forCall: forCall, gen: gen);
    _pauseSessionFuture = future;
    await future;
  }

  Future<void> _pauseSessionInner(
      {required bool forCall, required int gen}) async {
    debugPrint('⏸ StudyModeService: session paused at line $_currentIndex'
        '${forCall ? ' (for call — raw player pause)' : ''}');
    // Координатор сам завершит completer текущего speak-запроса и вызовет stop.
    await _ttsCoordinator.stop();
    _cancelSegmentAwait(false);
    // Drain kick-цикла аналогично stop(): _isUserPaused=true заставит цикл
    // выйти на ближайшей проверке, но дождёмся его чтобы не осталось зомби.
    // Таймаут 3с (v5.8.6): одна попытка kick'а живёт до ~2.4с (setActive 1с +
    // play 1с + delay 400мс) — старого 2с не хватало, «хвостовой» play()
    // приземлялся уже после нашей паузы и воскрешал песню (гонка kick vs
    // пауза: FAB-пауза «не срабатывала»).
    final kick = _kickPlaybackFuture;
    if (kick != null) {
      try {
        await kick.timeout(const Duration(seconds: 3));
      } catch (_) {}
      _kickPlaybackFuture = null;
    }
    // Пока мы дренировали, пришёл resume (короткое прерывание — звук SMS) и
    // его runner уже запущен: НЕ пере-паузим плеер — иначе только что
    // возобновлённое воспроизведение снова встанет (v5.8.5).
    final stale = gen != _pauseGen;
    if (stale) {
      debugPrint('⏸ StudyModeService: stale pause tail — skip re-pause '
          '(session already resumed)');
    } else if (forCall) {
      // Safety-net re-pause ПОСЛЕ дренирования kick: kick мог успеть вызвать
      // handler.play() (реактивация сессии + _player.play()) уже ПОСЛЕ
      // _systemPause handler'а → песня осталась бы играющей во время звонка.
      // Паузим сырым _audio.player.pause() — в обход handler.pause(), чтобы НЕ
      // выставить ложно _userPausedDuringCall (что заблокировало бы авто-resume
      // study после звонка). Уведомление синхронизируется playbackEventStream-
      // листенером handler'а.
      try {
        await _audio.player.pause();
      } catch (_) {}
    } else {
      // Служебная пауза (не пользовательская): systemPause не дёргает
      // onUserPause-хендофф и не трогает user-pause-бухгалтерию handler'а —
      // намерение пользователя уже зафиксировано тем путём, который вызвал
      // pauseSession (FAB/lock-screen → handler.pause, onUserPause и т.п.)
      // (v5.8.6). Уведомление обновляется как обычно.
      try {
        await _audio.systemPause();
      } catch (_) {}
    }
    // Контрольный re-pause (гонка kick vs пауза, v5.8.6): drain мог не
    // дождаться последнего in-flight play() kick'а — тот приземлился уже
    // ПОСЛЕ паузы, и песня продолжала бы играть на «запаузненной» сессии.
    // Даём ему мгновение проявиться в player.playing и паузим сырой паузой;
    // только пока хвост актуален (после resume gen не совпадает и новый
    // runner мы не трогаем).
    if (gen == _pauseGen && _audio.player.playing) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (gen == _pauseGen && _audio.player.playing) {
        debugPrint('⏸ StudyModeService: post-pause re-check — player still '
            'playing, raw re-pause');
        try {
          await _audio.player.pause();
        } catch (_) {}
      }
    }
    await _restoreVolume();
    _isSpeaking = false;
    _phase = StudyPhase.idle;
    notifyListeners();
  }

  /// Resumes a paused study session (re-starts from the current line).
  Future<void> resumeSession() async {
    if (!_isActive || !_isUserPaused) return;
    // Дождаться хвоста незавершённой паузы: у короткого прерывания (звук SMS)
    // interruption-end приходит, пока pauseSession ещё дренирует kick-цикл.
    // Без ожидания её хвост гасил _cancelSegmentAwait'ом и re-pause'ом только
    // что запущенный runner (v5.8.5). Если пауза зависла дольше таймаута —
    // инкремент генерации ниже останавливает хвост до разрушительных шагов.
    final pause = _pauseSessionFuture;
    if (pause != null) {
      try {
        await pause.timeout(const Duration(seconds: 3));
      } catch (_) {}
      _pauseSessionFuture = null;
    }
    if (!_isActive || !_isUserPaused || _disposed) return;
    _pauseGen++; // остановить зависший хвост паузы, если он ещё жив
    _isUserPaused = false;
    // Watchdog мог выключить TTS (первый speak после прерывания зависает на
    // деактивированной аудиосессии) — даём речи второй шанс в ЭТОЙ же песне,
    // иначе перевод молчал бы до конца трека и восстанавливался только на
    // следующей песне (_ensureTtsReady). Стрик сбрасываем безусловно: первый
    // speak после resume не должен быть «в одном шаге» от защёлки.
    _ttsFailStreak = 0;
    if (_speakDisabled && _langAvailable) {
      setSpeakDisabled(false);
    }
    debugPrint('▶ StudyModeService: session resumed from line $_currentIndex');
    notifyListeners();
    _startRunner();
  }

  /// Fully stops study mode. When [userRequested] is true (the user explicitly
  /// turned it off via the button), the persisted "enabled" flag is cleared so
  /// it won't auto-restart on the next song. Internal stops (song change,
  /// completion, errors) keep the flag so the mode is restored for the next
  /// song.
  Future<void> stop({bool userRequested = false}) async {
    if (!_isActive) {
      if (userRequested) await _persistEnabled(false);
      return;
    }
    _isActive = false;
    _isUserPaused = false;
    _isSpeaking = false;
    _phase = StudyPhase.idle;
    _currentIndex = -1;
    // Инвалидируем все висящие _speakOver().then колбэки этой сессии —
    // иначе они доживут до нового start() (смена песни) и создадут зомби-kick.
    _sessionToken++;
    _speakToken++;
    // Останавливаем и возможный хвост pauseSession (v5.8.5): его re-pause и
    // _cancelSegmentAwait не должны тронуть runner новой песни после start().
    _pauseGen++;
    _pauseSessionFuture = null;
    debugPrint('⏹ StudyModeService: stopped');
    _cancelSegmentAwait(false);
    // Координатор остановит текущий speak и завершит его completer.
    await _ttsCoordinator.stop();
    // Ждём завершения активного kick-цикла: флаги уже сброшены, поэтому цикл
    // выйдет на ближайшей проверке (!_isActive), но его текущий await мог быть
    // в середине play()/Future.delayed — дождёмся, чтобы гарантированно не
    // осталось зомби, которое проснётся после нового start() (смена песни) и
    // начнёт мешать воспроизведению. Таймаут — защита от зависшего Future.
    final kick = _kickPlaybackFuture;
    if (kick != null) {
      try {
        await kick.timeout(const Duration(seconds: 2));
      } catch (_) {}
      _kickPlaybackFuture = null;
    }
    try {
      await _audio.systemPause();
    } catch (_) {}
    await _restoreVolume();
    if (userRequested) await _persistEnabled(false);
    notifyListeners();
  }

  Future<void> toggle() async {
    if (_isActive) {
      await stop(userRequested: true);
    } else {
      await start();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _segmentTimer?.cancel();
    _segmentWatchdog?.cancel();
    _overlayTimer?.cancel();
    _playerStateSub?.cancel();
    _ttsCoordinator.stop();
    super.dispose();
  }
}
