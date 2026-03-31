import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/models/lyric_line.dart';
import 'package:lingotune/models/translation.dart' show Translation;
import 'package:lingotune/models/loop_mode.dart';
import 'package:lingotune/services/translation_service.dart';
import 'package:lingotune/services/settings_provider.dart';
import 'package:lingotune/services/database_service.dart';
import 'package:lingotune/services/folder_config_service.dart';

class PlayerTranslationHelper {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> loadAllTranslations(
    BuildContext context,
    String songId,
    String songName,
    TranslationService translationService,
  ) async {
    try {
      debugPrint('=== DEBUG: Loading all translations for song: $songName ===');
      debugPrint('Song ID: $songId');

      translationService.clear();
      debugPrint('Translation service cleared before loading');

      final translationFiles = await _databaseService.getTranslationFiles(songId);

      debugPrint('Found ${translationFiles.length} translation files in database for song: $songName');

      if (translationFiles.isEmpty) {
        debugPrint('No translations in database, trying to scan folder...');

        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (context.mounted && settingsProvider.showTranslationMessages) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Переводов нет, сканируем папку...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }

        await scanAndAddTranslations(context, songId, songName, translationService);
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
              debugPrint('✓ Added translation: $languageName ($language) with ${lines.length} lines');
            }
            loadedCount++;
          }

