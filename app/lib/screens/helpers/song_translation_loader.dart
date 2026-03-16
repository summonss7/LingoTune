import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/models/lyric_line.dart';
import 'package:lingotune/models/translation.dart' show Translation;
import 'package:lingotune/services/database_service.dart';
import 'package:lingotune/services/folder_config_service.dart';
import 'package:lingotune/services/translation_service.dart';

class SongTranslationLoader {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> loadAllTranslationsForPlayer(
    BuildContext context,
    Song song,
    TranslationService translationService,
  ) async {
    try {
      debugPrint('=== Loading translations for player: ${song.title} ===');
      debugPrint('Song ID: ${song.id}');

      translationService.clear();
      await Future.delayed(const Duration(milliseconds: 50));

      final translationFiles = await _databaseService.getTranslationFiles(song.id);
      debugPrint('Found ${translationFiles.length} translation files in database for song: ${song.title}');

      if (translationFiles.isEmpty) {
        debugPrint('No translations in database, trying to scan folder...');
        await scanAndAddTranslationsForPlayer(context, song.id, song.title, translationService);
        return;
      }

      debugPrint('Loading translations from database...');
      int loadedCount = 0;
      int errorCount = 0;

      for (final tf in translationFiles) {
        final filePath = tf['filePath'] as String;
        final language = tf['language'] as String;
        final languageName = tf['languageName'] as String;
        final type = tf['type'] as String?;

        debugPrint('Loading translation: $languageName ($language) type: $type from: $filePath');

        try {
          final file = File(filePath);
          if (!await file.exists()) {
            debugPrint('⚠ File does not exist: $filePath');
            errorCount++;
            continue;
          }

          final content = await file.readAsString();
          debugPrint('File content length: ${content.length} characters');

          final data = json.decode(content) as Map<String, dynamic>;

          if (data.containsKey('translations')) {
            final translations = data['translations'] as List;
            for (final t in translations) {
              final translationData = t as Map<String, dynamic>;

              final lines = (translationData['lines'] as List?)
                  ?.map((l) => LyricLine.fromJson(l as Map<String, dynamic>))
                  .toList() ?? [];

              final newTranslation = Translation(
                language: language,
                languageName: languageName,
                type: type,
                lines: lines,
                filePath: filePath,
              );

              translationService.addTranslation(newTranslation);
              debugPrint('✓ Added translation: $languageName ($language) with ${lines.length} lines');
            }
            loadedCount++;
          } else {
            debugPrint('⚠ No translations key in file: $filePath');
            errorCount++;
          }

          debugPrint('✓ Successfully loaded translation: $languageName');
        } catch (e) {
          debugPrint('✗ Error loading translation file $filePath: $e');
          debugPrint('Stack trace: ${StackTrace.current}');
          errorCount++;
        }
      }

      debugPrint('=== All translations loaded for player: ${song.title} ===');
      debugPrint('Total translations loaded: ${translationService.translations.length}');
      debugPrint('Successfully loaded: $loadedCount');
      debugPrint('Errors encountered: $errorCount');
    } catch (e) {
      debugPrint('Error loading translations for player: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> scanAndAddTranslationsForPlayer(
    BuildContext context,
    String songId,
    String songName,
    TranslationService translationService,
  ) async {
    try {
      debugPrint('=== Scanning and adding translations for player: $songName ===');
      debugPrint('Song ID: $songId');

      final translationFiles = await FolderConfigService.findAllJsonFiles(songName);

      if (translationFiles.isEmpty) {
        debugPrint('No translation files found in folder for song: $songName');
        return;
      }

      debugPrint('Found ${translationFiles.length} translation files in folder');
      for (final tf in translationFiles) {
        debugPrint('  - ${tf.languageName} (${tf.language}) type: ${tf.type}');
      }

      int addedCount = 0;
      int errorCount = 0;

      for (final tf in translationFiles) {
        try {
          final language = tf.language;
          final languageName = tf.languageName;
          final type = tf.type;
          final filePath = tf.filePath;

          await _databaseService.addTranslationFile(songId, language, languageName, filePath, type: type);
          addedCount++;

          debugPrint('✓ Added translation to database: $languageName ($language) type: $type');

          final file = File(filePath);
          final content = await file.readAsString();
          final data = json.decode(content) as Map<String, dynamic>;

          if (data.containsKey('translations')) {
            final translations = data['translations'] as List;
            for (final t in translations) {
              final translationData = t as Map<String, dynamic>;
              final lines = (translationData['lines'] as List?)
                  ?.map((l) => LyricLine.fromJson(l as Map<String, dynamic>))
                  .toList() ?? [];

              final newTranslation = Translation(
                language: language,
                languageName: languageName,
                type: type,
                lines: lines,
                filePath: filePath,
              );

              translationService.addTranslation(newTranslation);
            }
          }
        } catch (e) {
          debugPrint('✗ Error adding translation to database: $e');
          debugPrint('Stack trace: ${StackTrace.current}');
          errorCount++;
        }
      }

      debugPrint('=== Scan completed for player: $songName ===');
      debugPrint('Added to database: $addedCount');
      debugPrint('Errors: $errorCount');
      debugPrint('Total translations in service: ${translationService.translations.length}');
    } catch (e) {
      debugPrint('Error scanning translations for player: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }
}
