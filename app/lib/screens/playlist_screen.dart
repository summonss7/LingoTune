import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../services/playlist_service.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
import '../services/cover_art_service.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import 'playlist_songs_screen.dart';
import 'package:image/image.dart' as img;

class PlaylistScreen extends StatefulWidget {
  final AudioService audioService;
  final LyricsService lyricsService;
  final TranslationService translationService;

  const PlaylistScreen({
    super.key,
    required this.audioService,
    required this.lyricsService,
    required this.translationService,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final ImagePicker _picker = ImagePicker();
  List<Playlist> _playlists = [];
  bool _isLoading = true;
  String _sortBy = 'default';

  @override
  void initState() {
    super.initState();
    _loadSortPreference();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final playlists = await _playlistService.getAllPlaylists();

      setState(() {
        _playlists = playlists;
        _isLoading = false;
      });

      _applySorting();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load playlists: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortBy = prefs.getString('playlistsSortBy') ?? 'default';
    });
  }

  void _applySorting() {
    // Разделяем системные и обычные плейлисты
    final systemPlaylists = _playlists.where((p) => p.isSystem).toList();
    final regularPlaylists = _playlists.where((p) => !p.isSystem).toList();

    // Сортируем только обычные плейлисты
    List<Playlist> sortedRegular;
    switch (_sortBy) {
      case 'name_asc':
        sortedRegular = List.from(regularPlaylists)
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_desc':
        sortedRegular = List.from(regularPlaylists)
          ..sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'date_desc':
        sortedRegular = List.from(regularPlaylists)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'song_count_desc':
        sortedRegular = List.from(regularPlaylists)
          ..sort((a, b) => b.songCount.compareTo(a.songCount));
        break;
      case 'default':
      default:
        sortedRegular = regularPlaylists;
        break;
    }

    // Сортируем системные плейлисты (Favorites всегда первый)
    systemPlaylists.sort((a, b) {
      if (a.name.toLowerCase().contains('favorite') || a.name.toLowerCase().contains('избран') || a.name.toLowerCase().contains('избр') || a.name.toLowerCase().contains('favor')) {
        return -1;
      }
      if (b.name.toLowerCase().contains('favorite') || b.name.toLowerCase().contains('избран') || b.name.toLowerCase().contains('избр') || b.name.toLowerCase().contains('favor')) {
        return 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    // Объединяем в зависимости от направления сортировки
    switch (_sortBy) {
      case 'name_desc':
        _playlists = [...sortedRegular, ...systemPlaylists];
        break;
      case 'date_desc':
      case 'song_count_desc':
        _playlists = [...systemPlaylists, ...sortedRegular];
        break;
      default:
        _playlists = [...systemPlaylists, ...sortedRegular];
        break;
    }
  }

  Future<void> _sortPlaylists(String sortBy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playlistsSortBy', sortBy);
    setState(() {
      _sortBy = sortBy;
    });
    if (sortBy == 'default') {
      await _loadPlaylists();
    } else {
      _applySorting();
    }
  }

  Future<String?> _generatePlaylistCoverArt(String playlistName, String playlistId) async {
    try {
      final gradient = CoverArtService.getGradientForSong(playlistName);
      final initial = playlistName.isNotEmpty ? playlistName[0].toUpperCase() : '?';

      final image = img.Image(width: 200, height: 200);

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final ratio = x / image.width;
          final r = gradient.first.red +
              (gradient.last.red - gradient.first.red) * ratio;
          final g = gradient.first.green +
              (gradient.last.green - gradient.first.green) * ratio;
          final b = gradient.first.blue +
              (gradient.last.blue - gradient.first.blue) * ratio;
          image.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);
        }
      }

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_cover_$playlistId.png');
      await tempFile.writeAsBytes(img.encodePng(image));

      return await CoverArtService.saveCoverArt(tempFile.path, playlistName);
    } catch (e) {
      debugPrint('Error generating playlist cover art: $e');
      return null;
    }
  }

  Future<void> _createPlaylist() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String? selectedMusicFolder;
    bool hasUserEditedName = false;

