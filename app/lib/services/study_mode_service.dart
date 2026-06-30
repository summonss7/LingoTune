import 'dart:async';
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

  StreamSubscription<Duration>? _posSub;
  StreamSubscription? _playerStateSub;
  Completer<bool>? _segmentCompleter;
  Completer<void>? _speakCompleter;

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
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _setTtsLanguage(_ttsLanguage);
      _ttsReady = true;
      debugPrint('✓ StudyModeService: TTS initialized (rate=$_speechRate)');
    } catch (e) {
      debugPrint('✗ StudyModeService: TTS init error: $e');
    }
  }

  /// Speaks [text] and resolves when speech finishes, errors out, or is stopped.
  Future<void> _speak(String text) {
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
    // Watchdog: force-complete if TTS never fires completion (prevents loop stall).
    final estSeconds = (text.length / 8).ceil().clamp(4, 60);
    final watchdog = Timer(Duration(seconds: estSeconds + 6), () {
      if (!completer.isCompleted) {
        debugPrint(
            '⚠ StudyMode TTS watchdog timeout (${estSeconds + 6}s), forcing completion');
        try {
          _tts.stop();
        } catch (_) {}
        if (!completer.isCompleted) completer.complete();
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
    if (!_ttsReady) return;
    try {
      final available = await _tts.isLanguageAvailable(locale);
      if (available == true) {
        await _tts.setLanguage(locale);
        debugPrint('✓ StudyModeService: TTS language set to $locale');
      } else {
        debugPrint('⚠ StudyModeService: TTS language $locale not available');
      }
    } catch (e) {
      debugPrint('⚠ StudyModeService: TTS setLanguage($locale) error: $e');
    }
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

  /// Starts study mode from the line closest to the current playback position.
  Future<bool> start() async {
    if (_isActive) return true;
    final lines = _lyrics.lyricLines;
    if (lines.isEmpty) {
      debugPrint('⚠ StudyModeService: no lyrics, cannot start');
      return false;
    }

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
    return true;
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
        await stop();
      }
    } catch (e) {
      debugPrint('✗ StudyModeService loop error: $e');
      await stop();
    }
  }

  Future<bool> _handleTranslationFirst(int index, String? text) async {
    final lines = _lyrics.lyricLines;
    try {
      await _audio.seek(
          Duration(milliseconds: (lines[index].startTime * 1000).round()));
    } catch (_) {}
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
      await _audio.play();
    } catch (e) {
      debugPrint('✗ StudyMode continuous play error: $e');
    }
    _ensurePlaybackResumed();

    // Speak at the start of the current line immediately (if timing start/both).
    if (_overlayTiming != OverlayTiming.end) {
      _speakOver(_getTranslationText(curLine));
    }

    int lastLine = curLine;
    _posSub = _audio.player.positionStream.listen((pos) {
      if (!_isActive || _isUserPaused || _disposed) {
        _cancelSegmentAwait(false);
        return;
      }
      final posSec = pos.inMilliseconds / 1000.0;
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
        stop();
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
    _speak(text).then((_) {
      _isSpeaking = false;
      _restoreVolume();
      if (_isActive && !_isUserPaused && !_disposed) {
        _phase = StudyPhase.playingSegment;
        notifyListeners();
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
      await _audio.seek(Duration(milliseconds: startMs));
      await _audio.play();
      debugPrint(
          '▶ StudyMode segment[$index]: play (start=${startMs}ms end=${endSec}s)');
    } catch (e) {
      debugPrint('✗ StudyMode seek/play error: $e');
    }
    _ensurePlaybackResumed();

    final completer = Completer<bool>();
    _segmentCompleter = completer;

    if (endSec != null) {
      _posSub = _audio.player.positionStream.listen((pos) {
        if (!_isActive || _isUserPaused || _disposed) {
          _cancelSegmentAwait(false);
          return;
        }
        if (pos.inMilliseconds / 1000.0 >= endSec) {
          debugPrint('⏹ StudyMode segment[$index]: reached end ${endSec}s');
          try {
            _audio.pause();
          } catch (_) {}
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

  /// Ensures the player actually resumed after [AudioService.play]; retries on
  /// Android where the audio session can deactivate during the TTS pause.
  void _ensurePlaybackResumed({int remaining = 3}) {
    if (remaining <= 0 || !_isActive || _isUserPaused || _disposed) return;
    Timer(const Duration(milliseconds: 500), () {
      if (!_isActive || _isUserPaused || _disposed) return;
      if (!_audio.player.playing) {
        debugPrint(
            '⚠ StudyMode: playback not resumed, retrying play() ($remaining left)');
        _audio
            .play()
            .catchError((e) => debugPrint('✗ StudyMode retry play error: $e'));
        _ensurePlaybackResumed(remaining: remaining - 1);
      }
    });
  }

  void _cancelSegmentAwait(bool result) {
    _posSub?.cancel();
    _posSub = null;
    _playerStateSub?.cancel();
    _playerStateSub = null;
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

  /// Fully stops study mode.
  Future<void> stop() async {
    if (!_isActive) return;
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
    notifyListeners();
  }

  Future<void> toggle() async {
    if (_isActive) {
      await stop();
    } else {
      await start();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _posSub?.cancel();
    _playerStateSub?.cancel();
    _tts.stop();
    super.dispose();
  }
}
