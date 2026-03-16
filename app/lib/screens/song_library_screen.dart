import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:image_cropper/image_cropper.dart'; // Temporarily disabled due to Android 13+ crashes
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/lyric_line.dart';
import '../models/translation.dart';
import '../services/audio_service.dart';
import '../services/lyrics_service.dart';
import '../services/translation_service.dart';
import '../services/database_service.dart';
import '../services/folder_config_service.dart';
import '../services/playlist_service.dart';
import '../services/export_import_service.dart';
import '../services/cover_art_service.dart';
import '../services/settings_provider.dart';
import 'lyric_generator_dialog.dart';
import '../widgets/empty_library_widget.dart';
import '../widgets/loading_widget.dart';
import 'player_screen.dart';
import '../widgets/lyrics_search_dialog.dart';
import 'package:lingotune/services/export_import_service.dart' show ImportResult, ImportMode;
import 'helpers/song_import_helper.dart';
import 'helpers/song_cover_helper.dart';
import 'helpers/song_translation_loader.dart';

class SongLibraryScreen extends StatefulWidget {
  final AudioService audioService;
  final LyricsService lyricsService;
  final TranslationService translationService;

  const SongLibraryScreen({
    super.key,
    required this.audioService,
    required this.lyricsService,
    required this.translationService,
  });

  @override
  State<SongLibraryScreen> createState() => _SongLibraryScreenState();
}

class _SongLibraryScreenState extends State<SongLibraryScreen> {
  List<Song> _songs = [];
  bool _isLoading = false;
  bool _isImporting = false;
  bool _isSelectionMode = false;
  final Map<String, Song> _selectedSongs = {};
  final DatabaseService _databaseService = DatabaseService();
  final PlaylistService _playlistService = PlaylistService();
  final Uuid _uuid = const Uuid();
  String _sortBy = 'default';

  final SongImportHelper _songImportHelper = SongImportHelper();
  final SongCoverHelper _songCoverHelper = SongCoverHelper();
  final SongTranslationLoader _songTranslationLoader = SongTranslationLoader();

