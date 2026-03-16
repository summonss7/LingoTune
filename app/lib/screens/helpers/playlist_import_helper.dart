import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:lingotune/l10n/app_localizations.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/models/playlist.dart';
import 'package:lingotune/services/database_service.dart';
import 'package:lingotune/services/folder_config_service.dart';
import 'package:lingotune/services/playlist_service.dart';
import 'package:lingotune/services/export_import_service.dart';

class PlaylistImportHelper {
  final DatabaseService _databaseService = DatabaseService();
  final PlaylistService _playlistService = PlaylistService();

  Future<void> importSong(
    BuildContext context,
    Playlist playlist,
    Function setState,
    List<Song> songs,
  ) async {
    if (!context.mounted) return;

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
      await importAudioOnly(context, playlist, setState, songs);
    } else if (result == 'archive') {
      await importSongWithArchive(context, playlist, setState, songs);
    }
  }

  Future<void> importAudioOnly(
    BuildContext context,
    Playlist playlist,
    Function setState,
    List<Song> songs,
  ) async {
    debugPrint('=== Starting importAudioOnly to playlist ===');

    setState(() {
    });

    try {
      final audioResult = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (audioResult == null || audioResult.files.isEmpty) {
        setState(() {
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
        });
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      int importedCount = 0;

      for (final audioPath in audioFiles) {
        debugPrint('=== DEBUG: Import Song $importedCount to playlist ===');
        debugPrint('Audio path: $audioPath');

        final fileName = path.basename(audioPath);
        final title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false), '');
        final baseName = path.basenameWithoutExtension(audioPath);

        debugPrint('File name: $fileName');
        debugPrint('Base name: $baseName');
        debugPrint('Title: $title');

        String? lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
        final translationFiles = await FolderConfigService.findAllJsonFiles(baseName);

        debugPrint('LRC path found: $lrcPathToSave');
        debugPrint('Translation files found: ${translationFiles.length}');

        final hasLyrics = lrcPathToSave != null || translationFiles.isNotEmpty;
        final song = Song(
          id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}_$importedCount',
          title: title,
          artist: 'Unknown Artist',
          audioPath: audioPath,
          lrcPath: lrcPathToSave,
          translationsPath: translationFiles.isNotEmpty ? translationFiles.first.filePath : null,
          originalLanguage: 'unknown',
          hasLyrics: hasLyrics,
        );

        await _databaseService.insertSong(song);
        await _playlistService.addSongToPlaylist(playlist.id, song.id);

        int translationsAdded = 0;
        int errorsCount = 0;
        for (final tf in translationFiles) {
          try {
            await _databaseService.addTranslationFile(
              song.id,
              tf.language,
              tf.languageName,
              tf.filePath,
              type: tf.type,
            );
            translationsAdded++;
          } catch (e) {
            debugPrint('✗ Error adding translation ${tf.languageName}: $e');
            errorsCount++;
          }
        }

        songs.add(song);
        importedCount++;
        debugPrint('✓ Successfully imported song: ${song.title}');
        debugPrint('  Translations added: $translationsAdded, Errors: $errorsCount');
      }

      setState(() {
      });

      if (context.mounted) {
        String message = 'Successfully imported $importedCount song(s) to playlist';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
      });

      debugPrint('Error in importAudioOnly to playlist: $e');
      debugPrint('Stack trace: ${StackTrace.current}');

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToImportSongs(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> importSongWithArchive(
    BuildContext context,
    Playlist playlist,
    Function setState,
    List<Song> songs,
  ) async {
    debugPrint('=== Starting importSongWithArchive to playlist ===');

    setState(() {
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
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No audio file selected'),
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
        dialogTitle: 'Select ZIP archive with lyrics for "$title"',
      );

      if (zipResult == null || zipResult.files.isEmpty || zipResult.files.single.path == null) {
        debugPrint('No ZIP archive selected');
        setState(() {
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No ZIP archive selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final zipPath = zipResult.files.single.path!;
      debugPrint('ZIP selected: $zipPath');

      final folder = await FolderConfigService.getConfiguredFolder();
      if (folder == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No folder configured'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
        });
        return;
      }

      debugPrint('Configured folder: ${folder.path}');

      debugPrint('Step 3: Extract archive');
      final extractedFiles = await ExportImportService.extractSongArchive(
        zipPath,
        folder.path,
        baseName,
      );

      debugPrint('Extracted ${extractedFiles.length} files from archive');

      int lrcFound = 0;
      int jsonFound = 0;
      String? lrcPathToSave;

      debugPrint('Step 4: Analyzing extracted files');
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
        }
      }

      debugPrint('File analysis complete: $lrcFound LRC, $jsonFound JSON');

      final hasLyrics = lrcPathToSave != null || jsonFound > 0;
      final song = Song(
        id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}',
        title: title,
        artist: 'Unknown Artist',
        audioPath: audioPath,
        lrcPath: lrcPathToSave,
        translationsPath: jsonFound > 0 ? extractedFiles.firstWhere((f) => f.endsWith('.json') || f.toLowerCase().endsWith('.json'), orElse: () => extractedFiles.first) : null,
        originalLanguage: 'unknown',
        hasLyrics: hasLyrics,
      );

      await _databaseService.insertSong(song);
      await _playlistService.addSongToPlaylist(playlist.id, song.id);

      for (final filePath in extractedFiles) {
        final fileName = path.basename(filePath);
        if (fileName.endsWith('.json') || fileName.toLowerCase().endsWith('.json')) {
          final langCode = path.basenameWithoutExtension(fileName).split('_').last;
          final langName = langCode.toUpperCase();
          try {
            await _databaseService.addTranslationFile(
              song.id,
              langCode,
              langName,
              filePath,
              type: 'json',
            );
          } catch (e) {
            debugPrint('✗ Error adding translation $langName: $e');
          }
        }
      }

      songs.add(song);
      debugPrint('✓ Successfully imported song: ${song.title}');

      setState(() {
      });

      if (context.mounted) {
        String message = '✓ Imported: "$title"';
        message += '\n📁 $lrcFound LRC, $jsonFound JSON files';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
      });

      debugPrint('=== ERROR in importSongWithArchive to playlist ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToImportSongs(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
