import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:just_audio/just_audio.dart' show ProcessingState;
import 'package:audio_service/audio_service.dart' as audio_pkg;
import 'package:permission_handler/permission_handler.dart';
import '../models/song.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart' show Translation;
import '../models/loop_mode.dart';
import '../models/playlist.dart';
import '../services/audio_service.dart';
import '../services/audio_position_corrector.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
import '../services/study_mode_service.dart';
import '../services/settings_provider.dart';
import '../services/car_detection_service.dart';
import '../services/car_alert_service.dart';
import '../services/export_import_service.dart';
import '../services/database_service.dart';
import '../services/folder_config_service.dart';
import '../services/phone_call_service.dart';
import '../services/tts_coordinator.dart';
import '../services/tts/tts_engine.dart' show TtsSource;
import '../widgets/lyric_line_widget.dart';
import '../widgets/settings/vertical_focus_offset_slider.dart';
import 'translation_editor_screen.dart';
import 'text_loader_dialog.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../utils/lrc_formatter.dart';
import '../utils/lyric_colors.dart';
import 'helpers/player_translation_helper.dart';
import 'helpers/player_playlist_helper.dart';
import 'helpers/player_import_helper.dart';
import 'helpers/player_export_helper.dart';
import '../utils/language_helpers.dart';

class PlayerScreen extends StatefulWidget {
  final Song song;
  final AudioService audioService;
  final LyricsService lyricsService;
  final TranslationService translationService;
  final List<Song>? playlistSongs;
  final bool shouldResume;

