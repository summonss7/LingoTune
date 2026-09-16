import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service/audio_service.dart' as audio_pkg;
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart' hide LoopMode;
import '../models/song.dart';
import '../models/loop_mode.dart';
import 'becoming_noisy_service.dart';
import 'phone_call_service.dart';

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

  /// Время последнего resume после прерывания (отбой звонка). Используется
  /// дебаунсом «эха» в [_handleCallPause] (v5.8.5): на целевых ROM
  /// audio_session присылает interruption-события с большой задержкой, и
  /// запоздалый begin уже ОТБОЙНОГО звонка делал новую паузу, а парный end
  /// больше не приходил → плеер навсегда замирал (симптом «после звонка не
  /// возобновляется»).
  DateTime? _lastResumeAt;

  /// Время последней явной паузы пользователем (публичный [pause]). Второй
  /// отложенный раунд resume-kick не должен перебивать свежее намерение
  /// пользователя (v5.8.5).
  DateTime? _lastUserPauseAt;

  /// Окно дебаунса эха: interruption-begin в пределах этого времени после
  /// resume при подтверждённо свободной линии (PhoneCallService == idle)
  /// считается эхом отбоя и игнорируется.
  static const _staleEchoWindow = Duration(seconds: 5);

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

  /// Вызывается при отключении наушников (нативный ACTION_AUDIO_BECOMING_NOISY
  /// через [BecomingNoisyService] — надёжнее audio_session, который держит
  /// свой receiver только при активном audio focus, а приложение регулярно
  /// деактивирует сессию: TTS-хендофф study, zombie-recovery). Возвращает
  /// `true`, если колбэк взял паузу на себя (активен study mode →
  /// pauseSession корректно стопает и TTS, и kick-цикл — обычный pause()
  /// плеера kick-цикл тут же перебил бы и песня заиграла бы в динамике).
  bool Function()? onBecomingNoisy;

  /// Вызывается из [pause], когда пользователь нажал паузу ЛЮБЫМ способом:
  /// FAB, мини-плеер, lock-screen, уведомление, media-button. До v5.8.6 пауза
  /// мимо FAB до StudyModeService не доходила: плеер стоял, а сессия считала
  /// себя «активной» → segment-watchdog через segLen+10с решал «зомби»,
  /// форсировал следующую строку и kick-цикл перезапускал песню («пауза не
  /// работает — само играет дальше»). Возвращает `true`, если колбэк взял
  /// паузу на себя (study активен → pauseSession: стоп TTS + drain kick +
  /// честная пауза плеера с обновлением уведомления). Внутренние паузы study
  /// идут через [pauseFromStudy] и сюда НЕ попадают.
  bool Function()? onUserPause;

  /// Вызывается из [play], когда пользователь нажал play (FAB / lock-screen /
  /// уведомление / media-button) при активной, но пользовательски
  /// запаузненной study-сессии. Возвращает `true`, если колбэк взял запуск на
  /// себя (resumeSession запускает runner, озвучку и kick плеера). Внутренние
  /// play study (kick-цикл) идут через [playFromStudy] и сюда НЕ попадают.
  bool Function()? onUserPlay;

  StreamSubscription? _playbackEventSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playingSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _interruptionSubscription;
  StreamSubscription? _becomingNoisySubscription;
  StreamSubscription? _nativeNoisySubscription;

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
        // Отключение наушников (ACTION_AUDIO_BECOMING_NOISY). Во время звонка
        // игнорируем: плеер уже на паузе (_pausedForCall), а некоторые ROM
        // шпурят это событие при смене аудио-маршрута на earpiece — без этой
        // защиты pause() выставил бы _userPausedDuringCall=true и заблокировал
        // честный авто-resume после звонка (симптом «после звонка встаёт»).
        if (_pausedForCall) {
          debugPrint('📞 BackgroundAudioHandler: becomingNoisy ignored (call in progress)');
          return;
        }
        pause();
      });

      // Нативный детектор отключения наушников — основной путь: audio_session
      // регистрирует свой receiver (выше) ТОЛЬКО пока держит audio focus, а
      // приложение регулярно деактивирует сессию (TTS-хендофф study,
      // zombie-recovery) — в этих состояниях unplug не доходил до Dart и
      // песня продолжала играть в динамике. Нативный receiver работает всегда.
      if (BecomingNoisyService.instance.start()) {
        _nativeNoisySubscription =
            BecomingNoisyService.instance.noisyEvents.listen((_) {
          _handleBecomingNoisy();
        });
      }

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
    // Дебаунс эха (v5.8.5): нативный детектор (TelephonyManager) уже дал idle,
    // мы возобновились — а сейчас пришёл ЗАПОЗДАЛЫЙ audio_session begin того
    // же звонка. Принять его = новая пауза без парного end → плеер замрёт.
    // Эхо игнорируем ТОЛЬКО при подтверждении детектором, что линия свободна;
    // без детектора (нет permission / не Android) событие принимаем как раньше.
    final lastResume = _lastResumeAt;
    if (lastResume != null &&
        DateTime.now().difference(lastResume) < _staleEchoWindow) {
      final phone = PhoneCallService.instance;
      if (phone.isListening && phone.current == CallState.idle) {
        debugPrint('📞 BackgroundAudioHandler: stale interruption echo '
            'after recent resume — ignored');
        return;
      }
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
    // Момент resume — для дебаунса эха в [_handleCallPause] (см. там).
    _lastResumeAt = DateTime.now();
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
      // Лёгкий zombie-recovery после звонка: аудиосессия была деактивирована, и
      // play() мог оставить just_audio в состоянии «playing=true, позиция не
      // двигается» — тогда песня не дойдёт до completed и не начнётся
      // следующая. Для study этот вызов не выполняется (wasPlaying=false,
      // resume делает _kickPlayback); здесь защищаем обычный фоновый путь.
      // Fire-and-forget, чтобы onPlaybackResumed сработал без задержки.
      _ensureAdvancingAfterResume();
    }
    onPlaybackResumed?.call(false);
  }

  /// Пауза при отключении наушников. Основной путь — нативный
  /// [BecomingNoisyPlugin] (подписка в [_initAudioSession]); подписка
  /// audio_session.becomingNoisyEventStream остаётся дублирующим fallback
  /// (пауза идемпотентна — второе срабатывание по уже паузнутому плееру
  /// безвредно).
  void _handleBecomingNoisy() {
    // Ничего не звучит → игнор. Покрывает и ложные noisy при смене
    // аудио-маршрута во время звонка (ROM-костыль из v5.7.4): в call-паузе
    // плеер стоит, событие должно быть проигнорировано, чтобы не тронуть
    // честный авто-resume после звонка. wasPlayingRecently покрывает
    // кратковременные паузы study (kick-фаза, TTS-сегмент).
    final audible = _player.playing || wasPlayingRecently;
    if (!audible) {
      debugPrint('🎧 BackgroundAudioHandler: becomingNoisy ignored (not audible)');
      return;
    }
    // Study mode: экран сам ставит сессию на паузу через pauseSession()
    // (стоп TTS + drain kick-цикла); системный pause() плеера kick-цикл
    // тут же перебил бы — и песня продолжила бы играть в динамике.
    if (onBecomingNoisy?.call() ?? false) {
      return;
    }
    if (_pausedForCall) {
      // Редкий случай: ROM не остановил воспроизведение во время звонка и
      // слушатель выдернул наушники. Только системная пауза, без
      // _userPausedDuringCall — чтобы не блокировать авто-resume после звонка.
      debugPrint('🎧 BackgroundAudioHandler: becomingNoisy → system pause (call in progress)');
      _systemPause();
      return;
    }
    debugPrint('🎧 BackgroundAudioHandler: becomingNoisy → pause');
    pause();
  }

  /// Лёгкий zombie-recovery после звонка (см. [_handleCallResume]). Проверяет,
  /// действительно ли позиция плеера двигается после resume-`play()`; если нет —
  /// реактивирует аудиосессию и ретраит play(). Несколько попыток с timeout,
  /// чтобы висящий just_audio Future нас не заблокировал. Если первый раунд не
  /// раскачал позицию — ОДИН отложенный второй раунд через 5с (v5.8.5): на
  /// части ROM in-call UI возвращает фокус позже нашего кика, и раньше после
  /// сдачи ретраев не было вообще (симптом «после звонка так и не заиграло»).
  Future<void> _ensureAdvancingAfterResume() async {
    if (await _resumeKickRound()) return;
    await Future.delayed(const Duration(seconds: 5));
    // Начался новый звонок/прерывание или пользователь явно нажал паузу за
    // время ожидания — не перебиваем чужое намерение.
    if (_pausedForCall) {
      debugPrint('⚠ BackgroundAudioHandler: second resume-kick round skipped '
          '(new interruption)');
      return;
    }
    final lastPause = _lastUserPauseAt;
    if (lastPause != null &&
        DateTime.now().difference(lastPause) < const Duration(seconds: 6)) {
      debugPrint('⚠ BackgroundAudioHandler: second resume-kick round skipped '
          '(user paused)');
      return;
    }
    await _resumeKickRound();
  }

  /// Один раунд resume-kick'а (3 попытки). Возвращает true, когда продолжать
  /// не нужно: позиция двигается, песня доиграла, начался звонок либо раунд
  /// исчерпан (false — можно пробовать ещё один отложенный).
  Future<bool> _resumeKickRound() async {
    const stepTimeout = Duration(seconds: 1);
    for (int attempt = 1; attempt <= 3; attempt++) {
      if (_pausedForCall) {
        debugPrint('⚠ BackgroundAudioHandler: resume-kick aborted '
            '(call/interruption in progress)');
        return true;
      }
      final Duration before = _player.position;
      await Future.delayed(const Duration(milliseconds: 400));
      // Песня естественным образом доиграла — кикать нечего.
      if (_player.processingState == ProcessingState.completed) {
        debugPrint('⚠ BackgroundAudioHandler: resume-kick — player completed, nothing to kick');
        return true;
      }
      final Duration after = _player.position;
      if (after != before) {
        debugPrint('✓ BackgroundAudioHandler: playback advancing after resume '
            '(attempt $attempt, ${before.inMilliseconds}→${after.inMilliseconds}ms)');
        return true;
      }
      debugPrint('⚠ BackgroundAudioHandler: resume-kick attempt $attempt '
          '— position stuck at ${after.inMilliseconds}ms');
      try {
        final session = await AudioSession.instance;
        await session.setActive(true).timeout(stepTimeout);
        await _player.play().timeout(stepTimeout);
      } catch (e) {
        debugPrint('⚠ BackgroundAudioHandler: resume-kick error (attempt $attempt): $e');
      }
    }
    debugPrint('✗ BackgroundAudioHandler: resume-kick round gave up '
        '(position not advancing)');
    return false;
  }

  /// Публичный триггер паузы от нативного детектора звонка
  /// ([PhoneCallService], состояние ringing/offhook). См. [_handleCallPause].
  void pauseForCall() => _handleCallPause();

  /// Публичный триггер возобновления от нативного детектора звонка
  /// ([PhoneCallService], состояние idle). См. [_handleCallResume].
  void resumeAfterCall() => _handleCallResume();

  /// Активна ли сейчас пауза по звонку/прерыванию (см. [_pausedForCall]).
  /// Публичный гейт для study kick-цикла и watchdog'ов экрана: не бороться с
  /// легитимной паузой и не форсить смену песни посреди разговора (v5.8.5).
  bool get isPausedForCall => _pausedForCall;

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
          // Рестарт loop-one в async-функции с try/finally + timeout: цепочка
          // seek().then(play().then(...)) БЕЗ обработки ошибок могла залипнуть
          // _isHandlingCompletion=true навсегда, если seek/play бросал или висел
          // (just_audio Futures виснут после деактивации сессии TTS/звонком) —
          // тогда loop-one навсегда переставал перезапускать песню. Теперь флаг
          // гарантированно сбрасывается в finally.
          _restartLoopOne();
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

  /// Перезапуск текущей песни для LoopMode.one. Поправляет зомби-состояние
  /// just_audio, типичное сразу после `processingState == completed`: seek(0)
  /// сбрасывает позицию в начало, но `play()` может НЕ запустить звук (плеер
  /// числится playing, позиция стоит на 0) — симптом «переключилось в начало,
  /// но плей не включается». Поэтому после seek+play проверяем, что позиция
  /// реально пошла от 0; если нет — реактивируем аудиосессию и nudge'им seek'ом
  /// к текущей позиции (force re-buffer), как в [_kickPlaybackAsync] /
  /// [AudioService.ensurePlaybackAdvancing]. Try/finally + timeout гарантируют,
  /// что [_isHandlingCompletion] всегда сбросится.
  Future<void> _restartLoopOne() async {
    const stepTimeout = Duration(seconds: 1);
    try {
      for (int attempt = 1; attempt <= 4; attempt++) {
        try {
          await _player.seek(Duration.zero).timeout(stepTimeout);
        } catch (e) {
          debugPrint(
              '⚠ BackgroundAudioHandler: loop-one seek error (attempt $attempt): $e');
        }
        try {
          await _player.play().timeout(stepTimeout);
        } catch (e) {
          debugPrint(
              '⚠ BackgroundAudioHandler: loop-one play error (attempt $attempt): $e');
        }
        // Даём плееру ~0.4с реально стартовать и проверяем движение позиции.
        await Future.delayed(const Duration(milliseconds: 400));
        final pos = _player.position;
        if (pos > Duration.zero) {
          debugPrint('✓ BackgroundAudioHandler: LoopMode.one restarted on '
              'attempt $attempt (pos=${pos.inMilliseconds}ms)');
          return;
        }
        // Зомби: позиция стоит на 0 при playing=true. Nudge — реактивируем
        // сессию и seek к текущей позиции, чтобы заставить just_audio re-buffer.
        debugPrint('⚠ BackgroundAudioHandler: loop-one zombie at 0 '
            '(attempt $attempt) — nudging');
        try {
          final session = await AudioSession.instance;
          await session.setActive(true).timeout(stepTimeout);
        } catch (e) {
          debugPrint(
              '⚠ BackgroundAudioHandler: loop-one session error (attempt $attempt): $e');
        }
        try {
          await _player.seek(_player.position).timeout(stepTimeout);
        } catch (e) {
          debugPrint(
              '⚠ BackgroundAudioHandler: loop-one nudge seek error (attempt $attempt): $e');
        }
      }
      debugPrint('✗ BackgroundAudioHandler: LoopMode.one restart — '
          'position not advancing after retries');
    } catch (e) {
      debugPrint('⚠ BackgroundAudioHandler: LoopMode.one restart error: $e');
    } finally {
      _isHandlingCompletion = false;
    }
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
    // Study-сессия на пользовательской паузе → её возобновляет колбэк
    // (resumeSession: runner + озвучка + kick плеера). Дублировать запуск
    // здесь не нужно. Активная НЕзапаузненная сессия возвращает false —
    // дальше обычный play (no-op: плеером управляет runner/kick).
    if (!_pausedForCall && (onUserPlay?.call() ?? false)) {
      return;
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
    _lastUserPauseAt = DateTime.now();
    // Активен study mode → пауза уходит в pauseSession (стоп TTS + drain
    // kick-цикла + честная пауза плеера). Без хендоффа прямая пауза плеера
    // стояла бы только до ближайшего kick'а (v5.8.6). Во время звонка
    // (_pausedForCall) study уже паузнут call-машиной — там своё расписание.
    if (!_pausedForCall && (onUserPause?.call() ?? false)) {
      return;
    }
    await _systemPause();
  }

  /// Пауза плеера ИЗ ВНУТРЕННЕЙ логики StudyModeService (TTS-фазы runner'а,
  /// финальная пауза pauseSession, stop). В отличие от публичного [pause] это
  /// НЕ пользовательское намерение: не дёргает [onUserPause] (иначе пауза
  /// TTS-фазы рекурсивно «превращалась» бы в pauseSession) и не трогает
  /// [_userPausedDuringCall] / [_lastUserPauseAt]. Уведомление обновляется —
  /// как и в [_systemPause].
  Future<void> pauseFromStudy() => _systemPause();

  /// play() ИЗ ВНУТРЕННЕЙ логики StudyModeService (kick-цикл после TTS).
  /// Без колбэка [onUserPlay]: kick — служебный, не «пользователь нажал play»
  /// (иначе in-flight kick во время паузы воскресил бы её через resumeSession).
  /// Тело повторяет [play] без пользовательских веток.
  Future<void> playFromStudy() async {
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
      debugPrint('✗ BackgroundAudioHandler: Error in playFromStudy(): $e');
    }
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
    // Нативную noisy-подписку снимаем только здесь, а НЕ в stop(): stop()
    // вызывается и при обычной остановке воспроизведения (закрытие
    // уведомления), а receiver должен пережить её — иначе после остановки и
    // повторного запуска воспроизведения отключение наушников снова
    // потерялось бы (регрессия «подписки отменяются навсегда»).
    await _nativeNoisySubscription?.cancel();
    _nativeNoisySubscription = null;
    BecomingNoisyService.instance.stop();
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
    // Цикл с уведомления (экран блокировки) ограничен базовыми режимами
    // off → all → one → off. allPlaylists/favorites требуют динамической
    // загрузки списков в PlayerScreen (БД/плейлисты), что недоступно из
    // notification-контролов: попадание в них с экрана блокировки ломало бы
    // очередь. Если текущий режим — allPlaylists/favorites, сбрасываем в off.
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
      case LoopMode.allPlaylists:
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
