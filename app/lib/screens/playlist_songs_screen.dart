import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart' show Translation;
import '../services/playlist_service.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
import '../services/cover_art_service.dart';
import '../services/database_service.dart';
import '../services/settings_provider.dart';
import '../services/export_import_service.dart';
import '../services/folder_config_service.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import 'player_screen.dart';
import 'lyric_generator_dialog.dart';
import 'helpers/cover_art_helper.dart';
import 'helpers/playlist_import_helper.dart';
import 'helpers/song_translation_loader.dart';
import '../widgets/mini_player_widget.dart';

class PlaylistSongsScreen extends StatefulWidget {
  final Playlist playlist;
  final AudioService audioService;
  final LyricsService lyricsService;
  final TranslationService translationService;

  const PlaylistSongsScreen({
    super.key,
    required this.playlist,
    required this.audioService,
    required this.lyricsService,
    required this.translationService,
  });

  @override
  State<PlaylistSongsScreen> createState() => _PlaylistSongsScreenState();
}

class _PlaylistSongsScreenState extends State<PlaylistSongsScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  final CoverArtHelper _coverArtHelper = CoverArtHelper();
  final PlaylistImportHelper _playlistImportHelper = PlaylistImportHelper();
  final SongTranslationLoader _songTranslationLoader = SongTranslationLoader();

  List<Song> _songs = [];
  bool _isLoading = true;
  bool _isReorderMode = false;
  bool _isSelectionMode = false;
  final Map<String, Song> _selectedSongs = {};
  bool _isImporting = false;
  bool _isRefreshing = false;
  String _sortBy = 'default';
  final Map<String, Color> _buttonColorsCache = {};

  /// Локальная копия плейлиста: переименование обновляет заголовок AppBar,
  /// не пересоздавая экран (widget.playlist иммутабелен).
  late Playlist _playlist = widget.playlist;

  /// Множество id песен, входящих в системный плейлист `favorites`. Нужно,
  /// чтобы рисовать заполненное/пустое сердечко на каждой строке списка.
  Set<String> _favoriteSongIds = {};

  final ScrollController _scrollController = ScrollController();
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _loadSortPreference();
    _loadSongs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentSong() {
    if (_didInitialScroll) return;
    final currentSongId = widget.audioService.currentSongIdNotifier.value;
    if (currentSongId == null || _songs.isEmpty) return;
    final index = _songs.indexWhere((s) => s.id == currentSongId);
    if (index < 0) return;

    _didInitialScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) return;
      final avgHeight = maxExtent / _songs.length;
      final target = (index * avgHeight - 2 * avgHeight).clamp(0.0, maxExtent);
      _scrollController.jumpTo(target);
    });
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortBy = prefs.getString('playlistSortBy_${widget.playlist.id}') ?? 'default';
      _isReorderMode = prefs.getBool('reorderMode_${widget.playlist.id}') ?? false;
    });
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final songs = await _playlistService.getSongsInPlaylist(widget.playlist.id);

      // Грузим множество id избранных (один запрос), чтобы рисовать сердечко.
      Set<String> favIds = {};
      if (widget.playlist.id != 'favorites') {
        try {
          final favSongs =
              await _playlistService.getSongsInPlaylist('favorites');
          favIds = favSongs.map((s) => s.id).toSet();
        } catch (e) {
          debugPrint('⚠ Could not load favorites ids: $e');
        }
      }

      setState(() {
        _songs = songs;
        _favoriteSongIds = favIds;
        _isLoading = false;
      });

      _applySorting();
      await _checkTimestampsValidity();
      _scrollToCurrentSong();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToLoadSongsMsg(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkTimestampsValidity() async {
    for (final song in _songs) {
      if (song.hasLyrics && song.lrcPath != null) {
        final hasValidTimestamps = await LyricsService.hasValidTimestamps(song.lrcPath);
        if (hasValidTimestamps) {
          _buttonColorsCache[song.id] = Theme.of(context).colorScheme.primary;
        } else {
          _buttonColorsCache[song.id] = Colors.purple;
        }
      } else {
        _buttonColorsCache[song.id] = Colors.deepOrange;
      }
    }
    setState(() {});
  }

  Color _getGeneratorButtonColor(Song song) {
    if (_buttonColorsCache.containsKey(song.id)) {
      return _buttonColorsCache[song.id]!;
    }
    
    if (!song.hasLyrics) {
      return Colors.deepOrange;
    }
    
    return Theme.of(context).colorScheme.primary;
  }

  void _applySorting() {
    switch (_sortBy) {
      case 'alphabetical_asc':
        _songs.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'alphabetical_desc':
        _songs.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case 'date_asc':
        _songs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'date_desc':
        _songs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'default':
      default:
        break;
    }
  }

  Future<void> _editCoverArt(Song song) async {
    await _coverArtHelper.editCoverArt(
      context,
      song,
      (callback) => setState(() {
        if (callback is Function) callback();
      }),
      _songs,
    );
  }

  Future<void> _removeSong(Song song) async {
    try {
      await _playlistService.removeSongFromPlaylist(widget.playlist.id, song.id);
      await _loadSongs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToRemoveSongMsg(e.toString()))),
        );
      }
    }
  }

  /// Добавляет/убирает песню из системного плейлиста `favorites` и обновляет
  /// локальное множество [_favoriteSongIds] (без полной перезагрузки списка).
  Future<void> _toggleFavorite(Song song) async {
    try {
      final isFav = _favoriteSongIds.contains(song.id);
      if (isFav) {
        await _playlistService.removeSongFromPlaylist('favorites', song.id);
        debugPrint('💔 Removed from favorites: ${song.title}');
      } else {
        await _playlistService.addSongToPlaylist('favorites', song.id);
        debugPrint('❤ Added to favorites: ${song.title}');
      }
      setState(() {
        if (isFav) {
          _favoriteSongIds.remove(song.id);
        } else {
          _favoriteSongIds.add(song.id);
        }
      });
    } catch (e) {
      debugPrint('✗ Error toggling favorite: $e');
    }
  }

  /// Кнопка-сердечко для строки песни. Не показывается, если текущий
  /// плейлист сам является `favorites` (там сердечко избыточно — там есть
  /// кнопка удаления).
  Widget _buildFavoriteButton(Song song, AppLocalizations l10n) {
    final isFav = _favoriteSongIds.contains(song.id);
    return IconButton(
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : null,
      ),
      onPressed: () => _toggleFavorite(song),
      tooltip: isFav ? l10n.removeFromFavorites : l10n.addToFavorites,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    setState(() {
      final song = _songs.removeAt(oldIndex);
      _songs.insert(newIndex, song);
    });

    _playlistService.updatePlaylistSongsOrder(widget.playlist.id, _songs).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToReorderSongsMsg(e.toString()))),
        );
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedSongs.clear();
      }
    });
  }

  void _toggleSongSelection(Song song) {
    setState(() {
      if (_selectedSongs.containsKey(song.id)) {
        _selectedSongs.remove(song.id);
      } else {
        _selectedSongs[song.id] = song;
      }
    });
  }

  void _sortSongs(String sortBy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playlistSortBy_${widget.playlist.id}', sortBy);
    setState(() {
      _sortBy = sortBy;
    });
    if (sortBy == 'default') {
      _loadSongs();
    } else {
      _applySorting();
    }
  }

  Future<void> _renamePlaylist() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _playlist.name);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.renamePlaylistTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          decoration: InputDecoration(
            labelText: l10n.playlistNameLabel,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    final newName = (result ?? '').trim();
    if (newName.isEmpty || newName == _playlist.name) return;

    try {
      // Дубль имени запутает пользователя в списке плейлистов — не даём.
      final all = await _playlistService.getAllPlaylists();
      final duplicate = all.any((p) =>
          p.id != _playlist.id &&
          p.name.toLowerCase() == newName.toLowerCase());
      if (duplicate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.playlistNameExists),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final ok = await _playlistService.renamePlaylist(_playlist.id, newName);
      if (!ok) return;
      setState(() {
        _playlist = _playlist.copyWith(name: newName);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.playlistRenamed),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error renaming playlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSelectedSongsFromPlaylist() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      for (var song in _selectedSongs.values) {
        await _playlistService.removeSongFromPlaylist(widget.playlist.id, song.id);
      }
      setState(() {
        for (var song in _selectedSongs.values) {
          _songs.remove(song);
        }
         _isSelectionMode = false;
         _selectedSongs.clear();
       });
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(l10n.removedSongsFromPlaylist),
             backgroundColor: Colors.green,
           ),
         );
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('${l10n.failedToRemoveSongs} $e'),
             backgroundColor: Colors.red,
           ),
         );
       }
     }
  }

  Future<void> _addSongsFromLibrary() async {
    final l10n = AppLocalizations.of(context)!;
    final allSongs = await _databaseService.getAllSongs();
    final playlistSongs = await _playlistService.getSongsInPlaylist(widget.playlist.id);
    final playlistSongIds = playlistSongs.map((s) => s.id).toSet();

    final availableSongs = allSongs.where((s) => !playlistSongIds.contains(s.id)).toList();

    if (!mounted) return;

    final Map<String, Song> selectedSongs = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addSongsToLibrary),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: availableSongs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_note, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(l10n.noSongsToAdd, style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (selectedSongs.length == availableSongs.length) {
                                  selectedSongs.clear();
                                } else {
                                  for (var song in availableSongs) {
                                    selectedSongs[song.id] = song;
                                  }
                                }
                              });
                            },
                            child: Text(selectedSongs.length == availableSongs.length ? l10n.deselectAll : l10n.selectAll),
                          ),
                          const Spacer(),
                          Text('${selectedSongs.length} ${l10n.selected}'),
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: availableSongs.length,
                          itemBuilder: (context, index) {
                            final song = availableSongs[index];
                            final isSelected = selectedSongs.containsKey(song.id);
                            return ListTile(
                              leading: CoverArtService.buildCoverArtWidget(
                                title: song.title,
                                coverArtPath: song.coverArtPath,
                                coverArtVersion: song.coverArtVersion,
                                size: 40,
                              ),
                              title: Text(song.title, style: const TextStyle(fontSize: 14)),
                              subtitle: Text(song.artist, style: const TextStyle(fontSize: 12)),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : null,
                              onTap: () {
                                setState(() {
                                  if (selectedSongs.containsKey(song.id)) {
                                    selectedSongs.remove(song.id);
                                  } else {
                                    selectedSongs[song.id] = song;
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: selectedSongs.isEmpty ? null : () async {
                try {
                  for (var song in selectedSongs.values) {
                    await _playlistService.addSongToPlaylist(widget.playlist.id, song.id);
                  }
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.addedSongsToPlaylistMsg(selectedSongs.length, widget.playlist.name)),
                        backgroundColor: Colors.green,
                      ),
                    );
                    await _loadSongs();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.failedToAddSongsMsg(e.toString())),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.addSongsButton(selectedSongs.length)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playSong(Song song) async {
    try {
      debugPrint('=== DEBUG: PlaylistSongsScreen - _playSong for ${song.title} ===');
      
      widget.lyricsService.clear();
      widget.translationService.clear();

      await _loadAllTranslationsForPlayer(song);

      if (song.lrcPath != null && song.lrcPath!.isNotEmpty) {
        debugPrint('Loading LRC file from: ${song.lrcPath}');
        await widget.lyricsService.loadLrcFile(song.lrcPath!);
        debugPrint('LRC file loaded successfully, lyric lines count: ${widget.lyricsService.lyricLines.length}');
      } else {
        debugPrint('No LRC file to load - lrcPath is null or empty');
      }

      debugPrint('Loading audio from: ${song.audioPath}');
      await widget.audioService.loadAudio(song.audioPath);
      debugPrint('Audio loaded successfully');

      if (!mounted) return;

      debugPrint('Navigating to player screen...');
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            audioService: widget.audioService,
            lyricsService: widget.lyricsService,
            translationService: widget.translationService,
            song: song,
            playlistSongs: _songs,
          ),
        ),
      );
      
      await _loadSongs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToPlaySongMsg(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadAllTranslationsForPlayer(Song song) async {
    await _songTranslationLoader.loadAllTranslationsForPlayer(
      context,
      song,
      widget.translationService,
    );
  }

  Future<void> _scanAndAddTranslationsForPlayer(String songId, String songName) async {
    await _songTranslationLoader.scanAndAddTranslationsForPlayer(
      context,
      songId,
      songName,
      widget.translationService,
    );
  }

  Future<void> _refreshFolderPlaylist() async {
    if (widget.playlist.musicFolderPath == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    final bool? onlySongsResult = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.refreshFolder),
        content: Text(l10n.refreshDialogDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.refreshOnlySongs),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.refreshEverything),
          ),
        ],
      ),
    );

    if (onlySongsResult == null) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final result = await Navigator.of(context).push<FolderRefreshResult>(
        MaterialPageRoute(
          builder: (context) => _RefreshProgressDialog(
            playlist: widget.playlist,
            onlySongs: onlySongsResult,
            l10n: l10n,
          ),
        ),
      );

      if (result != null) {
        await _loadSongs();

        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.refreshedPlaylist(result.totalSongs)),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.refreshPlaylistError(result.error)),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.refreshPlaylistError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Widget _buildSongList() {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<String?>(
      valueListenable: widget.audioService.currentSongIdNotifier,
      builder: (context, currentSongId, _) {
        return ReorderableListView.builder(
          scrollController: _scrollController,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                return Transform.translate(
                  offset: Offset(0, 50 * animation.value),
                  child: child,
                );
              },
              child: child,
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (_isReorderMode) {
              _onReorder(oldIndex, newIndex);
            }
          },
          padding: const EdgeInsets.all(16),
          itemCount: _songs.length,
          itemBuilder: (context, index) {
            final song = _songs[index];
            final isSelected = _selectedSongs.containsKey(song.id);
            final isCurrentlyPlaying = song.id == currentSongId;
            return Card(
              key: ValueKey(song.id),
              margin: const EdgeInsets.only(bottom: 8),
              color: isCurrentlyPlaying
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                  : null,
              shape: isCurrentlyPlaying
                  ? RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    )
                  : null,
              child: ListTile(
                leading: _isSelectionMode
                    ? Checkbox(
                        value: isSelected,
                        onChanged: (_) => _toggleSongSelection(song),
                      )
                    : Stack(
                        children: [
                          CoverArtService.buildCoverArtWidget(
                            title: song.title,
                            coverArtPath: song.coverArtPath,
                            coverArtVersion: song.coverArtVersion,
                            size: 56,
                          ),
                          if (isCurrentlyPlaying)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.graphic_eq,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                          if (!widget.playlist.isSystem)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _editCoverArt(song),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCurrentlyPlaying
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                subtitle: Text(song.artist),
                trailing: _isSelectionMode
                    ? null
                    : _isReorderMode
                        ? const Icon(Icons.drag_handle)
                        // Плейлист `favorites` ведёт себя как редактируемый
                        // (remove вместо play_arrow — удалить из избранного =
                        // убрать из этого плейлиста). Сердечко в нём не
                        // показываем, т.к. оно там избыточно.
                        : (!widget.playlist.isSystem ||
                                widget.playlist.id == 'favorites')
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.playlist.id != 'favorites')
                                    _buildFavoriteButton(song, l10n),
                                  IconButton(
                                    icon: Icon(Icons.auto_awesome,
                                        color: _getGeneratorButtonColor(song)),
                                    onPressed: () => _showGenerateDialog(song),
                                    tooltip: l10n.generateLyrics,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () => _removeSong(song),
                                    color: Colors.red,
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildFavoriteButton(song, l10n),
                                  IconButton(
                                    icon: Icon(Icons.auto_awesome,
                                        color: _getGeneratorButtonColor(song)),
                                    onPressed: () => _showGenerateDialog(song),
                                    tooltip: l10n.generateLyrics,
                                  ),
                                  const Icon(Icons.play_arrow),
                                ],
                              ),
                onTap: _isSelectionMode ? () => _toggleSongSelection(song) : () => _playSong(song),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
       return Scaffold(
        appBar: AppBar(
        title: _isSelectionMode
            ? Text(l10n.selectedSongsCount(_selectedSongs.length))
            : Text(_playlist.name),
        elevation: 0,
        actions: _isSelectionMode
            ? [
                TextButton.icon(
                  onPressed: _selectedSongs.isNotEmpty ? _deleteSelectedSongsFromPlaylist : null,
                  icon: const Icon(Icons.remove_circle),
                  label: Text(AppLocalizations.of(context)!.removeSong),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedSongs.length == _songs.length) {
                        _selectedSongs.clear();
                      } else {
                        for (var song in _songs) {
                          _selectedSongs[song.id] = song;
                        }
                      }
                    });
                  },
                   child: Text(_selectedSongs.length == _songs.length ? l10n.deselectAll : l10n.selectAll),
                ),
                 IconButton(
                   icon: const Icon(Icons.close),
                   onPressed: _toggleSelectionMode,
                   tooltip: l10n.exitSelectionMode,
                 ),
               ]
               : [
                  if (widget.playlist.musicFolderPath != null)
                    IconButton(
                      icon: _isRefreshing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      onPressed: _isRefreshing ? null : _refreshFolderPlaylist,
                      tooltip: l10n.refreshFolder,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _isImporting ? null : _importSong,
                      tooltip: l10n.importSong,
                    ),
                 IconButton(
                   icon: const Icon(Icons.playlist_add),
                   onPressed: _isImporting ? null : _addSongsFromLibrary,
                   tooltip: l10n.addSongsToLibrary,
                 ),
                 PopupMenuButton<String>(
                   icon: const Icon(Icons.sort_by_alpha),
                   tooltip: l10n.sortSongs,
                   onSelected: (value) {
                     if (value == 'rename') {
                       _renamePlaylist();
                     } else {
                       _sortSongs(value);
                     }
                   },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'default',
                      child: Text('📋 ${l10n.sortDefault}'),
                    ),
                    PopupMenuItem(
                      value: 'alphabetical_asc',
                      child: Text('🔤 ${l10n.sortAlphabeticalAsc}'),
                    ),
                    PopupMenuItem(
                      value: 'alphabetical_desc',
                      child: Text('🔤 ${l10n.sortAlphabeticalDesc}'),
                    ),
                    PopupMenuItem(
                      value: 'date_desc',
                      child: Text('📅 ${l10n.sortDateDesc}'),
                    ),
                    PopupMenuItem(
                      value: 'date_asc',
                      child: Text('📅 ${l10n.sortDateAsc}'),
                    ),
                    if (!widget.playlist.isSystem) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'rename',
                        child: Text('✏️ ${l10n.renamePlaylist}'),
                      ),
                    ],
                  ],
                ),
                if (!widget.playlist.isSystem)
                  IconButton(
                    icon: Icon(_isReorderMode ? Icons.check : Icons.sort),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final newValue = !_isReorderMode;
                      await prefs.setBool('reorderMode_${widget.playlist.id}', newValue);
                      setState(() {
                         _isReorderMode = newValue;
                       });
                     },
                     tooltip: _isReorderMode ? l10n.done : l10n.reorder,
                   ),
                 IconButton(
                   icon: const Icon(Icons.checklist),
                   onPressed: _toggleSelectionMode,
                   tooltip: l10n.selectMultiple,
                 ),
              ],
      ),
      body: Column(
        children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
             : _isImporting
                 ? Center(
                      child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           const CircularProgressIndicator(),
                           const SizedBox(height: 16),
                           Text(l10n.importingSongs),
                         ],
                       ),
                    )
                : _songs.isEmpty
                    ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noSongsInPlaylist,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.addSongsFromLibraryHint,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                             ),
                        ),
                      ],
                    ),
                  )
                : _buildSongList(),
           ),
           ListenableBuilder(
            listenable: widget.audioService,
            builder: (context, _) => MiniPlayerWidget(
              audioService: widget.audioService,
              onTap: _openCurrentPlayer,
              onPlayPause: _togglePlayback,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showGenerateDialog(Song song) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final apiKey = settingsProvider.deepseekApiKey;

    if (apiKey == null || apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseSetDeepSeekApiKey),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => LyricGeneratorDialog(
        song: song,
        apiKey: apiKey,
        prompt: settingsProvider.deepseekPrompt,
        timeout: settingsProvider.deepseekTimeout,
        model: settingsProvider.deepseekModel,
        promptPreset: settingsProvider.selectedPromptPreset,
        maxTokensRegular: settingsProvider.deepseekMaxTokensRegular,
        maxTokensJson: settingsProvider.deepseekMaxTokensJson,
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.lyricsGeneratedSuccessfullyMsg)),
      );
      await _loadSongs();
    }
  }

  Future<void> _togglePlayback() async {
    try {
      final isPlaying = await widget.audioService.player.playingStream.first;
      if (isPlaying) {
        await widget.audioService.pause();
      } else {
        if (widget.audioService.isInitialized) {
          await widget.audioService.play();
        }
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
    }
  }

  Future<void> _openCurrentPlayer() async {
    final song = widget.audioService.currentSong;
    if (song == null || !widget.audioService.hasActiveSong) return;

    try {
      final db = DatabaseService();
      final updatedSong = await db.getSong(song.id);
      if (updatedSong == null) return;

      if (widget.lyricsService.lyricLines.isEmpty && updatedSong.lrcPath != null && updatedSong.lrcPath!.isNotEmpty) {
        await widget.lyricsService.loadLrcFile(updatedSong.lrcPath!);
      }

      if (widget.translationService.translations.isEmpty) {
        final translationFiles = await db.getTranslationFiles(song.id);
        for (final tf in translationFiles) {
          final filePath = tf['filePath'] as String;
          final language = tf['language'] as String;
          final languageName = tf['languageName'] as String;
          final type = tf['type'] as String?;

          try {
            final file = File(filePath);
            if (await file.exists()) {
              final content = await file.readAsString();
              final data = json.decode(content) as Map<String, dynamic>;
              if (data.containsKey('translations')) {
                final translations = data['translations'] as List;
                for (final t in translations) {
                  final translationData = t as Map<String, dynamic>;
                  final lines = (translationData['lines'] as List?)
                      ?.map((l) => LyricLine.fromJson(l as Map<String, dynamic>))
                      .toList() ?? [];
                  widget.translationService.addTranslation(Translation(
                    language: language,
                    languageName: languageName,
                    type: type,
                    lines: lines,
                    filePath: filePath,
                  ));
                }
              }
            }
          } catch (e) {
            debugPrint('Error loading translation for resume: $e');
          }
        }
      }

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(
            song: updatedSong,
            audioService: widget.audioService,
            lyricsService: widget.lyricsService,
            translationService: widget.translationService,
            playlistSongs: widget.audioService.currentPlaylist,
            shouldResume: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error opening current player: $e');
    }
  }

  Future<void> _importSong() async {
    await _playlistImportHelper.importSong(
      context,
      widget.playlist,
      (callback) => setState(() {
        if (callback is Function) callback();
      }),
      _songs,
    );
  }
}

class _RefreshProgressDialog extends StatefulWidget {
  final Playlist playlist;
  final bool onlySongs;
  final AppLocalizations l10n;

  const _RefreshProgressDialog({
    required this.playlist,
    required this.onlySongs,
    required this.l10n,
  });

  @override
  State<_RefreshProgressDialog> createState() => _RefreshProgressDialogState();
}

class _RefreshProgressDialogState extends State<_RefreshProgressDialog> {
  final PlaylistService _playlistService = PlaylistService();
  double _progressValue = 0.0;
  String _progressText = '';
  FolderRefreshResult? _result;

  @override
  void initState() {
    super.initState();
    _performRefresh();
  }

  Future<void> _performRefresh() async {
    try {
      _result = await _playlistService.refreshPlaylistFolder(
        widget.playlist,
        (progress) {
          if (mounted) {
            setState(() {
              _progressValue = progress.progress;
              _progressText = '${progress.currentFileName}\n'
                  '${widget.l10n.importingFolderProgress(progress.processedFiles, progress.foundSongs, progress.totalFiles)}';
            });
          }
        },
        onlySongs: widget.onlySongs,
      );
    } catch (e) {
      _result = FolderRefreshResult(
        totalSongs: 0,
        addedSongs: 0,
        removedSongs: 0,
        error: e.toString(),
      );
    }

    if (mounted) {
      Navigator.of(context).pop(_result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                widget.l10n.refreshFolder,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progressValue),
              const SizedBox(height: 8),
              Text(
                _progressText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