    final iconOptions = [
      {'value': null, 'label': l10n.playlistPlay, 'icon': Icons.playlist_play},
      {'value': 'music_note', 'label': l10n.musicNote, 'icon': Icons.music_note},
      {'value': 'favorite', 'label': l10n.favorite, 'icon': Icons.favorite},
      {'value': 'language', 'label': l10n.language, 'icon': Icons.language},
      {'value': 'library_music', 'label': l10n.libraryMusic, 'icon': Icons.library_music},
    ];
    String? selectedIcon;

    final result = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.createPlaylist),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedMusicFolder != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_open, color: Colors.green, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              path.basename(selectedMusicFolder!),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              selectedMusicFolder!,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            selectedMusicFolder = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.folder_open, size: 28),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.selectMusicFolder,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            l10n.tapToSelectFolder,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.getDirectoryPath();
                      if (result != null && result.isNotEmpty) {
                        setState(() {
                          selectedMusicFolder = result;
                          if (!hasUserEditedName) {
                            final folderName = path.basename(result);
                            controller.text = folderName;
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.playlistName,
                  hintText: 'My Playlist',
                  prefixIcon: const Icon(Icons.edit),
                ),
                onChanged: (value) {
                  if (!hasUserEditedName && value.isNotEmpty) {
                    hasUserEditedName = true;
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedIcon,
                decoration: InputDecoration(
                  labelText: l10n.iconOptional,
                  prefixIcon: Icon(_getIconData(selectedIcon)),
                ),
                items: iconOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'] as String?,
                    child: Row(
                      children: [
                        Icon(option['icon'] as IconData, size: 20),
                        const SizedBox(width: 12),
                        Text(option['label'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIcon = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                final icon = selectedIcon;

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pleaseEnterPlaylistName)),
                  );
                  return;
                }

                if (selectedMusicFolder != null) {
                  final permissionGranted = await _requestFolderPermissions(context);
                  if (!permissionGranted) {
                    return;
                  }
                }

                try {
                  final playlistId = DateTime.now().millisecondsSinceEpoch.toString();
                  final playlist = Playlist(
                    id: playlistId,
                    name: name,
                    icon: icon,
                    isSystem: false,
                    musicFolderPath: selectedMusicFolder,
                  );
                  await _playlistService.insertPlaylist(playlist);

                  final coverArtPath = await _generatePlaylistCoverArt(name, playlistId);
                  if (coverArtPath != null) {
                    final updatedPlaylist = playlist.copyWith(
                      coverArtPath: coverArtPath,
                      coverArtVersion: 0,
                    );
                    await _playlistService.updatePlaylist(updatedPlaylist);
                  }

                  Navigator.pop(context);

                  if (selectedMusicFolder != null) {
                    await _refreshPlaylistFolder(playlist, l10n);
                  }

                  await _loadPlaylists();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.failedToCreatePlaylist(e.toString()))),
                    );
                  }
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
       ),
     );
    controller.dispose();
  }

  Future<bool> _requestFolderPermissions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      bool permissionGranted = false;

      if (sdkInt >= 33) {
        final status = await Permission.manageExternalStorage.request();
        permissionGranted = status.isGranted;
      } else {
        final status = await Permission.storage.request();
        permissionGranted = status.isGranted;
      }

      if (!permissionGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.accessDenied),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _refreshPlaylistFolder(Playlist playlist, AppLocalizations l10n) async {
    if (playlist.musicFolderPath == null) {
      return;
    }

    try {
      final result = await Navigator.of(context).push<FolderRefreshResult>(
        MaterialPageRoute(
          builder: (context) => _CreatePlaylistRefreshDialog(
            playlist: playlist,
            l10n: l10n,
          ),
        ),
      );

      if (result != null && mounted) {
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
    } catch (e) {
      debugPrint('Error refreshing folder: $e');
    }
  }

  Future<void> _linkFolderToPlaylist(Playlist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      
      if (result != null && result.isNotEmpty) {
        final dir = Directory(result);
        final exists = await dir.exists();
        
        if (exists) {
          final updatedPlaylist = playlist.copyWith(
            musicFolderPath: result,
          );
          await _playlistService.updatePlaylist(updatedPlaylist);
          
          setState(() {
            final index = _playlists.indexWhere((p) => p.id == playlist.id);
            if (index != -1) {
              _playlists[index] = updatedPlaylist;
            }
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.folderLinkedToPlaylist),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.folderSetFailed),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error linking folder to playlist: $e');
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

  Future<void> _unlinkFolderFromPlaylist(Playlist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final updatedPlaylist = playlist.copyWith(
        musicFolderPath: null,
      );
      await _playlistService.updatePlaylist(updatedPlaylist);
      
      setState(() {
        final index = _playlists.indexWhere((p) => p.id == playlist.id);
        if (index != -1) {
          _playlists[index] = updatedPlaylist;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.folderUnlinkedFromPlaylist),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error unlinking folder from playlist: $e');
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

  Future<void> _renamePlaylist(Playlist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: playlist.name);
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
    if (newName.isEmpty || newName == playlist.name) return;

    try {
      // Дубль имени запутает пользователя в списке — не даём создать.
      final all = await _playlistService.getAllPlaylists();
      final duplicate = all.any((p) =>
          p.id != playlist.id &&
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

      final ok = await _playlistService.renamePlaylist(playlist.id, newName);
      if (!ok) return;
      await _loadPlaylists();
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

  Future<void> _deletePlaylist(Playlist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePlaylistTitle),
        content: Text(l10n.deletePlaylistConfirm(playlist.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _playlistService.deletePlaylist(playlist.id);
        await _loadPlaylists();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.failedToDeletePlaylist} $e')),
          );
        }
      }
    }
  }

  Future<void> _editPlaylistCover(Playlist playlist) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.playlistCover),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (playlist.coverArtPath != null && playlist.coverArtPath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(playlist.coverArtPath!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: CoverArtService.getGradientForSong(playlist.name),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    playlist.name.isNotEmpty ? playlist.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.selectFromGallery),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            if (playlist.coverArtPath != null && playlist.coverArtPath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(l10n.removeCover),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == 'gallery') {
      bool permissionGranted = false;
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          final status = await Permission.photos.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.photoPermissionDenied),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            return;
          }
          permissionGranted = status.isGranted;
        } else {
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.photoPermissionDenied),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            return;
          }
          permissionGranted = status.isGranted;
        }

        if (!permissionGranted) return;
      } catch (e) {
        debugPrint('Error checking Android permissions: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorWithMessage('Permission check failed: $e')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        try {
          String imagePath = pickedFile.path;

          if (imagePath.startsWith('content://')) {
            debugPrint('Content URI detected, converting to file path: $imagePath');
            try {
              final xFile = pickedFile;
              final bytes = await xFile.readAsBytes();

              final tempDir = await getTemporaryDirectory();
              final tempFile = File('${tempDir.path}/temp_cover_${DateTime.now().millisecondsSinceEpoch}.jpg');
              await tempFile.writeAsBytes(bytes);

              imagePath = tempFile.path;
              debugPrint('Converted to temporary file path: $imagePath');
            } catch (e) {
              debugPrint('Failed to convert content URI: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.imageProcessingError),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
          }

          final newCoverPath = await CoverArtService.saveCoverArt(imagePath, playlist.name);

          final updatedPlaylist = playlist.copyWith(
            coverArtPath: newCoverPath,
            coverArtVersion: playlist.coverArtVersion + 1,
          );
          await _playlistService.updatePlaylist(updatedPlaylist);

          setState(() {
            final index = _playlists.indexWhere((p) => p.id == playlist.id);
            if (index != -1) {
              _playlists[index] = updatedPlaylist;
            }
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.coverUpdated),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error processing cover art: $e');
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
    } else if (result == 'delete') {
      await CoverArtService.deleteCoverArt(playlist.coverArtPath);

      final updatedPlaylist = playlist.copyWith(
        coverArtPath: null,
        coverArtVersion: playlist.coverArtVersion + 1,
      );
      await _playlistService.updatePlaylist(updatedPlaylist);

      setState(() {
        final index = _playlists.indexWhere((p) => p.id == playlist.id);
        if (index != -1) {
          _playlists[index] = updatedPlaylist;
          _playlists = List.from(_playlists);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.coverRemoved),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _checkFolderAccess(Playlist playlist) async {
    final l10n = AppLocalizations.of(context)!;

    if (playlist.musicFolderPath == null || playlist.musicFolderPath!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noFolderConfigured),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    bool permissionGranted = false;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          if (mounted) {
            _showPermissionResultDialog(
              l10n,
              false,
              l10n.accessDenied,
              l10n.pleaseGrantPermissions,
              null,
              null,
            );
          }
          return;
        }
        permissionGranted = status.isGranted;
      } else {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            _showPermissionResultDialog(
              l10n,
              false,
              l10n.accessDenied,
              l10n.pleaseGrantPermissions,
              null,
              null,
            );
          }
          return;
        }
        permissionGranted = status.isGranted;
      }
    } catch (e) {
      debugPrint('Error checking Android permissions: $e');
      if (mounted) {
        _showPermissionResultDialog(
          l10n,
          false,
          l10n.permissionRequestFailed,
          l10n.errorWithMessage(e.toString()),
          null,
          null,
        );
      }
      return;
    }

    if (!permissionGranted) return;

    final folderPath = playlist.musicFolderPath!;
    final folder = Directory(folderPath);

    if (!await folder.exists()) {
      if (mounted) {
        _showPermissionResultDialog(
          l10n,
          false,
          l10n.folderDoesNotExist,
          l10n.folderPathColon,
          folderPath,
          null,
        );
      }
      return;
    }

    try {
      final files = await folder.list().toList();
      final audioFiles = <FileSystemEntity>[];
      final lyricsFiles = <FileSystemEntity>[];

      for (final file in files) {
        if (file is File) {
          final extension = path.extension(file.path).toLowerCase();
          if (['.mp3', '.wav', '.m4a', '.ogg', '.flac'].contains(extension)) {
            audioFiles.add(file);
          } else if (extension == '.zip') {
            lyricsFiles.add(file);
          }
        }
      }

      final audioCount = audioFiles.length;
      final lyricsCount = lyricsFiles.length;

      if (mounted) {
        _showPermissionResultDialog(
          l10n,
          true,
          l10n.folderAccessible,
          l10n.folderPathColon,
          folderPath,
          {'audio': audioCount, 'lyrics': lyricsCount},
        );
      }
    } catch (e) {
      debugPrint('Error checking folder access: $e');
      if (mounted) {
        _showPermissionResultDialog(
          l10n,
          false,
          l10n.folderNotAccessible,
          l10n.errorCheckingAccess(e.toString()),
          folderPath,
          null,
        );
      }
    }
  }

  void _showPermissionResultDialog(
    AppLocalizations l10n,
    bool hasAccess,
    String status,
    String message,
    String? folderPath,
    Map<String, int>? fileCounts,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              hasAccess ? Icons.check_circle : Icons.error,
              color: hasAccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(l10n.checkFolderAccess),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: TextStyle(
                color: hasAccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.permissionsStatus),
            Text(message),
            if (folderPath != null) ...[
              const SizedBox(height: 16),
              Text(l10n.folderPathColon),
              Text(
                folderPath,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            if (hasAccess && fileCounts != null) ...[
              const SizedBox(height: 16),
              Text(l10n.folderContent),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.music_note, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.audioFilesFound(fileCounts['audio'] ?? 0)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.description, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.lyricsFound(fileCounts['lyrics'] ?? 0)),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'library_music':
        return Icons.library_music;
      case 'favorite':
        return Icons.favorite;
      case 'language':
        return Icons.language;
      case 'music_note':
        return Icons.music_note;
      default:
        return Icons.playlist_play;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Icon(Icons.playlist_play, size: 28),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: 'Sort playlists',
            onSelected: _sortPlaylists,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'default',
                child: Text('📋 ${l10n.sortDefault}'),
              ),
              PopupMenuItem(
                value: 'name_asc',
                child: Text('🔤 ${l10n.sortAlphabeticalAsc}'),
              ),
              PopupMenuItem(
                value: 'name_desc',
                child: Text('🔤 ${l10n.sortAlphabeticalDesc}'),
              ),
              PopupMenuItem(
                value: 'date_desc',
                child: Text('📅 ${l10n.sortDateDesc}'),
              ),
              PopupMenuItem(
                value: 'song_count_desc',
                child: Text('🎵 ${l10n.mostSongs}'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.playlist_play,
                        size: 64,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noPlaylistsFound,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first playlist to organize your songs',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    return FutureBuilder<int>(
                      future: _playlistService.getPlaylistSongCount(playlist.id),
                      builder: (context, snapshot) {
                        final songCount = snapshot.data ?? 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                if (!playlist.isSystem) {
                                  _editPlaylistCover(playlist);
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: playlist.coverArtPath != null && playlist.coverArtPath!.isNotEmpty
                                        ? null
                                        : Theme.of(context).colorScheme.secondaryContainer,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (playlist.coverArtPath != null && playlist.coverArtPath!.isNotEmpty)
                                        Positioned.fill(
                                          child: CoverArtService.buildCoverArtWidget(
                                            title: playlist.name,
                                            coverArtPath: playlist.coverArtPath,
                                            coverArtVersion: playlist.coverArtVersion,
                                            size: 56,
                                          ),
                                        )
                                      else
                                        _buildDefaultLeading(playlist),
                                      if (!playlist.isSystem)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    playlist.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (playlist.musicFolderPath != null && playlist.musicFolderPath!.isNotEmpty)
                                  const Icon(
                                    Icons.folder_open,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$songCount ${l10n.allSongs.toLowerCase()}'),
                                if (playlist.musicFolderPath != null && playlist.musicFolderPath!.isNotEmpty)
                                  Text(
                                    '${playlist.musicFolderPath!}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: playlist.isSystem
                                ? null
                                : PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _deletePlaylist(playlist);
                                      } else if (value == 'rename') {
                                        _renamePlaylist(playlist);
                                      } else if (value == 'edit_cover') {
                                        _editPlaylistCover(playlist);
                                      } else if (value == 'link_folder') {
                                        _linkFolderToPlaylist(playlist);
                                      } else if (value == 'unlink_folder') {
                                        _unlinkFolderFromPlaylist(playlist);
                                      } else if (value == 'check_access') {
                                        _checkFolderAccess(playlist);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'rename',
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.drive_file_rename_outline,
                                                size: 20),
                                            const SizedBox(width: 8),
                                            Text(l10n.renamePlaylist),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit_cover',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.image, size: 20),
                                            const SizedBox(width: 8),
                                            Text(l10n.playlistCover),
                                          ],
                                        ),
                                      ),
                                      if (playlist.musicFolderPath == null || playlist.musicFolderPath!.isEmpty)
                                        PopupMenuItem(
                                          value: 'link_folder',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.folder_open, size: 20),
                                              const SizedBox(width: 8),
                                              Text(l10n.selectMusicFolder),
                                            ],
                                          ),
                                        )
                                      else ...[
                                        PopupMenuItem(
                                          value: 'check_access',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.check_circle, size: 20),
                                              const SizedBox(width: 8),
                                              Text(l10n.checkFolderAccess),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'unlink_folder',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.folder_off, size: 20),
                                              const SizedBox(width: 8),
                                              Text('Unlink Folder'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistSongsScreen(
                                    playlist: playlist,
                                    audioService: widget.audioService,
                                    lyricsService: widget.lyricsService,
                                    translationService: widget.translationService,
                                  ),
                                ),
                              );
                              await _loadPlaylists();
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPlaylist,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDefaultLeading(Playlist playlist) {
    return Center(
      child: Icon(
        _getIconData(playlist.icon),
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}

class _CreatePlaylistRefreshDialog extends StatefulWidget {
  final Playlist playlist;
  final AppLocalizations l10n;

  const _CreatePlaylistRefreshDialog({
    required this.playlist,
    required this.l10n,
  });

  @override
  State<_CreatePlaylistRefreshDialog> createState() => _CreatePlaylistRefreshDialogState();
}

class _CreatePlaylistRefreshDialogState extends State<_CreatePlaylistRefreshDialog> {
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
        onlySongs: false,
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
                widget.l10n.scanningFolder,
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
