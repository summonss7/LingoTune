import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:lingotune/l10n/app_localizations.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/models/lyric_line.dart';
import 'package:lingotune/models/translation.dart' show Translation;
import 'package:lingotune/services/database_service.dart';
import 'package:lingotune/services/folder_config_service.dart';
import 'package:lingotune/services/translation_service.dart';
import 'package:lingotune/services/export_import_service.dart';

class PlayerImportHelper {
  final DatabaseService _databaseService = DatabaseService();

  Future<void> loadTranslationsFromFile(
    BuildContext context,
    Song song,
    TranslationService translationService,
  ) async {
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importTranslationDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_zip),
              title: Text(l10n.loadTranslationFromZip),
              onTap: () => Navigator.of(context).pop('zip'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: Text(l10n.loadTranslationFromJson),
              onTap: () => Navigator.of(context).pop('json'),
            ),
          ],
        ),
      ),
    );

    if (result == 'zip') {
      await loadTranslationFromZip(context, song, translationService);
    } else if (result == 'json') {
      await loadTranslationFromJson(context, song, translationService);
    }
  }

  Future<void> loadTranslationFromZip(
    BuildContext context,
    Song song,
    TranslationService translationService,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final zipPath = (result.files.single.path ?? result.files.single.identifier) as String;
        await processTranslationZipArchive(context, song, zipPath, translationService);
      } else {
        debugPrint('No file selected');
      }
    } catch (e) {
      debugPrint('Error loading translations from ZIP: $e');
      if (context.mounted) {
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

  Future<void> loadTranslationFromJson(
    BuildContext context,
    Song song,
    TranslationService translationService,
  ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          final filePath = (file.path ?? file.identifier) as String;
          await showLanguageInputDialog(context, File(filePath), song, translationService);
        }
      } else {
        debugPrint('No file selected');
      }
    } catch (e) {
      debugPrint('Error loading translations from JSON: $e');
      if (context.mounted) {
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

  Future<void> processTranslationZipArchive(
    BuildContext context,
    Song song,
    String zipPath,
    TranslationService translationService,
  ) async {
    try {
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
        return;
      }

      final baseName = song.title;

      final extractedFiles = await ExportImportService.extractSongArchive(
        zipPath,
        folder.path,
        baseName,
      );

      final scanResult = await scanTranslationsForSong(song, extractedFiles);
      final lrcFound = scanResult['lrcFound'] as int;
      final lrcPath = scanResult['lrcPath'] as String?;
      final translationsAdded = scanResult['translationsAdded'] as int;

      if (lrcFound > 0 && lrcPath != null) {
        await _databaseService.updateSongLrcPath(song.id, lrcPath);

        final l10n = AppLocalizations.of(context)!;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ LRC file loaded'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      if (translationsAdded > 0) {
        await loadAllTranslationsFromDatabase(context, song.id, song.title, translationService);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ $translationsAdded translation(s) loaded'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error processing ZIP archive: $e');
      if (context.mounted) {
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

  Future<Map<String, dynamic>> scanTranslationsForSong(
    Song song,
    List<String> extractedFiles,
  ) async {
    int translationsAdded = 0;
    int errorsCount = 0;
    int lrcFound = 0;
    String? lrcPathToSave;

    for (final filePath in extractedFiles) {
      final fileName = path_pkg.basename(filePath);

      if (fileName.endsWith('.lrc') || fileName.toLowerCase().endsWith('.lrc')) {
        lrcPathToSave = filePath;
        lrcFound++;
      } else if (fileName.endsWith('.json') || fileName.toLowerCase().endsWith('.json')) {
        try {
          final file = File(filePath);
          if (!await file.exists()) {
            errorsCount++;
            continue;
          }

          final content = await file.readAsString();
          final data = json.decode(content) as Map<String, dynamic>;

          if (!data.containsKey('translations') || data['translations'] == null) {
            errorsCount++;
            continue;
          }

          final translations = data['translations'] as List;
          if (translations.isEmpty) {
            errorsCount++;
            continue;
          }

          for (final t in translations) {
            try {
              final translationData = t as Map<String, dynamic>;

              final language = translationData['language'] as String? ?? 'unknown';
              final languageName = translationData['languageName'] as String? ?? 'Unknown';
              final type = translationData['type'] as String?;

              await _databaseService.addTranslationFile(
                song.id,
                language,
                languageName,
                filePath,
                type: type,
              );
              translationsAdded++;
            } catch (e) {
              errorsCount++;
            }
          }
        } catch (e) {
          errorsCount++;
        }
      }
    }

    return {
      'lrcFound': lrcFound,
      'lrcPath': lrcPathToSave,
      'translationsAdded': translationsAdded,
      'errorsCount': errorsCount,
    };
  }

  Future<void> showLanguageInputDialog(
    BuildContext context,
    File file,
    Song song,
    TranslationService translationService,
  ) async {
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
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
                    setDialogState(() {
                      selectedType = value;
                    });
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
      },
    );

    if (result != null) {
      await loadTranslationFile(file, result['name'], result['type'], song.id);
    }
  }

  Future<void> loadTranslationFile(
    File file,
    String languageName,
    String? type,
    String songId,
  ) async {
    try {
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
      }

      final fileContent = json.encode(data);
      await file.writeAsString(fileContent);
    } catch (e) {
      debugPrint('Error loading translation file: $e');
    }
  }

  Future<void> loadAllTranslationsFromDatabase(
    BuildContext context,
    String songId,
    String songName,
    TranslationService translationService,
  ) async {
    try {
      translationService.clear();
      await Future.delayed(const Duration(milliseconds: 50));

      final translationFiles = await _databaseService.getTranslationFiles(songId);

      for (final tf in translationFiles) {
        final filePath = tf['filePath'] as String;
        final language = tf['language'] as String;
        final languageName = tf['languageName'] as String;
        final type = tf['type'] as String?;

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
            }
          }
        } catch (e) {
          debugPrint('Error loading translation: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading translations from database: $e');
    }
  }
}