  @override
  void initState() {
    super.initState();
    _loadSortPreference();
    _loadSongs();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _loadSongs();
    }
  }

  Future<void> _loadSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sortBy = prefs.getString('librarySortBy') ?? 'default';
    });
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final songs = await _databaseService.getAllSongs();

      setState(() {
        _songs = songs;
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
            content: Text('Failed to load songs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> refreshSongs() async {
    await _loadSongs();
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

  Future<void> _importSong() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importSongDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(l10n.audioOnly),
              subtitle: Text(l10n.addLyricsLater),
              onTap: () => Navigator.of(context).pop('audio'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_zip),
              title: Text(l10n.audioWithLyricsZIP),
              subtitle: Text(l10n.importWithAllTranslations),
              onTap: () => Navigator.of(context).pop('archive'),
            ),
          ],
        ),
      ),
    );

    if (result == 'audio') {
      await _importAudioOnly();
    } else if (result == 'archive') {
      await _importSongWithArchive();
    }
  }

  Future<void> _importAudioOnlyInternal(String title, String audioPath) async {
    await _songImportHelper.importAudioOnlyInternal(
      title,
      audioPath,
      (callback) => setState(() {
        if (callback is Function) callback();
      }),
      context,
      _songs,
      mounted,
    );
  }

  Future<void> _importFolders() async {
    if (!mounted) return;

    debugPrint('=== _importFolders START ===');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _FolderImportDialog(),
    );

    debugPrint('_importFolders: Dialog result = $result');

    if (result == null) {
      debugPrint('_importFolders: Result is null, exiting');
      return;
    }

    setState(() {
      _isImporting = true;
    });
    debugPrint('_importFolders: _isImporting set to true');

    try {
      final playlistName = result['playlistName'] ?? '';
      final musicFolder = result['musicFolder'];
      final lyricsFolder = result['lyricsFolder'];

      debugPrint('_importFolders: playlistName = $playlistName');
      debugPrint('_importFolders: musicFolder = $musicFolder');
      debugPrint('_importFolders: lyricsFolder = $lyricsFolder');

      if (musicFolder == null) {
        debugPrint('_importFolders: musicFolder is null, showing error');
        setState(() {
          _isImporting = false;
        });

        final l10n = AppLocalizations.of(context)!;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.musicFolderNotSelected),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final musicDir = Directory(musicFolder);
      if (!musicDir.existsSync()) {
        debugPrint('_importFolders: Music folder does not exist');
        setState(() {
          _isImporting = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.musicFolderDoesNotExist),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final playlistId = '${DateTime.now().millisecondsSinceEpoch}';
      final playlist = Playlist(
        id: playlistId,
        name: playlistName,
        icon: 'folder',
        isSystem: false,
        musicFolderPath: musicFolder,
        lyricsFolderPath: lyricsFolder,
      );

      debugPrint('_importFolders: Creating playlist: $playlistId');
      await _playlistService.insertPlaylist(playlist).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('_importFolders: Playlist insert TIMEOUT');
          throw TimeoutException('Playlist insert timeout');
        },
      );
      debugPrint('_importFolders: Playlist created successfully');

      final l10n = AppLocalizations.of(context)!;

      setState(() {
        _isImporting = false;
      });
      debugPrint('_importFolders: _isImporting set to false');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l10n.playlistCreatedWithLink),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('_importFolders: SUCCESS');
    } catch (e, stackTrace) {
      debugPrint('_importFolders: ERROR: $e');
      debugPrint('_importFolders: Stack trace: $stackTrace');

      setState(() {
        _isImporting = false;
      });
      debugPrint('_importFolders: _isImporting set to false (error)');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import folders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.mp3', '.wav', '.m4a', '.ogg', '.flac'].contains(extension);
  }

  Future<List<TranslationFile>> _findTranslationFilesInFolder(String folderPath, String songName) async {
    final List<TranslationFile> translationFiles = [];
    final folder = Directory(folderPath);

    if (!folder.existsSync()) return translationFiles;

    final files = folder.listSync();
    final songNameLower = songName.toLowerCase();

    for (final f in files) {
      if (f is File) {
        final fileName = path.basename(f.path).toLowerCase();
        if (fileName.startsWith(songNameLower) && fileName.endsWith('.json')) {
          try {
            final content = await File(f.path).readAsString();
            final data = json.decode(content) as Map<String, dynamic>;

            if (data.containsKey('translations') && data['translations'] != null) {
              final translations = data['translations'] as List;
              if (translations.isNotEmpty) {
                final translation = translations[0] as Map<String, dynamic>;
                final language = translation['language'] as String? ?? 'unknown';
                final languageName = translation['languageName'] as String? ?? 'Unknown';
                final type = translation['type'] as String?;

                translationFiles.add(TranslationFile(
                  filePath: f.path,
                  language: language,
                  languageName: languageName,
                  type: type,
                ));
              }
            }
          } catch (e) {
            debugPrint('Error reading JSON file: $e');
          }
        }
      }
    }

    return translationFiles;
  }

  Future<void> _importAudioOnly() async {
    debugPrint('=== Starting _importAudioOnly ===');

    setState(() {
      _isImporting = true;
    });

    try {
      final audioResult = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (audioResult == null || audioResult.files.isEmpty) {
        setState(() {
          _isImporting = false;
        });
        return;
      }

      final audioFiles = <String>[];
      for (final file in audioResult.files) {
        if (file.path != null) {
          audioFiles.add(file.path!);
        }
      }

      if (audioFiles.isEmpty) {
        setState(() {
          _isImporting = false;
        });
        return;
      }

      int importedCount = 0;

      for (final audioPath in audioFiles) {
        debugPrint('=== DEBUG: Import Song $importedCount ===');
        debugPrint('Audio path: $audioPath');

        final fileName = path.basename(audioPath);
        final title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false), '');
        final baseName = path.basenameWithoutExtension(audioPath);

        debugPrint('File name: $fileName');
        debugPrint('Base name: $baseName');
        debugPrint('Title: $title');

        final song = Song(
          id: _uuid.v4(),
          title: title,
          artist: 'Unknown Artist',
          audioPath: audioPath,
          lrcPath: null,
          translationsPath: null,
          originalLanguage: 'unknown',
          hasLyrics: false,
        );

        debugPrint('Saving song to database...');
        await _databaseService.insertSong(song);

        _songs.add(song);
        importedCount++;

        debugPrint('=== Song import completed ===');
        debugPrint('Song ID: ${song.id}');
        debugPrint('Song hasLyrics: ${song.hasLyrics}');
      }

      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.successfullyImportedSongs(importedCount)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error in _importAudioOnly: $e');
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _importSongWithArchive() async {
    debugPrint('=== Starting _importSongWithArchive ===');

    setState(() {
      _isImporting = true;
    });

    try {
      debugPrint('Step 1: Select audio file');
      final audioResult = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (audioResult == null || audioResult.files.isEmpty || audioResult.files.single.path == null) {
        debugPrint('No audio file selected');
        setState(() {
          _isImporting = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noAudioFileSelected),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final audioPath = audioResult.files.single.path!;
      final baseName = path.basenameWithoutExtension(audioPath);
      final title = path.basename(audioPath).replaceAll(RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false), '');

      debugPrint('Audio selected: $audioPath');
      debugPrint('Base name: $baseName');
      debugPrint('Title: $title');

      debugPrint('Step 2: Select ZIP archive');
      final l10n = AppLocalizations.of(context)!;
      final zipResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: l10n.selectZipArchiveWithLyrics(title),
      );

      if (zipResult == null || zipResult.files.isEmpty || zipResult.files.single.path == null) {
        debugPrint('No ZIP archive selected');
        setState(() {
          _isImporting = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noZipArchiveSelected),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final zipPath = zipResult.files.single.path!;
      debugPrint('=== Importing song with archive ===');
      debugPrint('Audio: $audioPath');
      debugPrint('ZIP: $zipPath');
      debugPrint('Base name: $baseName');

      debugPrint('Step 3: Get configured folder');
      final folder = await FolderConfigService.getConfiguredFolder();
      if (folder == null) {
        debugPrint('ERROR: No folder configured');
        setState(() {
          _isImporting = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noFolderConfigured),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      debugPrint('Configured folder: ${folder.path}');

      debugPrint('Step 4: Extract archive');
      final extractedFiles = await ExportImportService.extractSongArchive(zipPath, folder.path, baseName);

      debugPrint('=== Extracted files count: ${extractedFiles.length} ===');

      int lrcFound = 0;
      int jsonFound = 0;
      String? lrcPathToSave;
      String? jsonPathToSave;

      debugPrint('Step 5: Analyzing extracted files');
      for (final filePath in extractedFiles) {
        final fileName = path.basename(filePath);
        debugPrint('Analyzing: $fileName');

        if (fileName.endsWith('.lrc') || fileName.toLowerCase().endsWith('.lrc')) {
          lrcPathToSave = filePath;
          lrcFound++;
          debugPrint('✓ Found LRC file: $fileName');
        } else if (fileName.endsWith('.json') || fileName.toLowerCase().endsWith('.json')) {
          jsonFound++;
          debugPrint('✓ Found JSON file: $fileName');
        } else {
          debugPrint('⚠ Unknown file type: $fileName');
        }
      }

      debugPrint('=== File analysis complete ===');
      debugPrint('LRC files found: $lrcFound');
      debugPrint('JSON files found: $jsonFound');
      debugPrint('LRC path to save: $lrcPathToSave');

      debugPrint('Step 6: Creating song object');
      final hasLyrics = lrcPathToSave != null;
      final song = Song(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        artist: 'Unknown Artist',
        audioPath: audioPath,
        lrcPath: lrcPathToSave,
        translationsPath: null,
        originalLanguage: 'unknown',
        hasLyrics: hasLyrics,
      );

      debugPrint('Song created: ${song.title} (ID: ${song.id})');

      debugPrint('Step 7: Saving song to database');
      await _databaseService.insertSong(song);
      _songs.add(song);
      debugPrint('✓ Song saved to database');

      debugPrint('Step 8: Scanning for translations');
      await _scanTranslationsForSong(song, extractedFiles);

      await Future.delayed(const Duration(milliseconds: 100));

      final translationCount = await _databaseService.getTranslationCount(song.id);
      debugPrint('Step 8.1: Translations in database: $translationCount');

      debugPrint('Step 9: Updating UI');
      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        String message = '✓ Imported: "$title"';
        message += '\n📁 $lrcFound LRC, $jsonFound JSON files';

        debugPrint('=== Import completed successfully ===');
        debugPrint('Final message: $message');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('=== ERROR in _importSongWithArchive ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');

      final l10n = AppLocalizations.of(context)!;

      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToImportSong(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _scanTranslationsForSong(Song song, List<String> extractedFiles) async {
    try {
      debugPrint('=== Scanning translations for song: ${song.title} ===');
      debugPrint('Song ID: ${song.id}');
      debugPrint('Total extracted files: ${extractedFiles.length}');
      int translationsAdded = 0;
      int errorsCount = 0;

      final futures = <Future<void>>[];

      for (final filePath in extractedFiles) {
        final fileName = path.basename(filePath);

        if (fileName.endsWith('.json') || fileName.toLowerCase().endsWith('.json')) {
          debugPrint('Processing JSON file: $fileName');

          futures.add(() async {
            try {
              final file = File(filePath);
              if (!await file.exists()) {
                debugPrint('⚠ File does not exist: $filePath');
                errorsCount++;
                return;
              }

              debugPrint('Reading file: $filePath');
              final content = await file.readAsString();
              debugPrint('File size: ${content.length} characters');

              final data = json.decode(content) as Map<String, dynamic>;

              if (!data.containsKey('translations') || data['translations'] == null) {
                debugPrint('⚠ No translations key in file: $fileName');
                errorsCount++;
                return;
              }

              final translations = data['translations'] as List;
              if (translations.isEmpty) {
                debugPrint('⚠ Empty translations array in file: $fileName');
                errorsCount++;
                return;
              }

              debugPrint('Found ${translations.length} translations in file: $fileName');

              for (final t in translations) {
                try {
                  final translationData = t as Map<String, dynamic>;

                  final language = translationData['language'] as String? ?? 'unknown';
                  final languageName = translationData['languageName'] as String? ?? 'Unknown';
                  final type = translationData['type'] as String?;

                  debugPrint('Translation found: $languageName ($language) type: $type');

                  await _databaseService.addTranslationFile(
                    song.id,
                    language,
                    languageName,
                    filePath,
                    type: type,
                  );

                  translationsAdded++;
                  debugPrint('✓ Added translation: $languageName for song: ${song.title}');
                } catch (e) {
                  debugPrint('✗ Error adding translation from $fileName: $e');
                  debugPrint('Stack trace: ${StackTrace.current}');
                  errorsCount++;
                }
              }

              debugPrint('✓ Successfully processed file: $fileName');
            } catch (e) {
              debugPrint('✗ Error processing JSON file $fileName: $e');
              debugPrint('Stack trace: ${StackTrace.current}');
              errorsCount++;
            }
          }());
        } else {
          debugPrint('Skipping non-JSON file: $fileName');
        }
      }

      await Future.wait(futures, eagerError: false);

      debugPrint('=== Translation scan completed for song: ${song.title} ===');
      debugPrint('Total translations added: $translationsAdded');
      debugPrint('Total errors encountered: $errorsCount');

      await Future.delayed(const Duration(milliseconds: 50));

      final finalCount = await _databaseService.getTranslationCount(song.id);
      debugPrint('Final translation count in database: $finalCount');
    } catch (e) {
      debugPrint('✗ Fatal error scanning translations for song ${song.title}: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<String?> _showMissingFilesDialog(String songName, bool missingLrc, bool missingJson) async {
    if (!missingLrc && !missingJson) return 'skip';

    final l10n = AppLocalizations.of(context)!;

    final missingFiles = <String>[];
    if (missingLrc) missingFiles.add('LRC');
    if (missingJson) missingFiles.add('JSON');

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.missingLyricsTranslations),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.missingForSong(songName)),
            const SizedBox(height: 8),
            Text(l10n.missingFilesList(missingFiles.join(', '))),
            const SizedBox(height: 16),
            Text(l10n.whatWouldYouLikeToDo),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('skip'),
            child: Text(l10n.skip),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('add_files'),
            child: Text(l10n.importSongs),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('generate'),
            child: Text(l10n.generateLyrics),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('audio_only'),
            child: Text(l10n.audioOnly),
          ),
        ],
      ),
    );

    if (result == 'add_files') {
      await _addMissingFiles(songName, missingLrc, missingJson);
    }

    return result;
  }

  Future<void> _addMissingFiles(String songName, bool needLrc, bool needJson) async {
    if (needLrc) {
      await _copyLrcWithRetry(songName);
    }

    if (needJson) {
      await _copyJsonFilesWithRetry(songName);
    }
  }

  Future<void> _copyLrcWithRetry(String songName) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['lrc'],
      dialogTitle: 'Select LRC file for "$songName"',
    );

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        final success = await FolderConfigService.copyLrcFile(filePath, songName);
        if (success) {
          debugPrint('LRC file copied successfully');
        } else {
          if (mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.failedToCopyLrcFile),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: l10n.retry,
                  textColor: Colors.white,
                  onPressed: () => _copyLrcWithRetry(songName),
                ),
              ),
            );
          }
        }
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

  Future<void> _copyJsonFilesWithRetry(String songName) async {
    debugPrint('=== Selecting JSON files for song: $songName ===');

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: true,
      dialogTitle: 'Select JSON files for "$songName"',
    );

    if (result != null && result.files.isNotEmpty) {
      debugPrint('Selected ${result.files.length} JSON files');

      int successCount = 0;
      int errorCount = 0;
      for (final file in result.files) {
        final filePath = file.path;
        if (filePath != null) {
          debugPrint('Attempting to copy JSON file: $filePath');
          final success = await FolderConfigService.copyJsonFile(filePath, songName);
          if (success) {
            successCount++;
            debugPrint('✓ JSON file copied successfully: $filePath');
          } else {
            errorCount++;
            debugPrint('✗ Failed to copy JSON file: $filePath');
          }
        }
      }

      debugPrint('=== Copy operation completed ===');
      debugPrint('Success: $successCount, Errors: $errorCount');

      if (successCount > 0) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${l10n.copiedJsonFiles(successCount)}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✗ ${l10n.failedToCopyJsonFiles}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: () => _copyJsonFilesWithRetry(songName),
              ),
            ),
          );
        }
      }
    } else {
      debugPrint('No JSON files selected');
    }
  }

  Future<void> _openPlayer(Song song) async {
    debugPrint('=== DEBUG: Open Player ===');
    debugPrint('Song ID: ${song.id}');
    debugPrint('Song: ${song.title}');
    debugPrint('Artist: ${song.artist}');
    debugPrint('Audio path: ${song.audioPath}');
    debugPrint('Audio path type: ${song.audioPath.startsWith('content://') ? 'content URI' : 'file path'}');
    debugPrint('LRC path: ${song.lrcPath}');
    debugPrint('LRC path is null: ${song.lrcPath == null}');
    debugPrint('LRC path is empty: ${song.lrcPath?.isEmpty ?? true}');
    debugPrint('JSON path: ${song.translationsPath}');
    debugPrint('JSON path is null: ${song.translationsPath == null}');
    debugPrint('JSON path is empty: ${song.translationsPath?.isEmpty ?? true}');

    try {
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
      debugPrint('Audio loaded successfully, isInitialized: ${widget.audioService.isInitialized}');

      if (mounted) {
        debugPrint('Navigating to player screen...');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              song: song,
              audioService: widget.audioService,
              lyricsService: widget.lyricsService,
              translationService: widget.translationService,
              playlistSongs: _songs,
            ),
          ),
        );
        
        await _loadSongs();
      }
    } catch (e) {
      debugPrint('=== ERROR: Failed to open player ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToOpenSong(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _confirmDelete(Song song) {
    bool deleteFiles = true;
    
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.deleteSong),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.deleteSongConfirm(song.title)),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(l10n.alsoDeleteLrcJsonFiles),
                  value: deleteFiles,
                  onChanged: (value) {
                    setState(() {
                      deleteFiles = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.platform,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteSong(song, deleteFiles);
                },
                child: Text(l10n.delete),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteSong(Song song, bool deleteFiles) async {
    try {
      await _databaseService.deleteSong(song.id);

      int deletedLrc = 0;
      int deletedJson = 0;

      if (deleteFiles) {
        if (song.lrcPath != null && song.lrcPath!.isNotEmpty) {
          final lrcFile = File(song.lrcPath!);
          try {
            if (lrcFile.existsSync()) {
              await lrcFile.delete();
              deletedLrc = 1;
              debugPrint('Deleted LRC file: ${song.lrcPath}');
            }
          } catch (e) {
            debugPrint('Error deleting LRC file: $e');
          }
        }

        if (song.translationsPath != null && song.translationsPath!.isNotEmpty) {
          final jsonFile = File(song.translationsPath!);
          try {
            if (jsonFile.existsSync()) {
              await jsonFile.delete();
              deletedJson = 1;
              debugPrint('Deleted JSON file: ${song.translationsPath}');
            }
          } catch (e) {
            debugPrint('Error deleting JSON file: $e');
          }
        }
      }

      setState(() {
        _songs.remove(song);
      });

      String message = 'Deleted "${song.title}"';
      if (deleteFiles && (deletedLrc > 0 || deletedJson > 0)) {
        message += ' (';
        List<String> deleted = [];
        if (deletedLrc > 0) deleted.add('LRC');
        if (deletedJson > 0) deleted.add('JSON');
        message += deleted.join(', ');
        message += ')';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToDeleteSong(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editCoverArt(Song song) async {
    await _songCoverHelper.editCoverArt(
      context,
      song,
      (callback) => setState(() {
        if (callback is Function) callback();
      }),
      _songs,
    );
  }

  Future<void> _addToPlaylist(Song song) async {
    final playlists = await _playlistService.getAllPlaylists();
    final Map<String, bool> playlistStatus = {};

    for (final playlist in playlists) {
      playlistStatus[playlist.id] = await _playlistService.isSongInPlaylist(playlist.id, song.id);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              final isInPlaylist = playlistStatus[playlist.id] ?? false;
              return ListTile(
                leading: CoverArtService.buildCoverArtWidget(
                  title: playlist.name,
                  coverArtPath: playlist.coverArtPath,
                  coverArtVersion: playlist.coverArtVersion,
                  size: 56,
                ),
                title: Text(playlist.name),
                trailing: isInPlaylist 
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                    : null,
                onTap: isInPlaylist ? null : () async {
                  try {
                    await _playlistService.addSongToPlaylist(playlist.id, song.id);
                    if (mounted) {
                      final l10n = AppLocalizations.of(context)!;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.addedToPlaylistWithQuotes(playlist.name))),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      final l10n = AppLocalizations.of(context)!;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.failedToAddToPlaylistError(e)),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.setDeepSeekApiKey),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.lyricsGeneratedSuccessfully)),
      );
      await _loadSongs();
    }
  }

  IconData _getPlaylistIcon(String? iconName) {
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

  Future<void> _exportAllSongs() async {
    final l10n = AppLocalizations.of(context)!;
    if (_songs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.noSongsFound}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    bool includeMp3 = false;

    if (mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.exportSongs),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.exportSongs),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(l10n.includeMp3Files),
                  subtitle: Text(l10n.includeMp3FilesSubtitle),
                  value: includeMp3,
                  onChanged: (value) {
                    setState(() {
                      includeMp3 = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.exportLrc),
              ),
            ],
          ),
        ),
      );

      if (result != true) return;
    }

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      final zipFile = await ExportImportService.exportAllSongs(_songs, includeDatabase: true, includeMp3: includeMp3);

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (zipFile != null) {
        final description = includeMp3 
            ? 'LingoTune экспорт: ${_songs.length} песен с MP3 файлами, лирикой и переводами'
            : 'LingoTune экспорт: ${_songs.length} песен с лирикой и переводами';
        await ExportImportService.shareExportFile(zipFile, description);

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.exportedSongsCount(_songs.length)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToExportSongs),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error exporting all songs: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLoadSongs(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importFromZip() async {
    final l10n = AppLocalizations.of(context)!;
    bool importMp3 = false;

    if (mounted) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(l10n.import),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.import),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(l10n.importMp3Files),
                  subtitle: Text(l10n.importMp3FilesSubtitle),
                  value: importMp3,
                  onChanged: (value) {
                    setState(() {
                      importMp3 = value ?? false;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.next),
              ),
            ],
          ),
        ),
      );

      if (result != true) return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        dialogTitle: 'Select ZIP file with LRC and JSON files',
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      final filePath = (result.files.single.path ?? result.files.single.identifier) as String;
      debugPrint('=== Starting import from: $filePath ===');

      final file = File(filePath);
      
      if (!await file.exists()) {
        debugPrint('ERROR: File does not exist: $filePath');
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.fileNotFound),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (filePath.endsWith('.json') || filePath.endsWith('.lrc')) {
        debugPrint('ERROR: Expected ZIP file, got JSON or LRC');
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.selectZipFileNotJson),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      try {
        final importResult = await ExportImportService.importFromZip(filePath, importDatabase: true, extractMp3: importMp3);

        debugPrint('=== Import result ===');
        debugPrint('File count: ${importResult.fileCount}');
        debugPrint('Has database: ${importResult.hasDatabase}');
        debugPrint('Database file: ${importResult.databaseFile?.path}');
        debugPrint('MP3 files: ${importResult.mp3Files.length}');

        if (mounted) {
          Navigator.of(context).pop();
        }

        if (importResult.hasDatabase && importResult.databaseFile != null) {
          debugPrint('=== Showing database import dialog ===');
          await _showDatabaseImportDialog(importResult, importMp3);
        } else {
          if (importResult.fileCount > 0 || importResult.mp3Files.length > 0) {
            await _loadSongs();
            await _scanAllTranslationsForImportedSongs();

            if (importResult.mp3Files.isNotEmpty) {
              await _importMp3Files(importResult.mp3Files);
            }

            if (mounted) {
              String message = 'Импортировано файлов: ${importResult.fileCount}';
              if (importResult.mp3Files.isNotEmpty) {
                message += ', MP3: ${importResult.mp3Files.length}';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } else {
            if (mounted) {
              final l10n = AppLocalizations.of(context)!;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.noFilesFoundInZip),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      } on FormatException catch (e) {
        debugPrint('ERROR: ZIP format exception: $e');
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.invalidZipFileFormat(e.message)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        debugPrint('ERROR: Import exception: $e');
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.importFailed(e.toString())),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error importing from ZIP: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _scanAllTranslationsForImportedSongs() async {
    try {
      debugPrint('=== Scanning translations for all imported songs ===');

      final songs = await _databaseService.getAllSongs();
      int totalTranslationsAdded = 0;

      for (final song in songs) {
        try {
          final translationFiles = await FolderConfigService.findAllJsonFiles(song.title);

          for (final tf in translationFiles) {
            try {
              await _databaseService.addTranslationFile(
                song.id,
                tf.language,
                tf.languageName,
                tf.filePath,
                type: tf.type,
              );
              totalTranslationsAdded++;
              debugPrint('Added translation: ${tf.languageName} for song: ${song.title}');
            } catch (e) {
              debugPrint('Error adding translation to database for song ${song.title}: $e');
            }
          }
        } catch (e) {
          debugPrint('Error scanning translations for song ${song.title}: $e');
        }
      }

      debugPrint('=== Total translations added: $totalTranslationsAdded ===');

      if (totalTranslationsAdded > 0 && mounted) {
        final l10n = AppLocalizations.of(context)!;
        await _loadSongs();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.foundTranslationsCount(totalTranslationsAdded)),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error scanning all translations: $e');
    }
  }

  Future<void> _showDatabaseImportDialog(ImportResult importResult, bool importMp3) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.databaseFound),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.importSuccessNoDatabase(importResult.fileCount)),
            if (importResult.mp3Files.isNotEmpty)
              Text(l10n.mp3FilesCount(importResult.mp3Files.length)),
            const SizedBox(height: 8),
            Text(l10n.importDatabaseQuestion),
            const SizedBox(height: 16),
            Text(l10n.mergeDatabaseDescription),
            Text(l10n.replaceDatabaseDescription),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (importResult.fileCount > 0 || importResult.mp3Files.isNotEmpty) {
                _loadSongs();
                if (importResult.mp3Files.isNotEmpty) {
                  _importMp3Files(importResult.mp3Files);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.importedFilesWithSkippedDatabase(importResult.fileCount)),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text(l10n.skipDatabase),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ExportImportService.importDatabase(
                  importResult.databaseFile!,
                  ImportMode.merge,
                );

                if (importResult.mp3Files.isNotEmpty) {
                  debugPrint('=== Updating MP3 paths after database merge ===');

                  final fileNameToPathMap = <String, String>{};
                  for (final mp3Path in importResult.mp3Files) {
                    final fileName = path.basename(mp3Path);
                    fileNameToPathMap[fileName] = mp3Path;
                    debugPrint('File mapping: $fileName -> $mp3Path');
                  }

                  final updatedCount = await _databaseService.updateAllSongPaths(fileNameToPathMap);
                  debugPrint('Updated $updatedCount song paths');
                }

                await _loadSongs();

                if (mounted) {
                  String message;
                  if (importResult.mp3Files.isNotEmpty) {
                    message = l10n.databaseMergedWithMp3(importResult.mp3Files.length);
                  } else {
                    message = l10n.databaseMerged;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.failedToImportSongs(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.mergeDatabase),
          ),
          TextButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.confirmReplaceDatabase),
                  content: Text(l10n.confirmReplaceDatabaseWarning),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(l10n.replaceAll),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                Navigator.of(context).pop();
                try {
                  debugPrint('=== Replacing database ===');
                  await ExportImportService.importDatabase(
                    importResult.databaseFile!,
                    ImportMode.replace,
                  );

                  if (importResult.mp3Files.isNotEmpty) {
                    debugPrint('=== Updating MP3 paths after database replace ===');

                    final fileNameToPathMap = <String, String>{};
                    for (final mp3Path in importResult.mp3Files) {
                      final fileName = path.basename(mp3Path);
                      fileNameToPathMap[fileName] = mp3Path;
                      debugPrint('File mapping: $fileName -> $mp3Path');
                    }

                    final updatedCount = await _databaseService.updateAllSongPaths(fileNameToPathMap);
                    debugPrint('Updated $updatedCount song paths');
                  }

                  await _loadSongs();

                  if (mounted) {
                    String message;
                    if (importResult.mp3Files.isNotEmpty) {
                      message = l10n.databaseReplacedWithMp3(importResult.mp3Files.length);
                    } else {
                      message = l10n.databaseReplaced;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.failedToImportSongs(e.toString())),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(l10n.replaceDatabase, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _importMp3Files(List<String> mp3FilePaths) async {
    try {
      debugPrint('=== Importing MP3 files ===');
      debugPrint('Total MP3 files: ${mp3FilePaths.length}');

      int importedCount = 0;
      int updatedCount = 0;
      int notFoundCount = 0;
      final unmatchedFiles = <String>[];

      final existingSongs = await _databaseService.getAllSongs();
      debugPrint('Existing songs in database: ${existingSongs.length}');

      for (final mp3Path in mp3FilePaths) {
        try {
          final fileName = path.basename(mp3Path);
          final title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false), '');
          final baseName = path.basenameWithoutExtension(mp3Path);

          debugPrint('Processing MP3: $fileName');
          debugPrint('Title: $title');
          debugPrint('Base name: $baseName');

          final mp3File = File(mp3Path);
          if (!mp3File.existsSync()) {
            debugPrint('✗ MP3 file does not exist: $mp3Path');
            notFoundCount++;
            unmatchedFiles.add(fileName);
            continue;
          }

          final matchingSongs = existingSongs.where((song) {
            final songBaseName = path.basenameWithoutExtension(song.audioPath);
            final titleMatch = song.title.toLowerCase() == baseName.toLowerCase();
            final pathMatch = songBaseName.toLowerCase() == baseName.toLowerCase();
            final partialMatch = song.title.toLowerCase().contains(baseName.toLowerCase()) ||
                            baseName.toLowerCase().contains(song.title.toLowerCase());

            return titleMatch || pathMatch || partialMatch;
          }).toList();

          if (matchingSongs.isNotEmpty) {
            final existingSong = matchingSongs.first;
            debugPrint('✓ Found matching song: ${existingSong.title}');
            
            await _databaseService.updateSongAudioPath(existingSong.id, mp3Path);
            
            final lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
            if (lrcPathToSave != null) {
              await _databaseService.updateSongLrcPath(existingSong.id, lrcPathToSave);
              debugPrint('✓ Updated LRC path');
            }
            
            final newSong = existingSong.copyWith(audioPath: mp3Path, lrcPath: lrcPathToSave);
            final index = _songs.indexWhere((s) => s.id == existingSong.id);
            if (index != -1) {
              _songs[index] = newSong;
            }
            updatedCount++;
            debugPrint('✓ Updated song: ${existingSong.title}');
            continue;
          }

          String? lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
          final translationFiles = await FolderConfigService.findAllJsonFiles(baseName);

          debugPrint('LRC path found: $lrcPathToSave');
          debugPrint('Translation files found: ${translationFiles.length}');

          final hasLyrics = lrcPathToSave != null || translationFiles.isNotEmpty;
          final song = Song(
            id: '${DateTime.now().millisecondsSinceEpoch}_$importedCount',
            title: title,
            artist: 'Unknown Artist',
            audioPath: mp3Path,
            lrcPath: lrcPathToSave,
            translationsPath: translationFiles.isNotEmpty ? translationFiles.first.filePath : null,
            originalLanguage: 'unknown',
            hasLyrics: hasLyrics,
          );

          await _databaseService.insertSong(song);

          for (final tf in translationFiles) {
            try {
              await _databaseService.addTranslationFile(
                song.id,
                tf.language,
                tf.languageName,
                tf.filePath,
                type: tf.type,
              );
            } catch (e) {
              debugPrint('Error adding translation: $e');
            }
          }

          _songs.add(song);
          importedCount++;
          debugPrint('✓ Successfully imported: $title');
        } catch (e) {
          debugPrint('✗ Error importing MP3 file $mp3Path: $e');
        }
      }

      debugPrint('=== MP3 import completed ===');
      debugPrint('Imported: $importedCount');
      debugPrint('Updated: $updatedCount');
      debugPrint('Not found: $notFoundCount');
      
      if (unmatchedFiles.isNotEmpty) {
        debugPrint('Unmatched files: ${unmatchedFiles.join(', ')}');
      }

      if (mounted && (importedCount > 0 || updatedCount > 0)) {
        String message = '';
        if (importedCount > 0) {
          message += 'Импортировано $importedCount новых песен';
        }
        if (updatedCount > 0) {
          if (message.isNotEmpty) message += ', ';
          message += 'обновлено путей: $updatedCount';
        }
        if (notFoundCount > 0) {
          if (message.isNotEmpty) message += ', ';
          message += 'не найдено: $notFoundCount';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error importing MP3 files: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mp3ImportError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _showLyricsSearchDialog() {
    final l10n = AppLocalizations.of(context)!;
    if (_songs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.importSongFirstToSearch),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final lastSong = _songs.last;

    showDialog(
      context: context,
      builder: (context) => LyricsSearchDialog(
        artist: lastSong.artist,
        title: lastSong.title,
        onLyricsFetched: (lyrics) {
          _handleLyricsFetched(lyrics, lastSong);
        },
      ),
    );
  }

  void _handleLyricsFetched(String lyrics, Song song) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lyricsFetched),
        content: Text(l10n.lyricsFoundUseCreate),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
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
    await prefs.setString('librarySortBy', sortBy);
    setState(() {
      _sortBy = sortBy;
    });
    if (sortBy == 'default') {
      _loadSongs();
    } else {
      _applySorting();
    }
  }

  Future<void> _deleteSelectedSongs() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSelectedSongs),
        content: Text(l10n.deleteMultipleSongsConfirm(_selectedSongs.length)),
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

    if (confirmed == true) {
      try {
        for (var song in _selectedSongs.values) {
          await _databaseService.deleteSong(song.id);
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
              content: Text(l10n.songsDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToRemoveSongs(e)),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _addSelectedSongsToPlaylist() async {
    final l10n = AppLocalizations.of(context)!;
    final playlists = await _playlistService.getAllPlaylists();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addMultipleSongsToPlaylistTitle(_selectedSongs.length)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                leading: Icon(_getPlaylistIcon(playlist.icon)),
                title: Text(playlist.name),
                onTap: () async {
                  try {
                    for (var song in _selectedSongs.values) {
                      await _playlistService.addSongToPlaylist(playlist.id, song.id);
                    }
                    if (mounted) {
                      final addedCount = _selectedSongs.length;
                      Navigator.pop(context);
                      setState(() {
                        _isSelectionMode = false;
                        _selectedSongs.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.addedMultipleSongsToPlaylist(addedCount, playlist.name))),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.failedToAddToPlaylistError(e)),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
     return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text(l10n.selectedSongsCount(_selectedSongs.length))
            : const Icon(Icons.library_music, size: 28),
        backgroundColor: _isSelectionMode
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.inversePrimary,
        actions: _isSelectionMode
            ? [
                TextButton.icon(
                  onPressed: _selectedSongs.isNotEmpty ? _addSelectedSongsToPlaylist : null,
                  icon: const Icon(Icons.playlist_add),
                  label: Text(AppLocalizations.of(context)!.addToPlaylistShort),
                ),
                TextButton.icon(
                  onPressed: _selectedSongs.isNotEmpty ? _deleteSelectedSongs : null,
                  icon: const Icon(Icons.delete),
                  label: Text(AppLocalizations.of(context)!.deleteShort),
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
                  child: Text(_selectedSongs.length == _songs.length 
                      ? AppLocalizations.of(context)!.deselectAllShort 
                      : AppLocalizations.of(context)!.selectAllShort),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSelectionMode,
                  tooltip: AppLocalizations.of(context)!.exitSelectionMode,
                ),
              ]
            : [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort_by_alpha),
                  tooltip: 'Sort songs',
                  onSelected: _sortSongs,
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
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: _toggleSelectionMode,
                  tooltip: AppLocalizations.of(context)!.addMultiple,
                ),
//                 IconButton(
//                   icon: const Icon(Icons.cloud_upload),
//                   onPressed: _importFromZip,
//                   tooltip: 'Import ZIP',
//                 ),
                IconButton(
                  icon: const Icon(Icons.cloud_download),
                  onPressed: _exportAllSongs,
                  tooltip: 'Export All',
                ),
//                  IconButton(
//                    icon: const Icon(Icons.folder),
//                    onPressed: _isImporting ? null : _importFolders,
//                    tooltip: 'Import Folders',
//                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _isImporting ? null : _importSong,
                    tooltip: 'Import Song',
                  ),
               ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading songs...')
          : _isImporting
              ? const LoadingWidget(message: 'Importing song...')
              : _songs.isEmpty
                  ? EmptyLibraryWidget(
                      onAddSong: _importSong,
                    )
                  : ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        final isSelected = _selectedSongs.containsKey(song.id);

                         return Dismissible(
                           key: Key(song.id),
                           onDismissed: _isSelectionMode ? null : (direction) {
                            _deleteSong(song, false);
                          },
                           confirmDismiss: _isSelectionMode ? null : (direction) async {
                             final l10n = AppLocalizations.of(context)!;
                             return await showDialog(
                               context: context,
                               builder: (context) => AlertDialog(
                                 title: Text(l10n.deleteSong),
                                 content: Text(l10n.deleteSongConfirm(song.title)),
                                 actions: [
                                   TextButton(
                                     onPressed: () => Navigator.of(context).pop(false),
                                     child: Text(l10n.cancel),
                                   ),
                                   TextButton(
                                     onPressed: () => Navigator.of(context).pop(true),
                                     child: Text(l10n.delete),
                                   ),
                                 ],
                               ),
                             );
                           },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
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
                            title: Text(song.title),
                            subtitle: Text(song.artist),
                             trailing: _isSelectionMode ? null : Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                  IconButton(
                                    icon: const Icon(Icons.playlist_add),
                                    onPressed: () => _addToPlaylist(song),
                                    tooltip: l10n.addToPlaylist,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.auto_awesome, color: !song.hasLyrics ? Colors.deepOrange : Theme.of(context).colorScheme.primary),
                                    onPressed: () => _showGenerateDialog(song),
                                    tooltip: l10n.generateLyrics,
                                  ),
                               ],
                             ),
                            onTap: _isSelectionMode ? () => _toggleSongSelection(song) : () => _openPlayer(song),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _FolderImportDialog extends StatefulWidget {
  @override
  State<_FolderImportDialog> createState() => _FolderImportDialogState();
}

class _FolderImportDialogState extends State<_FolderImportDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _manualPathController = TextEditingController();
  String? _musicFolder;
  String? _lyricsFolder;
  bool _sameFolderForLyrics = true;
  bool _isSelectingFolder = false;
  bool _useManualPath = false;
  Timer? _debounceTimer;
  final GlobalKey<_FolderImportDialogState> _dialogKey = GlobalKey<_FolderImportDialogState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Playlist ${DateTime.now().millisecondsSinceEpoch}';
    _manualPathController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manualPathController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _selectMusicFolder() async {
    if (_isSelectingFolder) {
      debugPrint('_selectMusicFolder: Already selecting, ignoring');
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSelectingFolder = true;
    });
    debugPrint('_selectMusicFolder: _isSelectingFolder set to true');

    try {
      if (Platform.isAndroid) {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final androidInfo = await deviceInfo.androidInfo;
          final sdkInt = androidInfo.version.sdkInt;

          debugPrint('=== _selectMusicFolder START ===');
          debugPrint('Android SDK: $sdkInt');
          debugPrint('Android version: ${androidInfo.version.release}');

          bool permissionGranted = false;

          if (sdkInt != null && sdkInt >= 33) {
            debugPrint('Requesting MANAGE_EXTERNAL_STORAGE permission for Android 13+');
            final status = await Permission.manageExternalStorage.request();
            debugPrint('Permission status: $status');

            if (!status.isGranted) {
              debugPrint('_selectMusicFolder: Permission NOT granted, showing dialog');
              if (mounted) {
                _showPermissionDialog(l10n, 'manageExternalStorage', _selectMusicFolder);
              }
              return;
            }
            permissionGranted = status.isGranted;
            debugPrint('_selectMusicFolder: Permission GRANTED');
          } else {
            debugPrint('Requesting STORAGE permission for Android < 13');
            final status = await Permission.storage.request();
            debugPrint('Permission status: $status');

            if (!status.isGranted) {
              debugPrint('_selectMusicFolder: Permission NOT granted, showing error');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.errorWithMessage('Storage permission denied')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
            permissionGranted = status.isGranted;
            debugPrint('_selectMusicFolder: Permission GRANTED');
          }

          if (!permissionGranted) {
            debugPrint('_selectMusicFolder: No permission, exiting');
            return;
          }
        } catch (e, stackTrace) {
          debugPrint('_selectMusicFolder: Error getting Android device info: $e');
          debugPrint('_selectMusicFolder: Stack trace: $stackTrace');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorWithMessage('Failed to get device info: $e')),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      debugPrint('_selectMusicFolder: Opening folder picker...');
      final result = await FilePicker.platform.getDirectoryPath();
      debugPrint('_selectMusicFolder: Folder picker result = $result');
      debugPrint('_selectMusicFolder: Result is null: ${result == null}');
      debugPrint('_selectMusicFolder: Result is empty: ${result?.isEmpty ?? false}');

      if (result == null || result.isEmpty) {
        debugPrint('_selectMusicFolder: No folder selected');
        if (mounted) {
          _showFolderPickerFallback(l10n);
        }
      } else if (mounted && !_useManualPath) {
        debugPrint('_selectMusicFolder: Checking if folder exists: $result');
        final dir = Directory(result);
        final exists = await dir.exists();
        debugPrint('_selectMusicFolder: Folder exists: $exists');

        if (exists) {
          debugPrint('_selectMusicFolder: Setting _musicFolder to: $result');
          setState(() {
            _musicFolder = result;
            if (_sameFolderForLyrics) {
              _lyricsFolder = result;
            }
          });
          debugPrint('_selectMusicFolder: _musicFolder and _lyricsFolder updated');
        } else {
          debugPrint('_selectMusicFolder: Selected folder does not exist');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorWithMessage('Selected folder does not exist')),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      debugPrint('_selectMusicFolder: SUCCESS');
    } catch (e, stackTrace) {
      debugPrint('_selectMusicFolder: ERROR: $e');
      debugPrint('_selectMusicFolder: Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _selectMusicFolder(),
            ),
          ),
        );
      }
    } finally {
      debugPrint('_selectMusicFolder: Finally block - resetting _isSelectingFolder');
      if (mounted) {
        setState(() {
          _isSelectingFolder = false;
        });
        debugPrint('_selectMusicFolder: _isSelectingFolder set to false');
      } else {
        debugPrint('_selectMusicFolder: Widget not mounted, skipping setState');
      }
    }
  }

  void _showPermissionDialog(AppLocalizations l10n, String permissionType, VoidCallback onRetry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storagePermissionRequired),
            const SizedBox(height: 8),
            Text(l10n.enableStoragePermission),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  void _showFolderPickerFallback(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Text(l10n.unableToSelectFolder),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _selectFilesInstead(l10n);
            },
            child: Text(l10n.selectFilesInstead),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFilesInstead(AppLocalizations l10n) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'flac'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final firstFile = result.files.first.path;
      if (firstFile != null) {
        final folder = path.dirname(firstFile);
        debugPrint('_selectFilesInstead: Setting folder from file: $folder');
        setState(() {
          _musicFolder = folder;
          if (_sameFolderForLyrics) {
            _lyricsFolder = folder;
          }
        });
      }
    }
  }

  Future<void> _setManualPath(AppLocalizations l10n) async {
    final manualPath = _manualPathController.text.trim();
    debugPrint('_setManualPath: Manual path entered: $manualPath');

    if (manualPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.enterFolderPath),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final dir = Directory(manualPath);
      final exists = await dir.exists();
      debugPrint('_setManualPath: Folder exists: $exists');

      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.folderDoesNotExist),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _musicFolder = manualPath;
        if (_sameFolderForLyrics) {
          _lyricsFolder = manualPath;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.folderSetWithPath(manualPath)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('_setManualPath: Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSettingFolder(e)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectLyricsFolder() async {
    if (_isSelectingFolder) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSelectingFolder = true;
    });

    try {
      if (Platform.isAndroid) {
        try {
          final deviceInfo = DeviceInfoPlugin();
          final androidInfo = await deviceInfo.androidInfo;
          final sdkInt = androidInfo.version.sdkInt;

          debugPrint('=== _selectLyricsFolder ===');
          debugPrint('Android SDK: $sdkInt');
          debugPrint('Android version: ${androidInfo.version.release}');

          bool permissionGranted = false;

          if (sdkInt != null && sdkInt >= 33) {
            debugPrint('Requesting MANAGE_EXTERNAL_STORAGE permission for Android 13+');
            final status = await Permission.manageExternalStorage.request();
            debugPrint('Permission status: $status');
            
            if (!status.isGranted) {
              if (mounted) {
                _showPermissionDialog(l10n, 'manageExternalStorage', _selectLyricsFolder);
              }
              return;
            }
            permissionGranted = status.isGranted;
          } else {
            debugPrint('Requesting STORAGE permission for Android < 13');
            final status = await Permission.storage.request();
            debugPrint('Permission status: $status');
            
            if (!status.isGranted) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.errorWithMessage('Storage permission denied')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              return;
            }
            permissionGranted = status.isGranted;
          }

          if (!permissionGranted) return;
        } catch (e) {
          debugPrint('Error getting Android device info: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorWithMessage('Failed to get device info: $e')),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      debugPrint('Opening folder picker...');
      final result = await FilePicker.platform.getDirectoryPath();
      debugPrint('Folder picker result: $result');

      if (result == null || result.isEmpty) {
        debugPrint('No folder selected');
        if (mounted) {
          _showLyricsFolderPickerFallback(l10n);
        }
      } else if (mounted) {
        final dir = Directory(result);
        final exists = await dir.exists();
        debugPrint('Folder exists: $exists');
        
        if (exists) {
          setState(() {
            _lyricsFolder = result;
          });
          debugPrint('Lyrics folder set to: $result');
        } else {
          debugPrint('Selected folder does not exist');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.errorWithMessage('Selected folder does not exist')),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error selecting lyrics folder: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _selectLyricsFolder(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingFolder = false;
        });
      }
    }
  }

  void _showLyricsFolderPickerFallback(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Text(l10n.unableToSelectLyricsFolder),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _selectLyricsFilesInstead(l10n);
            },
            child: Text(l10n.selectFilesInstead),
          ),
        ],
      ),
    );
  }

  Future<void> _selectLyricsFilesInstead(AppLocalizations l10n) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['lrc', 'json'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final firstFile = result.files.first.path;
      if (firstFile != null) {
        final folder = path.dirname(firstFile);
        setState(() {
          _lyricsFolder = folder;
        });
      }
    }
  }

   void _confirm() {
    final l10n = AppLocalizations.of(context)!;

    debugPrint('=== _confirm START ===');
    debugPrint('_confirm: playlistName = ${_nameController.text}');
    debugPrint('_confirm: musicFolder = $_musicFolder');
    debugPrint('_confirm: lyricsFolder = $_lyricsFolder');
    debugPrint('_confirm: sameFolderForLyrics = $_sameFolderForLyrics');

    if (_nameController.text.isEmpty) {
      debugPrint('_confirm: Name is empty, showing error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterPlaylistName)),
      );
      return;
    }

    if (_musicFolder == null) {
      debugPrint('_confirm: musicFolder is null, showing error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseSelectMusicFolder)),
      );
      return;
    }

    debugPrint('_confirm: All checks passed, calling Navigator.pop()');
    Navigator.of(context, rootNavigator: true).pop({
      'playlistName': _nameController.text,
      'musicFolder': _musicFolder,
      'lyricsFolder': _lyricsFolder,
    });
    debugPrint('_confirm: Navigator.pop() called successfully');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.importFolders),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💡 LRC and JSON files with lyrics must have THE SAME NAME as the audio file (without extension)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
             ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(l10n.useManualPath),
                subtitle: Text(l10n.enterFolderPathManually),
                value: _useManualPath,
                onChanged: (value) {
                  setState(() {
                    _useManualPath = value;
                  });
                },
              ),
             const SizedBox(height: 16),
             if (_useManualPath)
               Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _manualPathController,
                      decoration: InputDecoration(
                        labelText: l10n.folderPathLabel,
                        hintText: l10n.folderPathHint,
                        border: const OutlineInputBorder(),
                        helperText: l10n.fullPathToMusicFolder,
                      ),
                      onChanged: (value) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            setState(() {
                              _musicFolder = value.trim().isEmpty ? null : value.trim();
                              if (_sameFolderForLyrics) {
                                _lyricsFolder = value.trim().isEmpty ? null : value.trim();
                              }
                            });
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _setManualPath(l10n),
                      icon: const Icon(Icons.check_circle),
                      label: Text('📋 ${l10n.setPath}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                   const SizedBox(height: 16),
                 ],
               ),
             const SizedBox(height: 16),
             TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.playlistName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: _isSelectingFolder
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.music_note),
              title: Text(_musicFolder ?? l10n.selectMusicFolder),
              subtitle: Text(l10n.folderWithAudioFiles),
              trailing: _isSelectingFolder
                  ? null
                  : const Icon(Icons.folder_open),
              onTap: _isSelectingFolder ? null : _selectMusicFolder,
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              title: Text(l10n.sameFolderForLyrics),
              value: _sameFolderForLyrics,
              onChanged: _isSelectingFolder
                  ? null
                  : (value) {
                      setState(() {
                        _sameFolderForLyrics = value ?? true;
                        if (_sameFolderForLyrics) {
                          _lyricsFolder = _musicFolder;
                        }
                      });
                    },
            ),
            if (!_sameFolderForLyrics)
              ListTile(
                leading: _isSelectingFolder
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lyrics),
                title: Text(_lyricsFolder ?? l10n.selectLyricsFolder),
                subtitle: Text(l10n.folderWithLyricsFiles),
                trailing: _isSelectingFolder
                    ? null
                    : const Icon(Icons.folder_open),
                onTap: _isSelectingFolder ? null : _selectLyricsFolder,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _confirm,
          child: Text(l10n.createPlaylist),
        ),
      ],
    );
  }
}
