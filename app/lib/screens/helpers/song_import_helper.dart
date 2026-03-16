import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:lingotune/l10n/app_localizations.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/services/database_service.dart';
import 'package:lingotune/services/folder_config_service.dart';
import 'package:lingotune/services/playlist_service.dart';
import 'package:lingotune/services/export_import_service.dart';
import 'package:uuid/uuid.dart';

class SongImportHelper {
  final DatabaseService _databaseService = DatabaseService();
  final PlaylistService _playlistService = PlaylistService();
  final Uuid _uuid = const Uuid();

  Future<void> importAudioOnlyInternal(
    String title,
    String audioPath,
    Function setState,
    BuildContext context,
    List<Song> songs,
    bool isMounted,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        setState(() {
        });

        if (isMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noAudioFilesSelected),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final audioFiles = <String>[];

      for (final file in result.files) {
        if (file.path != null) {
          audioFiles.add(file.path!);
        }
      }

      if (audioFiles.isEmpty) {
        setState(() {
        });

        if (isMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noAudioFilesSelected),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      int importedCount = 0;
      int lrcFound = 0;
      int jsonFound = 0;
      int missingFiles = 0;

      for (final audioPath in audioFiles) {
        debugPrint('=== DEBUG: Import Song $importedCount ===');
        debugPrint('Audio path: $audioPath');

        final fileName = path.basename(audioPath);
        final baseName = path.basenameWithoutExtension(audioPath);

        debugPrint('File name: $fileName');
        debugPrint('Base name: $baseName');

        String? lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
        final translationFiles = await FolderConfigService.findAllJsonFiles(baseName);

        debugPrint('LRC path found: $lrcPathToSave');
        debugPrint('Translation files found: ${translationFiles.length}');

        if (lrcPathToSave == null || translationFiles.isEmpty) {
          debugPrint('Missing files detected');
          missingFiles++;
          final action = await showMissingFilesDialog(
            context,
            baseName,
            lrcPathToSave == null,
            translationFiles.isEmpty,
          );

          if (action == 'audio_only') {
            await importAudioOnlyInternal(baseName, audioPath, setState, context, songs, isMounted);
            continue;
          } else {
            lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
            final newTranslationFiles = await FolderConfigService.findAllJsonFiles(baseName);
            if (newTranslationFiles.isNotEmpty) {
              translationFiles.clear();
              translationFiles.addAll(newTranslationFiles);
            }
          }
        }

        if (lrcPathToSave != null) lrcFound++;
        if (translationFiles.isNotEmpty) jsonFound++;

        final hasLyrics = lrcPathToSave != null || translationFiles.isNotEmpty;
        final song = Song(
          id: _uuid.v4(),
          title: title,
          artist: 'Unknown Artist',
          audioPath: audioPath,
          lrcPath: lrcPathToSave,
          translationsPath: translationFiles.isNotEmpty ? translationFiles.first.filePath : null,
          originalLanguage: 'unknown',
          hasLyrics: hasLyrics,
        );

        await _databaseService.insertSong(song);

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
      }

      setState(() {
      });

      if (isMounted) {
        String message = 'Successfully imported $importedCount song(s)';

        if (lrcFound > 0 || jsonFound > 0) {
          message += '\n';
          if (lrcFound > 0) message += '✓ LRC: $lrcFound, ';
          if (jsonFound > 0) message += '✓ JSON: $jsonFound';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          message += '\n\nNo LRC or JSON files found.';
          message += '\nSelect them together with MP3 files.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
      });

      if (isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToImportSongs(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> showMissingFilesDialog(
    BuildContext context,
    String songName,
    bool missingLrc,
    bool missingJson,
  ) async {
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
      await addMissingFiles(context, songName, missingLrc, missingJson);
    }

    return result;
  }

  Future<void> addMissingFiles(
    BuildContext context,
    String songName,
    bool needLrc,
    bool needJson,
  ) async {
    if (needLrc) {
      await copyLrcWithRetry(context, songName);
    }

    if (needJson) {
      await copyJsonFilesWithRetry(context, songName);
    }
  }

  Future<void> copyLrcWithRetry(BuildContext context, String songName) async {
    final l10n = AppLocalizations.of(context)!;
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
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.failedToCopyLrcFile),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: l10n.retry,
                  textColor: Colors.white,
                  onPressed: () => copyLrcWithRetry(context, songName),
                ),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> copyJsonFilesWithRetry(BuildContext context, String songName) async {
    debugPrint('=== Selecting JSON files for song: $songName ===');

    final l10n = AppLocalizations.of(context)!;
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

      if (successCount > 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${l10n.copiedJsonFiles(successCount)}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✗ ${l10n.failedToCopyJsonFiles}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: l10n.retry,
                textColor: Colors.white,
                onPressed: () => copyJsonFilesWithRetry(context, songName),
              ),
            ),
          );
        }
      }
    }
  }
}
