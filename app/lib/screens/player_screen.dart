import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:audio_service/audio_service.dart' as audio_pkg;
import '../models/song.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart' show Translation;
import '../models/loop_mode.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
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

  const PlayerScreen({
    super.key,
    required this.song,
    required this.audioService,
    required this.lyricsService,
    required this.translationService,
    this.playlistSongs,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with AutomaticKeepAliveClientMixin {
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

  final PlayerTranslationHelper _playerTranslationHelper = PlayerTranslationHelper();
  final PlayerPlaylistHelper _playerPlaylistHelper = PlayerPlaylistHelper();
  final PlayerImportHelper _playerImportHelper = PlayerImportHelper();
  final PlayerExportHelper _playerExportHelper = PlayerExportHelper();

  double _autoScrollFocusOffset = 0.0;
  bool _isFirstLoad = true;

  List<Song> get playlistSongs => widget.playlistSongs ?? [];

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('=== PlayerScreen: didChangeDependencies ===');
    debugPrint('Widget song: ${widget.song.title}');
    debugPrint('Current song: ${_currentSong.title}');
    debugPrint('Lyrics lines in service: ${widget.lyricsService.lyricLines.length}');
    debugPrint('Translations in service: ${widget.translationService.translations.length}');
  
    if (_currentSong.id != widget.song.id) {
      debugPrint('=== Song ID changed, syncing ===');
      _currentSong = widget.song;
      _isShuffleEnabled = widget.audioService.isShuffleEnabled;
      _loopMode = widget.audioService.loopMode;
      _reloadSongDataWithSettings();
    } else if (widget.song.lrcPath != _currentSong.lrcPath || widget.lyricsService.lyricLines.isEmpty) {
      debugPrint('=== Reloading because lrcPath changed OR lyrics empty ===');
      _reloadSongData();
    }
  }

  Future<void> _reloadSongDataWithSettings() async {
    await _loadSettings();
    
    final prefs = await SharedPreferences.getInstance();
    final defaultOffset = prefs.getDouble('defaultAutoScrollFocusOffset') ?? 50.0;
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
    await _updateLyricsWithTranslations();
    if (mounted) setState(() {});
  }
  
  Future<void> _reloadSongData() async {
    final db = DatabaseService();
    final updatedSong = await db.getSong(_currentSong.id);
    
    if (updatedSong != null && mounted) {
      _currentSong = updatedSong;
      
      if (_currentSong.lrcPath != null && _currentSong.lrcPath!.isNotEmpty) {
        debugPrint('Reloading LRC file from DB: ${_currentSong.lrcPath}');
        await widget.lyricsService.loadLrcFile(_currentSong.lrcPath!);
      }
      
      await _loadAllTranslations(_currentSong.id, _currentSong.title);
      await _updateLyricsWithTranslations();
      if (mounted) setState(() {});
      
      debugPrint('=== Reloaded from DB ===');
      debugPrint('Lyrics after reload: ${widget.lyricsService.lyricLines.length}');
      debugPrint('Translations after reload: ${widget.translationService.translations.length}');
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    debugPrint('=== PlayerScreen: deactivate ===');
    debugPrint('Current song: ${_currentSong.title}');
    debugPrint('Translations in service before deactivate: ${widget.translationService.translations.length}');
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
    await _playerPlaylistHelper.playNextSong(
      widget.playlistSongs,
      _currentSong.id,
      _isShuffleEnabled,
      _loopMode,
      widget.audioService,
      _playSong,
    );
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
    debugPrint('=== DEBUG: _playSong called for: ${song.title} ===');
    debugPrint('Clearing old translations...');

    widget.translationService.clear();

    setState(() {
    });

    await widget.audioService.loadAudio(song.audioPath);

    if (song.lrcPath != null && song.lrcPath!.isNotEmpty) {
      await widget.lyricsService.loadLrcFile(song.lrcPath!);
    }

    setState(() {
      _currentSong = song;
    });

    debugPrint('Loading all translations for song: ${song.title}');
    await _loadAllTranslations(song.id, song.title);

    debugPrint('Translations loaded: ${widget.translationService.translations.length} total');
    for (int i = 0; i < widget.translationService.translations.length; i++) {
      final t = widget.translationService.translations[i];
      debugPrint('Translation $i: ${t.languageName} (${t.language}) type: ${t.type}');
    }

    debugPrint('Transcript available: ${widget.translationService.transcriptTranslation != null}');
    if (widget.translationService.transcriptTranslation != null) {
    debugPrint('Transcript: ${widget.translationService.transcriptTranslation!.languageName} with ${widget.translationService.transcriptTranslation!.lines.length} lines');
    }

    final prefs = await SharedPreferences.getInstance();
    final showTranscript = prefs.getBool('showTranscription') ?? false;
    debugPrint('Show transcription setting: $showTranscript');

    debugPrint('Loading saved language for song...');
    final db = DatabaseService();
    final savedLanguage = await db.getSelectedLanguage(song.id);
    debugPrint('Saved language from database: $savedLanguage');

    await _selectLanguageBasedOnSettings();

    await _updateLyricsWithTranslations();

    await widget.audioService.play();

    final handler = widget.audioService.backgroundHandler;
    if (handler != null) {
      debugPrint('=== Updating background notification for: ${song.title} ===');

      widget.audioService.setCurrentSong(song);

      if (widget.playlistSongs != null && widget.playlistSongs!.isNotEmpty) {
        final currentIndex = widget.playlistSongs!.indexWhere((s) => s.id == song.id);
        debugPrint('Calling playSong from BackgroundHandler with index: $currentIndex');

        await handler.playSong(song, currentIndex >= 0 ? currentIndex : 0);
        widget.audioService.setCurrentPlaylist(widget.playlistSongs!);
      }

      debugPrint('✓ Background notification updated');
    } else {
      debugPrint('⚠ Background handler is null, notification may not appear');
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('=== PlayerScreen: initState ===');
    debugPrint('Song: ${widget.song.title}');
    debugPrint('LRC path: ${widget.song.lrcPath}');
    debugPrint('Translations in service: ${widget.translationService.translations.length}');

    _currentSong = widget.song;
    _isShuffleEnabled = widget.audioService.isShuffleEnabled;
    _loopMode = widget.audioService.loopMode;
    _loadSettings();
    _startPositionUpdates();

    _initSongData();

    widget.audioService.onSongComplete = () {
      if (mounted) {
        _playNextSong();
      }
    };

    _initBackgroundAudio();
  }

  Future<void> _initSongData() async {
    if (widget.song.lrcPath != null && widget.song.lrcPath!.isNotEmpty) {
      debugPrint('Loading LRC file from song in initState: ${widget.song.lrcPath}');
      await widget.lyricsService.loadLrcFile(widget.song.lrcPath!);
      debugPrint('LRC loaded successfully, lyric lines count: ${widget.lyricsService.lyricLines.length}');
    }

    if (widget.translationService.translations.isEmpty) {
      debugPrint('Translations are empty in initState, loading from database...');
      await _loadAllTranslations(widget.song.id, widget.song.title);
    }

    await _updateLyricsWithTranslations();

    _autoPlay();

    if (mounted) {
      setState(() {});
      await _selectLanguageBasedOnSettings();
    }
  }

  Future<void> _initBackgroundAudio() async {
    debugPrint('=== PlayerScreen: Checking background audio ===');
    if (widget.audioService.backgroundHandler != null) {
      debugPrint('✓ Background handler is active');

      if (widget.playlistSongs != null && widget.playlistSongs!.isNotEmpty) {
        final currentIndex = widget.playlistSongs!.indexWhere((s) => s.id == widget.song.id);

        widget.audioService.setCurrentPlaylist(widget.playlistSongs!);

        await widget.audioService.backgroundHandler!.setPlaylist(
          widget.playlistSongs!,
          currentIndex >= 0 && currentIndex < widget.playlistSongs!.length ? currentIndex : 0,
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultOffset = prefs.getDouble('defaultAutoScrollFocusOffset') ?? 50.0;

    // При первом запуске - сбросить на дефолт
    if (_isFirstLoad) {
      await prefs.setDouble('autoScrollFocusOffset', defaultOffset);
      _isFirstLoad = false;
    }

    setState(() {
      _highlightNextLine = prefs.getBool('highlightNextLine') ?? true;
      _autoScroll = prefs.getBool('autoScroll') ?? true;
      _autoScrollFocusOffset = prefs.getDouble('autoScrollFocusOffset') ?? 50.0;
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
    );
  }


  void _scrollToCurrentLine() {
    final currentIndex = widget.lyricsService.currentIndex;
    final totalLines = widget.lyricsService.lyricLines.length;

    if (currentIndex >= 0 && currentIndex < totalLines) {
      if (currentIndex == _lastScrolledIndex) return;
      _lastScrolledIndex = currentIndex;

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
              final viewportBox = scrollable.context.findRenderObject() as RenderBox;
              final itemScreenPos = renderBox.localToGlobal(Offset.zero);
              final itemRelativeY = viewportBox.globalToLocal(itemScreenPos).dy;
              final itemAbsolute = _scrollController.offset + itemRelativeY;
              final maxExtent = _scrollController.position.maxScrollExtent;
              final targetOffset = (itemAbsolute - scrollOffset + focusOffset)
                  .clamp(0.0, maxExtent);

              await _scrollController.animateTo(
                targetOffset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
            return;
          }
        }

        final maxExtent = _scrollController.position.maxScrollExtent;
        if (totalLines > 1 && maxExtent > 0) {
          final avgHeight = maxExtent / totalLines;
          final jumpTarget = (avgHeight * currentIndex - avgHeight * 2)
              .clamp(0.0, maxExtent);

          await _scrollController.animateTo(
            jumpTarget,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );

          if (!mounted) return;
          if (currentIndex < _lineKeys.length) {
            final keyContext = _lineKeys[currentIndex].currentContext;
            if (keyContext != null) {
              final renderBox = keyContext.findRenderObject() as RenderBox;
              final scrollable = Scrollable.of(keyContext);
              if (scrollable != null) {
                final viewportBox = scrollable.context.findRenderObject() as RenderBox;
                final itemScreenPos = renderBox.localToGlobal(Offset.zero);
                final itemRelativeY = viewportBox.globalToLocal(itemScreenPos).dy;
                final itemAbsolute = _scrollController.offset + itemRelativeY;
                final maxExtent2 = _scrollController.position.maxScrollExtent;
                final targetOffset = (itemAbsolute - scrollOffset + focusOffset)
                    .clamp(0.0, maxExtent2);

                await _scrollController.animateTo(
                  targetOffset,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
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
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (widget.audioService.isInitialized) {
        final position = widget.audioService.position.inMilliseconds.toDouble() / 1000;
        widget.lyricsService.updatePosition(position);

        final prefs = await SharedPreferences.getInstance();
        final showTranscript = prefs.getBool('showTranscription') ?? false;

        final currentLineIndex = widget.lyricsService.currentIndex;
        final currentLangIndex = widget.translationService.currentLanguageIndex;
        final needsTranslationUpdate = currentLineIndex != _lastProcessedIndex ||
            currentLangIndex != _lastProcessedLanguageIndex ||
            showTranscript != _cachedShowTranscription;

        _cachedShowTranscription = showTranscript;

        if (needsTranslationUpdate) {
          _lastProcessedIndex = currentLineIndex;
          _lastProcessedLanguageIndex = currentLangIndex;
          await _updateLyricsWithTranslations();
        }

        if (_autoScroll && !_isEditMode) {
          _scrollToCurrentLine();
        }

        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _scrollController.dispose();
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
        debugPrint('=== Dialog closed with result=true, reloading song data ===');
        final db = DatabaseService();
        
        // Перезагружаем данные песни из базы данных
        final updatedSong = await db.getSong(_currentSong.id);
        
        if (updatedSong != null) {
          debugPrint('=== Updated song loaded from DB ===');
          debugPrint('Updated song lrcPath: ${updatedSong!.lrcPath}');
          debugPrint('Updated song originalLanguage: ${updatedSong!.originalLanguage}');
          
          // Обновляем текущую песню
          _currentSong = updatedSong!;
          
          // Если есть LRC файл, загружаем его
          if (updatedSong!.lrcPath != null && updatedSong!.lrcPath!.isNotEmpty) {
            debugPrint('Loading LRC file: ${updatedSong!.lrcPath}');
            await widget.lyricsService.loadLrcFile(updatedSong!.lrcPath!);
            debugPrint('LRC loaded, lyric lines count: ${widget.lyricsService.lyricLines.length}');
          }
          
          // Загружаем все переводы для песни
          await _loadAllTranslations(_currentSong.id, _currentSong.title);
          
          // Применяем переводы к текущим строкам
          await _updateLyricsWithTranslations();
          
          // Обновляем состояние UI
          setState(() {});
          
          debugPrint('=== After reloading ===');
          debugPrint('Lyrics lines: ${widget.lyricsService.lyricLines.length}');
          debugPrint('Translations: ${widget.translationService.translations.length}');
          
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final sw = MediaQuery.of(context).size.width;
    final hd = widget.translationService.translations.isNotEmpty;
    final dw = hd ? sw * 0.22 : 0.0;
    final avail = sw - 56.0 - dw - (hd ? 12.0 : 4.0);
    int cnt = 5;
    if (!_isEditMode) cnt++;
    if (_isEditMode) cnt++;
    final bs = (avail / cnt).clamp(18.0, 44.0);
    final iconSz = (bs * 0.72).clamp(12.0, 24.0);

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
        if (!_isEditMode)
          btn(
            _autoScroll ? Icons.play_arrow : Icons.pause,
            () => setState(() => _autoScroll = !_autoScroll),
            color: _autoScroll ? Colors.green : Colors.grey,
          ),
        btn(Icons.share, _exportCurrentSong),
        btn(
          _isEditMode ? Icons.edit_off : Icons.edit_note,
          () => setState(() => _isEditMode = !_isEditMode),
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
            await _updateLyricsWithTranslations();
            setState(() {});
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(!show ? l10n.transcriptionEnabled : l10n.transcriptionDisabled),
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
            if (value == 'edit') {
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
                await _updateLyricsWithTranslations();
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
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 20),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.editTranslations),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'add',
              child: Row(
                children: [
                  const Icon(Icons.archive, size: 20),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.loadTranslationsFromFile),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'loadText',
              child: Row(
                children: [
                  const Icon(Icons.description, size: 20),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.loadTextMenu),
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
                    Text(AppLocalizations.of(context)!.deleteTranslation),
                  ],
                ),
              ),
          ],
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
                SizedBox(width: widget.translationService.translations.length > 1 ? 6 : 0),
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
                      final translation = widget.translationService.translations[index];
                      final db = DatabaseService();
                      await db.setSelectedLanguage(_currentSong.id, translation.language);
                      await _updateLyricsWithTranslations();
                      if (mounted) {
                        final l10n = AppLocalizations.of(context)!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.languageSelected(translation.languageName)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                      setState(() { });
                    }
                  },
                  items: widget.translationService.translations.asMap().entries.map((entry) {
                    final translation = entry.value;
                    final isSelected = entry.key == widget.translationService.currentLanguageIndex;
                    final shortName = _getShortLanguageName(translation.languageName, translation.language);
                    final emoji = _getLanguageEmoji(translation.language, translation.type);
                    return DropdownMenuItem<String>(
                      value: entry.key.toString(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: TextStyle(fontSize: isLandscape ? 14 : 16)),
                          const SizedBox(width: 6),
                          Text(
                            shortName,
                            style: TextStyle(
                              fontSize: isLandscape ? 12 : 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, size: isLandscape ? 14 : 16, color: Theme.of(context).colorScheme.primary),
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
      child: IconButton(
        icon: Icon(
          icon,
          color: color,
          weight: isLoopEnabled ? 900 : 400,
        ),
        onPressed: _toggleLoop,
        tooltip: localizations.repeat,
        iconSize: iconSize,
      ),
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
        final zipPath = (result.files.single.path ?? result.files.single.identifier) as String;
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
        await _updateLyricsWithTranslations();
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
        await _updateLyricsWithTranslations();
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
            backgroundColor: translationsAdded > 0 || lrcFound > 0 ? Colors.green : Colors.orange,
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

  Future<Map<String, dynamic>> _scanTranslationsForSong(List<String> extractedFiles) async {
    try {
      debugPrint('=== Scanning translations for song: ${widget.song.title} ===');
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

        if (fileName.endsWith('.lrc') || fileName.toLowerCase().endsWith('.lrc')) {
          lrcPathToSave = filePath;
          lrcFound++;
          debugPrint('  ✓ Found LRC file: "$fileName"');
        } else if (fileName.endsWith('.json') || fileName.toLowerCase().endsWith('.json')) {
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

            if (!data.containsKey('translations') || data['translations'] == null) {
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

                final language = translationData['language'] as String? ?? 'unknown';
                final languageName = translationData['languageName'] as String? ?? 'Unknown';
                final type = translationData['type'] as String?;

                debugPrint('  Translation found: $languageName ($language) type: $type');

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

      debugPrint('=== Translation scan completed for song: ${widget.song.title} ===');
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
      debugPrint('✗ Fatal error scanning translations for song ${widget.song.title}: $e');
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

  Future<void> _loadTranslationFile(File file, String languageName, String? type) async {
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
        debugPrint('✓ Added translation: ${translation.languageName} (${translation.language})');
      }
      
      _updateLyricsWithTranslations();
      
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

      if (widget.translationService.translations.isNotEmpty || widget.translationService.transcriptTranslation != null) {
        widget.translationService.updateLineTimestamps(widget.lyricsService.lyricLines);
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
                          if (mounted && _lineKeys.length < widget.lyricsService.lyricLines.length) {
                            setState(() {
                              while (_lineKeys.length < widget.lyricsService.lyricLines.length) {
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
                          final isCurrent = index == widget.lyricsService.currentIndex;
                          final isNext = _highlightNextLine && index == widget.lyricsService.currentIndex + 1;

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
                                  final currentTime = widget.audioService.position.inMilliseconds.toDouble() / 1000;
                                  widget.lyricsService.updateLineTimestamp(index, currentTime);
                                  widget.translationService.updateLineTimestamps(widget.lyricsService.lyricLines);
                                  setState(() {});
                                } else {
                                  _lastScrolledIndex = -1;
                                  widget.audioService.seek(Duration(milliseconds: (line.startTime * 1000).toInt()));
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_autoScroll && !_isEditMode && Provider.of<SettingsProvider>(context).showVerticalSlider)
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
                        return Slider(
                          value: position.inMilliseconds.toDouble(),
                          max: duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            widget.audioService.seek(Duration(milliseconds: value.toInt()));
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
                          return Text(_formatDuration(position), style: TextStyle(fontSize: isLandscape ? 12 : null));
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isLandscape ? 8.0 : 16.0),
                          child: Text(
                            _currentSong.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isLandscape ? 11 : 13,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      StreamBuilder<Duration?>(
                        stream: widget.audioService.player.durationStream,
                        initialData: Duration.zero,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          return Text(_formatDuration(duration), style: TextStyle(fontSize: isLandscape ? 12 : null));
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
                    final totalButtonWidth = buttonCount * (baseIconSize + 16) + fabVisualSize + totalSpacing;
                    double iconSize;
                    double fabSize;
                    double spacing;
                    if (totalButtonWidth <= availableWidth) {
                      iconSize = baseIconSize;
                      fabSize = baseFabSize;
                      spacing = baseSpacing;
                    } else {
                      final ratio = availableWidth / totalButtonWidth;
                      iconSize = (baseIconSize * ratio).clamp(18.0, baseIconSize);
                      fabSize = (baseFabSize * ratio).clamp(36.0, baseFabSize);
                      spacing = (baseSpacing * ratio).clamp(4.0, baseSpacing);
                    }
                    final fabIconSize = (fabSize * 0.5).clamp(18.0, 28.0);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _isShuffleEnabled 
                                ? Theme.of(context).colorScheme.primaryContainer 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: _isShuffleEnabled
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
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
                          onPressed: _canPlayPrevious() ? _playPreviousSong : null,
                          iconSize: iconSize,
                          padding: const EdgeInsets.all(4.0),
                        ),
                        IconButton(
                          icon: const Icon(Icons.replay_10),
                          onPressed: () {
                            final currentPosition =
                                widget.audioService.position.inSeconds - 10;
                            widget.audioService.seek(Duration(
                                seconds: currentPosition > 0 ? currentPosition : 0));
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
                            initialData: false,
                            builder: (context, snapshot) {
                              final isPlaying = snapshot.data ?? false;
                              return FloatingActionButton(
                                onPressed: () {
                                  if (isPlaying) {
                                    widget.audioService.pause();
                                  } else {
                                    widget.audioService.play();
                                  }
                                },
                                child: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: fabIconSize),
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
                                seconds: currentPosition < widget.audioService.duration.inSeconds
                                    ? currentPosition
                                    : widget.audioService.duration.inSeconds));
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
        content: Text(l10n.deleteTranslationConfirm(currentTranslation.languageName)),
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
      debugPrint('Deleting translation: ${currentTranslation.languageName} (${currentTranslation.language})');

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

      await _updateLyricsWithTranslations();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translationDeleted(currentTranslation.languageName)),
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
