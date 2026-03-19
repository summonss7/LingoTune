import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import '../models/song.dart';
import 'database_service.dart';
import 'folder_config_service.dart';

enum ImportMode { merge, replace }

class ImportResult {
  final int fileCount;
  final bool hasDatabase;
  final File? databaseFile;
  final List<String> mp3Files;

  ImportResult({
    required this.fileCount,
    required this.hasDatabase,
    this.databaseFile,
    this.mp3Files = const [],
  });
}

class ExportImportService {
  static String _sanitizeFileName(String name) {
    if (name.isEmpty) return 'untitled';
    
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    String sanitized = name.replaceAll(invalidChars, '_');
    
    sanitized = sanitized.trim();
    if (sanitized.isEmpty) sanitized = 'untitled';
    
    return sanitized;
  }

  static Future<File?> exportSong(Song song) async {
    try {
      debugPrint('=== Export Song: ${song.title} ===');
      debugPrint('Song ID: ${song.id}');

      final sanitizedTitle = _sanitizeFileName(song.title);
      final tempDir = await getTemporaryDirectory();
      final zipFile = File(path.join(tempDir.path, '$sanitizedTitle.zip'));

      final archive = Archive();

      if (song.lrcPath != null && song.lrcPath!.isNotEmpty) {
        final lrcFile = File(song.lrcPath!);
        if (lrcFile.existsSync()) {
          final lrcBytes = await lrcFile.readAsBytes();
          final lrcFileName = '$sanitizedTitle.lrc';
          final archiveFile = ArchiveFile(lrcFileName, lrcBytes.length, lrcBytes);
          archive.addFile(archiveFile);
          debugPrint('Added LRC file: $lrcFileName');
        }
      }

      final db = DatabaseService();
      final translationFiles = await db.getTranslationFiles(song.id);
      debugPrint('Found ${translationFiles.length} JSON files for song: ${song.title}');

      for (final tf in translationFiles) {
        final filePath = tf['filePath'] as String;
        final language = tf['language'] as String;
        final languageName = tf['languageName'] as String;

        debugPrint('Processing translation: $languageName ($language) at $filePath');

        final file = File(filePath);
        if (file.existsSync()) {
          final jsonBytes = await file.readAsBytes();
          final jsonFileName = '${sanitizedTitle}_$language.json';
          final archiveFile = ArchiveFile(jsonFileName, jsonBytes.length, jsonBytes);
          archive.addFile(archiveFile);
          debugPrint('  ✓ Added JSON file: $jsonFileName');
        } else {
          debugPrint('  ✗ File not found: $filePath');
        }
      }

      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes != null) {
        await zipFile.writeAsBytes(zipBytes);
        debugPrint('Export completed: ${zipFile.path}');
        return zipFile;
      }

      return null;
    } catch (e) {
      debugPrint('Error exporting song: $e');
      return null;
    }
  }
  
  static Future<File?> exportAllSongs(List<Song> songs, {bool includeDatabase = true, bool includeMp3 = false}) async {
    try {
      debugPrint('=== Export All Songs: ${songs.length} songs ===');
      debugPrint('Include MP3: $includeMp3');

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final zipFile = File(path.join(tempDir.path, 'lingotune_export_$timestamp.zip'));

      final archive = Archive();
      final db = DatabaseService();

      for (final song in songs) {
        debugPrint('=== Processing song: ${song.title} ===');

        final sanitizedTitle = _sanitizeFileName(song.title);
        final songFolder = '$sanitizedTitle/';

        if (song.lrcPath != null && song.lrcPath!.isNotEmpty) {
          final lrcFile = File(song.lrcPath!);
          if (lrcFile.existsSync()) {
            final lrcBytes = await lrcFile.readAsBytes();
            final lrcFileName = '$songFolder$sanitizedTitle.lrc';
            final archiveFile = ArchiveFile(lrcFileName, lrcBytes.length, lrcBytes);
            archive.addFile(archiveFile);
            debugPrint('  ✓ Added LRC file: $lrcFileName');
          }
        }

        final translationFiles = await db.getTranslationFiles(song.id);
        debugPrint('  Found ${translationFiles.length} JSON files for song: ${song.title}');

        for (final tf in translationFiles) {
          final filePath = tf['filePath'] as String;
          final language = tf['language'] as String;
          final languageName = tf['languageName'] as String;

          debugPrint('  Processing translation: $languageName ($language)');

          final file = File(filePath);
          if (file.existsSync()) {
            final jsonBytes = await file.readAsBytes();
            final jsonFileName = '$songFolder${sanitizedTitle}_$language.json';
            final archiveFile = ArchiveFile(jsonFileName, jsonBytes.length, jsonBytes);
            archive.addFile(archiveFile);
            debugPrint('    ✓ Added JSON file: $jsonFileName');
          } else {
            debugPrint('    ✗ File not found: $filePath');
          }
        }

        if (includeMp3 && song.audioPath.isNotEmpty) {
          final audioFile = File(song.audioPath);
          if (audioFile.existsSync()) {
            final audioBytes = await audioFile.readAsBytes();
            final audioFileName = path.basename(audioFile.path);
            final archiveFileName = '$songFolder$sanitizedTitle${path.extension(audioFileName)}';
            final archiveFile = ArchiveFile(archiveFileName, audioBytes.length, audioBytes);
            archive.addFile(archiveFile);
            debugPrint('  ✓ Added MP3 file: $archiveFileName');
          }
        }
      }

      if (includeDatabase) {
        await _exportDatabase(archive);
      }

      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes != null) {
        await zipFile.writeAsBytes(zipBytes);
        debugPrint('Export all completed: ${zipFile.path}');
        return zipFile;
      }

      return null;
    } catch (e) {
      debugPrint('Error exporting all songs: $e');
      return null;
    }
  }
  
  static Future<void> shareExportFile(File zipFile, String description) async {
    try {
      await Share.shareXFiles(
        [XFile(zipFile.path)],
        subject: 'LingoTune Export',
        text: description,
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  static Future<void> _exportDatabase(Archive archive) async {
    try {
      debugPrint('=== Exporting database ===');

      final dbPath = await getDatabasesPath();
      final dbFile = File(path.join(dbPath, 'lingotune.db'));

      if (dbFile.existsSync()) {
        final dbBytes = await dbFile.readAsBytes();
        final archiveFile = ArchiveFile('lingotune.db', dbBytes.length, dbBytes);
        archive.addFile(archiveFile);
        debugPrint('Added database file: ${dbFile.path}');
      } else {
        debugPrint('Warning: Database file not found at ${dbFile.path}');
      }
    } catch (e) {
      debugPrint('Error exporting database: $e');
    }
  }

  static Archive _decodeArchive(List<int> bytes) {
    return ZipDecoder().decodeBytes(bytes);
  }

  static Future<List<File>> extractMp3Files(String zipPath, String tempDir) async {
    try {
      debugPrint('=== Extracting MP3 files from: $zipPath ===');

      final bytes = await File(zipPath).readAsBytes();
      final archive = await compute(_decodeArchive, bytes);

      final extractedFiles = <File>[];

      for (final file in archive.files) {
        final isDirectory = file.name.endsWith('/') || file.name.endsWith('\\');
        
        if (!isDirectory) {
          final fileName = file.name.toLowerCase();
          if (fileName.endsWith('.mp3') || fileName.endsWith('.m4a') || 
              fileName.endsWith('.wav') || fileName.endsWith('.ogg') || 
              fileName.endsWith('.flac')) {
            final filePath = path.join(tempDir, file.name);
            final outputFile = File(filePath);
            await outputFile.writeAsBytes(file.content as List<int>);
            extractedFiles.add(outputFile);
            debugPrint('✓ Extracted audio file: ${file.name}');
          }
        }
      }

      debugPrint('=== MP3 extraction completed: ${extractedFiles.length} files ===');
      return extractedFiles;
    } catch (e, stackTrace) {
      debugPrint('Error extracting MP3 files: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
  
  static Future<ImportResult> importFromZip(String zipPath, {bool importDatabase = false, bool extractMp3 = false}) async {
    try {
      debugPrint('=== Import from ZIP: $zipPath ===');
      debugPrint('Import database: $importDatabase');
      debugPrint('Extract MP3: $extractMp3');

      final bytes = await File(zipPath).readAsBytes();
      debugPrint('Archive size: ${bytes.length} bytes');

      final archive = await compute(_decodeArchive, bytes);
      debugPrint('Archive items: ${archive.files.length}');

      final folder = await FolderConfigService.getConfiguredFolder();
      if (folder == null) {
        debugPrint('ERROR: No folder configured for import');
        return ImportResult(fileCount: 0, hasDatabase: false);
      }

      debugPrint('Target folder: ${folder.path}');

      int importedCount = 0;
      bool hasDatabase = false;
      File? databaseFile;
      final extractedMp3Files = <String>[];

      debugPrint('=== Starting file extraction from archive ===');

      for (final file in archive.files) {
        final isDirectory = file.name.endsWith('/') || file.name.endsWith('\\');

        debugPrint('Item: ${file.name}, isDirectory: $isDirectory, size: ${file.size}');

        if (!isDirectory) {
          final fileName = file.name;
          final fileNameLower = fileName.toLowerCase();

          debugPrint('Processing file: $fileName');

          if (importDatabase && fileName == 'lingotune.db') {
            hasDatabase = true;
            final tempDir = await getTemporaryDirectory();
            databaseFile = File(path.join(tempDir.path, 'imported_lingotune.db'));
            await databaseFile.writeAsBytes(file.content as List<int>);
            debugPrint('✓ Found and extracted database file: $fileName');
            continue;
          }

          if (extractMp3 && (fileNameLower.endsWith('.mp3') || fileNameLower.endsWith('.m4a') || 
              fileNameLower.endsWith('.wav') || fileNameLower.endsWith('.ogg') || fileNameLower.endsWith('.flac'))) {
            final tempDir = await getTemporaryDirectory();
            final mp3TempPath = path.join(tempDir.path, 'imported_audio', fileName);
            final mp3File = File(mp3TempPath);
            await mp3File.create(recursive: true);
            await mp3File.writeAsBytes(file.content as List<int>);
            extractedMp3Files.add(mp3TempPath);
            debugPrint('✓ Extracted MP3 file: $fileName -> $mp3TempPath');
            continue;
          }

          final filePath = path.join(folder.path, fileName);

          debugPrint('Extracting: $fileName -> $filePath');

          final outputFile = File(filePath);

          await outputFile.writeAsBytes(file.content as List<int>);

          debugPrint('✓ Extracted successfully: $fileName');
          importedCount++;
        } else {
          debugPrint('Skipping directory: ${file.name}');
        }
      }

      debugPrint('=== Import completed ===');
      debugPrint('Imported files: $importedCount');
      debugPrint('Has database: $hasDatabase');
      debugPrint('Extracted MP3 files: ${extractedMp3Files.length}');

      if (extractMp3 && extractedMp3Files.isNotEmpty) {
        debugPrint('=== Copying MP3 files to configured folder ===');
        final finalMp3Paths = <String>[];

        for (final tempPath in extractedMp3Files) {
          final fileName = path.basename(tempPath);
          final finalPath = path.join(folder.path, fileName);

          try {
            final tempFile = File(tempPath);

            await tempFile.copy(finalPath);
            finalMp3Paths.add(finalPath);
            debugPrint('✓ Copied MP3: $fileName -> $finalPath');
          } catch (e) {
            debugPrint('✗ Error copying MP3 $fileName: $e');
          }
        }

        extractedMp3Files.clear();
        extractedMp3Files.addAll(finalMp3Paths);
        debugPrint('=== MP3 copy completed: ${finalMp3Paths.length} files ===');
      }

      return ImportResult(
        fileCount: importedCount,
        hasDatabase: hasDatabase,
        databaseFile: databaseFile,
        mp3Files: extractedMp3Files,
      );
    } catch (e, stackTrace) {
      debugPrint('=== ERROR importing from ZIP ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ImportResult(fileCount: 0, hasDatabase: false, mp3Files: []);
    }
  }

  static Future<void> importDatabase(File databaseFile, ImportMode mode, {String? newFolderPath}) async {
    try {
      debugPrint('=== Importing database (mode: $mode) ===');
      debugPrint('New folder path for rebasing: $newFolderPath');

      final dbPath = await getDatabasesPath();
      final targetDbFile = File(path.join(dbPath, 'lingotune.db'));

      if (mode == ImportMode.replace) {
        if (targetDbFile.existsSync()) {
          await targetDbFile.delete();
        }
        await databaseFile.copy(targetDbFile.path);
        debugPrint('Replaced database file');
        
        if (newFolderPath != null) {
          await DatabaseService().rebaseAllPaths(newFolderPath);
        }
      } else if (mode == ImportMode.merge) {
        await DatabaseService().mergeDatabase(databaseFile.path, newFolderPath: newFolderPath);
        debugPrint('Merged database file');
      }
    } catch (e) {
      debugPrint('Error importing database: $e');
      rethrow;
    }
  }

  static Future<List<String>> extractSongArchive(String zipPath, String targetDir, String baseName) async {
    try {
      debugPrint('=== Extract song archive: $zipPath ===');
      debugPrint('Target directory: $targetDir');
      debugPrint('Base name: $baseName');

      final bytes = await File(zipPath).readAsBytes();
      debugPrint('Archive size: ${bytes.length} bytes');

      final archive = await compute(_decodeArchive, bytes);
      debugPrint('Archive type: ${archive.runtimeType}');
      debugPrint('Archive files property: ${archive.files.length}');

      final extractedFiles = <String>[];

      debugPrint('=== Starting file iteration ===');
      debugPrint('Total items in archive: ${archive.files.length}');

      for (final file in archive.files) {
        final isDirectory = file.name.endsWith('/') || file.name.endsWith('\\');

        debugPrint('Processing file: ${file.name}, isDirectory: $isDirectory, size: ${file.size}');

        if (!isDirectory) {
          // Normalize separators and STRIP leading slashes to prevent absolute path escapes
          String fileName = file.name.replaceAll('\\', '/');
          while (fileName.startsWith('/')) {
            fileName = fileName.substring(1);
          }
          
          final filePath = path.join(targetDir, fileName);

          debugPrint('Extracting: $file.name -> $filePath');
          debugPrint('File content size: ${file.content?.length ?? 0}');

          final outputFile = File(filePath);
          if (!await outputFile.parent.exists()) {
            await outputFile.parent.create(recursive: true);
          }
          
          await outputFile.writeAsBytes(file.content as List<int>);
          extractedFiles.add(filePath);

          debugPrint('✓ Extracted successfully: $fileName');
        } else {
          debugPrint('Skipping directory: ${file.name}');
        }
      }

      debugPrint('=== Archive extraction completed ===');
      debugPrint('Total extracted files: ${extractedFiles.length}');
      debugPrint('Extracted files: ${extractedFiles.join(', ')}');

      return extractedFiles;
    } catch (e, stackTrace) {
      debugPrint('=== ERROR extracting song archive ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}