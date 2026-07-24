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

  /// Время последнего перехода плеера в состояние playing (обновляется из
  /// [_player.playingStream]). Используется [wasPlayingRecently] как надёжный
  /// сигнал «слушатель активно слушает прямо сейчас» — в отличие от сырого
  /// `_player.playing`, не ломается в кратковременных паузах study (kick-фаза,
  /// когда [_kickPlayback] ретраит play() но плеер ещё не стартовал; TTS-пауза
  /// сегмента). Решает регрессию v5.7.3, когда `wasAudible = player.playing`
  /// ложно давал false в kick-фазе → после звонка study не возобновлялся.
  DateTime? _lastPlayingAt;

  /// Дедупликация двойного срабатывания паузы при звонке. Прямой детектор
  /// [PhoneCallService] (TelephonyManager) и `audio_session.interruptionEvent`
  /// могут оба прислать событие по одному звонку. Этот флаг гарантирует, что
  /// пауза (и захват «играло ли до звонка») выполняется ровно один раз, и resume
  /// тоже сработает один раз. Управляется из [pauseForCall]/[resumeAfterCall].
  bool _pausedForCall = false;

  /// Пользователь явно поставил паузу (кнопка экрана блокировки / FAB / media
  /// button) ПОКА шло прерывание звонка ([_pausedForCall]==true). В таком случае
  /// авто-resume по окончании звонка [_handleCallResume] НЕ должен запускать
  /// воспроизведение и study-сессию — последнее намерение пользователя
  /// «перекрывает» захваченное ранее `_wasPlayingBeforeInterruption`.
  ///
  /// Почему нужен отдельный флаг, а не просто проверка `_player.playing`: во
  /// время прерывания плеер уже остановлен (либо паузой звонка, либо самим
  /// пользователем) → `_player.playing` всегда false в момент resume, им нельзя
  /// отличить «паузил звонок» от «паузил пользователь». Флаг выставляется только
  /// в публичном [pause] (внешний триггер при активном прерывании), а внутренняя
  /// системная пауза [_systemPause] и study-сегменты его НЕ трогают. Сбрасывается
  /// в [play] (пользователь нажал play — хочет слушать) и в [_handleCallResume].
  bool _userPausedDuringCall = false;

  Function(bool)? onShuffleToggled;
  Function(LoopMode)? onLoopToggled;
  Function()? onSkipToNextRequested;
  Function()? onSkipToPreviousRequested;

  /// Вызывается в начале прерывания аудиосессии (входящий звонок, будильник,
  /// другой плеер). Возвращает `true` если колбэк взял управление паузой на себя
  /// (активен study mode → pauseSession стопает TTS + drain kick-цикла). В этом
  /// случае handler НЕ захватывает `_wasPlayingBeforeInterruption` и НЕ делает
  /// авто-resume песни после звонка — это делает [onPlaybackResumed]
  /// (resumeSession). TTS играет на отдельном AudioPlayer, который обычный
  /// pause() не затрагивает; простой TtsCoordinator.stop() здесь НЕ подходит:
  /// он завершает _speak() и study runner тут же запускает _kickPlayback(),
  /// пытающийся играть песню во время звонка.
  bool Function()? onPlaybackInterrupted;

  /// Вызывается по завершении прерывания (конец звонка). PlayerScreen
  /// возобновляет study-сессию, если она была паузнута ради звонка.
  /// `userPaused == true` означает, что пользователь вручную нажал паузу
  /// (экран блокировки / FAB) во время прерывания — в этом случае study НЕ
  /// возобновляется (уважаем последнее намерение пользователя).
  void Function(bool userPaused)? onPlaybackResumed;

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

  /// Играло ли воспроизведение за последние [_recentPlayWindow]. Надёжный сигнал
  /// «слушатель активен», используемый [PlayerScreen.onPlaybackInterrupted] для
  /// решения, возобновлять ли study после звонка. Окно выбрано с запасом больше
  /// любой паузы study (TTS-сегмент, kick-фаза — секунды), но много меньше
  /// «часов простоя» (когда пользователь lock-screen-paused и забыл).
  static const _recentPlayWindow = Duration(minutes: 2);
  bool get wasPlayingRecently {
    final t = _lastPlayingAt;
    if (t == null) return false;
    return DateTime.now().difference(t) < _recentPlayWindow;
  }

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
      // androidWillPauseWhenDucked: true — при входящем звонке ОС получает
      // AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK. С дефолтом (false) ОС сама делает
      // дакинг (приглушает медиапоток), из-за чего песня «тихонько слышно» во
      // время разговора, а наш pause() может не подействовать над уже-дакнутым
      // потоком (особенно на ColorOS China). С true ОС НЕ дакит сама, а
      // присылает interruption-событие → мы честно паузим и возобновляем.
      await session.configure(
        const AudioSessionConfiguration.music()
            .copyWith(androidWillPauseWhenDucked: true),
      );
      
      _interruptionSubscription = session.interruptionEventStream.listen((event) {
        debugPrint(
            '📞 BackgroundAudioHandler: interruption begin=${event.begin} type=${event.type}');
        if (event.begin) {
          // audio-focus interruption (будильник, другой плеер, звонок на
          // устройствах где дакинг всё-таки доставляет событие). Идёт через тот
          // же путь дедупликации, что и прямой детектор PhoneCallService:
          // whichever сработал первым ставит _pausedForCall=true, второй no-op.
          _handleCallPause();
        } else {
          _handleCallResume();
        }
      });
      
      _becomingNoisySubscription = session.becomingNoisyEventStream.listen((_) {
        pause();
      });
      
      debugPrint('✓ BackgroundAudioHandler: AudioSession configured (willPauseWhenDucked=true) with interruption handling');
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error configuring AudioSession: $e');
    }
  }

  /// Общий путь паузы для звонка/прерывания с дедупликацией. Вызывается как из
  /// `audio_session.interruptionEventStream` (begin), так и из нативного
  /// детектора [PhoneCallService] (ringing/offhook). Дедуп по [_pausedForCall]
  /// гарантирует, что по одному звонку пауза сработает ровно один раз — даже
  /// если оба источника прислали событие.
  void _handleCallPause() {
    if (_pausedForCall) {
      debugPrint('📞 BackgroundAudioHandler: pause already handled (dedupe)');
      return;
    }
    _pausedForCall = true;
    // Даём study mode корректно поставить сессию на паузу (стоп TTS +
    // drain kick-цикла). Если колбэк взял управление на себя — НЕ захватываем
    // wasPlaying и не делаем авто-resume песни, этим займётся resumeSession
    // через onPlaybackResumed.
    final studyHandled = onPlaybackInterrupted?.call() ?? false;
    _wasPlayingBeforeInterruption = studyHandled ? false : _player.playing;
    // Системная пауза (НЕ через публичный [pause]) — чтобы не выставить
    // _userPausedDuringCall: это ведь мы сами ставим паузу, а не пользователь.
    _systemPause();
  }

  /// Общий путь возобновления после звонка/прерывания с дедупликацией. См.
  /// [_handleCallPause]. Если до этого не было паузы по звонку — no-op
  /// (защита от ложного resume, если interruption-end пришёл без begin).
  void _handleCallResume() {
    if (!_pausedForCall) {
      debugPrint('📞 BackgroundAudioHandler: resume skipped (no prior pause)');
      return;
    }
    _pausedForCall = false;
    final wasPlaying = _wasPlayingBeforeInterruption;
    _wasPlayingBeforeInterruption = false;
    // Пользователь вручную нажал паузу во время прерывания (lock-screen / FAB)
    // → НЕ авто-resumeим: его последнее намерение важнее захваченного wasPlaying.
    final userPaused = _userPausedDuringCall;
    _userPausedDuringCall = false;
    if (userPaused) {
      debugPrint('📞 BackgroundAudioHandler: resume skipped '
          '(user paused during interruption)');
      // Всё равно сообщаем экрану (чтобы сбросить _studyPausedForCall), но без
      // запуска воспроизведения/study.
      onPlaybackResumed?.call(true);
      return;
    }
    if (wasPlaying) {
      play();
    }
    onPlaybackResumed?.call(false);
  }

  /// Публичный триггер паузы от нативного детектора звонка
  /// ([PhoneCallService], состояние ringing/offhook). См. [_handleCallPause].
  void pauseForCall() => _handleCallPause();

  /// Публичный триггер возобновления от нативного детектора звонка
  /// ([PhoneCallService], состояние idle). См. [_handleCallResume].
  void resumeAfterCall() => _handleCallResume();

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
      if (playing) {
        _lastPlayingAt = DateTime.now();
      }
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
    // Пользователь (lock-screen / FAB / media button) явно нажал play. Если это
    // произошло во время прерывания звонка — отменяем «хочу паузу», чтобы по
    // окончании звонка корректно возобновиться.
    if (_pausedForCall) {
      _userPausedDuringCall = false;
    }
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
    // Пользователь (lock-screen / FAB / media button) явно нажал паузу во время
    // прерывания звонка → фиксируем намерение, чтобы [_handleCallResume] НЕ
    // авто-resumeил. Если звонка нет — флаг останется false (его сбрасывает
    // [_handleCallResume] по окончании прерывания).
    if (_pausedForCall) {
      _userPausedDuringCall = true;
      debugPrint('📞 BackgroundAudioHandler: user paused during call');
    }
    await _systemPause();
  }

  /// Системная пауза плеера без выставления [_userPausedDuringCall].
  /// Используется внутренней паузой звонка [_handleCallPause] (своё управление
  /// паузой не должно помечаться как «пользовательское») — см. комментарий к
  /// [_userPausedDuringCall].
  Future<void> _systemPause() async {
    try {
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        controls: _buildControls(false),
      ));

      await _player.pause();
      _syncPlaybackState();
    } catch (e) {
      debugPrint('✗ BackgroundAudioHandler: Error in _systemPause(): $e');
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
        _loopMode = LoopMode.favorites;
        break;
      case LoopMode.favorites:
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
