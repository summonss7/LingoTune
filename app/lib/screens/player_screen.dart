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
import '../models/song.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart' show Translation;
import '../models/loop_mode.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
import '../services/study_mode_service.dart';
import '../services/settings_provider.dart';
import '../services/export_import_service.dart';
import '../services/database_service.dart';
import '../services/folder_config_service.dart';
import '../widgets/lyric_line_widget.dart';
import '../widgets/settings/vertical_focus_offset_slider.dart';
import 'translation_editor_screen.dart';
import 'text_loader_dialog.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../utils/lrc_formatter.dart';
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

  List<Song> get playlistSongs => widget.playlistSongs ?? [];

  @override
  bool get wantKeepAlive => true;

  void _onSettingsChanged() {
    final sp = _settingsProvider;
    if (sp != null) {
      widget.lyricsService.setPositionOffset(sp.lyricsPositionOffset);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    if (_settingsProvider != sp) {
      _settingsProvider?.removeListener(_onSettingsChanged);
      _settingsProvider = sp;
      _settingsProvider!.addListener(_onSettingsChanged);
      widget.lyricsService.setPositionOffset(sp.lyricsPositionOffset);
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
    setState(() {
      widget.audioService.toggleLoop();
      _loopMode = widget.audioService.loopMode;
    });
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
    _studyEvt('ensureTts: lang $lang NOT available (engine=${_studyModeService.activeEngine})');
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
    if (_studyModeService.isActive && !_studyModeService.isUserPaused) {
      await _studyModeService.stop(userRequested: true);
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

  static const List<double> _studySpeechRates = [
    0.3,
    0.4,
    0.5,
    0.6,
    0.7,
    0.8,
    0.9,
    1.0,
    1.1
  ];

  void _showStudyModeSettingsDialog() {
    final l10n = AppLocalizations.of(context)!;
    StudyModeOrder currentOrder = _studyModeService.order;
    double currentRate = _studyModeService.speechRate;
    OverlayTiming currentTiming = _studyModeService.overlayTiming;
    double currentDuck = _studyModeService.duckVolume;

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
                    ],
                    const Divider(),
                    Text(l10n.studyModeSpeechRate,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _studySpeechRates.map((rate) {
                        final selected = (currentRate - rate).abs() < 0.001;
                        return ChoiceChip(
                          label: Text('${rate}x'),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => currentRate = rate);
                            _studyModeService.setSpeechRate(rate);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
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
      widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
      widget.audioService,
      _playSong,
    );
  }

  Future<void> _playNextSong() async {
    if (_loopMode == LoopMode.allPlaylists) {
      await _playNextFromAllPlaylists();
      return;
    }

    await _playerPlaylistHelper.playNextSong(
      widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
      widget.audioService,
      _playSong,
      null,
    );
  }

  Future<void> _playNextFromAllPlaylists() async {
    if (widget.playlistSongs == null || widget.playlistSongs!.isEmpty) {
      return;
    }

    final currentIndex =
        widget.playlistSongs!.indexWhere((s) => s.id == _currentSong.id);

    if (currentIndex < widget.playlistSongs!.length - 1) {
      await _playSong(widget.playlistSongs![currentIndex + 1]);
    } else {
      try {
        final db = DatabaseService();
        final playlists = await db.getAllPlaylists();

        if (playlists.isEmpty) {
          return;
        }

        String currentPlaylistId = '';
        if (widget.audioService.currentPlaylist != null &&
            widget.audioService.currentPlaylist!.isNotEmpty) {
          final firstSongId = widget.audioService.currentPlaylist!.first.id;
          for (final p in playlists) {
            final pSongs = await db.getSongsInPlaylist(p.id!);
            if (pSongs.any((s) => s.id == firstSongId)) {
              currentPlaylistId = p.id!;
              break;
            }
          }
        }

        final currentPlaylistIndex =
            playlists.indexWhere((p) => p.id == currentPlaylistId);
        final nextPlaylistIndex = (currentPlaylistIndex + 1) % playlists.length;
        final nextPlaylist = playlists[nextPlaylistIndex];

        final nextPlaylistSongs = await db.getSongsInPlaylist(nextPlaylist.id!);

        if (nextPlaylistSongs.isNotEmpty) {
          widget.audioService.setCurrentPlaylist(nextPlaylistSongs);
          await _playSong(nextPlaylistSongs.first);
        }
      } catch (e) {
        debugPrint('✗ Error playing from next playlist: $e');
      }
    }
  }

  bool _canPlayPrevious() {
    return _playerPlaylistHelper.canPlayPrevious(
      widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
    );
  }

  bool _canPlayNext() {
    if (_loopMode == LoopMode.allPlaylists) {
      return true;
    }
    return _playerPlaylistHelper.canPlayNext(
      widget.playlistSongs,
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
      // Reset the lyrics scroll to the top for the new song — otherwise the
      // previous song's scroll offset leaves the new lyrics outside the
      // viewport ("текст за зоной видимости" after switching songs).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0.0);
        }
      });

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

        if (widget.playlistSongs != null && widget.playlistSongs!.isNotEmpty) {
          final currentIndex =
              widget.playlistSongs!.indexWhere((s) => s.id == song.id);
          final index = currentIndex >= 0 ? currentIndex : 0;

          await handler.setPlaylist(widget.playlistSongs!, index);
          widget.audioService.setCurrentPlaylist(widget.playlistSongs!);

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
    _playbackSpeed = widget.audioService.playbackSpeed;
    _studyModeService = StudyModeService(
        widget.audioService, widget.lyricsService, widget.translationService);
    // When study mode finishes a song naturally, trigger loop/next instead of
    // pausing (onSongComplete is guarded while study mode is active, so without
    // this the loop/repeat wouldn't fire and playback would just stop).
    _studyModeService.onStudyCompleted = _onStudySongCompleted;
    _loadSettings();
    _startPositionUpdates();

    _initSongData();

    widget.audioService.onSongComplete = () {
      if (!mounted) return;
      if (_studyModeService.isActive) {
        _studyEvt('onSongComplete: GUARDED (study active)');
        debugPrint(
            '=== Study mode active, completion handled by StudyModeService ===');
        return;
      }
      _studyEvt('onSongComplete: NOT guarded -> playNext');
      _playNextSong();
    };

    _initBackgroundAudio();
  }

  Future<void> _initSongData() async {
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
        final position =
            widget.audioService.position.inMilliseconds.toDouble() / 1000;
        widget.lyricsService.updatePosition(position);

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

      // Always rebuild so the AppBar (language indicator), translations and
      // other UI refresh even when the player hasn't reported isInitialized
      // yet (e.g. right after switching songs via the background handler).
      if (mounted) {
        setState(() {});
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
        _startPositionUpdates();
        _syncWithActuallyPlayingSong();
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isInBackground = true;
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
    _positionTimer?.cancel();
    _scrollController.dispose();
    _studyModeService.dispose();

    final handler = widget.audioService.backgroundHandler;
    if (handler != null) {
      handler.onSkipToNextRequested = null;
      handler.onSkipToPreviousRequested = null;
    }

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
    final avail = sw - 56.0 - dw - (hd ? 12.0 : 4.0);
    int cnt = 5; // study, study-settings, swap, transcription, popup
    if (_isEditMode) cnt++; // save
    final bs = (avail / cnt).clamp(18.0, 44.0);
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildStudyModeButton(iconSize: hdrBtnSize),
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
            } else if (value == 'share') {
              await _exportCurrentSong();
            } else if (value == 'editMode') {
              setState(() => _isEditMode = !_isEditMode);
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
        if (hd) SizedBox(width: 8),
        if (hd)
          Container(
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
                    width: widget.translationService.translations.length > 1
                        ? 6
                        : 0),
                DropdownButton<String>(
                  value:
                      widget.translationService.currentLanguageIndex.toString(),
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
                            content: Text(l10n
                                .languageSelected(translation.languageName)),
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
                    final isSelected = entry.key ==
                        widget.translationService.currentLanguageIndex;
                    final shortName = _getShortLanguageName(
                        translation.languageName, translation.language);
                    final emoji = _getLanguageEmoji(
                        translation.language, translation.type);
                    return DropdownMenuItem<String>(
                      value: entry.key.toString(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji,
                              style:
                                  TextStyle(fontSize: isLandscape ? 14 : 16)),
                          const SizedBox(width: 6),
                          Text(
                            shortName,
                            style: TextStyle(
                              fontSize: isLandscape ? 12 : 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
          ),
        const SizedBox(width: 4),
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
                        : localizations.repeatAllPlaylists,
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

  Widget _buildStudyModeButton({double iconSize = 32.0}) {
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
            tooltip:
                '${l10n.studyModeTooltip}\n${l10n.studyModeLongPressHint}',
            iconSize: iconSize,
            padding: const EdgeInsets.all(4.0),
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
                        'TTS engine=${s.selectedEngine ?? s.activeEngine ?? "?"} '
                        'engines=${s.availableEngines.length} '
                        'langAvail=${s.isLanguageAvailable} '
                        'speakDisabled=${s.speakDisabled}\n'
                        'EVT: $_lastStudyEvent';
                  }(),
                ),
              ),
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
                                  final currentTime = widget
                                          .audioService.position.inMilliseconds
                                          .toDouble() /
                                      1000;
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
                                  final studySpeaking =
                                      _studyModeService.isSpeaking;
                                  final IconData fabIconData;
                                  if (studyActive && studySpeaking) {
                                    fabIconData = Icons.record_voice_over;
                                  } else if (studyActive) {
                                    fabIconData = studyPaused
                                        ? Icons.play_arrow
                                        : Icons.pause;
                                  } else {
                                    fabIconData = isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow;
                                  }
                                  return FloatingActionButton(
                                    onPressed: () {
                                      _studyEvt('FAB: pressed '
                                          'studyActive=$studyActive '
                                          'studyPaused=$studyPaused '
                                          'isPlaying=$isPlaying');
                                      if (studyActive) {
                                        if (studyPaused) {
                                          _studyModeService.resumeSession();
                                        } else {
                                          _studyModeService.pauseSession();
                                        }
                                        return;
                                      }
                                      if (isPlaying) {
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
