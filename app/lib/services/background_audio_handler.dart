import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service/audio_service.dart' as audio_pkg;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' hide LoopMode;
import '../models/song.dart';
import '../models/loop_mode.dart';

class BackgroundAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffleEnabled = false;
  bool _isHandlingCompletion = false;
  bool _wasPlayingBeforeInterruption = false;

  Function(bool)? onShuffleToggled;
  Function(LoopMode)? onLoopToggled;
  Function()? onSkipToNextRequested;
  Function()? onSkipToPreviousRequested;

  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _interruptionSubscription;
  StreamSubscription? _becomingNoisySubscription;

  BackgroundAudioHandler(this._player) {
    _setupListeners();
    _initAudioSession();
    _initializeState();
  }

  LoopMode get loopMode => _loopMode;
  bool get isShuffleEnabled => _isShuffleEnabled;

  void setLoopMode(LoopMode mode) {
    _loopMode = mode;
    debugPrint('✓ BackgroundAudioHandler: Loop mode set to: $mode');
  }

  void setShuffleEnabled(bool enabled) {
    _isShuffleEnabled = enabled;
    debugPrint('✓ BackgroundAudioHandler: Shuffle set to: $enabled');
  }

  void updateNotificationControls() {
    _syncPlaybackState();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      
      _interruptionSubscription = session.interruptionEventStream.listen((event) {
        if (event.begin) {
          _wasPlayingBeforeInterruption = _player.playing;
          pause();
        } else {
          if (_wasPlayingBeforeInterruption) {
            play();
          }
          _wasPlayingBeforeInterruption = false;
        }
      });
      
      _becomingNoisySubscription = session.becomingNoisyEventStream.listen((_) {
        pause();
      });
      
      debugPrint('✓ BackgroundAudioHandler: AudioSession configured with interruption handling');
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error configuring AudioSession: $e');
    }
  }

  void _initializeState() {
    playbackState.add(PlaybackState(
      controls: _buildControls(false),
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [1, 2, 3],
      processingState: AudioProcessingState.idle,
      playing: false,
      updatePosition: Duration.zero,
    ));
  }

  void _setupListeners() {
    _playbackEventSubscription = _player.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.one && !_isHandlingCompletion) {
          _isHandlingCompletion = true;
          debugPrint('✓ BackgroundAudioHandler: LoopMode.one - restarting song');
          _player.seek(Duration.zero).then((_) {
            _player.play().then((_) {
              _isHandlingCompletion = false;
            });
          });
        }
      } else {
        _isHandlingCompletion = false;
      }
      _syncPlaybackState();
    });

    _positionSubscription = _player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    _playingSubscription = _player.playingStream.listen((playing) {
      _syncPlaybackState();
    });

    _bufferedPositionSubscription = _player.bufferedPositionStream.listen((bufferedPosition) {
      playbackState.add(playbackState.value.copyWith(
        bufferedPosition: bufferedPosition,
      ));
    });

    _playerStateSubscription = _player.playerStateStream.listen((state) {
      final processingState = _mapProcessingState(state.processingState);
      playbackState.add(playbackState.value.copyWith(
        processingState: processingState,
      ));
    });

    _durationSubscription = _player.durationStream.listen((duration) {
      final currentMediaItem = mediaItem.value;
      if (currentMediaItem != null && duration != null) {
        mediaItem.add(currentMediaItem.copyWith(duration: duration));
      }
    });
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  List<audio_pkg.MediaControl> _buildControls(bool playing) {
    return [
      audio_pkg.MediaControl(
        androidIcon: 'drawable/ic_shuffle',
        label: _isShuffleEnabled ? 'Shuffle on' : 'Shuffle off',
        action: MediaAction.setShuffleMode,
      ),
      audio_pkg.MediaControl.skipToPrevious,
      playing ? audio_pkg.MediaControl.pause : audio_pkg.MediaControl.play,
      audio_pkg.MediaControl.skipToNext,
      audio_pkg.MediaControl(
        androidIcon: _loopMode == LoopMode.one ? 'drawable/ic_repeat_one' : 'drawable/ic_repeat',
        label: _loopMode == LoopMode.off ? 'Repeat off' : _loopMode == LoopMode.all ? 'Repeat all' : 'Repeat one',
        action: MediaAction.setRepeatMode,
      ),
    ];
  }

  void _syncPlaybackState() {
    final playing = _player.playing;

    playbackState.add(playbackState.value.copyWith(
      playing: playing,
      controls: _buildControls(playing),
      updatePosition: _player.position,
      androidCompactActionIndices: const [1, 2, 3],
    ));
  }

  Future<void> loadSong(String audioPath) async {
    try {
      // Timeouts guard against just_audio Futures that can hang indefinitely
      // after the Android audio session was deactivated by TTS speech (study
      // mode): a plain setFilePath() Future may never resolve in that state,
      // which would block the caller forever. The actual load is verified
      // separately by AudioService.ensurePlaybackAdvancing().
      if (audioPath.startsWith('content://')) {
        await _player.setUrl(audioPath)
            .timeout(const Duration(seconds: 5));
      } else {
        await _player.setFilePath(audioPath)
            .timeout(const Duration(seconds: 5));
      }
      debugPrint('✓ BackgroundAudioHandler: Loaded audio: $audioPath');
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error loading audio: $e');
    }
  }

  void setPlaybackSpeed(double speed) {
    _player.setSpeed(speed);
  }

  Future<void> setPlaylist(List<Song> playlist, int startIndex) async {
    final mediaItems = playlist.map((song) => audio_pkg.MediaItem(
      id: song.audioPath,
      title: song.title,
      artist: song.artist,
      artUri: song.coverArtPath != null ? Uri.file(song.coverArtPath!) : null,
    )).toList();

    queue.add(mediaItems);

    if (mediaItems.isNotEmpty && startIndex >= 0 && startIndex < mediaItems.length) {
      mediaItem.add(mediaItems[startIndex]);
    }
  }

  Future<void> playSong(Song song, int index) async {
    try {
      // Timeouts on every await are CRITICAL here: after the Android audio
      // session is deactivated by TTS speech (study mode), just_audio Futures
      // — especially `_player.play()` — can hang indefinitely (the audio
      // actually starts, but the Future never resolves). A hanging play()
      // blocks this method, which blocks PlayerScreen._playSong, which then
      // never reaches study-mode restart -> study stays inactive after a song
      // switch until the user manually presses play/pause (which issues a new
      // play/pause that resolves the hung Future). Bounding each await breaks
      // the deadlock; real playback is re-verified by
      // AudioService.ensurePlaybackAdvancing() in _playSong.
      final session = await AudioSession.instance;
      await session.setActive(true).timeout(const Duration(seconds: 2));

      if (song.audioPath.startsWith('content://')) {
        await _player.setUrl(song.audioPath)
            .timeout(const Duration(seconds: 5));
      } else {
        await _player.setFilePath(song.audioPath)
            .timeout(const Duration(seconds: 5));
      }

      final duration = _player.duration ?? Duration.zero;

      final newMediaItem = audio_pkg.MediaItem(
        id: song.audioPath,
        title: song.title,
        artist: song.artist,
        artUri: song.coverArtPath != null ? Uri.file(song.coverArtPath!) : null,
        duration: duration,
      );

      mediaItem.add(newMediaItem);

      final queueList = queue.value;
      if (index >= 0 && index < queueList.length) {
        playbackState.add(playbackState.value.copyWith(queueIndex: index));

        final updatedQueue = queueList[index].copyWith(duration: duration);
        queueList[index] = updatedQueue;
        queue.add(queueList);
      }

      await _player.play().timeout(const Duration(seconds: 1));
      _syncPlaybackState();
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error playing song: $e');
    }
  }

  Future<void> updateNotification(Song song, int index) async {
    try {
      final duration = _player.duration ?? Duration.zero;

      final newMediaItem = audio_pkg.MediaItem(
        id: song.audioPath,
        title: song.title,
        artist: song.artist,
        artUri: song.coverArtPath != null ? Uri.file(song.coverArtPath!) : null,
        duration: duration,
      );

      mediaItem.add(newMediaItem);

      final queueList = queue.value;
      if (index >= 0 && index < queueList.length) {
        playbackState.add(playbackState.value.copyWith(queueIndex: index));

        final updatedQueue = queueList[index].copyWith(duration: duration);
        queueList[index] = updatedQueue;
        queue.add(queueList);
      }

      debugPrint('✓ BackgroundAudioHandler: Notification updated for: ${song.title}');
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error updating notification: $e');
    }
  }

  void updateCurrentSong(Song song) {
    mediaItem.add(audio_pkg.MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      artUri: song.coverArtPath != null ? Uri.file(song.coverArtPath!) : null,
    ));
  }

  @override
  Future<void> play() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
      
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        controls: _buildControls(true),
        processingState: AudioProcessingState.ready,
      ));

      await _player.play();
      _syncPlaybackState();
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error in play(): $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        controls: _buildControls(false),
      ));

      await _player.pause();
      _syncPlaybackState();
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error in pause(): $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
      
      await _playbackEventSubscription?.cancel();
      await _positionSubscription?.cancel();
      await _playingSubscription?.cancel();
      await _bufferedPositionSubscription?.cancel();
      await _playerStateSubscription?.cancel();
      await _durationSubscription?.cancel();
      await _interruptionSubscription?.cancel();
      await _becomingNoisySubscription?.cancel();

      await _player.stop();

      playbackState.add(PlaybackState(
        controls: [],
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
      ));
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error in stop(): $e');
    }
  }

  Future<void> dispose() async {
    await stop();
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error in seek(): $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onSkipToNextRequested != null) {
      debugPrint('✓ BackgroundAudioHandler: skipToNext → delegating to PlayerScreen');
      onSkipToNextRequested!();
      return;
    }
    debugPrint('⚠ BackgroundAudioHandler: skipToNext — no callback, using fallback');
    final queueList = queue.value;
    final currentIndex = playbackState.value.queueIndex ?? 0;
    if (queueList.isEmpty) return;
    final nextIndex = (currentIndex + 1) % queueList.length;
    await skipToQueueItem(nextIndex);
  }

  @override
  Future<void> skipToPrevious() async {
    if (onSkipToPreviousRequested != null) {
      debugPrint('✓ BackgroundAudioHandler: skipToPrevious → delegating to PlayerScreen');
      onSkipToPreviousRequested!();
      return;
    }
    debugPrint('⚠ BackgroundAudioHandler: skipToPrevious — no callback, using fallback');
    final queueList = queue.value;
    final currentIndex = playbackState.value.queueIndex ?? 0;
    if (queueList.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    final previousIndex = (currentIndex - 1 + queueList.length) % queueList.length;
    await skipToQueueItem(previousIndex);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    final queueList = queue.value;

    if (index < 0 || index >= queueList.length) {
      return;
    }

    final item = queueList[index];
    mediaItem.add(item);

    try {
      if (item.id.startsWith('content://')) {
        await _player.setUrl(item.id);
      } else {
        await _player.setFilePath(item.id);
      }

      playbackState.add(playbackState.value.copyWith(
        queueIndex: index,
      ));

      final duration = _player.duration ?? Duration.zero;
      final updatedItem = item.copyWith(duration: duration);
      queueList[index] = updatedItem;
      queue.add(queueList);

      await _player.play();
      _syncPlaybackState();
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error skipping to queue item: $e');
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _isShuffleEnabled = !_isShuffleEnabled;
    debugPrint('✓ BackgroundAudioHandler: Shuffle toggled to: $_isShuffleEnabled');
    onShuffleToggled?.call(_isShuffleEnabled);
    _syncPlaybackState();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
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
    debugPrint('✓ BackgroundAudioHandler: Loop mode toggled to: $_loopMode');
    onLoopToggled?.call(_loopMode);
    _syncPlaybackState();
  }

  @override
  Future<void> playMediaItem(audio_pkg.MediaItem mediaItem) async {
    await play();
  }
}
