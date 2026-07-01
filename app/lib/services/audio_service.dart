import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' hide LoopMode;
import 'package:audio_service/audio_service.dart' as audio_pkg;
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_audio_handler.dart';
import '../models/song.dart';
import '../models/loop_mode.dart';

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffleEnabled = false;
  double _playbackSpeed = 1.0;
  List<int>? _shuffledIndices;
  Function()? onSongComplete;
  BackgroundAudioHandler? _backgroundHandler;
  List<Song>? _currentPlaylist;
  Song? _currentSong;
  final ValueNotifier<String?> currentSongIdNotifier = ValueNotifier(null);

  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  AudioPlayer get player => _player;
  BackgroundAudioHandler? get backgroundHandler => _backgroundHandler;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;
  bool get hasActiveSong => _currentSong != null && _isInitialized;
  Duration get duration => _duration;
  Duration get position => _position;
  LoopMode get loopMode => _loopMode;
  bool get isShuffleEnabled => _isShuffleEnabled;
  double get playbackSpeed => _playbackSpeed;
  List<Song>? get currentPlaylist => _currentPlaylist;
  Song? get currentSong => _currentSong;
  List<int>? get shuffledPlaylist => _shuffledIndices;

  AudioService() {
    _loadPlaybackSettings();
    _initPlayer();
  }

  Future<void> _loadPlaybackSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loopIndex = prefs.getInt('loopMode') ?? 0;
      _loopMode = LoopMode.values[loopIndex.clamp(0, LoopMode.values.length - 1)];
      _isShuffleEnabled = prefs.getBool('isShuffleEnabled') ?? false;
      _playbackSpeed = prefs.getDouble('playbackSpeed') ?? 1.0;
      debugPrint('✓ AudioService: Loaded playback settings - loop: $_loopMode, shuffle: $_isShuffleEnabled, speed: $_playbackSpeed');
    } catch (e) {
      debugPrint('✗ Error loading playback settings: $e');
    }
  }

  Future<void> _savePlaybackSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('loopMode', _loopMode.index);
      await prefs.setBool('isShuffleEnabled', _isShuffleEnabled);
      await prefs.setDouble('playbackSpeed', _playbackSpeed);
    } catch (e) {
      debugPrint('✗ Error saving playback settings: $e');
    }
  }

  void _initPlayer() {
    _playbackEventSubscription = _player.playbackEventStream.listen((event) {
      _isPlaying = _player.playing;
      if (event.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
      notifyListeners();
    }, onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });

    _positionSubscription = _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _durationSubscription = _player.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  void _onSongCompleted() {
    if (_loopMode == LoopMode.one) {
      return;
    }
    onSongComplete?.call();
  }

  Future<void> loadAudio(String audioPath) async {
    try {
      debugPrint('=== AudioService: Loading audio: $audioPath ===');
      
      if (_backgroundHandler != null) {
        await _backgroundHandler!.loadSong(audioPath);
        _backgroundHandler!.setPlaybackSpeed(_playbackSpeed);
        debugPrint('✓ AudioService: Loaded audio in BackgroundHandler');
      } else {
        debugPrint('⚠ AudioService: BackgroundHandler is null, loading in local player');
        if (audioPath.startsWith('content://')) {
          await _player.setUrl(audioPath);
        } else {
          await _player.setFilePath(audioPath);
        }
      }
      _isInitialized = true;
      _player.setSpeed(_playbackSpeed);
      notifyListeners();
    } catch (e) {
      debugPrint('✗ Error loading audio: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> play() async {
    try {
      if (_backgroundHandler != null) {
        await _backgroundHandler!.play();
        debugPrint('✓ AudioService: Play via BackgroundHandler');
      } else if (_isInitialized) {
        await _player.play();
        debugPrint('✓ AudioService: Play via local player');
      }
    } catch (e) {
      debugPrint('✗ Error in play(): $e');
    }
  }

  Future<void> pause() async {
    try {
      if (_backgroundHandler != null) {
        await _backgroundHandler!.pause();
        debugPrint('✓ AudioService: Pause via BackgroundHandler');
      } else if (_isInitialized) {
        await _player.pause();
        debugPrint('✓ AudioService: Pause via local player');
      }
    } catch (e) {
      debugPrint('✗ Error in pause(): $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_backgroundHandler != null) {
        await _backgroundHandler!.stop();
        debugPrint('✓ AudioService: Stop via BackgroundHandler');
      } else if (_isInitialized) {
        await _player.stop();
      }
    } catch (e) {
      debugPrint('✗ Error in stop(): $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      if (_backgroundHandler != null) {
        await _backgroundHandler!.seek(position);
        debugPrint('✓ AudioService: Seek via BackgroundHandler');
      } else if (_isInitialized) {
        await _player.seek(position);
      }
    } catch (e) {
      debugPrint('✗ Error in seek(): $e');
    }
  }

  Future<void> seekToPosition(double seconds) async {
    try {
      final position = Duration(milliseconds: (seconds * 1000).toInt());
      if (_backgroundHandler != null) {
        await _backgroundHandler!.seek(position);
        debugPrint('✓ AudioService: SeekToPosition via BackgroundHandler');
      } else if (_isInitialized) {
        await _player.seek(position);
      }
    } catch (e) {
      debugPrint('✗ Error in seekToPosition(): $e');
    }
  }

  /// Ensures playback is ACTUALLY advancing (position moving), not just
  /// reported as "playing". After a song switch — especially right after TTS
  /// speech, which deactivates the Android audio session — a plain `play()`
  /// can leave just_audio in a zombie state (`playing == true`, but the
  /// position never moves). This reactivates the session, calls `play()` and
  /// verifies the position moved within ~400ms; if it didn't, it retries and
  /// nudges the player with a seek to the current position (which forces
  /// just_audio to re-buffer and escape the zombie). No-op when playback is
  /// already healthy (returns on the first advancing check).
  Future<void> ensurePlaybackAdvancing({int maxAttempts = 5}) async {
    const stepTimeout = Duration(seconds: 1);
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final session = await AudioSession.instance;
        await session.setActive(true).timeout(stepTimeout);
      } catch (e) {
        debugPrint(
            '⚠ AudioService.ensurePlayback: session error (attempt $attempt): $e');
      }
      try {
        await play().timeout(stepTimeout);
      } catch (e) {
        debugPrint(
            '✗ AudioService.ensurePlayback: play error/timeout (attempt $attempt): $e');
      }
      final Duration before = _position;
      await Future.delayed(const Duration(milliseconds: 400));
      final Duration after = _position;
      if (after != before) {
        debugPrint(
            '✓ AudioService.ensurePlayback: advancing on attempt $attempt (${before.inMilliseconds}→${after.inMilliseconds}ms)');
        return;
      }
      // If the song ended naturally, there's nothing to kick — bail out.
      if (_player.processingState == ProcessingState.completed) {
        debugPrint(
            '⚠ AudioService.ensurePlayback: player reached completed, nothing to kick');
        return;
      }
      debugPrint(
            '⚠ AudioService.ensurePlayback: stuck at ${after.inMilliseconds}ms (attempt $attempt)');
      // Zombie-state escape: seek to the current position to force a re-buffer.
      if (attempt >= 2) {
        try {
          await seek(after).timeout(stepTimeout);
        } catch (e) {
          debugPrint(
              '⚠ AudioService.ensurePlayback: zombie-nudge seek error (attempt $attempt): $e');
        }
      }
    }
    debugPrint(
        '✗ AudioService.ensurePlayback: gave up after $maxAttempts attempts');
  }

  void setPlaybackRate(double rate) {
    _playbackSpeed = rate;
    _player.setSpeed(rate);
    _backgroundHandler?.setPlaybackSpeed(rate);
    _savePlaybackSettings();
    notifyListeners();
  }

  void toggleLoop() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.allPlaylists;
        break;
      case LoopMode.allPlaylists:
        _loopMode = LoopMode.off;
        break;
    }
    _backgroundHandler?.setLoopMode(_loopMode);
    _backgroundHandler?.updateNotificationControls();
    _savePlaybackSettings();
    notifyListeners();
  }

  void setLoopMode(LoopMode mode) {
    _loopMode = mode;
    _backgroundHandler?.setLoopMode(_loopMode);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    _backgroundHandler?.setShuffleEnabled(_isShuffleEnabled);
    _backgroundHandler?.updateNotificationControls();
    _savePlaybackSettings();
    notifyListeners();
  }

  void setShuffledPlaylist(List<int> indices) {
    _shuffledIndices = List.from(indices);
  }

  int? getNextShuffledIndex(int currentSongIndex, int totalSongs) {
    if (!_isShuffleEnabled || _shuffledIndices == null) {
      return null;
    }

    final currentIndexInShuffle = _shuffledIndices!.indexOf(currentSongIndex);
    if (currentIndexInShuffle == -1) {
      return null;
    }

    final nextIndexInShuffle = currentIndexInShuffle + 1;
    if (nextIndexInShuffle >= _shuffledIndices!.length) {
      if (_loopMode == LoopMode.all) {
        return _shuffledIndices!.first;
      }
      return null;
    }

    return _shuffledIndices![nextIndexInShuffle];
  }

  int? getPreviousShuffledIndex(int currentSongIndex) {
    if (!_isShuffleEnabled || _shuffledIndices == null) {
      return null;
    }

    final currentIndexInShuffle = _shuffledIndices!.indexOf(currentSongIndex);
    if (currentIndexInShuffle == -1) {
      return null;
    }

    final previousIndexInShuffle = currentIndexInShuffle - 1;
    if (previousIndexInShuffle < 0) {
      if (_loopMode == LoopMode.all) {
        return _shuffledIndices!.last;
      }
      return null;
    }

    return _shuffledIndices![previousIndexInShuffle];
  }

  void resetShuffleState() {
    _isShuffleEnabled = false;
    _shuffledIndices = null;
    notifyListeners();
  }

  void setBackgroundHandler(BackgroundAudioHandler handler) {
    _backgroundHandler = handler;
    _backgroundHandler?.setLoopMode(_loopMode);
    _backgroundHandler?.setShuffleEnabled(_isShuffleEnabled);
    _backgroundHandler!.onShuffleToggled = (enabled) {
      _isShuffleEnabled = enabled;
      notifyListeners();
    };
    _backgroundHandler!.onLoopToggled = (mode) {
      _loopMode = mode;
      notifyListeners();
    };
    debugPrint('✓ AudioService: Background handler set from MainScreen');
  }

  void setCurrentPlaylist(List<Song> playlist) {
    _currentPlaylist = playlist;
    debugPrint('✓ AudioService: Current playlist set with ${playlist.length} songs');
  }

  void setCurrentSong(Song song) {
    _currentSong = song;
    currentSongIdNotifier.value = song.id;
    debugPrint('✓ AudioService: Current song set to: ${song.title}');
  }

  int? _getCurrentSongIndex() {
    if (_currentPlaylist == null || _currentPlaylist!.isEmpty || _currentSong == null) {
      return null;
    }
    return _currentPlaylist!.indexWhere((s) => s.id == _currentSong!.id);
  }

  Future<void> _playSongAtIndex(int index, String direction) async {
    debugPrint('=== _playSongAtIndex START ===');
    debugPrint('Index: $index, Direction: $direction');

    if (index < 0 || index >= _currentPlaylist!.length) {
      return;
    }

    final song = _currentPlaylist![index];

    await loadAudio(song.audioPath);
    _currentSong = song;
    currentSongIdNotifier.value = song.id;
    notifyListeners();

    if (_backgroundHandler != null) {
      await _backgroundHandler!.setPlaylist(_currentPlaylist!, index);
      await _backgroundHandler!.playSong(song, index);
    } else {
      await play();
    }

    notifyListeners();
  }

  Future<void> playNextSong() async {
    final currentIndex = _getCurrentSongIndex();
    if (currentIndex == null || currentIndex == -1) {
      debugPrint('⚠ AudioService: Cannot play next song - current song not found');
      return;
    }

    int nextIndex;
    if (_isShuffleEnabled && _shuffledIndices != null) {
      nextIndex = getNextShuffledIndex(currentIndex, _currentPlaylist!.length) ?? currentIndex;
    } else {
      if (_loopMode == LoopMode.one) {
        await seek(Duration.zero);
        await play();
        return;
      }
      if (currentIndex < _currentPlaylist!.length - 1) {
        nextIndex = currentIndex + 1;
      } else if (_loopMode == LoopMode.all) {
        nextIndex = 0;
      } else {
        debugPrint('⚠ AudioService: No next song available');
        return;
      }
    }

    await _playSongAtIndex(nextIndex, 'next');
  }

  Future<void> playPreviousSong() async {
    final currentIndex = _getCurrentSongIndex();
    if (currentIndex == null || currentIndex == -1) {
      debugPrint('⚠ AudioService: Cannot play previous song - current song not found');
      return;
    }

    int previousIndex;
    if (_isShuffleEnabled && _shuffledIndices != null) {
      previousIndex = getPreviousShuffledIndex(currentIndex) ?? currentIndex;
    } else {
      if (currentIndex > 0) {
        previousIndex = currentIndex - 1;
      } else if (_loopMode == LoopMode.all) {
        previousIndex = _currentPlaylist!.length - 1;
      } else {
        debugPrint('⚠ AudioService: No previous song available');
        return;
      }
    }

    await _playSongAtIndex(previousIndex, 'previous');
  }

  void updateBackgroundMediaItem(String title, String artist) {
    final handler = _backgroundHandler;
    if (handler != null) {
      handler.mediaItem.add(audio_pkg.MediaItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        artist: artist,
      ));
    }
  }

  @override
  void dispose() {
    _playbackEventSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _player.dispose();
    _backgroundHandler?.stop();
    currentSongIdNotifier.dispose();
    super.dispose();
  }
}
