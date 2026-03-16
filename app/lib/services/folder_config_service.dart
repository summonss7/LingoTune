import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TranslationFile {
  final String filePath;
  final String language;
  final String languageName;
  final String? type;

  TranslationFile({
    required this.filePath,
    required this.language,
    required this.languageName,
    this.type,
  });

  @override
  String toString() {
    return 'TranslationFile(filePath: $filePath, language: $language, languageName: $languageName, type: $type)';
  }
}

class FolderConfigService {
  static const String _prefKeyCustomFolder = 'customLrcJsonFolder';
  static const String _prefKeyUseCustom = 'useCustomFolder';
  static const String _defaultFolderName = 'LingoTune_Lyrics';

  static Future<Directory> getDefaultFolder() async {
    final directory = await getExternalStorageDirectory();
    final lyricsFolder = Directory(path.join(directory!.parent.path, _defaultFolderName));

    if (!lyricsFolder.existsSync()) {
      await lyricsFolder.create(recursive: true);
    }

    return lyricsFolder;
  }

  static Future<Directory?> getConfiguredFolder() async {
    final prefs = await SharedPreferences.getInstance();
    final useCustom = prefs.getBool(_prefKeyUseCustom) ?? true;

    if (!useCustom) return null;

    final customPath = prefs.getString(_prefKeyCustomFolder);
    if (customPath != null && customPath.isNotEmpty) {
      final folder = Directory(customPath);
      if (folder.existsSync()) {
        return folder;
      }
    }

    return getDefaultFolder();
  }

  static Future<bool> setCustomFolder(String folderPath) async {
    final folder = Directory(folderPath);

    if (!folder.existsSync()) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyCustomFolder, folderPath);
    await prefs.setBool(_prefKeyUseCustom, true);