  const PlayerScreen({
    super.key,
    required this.song,
    required this.audioService,
    required this.lyricsService,
    required this.translationService,
    this.playlistSongs,
    this.shouldResume = false,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  Timer? _positionTimer;
  bool _highlightNextLine = true;
  bool _isEditMode = false;
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;
  List<GlobalKey> _lineKeys = [];
  int _lastScrolledIndex = -1;
  late Song _currentSong;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  final Random _random = Random();

  /// Корректор позиции для подсветки строк (wall-clock интерполяция против
  /// VBR MP3 дрейфа). Применяется только к LyricsService.updatePosition.
  final AudioPositionCorrector _positionCorrector = AudioPositionCorrector();

  /// Wall-clock момент последнего setState в _positionTimer (throttling до
  /// ~8/сек вместо 20/сек — снижает нагрузку на UI-изолят, из-за которой
  /// колбэк positionStream обрабатывался с задержкой → _position устаревал).
  DateTime _lastSetStateTime = DateTime.fromMillisecondsSinceEpoch(0);

  /// Живой список песен АКТИВНОГО плейлиста (того, что сейчас играет).
  /// Изначально = [widget.playlistSongs], но в режиме `LoopMode.allPlaylists`
  /// переключается на другой плейлист. Все операции next/prev/queue работают с
  /// этим списком, а не с устаревшим [widget.playlistSongs] (который фиксируется
  /// при создании экрана и не обновляется при переходе между плейлистами).
  List<Song>? _activePlaybackList;

  /// Глобальная перемешанная очередь для `allPlaylists` + shuffle (v5.8.7):
  /// ВСЕ песни библиотеки (объединение всех плейлистов, дедуп по song.id) в
  /// случайном порядке — «случайный по плейлистам» больше не прогоняет папку
  /// подряд, а тянет почти каждую песню со всей библиотеки. Строится лениво
  /// при первом next и пересобирается после исчерпания цикла. `null` — не
  /// построена (или шаффл выключен).
  List<Song>? _globalShuffleQueue;

  /// Позиция в [_globalShuffleQueue] последней запущенной песни (-1 — ещё
  /// ничего из очереди не играли).
  int _globalShufflePos = -1;

  bool _cachedShowTranscription = false;
  int _lastProcessedIndex = -1;
  int _lastProcessedLanguageIndex = -1;

  final PlayerTranslationHelper _playerTranslationHelper =
      PlayerTranslationHelper();
  final PlayerPlaylistHelper _playerPlaylistHelper = PlayerPlaylistHelper();
  final PlayerImportHelper _playerImportHelper = PlayerImportHelper();
  final PlayerExportHelper _playerExportHelper = PlayerExportHelper();

  late final StudyModeService _studyModeService;

  double _autoScrollFocusOffset = 0.0;
  double _playbackSpeed = 1.0;
  bool _isFirstLoad = true;
  bool _isInBackground = false;
  bool _isReloading = false;
  bool _isSongLoading = false;

  /// Watchdog дедлока завершения трека в study-режиме. Когда песня доиграла
  /// (`processingState == completed`), обычный путь [onSongComplete] заблоки-
  /// рован (study активен), а продвижение зависит от того, что СВОЙ детектор
  /// study поймает completed и дёрнет [onStudyCompleted]. После звонка этот
  /// детектор может не сработать чисто → песня доиграла, а следующая не
  /// началась. Watchdog принудительно запускает следующую, если за ~4с study
  /// не продвинулся. [_watchdogSongId] хранит id песни, на которой вооружились
  /// (если песня сменилась — study справился, форсить не нужно).
  Timer? _completionWatchdog;
  String? _watchdogSongId;

  /// Сколько раз подряд watchdog дедлока завершения РЕАРМИЛСЯ из-за
  /// «подозрительных» состояний (call-пауза / user-пауза study), не стреляя
  /// (v5.8.8). Бесконечный реарм и был багом «после звонка/уведомления
  /// следующая песня сама не включается»: залипший флаг паузы при ДОИГРАВШЕЙ
  /// песне держал петлю вечно (лечилось только ручными пауза+play). После
  /// [_callStuckRearmLimit] / [_userPauseStuckRearmLimit] реармов подряд при
  /// подтверждённо свободной линии включается самолечение
  /// ([_selfHealStuckCompletion]).
  int _watchdogStuckRearms = 0;

  /// Порог реармов для call-ветки (~20 с): begin без end (beep уведомления,
  /// эхо отбоя вне окна дебаунса) — снимаем паузу и форсим next.
  static const int _callStuckRearmLimit = 5;

  /// Порог реармов для user-pause-ветки (~32 с): порог выше, чтобы у
  /// настоящей пользовательской паузы был запас; самолечение дополнительно
  /// требует `processingState == completed` (пауза при ДОИГРАВШЕЙ песне —
  /// гонка прерывания, а не намерение «продолжить позже»).
  static const int _userPauseStuckRearmLimit = 8;

  /// Была ли study-сессия паузнута ради входящего звонка/прерывания. Ставится
  /// в [onPlaybackInterrupted] (BackgroundAudioHandler) и снимается в
  /// [onPlaybackResumed], чтобы после звонка корректно возобновить озвучку.
  bool _studyPausedForCall = false;

  /// Производился ли РЕАЛЬНО звук study-сессией в момент начала прерывания
  /// звонка (TTS говорил ИЛИ песня играла). Захватывается в
  /// [onPlaybackInterrupted]. Нужно, чтобы не возобновлять study после отбоя,
  /// если на самом деле давно ничего не звучало: lock-screen pause останавливает
  /// плеер, но НЕ доходит до [StudyModeService.pauseSession], поэтому study
  /// числится «активным и не паузнутым» (`isActive && !isUserPaused`) даже через
  /// часы тишины. Без этого флага после звонка music внезапно заигрывал бы.
  bool _studyWasAudibleBeforeCall = false;

  /// Подписка на нативный детектор звонка ([PhoneCallService]). На ряде ROM
  /// (ColorOS/Realme UI, MIUI/HyperOS) системный дакинг медиапотока при звонке
  /// игнорирует `willPauseWhenDucked`, и audio-focus interruption либо
  /// опаздывает, либо не приходит. Прямой слушатель TelephonyManager
  /// срабатывает в момент начала звонка — гарантированно раньше дакинга.
  StreamSubscription<CallState>? _phoneCallSub;

  /// Находится ли текущая песня в системном плейлисте `favorites`. Обновляется
  /// при смене песни ([_playSong]) и по тапу на кнопку-сердечко.
  bool _isCurrentSongFavorite = false;

  // === DIAGNOSTIC (5.0.7): last study-mode lifecycle event, shown in the
  // service-data overlay so we can trace why study fails to restart after a
  // song switch. Remove after the root cause is fixed. ===
  String _lastStudyEvent = 'init';
  void _studyEvt(String msg) {
    _lastStudyEvent = msg;
    debugPrint('🔍 STUDY-EVT: $msg');
    // Force the overlay to refresh immediately so we can follow the lifecycle
    // LIVE (the 50ms position timer is cancelled during _playSong, so without
    // this the overlay would freeze and hide the exact failure point).
    if (mounted) setState(() {});
  }

  SettingsProvider? _settingsProvider;

  // Единый TTS-координатор (singleton) — читаем диагностику для overlay.
  final TtsCoordinator _ttsCoordinator = TtsCoordinator.instance;
  // Кеш текущего ttsSource (чтобы реагировать на смену в Настройках).
  String _currentTtsSource = 'offline';

  late final CarDetectionService _carDetectionService;
  late final CarAlertService _carAlertService;

  // Время последнего обработанного срабатывания (чтобы не запускать alert
  // повторно для одного и того же lastDetection).
  DateTime? _lastProcessedCarDetectionAt;

  void _onCarDetection() {
    // CarDetectionService.notifyListeners вызывается как на срабатывании,
    // так и при старте/остановке. Реагируем только на новые детекции.
    final detection = _carDetectionService.lastDetection;
    if (detection == null) return;
    final lastAt = _lastProcessedCarDetectionAt;
    if (lastAt != null && detection.timestamp.isAtSameMomentAs(lastAt)) {
      return;
    }
    _lastProcessedCarDetectionAt = detection.timestamp;

    debugPrint('🚗 PlayerScreen: car detected → alert');
    // Запускаем alert (звук/вибро/голос) и обновляем overlay.
    _carAlertService.alert(detection);
    if (mounted) setState(() {});
  }

  Future<void> _toggleCarDetection() async {
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    if (_carDetectionService.isActive) {
      await _carDetectionService.stop();
      await sp.setCarDetectionEnabled(false);
      return;
    }
    final ok = await _carDetectionService.start(
      sensitivity: sp.carDetectionSensitivity,
    );
    if (ok) {
      await sp.setCarDetectionEnabled(true);
      await _carAlertService.ensureInitialized();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.carDetectionStarted),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.carDetectionMicDenied),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  List<Song> get playlistSongs => widget.playlistSongs ?? [];

  @override
  bool get wantKeepAlive => true;

  void _onSettingsChanged() {
    final sp = _settingsProvider;
    if (sp != null) {
      widget.lyricsService.setPositionOffset(sp.lyricsPositionOffset);
      // Реакция на смену источника TTS (offline/system) в Настройках.
      if (sp.ttsSource != _currentTtsSource) {
        _currentTtsSource = sp.ttsSource;
        _applyTtsSource();
      }
    }
  }

  /// Переключает координатор на текущий ttsSource из SettingsProvider.
  /// Безопасно вызывать многократно — координатор сам пропустит no-op.
  Future<void> _applyTtsSource() async {
    final sp = _settingsProvider;
    if (sp == null) return;
    final source =
        sp.ttsSource == 'system' ? TtsSource.system : TtsSource.offline;
    final lang = widget.translationService.currentTranslation?.language ?? 'ru';
    try {
      await _ttsCoordinator.setTtsSource(source, languageCode: lang);
      // После смены движка — синхронизируем доступность языка в study.
      if (_studyModeService.isActive) {
        await _studyModeService.applyConfiguredEngine();
      }
    } catch (e) {
      debugPrint('⚠ PlayerScreen: setTtsSource($source) error: $e');
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    if (_settingsProvider != sp) {
      _settingsProvider?.removeListener(_onSettingsChanged);
      _settingsProvider = sp;
      _currentTtsSource = sp.ttsSource;
      _settingsProvider!.addListener(_onSettingsChanged);
      widget.lyricsService.setPositionOffset(sp.lyricsPositionOffset);
      // Первый запуск координатора с правильным ttsSource. Безопасен для
      // повторных вызовов — координатор идемпотентен.
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyTtsSource());
    }
    debugPrint('=== PlayerScreen: didChangeDependencies ===');
    debugPrint('Widget song: ${widget.song.title}');
    debugPrint('Current song: ${_currentSong.title}');
    debugPrint('AudioService song: ${widget.audioService.currentSong?.title}');
    debugPrint(
        'Lyrics lines in service: ${widget.lyricsService.lyricLines.length}');
    debugPrint(
        'Translations in service: ${widget.translationService.translations.length}');

    if (_isReloading) {
      debugPrint('=== Skipping didChangeDependencies: reload in progress ===');
      return;
    }

    if (_currentSong.id != widget.song.id) {
      final actualPlayingPath = widget.audioService.currentSong?.audioPath;
      if (actualPlayingPath != null &&
          actualPlayingPath != widget.song.audioPath &&
          actualPlayingPath == _currentSong.audioPath) {
        debugPrint(
            '=== Skipping didChangeDependencies: audioService plays _currentSong, not widget.song ===');
        return;
      }

      debugPrint('=== Song ID changed, syncing ===');
      _currentSong = widget.song;
      _isShuffleEnabled = widget.audioService.isShuffleEnabled;
      _loopMode = widget.audioService.loopMode;
      _reloadSongDataWithSettings();
    } else if (widget.song.lrcPath != _currentSong.lrcPath ||
        widget.lyricsService.lyricLines.isEmpty) {
      debugPrint('=== Reloading because lrcPath changed OR lyrics empty ===');
      _reloadSongData();
    } else if (widget.translationService.translations.isEmpty) {
      debugPrint('=== Reloading because translations are empty ===');
      _reloadSongData();
    } else if (widget.translationService.currentTranslation == null) {
      debugPrint('=== Restoring currentTranslation (was null) ===');
      _restoreCurrentTranslation();
    }
  }

  Future<void> _restoreCurrentTranslation() async {
    if (widget.translationService.translations.isNotEmpty &&
        widget.translationService.currentTranslation == null) {
      debugPrint('✓ Restoring currentTranslation from available translations');
      await _selectLanguageBasedOnSettings();
      await _updateAllLyricsWithTranslations();
      if (mounted) setState(() {});
    }
  }

  Future<void> _reloadSongDataWithSettings() async {
    await _loadSettings();

    final prefs = await SharedPreferences.getInstance();
    final defaultOffset =
        prefs.getDouble('defaultAutoScrollFocusOffset') ?? 50.0;
    await prefs.setDouble('autoScrollFocusOffset', defaultOffset);
    if (!mounted) return;
    setState(() {
      _autoScrollFocusOffset = defaultOffset;
    });

    if (_currentSong.lrcPath != null && _currentSong.lrcPath!.isNotEmpty) {
      debugPrint('Reloading LRC file: ${_currentSong.lrcPath}');
      await widget.lyricsService.loadLrcFile(_currentSong.lrcPath!);
    }

    await _loadAllTranslations(_currentSong.id, _currentSong.title);
    await _selectLanguageBasedOnSettings();
    await _updateAllLyricsWithTranslations();
    if (mounted) setState(() {});
  }

  Future<void> _reloadSongData() async {
    if (_isReloading) {
      debugPrint('⚠ _reloadSongData already in progress, skipping');
      return;
    }
    _isReloading = true;
    try {
      final db = DatabaseService();
      final updatedSong = await db.getSong(_currentSong.id);

      if (updatedSong != null && mounted) {
        _currentSong = updatedSong;

        if (_currentSong.lrcPath != null && _currentSong.lrcPath!.isNotEmpty) {
          debugPrint('Reloading LRC file from DB: ${_currentSong.lrcPath}');
          await widget.lyricsService.loadLrcFile(_currentSong.lrcPath!);
        }

        await _loadAllTranslations(_currentSong.id, _currentSong.title);
        await _selectLanguageBasedOnSettings();
        await _updateAllLyricsWithTranslations();
        if (mounted) setState(() {});

        debugPrint('=== Reloaded from DB ===');
        debugPrint(
            'Lyrics after reload: ${widget.lyricsService.lyricLines.length}');
        debugPrint(
            'Translations after reload: ${widget.translationService.translations.length}');
      }
    } finally {
      _isReloading = false;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('=== PlayerScreen: deactivate ===');
    debugPrint('Current song: ${_currentSong.title}');
    debugPrint(
        'Translations in service before deactivate: ${widget.translationService.translations.length}');
  }

  String _getShortLanguageName(String languageName, String languageCode) {
    return LanguageHelper.getShortLanguageName(languageName, languageCode);
  }

  String _getLanguageEmoji(String language, String? type) {
    return LanguageHelper.getLanguageEmoji(language, type);
  }

  Future<void> _selectLanguageBasedOnSettings() async {
    await _playerTranslationHelper.selectLanguageBasedOnSettings(
      context,
      widget.translationService,
    );
  }

  int _getCurrentSongIndex() {
    if (widget.playlistSongs == null || widget.playlistSongs!.isEmpty) {
      return -1;
    }
    for (int i = 0; i < widget.playlistSongs!.length; i++) {
      if (widget.playlistSongs![i].id == _currentSong.id) {
        return i;
      }
    }
    return -1;
  }

  void _generateShuffledIndices() {
    _playerPlaylistHelper.generateShuffledIndices(
      widget.playlistSongs,
      _currentSong.id,
      widget.audioService,
    );
  }

  void _toggleShuffle() {
    setState(() {
      _isShuffleEnabled = !_isShuffleEnabled;
      widget.audioService.toggleShuffle();

      if (_isShuffleEnabled) {
        _generateShuffledIndices();
      }
    });
  }

  void _toggleLoop() {
    // Режим «избранное» убран из цикла: off → all → one → allPlaylists → off.
    // Избранные песни слушаются через отдельную закладку (открываешь плейлист
    // избранного — и играет по кругу как LoopMode.all).
    setState(() {
      widget.audioService.toggleLoop();
      _loopMode = widget.audioService.loopMode;
    });
  }

  /// Синхронизация локальных копий loop/shuffle с [AudioService]. Режим можно
  /// переключить с экрана блокировки (notification) — без этого слушателя
  /// кнопки и логика next/prev/study-completion работали бы с устаревшим
  /// значением (симптом «режимы глючат в фоне»). Регистрируется в initState,
  /// снимается в dispose.
  void _onAudioServiceChanged() {
    if (!mounted) return;
    final newLoop = widget.audioService.loopMode;
    final newShuffle = widget.audioService.isShuffleEnabled;
    // Шаффл выключили (кнопкой на экране или из уведомления) — глобальная
    // перемешанная очередь больше неактуальна (v5.8.7).
    if (!newShuffle) {
      _globalShuffleQueue = null;
      _globalShufflePos = -1;
    }
    if (newLoop != _loopMode || newShuffle != _isShuffleEnabled) {
      setState(() {
        _loopMode = newLoop;
        _isShuffleEnabled = newShuffle;
      });
    }
  }

  /// Вооружает watchdog дедлока завершения (см. [_completionWatchdog]).
  /// Вызывается из [onSongComplete], когда song завершается в study-режиме.
  void _armCompletionWatchdog() {
    _completionWatchdog?.cancel();
    _watchdogSongId = _currentSong.id;
    _completionWatchdog = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      final player = widget.audioService.player;
      // Песня сменилась → study сам справился, форсить не нужно.
      if (_currentSong.id != _watchdogSongId) {
        _watchdogStuckRearms = 0;
        _studyEvt('completion WATCHDOG: song already advanced, no-op');
        return;
      }
      // Загрузка другой песни идёт → _playSong доберётся до конца сам.
      if (_isSongLoading) {
        _studyEvt('completion WATCHDOG: song is loading, no-op');
        return;
      }
      final completed = player.processingState == ProcessingState.completed;
      // Идёт звонок/прерывание — плеер ЛЕГИТИМНО на паузе (v5.8.5: раньше
      // «stuck = !playing» стрелял в call-паузе и запускал следующую песню
      // ПРЯМО посреди разговора). Переносим проверку, пока прерывание активно;
      // после отбоя study сам двинется (resumeSession) либо watchdog сработает
      // по-настоящему. НО (v5.8.8): если нативный детектор подтверждает, что
      // линии свободна, а пауза «висит» уже несколько реармов — это begin без
      // end (beep уведомления/сообщения, эхо отбоя) → самолечение.
      if ((widget.audioService.backgroundHandler?.isPausedForCall ?? false) ||
          _studyPausedForCall) {
        if (_watchdogStuckRearms >= _callStuckRearmLimit &&
            _canSelfHealCompletion()) {
          _selfHealStuckCompletion(
              'call/interruption pause stuck ${_watchdogStuckRearms + 1} '
              're-arms, phone idle');
          return;
        }
        _watchdogStuckRearms++;
        _studyEvt('completion WATCHDOG: call/interruption in progress '
            '— re-arming (${_watchdogStuckRearms}/$_callStuckRearmLimit)');
        _armCompletionWatchdog();
        return;
      }
      // Study на ПАУЗЕ у пользователя (FAB / lock-screen, v5.8.6): «стоит» —
      // это намерение, а не deadlock. Форсить следующую песню значило бы
      // перебить паузу (поставил паузу в конце песни → сама заиграла
      // следующая). Переносим проверку: после resume study двинется сам либо
      // watchdog сработает по-настоящему. Исключение (v5.8.8): пауза при УЖЕ
      // ДОИГРАВШЕЙ песне бессмысленна как «вернуться сюда позже» — completed
      // при паузе означает гонку прерывания (pauseSession не остановила
      // плеер, ин-флайтовый play() kick-цикла его воскресил) → после
      // [_userPauseStuckRearmLimit] реармов самолечимся.
      if (_studyModeService.isActive && _studyModeService.isUserPaused) {
        if (completed &&
            _watchdogStuckRearms >= _userPauseStuckRearmLimit &&
            _canSelfHealCompletion()) {
          _selfHealStuckCompletion('study paused but song completed '
              '${_watchdogStuckRearms + 1} re-arms');
          return;
        }
        _watchdogStuckRearms++;
        _studyEvt('completion WATCHDOG: study user-paused — re-arming '
            '(${_watchdogStuckRearms}/$_userPauseStuckRearmLimit)');
        _armCompletionWatchdog();
        return;
      }
      final stuck = !player.playing;
      if (completed || stuck) {
        _studyEvt('completion WATCHDOG FIRED — study did not advance, '
            'forcing next (completed=$completed, stuck=$stuck)');
        debugPrint('⏰ PlayerScreen: completion watchdog — forcing next song '
            '(study did not handle completion after call/zombie)');
        _playNextSong();
      } else {
        _studyEvt('completion WATCHDOG: player still playing, no-op');
      }
    });
  }

  /// Можно ли самолечить залипший watchdog: нативный детектор звонка
  /// ([PhoneCallService]) работает И подтверждает, что линии свободна.
  /// Без работающего детектора отличить «залипший beep» от реального
  /// разговора невозможно — не форсим музыку посреди звонка.
  bool _canSelfHealCompletion() {
    if (!mounted || _isSongLoading) return false;
    final phone = PhoneCallService.instance;
    return phone.isListening && phone.current == CallState.idle;
  }

  /// Самолечение залипшего автоперехода (v5.8.8). Симптом: после звонка или
  /// beep'а уведомления песня доиграла до конца, а следующая сама не
  /// включилась (спасали только ручные пауза+play — play доходил до
  /// resumeSession). Причина: study-сессия залипла в паузе при играющем
  /// плеере (гонка kick vs pauseSession) либо call-пауза осталась без
  /// парного end → watchdog реармился вечно. Лечение: снять залипшие флаги и
  /// форснуть следующую песню — [_playSong] чисто остановит и перезапустит
  /// study на новой песне (TTS вернётся через _ensureTtsReady).
  void _selfHealStuckCompletion(String reason) {
    _studyEvt('completion WATCHDOG SELF-HEAL — $reason');
    debugPrint('🔧 PlayerScreen: completion watchdog SELF-HEAL ($reason)');
    // Залипший begin без end (beep уведомления): снимаем call-паузу —
    // _handleCallResume сам вызовет onPlaybackResumed (дренирует хвосты).
    widget.audioService.backgroundHandler?.clearStaleCallPause();
    _studyPausedForCall = false;
    _studyWasAudibleBeforeCall = false;
    _playNextSong();
  }

  /// Отменяет watchdog. Вызывается при начале [_playSong] (любая смена песни)
  /// и когда обычный путь завершения сам запускает next (study не активен).
  void _cancelCompletionWatchdog() {
    _watchdogStuckRearms = 0;
    _completionWatchdog?.cancel();
    _completionWatchdog = null;
  }

  /// Pre-flight TTS check before starting study mode. If the current
  /// translation language has no installed voice (common on Chinese ROMs
  /// without the right TTS engine), either asks the user (manual toggle) or
  /// silently switches to segments-only mode (auto-start / restart after song
  /// switch). Returns true if study mode should proceed.
  Future<bool> _ensureTtsReady({required bool fromUser}) async {
    final lang = widget.translationService.currentTranslation?.language;
    if (lang == null) return true; // no translation -> nothing to speak anyway
    final ok = await _studyModeService.checkLanguageAvailable(lang);
    if (ok) {
      _studyModeService.setSpeakDisabled(false);
      return true;
    }
    _studyEvt(
        'ensureTts: lang $lang NOT available (engine=${_studyModeService.activeEngine})');
    if (fromUser && mounted) {
      final cont = await _showTtsUnavailableDialog();
      if (!cont) return false;
    }
    // Auto-disable speech so the runner keeps advancing over segments instead
    // of hanging in silence for ~12s on every line.
    _studyModeService.setSpeakDisabled(true);
    return true;
  }

  /// Shown when the translation language has no installed TTS voice.
  /// Offers "continue without voice" (segments-only study) or cancel.
  Future<bool> _showTtsUnavailableDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.ttsLangMissingTitle),
            content: Text(l10n.ttsLangMissingBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(l10n.ttsContinueNoVoice),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _toggleStudyMode() async {
    // Верхняя кнопка — чистое ВКЛ/ВЫКЛ режима (v5.8.6): активная сессия
    // выключается в любом состоянии, в т.ч. с пользовательской паузы (раньше
    // пауза + нажатие кнопки молча перезапускали сессию — неинтуитивно).
    if (_studyModeService.isActive) {
      // Выключение режима НЕ должно трогать транспорт (v5.8.7): stop()
      // безусловно паузит плеер — в «Поверх» это глушило непрерывно игравшую
      // песню. Кнопка управляет только голосовым слоем. Запоминаем, звучало
      // ли что-то (озвучка / сегмент / играло недавно), и после остановки
      // сессии продолжаем обычное воспроизведение с текущей позиции.
      final wasAudible = !_studyModeService.isUserPaused &&
          (_studyModeService.isSpeaking ||
              widget.audioService.player.playing ||
              (widget.audioService.backgroundHandler?.wasPlayingRecently ??
                  false));
      await _studyModeService.stop(userRequested: true);
      if (wasAudible) {
        // ensurePlaybackAdvancing сам реактивирует аудиосессию после
        // TTS-хендоффа и лечит зомби just_audio; no-op, если всё здорово.
        await widget.audioService.ensurePlaybackAdvancing();
      }
      if (mounted) setState(() {});
      return;
    }
    if (widget.lyricsService.lyricLines.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.studyModeNoLyrics),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    if (!await _ensureTtsReady(fromUser: true)) return;
    final started = await _studyModeService.start();
    if (started && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_studyModeService.speakDisabled
              ? l10n.studyModeStartedNoVoice
              : l10n.studyModeStarted),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {});
    }
  }

  /// Auto-starts study mode on player init if it was persisted as enabled.
  /// Reads the flag directly from SharedPreferences because StudyModeService's
  /// async _init() may not have completed yet at this point.
  Future<void> _maybeAutoStartStudy() async {
    if (!mounted) return;
    bool persisted = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      persisted = prefs.getBool('studyModeEnabled') ?? false;
    } catch (_) {}
    if (!persisted) return;
    if (widget.lyricsService.lyricLines.isEmpty) return;
    if (_studyModeService.isActive) return;
    debugPrint('▶ Study mode persisted ON — auto-starting on player init');
    await _ensureTtsReady(fromUser: false);
    await _studyModeService.start();
    if (mounted) setState(() {});
  }

  /// Auto-starts car detection if the user previously enabled it. Mirrors
  /// [_maybeAutoStartStudy]. Runs once on player init (via post-frame).
  Future<void> _maybeAutoStartCarDetection() async {
    if (!mounted) return;
    bool persisted = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      persisted = prefs.getBool('carDetectionEnabled') ?? false;
    } catch (_) {}
    if (!persisted) return;
    if (_carDetectionService.isActive) return;
    debugPrint('▶ Car detection persisted ON — auto-starting on player init');
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    await _carAlertService.ensureInitialized();
    final ok = await _carDetectionService.start(
      sensitivity: sp.carDetectionSensitivity,
    );
    if (mounted) setState(() {});
    debugPrint('▶ Car detection auto-start result: $ok');
  }

  /// Restarts study mode after a song switch or seek if it was persisted as
  /// enabled. [delay] lets a freshly started song settle (avoids a race where
  /// the background handler's play events conflict with study mode's immediate
  /// seek+pause, which previously prevented the restart from "taking").
  Future<void> _restartStudyIfNeeded({
    Duration delay = Duration.zero,
  }) async {
    _studyEvt('restart: check (persist=${_studyModeService.enabledPersist}, '
        'isActive=${_studyModeService.isActive}, '
        'lyricsEmpty=${widget.lyricsService.lyricLines.isEmpty}, mounted=$mounted)');
    if (!mounted) {
      _studyEvt('restart: SKIP !mounted');
      return;
    }
    if (!_studyModeService.enabledPersist) {
      _studyEvt('restart: SKIP !persist');
      return;
    }
    if (widget.lyricsService.lyricLines.isEmpty) {
      _studyEvt('restart: SKIP lyrics empty');
      return;
    }
    if (_studyModeService.isActive) {
      _studyEvt('restart: SKIP already active');
      return;
    }
    if (delay != Duration.zero) {
      await Future.delayed(delay);
      if (!mounted) {
        _studyEvt('restart: SKIP !mounted after delay');
        return;
      }
    }
    debugPrint('▶ Study mode persist — restarting after song switch/seek');
    await _ensureTtsReady(fromUser: false);
    final started = await _studyModeService.start();
    _studyEvt('restart: start() -> $started; '
        'isActive=${_studyModeService.isActive} '
        'speakDisabled=${_studyModeService.speakDisabled}');
    if (mounted) setState(() {});
  }

  /// Triggered by StudyModeService when a song ends naturally during study
  /// mode. `onSongComplete` is guarded while study mode is active, so the
  /// normal loop/next wouldn't fire — this callback bridges that gap: it
  /// advances to the next song (respecting loop mode), and `_playSong` stops &
  /// restarts study mode (persist) for the new song.
  Future<void> _onStudySongCompleted() async {
    if (!mounted) return;
    _studyEvt('onStudyCompleted: loop=${_loopMode.name}, '
        'song=${_currentSong.id}, isActive=${_studyModeService.isActive}, '
        'load=$_isSongLoading');
    debugPrint('▶ Study mode completed song — triggering loop/next');
    if (_loopMode == LoopMode.one) {
      // Repeat current song from the start (reload so study mode restarts
      // cleanly from line 0).
      await _playSong(_currentSong);
    } else {
      // Advance (LoopMode.all/allPlaylists/shuffle wrap; off does nothing at
      // the last song). _playSong restarts study mode via persist.
      final prevId = _currentSong.id;
      await _playNextSong();
      _studyEvt('onStudyCompleted: after playNext '
          'prev=$prevId new=${_currentSong.id} '
          'isActive=${_studyModeService.isActive}');
      // Only stop study mode if NOTHING actually advanced (LoopMode.off, last
      // song). Comparing the song id is the reliable signal: by this point
      // `_playSong` has already restarted study mode for the NEW song (so
      // `isActive` is true regardless) — checking `isActive` here would
      // incorrectly kill the just-restarted session (see v5.0.5 fix).
      if (mounted && _currentSong.id == prevId && _studyModeService.isActive) {
        _studyEvt('onStudyCompleted: nothing advanced -> stop');
        await _studyModeService.stop();
      }
    }
  }

  Future<void> _openStudyModeSettings() async {
    if (_studyModeService.isActive && !_studyModeService.isUserPaused) {
      await _studyModeService.pauseSession();
    }
    if (!mounted) return;
    _showStudyModeSettingsDialog();
  }

  void _showStudyModeSettingsDialog() {
    final l10n = AppLocalizations.of(context)!;
    StudyModeOrder currentOrder = _studyModeService.order;
    double currentRate = _studyModeService.speechRate;
    double currentVolume = _studyModeService.speechVolume;
    OverlayTiming currentTiming = _studyModeService.overlayTiming;
    double currentDuck = _studyModeService.duckVolume;
    double currentTtsOffset = _studyModeService.ttsOffset;
    double currentSpeed = widget.audioService.playbackSpeed;
    bool perSong = _studyModeService.perSongOverride;
    final songTitle = _currentSong.title;

    Widget timingChip(String label, OverlayTiming value, OverlayTiming current,
        ValueChanged<OverlayTiming> onPick) {
      return ChoiceChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) => onPick(value),
      );
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(l10n.studyModeSettings),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(l10n.studyPerSongOverride),
                      subtitle: Text(l10n.studyPerSongOverrideSubtitle),
                      value: perSong,
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      onChanged: (v) async {
                        await _studyModeService.setPerSongOverride(v);
                        await widget.audioService.setPerSongOverride(v);
                        setState(() {
                          perSong = v;
                          currentOrder = _studyModeService.order;
                          currentRate = _studyModeService.speechRate;
                          currentVolume = _studyModeService.speechVolume;
                          currentTiming = _studyModeService.overlayTiming;
                          currentDuck = _studyModeService.duckVolume;
                          currentTtsOffset = _studyModeService.ttsOffset;
                          currentSpeed = widget.audioService.playbackSpeed;
                        });
                      },
                    ),
                    const Divider(),
                    Text(l10n.studyModeOrder,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile<StudyModeOrder>(
                      value: StudyModeOrder.translationFirst,
                      groupValue: currentOrder,
                      title: Text(l10n.studyModeOrderTranslationFirst),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => currentOrder = v);
                        _studyModeService.setOrder(v);
                      },
                    ),
                    RadioListTile<StudyModeOrder>(
                      value: StudyModeOrder.originalFirst,
                      groupValue: currentOrder,
                      title: Text(l10n.studyModeOrderOriginalFirst),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => currentOrder = v);
                        _studyModeService.setOrder(v);
                      },
                    ),
                    RadioListTile<StudyModeOrder>(
                      value: StudyModeOrder.overlay,
                      groupValue: currentOrder,
                      title: Text(l10n.studyModeOrderOverlay),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => currentOrder = v);
                        _studyModeService.setOrder(v);
                      },
                    ),
                    if (currentOrder == StudyModeOrder.overlay) ...[
                      const SizedBox(height: 4),
                      Text(l10n.studyModeOverlayTiming,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          timingChip(l10n.studyModeOverlayAtStart,
                              OverlayTiming.start, currentTiming, (v) {
                            setState(() => currentTiming = v);
                            _studyModeService.setOverlayTiming(v);
                          }),
                          timingChip(l10n.studyModeOverlayAtEnd,
                              OverlayTiming.end, currentTiming, (v) {
                            setState(() => currentTiming = v);
                            _studyModeService.setOverlayTiming(v);
                          }),
                          timingChip(l10n.studyModeOverlayAtBoth,
                              OverlayTiming.both, currentTiming, (v) {
                            setState(() => currentTiming = v);
                            _studyModeService.setOverlayTiming(v);
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${l10n.studyModeDuckVolume}: ${(currentDuck * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: currentDuck,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(currentDuck * 100).round()}%',
                        onChanged: (v) {
                          setState(() => currentDuck = v);
                          _studyModeService.setDuckVolume(v);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${l10n.studyModeTtsOffset}: ${currentTtsOffset >= 0 ? '+' : ''}${currentTtsOffset.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: currentTtsOffset.clamp(-5.0, 5.0),
                        min: -5.0,
                        max: 5.0,
                        divisions: 100,
                        label: '${currentTtsOffset.toStringAsFixed(1)}',
                        onChanged: (v) {
                          setState(() => currentTtsOffset = v);
                          _studyModeService.setTtsOffset(v);
                        },
                      ),
                      Text(
                        l10n.studyModeTtsOffsetHint,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Divider(),
                    Text(
                        '${l10n.studyModeSpeechRate}: ${currentRate.toStringAsFixed(1)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: currentRate.clamp(0.3, 2.5),
                      min: 0.3,
                      max: 2.5,
                      divisions: 22,
                      label: '${currentRate.toStringAsFixed(1)}x',
                      onChanged: (v) {
                        setState(() => currentRate = v);
                        _studyModeService.setSpeechRate(v);
                      },
                    ),
                    Text(
                        '${l10n.studyModeSpeechVolume}: ${currentVolume.toStringAsFixed(1)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: currentVolume.clamp(0.0, 3.0),
                      min: 0.0,
                      max: 3.0,
                      divisions: 30,
                      label: '${currentVolume.toStringAsFixed(1)}x',
                      onChanged: (v) {
                        setState(() => currentVolume = v);
                        _studyModeService.setSpeechVolume(v);
                      },
                    ),
                    const Divider(),
                    Text(
                        '${l10n.playbackSpeed}: ${currentSpeed.toStringAsFixed(2)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: currentSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 30,
                      label: '${currentSpeed.toStringAsFixed(2)}x',
                      onChanged: (v) {
                        setState(() => currentSpeed = v);
                        widget.audioService.setPlaybackRate(v);
                      },
                    ),
                    if (perSong)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '🎵 "$songTitle"',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(ctx).colorScheme.primary),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    // Слайдер скорости в диалоге мог изменить значение через
                    // audioService — синхронизируем локальную переменную, чтобы
                    // индикатор скорости на главном экране был актуален.
                    if (mounted) {
                      setState(() =>
                          _playbackSpeed = widget.audioService.playbackSpeed);
                    }
                  },
                  child: Text(l10n.close),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _playPreviousSong() async {
    await _playerPlaylistHelper.playPreviousSong(
      _activePlaybackList ?? widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
      widget.audioService,
      _playSong,
    );
  }

  Future<void> _playNextSong() async {
    if (_loopMode == LoopMode.allPlaylists) {
      // Shuffle ВКЛ (v5.8.7): «случайный по плейлистам» тянет почти каждую
      // песню из перемешанного массива ВСЕЙ библиотеки (все папки, без
      // повторов внутри цикла), а не прогоняет текущую папку подряд до конца.
      if (_isShuffleEnabled) {
        await _playNextFromShuffledLibrary();
        return;
      }
      await _playNextFromAllPlaylists();
      return;
    }

    await _playerPlaylistHelper.playNextSong(
      _activePlaybackList ?? widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
      widget.audioService,
      _playSong,
      null,
    );
  }

  /// Логика режима `LoopMode.allPlaylists` БЕЗ шаффла (v5.8.7: при включённом
  /// шаффле см. [_playNextFromShuffledLibrary] — глобальная очередь по всей
  /// библиотеке): играет активный плейлист целиком, затем переходит к ДРУГОМУ
  /// плейлисту. Источник очереди — ЖИВОЙ [_activePlaybackList] (он сам
  /// обновляется при смене плейлиста), а НЕ устаревший [widget.playlistSongs].
  ///
  /// Поведение при завершении текущего плейлиста:
  ///   - следующий плейлист по порядку (createdAt), wrap-around, пустые
  ///     пропускаются.
  Future<void> _playNextFromAllPlaylists() async {
    final list = _activePlaybackList ?? widget.playlistSongs;
    if (list == null || list.isEmpty) {
      await _switchToNextPlaylist();
      return;
    }

    final currentIndex = list.indexWhere((s) => s.id == _currentSong.id);

    if (currentIndex >= 0 && currentIndex < list.length - 1) {
      // В текущем плейлисте ещё есть песни → играем следующую.
      await _playSong(list[currentIndex + 1]);
    } else {
      // Текущий плейлист доиграл до конца → переходим к другому.
      await _switchToNextPlaylist();
    }
  }

  /// «Случайный по плейлистам» (v5.8.7): глобальная перемешанная очередь из
  /// ВСЕХ песен библиотеки (объединение всех плейлистов). До этого шаффл в
  /// allPlaylists не участвовал в выборе песни вообще: папка прогонялась
  /// подряд до конца, случайной была только СЛЕДУЮЩАЯ папка (и та входила с
  /// первой песни), а идентификация текущей папки по первой песне сбивалась
  /// системным плейлистом «все песни» → «запрыгивало обратно в первую папку».
  ///
  /// Очередь строится лениво и пересобирается после исчерпания цикла (новый
  /// случайный порядок). Активным списком становится сама очередь — тогда
  /// [_playSong] находит корректные индексы, prev/уведомление/фоновая
  /// очередь остаются консистентными.
  Future<void> _playNextFromShuffledLibrary() async {
    try {
      final currentId = _currentSong.id;
      if (_globalShuffleQueue == null ||
          _globalShufflePos >= _globalShuffleQueue!.length - 1) {
        final db = DatabaseService();
        final playlists = await db.getAllPlaylists();
        // Дедуп по song.id: песня живёт и в своей папке, и в системных
        // «все песни»/«избранное» — без дедупа она играла бы по 2+ раза за
        // цикл.
        final byId = <String, Song>{};
        for (final p in playlists) {
          for (final s in await db.getSongsInPlaylist(p.id!)) {
            byId.putIfAbsent(s.id, () => s);
          }
        }
        if (byId.isEmpty) return;
        final library = byId.values.toList();
        // Только что игравшую песню не повторяем в новом цикле сразу же.
        library.removeWhere((s) => s.id == currentId);
        if (library.isEmpty) return;
        library.shuffle(_random);
        _globalShuffleQueue = library;
        _globalShufflePos = -1;
        if (!mounted) return;
        setState(() => _activePlaybackList = library);
        widget.audioService.setCurrentPlaylist(library);
        debugPrint('🔀 allPlaylists+shuffle: built global queue '
            '(${library.length} songs)');
      }
      _globalShufflePos++;
      await _playSong(_globalShuffleQueue![_globalShufflePos]);
    } catch (e, st) {
      debugPrint('✗ Error playing next from shuffled library: $e\n$st');
    }
  }

  /// Выбирает следующий плейлист и переключает на него [_activePlaybackList].
  /// См. [_playNextFromAllPlaylists] про правила выбора (shuffle/по порядку).
  Future<void> _switchToNextPlaylist() async {
    try {
      final db = DatabaseService();
      final playlists = await db.getAllPlaylists();
      if (playlists.isEmpty) return;

      // Грузим песни всех плейлистов один раз, оставляем только непустые.
      final songsByPlaylist = <Playlist, List<Song>>{};
      for (final p in playlists) {
        final songs = await db.getSongsInPlaylist(p.id!);
        if (songs.isNotEmpty) songsByPlaylist[p] = songs;
      }
      if (songsByPlaylist.isEmpty) return;

      final nonEmpty =
          songsByPlaylist.keys.toList(); // порядок createdAt сохранён

      // Идентифицируем текущий плейлист по первой песне активного списка.
      String? currentId;
      final activeList = _activePlaybackList;
      if (activeList != null && activeList.isNotEmpty) {
        final firstId = activeList.first.id;
        for (final entry in songsByPlaylist.entries) {
          if (entry.value.any((s) => s.id == firstId)) {
            currentId = entry.key.id;
            break;
          }
        }
      }

      final Playlist chosen;
      if (_isShuffleEnabled) {
        // Случайный плейлист, отличный от текущего (если есть из чего выбирать).
        final others = currentId == null
            ? nonEmpty
            : nonEmpty.where((p) => p.id != currentId).toList();
        final pool = others.isNotEmpty ? others : nonEmpty;
        chosen = pool[_random.nextInt(pool.length)];
      } else {
        // По порядку: следующий за текущим, wrap-around.
        if (currentId == null) {
          chosen = nonEmpty.first;
        } else {
          final idx = nonEmpty.indexWhere((p) => p.id == currentId);
          chosen = idx == -1
              ? nonEmpty.first
              : nonEmpty[(idx + 1) % nonEmpty.length];
        }
      }

      final nextSongs = songsByPlaylist[chosen]!;

      if (!mounted) return;
      setState(() => _activePlaybackList = nextSongs);
      widget.audioService.setCurrentPlaylist(nextSongs);
      debugPrint('🔀 allPlaylists: switched to "${chosen.name}" '
          '(${nextSongs.length} songs, shuffle=$_isShuffleEnabled)');
      await _playSong(nextSongs.first);
    } catch (e, st) {
      debugPrint('✗ Error switching to next playlist: $e\n$st');
    }
  }

  /// Перезагружает [_isCurrentSongFavorite] для [_currentSong]. Вызывается при
  /// смене песни ([_playSong]) и при открытии экрана.
  Future<void> _refreshCurrentSongFavoriteStatus() async {
    try {
      final db = DatabaseService();
      final isFav = await db.isSongInPlaylist('favorites', _currentSong.id);
      if (mounted) {
        setState(() => _isCurrentSongFavorite = isFav);
      }
    } catch (e) {
      debugPrint('✗ Error checking favorite status: $e');
    }
  }

  /// Добавляет/убирает текущую песню из системного плейлиста `favorites`.
  /// Сердечко НЕ меняет режим воспроизведения: режим «избранное» убран из цикла
  /// переключения, поэтому здесь только обновляем флаг и сам список избранного.
  /// Слушать избранные песни можно, открыв плейлист избранного в библиотеке.
  Future<void> _toggleCurrentSongFavorite() async {
    try {
      final db = DatabaseService();
      if (_isCurrentSongFavorite) {
        await db.removeSongFromPlaylist('favorites', _currentSong.id);
        debugPrint('💔 Removed from favorites: ${_currentSong.title}');
      } else {
        await db.addSongToPlaylist('favorites', _currentSong.id);
        debugPrint('❤ Added to favorites: ${_currentSong.title}');
      }
      if (mounted) {
        setState(() => _isCurrentSongFavorite = !_isCurrentSongFavorite);
      }
    } catch (e) {
      debugPrint('✗ Error toggling favorite: $e');
    }
  }

  bool _canPlayPrevious() {
    return _playerPlaylistHelper.canPlayPrevious(
      _activePlaybackList ?? widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
    );
  }

  bool _canPlayNext() {
    if (_loopMode == LoopMode.allPlaylists || _loopMode == LoopMode.favorites) {
      return true;
    }
    return _playerPlaylistHelper.canPlayNext(
      _activePlaybackList ?? widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
    );
  }

  Future<void> _loadAllTranslations(String songId, String songName) async {
    await _playerTranslationHelper.loadAllTranslations(
      context,
      songId,
      songName,
      widget.translationService,
    );
  }

  Future<void> _scanAndAddTranslations(String songId, String songName) async {
    await _playerTranslationHelper.scanAndAddTranslations(
      context,
      songId,
      songName,
      widget.translationService,
    );
  }

  Future<void> _playSong(Song song) async {
    // Любая смена песни (study-completion, ручной next/prev, watchdog-форс) —
    // отменяем watchdog дедлока завершения (см. _armCompletionWatchdog).
    _cancelCompletionWatchdog();
    _studyEvt('playSong: ENTER "${song.title}" '
        '(load=$_isSongLoading, isActive=${_studyModeService.isActive}, '
        'persist=${_studyModeService.enabledPersist})');
    if (_isSongLoading) {
      debugPrint(
          '⚠ _playSong: already loading another song, skipping: ${song.title}');
      _studyEvt('playSong: SKIP (already loading)');
      return;
    }
    _isSongLoading = true;
    _positionTimer?.cancel();
    // Смена песни → новая позиция/аудио. Сбрасываем корректор, чтобы он
    // пересинхронизировался с новой _player.position, а не продолжал
    // wall-clock траекторию старой песни.
    _positionCorrector.reset();
    if (_studyModeService.isActive) {
      await _studyModeService.stop();
      _studyEvt('playSong: after stop '
          'isActive=${_studyModeService.isActive}');
    }

    try {
      debugPrint('=== DEBUG: _playSong called for: ${song.title} ===');

      widget.translationService.clear();

      if (song.lrcPath != null && song.lrcPath!.isNotEmpty) {
        await widget.lyricsService.loadLrcFile(song.lrcPath!);
      }

      setState(() {
        _currentSong = song;
        _lastScrolledIndex = -1;
        _lastProcessedIndex = -1;
        _lastProcessedLanguageIndex = -1;
      });
      // Сменили песню → обновляем флаг избранного для кнопки-сердечка.
      _refreshCurrentSongFavoriteStatus();
      // Reset the lyrics scroll to the top for the new song — otherwise the
      // previous song's scroll offset leaves the new lyrics outside the
      // viewport ("текст за зоной видимости" after switching songs).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      });

      // Применяем per-song настройки для новой песни ДО загрузки аудио, чтобы
      // скорость воспроизведения и study-параметры соответствовали именно ей.
      await _studyModeService.applyPerSongSettings(song.id);
      await widget.audioService.applyPerSongSettings(song.id);
      if (mounted) {
        setState(() => _playbackSpeed = widget.audioService.playbackSpeed);
      }

      await _loadAllTranslations(song.id, song.title);
      await _selectLanguageBasedOnSettings();
      await _updateAllLyricsWithTranslations();
      // Refresh the AppBar (language indicator) and translation display right
      // after translations loaded, so they appear immediately without waiting
      // for the next position-timer tick.
      if (mounted) setState(() {});

      widget.audioService.setCurrentSong(song);

      final handler = widget.audioService.backgroundHandler;
      if (handler != null) {
        debugPrint('=== Playing via BackgroundHandler: ${song.title} ===');

        // Используем ЖИВОЙ активный список (он обновляется при переходе между
        // плейлистами в режиме allPlaylists). Падаем на widget.playlistSongs,
        // только если активный список вдруг не задан.
        final activeList = _activePlaybackList ?? widget.playlistSongs;
        if (activeList != null && activeList.isNotEmpty) {
          final currentIndex = activeList.indexWhere((s) => s.id == song.id);
          final index = currentIndex >= 0 ? currentIndex : 0;

          await handler.setPlaylist(activeList, index);
          widget.audioService.setCurrentPlaylist(activeList);

          await handler.playSong(song, index);
        } else {
          await handler.playSong(song, 0);
        }

        debugPrint('✓ Background: playing ${song.title}');
      } else {
        debugPrint('=== Playing via local player: ${song.title} ===');
        await widget.audioService.loadAudio(song.audioPath);
        await widget.audioService.play();
      }
      _studyEvt('playSong: post-start '
          'state=${widget.audioService.player.processingState.name} '
          'pos=${widget.audioService.position.inMilliseconds}ms');

      // After a song switch that follows TTS speech (study mode), the Android
      // audio session is deactivated and a plain play() can leave just_audio
      // in a zombie state — position never advances, so lyrics don't scroll
      // and study mode never detects line boundaries. Verify (and force) real
      // playback advancement before restarting study. Scoped to study persist
      // (the only path where TTS deactivates the session); no-op when healthy.
      if (_studyModeService.enabledPersist) {
        await widget.audioService.ensurePlaybackAdvancing();
        _studyEvt('playSong: post-kick '
            'state=${widget.audioService.player.processingState.name} '
            'pos=${widget.audioService.position.inMilliseconds}ms');
      }

      // If study mode is persisted as enabled, restart it for the new song.
      // A short delay lets the freshly started playback settle so the restart
      // reliably "takes" (ensurePlaybackAdvancing already verified motion, so
      // only a small breath is needed).
      await _restartStudyIfNeeded(delay: const Duration(milliseconds: 50));
      _studyEvt('playSong: post-restart '
          'isActive=${_studyModeService.isActive} '
          'phase=${_studyModeService.phase.name}');
    } finally {
      _isSongLoading = false;
      _startPositionUpdates();
      _studyEvt('playSong: FINALLY '
          'isActive=${_studyModeService.isActive} load=$_isSongLoading');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint(
        '=== PlayerScreen: initState (shouldResume: ${widget.shouldResume}) ===');
    debugPrint('Song: ${widget.song.title}');
    debugPrint('LRC path: ${widget.song.lrcPath}');
    debugPrint(
        'Translations in service: ${widget.translationService.translations.length}');

    _currentSong = widget.song;
    _isShuffleEnabled = widget.audioService.isShuffleEnabled;
    _loopMode = widget.audioService.loopMode;
    // favorites — transient-режим, не должен восстанавливаться при открытии
    // экрана (требует динамической загрузки списка из БД, что делается только
    // через явный тап на кнопку loop). На всякий случай сбрасываем в off.
    if (_loopMode == LoopMode.favorites) {
      _loopMode = LoopMode.off;
      widget.audioService.setLoopMode(LoopMode.off);
    }
    _playbackSpeed = widget.audioService.playbackSpeed;
    // Активный список воспроизведения = исходный плейлист экрана.
    _activePlaybackList = widget.playlistSongs;
    _studyModeService = StudyModeService(
        widget.audioService, widget.lyricsService, widget.translationService);
    // When study mode finishes a song naturally, trigger loop/next instead of
    // pausing (onSongComplete is guarded while study mode is active, so without
    // this the loop/repeat wouldn't fire and playback would just stop).
    _studyModeService.onStudyCompleted = _onStudySongCompleted;

    // === Car detection: спектральный анализатор микрофона + alert-сервис ===
    _carAlertService = CarAlertService(
      Provider.of<SettingsProvider>(context, listen: false),
    );
    _carDetectionService = CarDetectionService();
    // A5: даём детектору знать, когда study mode озвучивает перевод — тогда
    // alert увеличивает throttle до 5 сек и не перебивает речь каждые 2 сек.
    _carDetectionService.isStudySpeaking = () => _studyModeService.isSpeaking;
    _carDetectionService.addListener(_onCarDetection);

    _loadSettings();
    _startPositionUpdates();

    _initSongData();
    // Загружаем флаг избранного для стартовой песни (кнопка-сердечко).
    _refreshCurrentSongFavoriteStatus();

    widget.audioService.onSongComplete = () {
      if (!mounted) return;
      if (_studyModeService.isActive) {
        _studyEvt('onSongComplete: GUARDED (study active) — arming watchdog');
        debugPrint(
            '=== Study mode active, completion handled by StudyModeService ===');
        // Study активен → обычный путь onSongComplete заблокирован. Но
        // продвижение зависит от того, что СВОЙ детектор study поймает
        // completed и дёрнет onStudyCompleted. После звонка аудиосессия
        // сброшена и этот детектор может не сработать чисто → песня доиграла,
        // а следующая не началась (симптом «после звонка встаёт»). Вооружаем
        // watchdog: если за ~4с study не продвинулся — принудительно next.
        _armCompletionWatchdog();
        return;
      }
      _cancelCompletionWatchdog();
      _studyEvt('onSongComplete: NOT guarded -> playNext');
      _playNextSong();
    };

    // Синхронизация локальных копий loop/shuffle с сервисом: режим можно
    // переключить с экрана блокировки (notification), и без этого слушателя
    // кнопки/логика PlayerScreen работали бы с устаревшим значением (симптом
    // «режимы глючат в фоне»). Снимается в dispose.
    widget.audioService.addListener(_onAudioServiceChanged);

    _initBackgroundAudio();

    // Auto-start car detection if persisted (once, after first frame).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoStartCarDetection();
    });
  }

  Future<void> _initSongData() async {
    // Применяем per-song настройки ДО любой загрузки аудио — чтобы скорость
    // воспроизведения и study-параметры соответствовали именно этой песне.
    await _studyModeService.applyPerSongSettings(widget.song.id);
    await widget.audioService.applyPerSongSettings(widget.song.id);
    _playbackSpeed = widget.audioService.playbackSpeed;

    if (widget.shouldResume) {
      debugPrint('=== Resuming player — checking player state ===');

      if (_isShuffleEnabled &&
          widget.playlistSongs != null &&
          widget.playlistSongs!.isNotEmpty) {
        debugPrint('✓ Regenerating shuffled indices for resumed shuffle mode');
        _generateShuffledIndices();
      }

      if (widget.audioService.player.processingState ==
          ProcessingState.completed) {
        debugPrint('⚠ Player in completed state on resume, seeking to start');
        await widget.audioService.seek(Duration.zero);
      }

      if (widget.translationService.translations.isNotEmpty) {
        await _updateAllLyricsWithTranslations();
      }
      if (mounted) {
        setState(() {});
        await _selectLanguageBasedOnSettings();
      }
      await _maybeAutoStartStudy();
      return;
    }

    if (widget.song.lrcPath != null && widget.song.lrcPath!.isNotEmpty) {
      debugPrint(
          'Loading LRC file from song in initState: ${widget.song.lrcPath}');
      await widget.lyricsService.loadLrcFile(widget.song.lrcPath!);
      debugPrint(
          'LRC loaded successfully, lyric lines count: ${widget.lyricsService.lyricLines.length}');
    }

    if (widget.translationService.translations.isEmpty) {
      debugPrint(
          'Translations are empty in initState, loading from database...');
      await _loadAllTranslations(widget.song.id, widget.song.title);
    }

    await _updateAllLyricsWithTranslations();

    if (_isShuffleEnabled &&
        widget.playlistSongs != null &&
        widget.playlistSongs!.isNotEmpty) {
      debugPrint('✓ Shuffle enabled on init, generating shuffled indices');
      _generateShuffledIndices();
    }

    _autoPlay();

    if (mounted) {
      setState(() {});
      await _selectLanguageBasedOnSettings();
    }
    await _maybeAutoStartStudy();
  }

  Future<void> _initBackgroundAudio() async {
    debugPrint('=== PlayerScreen: Checking background audio ===');
    widget.audioService.setCurrentSong(widget.song);
    if (widget.audioService.backgroundHandler != null) {
      debugPrint('✓ Background handler is active');

      widget.audioService.backgroundHandler!.onSkipToNextRequested = () {
        debugPrint('✓ PlayerScreen: skipToNext from notification');
        if (mounted) _playNextSong();
      };
      widget.audioService.backgroundHandler!.onSkipToPreviousRequested = () {
        debugPrint('✓ PlayerScreen: skipToPrevious from notification');
        if (mounted) _playPreviousSong();
      };

      // Звонок/прерывание: паузим study-сессию (стоп TTS + drain kick-цикла),
      // чтобы озвучка перевода не звучала во время разговора. Обычный pause()
      // в BackgroundAudioHandler стопает только песню, а TTS играет на отдельном
      // AudioPlayer. Возвращаем true → handler не делает авто-resume песни
      // после звонка, этим займётся onPlaybackResumed (resumeSession).
      widget.audioService.backgroundHandler!.onPlaybackInterrupted = () {
        if (!mounted) return false;
        if (_studyModeService.isActive && !_studyModeService.isUserPaused) {
          debugPrint('📞 PlayerScreen: pausing study for call/interruption');
          _studyPausedForCall = true;
          // Захватываем, шёл ли РЕАЛЬНО звук / была ли активная сессия в момент
          // начала прерывания. Без этого флага после отбоя звонка study
          // возобновился бы даже если слушатель давно поставил паузу через экран
          // блокировки (плеер остановлен, но study об этом не знает →
          // isActive && !isUserPaused). Сигналы:
          //  - isSpeaking: говорит ли сейчас TTS;
          //  - player.playing: играет ли сегмент песни прямо сейчас;
          //  - wasPlayingRecently: играло ли за последние ~2 мин. Покрывает
          //    kick-фазу study (когда _kickPlayback ретраит play(), но плеер ещё
          //    не стартовал → player.playing=false, isSpeaking=false). Без этого
          //    сигнала wasAudible ложно = false в kick-фазе → после звонка study
          //    не возобновлялся (регрессия v5.7.3).
          // Если ВСЁ false (часы простоя) → тишина → resume не нужен.
          _studyWasAudibleBeforeCall = _studyModeService.isSpeaking ||
              widget.audioService.player.playing ||
              (widget.audioService.backgroundHandler?.wasPlayingRecently ??
                  false);
          // fire-and-forget: _isUserPaused=true выставится синхронно (runner
          // остановится), TTS и kick дренируются в фоне; песню паузит сам
          // handler сразу после колбэка. forCall=true — пропускает внутренний
          // _audio.pause() (плеер уже остановлен _systemPause handler'а, и
          // этот вызов иначе ложно выставил бы _userPausedDuringCall).
          _studyModeService.pauseSession(forCall: true);
          return true;
        }
        return false;
      };
      widget.audioService.backgroundHandler!.onPlaybackResumed =
          (bool userPaused) {
        if (!mounted) return;
        if (_studyPausedForCall) {
          final wasAudible = _studyWasAudibleBeforeCall;
          _studyPausedForCall = false;
          _studyWasAudibleBeforeCall = false;
          // Пользователь вручную нажал паузу во время прерывания (lock-screen /
          // FAB) → НЕ возобновляем study, уважаем его последнее намерение.
          if (userPaused) {
            debugPrint('📞 PlayerScreen: study resume skipped '
                '(user paused during call)');
            return;
          }
          // В момент начала звонка реально ничего не звучало (слушатель давно
          // на паузе через экран блокировки) → НЕ возобновляем, иначе музыка
          // внезапно заиграла бы после отбоя.
          if (!wasAudible) {
            debugPrint('📞 PlayerScreen: study resume skipped '
                '(was not audible before call)');
            return;
          }
          debugPrint('📞 PlayerScreen: resuming study after call/interruption');
          _studyModeService.resumeSession();
        }
      };

      // Отключение наушников: в study mode ставим сессию на паузу тем же
      // путём, что кнопка паузы на FAB (pauseSession с forCall=false — стоп
      // TTS + drain kick-цикла + честная пауза плеера с обновлением
      // уведомления). Возвращаем true → handler не делает свой pause()
      // плеера (kick-цикл его тут же перебил бы).
      widget.audioService.backgroundHandler!.onBecomingNoisy = () {
        if (!mounted) return false;
        if (_studyModeService.isActive && !_studyModeService.isUserPaused) {
          debugPrint('🎧 PlayerScreen: pausing study (headphones unplugged)');
          _studyModeService.pauseSession();
          return true;
        }
        return false;
      };

      // Пауза «мимо FAB» (v5.8.6): lock-screen, уведомление, мини-плеер,
      // media-button — handler.pause() отдаёт её сюда, и study-сессия
      // ставится на паузу честным путём (стоп TTS + drain kick + пауза
      // плеера). Без хендоффа стоял только плеер, а сессия продолжала жить:
      // segment-watchdog форсил следующую строку и kick снова жал play
      // («нажимаю паузу — само играет дальше»). true → handler не делает
      // собственный _systemPause (pauseSession сам паузит после drain).
      widget.audioService.backgroundHandler!.onUserPause = () {
        if (!mounted) return false;
        if (_studyModeService.isActive &&
            !_studyModeService.isUserPaused &&
            !(widget.audioService.backgroundHandler?.isPausedForCall ??
                false)) {
          debugPrint('⏸ PlayerScreen: external pause → pauseSession (study)');
          _studyModeService.pauseSession();
          return true;
        }
        return false;
      };
      // Play «мимо FAB» (lock-screen / уведомление / мини-плеер) на
      // запаузненной study-сессии — возобновляем сессию целиком (runner +
      // озвучка + kick плеера). true → handler не дублирует запуск.
      widget.audioService.backgroundHandler!.onUserPlay = () {
        if (!mounted) return false;
        if (_studyModeService.isActive && _studyModeService.isUserPaused) {
          debugPrint('▶ PlayerScreen: external play → resumeSession (study)');
          _studyModeService.resumeSession();
          return true;
        }
        return false;
      };

      // Прямой детектор звонка (TelephonyManager) — надёжнее audio-focus на
      // ROM с агрессивным системным дакингом (ColorOS/Realme, MIUI). Запрос
      // READ_PHONE_STATE выполняется асинхронно; при отказе грациозно
      // откатываемся на interruption-схему (она остаётся подключённой выше).
      // Колбэки звонка идут через те же pauseForCall/resumeAfterCall handler'а
      // с дедупликацией — двойное срабатывание (phone-state + audio-focus)
      // безопасно.
      unawaited(_initPhoneCallDetection());

      if (widget.playlistSongs != null && widget.playlistSongs!.isNotEmpty) {
        final currentIndex =
            widget.playlistSongs!.indexWhere((s) => s.id == widget.song.id);

        widget.audioService.setCurrentPlaylist(widget.playlistSongs!);

        await widget.audioService.backgroundHandler!.setPlaylist(
          widget.playlistSongs!,
          currentIndex >= 0 && currentIndex < widget.playlistSongs!.length
              ? currentIndex
              : 0,
        );
      }
    }
  }

  /// Запрашивает `READ_PHONE_STATE` и подключает нативный детектор звонка
  /// ([PhoneCallService]). При отказе в permission / недоступности платформы
  /// тихо остаётся на audio-focus схеме (interruption-listener handler'а).
  /// Колбэки звонка дёргают те же [_studyPausedForCall]/`resumeSession`, что и
  /// interruption-путь — дедупликация в handler'е ([_pausedForCall]) защищает
  /// от двойного срабатывания.
  Future<void> _initPhoneCallDetection() async {
    final handler = widget.audioService.backgroundHandler;
    if (handler == null) return;

    if (!Platform.isAndroid) return;

    PermissionStatus status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      debugPrint('📞 PlayerScreen: READ_PHONE_STATE request -> ${status.name}');
    }
    if (!status.isGranted) {
      debugPrint('📞 PlayerScreen: phone permission denied, '
          'falling back to audio-focus interruption scheme');
      return;
    }

    final ok = PhoneCallService.instance.start();
    if (!ok) {
      debugPrint('📞 PlayerScreen: PhoneCallService unavailable, '
          'falling back to audio-focus interruption scheme');
      return;
    }

    _phoneCallSub = PhoneCallService.instance.callStates.listen((state) {
      if (!mounted) return;
      switch (state) {
        case CallState.ringing:
        case CallState.offhook:
          debugPrint('📞 PlayerScreen: call ${state.name} → pauseForCall');
          // Study-handoff (стоп TTS + drain kick-цикла) выполняется в
          // onPlaybackInterrupted handler'а; pauseForCall — единый путь паузы.
          handler.pauseForCall();
          break;
        case CallState.idle:
          debugPrint('📞 PlayerScreen: call ended → resumeAfterCall');
          handler.resumeAfterCall();
          break;
      }
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultOffset =
        prefs.getDouble('defaultAutoScrollFocusOffset') ?? 50.0;

    // При первом запуске - сбросить на дефолт
    if (_isFirstLoad) {
      await prefs.setDouble('autoScrollFocusOffset', defaultOffset);
      _isFirstLoad = false;
    }

    final lyricsPositionOffset =
        prefs.getDouble('lyricsPositionOffset') ?? 0.15;
    widget.lyricsService.setPositionOffset(lyricsPositionOffset);

    setState(() {
      _highlightNextLine = prefs.getBool('highlightNextLine') ?? true;
      _autoScroll = prefs.getBool('autoScroll') ?? true;
      _autoScrollFocusOffset = prefs.getDouble('autoScrollFocusOffset') ?? 50.0;
      _cachedShowTranscription = prefs.getBool('showTranscription') ?? false;
    });
  }

  void _onFocusOffsetChanged(double newValue) {
    setState(() {
      _autoScrollFocusOffset = newValue;
    });
  }

  Future<void> _autoPlay() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted && widget.audioService.isInitialized) {
      debugPrint('=== Auto-playing song ===');
      await widget.audioService.play();
    }
  }

  Future<void> _updateLyricsWithTranslations() async {
    _playerTranslationHelper.markDirty();
    await _playerTranslationHelper.updateLyricsWithTranslations(
      context,
      widget.lyricsService.lyricLines,
      widget.translationService,
      showTranscript: _cachedShowTranscription,
      focusIndex: widget.lyricsService.currentIndex,
    );
  }

  Future<void> _updateAllLyricsWithTranslations() async {
    _playerTranslationHelper.markDirty();
    await _playerTranslationHelper.updateLyricsWithTranslations(
      context,
      widget.lyricsService.lyricLines,
      widget.translationService,
      showTranscript: _cachedShowTranscription,
    );
  }

  void _scrollToCurrentLine() {
    final currentIndex = widget.lyricsService.currentIndex;
    final totalLines = widget.lyricsService.lyricLines.length;

    if (currentIndex >= 0 && currentIndex < totalLines) {
      if (currentIndex == _lastScrolledIndex) return;
      _lastScrolledIndex = currentIndex;

      final lines = widget.lyricsService.lyricLines;
      int scrollDuration;
      if (currentIndex > 0 && currentIndex < lines.length) {
        final intervalMs = ((lines[currentIndex].startTime -
                    lines[currentIndex - 1].startTime) *
                1000)
            .toInt();
        scrollDuration = (intervalMs * 0.4).round().clamp(80, 300);
      } else {
        scrollDuration = 150;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || !_scrollController.hasClients) return;

        final prefs = await SharedPreferences.getInstance();
        final scrollOffset = prefs.getDouble('scrollOffset') ?? 50.0;
        final focusOffset = _autoScrollFocusOffset;

        if (currentIndex < _lineKeys.length) {
          final keyContext = _lineKeys[currentIndex].currentContext;
          if (keyContext != null) {
            final renderBox = keyContext.findRenderObject() as RenderBox;
            final scrollable = Scrollable.of(keyContext);
            if (scrollable != null) {
              final viewportBox =
                  scrollable.context.findRenderObject() as RenderBox;
              final itemScreenPos = renderBox.localToGlobal(Offset.zero);
              final itemRelativeY = viewportBox.globalToLocal(itemScreenPos).dy;
              final itemAbsolute = _scrollController.offset + itemRelativeY;
              final maxExtent = _scrollController.position.maxScrollExtent;
              final targetOffset = (itemAbsolute - scrollOffset + focusOffset)
                  .clamp(0.0, maxExtent);

              await _scrollController.animateTo(
                targetOffset,
                duration: Duration(milliseconds: scrollDuration),
                curve: Curves.easeOut,
              );
            }
            return;
          }
        }

        final maxExtent = _scrollController.position.maxScrollExtent;
        if (totalLines > 1 && maxExtent > 0) {
          final avgHeight = maxExtent / totalLines;
          final jumpTarget =
              (avgHeight * currentIndex - avgHeight * 2).clamp(0.0, maxExtent);

          await _scrollController.animateTo(
            jumpTarget,
            duration: Duration(milliseconds: scrollDuration),
            curve: Curves.easeOut,
          );

          if (!mounted) return;
          if (currentIndex < _lineKeys.length) {
            final keyContext = _lineKeys[currentIndex].currentContext;
            if (keyContext != null) {
              final renderBox = keyContext.findRenderObject() as RenderBox;
              final scrollable = Scrollable.of(keyContext);
              if (scrollable != null) {
                final viewportBox =
                    scrollable.context.findRenderObject() as RenderBox;
                final itemScreenPos = renderBox.localToGlobal(Offset.zero);
                final itemRelativeY =
                    viewportBox.globalToLocal(itemScreenPos).dy;
                final itemAbsolute = _scrollController.offset + itemRelativeY;
                final maxExtent2 = _scrollController.position.maxScrollExtent;
                final targetOffset = (itemAbsolute - scrollOffset + focusOffset)
                    .clamp(0.0, maxExtent2);

                await _scrollController.animateTo(
                  targetOffset,
                  duration: Duration(milliseconds: scrollDuration),
                  curve: Curves.easeOut,
                );
              }
            }
          }
        }
      });
    }
  }

  Future<void> _exportCurrentSong() async {
    await _playerExportHelper.exportCurrentSong(
      context,
      _currentSong,
    );
  }

  void _startPositionUpdates() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (widget.audioService.isInitialized) {
        // Скорректированная позиция для подсветки строк. Коррекция
        // нейтрализует линейный дрейф позиции у VBR MP3 без Xing header
        // (ExoPlayer занижает позицию → подсветка опаздывает). Применяется
        // только здесь (для LyricsService), slider/индикатор времени
        // используют честную widget.audioService.position. Отключаемая в
        // Настройках (timingCorrection, по умолчанию ВКЛ).
        final rawPos = widget.audioService.position;
        final player = widget.audioService.player;
        Duration posForHighlight = rawPos;
        if (_settingsProvider?.timingCorrection ?? true) {
          final isReady = player.processingState == ProcessingState.ready;
          posForHighlight = _positionCorrector.correct(
            rawPos,
            playing: player.playing,
            isReady: isReady,
            speed: widget.audioService.playbackSpeed,
          );
        }
        final positionSec = posForHighlight.inMilliseconds.toDouble() / 1000;
        widget.lyricsService.updatePosition(positionSec);

        final currentLineIndex = widget.lyricsService.currentIndex;
        final currentLangIndex = widget.translationService.currentLanguageIndex;
        final needsTranslationUpdate =
            currentLineIndex != _lastProcessedIndex ||
                currentLangIndex != _lastProcessedLanguageIndex;

        if (needsTranslationUpdate) {
          _lastProcessedIndex = currentLineIndex;
          _lastProcessedLanguageIndex = currentLangIndex;
          _updateLyricsWithTranslations();
        }

        if (_autoScroll && !_isEditMode) {
          _scrollToCurrentLine();
        }
      }

      // Rebuild throttling: вместо setState на каждый 50мс-тик (20/сек) —
      // только если прошло >= 120мс с прошлого rebuild (~8/сек). Подсветка
      // строк обновляется через AnimatedBuilder над lyricsService независимо
      // (не зависит от этого setState), а для индикатора времени/AppBar 8/сек
      // достаточно. Снижение нагрузки на UI-изолят убирает задержки доставки
      // событий positionStream → _position перестаёт «устаревать».
      if (mounted) {
        final now = DateTime.now();
        if (now.difference(_lastSetStateTime).inMilliseconds >= 120) {
          _lastSetStateTime = now;
          setState(() {});
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (_isInBackground) {
        debugPrint(
            '=== PlayerScreen: resumed from background, restarting updates ===');
        _isInBackground = false;
        _lastScrolledIndex = -1;
        // После возврата из фона позиция аудио и wall-clock рассинхронизированы
        // (positionStream мог не тикать в фоне) — сбрасываем корректор, чтобы
        // он пересинхронизировался с актуальной _player.position при первом
        // тике после resume.
        _positionCorrector.reset();
        _startPositionUpdates();
        _syncWithActuallyPlayingSong();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isInBackground = true;
      // Отменяем 50мс-таймер в фоне — там некого rebuild'ить, а лишние тики
      // будят UI-изолят и мешают doze. positionStream в AudioService продолжит
      // обновлять _position независимо. При resumed таймер перезапустится.
      _positionTimer?.cancel();
      _positionTimer = null;
    }
  }

  Future<void> _syncWithActuallyPlayingSong() async {
    String? actualAudioPath;

    final handler = widget.audioService.backgroundHandler;
    if (handler != null) {
      final currentMediaItem = handler.mediaItem.value;
      if (currentMediaItem != null) {
        actualAudioPath = currentMediaItem.id;
        debugPrint('Background handler playing: $actualAudioPath');
      }
    }

    actualAudioPath ??= widget.audioService.currentSong?.audioPath;

    if (actualAudioPath != null && actualAudioPath != _currentSong.audioPath) {
      Song? actualSong;
      if (widget.playlistSongs != null) {
        try {
          actualSong = widget.playlistSongs!.firstWhere(
            (s) => s.audioPath == actualAudioPath,
          );
        } catch (_) {}
      }

      actualSong ??= widget.audioService.currentSong;

      if (actualSong == null) {
        final db = DatabaseService();
        final songs = await db.getAllSongs();
        try {
          actualSong = songs.firstWhere((s) => s.audioPath == actualAudioPath);
        } catch (_) {}
      }

      if (actualSong != null &&
          actualSong.audioPath != _currentSong.audioPath) {
        debugPrint(
            'Song changed while in background! Switching from "${_currentSong.title}" to "${actualSong.title}"');
        _currentSong = actualSong;

        if (_currentSong.lrcPath != null && _currentSong.lrcPath!.isNotEmpty) {
          await widget.lyricsService.loadLrcFile(_currentSong.lrcPath!);
        } else {
          widget.lyricsService.clear();
        }

        await _loadAllTranslations(_currentSong.id, _currentSong.title);
        await _selectLanguageBasedOnSettings();
        await _updateAllLyricsWithTranslations();

        if (mounted) setState(() {});
        return;
      }
    }

    await _updateAllLyricsWithTranslations();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _settingsProvider?.removeListener(_onSettingsChanged);
    widget.audioService.removeListener(_onAudioServiceChanged);
    _completionWatchdog?.cancel();
    _positionTimer?.cancel();
    _scrollController.dispose();
    // Чистим колбэки, владельцы которых переживают этот screen:
    // audioService и studyModeService.onStudyCompleted хранят замыкания на this,
    // и без очистки продолжали бы держать ссылки на disposed screen и дёргать
    // (guarded) логику после ухода с экрана.
    widget.audioService.onSongComplete = null;
    _studyModeService.onStudyCompleted = null;
    _studyModeService.dispose();

    _carDetectionService.removeListener(_onCarDetection);
    _carDetectionService.dispose();
    _carAlertService.dispose();

    final handler = widget.audioService.backgroundHandler;
    if (handler != null) {
      handler.onSkipToNextRequested = null;
      handler.onSkipToPreviousRequested = null;
      handler.onPlaybackInterrupted = null;
      handler.onPlaybackResumed = null;
      handler.onBecomingNoisy = null;
      handler.onUserPause = null;
      handler.onUserPlay = null;
    }

    // Отписываемся от детектора звонка и глушим нативный слушатель — иначе
    // TelephonyCallback/PhoneStateListener переживёт экран и продолжил бы
    // дёргать disposed handler (memory leak + phantom pause/resume).
    _phoneCallSub?.cancel();
    _phoneCallSub = null;
    PhoneCallService.instance.stop();

    super.dispose();
  }

  String _formatDuration(Duration duration) {
    return LrcFormatter.formatDuration(duration);
  }

  Future<void> _showTextLoaderDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TextLoaderDialog(
        song: _currentSong,
        lyricsService: widget.lyricsService,
        translationService: widget.translationService,
      ),
    );

    if (result == true) {
      try {
        debugPrint(
            '=== Dialog closed with result=true, reloading song data ===');
        final db = DatabaseService();

        // Перезагружаем данные песни из базы данных
        final updatedSong = await db.getSong(_currentSong.id);

        if (updatedSong != null) {
          debugPrint('=== Updated song loaded from DB ===');
          debugPrint('Updated song lrcPath: ${updatedSong!.lrcPath}');
          debugPrint(
              'Updated song originalLanguage: ${updatedSong!.originalLanguage}');

          // Обновляем текущую песню
          _currentSong = updatedSong!;

          // Если есть LRC файл, загружаем его
          if (updatedSong!.lrcPath != null &&
              updatedSong!.lrcPath!.isNotEmpty) {
            debugPrint('Loading LRC file: ${updatedSong!.lrcPath}');
            await widget.lyricsService.loadLrcFile(updatedSong!.lrcPath!);
            debugPrint(
                'LRC loaded, lyric lines count: ${widget.lyricsService.lyricLines.length}');
          }

          // Загружаем все переводы для песни
          await _loadAllTranslations(_currentSong.id, _currentSong.title);

          await _updateAllLyricsWithTranslations();

          setState(() {});

          debugPrint('=== After reloading ===');
          debugPrint('Lyrics lines: ${widget.lyricsService.lyricLines.length}');
          debugPrint(
              'Translations: ${widget.translationService.translations.length}');

          // Показываем сообщение об успехе
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.originalTextLoaded),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error reloading text and translations: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading text: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildAppBarContent(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final sw = MediaQuery.of(context).size.width;
    final hd = widget.translationService.translations.isNotEmpty;
    final dw = hd ? sw * 0.22 : 0.0;
    final avail = sw - 40.0 - dw - (hd ? 12.0 : 4.0);
    // НЕ edit mode: car-detect, study, study-settings, swap, transcription, popup = 6
    // edit mode: study-settings, save, swap, transcription, popup = 5
    // (car-detect и study скрыты в edit mode, зато появляется save)
    final int cnt = _isEditMode ? 5 : 6;
    final bs = (avail / cnt).clamp(18.0, 52.0);
    final iconSz = (bs * 0.72).clamp(12.0, 24.0);
    final hdrBtnSize = iconSz.clamp(20.0, 26.0);

    Widget btn(IconData icon, VoidCallback onTap, {Color? color}) {
      return SizedBox(
        width: bs,
        height: bs,
        child: IconButton(
          icon: Icon(icon, color: color),
          iconSize: iconSz,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: bs, height: bs),
          onPressed: onTap,
        ),
      );
    }

    final Widget langPicker = Container(
      constraints: BoxConstraints(maxWidth: dw),
      padding: EdgeInsets.symmetric(horizontal: isLandscape ? 4.0 : 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.translationService.translations.length > 1)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 4 : 6,
                vertical: isLandscape ? 2 : 3,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.translationService.translations.length}',
                style: TextStyle(
                  fontSize: isLandscape ? 10 : 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          SizedBox(
              width: widget.translationService.translations.length > 1 ? 6 : 0),
          DropdownButton<String>(
            value: widget.translationService.currentLanguageIndex.toString(),
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            underline: const SizedBox(),
            style: TextStyle(
              fontSize: isLandscape ? 12 : 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onChanged: (String? value) async {
              if (value != null) {
                final index = int.parse(value);
                widget.translationService.selectLanguage(index);
                final translation =
                    widget.translationService.translations[index];
                final db = DatabaseService();
                await db.setSelectedLanguage(
                    _currentSong.id, translation.language);
                await _updateAllLyricsWithTranslations();
                if (mounted) {
                  final l10n = AppLocalizations.of(context)!;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(l10n.languageSelected(translation.languageName)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
                setState(() {});
              }
            },
            items: widget.translationService.translations
                .asMap()
                .entries
                .map((entry) {
              final translation = entry.value;
              final isSelected =
                  entry.key == widget.translationService.currentLanguageIndex;
              final shortName = _getShortLanguageName(
                  translation.languageName, translation.language);
              final emoji =
                  _getLanguageEmoji(translation.language, translation.type);
              return DropdownMenuItem<String>(
                value: entry.key.toString(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji,
                        style: TextStyle(fontSize: isLandscape ? 14 : 16)),
                    const SizedBox(width: 6),
                    Text(
                      shortName,
                      style: TextStyle(
                        fontSize: isLandscape ? 12 : 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check,
                          size: isLandscape ? 14 : 16,
                          color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (!_isEditMode)
          _buildCarDetectionButton(iconSize: hdrBtnSize, boxSize: bs),
        if (!_isEditMode)
          _buildStudyModeButton(iconSize: hdrBtnSize, boxSize: bs),
        IconButton(
          icon: const Icon(Icons.tune),
          iconSize: hdrBtnSize,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: bs, height: bs),
          tooltip: AppLocalizations.of(context)!.studyModeOpenSettings,
          onPressed: _openStudyModeSettings,
        ),
        if (_isEditMode) btn(Icons.save, _saveLrcChanges),
        btn(
          Icons.swap_vert,
          () {
            final sp = Provider.of<SettingsProvider>(context, listen: false);
            sp.setShowTranslationFirst(!sp.showTranslationFirst);
          },
        ),
        btn(
          Icons.text_fields,
          () async {
            final prefs = await SharedPreferences.getInstance();
            final show = prefs.getBool('showTranscription') ?? false;
            await prefs.setBool('showTranscription', !show);
            _cachedShowTranscription = !show;
            _playerTranslationHelper.markDirty();
            await _updateAllLyricsWithTranslations();
            setState(() {});
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(!show
                      ? l10n.transcriptionEnabled
                      : l10n.transcriptionDisabled),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: iconSz),
          padding: EdgeInsets.symmetric(horizontal: (bs - iconSz) / 2),
          constraints: BoxConstraints(minWidth: bs, minHeight: bs),
          position: PopupMenuPosition.under,
          onSelected: (String value) async {
            if (value == 'autoScroll') {
              setState(() => _autoScroll = !_autoScroll);
            } else if (value == 'songSpeed') {
              _showSpeedDialog();
            } else if (value == 'lyricColors') {
              _showLyricColorsDialog();
            } else if (value == 'share') {
              await _exportCurrentSong();
            } else if (value == 'editMode') {
              final entering = !_isEditMode;
              setState(() => _isEditMode = entering);
              // Озвучка перевода не нужна при простановке меток — глушим study
              // mode с userRequested, чтобы persist-флаг тоже сбросился (иначе
              // авто-restart в _restartStudyIfNeeded перезапустит её). Car
              // detection не трогаем — он не мешает установке меток.
              if (entering && _studyModeService.isActive) {
                await _studyModeService.stop(userRequested: true);
              }
            } else if (value == 'edit') {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => TranslationEditorScreen(
                    song: _currentSong,
                    lyricLines: widget.lyricsService.lyricLines,
                    translationService: widget.translationService,
                    lyricsService: widget.lyricsService,
                  ),
                ),
              );
              if (saved == true) {
                await _updateAllLyricsWithTranslations();
                setState(() {});
              }
            } else if (value == 'add') {
              _loadTranslationsFromFile();
            } else if (value == 'loadText') {
              _showTextLoaderDialog();
            } else if (value == 'delete') {
              await _deleteCurrentTranslation();
            }
          },
          itemBuilder: (BuildContext context) {
            final l10n = AppLocalizations.of(context)!;
            return [
              PopupMenuItem<String>(
                value: 'autoScroll',
                child: Row(
                  children: [
                    Icon(
                      _autoScroll
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.autoScroll),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'songSpeed',
                child: Row(
                  children: [
                    const Icon(Icons.speed, size: 20),
                    const SizedBox(width: 12),
                    Text(
                        '${l10n.playbackSpeed}: ${_playbackSpeed == _playbackSpeed.roundToDouble() ? _playbackSpeed.toStringAsFixed(1) : _playbackSpeed}x'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'lyricColors',
                child: Row(
                  children: [
                    const Icon(Icons.palette, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.lyricColors),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    const Icon(Icons.share, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.exportCurrentSong),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'editMode',
                child: Row(
                  children: [
                    Icon(_isEditMode ? Icons.edit_off : Icons.edit_note,
                        size: 20),
                    const SizedBox(width: 12),
                    Text(_isEditMode ? l10n.exitEditMode : l10n.editTimestamps),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.editTranslations),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'add',
                child: Row(
                  children: [
                    const Icon(Icons.archive, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.loadTranslationsFromFile),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'loadText',
                child: Row(
                  children: [
                    const Icon(Icons.description, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.loadTextMenu),
                  ],
                ),
              ),
              if (widget.translationService.translations.isNotEmpty)
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.deleteTranslation),
                    ],
                  ),
                ),
            ];
          },
        ),
        const Spacer(),
        if (hd) langPicker,
      ],
    );
  }

  Widget _buildLoopButton(bool isLandscape, {double iconSize = 32.0}) {
    IconData icon;
    Color? color;

    switch (_loopMode) {
      case LoopMode.off:
        icon = Icons.repeat;
        color = null;
        break;
      case LoopMode.all:
        icon = Icons.repeat;
        color = Theme.of(context).colorScheme.primary;
        break;
      case LoopMode.one:
        icon = Icons.repeat_one;
        color = Theme.of(context).colorScheme.primary;
        break;
      case LoopMode.allPlaylists:
        icon = Icons.repeat;
        color = Theme.of(context).colorScheme.primary;
        break;
      case LoopMode.favorites:
        // Режим убран из цикла переключения; defensive — не должен наступить
        // через UI (избранное слушается через отдельную закладку).
        icon = Icons.repeat;
        color = null;
        break;
    }

    final localizations = AppLocalizations.of(context)!;
    final isLoopEnabled = _loopMode != LoopMode.off;

    return Container(
      decoration: BoxDecoration(
        color: isLoopEnabled
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isLoopEnabled
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(
              icon,
              color: color,
              weight: isLoopEnabled ? 900 : 400,
            ),
            onPressed: _toggleLoop,
            tooltip: _loopMode == LoopMode.off
                ? localizations.repeatOff
                : _loopMode == LoopMode.all
                    ? localizations.repeatAll
                    : _loopMode == LoopMode.one
                        ? localizations.repeatOne
                        : _loopMode == LoopMode.allPlaylists
                            ? localizations.repeatAllPlaylists
                            : localizations.repeatOff,
            iconSize: iconSize,
          ),
          if (_loopMode == LoopMode.allPlaylists)
            Positioned(
              right: 4,
              bottom: 4,
              child: Icon(
                Icons.list,
                size: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  void _showSpeedDialog() {
    final speeds = [0.5, 0.75, 0.8, 0.9, 1.0, 1.1, 1.25, 1.5, 2.0];
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.playbackSpeed),
        children: speeds.map((speed) {
          final isSelected = (speed - _playbackSpeed).abs() < 0.01;
          return SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _playbackSpeed = speed;
              });
              widget.audioService.setPlaybackRate(speed);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  speed == 1.0
                      ? '${speed}x (${l10n.speedNormal})'
                      : '${speed}x',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(this.context).colorScheme.primary
                        : null,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(this.context).colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Диалог выбора цветов оригинала/перевода: пресеты + точная настройка
  /// палитрой для каждого типа текста + живой preview. Без новых зависимостей
  /// — используется палитра [LyricColorPalette]. См. задачу подсветки строк.
  void _showLyricColorsDialog() {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // Локализованное имя пресета по его ключу (см. LyricColorPresets.nameKey).
    String presetName(String key) {
      switch (key) {
        case 'lyricPresetDefault':
          return l10n.lyricPresetDefault;
        case 'lyricPresetBlueRed':
          return l10n.lyricPresetBlueRed;
        case 'lyricPresetRedBlue':
          return l10n.lyricPresetRedBlue;
        case 'lyricPresetGreenOrange':
          return l10n.lyricPresetGreenOrange;
        case 'lyricPresetContrast':
          return l10n.lyricPresetContrast;
        default:
          return key;
      }
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        bool useCustom = settings.useCustomLyricColors;
        int origVal = settings.originalTextColorValue;
        int transVal = settings.translationTextColorValue;

        // Свотч одного цвета. Если выбран (currentValue == color.value) — рамка
        // и галочка. color == null означает «Авто» (цвет темы).
        Widget swatch(
            Color? color, int currentValue, ValueChanged<int?> onSelect) {
          final isAuto = color == null;
          final selected = isAuto
              ? currentValue == LyricColorPalette.autoValue
              : currentValue == color!.value;
          return GestureDetector(
            onTap: () => onSelect(isAuto ? null : color!.value),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAuto ? null : color,
                border: Border.all(
                  color: selected
                      ? Theme.of(dialogContext).colorScheme.primary
                      : Colors.black26,
                  width: selected ? 3 : 1,
                ),
              ),
              child: isAuto
                  ? Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : (selected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null),
            ),
          );
        }

        Widget swatchRow(
            String label, int currentValue, ValueChanged<int?> onSelect) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 6),
                child: Text(label,
                    style: Theme.of(dialogContext).textTheme.titleSmall),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    swatch(null, currentValue, onSelect),
                    ...LyricColorPalette.swatches
                        .map((s) => swatch(s.color, currentValue, onSelect)),
                  ],
                ),
              ),
            ],
          );
        }

        return StatefulBuilder(
          builder: (context, setState) {
            // Применяет пресет и включает useCustom.
            void applyPreset(LyricColorPreset p) {
              setState(() {
                origVal = p.originalValue;
                transVal = p.translationValue;
                useCustom = true;
              });
              settings.setUseCustomLyricColors(true);
              settings.setOriginalTextColor(
                  LyricColorPalette.colorFromValue(p.originalValue));
              settings.setTranslationTextColor(
                  LyricColorPalette.colorFromValue(p.translationValue));
            }

            void setOriginal(int? v) {
              setState(() {
                origVal = v ?? LyricColorPalette.autoValue;
                useCustom = true;
              });
              settings.setUseCustomLyricColors(true);
              settings.setOriginalTextColor(
                  LyricColorPalette.colorFromValue(origVal));
            }

            void setTranslation(int? v) {
              setState(() {
                transVal = v ?? LyricColorPalette.autoValue;
                useCustom = true;
              });
              settings.setUseCustomLyricColors(true);
              settings.setTranslationTextColor(
                  LyricColorPalette.colorFromValue(transVal));
            }

            final origColor =
                useCustom ? LyricColorPalette.colorFromValue(origVal) : null;
            final transColor =
                useCustom ? LyricColorPalette.colorFromValue(transVal) : null;

            return AlertDialog(
              title: Text(l10n.lyricColorsTitle),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.lyricColorsUseCustom),
                      value: useCustom,
                      onChanged: (v) {
                        setState(() => useCustom = v);
                        settings.setUseCustomLyricColors(v);
                      },
                    ),
                    if (useCustom) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 6),
                        child: Text(l10n.lyricColorsPresets,
                            style:
                                Theme.of(dialogContext).textTheme.titleSmall),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: LyricColorPresets.all.map((p) {
                          final selected = origVal == p.originalValue &&
                              transVal == p.translationValue;
                          return ChoiceChip(
                            label: Text(presetName(p.nameKey)),
                            selected: selected,
                            onSelected: (_) => applyPreset(p),
                          );
                        }).toList(),
                      ),
                      swatchRow(l10n.lyricColorsOriginal, origVal, setOriginal),
                      swatchRow(l10n.lyricColorsTranslation, transVal,
                          setTranslation),
                      // Живой preview: как будет выглядеть строка.
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 6),
                        child: Text(l10n.lyricColorsPreview,
                            style:
                                Theme.of(dialogContext).textTheme.titleSmall),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(dialogContext)
                              .colorScheme
                              .primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, how are you?',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: origColor ??
                                    Theme.of(dialogContext).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Привет, как дела?',
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: transColor ??
                                    Theme.of(dialogContext)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.lyricColorsDone),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStudyModeButton(
      {double iconSize = 32.0, double boxSize = 44.0}) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _studyModeService,
      builder: (context, _) {
        final isActive = _studyModeService.isActive;
        return Container(
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: IconButton(
            icon: Icon(
              Icons.record_voice_over,
              color: isActive ? Theme.of(context).colorScheme.primary : null,
              weight: isActive ? 900 : 400,
            ),
            onPressed: _toggleStudyMode,
            onLongPress: _openStudyModeSettings,
            tooltip: '${l10n.studyModeTooltip}\n${l10n.studyModeLongPressHint}',
            iconSize: iconSize,
            padding: EdgeInsets.zero,
            constraints:
                BoxConstraints.tightFor(width: boxSize, height: boxSize),
          ),
        );
      },
    );
  }

  Future<void> _loadTranslationsFromFile() async {
    await _playerImportHelper.loadTranslationsFromFile(
      context,
      _currentSong,
      widget.translationService,
    );
  }

  Widget _buildCarDetectionButton(
      {double iconSize = 32.0, double boxSize = 44.0}) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _carDetectionService,
      builder: (context, _) {
        final isActive = _carDetectionService.isActive;
        final hasAlert = _carDetectionService.lastDetection != null &&
            _carDetectionService.lastDetection!.timestamp
                .isAfter(DateTime.now().subtract(const Duration(seconds: 4)));
        return Container(
          decoration: BoxDecoration(
            color: hasAlert
                ? Colors.red.withValues(alpha: 0.35)
                : isActive
                    ? Theme.of(context).colorScheme.errorContainer
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: hasAlert
                ? Border.all(color: Colors.red, width: 2)
                : isActive
                    ? Border.all(
                        color: Theme.of(context).colorScheme.error,
                        width: 2,
                      )
                    : null,
          ),
          child: IconButton(
            icon: Icon(
              Icons.directions_car,
              color: hasAlert
                  ? Colors.red
                  : isActive
                      ? Theme.of(context).colorScheme.error
                      : null,
              weight: isActive ? 900 : 400,
            ),
            onPressed: _toggleCarDetection,
            tooltip: l10n.carDetectionTooltip,
            iconSize: iconSize,
            padding: EdgeInsets.zero,
            constraints:
                BoxConstraints.tightFor(width: boxSize, height: boxSize),
          ),
        );
      },
    );
  }

  Future<void> _loadTranslationFromZip() async {
    try {
      debugPrint('=== DEBUG: Loading translations from ZIP in player ===');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final zipPath = (result.files.single.path ??
            result.files.single.identifier) as String;
        await _processTranslationZipArchive(zipPath);
      } else {
        debugPrint('No file selected');
      }
    } catch (e) {
      debugPrint('Error loading translations from ZIP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load translations: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadTranslationFromJson() async {
    try {
      debugPrint('=== DEBUG: Loading translations from JSON in player ===');

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          final filePath = (file.path ?? file.identifier) as String;
          await _showLanguageInputDialog(File(filePath));
        }
      } else {
        debugPrint('No file selected');
      }
    } catch (e) {
      debugPrint('Error loading translations from JSON: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load translations: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _processTranslationZipArchive(String zipPath) async {
    try {
      debugPrint('=== Processing translation ZIP archive ===');
      debugPrint('ZIP path: $zipPath');

      final folder = await FolderConfigService.getConfiguredFolder();
      if (folder == null) {
        debugPrint('ERROR: No folder configured');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No folder configured'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final baseName = _currentSong.title;
      debugPrint('Base name: $baseName');
      debugPrint('Target folder: ${folder.path}');

      final extractedFiles = await ExportImportService.extractSongArchive(
        zipPath,
        folder.path,
        baseName,
      );

      debugPrint('=== Extracted ${extractedFiles.length} files ===');
      debugPrint('=== All extracted files ===');
      for (final filePath in extractedFiles) {
        final fileName = path_pkg.basename(filePath);
        debugPrint('  - $fileName');
      }
      debugPrint('=== End of extracted files list ===');

      final scanResult = await _scanTranslationsForSong(extractedFiles);
      final lrcFound = scanResult['lrcFound'] as int;
      final lrcPath = scanResult['lrcPath'] as String?;
      final translationsAdded = scanResult['translationsAdded'] as int;

      debugPrint('=== Scan results ===');
      debugPrint('LRC files found: $lrcFound');
      debugPrint('LRC path: $lrcPath');
      debugPrint('Translations added: $translationsAdded');

      final db = DatabaseService();

      if (lrcFound > 0 && lrcPath != null) {
        await db.updateSongLrcPath(_currentSong.id, lrcPath);
        await widget.lyricsService.loadLrcFile(lrcPath);
        await _updateAllLyricsWithTranslations();
        debugPrint('✓ LRC file loaded: $lrcPath');

        if (mounted) {
          setState(() {
            debugPrint('State updated after loading LRC');
          });
        }
      }

      if (translationsAdded > 0) {
        debugPrint('Reloading translations from database...');
        await _loadAllTranslations(_currentSong.id, _currentSong.title);
        await _updateAllLyricsWithTranslations();
        debugPrint('✓ Translations attached to LRC lines');

        if (mounted) {
          setState(() {
            debugPrint('State updated after loading translations');
          });
        }
      }

      final translationCount = widget.translationService.translations.length;
      debugPrint('=== Total translations after import: $translationCount ===');

      if (mounted) {
        setState(() {
          debugPrint('State updated after loading translations');
        });

        String message;
        if (lrcFound > 0 && translationsAdded > 0) {
          message = 'LRC and $translationsAdded translation(s) loaded';
        } else if (lrcFound > 0) {
          message = 'LRC file loaded';
        } else if (translationsAdded > 0) {
          message = '$translationsAdded translation(s) loaded';
        } else {
          message = 'No files loaded from archive';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: translationsAdded > 0 || lrcFound > 0
                ? Colors.green
                : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing ZIP archive: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process archive: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _scanTranslationsForSong(
      List<String> extractedFiles) async {
    try {
      debugPrint(
          '=== Scanning translations for song: ${widget.song.title} ===');
      debugPrint('Song ID: ${widget.song.id}');
      debugPrint('Total extracted files: ${extractedFiles.length}');
      int translationsAdded = 0;
      int errorsCount = 0;
      int lrcFound = 0;
      String? lrcPathToSave;
      final db = DatabaseService();

      for (final filePath in extractedFiles) {
        final fileName = path_pkg.basename(filePath);

        debugPrint('=== Processing file ===');
        debugPrint('  File name: "$fileName"');
        debugPrint('  File path: $filePath');

        if (fileName.endsWith('.lrc') ||
            fileName.toLowerCase().endsWith('.lrc')) {
          lrcPathToSave = filePath;
          lrcFound++;
          debugPrint('  ✓ Found LRC file: "$fileName"');
        } else if (fileName.endsWith('.json') ||
            fileName.toLowerCase().endsWith('.json')) {
          debugPrint('  ✓ This is a JSON file');

          try {
            final file = File(filePath);
            if (!await file.exists()) {
              debugPrint('  ⚠ File does not exist: $filePath');
              errorsCount++;
              continue;
            }

            debugPrint('  Reading JSON file...');
            final content = await file.readAsString();
            debugPrint('  File size: ${content.length} characters');

            final data = json.decode(content) as Map<String, dynamic>;

            if (!data.containsKey('translations') ||
                data['translations'] == null) {
              debugPrint('  ⚠ No translations key in file: $fileName');
              errorsCount++;
              continue;
            }

            final translations = data['translations'] as List;
            if (translations.isEmpty) {
              debugPrint('  ⚠ Empty translations array in file: $fileName');
              errorsCount++;
              continue;
            }

            debugPrint('  Found ${translations.length} translations in file');

            for (final t in translations) {
              try {
                final translationData = t as Map<String, dynamic>;

                final language =
                    translationData['language'] as String? ?? 'unknown';
                final languageName =
                    translationData['languageName'] as String? ?? 'Unknown';
                final type = translationData['type'] as String?;

                debugPrint(
                    '  Translation found: $languageName ($language) type: $type');

                await db.addTranslationFile(
                  widget.song.id,
                  language,
                  languageName,
                  filePath,
                  type: type,
                );
                translationsAdded++;
                debugPrint('  ✓ Saved translation to database: $languageName');
              } catch (e) {
                debugPrint('  ✗ Error adding translation: $e');
                errorsCount++;
              }
            }

            debugPrint('  ✓ Successfully processed JSON file: $fileName');
          } catch (e) {
            debugPrint('  ✗ Error processing JSON file $fileName: $e');
            errorsCount++;
          }
        } else {
          debugPrint('  ⚠ Skipping unknown file type: "$fileName"');
        }
      }

      debugPrint(
          '=== Translation scan completed for song: ${widget.song.title} ===');
      debugPrint('LRC files found: $lrcFound');
      debugPrint('LRC path: $lrcPathToSave');
      debugPrint('Total translations added to database: $translationsAdded');
      debugPrint('Total errors encountered: $errorsCount');

      return {
        'lrcFound': lrcFound,
        'lrcPath': lrcPathToSave,
        'translationsAdded': translationsAdded,
        'errorsCount': errorsCount,
      };
    } catch (e) {
      debugPrint(
          '✗ Fatal error scanning translations for song ${widget.song.title}: $e');
      return {
        'lrcFound': 0,
        'lrcPath': null,
        'translationsAdded': 0,
        'errorsCount': 1,
      };
    }
  }

  Future<void> _showLanguageInputDialog(File file) async {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController nameController = TextEditingController();
    String? selectedType;

    final typeOptions = [
      {'value': null, 'label': l10n.translationTypeNormal},
      {'value': 'author', 'label': l10n.translationTypeAuthor},
      {'value': 'poetic', 'label': l10n.translationTypePoetic},
      {'value': 'literal', 'label': l10n.translationTypeLiteral},
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.specifyTranslationLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.languageNameLabel,
                hintText: l10n.languageNameHint,
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.translationTypeLabel),
            DropdownButton<String>(
              value: selectedType,
              items: typeOptions.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'] as String?,
                  child: Text(type['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                selectedType = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) return;
              Navigator.pop(context, {
                'name': nameController.text,
                'type': selectedType,
              });
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (result != null) {
      await _loadTranslationFile(file, result['name'], result['type']);
    }
  }

  Future<void> _loadTranslationFile(
      File file, String languageName, String? type) async {
    try {
      debugPrint('Loading translation file ${file.path}');

      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;

      if (!data.containsKey('translations')) {
        throw Exception('Invalid JSON format: missing "translations" key');
      }

      final translations = data['translations'] as List;
      if (translations.isEmpty) {
        throw Exception('No translations found in file');
      }

      for (final t in translations) {
        final translationData = t as Map<String, dynamic>;
        translationData['languageName'] = languageName;
        if (type != null) {
          translationData['type'] = type;
        }

        final translation = Translation.fromJson(translationData);
        final translationWithFilePath = Translation(
          language: translation.language,
          languageName: translation.languageName,
          type: translation.type,
          lines: translation.lines,
          filePath: file.path,
        );

        widget.translationService.addTranslation(translationWithFilePath);
        debugPrint(
            '✓ Added translation: ${translation.languageName} (${translation.language})');
      }

      _updateAllLyricsWithTranslations();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translationLoadedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading translation: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLabel),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _saveLrcChanges() async {
    try {
      if (_currentSong.lrcPath == null) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noLrcFileAssociated),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final lrcPath = _currentSong.lrcPath!;
      final file = File(lrcPath);

      final lrcContent = _generateLrcContent(widget.lyricsService.lyricLines);

      await file.writeAsString(lrcContent);

      if (widget.translationService.translations.isNotEmpty ||
          widget.translationService.transcriptTranslation != null) {
        widget.translationService
            .updateLineTimestamps(widget.lyricsService.lyricLines);
        await widget.translationService.saveAllTranslations();
        debugPrint('All translation files saved successfully');
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.lrcAndTranslationsSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving LRC and translations: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateLrcContent(List<LyricLine> lines) {
    return LrcFormatter.generateLrcContent(lines);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _isEditMode
            ? Colors.orange
            : Theme.of(context).colorScheme.inversePrimary,
        titleSpacing: 0,
        leadingWidth: 40,
        centerTitle: false,
        title: _buildAppBarContent(context),
      ),
      body: Column(
        children: [
          // === DEBUG: Study Mode state overlay (only when "Service Data"
          // setting is enabled) ===
          // NOTE (5.0.7 diagnostic): shown whenever showServiceData is on —
          // NOT gated by studyModeService.isActive — so we can see the state
          // even when study is inactive (the exact failure case).
          if (Provider.of<SettingsProvider>(context).showServiceData)
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.lightGreenAccent,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
                child: Text(
                  () {
                    final p = widget.audioService.player;
                    final s = _studyModeService;
                    final src = _ttsCoordinator.currentSource.name;
                    final gen = _ttsCoordinator.lastGenerationMs;
                    return 'STUDY active=${s.isActive} '
                        'persist=${s.enabledPersist} '
                        'phase=${s.phase.name} '
                        'idx=${s.currentIndex} '
                        'paused=${s.isUserPaused} '
                        'speak=${s.isSpeaking} '
                        'resuming=${s.debugResuming}\n'
                        'PLAYER playing=${p.playing} '
                        'state=${p.processingState.name} '
                        'pos=${widget.audioService.position.inMilliseconds}ms '
                        'load=$_isSongLoading\n'
                        'SEG target=${s.debugSegmentEnd?.toStringAsFixed(2) ?? "null"}s '
                        'ticks=${s.debugSegmentTicks}\n'
                        'TTS src=$src '
                        'engine=${s.selectedEngine ?? s.activeEngine ?? "?"} '
                        'engines=${s.availableEngines.length} '
                        'langAvail=${s.isLanguageAvailable} '
                        'gen=${gen}ms '
                        'speakDisabled=${s.speakDisabled}\n'
                        'EVT: $_lastStudyEvent';
                  }(),
                ),
              ),
            ),
          // === Car Detection overlay: shown when detection is active.
          // Compact diagnostic line so the runner can see the analyser state. ===
          if (_carDetectionService.isActive)
            AnimatedBuilder(
              animation: _carDetectionService,
              builder: (context, _) {
                final d = _carDetectionService.lastDetection;
                final recentAlert = d != null &&
                    d.timestamp.isAfter(
                        DateTime.now().subtract(const Duration(seconds: 3)));
                return Container(
                  width: double.infinity,
                  color: recentAlert ? Colors.red.shade900 : Colors.black87,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    child: Text(
                      recentAlert
                          ? '🚗 CAR ${d!.levelLabel} '
                              'score=${d.score.toStringAsFixed(2)} '
                              '@${d.timestamp.toIso8601String().substring(11, 19)}'
                          : _carDetectionService.statusLine,
                    ),
                  ),
                );
              },
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: widget.lyricsService,
                    builder: (context, child) {
                      final lines = widget.lyricsService.lyricLines;
                      if (_lineKeys.length < lines.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted &&
                              _lineKeys.length <
                                  widget.lyricsService.lyricLines.length) {
                            setState(() {
                              while (_lineKeys.length <
                                  widget.lyricsService.lyricLines.length) {
                                _lineKeys.add(GlobalKey());
                              }
                            });
                          }
                        });
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: isLandscape ? 4.0 : 8.0,
                        ).copyWith(bottom: 180.0),
                        itemCount: lines.length,
                        itemBuilder: (context, index) {
                          final line = lines[index];
                          final isCurrent =
                              index == widget.lyricsService.currentIndex;
                          final isNext = _highlightNextLine &&
                              index == widget.lyricsService.currentIndex + 1;

                          return Padding(
                            key: _lineKeys[index],
                            padding: EdgeInsets.only(
                              right: isLandscape ? 0.0 : 8.0,
                              left: isLandscape ? 4.0 : 8.0,
                              top: isLandscape ? 2.0 : 4.0,
                              bottom: isLandscape ? 2.0 : 4.0,
                            ),
                            child: LyricLineWidget(
                              line: line,
                              isCurrent: isCurrent,
                              isNext: isNext,
                              isEditMode: _isEditMode,
                              onTap: () async {
                                if (_isEditMode) {
                                  // Живая позиция just_audio (updatePosition +
                                  // wall-clock), а не кэш positionStream:
                                  // во время редактирования тапы и пересборка
                                  // списка задерживают доставку событий, кэш
                                  // устаревает и метки пишутся раньше. Плюс
                                  // прогоняем через тот же корректор, что и
                                  // подсветка — метка и переключение строки
                                  // живут в одном домене времени.
                                  final player = widget.audioService.player;
                                  final livePos = player.position;
                                  final markPos = (_settingsProvider
                                              ?.timingCorrection ??
                                          true)
                                      ? _positionCorrector.correct(
                                          livePos,
                                          playing: player.playing,
                                          isReady: player.processingState ==
                                              ProcessingState.ready,
                                          speed:
                                              widget.audioService.playbackSpeed,
                                        )
                                      : livePos;
                                  final currentTime =
                                      markPos.inMilliseconds.toDouble() / 1000;
                                  widget.lyricsService
                                      .updateLineTimestamp(index, currentTime);
                                  widget.translationService
                                      .updateLineTimestamps(
                                          widget.lyricsService.lyricLines);
                                  setState(() {});
                                } else {
                                  _lastScrolledIndex = -1;
                                  if (_studyModeService.isActive) {
                                    await _studyModeService.stop();
                                  }
                                  await widget.audioService.seek(Duration(
                                      milliseconds:
                                          (line.startTime * 1000).toInt()));
                                  // Resume study mode from the tapped line if
                                  // it was persisted as enabled.
                                  await _restartStudyIfNeeded();
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_autoScroll &&
                    !_isEditMode &&
                    Provider.of<SettingsProvider>(context).showVerticalSlider)
                  VerticalFocusOffsetSlider(
                    offset: _autoScrollFocusOffset,
                    onChanged: _onFocusOffsetChanged,
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isLandscape ? 8.0 : 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<Duration>(
                  stream: widget.audioService.player.positionStream,
                  initialData: Duration.zero,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: widget.audioService.player.durationStream,
                      initialData: Duration.zero,
                      builder: (context, durationSnapshot) {
                        final duration = durationSnapshot.data ?? Duration.zero;
                        final maxMs = duration.inMilliseconds > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1.0;
                        final valueMs = position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, maxMs);
                        return Slider(
                          value: valueMs,
                          max: maxMs,
                          onChanged: (value) {
                            if (_studyModeService.isActive) {
                              _studyModeService.stop();
                            }
                            widget.audioService
                                .seek(Duration(milliseconds: value.toInt()));
                          },
                          onChangeEnd: (_) {
                            // Resume study mode from the new position if it was
                            // persisted as enabled (small delay so the seek
                            // position settles before start() reads it).
                            _restartStudyIfNeeded(
                                delay: const Duration(milliseconds: 250));
                          },
                        );
                      },
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Кнопка-сердечко: добавить/убрать текущую песню из избранного.
                    SizedBox(
                      width: isLandscape ? 24.0 : 28.0,
                      height: isLandscape ? 24.0 : 28.0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: isLandscape ? 24.0 : 28.0,
                          height: isLandscape ? 24.0 : 28.0,
                        ),
                        iconSize: isLandscape ? 16.0 : 20.0,
                        icon: Icon(
                          _isCurrentSongFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _isCurrentSongFavorite
                              ? Colors.red
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                        ),
                        onPressed: _toggleCurrentSongFavorite,
                        tooltip: _isCurrentSongFavorite
                            ? AppLocalizations.of(context)!.removeFromFavorites
                            : AppLocalizations.of(context)!.addToFavorites,
                      ),
                    ),
                    StreamBuilder<Duration>(
                      stream: widget.audioService.player.positionStream,
                      initialData: Duration.zero,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        return Text(_formatDuration(position),
                            style:
                                TextStyle(fontSize: isLandscape ? 12 : null));
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 8.0 : 16.0),
                        child: Text(
                          _currentSong.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isLandscape ? 11 : 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                    StreamBuilder<Duration?>(
                      stream: widget.audioService.player.durationStream,
                      initialData: Duration.zero,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? Duration.zero;
                        return Text(_formatDuration(duration),
                            style:
                                TextStyle(fontSize: isLandscape ? 12 : null));
                      },
                    ),
                    // Spacer для симметрии с кнопкой-сердечком слева.
                    SizedBox(width: isLandscape ? 24.0 : 28.0),
                  ],
                ),
                SizedBox(height: isLandscape ? 4.0 : 8.0),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final availableWidth = constraints.maxWidth;
                    final baseIconSize = isLandscape ? 24.0 : 32.0;
                    final baseFabSize = 56.0;
                    final baseSpacing = isLandscape ? 8.0 : 16.0;
                    final buttonCount = 7;
                    final fabVisualSize = baseFabSize;
                    final totalSpacing = baseSpacing * 2;
                    final totalButtonWidth = buttonCount * (baseIconSize + 16) +
                        fabVisualSize +
                        totalSpacing;
                    double iconSize;
                    double fabSize;
                    double spacing;
                    if (totalButtonWidth <= availableWidth) {
                      iconSize = baseIconSize;
                      fabSize = baseFabSize;
                      spacing = baseSpacing;
                    } else {
                      final ratio = availableWidth / totalButtonWidth;
                      iconSize =
                          (baseIconSize * ratio).clamp(18.0, baseIconSize);
                      fabSize = (baseFabSize * ratio).clamp(36.0, baseFabSize);
                      spacing = (baseSpacing * ratio).clamp(4.0, baseSpacing);
                    }
                    final fabIconSize = (fabSize * 0.5).clamp(18.0, 28.0);
                    return AnimatedBuilder(
                      animation: _studyModeService,
                      builder: (context, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: _isShuffleEnabled
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: _isShuffleEnabled
                                    ? Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.shuffle,
                                  color: _isShuffleEnabled
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                  weight: _isShuffleEnabled ? 900 : 400,
                                ),
                                onPressed: _toggleShuffle,
                                tooltip: AppLocalizations.of(context)!.shuffle,
                                iconSize: iconSize,
                                padding: const EdgeInsets.all(4.0),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              onPressed:
                                  _canPlayPrevious() ? _playPreviousSong : null,
                              iconSize: iconSize,
                              padding: const EdgeInsets.all(4.0),
                            ),
                            IconButton(
                              icon: const Icon(Icons.replay_10),
                              onPressed: () {
                                final currentPosition =
                                    widget.audioService.position.inSeconds - 10;
                                widget.audioService.seek(Duration(
                                    seconds: currentPosition > 0
                                        ? currentPosition
                                        : 0));
                              },
                              iconSize: iconSize,
                              padding: const EdgeInsets.all(4.0),
                            ),
                            SizedBox(
                              width: fabSize,
                              height: fabSize,
                              child: StreamBuilder<bool>(
                                stream:
                                    widget.audioService.player.playingStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return FloatingActionButton(
                                      onPressed: null,
                                      child: Icon(Icons.circle_outlined,
                                          size: fabIconSize,
                                          color: Colors.grey),
                                    );
                                  }
                                  final isPlaying = snapshot.data ?? false;
                                  final studyActive =
                                      _studyModeService.isActive;
                                  final studyPaused =
                                      _studyModeService.isUserPaused;
                                  // Центральная кнопка — ВСЕГДА транспортная
                                  // (v5.8.6): pause, пока что-то звучит
                                  // (сегмент песни или озвучка study), play —
                                  // когда всё стоит. «Голосовой» иконки тут
                                  // больше нет: её мигание во время озвучки
                                  // создавало ощущение, что режим живёт на
                                  // кнопке плей/пауза; режим включается
                                  // отдельной верхней кнопкой.
                                  final running =
                                      (studyActive && !studyPaused) ||
                                          isPlaying;
                                  final IconData fabIconData = running
                                      ? Icons.pause
                                      : Icons.play_arrow;
                                  return FloatingActionButton(
                                    onPressed: () {
                                      _studyEvt('FAB: pressed '
                                          'studyActive=$studyActive '
                                          'studyPaused=$studyPaused '
                                          'isPlaying=$isPlaying');
                                      // Чистый транспорт (v5.8.6): единый путь
                                      // для FAB, мини-плеера, lock-screen и
                                      // уведомления. При активном study
                                      // handler.pause()/play() хендоффятся в
                                      // pauseSession()/resumeSession()
                                      // (onUserPause/onUserPlay), поэтому
                                      // пауза останавливает и музыку, и
                                      // озвучку — а не «отрабатывает» до
                                      // ближайшего kick'а.
                                      if (running) {
                                        widget.audioService.pause();
                                      } else {
                                        widget.audioService.play();
                                      }
                                    },
                                    child: Icon(fabIconData, size: fabIconSize),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.forward_10),
                              onPressed: () {
                                final currentPosition =
                                    widget.audioService.position.inSeconds + 10;
                                widget.audioService.seek(Duration(
                                    seconds: currentPosition <
                                            widget
                                                .audioService.duration.inSeconds
                                        ? currentPosition
                                        : widget
                                            .audioService.duration.inSeconds));
                              },
                              iconSize: iconSize,
                              padding: const EdgeInsets.all(4.0),
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              onPressed: _canPlayNext() ? _playNextSong : null,
                              iconSize: iconSize,
                              padding: const EdgeInsets.all(4.0),
                            ),
                            _buildLoopButton(isLandscape, iconSize: iconSize),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCurrentTranslation() async {
    final currentTranslation = widget.translationService.currentTranslation;
    if (currentTranslation == null) {
      debugPrint('No current translation to delete');
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTranslationTitle),
        content: Text(
            l10n.deleteTranslationConfirm(currentTranslation.languageName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      debugPrint(
          'Deleting translation: ${currentTranslation.languageName} (${currentTranslation.language})');

      final db = DatabaseService();
      await db.removeTranslationFile(
        _currentSong.id,
        currentTranslation.language,
        type: currentTranslation.type,
      );

      await widget.translationService.removeAndSaveTranslation(
        currentTranslation.language,
        type: currentTranslation.type,
      );

      await _updateAllLyricsWithTranslations();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10n.translationDeleted(currentTranslation.languageName)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {});
      }

      debugPrint('✓ Translation deleted successfully');
    } catch (e) {
      debugPrint('✗ Error deleting translation: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteTranslation(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
