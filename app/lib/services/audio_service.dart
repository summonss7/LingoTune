import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart' as audio_pkg;
import 'background_audio_handler.dart';
import '../models/song.dart';

enum LoopMode { off, all, one }

class AudioService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isInitialized = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffleEnabled = false;
  List<int>? _shuffledIndices;
  Function()? onSongComplete;
  BackgroundAudioHandler? _backgroundHandler;
  List<Song>? _currentPlaylist;
  Song? _currentSong;

  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;

  AudioPlayer get player => _player;
  BackgroundAudioHandler? get backgroundHandler => _backgroundHandler;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isInitialized;
  Duration get duration => _duration;
  Duration get position => _position;
  LoopMode get loopMode => _loopMode;
  bool get isShuffleEnabled => _isShuffleEnabled;
  List<Song>? get currentPlaylist => _currentPlaylist;
  Song? get currentSong => _currentSong;

  AudioService() {
    _initPlayer();
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
      if (state.processingState == ProcessingState.completed) {
        _onSongCompleted();
      }
      notifyListeners();
    });
  }

  void _onSongCompleted() {
    onSongComplete?.call();
  }

  Future<void> loadAudio(String audioPath) async {
    try {
      debugPrint('=== AudioService: Loading audio: $audioPath ===');
      
      if (_backgroundHandler != null) {
        await _backgroundHandler!.loadSong(audioPath);
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

  void setPlaybackRate(double rate) {
    _player.setSpeed(rate);
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
        _loopMode = LoopMode.off;
        break;
    }
    notifyListeners();
  }

  void setLoopMode(LoopMode mode) {
    _loopMode = mode;
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
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
    debugPrint('✓ AudioService: Background handler set from MainScreen');
  }

  void setCurrentPlaylist(List<Song> playlist) {
    _currentPlaylist = playlist;
    debugPrint('✓ AudioService: Current playlist set with ${playlist.length} songs');
  }

  void setCurrentSong(Song song) {
    _currentSong = song;
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
    notifyListeners();

    if (_backgroundHandler != null) {
      await _backgroundHandler!.setPlaylist(_currentPlaylist!, index);
      await _backgroundHandler!.playSong(song, index);
    } else {
      await play();
    }

    onSongComplete?.call();
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
    super.dispose();
  }
}
