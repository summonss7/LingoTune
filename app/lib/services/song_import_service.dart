import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';
import '../models/song.dart';
import '../services/database_service.dart';
import '../services/cover_art_service.dart';
import '../services/folder_config_service.dart';
import '../services/playlist_service.dart';
import '../utils/snackbar_helper.dart';

class SongImportService {
  final DatabaseService _databaseService;
  final PlaylistService _playlistService;
  final CoverArtService _coverArtService;

  SongImportService({
    required DatabaseService databaseService,
    required PlaylistService playlistService,
    required CoverArtService coverArtService,
  })  : _databaseService = databaseService,
        _playlistService = playlistService,
        _coverArtService = coverArtService;

  Future<int> importAudioFiles({
    required BuildContext context,
    required List<String> audioPaths,
    String? playlistId,
  }) async {
    int importedCount = 0;
    int lrcFound = 0;
    int jsonFound = 0;
    int missingFiles = 0;

    for (final audioPath in audioPaths) {
      final fileName = path.basename(audioPath);
      final title = fileName.replaceAll(
        RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false),
        '',
      );
      final baseName = path.basenameWithoutExtension(audioPath);

      String? lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
      final translationFiles = await FolderConfigService.findAllJsonFiles(baseName);

      if (lrcPathToSave == null || translationFiles.isEmpty) {
        missingFiles++;
      }

      if (lrcPathToSave != null) lrcFound++;
      if (translationFiles.isNotEmpty) jsonFound++;

      final hasLyrics = lrcPathToSave != null || translationFiles.isNotEmpty;
      final song = Song(
        id: '${DateTime.now().millisecondsSinceEpoch}_$importedCount',
        title: title,
        artist: 'Unknown Artist',
        audioPath: audioPath,
        lrcPath: lrcPathToSave,
        translationsPath:
            translationFiles.isNotEmpty ? translationFiles.first.filePath : null,
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

      if (playlistId != null) {
        await _playlistService.addSongToPlaylist(playlistId, song.id);
      }

      importedCount++;
    }

    final message =
        'Imported $importedCount songs (LRC: $lrcFound, JSON: $jsonFound)';
    SnackBarHelper.showSuccess(context, message);

    return importedCount;
  }

  Future<Song?> importSingleAudio({
    required BuildContext context,
    required String audioPath,
  }) async {
    final fileName = path.basename(audioPath);
    final title = fileName.replaceAll(
      RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false),
      '',
    );
    final baseName = path.basenameWithoutExtension(audioPath);

    String? lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
    final translationFiles = await FolderConfigService.findAllJsonFiles(baseName);

    final hasLyrics = lrcPathToSave != null || translationFiles.isNotEmpty;

    if (!hasLyrics) {
      SnackBarHelper.showWarning(
        context,
        'No lyrics found. You can add them later.',
      );
    }

    final song = Song(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      artist: 'Unknown Artist',
      audioPath: audioPath,
      lrcPath: lrcPathToSave,
      translationsPath:
          translationFiles.isNotEmpty ? translationFiles.first.filePath : null,
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

    SnackBarHelper.showSuccess(context, 'Song imported successfully!');
    return song;
  }

  Future<int> importFromArchive({
    required BuildContext context,
    required String archivePath,
    String? playlistId,
  }) async {
    final tempDir = await Directory.systemTemp.createTemp();
    final tempPath = tempDir.path;

    try {
      await _extractArchive(archivePath, tempPath);

      final audioFiles = <String>[];
      final lrcFiles = <String>[];
      final jsonFiles = <String>[];

      for (final file in await tempDir.list()) {
        final path = file.path;
        if (path.endsWith('.mp3') ||
            path.endsWith('.wav') ||
            path.endsWith('.m4a')) {
          audioFiles.add(path);
        } else if (path.endsWith('.lrc')) {
          lrcFiles.add(path);
        } else if (path.endsWith('.json')) {
          jsonFiles.add(path);
        }
      }

      if (audioFiles.isEmpty) {
        SnackBarHelper.showError(context, 'No audio files found in archive');
        return 0;
      }

      int importedCount = 0;
      for (final audioPath in audioFiles) {
        final fileName = path.basename(audioPath);
        final baseName = path.basenameWithoutExtension(audioPath);

        final matchingLrc = lrcFiles.firstWhere(
          (lrc) => path.basename(lrc).startsWith(baseName),
          orElse: () => null as dynamic,
        );

        final matchingJsons = jsonFiles.where((json) =>
            path.basename(json).startsWith(baseName)).toList();

        final hasLyrics = matchingLrc != null || matchingJsons.isNotEmpty;
        final song = Song(
          id: '${DateTime.now().millisecondsSinceEpoch}_$importedCount',
          title: baseName,
          artist: 'Unknown Artist',
          audioPath: audioPath,
          lrcPath: matchingLrc?.path,
          translationsPath:
              matchingJsons.isNotEmpty ? matchingJsons.first.path : null,
          originalLanguage: 'unknown',
          hasLyrics: hasLyrics,
        );

        await _databaseService.insertSong(song);

        for (final jsonFile in matchingJsons) {
          try {
            final content = await File(jsonFile).readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            final translations = data['translations'] as List;

            for (final translation in translations) {
              await _databaseService.addTranslationFile(
                song.id,
                translation['language'] as String,
                translation['languageName'] as String,
                jsonFile,
                type: translation['type'] as String?,
              );
            }
          } catch (e) {
            debugPrint('Error parsing JSON: $e');
          }
        }

        if (playlistId != null) {
          await _playlistService.addSongToPlaylist(playlistId, song.id);
        }

        importedCount++;
      }

      SnackBarHelper.showSuccess(
        context,
        'Imported $importedCount songs from archive',
      );

      return importedCount;
    } finally {
      await tempDir.delete(recursive: true);
    }
  }

  Future<void> _extractArchive(String archivePath, String targetPath) async {
    final file = File(archivePath);
    if (!file.existsSync()) {
      throw Exception('Archive file does not exist');
    }

    final bytes = await file.readAsBytes();
    final directory = Directory(targetPath);
    
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }

    final archive = ZipDecoder().decodeBytes(bytes);
    
    for (final archiveFile in archive.files) {
      final filePath = path.join(targetPath, archiveFile.name);
      final outputFile = File(filePath);
      await outputFile.writeAsBytes(archiveFile.content);
    }
  }
}

