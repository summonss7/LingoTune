import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../services/database_service.dart';
import '../services/playlist_service.dart';
import 'folder_config_service.dart';
import 'export_import_service.dart';

class FolderImportProgress {
  final int totalFiles;
  final int currentFile;
  final int foundSongs;
  final String currentFileName;
  final double progress;

  FolderImportProgress({
    required this.totalFiles,
    required this.currentFile,
    required this.foundSongs,
    required this.currentFileName,
    required this.progress,
  });
}

class FolderImportResult {
  final Playlist? playlist;
  final int importedCount;
  final String error;

  FolderImportResult({
    required this.playlist,
    required this.importedCount,
    this.error = '',
  });

  bool get isSuccess => error.isEmpty;
}

class FolderImportService {
  final DatabaseService _databaseService;
  final PlaylistService _playlistService;

  FolderImportService({
    required DatabaseService databaseService,
    required PlaylistService playlistService,
  })  : _databaseService = databaseService,
        _playlistService = playlistService;

  Future<String> _getInternalLyricsDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final lyricsDir = Directory(path.join(docsDir.path, 'lyrics'));
    if (!await lyricsDir.exists()) {
      await lyricsDir.create(recursive: true);
    }
    return lyricsDir.path;
  }

  Future<String?> _persistLyricsFile(String sourcePath, String songId) async {
    try {
      final internalDir = await _getInternalLyricsDirectory();
      final sourceFileName = path.basename(sourcePath);
      final safeName = '${songId}_$sourceFileName'
          .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
          .replaceAll(' ', '_');
      final targetPath = path.join(internalDir, safeName);
      
      final sourceFile = File(sourcePath);
      final targetFile = File(targetPath);

      if (path.canonicalize(sourcePath) == path.canonicalize(targetPath)) {
        return targetPath;
      }

      if (await sourceFile.exists()) {
        final bytes = await sourceFile.readAsBytes();
        await targetFile.writeAsBytes(bytes, flush: true);
        debugPrint('✅ Import: Persisted to: $targetPath');
        return targetPath;
      }
    } catch (e) {
      debugPrint('❌ Import persistence error for $sourcePath: $e');
    }
    return null;
  }

  /// Generate a stable ID based on normalized audio path
  String _generateSongId(String audioPath) {
    final norm = _databaseService.normalizePathForSync(audioPath);
    int hash = 2166136261;
    for (int i = 0; i < norm.length; i++) {
      hash = (hash ^ norm.codeUnitAt(i)) * 16777619;
      hash &= 0xFFFFFFFF;
    }
    return 'song_${hash.toRadixString(36).padLeft(8, '0')}';
  }

  Future<FolderImportResult> importFolders({
    required String playlistName,
    required String musicFolderPath,
    required String? lyricsFolderPath,
    required Function(FolderImportProgress) onProgress,
    required Function() onCancel,
  }) async {
    int importedCount = 0;
    int processedFiles = 0;
    bool shouldCancel = false;
    String? error;

    try {
      final musicDir = Directory(musicFolderPath);
      if (!(await musicDir.exists())) {
        return FolderImportResult(
          playlist: Playlist(
            id: '',
            name: '',
            isSystem: false,
            createdAt: DateTime.now(),
          ),
          importedCount: 0,
          error: 'Music folder does not exist',
        );
      }

      final playlistId = '${DateTime.now().millisecondsSinceEpoch}';
      final playlist = Playlist(
        id: playlistId,
        name: playlistName,
        icon: 'folder',
        isSystem: false,
        musicFolderPath: musicFolderPath,
        lyricsFolderPath: lyricsFolderPath,
      );

      await _playlistService.insertPlaylist(playlist);

      // Cleanup existing chaos from database before sync
      await _databaseService.deduplicateSongs();

      final files = await musicDir.list().toList();
      final audioFiles = files.where((f) => f is File && _isAudioFile(f.path)).toList();

      onProgress(FolderImportProgress(
        totalFiles: audioFiles.length,
        currentFile: 0,
        foundSongs: 0,
        currentFileName: 'Scanning files...',
        progress: 0.0,
      ));

      Map<String, List<TranslationFile>>? translationCache;
      if (lyricsFolderPath != null) {
        translationCache = await _preloadTranslationFiles(lyricsFolderPath);
      }

      final songsToInsert = <Song>[];
      final songToTranslationsMap = <String, List<TranslationFile>>{};
      final playlistSongs = <String, int>{};
      
      final allCurrentSongs = await _databaseService.getAllSongs();
      final existingSongsByPath = <String, Song>{};
      for (final song in allCurrentSongs) {
        existingSongsByPath[_databaseService.normalizePathForSync(song.audioPath)] = song;
      }

      for (int i = 0; i < audioFiles.length; i++) {
        if (shouldCancel) break;

        final file = audioFiles[i];
        final normalizedPath = _databaseService.normalizePathForSync(file.path);
        final fileName = path.basename(file.path);
        final title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false), '');
        final baseName = path.basenameWithoutExtension(file.path);
        
        String? lrcPathToSave;
        List<TranslationFile> translationFiles = [];
        List<String> extractedFilesToDelete = [];

        final searchDir = lyricsFolderPath ?? musicFolderPath;
        final zipPath = path.join(searchDir, '$baseName.zip');
        final zipFile = File(zipPath);
        
        if (await zipFile.exists()) {
          try {
            debugPrint('Found zip file for $fileName, extracting...');
            final extracted = await ExportImportService.extractSongArchive(zipPath, searchDir, baseName);
            extractedFilesToDelete.addAll(extracted);
          } catch (e) {
            debugPrint('Failed to extract zip for $fileName: $e');
          }
        }

        // 1. Search for LRC
        lrcPathToSave = await _findLrcInFolder(searchDir, baseName, extractedFilesToDelete);
        
        // 2. Fallbacks for LRC (check global folder)
        if (lrcPathToSave == null) {
           lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
        }

        // 3. Find translations using smart match
        translationFiles = await _findTranslationFiles(baseName, searchDir, lyricsFolderPath);

        final existingSong = existingSongsByPath[normalizedPath];
        final songId = existingSong?.id ?? _generateSongId(file.path);

        // Persist files internally
        if (lrcPathToSave != null) {
          try {
            lrcPathToSave = await _persistLyricsFile(lrcPathToSave!, songId);
          } catch (e) {
            debugPrint('Import: Failed to persist LRC for $fileName: $e');
            lrcPathToSave = null;
          }
        }

        List<TranslationFile> persistedTranslationFiles = [];
        for (final tf in translationFiles) {
          try {
            final persistedPath = await _persistLyricsFile(tf.filePath, songId);
            if (persistedPath != null) {
              persistedTranslationFiles.add(TranslationFile(
                filePath: persistedPath,
                language: tf.language,
                languageName: tf.languageName,
                type: tf.type,
              ));
            }
          } catch (e) {
            debugPrint('Import: Failed to persist translation ${tf.language} for $fileName: $e');
          }
        }
        translationFiles = persistedTranslationFiles;

        // Cleanup unzipped files from the source folder
        for (final extractedPath in extractedFilesToDelete) {
          try {
            final f = File(extractedPath);
            if (await f.exists()) {
              await f.delete();
              debugPrint('Deleted extracted file during import: $extractedPath');
            }
          } catch (e) {
            debugPrint('Error deleting extracted file during import: $e');
          }
        }

        if (translationFiles.isNotEmpty) {
          songToTranslationsMap[songId] = translationFiles;
        }

        // Check if existing song files are missing
        bool currentLrcIsMissing = false;
        bool currentTransIsMissing = false;
        if (existingSong != null) {
          if (existingSong.lrcPath != null && !await File(existingSong.lrcPath!).exists()) {
            currentLrcIsMissing = true;
          }
          if (existingSong.translationsPath != null && !await File(existingSong.translationsPath!).exists()) {
            currentTransIsMissing = true;
          }
        }

        final hasLyrics = lrcPathToSave != null || translationFiles.isNotEmpty;
        final song = Song(
          id: songId,
          title: title,
          artist: existingSong?.artist ?? 'Unknown Artist',
          audioPath: file.path,
          lrcPath: lrcPathToSave ?? (currentLrcIsMissing ? null : existingSong?.lrcPath),
          translationsPath: translationFiles.isNotEmpty 
            ? translationFiles.first.filePath 
            : (currentTransIsMissing ? null : existingSong?.translationsPath),
          originalLanguage: existingSong?.originalLanguage ?? 'unknown',
          hasLyrics: hasLyrics || ((existingSong?.hasLyrics ?? false) && !currentLrcIsMissing && !currentTransIsMissing),
        );

        songsToInsert.add(song);
        playlistSongs[song.id] = importedCount;
        
        // Add to local map to prevent duplicates in same batch if duplicate files exist
        existingSongsByPath[normalizedPath] = song;

        importedCount++;
        processedFiles++;

        final progress = audioFiles.length > 0 ? processedFiles / audioFiles.length : 1.0;

        onProgress(FolderImportProgress(
          totalFiles: audioFiles.length,
          currentFile: processedFiles,
          foundSongs: importedCount,
          currentFileName: fileName,
          progress: progress,
        ));

        await Future.delayed(const Duration(milliseconds: 1));
      }

      if (shouldCancel) {
        await _databaseService.deletePlaylist(playlistId);
        return FolderImportResult(
          playlist: Playlist(
            id: '',
            name: '',
            isSystem: false,
            createdAt: DateTime.now(),
          ),
          importedCount: importedCount,
          error: 'Import cancelled',
        );
      }

      await _batchInsertSongs(songsToInsert);
      await _batchAddSongsToPlaylist(playlistId, songsToInsert);
      await _batchInsertTranslations(songToTranslationsMap);

      return FolderImportResult(
        playlist: playlist,
        importedCount: importedCount,
      );
    } catch (e, stackTrace) {
      debugPrint('Error importing folders: $e');
      debugPrint('Stack trace: $stackTrace');
      return FolderImportResult(
        playlist: Playlist(
          id: '',
          name: '',
          isSystem: false,
          createdAt: DateTime.now(),
        ),
        importedCount: importedCount,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, List<TranslationFile>>> _preloadTranslationFiles(
    String folderPath,
  ) async {
    final Map<String, List<TranslationFile>> cache = {};
    final folder = Directory(folderPath);

    if (!(await folder.exists())) {
      return cache;
    }

    try {
      final files = await folder.list().toList();

      for (final f in files) {
        if (f is File) {
          final fileName = path.basename(f.path);
          if (fileName.toLowerCase().endsWith('.json')) {
            try {
              final content = await File(f.path).readAsString();
              final data = json.decode(content) as Map<String, dynamic>;

              if (data.containsKey('translations') && data['translations'] != null) {
                final translations = data['translations'] as List;
                if (translations.isNotEmpty) {
                  final translation = translations[0] as Map<String, dynamic>;
                  final languageCode = translation['language'] as String? ?? 'unknown';
                  final languageName = translation['languageName'] as String? ?? 'Unknown';
                  final type = translation['type'] as String?;

                  final songName = fileName.replaceAll(RegExp(r'\.json$', caseSensitive: false), '').toLowerCase();

                  if (!cache.containsKey(songName)) {
                    cache[songName] = [];
                  }

                  cache[songName]!.add(TranslationFile(
                    filePath: f.path,
                    language: languageCode,
                    languageName: languageName,
                    type: type,
                  ));
                }
              }
            } catch (e) {
              debugPrint('Error reading JSON file $fileName: $e');
            }
          }
        }
      }

      return cache;
    } catch (e) {
      debugPrint('Error preloading translation files: $e');
      return cache;
    }
  }

  Future<void> _batchInsertSongs(List<Song> songs) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    for (final song in songs) {
      batch.insert(
        'songs',
        {
          'id': song.id,
          'title': song.title,
          'artist': song.artist,
          'audioPath': song.audioPath,
          'lrcPath': song.lrcPath,
          'translationsPath': song.translationsPath,
          'coverArtPath': song.coverArtPath,
          'coverArtVersion': song.coverArtVersion,
          'originalLanguage': song.originalLanguage,
          'language': song.language,
          'selectedLanguage': song.selectedLanguage,
          'createdAt': song.createdAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> _batchAddSongsToPlaylist(String playlistId, List<Song> songs) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    for (int i = 0; i < songs.length; i++) {
      batch.insert(
        'playlist_songs',
        {
          'playlistId': playlistId,
          'songId': songs[i].id,
          'position': i,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> _batchInsertTranslations(Map<String, List<TranslationFile>> songTranslations) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    for (final entry in songTranslations.entries) {
      final songId = entry.key;
      final translations = entry.value;
      for (final tf in translations) {
        final id = 'trans_${songId}_${tf.language}_${tf.type ?? 'default'}';
        batch.insert(
          'song_translations',
          {
            'id': id,
            'songId': songId,
            'language': tf.language,
            'languageName': tf.languageName,
            'filePath': tf.filePath,
            'type': tf.type,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
  }

  bool _isSmartMatch(String fileName, String songName) {
    final fName = path.basenameWithoutExtension(fileName).toLowerCase().trim();
    final sName = songName.toLowerCase().trim();
    
    // 1. Exact match
    if (fName == sName) return true;
    
    // 2. Starts with song name
    if (fName.startsWith(sName)) {
      final remainder = fName.substring(sName.length);
      if (remainder.isEmpty || remainder.startsWith(' ') || remainder.startsWith('-') || remainder.startsWith('_')) {
        return true;
      }
    }
    
    // 3. Reverse match
    if (sName.startsWith(fName)) {
      final remainder = sName.substring(fName.length);
      if (remainder.isEmpty || remainder.startsWith(' ') || remainder.startsWith('(') || remainder.startsWith('-')) {
        return true;
      }
    }

    return false;
  }

  Future<String?> _findLrcInFolder(String folderPath, String baseName, List<String> extractedFiles) async {
    // 1. Try extracted files first
    for (final f in extractedFiles) {
      if (path.extension(f).toLowerCase() == '.lrc') {
        if (_isSmartMatch(path.basename(f), baseName)) {
           return f;
        }
      }
    }
    
    // 2. Try match in folder
    final dir = Directory(folderPath);
    if (await dir.exists()) {
      final files = await dir.list().toList();
      for (final f in files) {
        if (f is File && path.extension(f.path).toLowerCase() == '.lrc') {
          if (_isSmartMatch(path.basename(f.path), baseName)) {
            return f.path;
          }
        }
      }
    }
    
    return null;
  }

  Future<List<TranslationFile>> _findTranslationFiles(
    String baseName,
    String searchDir,
    String? lyricsFolderPath,
  ) async {
    final files = <TranslationFile>[];

    Future<void> scanDir(String dirPath) async {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        final dirFiles = await dir.list().toList();
        for (final f in dirFiles) {
          if (f is File && f.path.toLowerCase().endsWith('.json')) {
            if (_isSmartMatch(path.basename(f.path), baseName)) {
              final translationFile = await _loadTranslationFile(f.path);
              if (translationFile != null) {
                final exists = files.any((existing) => 
                  existing.language == translationFile.language && 
                  existing.type == translationFile.type);
                if (!exists) {
                  files.add(translationFile);
                }
              }
            }
          }
        }
      }
    }

    await scanDir(searchDir);
    if (lyricsFolderPath != null && lyricsFolderPath != searchDir) {
      await scanDir(lyricsFolderPath);
    }

    return files;
  }

  Future<TranslationFile?> _loadTranslationFile(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final data = json.decode(content) as Map<String, dynamic>;
      if (data.containsKey('translations') && data['translations'] != null) {
        final translations = data['translations'] as List;
        if (translations.isNotEmpty) {
          final translation = translations[0] as Map<String, dynamic>;
          return TranslationFile(
            filePath: filePath,
            language: translation['language'] as String? ?? 'unknown',
            languageName: translation['languageName'] as String? ?? 'Unknown',
            type: translation['type'] as String?,
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading translation file $filePath: $e');
    }
    return null;
  }
}