    return true;
  }

  static Future<void> disableCustomFolder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyUseCustom, false);
  }

  static Future<List<TranslationFile>> findAllJsonFiles(String songName) async {
    debugPrint('=== FolderConfigService.findAllJsonFiles ===');
    debugPrint('Song name: $songName');

    final folder = await getConfiguredFolder();
    if (folder == null) {
      debugPrint('ERROR: No folder configured');
      return [];
    }

    debugPrint('Configured folder: ${folder.path}');

    final standardSuffixes = ['_ru', '_en', '_ro', '_fr', '_de', '_es', '_it', '_pt'];
    final List<TranslationFile> translationFiles = [];
    final Set<String> processedFiles = {};

    final files = await folder.list().toList();
    final songNameLower = songName.toLowerCase();

    debugPrint('=== Scanning folder for JSON files ===');
    debugPrint('Total files in folder: ${files.length}');

    for (final f in files) {
      if (f is File) {
        final fileName = path.basename(f.path);
        final fileNameLower = fileName.toLowerCase();

        debugPrint('Checking file: $fileName');

        if (!fileNameLower.startsWith(songNameLower) || !fileNameLower.endsWith('.json')) {
          debugPrint('  → Skipped (does not match song name: $songNameLower');
          continue;
        }

        final filePath = f.path;
        if (processedFiles.contains(filePath)) {
          debugPrint('  → Skipped (already processed)');
          continue;
        }

        processedFiles.add(filePath);

        String language = 'unknown';
        String languageName = 'Unknown';
        String? type;

        final file = File(filePath);
        try {
          final content = await file.readAsString();
          final data = json.decode(content) as Map<String, dynamic>;

          if (data.containsKey('translations') && data['translations'] != null) {
            final translations = data['translations'] as List;
            if (translations.isNotEmpty) {
              final translation = translations[0] as Map<String, dynamic>;
              language = translation['language'] as String? ?? 'unknown';
              languageName = translation['languageName'] as String? ?? 'Unknown';
              type = translation['type'] as String?;

              if (type != null && languageName == 'Транскрипция') {
                language = 'transcript';
              }
            }
          }
        } catch (e) {
          debugPrint('  ✗ Error reading JSON file $filePath: $e');
          continue;
        }

        translationFiles.add(TranslationFile(
          filePath: filePath,
          language: language,
          languageName: languageName,
          type: type,
        ));

        debugPrint('  ✓ Found translation file: $languageName ($language) type: $type');
      }
    }

    translationFiles.sort((a, b) {
      int langCompare = a.language.compareTo(b.language);
      if (langCompare != 0) return langCompare;

      String typeA = a.type ?? '';
      String typeB = b.type ?? '';
      return typeA.compareTo(typeB);
    });

    debugPrint('=== Found ${translationFiles.length} translation files for song: $songName ===');
    debugPrint('Files found: ${translationFiles.map((t) => '${t.languageName} (${t.language})').join(', ')}');

    return translationFiles;
  }

  static Future<String?> findLrcFile(String songName) async {
    debugPrint('=== FolderConfigService.findLrcFile ===');
    debugPrint('Song name: $songName');

    final folder = await getConfiguredFolder();
    if (folder == null) {
      debugPrint('ERROR: No folder configured');
      return null;
    }

    debugPrint('Configured folder: ${folder.path}');

    final lrcPath = path.join(folder.path, '$songName.lrc');
    debugPrint('Looking for LRC file at: $lrcPath');

    final file = File(lrcPath);
    final exists = file.existsSync();
    debugPrint('LRC file exists: $exists');

    if (exists) {
      debugPrint('LRC file found at: $lrcPath');
      return lrcPath;
    }

    debugPrint('LRC file not found directly, trying case-insensitive search...');
    final files = await folder.list().toList();
    for (final f in files) {
      if (f is File) {
        final fileName = path.basename(f.path);
        final fileNameLower = fileName.toLowerCase();
        final songNameLower = '$songName.lrc'.toLowerCase();

        if (fileNameLower == songNameLower) {
          debugPrint('Found LRC file (case-insensitive): ${f.path}');
          return f.path;
        }
      }
    }
    debugPrint('LRC file not found in case-insensitive search');
    return null;
  }

  static Future<String?> findJsonFile(String songName) async {
    debugPrint('=== FolderConfigService.findJsonFile ===');
    debugPrint('Song name: $songName');

    final folder = await getConfiguredFolder();
    if (folder == null) {
      debugPrint('ERROR: No folder configured');
      return null;
    }

    debugPrint('Configured folder: ${folder.path}');

    final standardSuffixes = ['_ru', '_en', '_ro', '_fr', '_de', '_es', '_it', '_pt'];

    final basePath = path.join(folder.path, '$songName.json');
    final baseFile = File(basePath);

    if (baseFile.existsSync()) {
      debugPrint('Found base JSON file: $basePath');
      return basePath;
    }

    debugPrint('Base JSON not found, searching with suffixes...');
    for (final suffix in standardSuffixes) {
      final suffixPath = path.join(folder.path, '${songName}$suffix.json');
      final suffixFile = File(suffixPath);

      if (suffixFile.existsSync()) {
        debugPrint('Found JSON file with suffix: $suffixPath');
        return suffixPath;
      }
    }

    debugPrint('Searching case-insensitive...');
    final files = await folder.list().toList();
    final songNameLower = songName.toLowerCase();

    for (final f in files) {
      if (f is File) {
        final fileName = path.basename(f.path).toLowerCase();

        if (fileName.startsWith(songNameLower) && fileName.endsWith('.json')) {
          debugPrint('Found JSON file (case-insensitive): ${f.path}');
          return f.path;
        }
      }
    }

    debugPrint('JSON file not found');
    return null;
  }

  static Future<bool> copyLrcFile(String sourcePath, String songName) async {
    final folder = await getConfiguredFolder();
    if (folder == null) return false;

    final destPath = path.join(folder.path, '$songName.lrc');
    final sourceFile = File(sourcePath);
    final destFile = File(destPath);

    try {
      await sourceFile.copy(destPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> copyJsonFile(String sourcePath, String songName) async {
    final folder = await getConfiguredFolder();
    if (folder == null) return false;

    final destPath = path.join(folder.path, '$songName.json');
    final sourceFile = File(sourcePath);
    final destFile = File(destPath);

    try {
      await sourceFile.copy(destPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteLrcFile(String songName) async {
    final folder = await getConfiguredFolder();
    if (folder == null) return false;

    final lrcPath = path.join(folder.path, '$songName.lrc');
    final lrcFile = File(lrcPath);

    try {
      if (lrcFile.existsSync()) {
        await lrcFile.delete();
        debugPrint('LRC file deleted: $lrcPath');
        return true;
      }
      debugPrint('LRC file not found: $lrcPath');
      return false;
    } catch (e) {
      debugPrint('Error deleting LRC file: $e');
      return false;
    }
  }

  static Future<bool> deleteJsonFile(String songName) async {
    final folder = await getConfiguredFolder();
    if (folder == null) return false;

    final jsonPath = path.join(folder.path, '$songName.json');
    final jsonFile = File(jsonPath);

    try {
      if (jsonFile.existsSync()) {
        await jsonFile.delete();
        debugPrint('JSON file deleted: $jsonPath');
        return true;
      }
      debugPrint('JSON file not found: $jsonPath');
      return false;
    } catch (e) {
      debugPrint('Error deleting JSON file: $e');
      return false;
    }
  }

  static Future<String> getFolderDisplayPath() async {
    final folder = await getConfiguredFolder();
    if (folder == null) return 'Disabled';

    return folder.path;
  }
}
