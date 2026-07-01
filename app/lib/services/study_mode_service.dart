import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart' show ProcessingState;
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_service.dart';
import 'lyrics_service.dart';
import 'translation_service.dart';

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
  final FlutterTts _tts = FlutterTts();

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
  double _duckVolume = 0.3;
  OverlayTiming _overlayTiming = OverlayTiming.start;
  double _savedVolume = 1.0;
  bool _isDucked = false;

  // Persisted "study mode enabled" flag. Lets the user toggle study mode once
  // and have it automatically restart on every subsequent song and after app
  // restart, instead of re-enabling it per song.
  bool _enabledPersist = false;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription? _playerStateSub;
  Completer<bool>? _segmentCompleter;
  Completer<void>? _speakCompleter;

  /// Invoked when study mode reaches the END of the song naturally (all lines
  /// processed / song completed). If set, the player is NOT paused here — the
  /// callback is expected to trigger the normal song-completion flow (loop /
  /// next), which respects the loop mode and restarts study mode (persist) for
  /// the next song. If null, falls back to [stop] (pause).
  VoidCallback? onStudyCompleted;

  // Polling timers for segment/line boundary detection. We poll
  // _audio.position (kept fresh by AudioService's own reliable positionStream
  // subscription) instead of subscribing to just_audio's positionStream
  // directly: dynamic subscriptions on that broadcast stream proved unreliable
  // right after the TTS audio-session handoff and never fired the boundary
  // callback, which stalled all three study modes.
  Timer? _segmentTimer;
  Timer? _overlayTimer;

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
  OverlayTiming get overlayTiming => _overlayTiming;
  double get duckVolume => _duckVolume;

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
      final orderIndex = prefs.getInt('studyModeOrder') ?? 0;
      _order = StudyModeOrder
          .values[orderIndex.clamp(0, StudyModeOrder.values.length - 1)];
      _speechRate = prefs.getDouble('studyModeSpeechRate') ?? 0.5;
      final timingIndex = prefs.getInt('studyModeOverlayTiming') ?? 0;
      _overlayTiming = OverlayTiming
          .values[timingIndex.clamp(0, OverlayTiming.values.length - 1)];
      _duckVolume = prefs.getDouble('studyModeDuckVolume') ?? 0.3;
      _enabledPersist = prefs.getBool('studyModeEnabled') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('✗ StudyModeService loadSettings error: $e');
    }
  }

  Future<void> setOrder(StudyModeOrder order) async {
    if (_order == order) return;
    _order = order;
    debugPrint('✓ StudyModeService: order set to $order');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('studyModeOrder', order.index);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    if (_ttsReady) {
      try {
        await _tts.setSpeechRate(rate);
      } catch (_) {}
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('studyModeSpeechRate', rate);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setOverlayTiming(OverlayTiming timing) async {
    if (_overlayTiming == timing) return;
    _overlayTiming = timing;
    debugPrint('✓ StudyModeService: overlay timing set to $timing');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('studyModeOverlayTiming', timing.index);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setDuckVolume(double volume) async {
    _duckVolume = volume.clamp(0.0, 1.0);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('studyModeDuckVolume', _duckVolume);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _initTts() async {
    try {
      // Enumerate all available TTS engines on the system. On Android 11+
      // (API 30+) this requires the TTS_SERVICE <queries> declaration in
      // AndroidManifest — without it getEngines returns empty because the
      // engines are "invisible" to package visibility, even though a default
      // engine may still partially work.
      try {
        final result = await _tts.getEngines;
        _availableEngines = (result as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList();
        debugPrint(
            '🎧 StudyModeService: available engines = $_availableEngines');
      } catch (e) {
        debugPrint('⚠ StudyModeService: getEngines error: $e');
      }

      // Resolve and apply the engine to use (user-configured or auto-prefer).
      await _applyConfiguredEngine();

      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _setTtsLanguage(_ttsLanguage);
      _ttsReady = true;
      debugPrint(
          '✓ StudyModeService: TTS initialized (rate=$_speechRate, engine=$_selectedEngine)');
    } catch (e) {
      debugPrint('✗ StudyModeService: TTS init error: $e');
    }
  }

  /// Resolves which TTS engine to use and applies it via setEngine.
  /// Priority:
  ///   1. user-configured engine (from SharedPreferences 'ttsEngine') if set
  ///      and present in [_availableEngines];
  ///   2. Google TTS (com.google.android.tts) if present — the most reliable
  ///      engine across ROMs (Chinese ROMs ship a broken Heytap engine as the
  ///      default, which lies in isLanguageAvailable and/or silently fails to
  ///      synthesize);
  ///   3. the system default engine (no setEngine call).
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
          debugPrint('🎧 StudyModeService: switched TTS engine -> $desired');
        } else {
          _selectedEngine = def;
          debugPrint(
              '⚠ StudyModeService: setEngine($desired) rejected (result=$res)');
        }
      } catch (e) {
        _selectedEngine = def;
        debugPrint('⚠ StudyModeService: setEngine($desired) error: $e');
      }
    } else {
      _selectedEngine = def;
    }
    _activeEngine = _selectedEngine ?? def;
  }

  /// Re-applies the configured engine at runtime (e.g. after the user changes
  /// the engine in Settings while a study session is active). setEngine
  /// re-binds the engine, so speech params and language are re-applied.
  Future<void> applyConfiguredEngine() async {
    if (!_ttsReady) return;
    await _applyConfiguredEngine();
    try {
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
    } catch (_) {}
    await _setTtsLanguage(_ttsLanguage);
    notifyListeners();
  }

  /// Speaks [text] and resolves when speech finishes, errors out, or is stopped.
  Future<void> _speak(String text) {
    // Segments-only mode: skip TTS entirely so the runner keeps advancing
    // (used when no voice is installed, or after TTS repeatedly hung).
    if (_speakDisabled) {
      return Future.value();
    }
    final completer = Completer<void>();
    _speakCompleter = completer;
    _tts.setCompletionHandler(() {
      debugPrint('🔊 StudyMode TTS: complete');
      if (!completer.isCompleted) completer.complete();
    });
    _tts.setErrorHandler((e) {
      debugPrint('✗ StudyMode TTS error: $e');
      if (!completer.isCompleted) completer.complete();
    });
    _tts.speak(text).then((_) {
      // speak() returns immediately; actual completion handled by handlers above.
    }).catchError((e) {
      debugPrint('✗ StudyMode TTS speak() error: $e');
      if (!completer.isCompleted) completer.complete();
    });
    // Fail-fast watchdog: if TTS never fires completion (typical when the
    // engine accepts speak() but can't actually speak the language — common on
    // Chinese ROMs without the right voice), resolve quickly and auto-disable
    // TTS so the rest of the song runs in segments-only mode instead of
    // hanging for up to a minute per line. Cap at ~12s (was up to 66s).
    final estSeconds = (text.length / 8).ceil().clamp(4, 9);
    final watchdogSeconds = (estSeconds + 3).clamp(5, 12);
    final watchdog = Timer(Duration(seconds: watchdogSeconds), () {
      if (!completer.isCompleted) {
        debugPrint(
            '⚠ StudyMode TTS watchdog timeout (${watchdogSeconds}s) — disabling TTS for this session');
        try {
          _tts.stop();
        } catch (_) {}
        if (!completer.isCompleted) completer.complete();
        // Auto-disable so subsequent lines don't hang again.
        setSpeakDisabled(true);
      }
    });
    return completer.future.then((v) {
      watchdog.cancel();
      return v;
    });
  }

  void _resolveSpeak() {
    final c = _speakCompleter;
    _speakCompleter = null;
    if (c != null && !c.isCompleted) c.complete();
  }

  Future<void> _setTtsLanguage(String languageCode) async {
    final locale = _mapLanguageToLocale(languageCode);
    _ttsLanguage = locale;
    bool available = true;
    try {
      final res = await _tts.isLanguageAvailable(locale);
      available = res == true;
      if (available) {
        await _tts.setLanguage(locale);
        debugPrint('✓ StudyModeService: TTS language set to $locale');
      } else {
        // Fallback: some Chinese ROM engines LIE in isLanguageAvailable
        // (report false even when a matching voice is actually installed).
        // Enumerate voices and set one whose locale matches — setVoice is
        // more granular and often works where setLanguage/isLanguageAvailable
        // don't.
        final voiceFound = await _trySetVoiceByLocale(locale);
        if (voiceFound) {
          available = true;
          debugPrint(
              '✓ StudyModeService: language $locale unavailable per API, but a '
              'matching voice was set via setVoice');
        } else {
          debugPrint(
              '⚠ StudyModeService: TTS language $locale NOT available on this '
              'device (no installed voice). Speech will be skipped.');
        }
      }
    } catch (e) {
      available = false;
      debugPrint('⚠ StudyModeService: TTS setLanguage($locale) error: $e');
    }
    final changed = _langAvailable != available;
    _langAvailable = available;
    if (changed) notifyListeners();
  }

  /// Tries to find and apply a voice matching [locale] via getVoices/setVoice.
  /// Returns true if a matching voice was applied. Workaround for engines that
  /// misreport isLanguageAvailable (common on Chinese ROMs).
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
            final res = await _tts
                .setVoice({'name': name, 'locale': rawLocale});
            return res == 1;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠ StudyModeService: getVoices/setVoice fallback error: $e');
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
    if (_ttsReady) {
      try {
        await _tts.setSpeechRate(_speechRate);
      } catch (_) {}
    }

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
        await _audio.pause();
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
        await _audio.pause();
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

    int curLine =
        _findLineIndexForPosition(_audio.position.inMilliseconds / 1000.0);
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
      final newLine = _findLineIndexForPosition(posSec);
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

  /// Fire-and-forget speak used by continuous overlay. Skips if already
  /// speaking (avoids pile-up at line boundaries).
  void _speakOver(String? text) {
    if (text == null || text.trim().isEmpty || !_ttsReady) return;
    if (_isSpeaking) {
      debugPrint('⏭ StudyMode overlay: TTS busy, skipping trigger');
      return;
    }
    _isSpeaking = true;
    _phase = StudyPhase.speaking;
    notifyListeners();
    _setDuckVolume();
    _speak(text).then((_) async {
      _isSpeaking = false;
      await _restoreVolume();
      if (_isActive && !_isUserPaused && !_disposed) {
        _phase = StudyPhase.playingSegment;
        notifyListeners();
        // While TTS spoke, Android's audio focus likely paused the song.
        // Resume it so the song keeps playing under/after the translation.
        final before = _audio.position;
        await Future.delayed(const Duration(milliseconds: 150));
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

    return completer.future;
  }

  /// Non-blocking wrapper that kicks playback in the background after a TTS
  /// pause. Must NOT be awaited by callers — boundary detection (the segment
  /// timer) is set up before this runs and polls position independently, so
  /// detection no longer depends on how long recovery takes.
  void _kickPlayback() {
    _kickPlaybackAsync();
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
      try {
        final session = await AudioSession.instance;
        await session.setActive(true).timeout(stepTimeout);
      } catch (e) {
        debugPrint('⚠ StudyMode: session setActive error (attempt $attempt): $e');
      }
      try {
        await _audio.play().timeout(stepTimeout);
      } catch (e) {
        debugPrint('✗ StudyMode: play() error/timeout (attempt $attempt): $e');
      }
      final Duration before = _audio.position;
      await Future.delayed(const Duration(milliseconds: 400));
      if (_disposed || !_isActive || _isUserPaused) break;
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
    _posSub?.cancel();
    _posSub = null;
    _segmentTimer?.cancel();
    _segmentTimer = null;
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
  Future<void> pauseSession() async {
    if (!_isActive || _isUserPaused) return;
    _isUserPaused = true;
    debugPrint('⏸ StudyModeService: session paused at line $_currentIndex');
    try {
      await _tts.stop();
    } catch (_) {}
    _resolveSpeak();
    _cancelSegmentAwait(false);
    try {
      await _audio.pause();
    } catch (_) {}
    await _restoreVolume();
    _isSpeaking = false;
    _phase = StudyPhase.idle;
    notifyListeners();
  }

  /// Resumes a paused study session (re-starts from the current line).
  Future<void> resumeSession() async {
    if (!_isActive || !_isUserPaused) return;
    _isUserPaused = false;
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
    debugPrint('⏹ StudyModeService: stopped');
    _cancelSegmentAwait(false);
    try {
      await _tts.stop();
    } catch (_) {}
    _resolveSpeak();
    try {
      await _audio.pause();
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
    _posSub?.cancel();
    _segmentTimer?.cancel();
    _overlayTimer?.cancel();
    _playerStateSub?.cancel();
    _tts.stop();
    super.dispose();
  }
}