          debugPrint('✓ Successfully loaded translation: $languageName');
        } catch (e) {
          debugPrint('✗ Error loading translation file $filePath: $e');
          errorCount++;
        }
      }

      debugPrint('=== All translations loaded for song: $songName ===');
      debugPrint('Total translations loaded: ${translationService.translations.length}');
      debugPrint('Successfully loaded: $loadedCount, Errors: $errorCount');

      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (context.mounted && settingsProvider.showTranslationMessages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Загружено переводов: ${translationService.translations.length}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading all translations: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (context.mounted && settingsProvider.showTranslationMessages) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки переводов: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> scanAndAddTranslations(
    BuildContext context,
    String songId,
    String songName,
    TranslationService translationService,
  ) async {
    try {
      debugPrint('=== DEBUG: Scanning and adding translations for song: $songName ===');

      final translationFiles = await FolderConfigService.findAllJsonFiles(songName);

      if (translationFiles.isEmpty) {
        debugPrint('No translation files found in folder for song: $songName');
        return;
      }

      int addedCount = 0;

      for (final tf in translationFiles) {
        try {
          final language = tf.language;
          final languageName = tf.languageName;
          final type = tf.type;
          final filePath = tf.filePath;

          await _databaseService.addTranslationFile(songId, language, languageName, filePath, type: type);
          addedCount++;

          debugPrint('Added translation to database: $languageName ($language) type: $type');
        } catch (e) {
          debugPrint('Error adding translation to database: $e');
        }
      }

      debugPrint('=== Added $addedCount translations to database for song: $songName ===');

      if (addedCount > 0) {
        await loadAllTranslations(context, songId, songName, translationService);
      }
    } catch (e) {
      debugPrint('Error scanning and adding translations: $e');
    }
  }

  Future<void> selectLanguageBasedOnSettings(
    BuildContext context,
    TranslationService translationService,
  ) async {
    if (translationService.translations.isEmpty) {
      debugPrint('⚠ No translations available');
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      if (context.mounted && settingsProvider.showTranslationMessages) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Переводов не найдено для этой песни'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    debugPrint('=== Available translations ===');
    for (int i = 0; i < translationService.translations.length; i++) {
      final t = translationService.translations[i];
      debugPrint('  [$i] ${t.languageName} (${t.language}) lines: ${t.lines.length}');
    }

    debugPrint('Selecting language from settings first...');
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final defaultLanguage = settingsProvider.defaultTranslationLanguage;
    debugPrint('Default translation language from settings: $defaultLanguage');

    final languagePriority = [defaultLanguage, 'ru', 'en', 'ro', 'fr', 'de', 'es', 'it', 'pt'];
    int selectedIndex = -1;

    for (final lang in languagePriority) {
      final index = translationService.translations.indexWhere((t) => t.language == lang);
      if (index != -1) {
        selectedIndex = index;
        debugPrint('✓ Found $lang at index $index');
        break;
      }
    }

    if (selectedIndex != -1) {
      debugPrint('✓ Selected translation at index $selectedIndex: ${translationService.translations[selectedIndex].languageName}');
      translationService.selectLanguage(selectedIndex);
      await Future.delayed(const Duration(milliseconds: 100));

      if (translationService.currentTranslation?.lines.isEmpty ?? true) {
        debugPrint('⚠ Selected translation has no lines, selecting first available');
        translationService.selectLanguage(0);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final selectedLanguage = translationService.currentTranslation;
      if (selectedLanguage != null) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (context.mounted && settingsProvider.showTranslationMessages) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Выбран язык: ${selectedLanguage.languageName}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      debugPrint('⚠ No match found in translations');
      final languageName = _getTranslationLanguageName(defaultLanguage);
      if (translationService.translations.isNotEmpty) {
        translationService.selectLanguage(0);
        await Future.delayed(const Duration(milliseconds: 100));

        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (context.mounted && settingsProvider.showTranslationMessages) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('В настройках выбран $languageName, но перевода нет. Открываю первый доступный: ${translationService.translations[0].languageName}'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }

    debugPrint('Current translation: ${translationService.currentTranslation?.languageName} (${translationService.currentTranslation?.language})');
    debugPrint('Translation has ${translationService.currentTranslation?.lines.length ?? 0} lines');
  }

  String _getTranslationLanguageName(String code) {
    switch (code) {
      case 'ru':
        return 'русский';
      case 'en':
        return 'английский';
      case 'ro':
        return 'румынский';
      case 'fr':
        return 'французский';
      case 'de':
        return 'немецкий';
      case 'es':
        return 'испанский';
      case 'it':
        return 'итальянский';
      case 'pt':
        return 'португальский';
      default:
        return 'Unknown';
    }
  }

  Future<void> updateLyricsWithTranslations(
    BuildContext context,
    List<LyricLine> lyricLines,
    TranslationService translationService,
  ) async {
    debugPrint('=== _updateLyricsWithTranslations called ===');

    final currentTranslation = translationService.currentTranslation;
    final transcriptTranslation = translationService.transcriptTranslation;

    debugPrint('Lines count: ${lyricLines.length}');
    debugPrint('Current translation: ${currentTranslation?.languageName} (${currentTranslation?.language})');
    debugPrint('Transcript translation: ${transcriptTranslation?.languageName} (${transcriptTranslation?.language})');
    debugPrint('Transcript has lines: ${transcriptTranslation?.lines.length ?? 0}');

    final prefs = await SharedPreferences.getInstance();
    final showTranscript = prefs.getBool('showTranscription') ?? false;

    debugPrint('Show transcript setting: $showTranscript');

    int translatedCount = 0;
    int transcriptCount = 0;

    for (final lyricLine in lyricLines) {
      if (currentTranslation != null) {
        final translatedText = translationService.getTranslationForLine(lyricLine.startTime);
        lyricLine.translatedText = translatedText;
        if (translatedText != null) translatedCount++;
      } else {
        lyricLine.translatedText = null;
      }

      if (showTranscript) {
        final transcriptText = translationService.getTranscriptForLine(lyricLine.startTime);
        final transcriptFromTranslation = transcriptText ??
            translationService.getTranscriptFromCurrentTranslation(lyricLine.startTime);

        if (transcriptFromTranslation != null) {
          lyricLine.transcript = transcriptFromTranslation;
          transcriptCount++;
        } else {
          lyricLine.transcript = null;
        }
      } else {
        lyricLine.transcript = null;
      }
    }

    debugPrint('Updated lyrics: $translatedCount translated, $transcriptCount transcript');
    debugPrint('=== _updateLyricsWithTranslations completed ===');
  }
}
