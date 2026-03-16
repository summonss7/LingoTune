import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import 'database_service.dart';
import 'folder_config_service.dart';
import 'export_import_service.dart';
import 'package:uuid/uuid.dart';

class FolderRefreshProgress {
  final int totalFiles;
  final int processedFiles;
  final int foundSongs;
  final int addedSongs;
  final int removedSongs;
  final String currentFileName;
  final double progress;

  FolderRefreshProgress({
    required this.totalFiles,
    required this.processedFiles,
    required this.foundSongs,
    required this.addedSongs,
    required this.removedSongs,
    required this.currentFileName,
    required this.progress,
  });
}

class FolderRefreshResult {
  final int totalSongs;
  final int addedSongs;
  final int removedSongs;
  final String error;

  FolderRefreshResult({
    required this.totalSongs,
    required this.addedSongs,
    required this.removedSongs,
    this.error = '',
  });

  bool get isSuccess => error.isEmpty;
}

class PlaylistService {
  static final PlaylistService _instance = PlaylistService._internal();
  static const Uuid _uuid = Uuid();

  factory PlaylistService() {
    return _instance;
  }

  PlaylistService._internal();

  final DatabaseService _databaseService = DatabaseService();

  Future<List<Playlist>> getAllPlaylists() async {
    return await _databaseService.getAllPlaylists();
  }

  Future<Playlist?> getPlaylist(String id) async {
    return await _databaseService.getPlaylist(id);
  }

  Future<void> insertPlaylist(Playlist playlist) async {
    await _databaseService.insertPlaylist(playlist);
  }

  Future<void> createPlaylist(String name, {String? icon}) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name,
      icon: icon,
      isSystem: false,
    );
    await _databaseService.insertPlaylist(playlist);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _databaseService.updatePlaylist(playlist);
  }

  Future<void> deletePlaylist(String id) async {
    final playlist = await getPlaylist(id);
    if (playlist != null && !playlist.isSystem) {
      await _databaseService.deletePlaylist(id);
    }
  }

  Future<List<Song>> getSongsInPlaylist(String playlistId) async {
    return await _databaseService.getSongsInPlaylist(playlistId);
  }

  Future<int> getPlaylistSongCount(String playlistId) async {
    return await _databaseService.getPlaylistSongCount(playlistId);
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    await _databaseService.addSongToPlaylist(playlistId, songId);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await _databaseService.removeSongFromPlaylist(playlistId, songId);
  }

  Future<void> updatePlaylistSongsOrder(String playlistId, List<Song> songs) async {
    final songIds = songs.map((s) => s.id).toList();
    await _databaseService.updatePlaylistSongsOrder(playlistId, songIds);
  }

  Future<bool> isSongInPlaylist(String playlistId, String songId) async {
    final songs = await getSongsInPlaylist(playlistId);
    return songs.any((s) => s.id == songId);
  }

  Future<void> createLanguagePlaylist(String language) async {
    final allSongs = await _databaseService.getAllSongs();
    final filteredSongs = allSongs.where((s) => s.language == language).toList();

    final playlistId = 'lang_${language.toLowerCase()}';
    final existingPlaylist = await getPlaylist(playlistId);

    if (existingPlaylist == null && filteredSongs.isNotEmpty) {
      final playlist = Playlist(
        id: playlistId,
        name: _capitalizeFirstLetter(language),
        icon: 'language',
        isSystem: true,
      );
      await _databaseService.insertPlaylist(playlist);

      for (final song in filteredSongs) {
        await addSongToPlaylist(playlistId, song.id);
      }
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<String> _getInternalLyricsDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final lyricsDir = Directory(path.join(docsDir.path, 'lyrics'));
    if (!await lyricsDir.exists()) {
      await lyricsDir.create(recursive: true);
      debugPrint('Created internal lyrics directory: ${lyricsDir.path}');
    }
    return lyricsDir.path;
  }

  Future<String?> _persistLyricsFile(String sourcePath, String songId, String extension) async {
    try {
      final internalDir = await _getInternalLyricsDirectory();
      final sourceFileName = path.basename(sourcePath);
      // Clean filename for Android/Windows safety
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
        debugPrint('✅ Persisted to: $targetPath');
        return targetPath;
      }
    } catch (e) {
      debugPrint('❌ Persistence error for $sourcePath: $e');
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

  Future<List<Playlist>> updateSystemPlaylists() async {
    final allSongs = await _databaseService.getAllSongs();
    final languageMap = <String, List<Song>>{};

    for (final song in allSongs) {
      if (song.language != null && song.language!.isNotEmpty) {
        if (!languageMap.containsKey(song.language)) {
          languageMap[song.language!] = [];
        }
        languageMap[song.language]!.add(song);
      }
    }

    for (final entry in languageMap.entries) {
      await createLanguagePlaylist(entry.key);
    }

    return await getAllPlaylists();
  }

  Future<FolderRefreshResult> refreshPlaylistFolder(
    Playlist playlist,
    Function(FolderRefreshProgress) onProgress, {
    bool onlySongs = false,
  }) async {
    if (playlist.musicFolderPath == null) {
      return FolderRefreshResult(
        totalSongs: 0,
        addedSongs: 0,
        removedSongs: 0,
        error: 'Playlist is not linked to a folder',
      );
    }

    int addedCount = 0;
    int removedCount = 0;
    bool needsUpdate = false;

    try {
      final musicDir = Directory(playlist.musicFolderPath!);
      if (!musicDir.existsSync()) {
        return FolderRefreshResult(
          totalSongs: 0,
          addedSongs: 0,
          removedSongs: 0,
          error: 'Music folder does not exist',
        );
      }

      // Cleanup existing chaos from database before sync
      await _databaseService.deduplicateSongs();

      // Cache folder files for efficient LRC/JSON search (prevents N*M operations)
      final Map<String, List<String>> folderFileCache = <String, List<String>>{};

      Future<void> cacheFolderFiles(String folderPath, {String extension = ''}) async {
        final dir = Directory(folderPath);
        if (!await dir.exists()) {
          if (!folderFileCache.containsKey(folderPath)) {
            folderFileCache[folderPath] = [];
          }
          return;
        }

        final files = await dir.list().toList();
        final matchedFiles = <String>[];
        for (final f in files) {
          if (f is File) {
            if (extension.isEmpty || path.extension(f.path).toLowerCase() == extension.toLowerCase()) {
              matchedFiles.add(f.path);
            }
          }
        }

        if (folderFileCache.containsKey(folderPath)) {
          folderFileCache[folderPath]!.addAll(matchedFiles);
          debugPrint('📁 Added ${matchedFiles.length} $extension files to existing cache: $folderPath');
        } else {
          folderFileCache[folderPath] = matchedFiles;
          debugPrint('📁 Cached ${matchedFiles.length} $extension files from: $folderPath');
        }
      }

      // Cache music folder files
      await cacheFolderFiles(playlist.musicFolderPath!, extension: '.lrc');
      await cacheFolderFiles(playlist.musicFolderPath!, extension: '.json');

      // Cache lyrics folder files if configured
      if (playlist.lyricsFolderPath != null) {
        await cacheFolderFiles(playlist.lyricsFolderPath!, extension: '.lrc');
        await cacheFolderFiles(playlist.lyricsFolderPath!, extension: '.json');
      }

      final files = await musicDir.list().toList();
      final audioFiles = files.where((f) => f is File && _isAudioFile(f.path)).toList();

      onProgress(FolderRefreshProgress(
        totalFiles: audioFiles.length,
        processedFiles: 0,
        foundSongs: 0,
        addedSongs: 0,
        removedSongs: 0,
        currentFileName: 'Starting...',
        progress: 0.0,
      ));

      final existingSongs = await _databaseService.getSongsInPlaylist(playlist.id);
      final existingSongPaths = <String>{};
      for (final song in existingSongs) {
        existingSongPaths.add(song.audioPath);
      }

      final currentSongPaths = <String>{};
      final songsToAdd = <String>[];

      final allCurrentSongs = await _databaseService.getAllSongs();
      final existingSongsByPath = <String, Song>{};
      for (final song in allCurrentSongs) {
        // Use normalized path for matching map
        final normalizedPath = _databaseService.normalizePathForSync(song.audioPath);
        existingSongsByPath[normalizedPath] = song;
      }

      for (int i = 0; i < audioFiles.length; i++) {
        final file = audioFiles[i];
        final normalizedCurrentPath = _databaseService.normalizePathForSync(file.path);
        final fileName = path.basename(file.path);
        // ... rest stays ...
        final title = fileName.replaceAll(RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false), '');
        final baseName = path.basenameWithoutExtension(file.path);

        String? lrcPathToSave;
        List<TranslationFile> translationFiles = [];
        List<String> extractedFilesToDelete = [];

        if (!onlySongs) {
          final searchDir = playlist.lyricsFolderPath ?? playlist.musicFolderPath!;

          if (await File(path.join(searchDir, '$baseName.zip')).exists()) {
            try {
              final extracted = await ExportImportService.extractSongArchive(
                path.join(searchDir, '$baseName.zip'),
                searchDir,
                baseName,
              );
              extractedFilesToDelete.addAll(extracted);
            } catch (e) {
              debugPrint('Failed to extract zip for $fileName: $e');
            }
          }

          // Case-insensitive search for LRC in searchDir or extracted files
          lrcPathToSave = await _findLrcInFolder(searchDir, baseName, extractedFilesToDelete, folderFileCache);

          if (lrcPathToSave == null) {
             // Fallback to global/configured lyrics folder if still not found
             lrcPathToSave = await FolderConfigService.findLrcFile(baseName);
          }

          translationFiles = await _findTranslationFiles(baseName, searchDir, playlist.lyricsFolderPath, folderFileCache, extractedFilesToDelete);
          debugPrint('Found ${translationFiles.length} translation files and LRC: ${lrcPathToSave != null} for $baseName');
        }

        final existingSong = existingSongsByPath[normalizedCurrentPath];

        // Process and persist files
        final songIdForFiles = existingSong?.id ?? _generateSongId(file.path);

        if (lrcPathToSave != null) {
          try {
            lrcPathToSave = await _persistLyricsFile(lrcPathToSave!, songIdForFiles, '.lrc');
          } catch (e) {
            debugPrint('Failed to persist LRC for $fileName: $e');
            lrcPathToSave = null;
          }
        }

        List<TranslationFile> persistedTranslationFiles = [];
        for (final tf in translationFiles) {
          try {
            final persistedPath = await _persistLyricsFile(tf.filePath, songIdForFiles, '.json');
            if (persistedPath != null) {
              persistedTranslationFiles.add(TranslationFile(
                filePath: persistedPath,
                language: tf.language,
                languageName: tf.languageName,
                type: tf.type,
              ));
            }
          } catch (e) {
            debugPrint('Failed to persist translation ${tf.language} for $fileName: $e');
          }
        }
        translationFiles = persistedTranslationFiles;

        // Cleanup extracted files from source folder
        for (final extractedPath in extractedFilesToDelete) {
          try {
            final f = File(extractedPath);
            if (await f.exists()) {
              await f.delete();
              debugPrint('Deleted extracted file: $extractedPath');
            }
          } catch (e) {
            debugPrint('Error deleting extracted file $extractedPath: $e');
          }
        }

        final hasLyrics = lrcPathToSave != null || translationFiles.isNotEmpty;

        if (existingSong != null) {
          bool currentLrcIsMissing = false;
          bool currentLrcPathInvalid = false;
          if (existingSong.lrcPath != null) {
             final lrcFile = File(existingSong.lrcPath!);
             if (!await lrcFile.exists()) {
               currentLrcIsMissing = true;
               debugPrint('⚠ Existing LRC file missing: ${existingSong.lrcPath}');
             } else {
               try {
                 final content = await lrcFile.readAsString();
                 if (content.trim().isEmpty) {
                   currentLrcIsMissing = true;
                   currentLrcPathInvalid = true;
                   debugPrint('⚠ Existing LRC file is empty: ${existingSong.lrcPath}');
                 }
               } catch (e) {
                 currentLrcIsMissing = true;
                 currentLrcPathInvalid = true;
                 debugPrint('⚠ Error reading existing LRC file: ${existingSong.lrcPath} - $e');
               }
             }
          }

          bool currentTransIsMissing = false;
          bool currentTransPathInvalid = false;
          if (existingSong.translationsPath != null) {
            final transFile = File(existingSong.translationsPath!);
            if (!await transFile.exists()) {
              currentTransIsMissing = true;
            } else {
              try {
                final content = await transFile.readAsString();
                if (content.trim().isEmpty) {
                  currentTransIsMissing = true;
                  currentTransPathInvalid = true;
                }
              } catch (e) {
                currentTransIsMissing = true;
                currentTransPathInvalid = true;
              }
            }
          }

          final prefs = await SharedPreferences.getInstance();
          final addToLibraryWhenAddingToPlaylist = prefs.getBool('addToLibraryWhenAddingToPlaylist') ?? false;

          final String? finalLrcPath;
          if (lrcPathToSave != null) {
            finalLrcPath = lrcPathToSave;
          } else if (!currentLrcIsMissing && !currentLrcPathInvalid) {
            finalLrcPath = existingSong.lrcPath;
          } else {
            finalLrcPath = null;
          }

          final String? finalTransPath;
          if (translationFiles.isNotEmpty) {
            finalTransPath = translationFiles.first.filePath;
          } else if (!currentTransIsMissing && !currentTransPathInvalid) {
            finalTransPath = existingSong.translationsPath;
          } else {
            finalTransPath = null;
          }

          final updatedSong = Song(
            id: existingSong.id,
            title: existingSong.title,
            artist: existingSong.artist,
            audioPath: existingSong.audioPath,
            lrcPath: finalLrcPath,
            translationsPath: finalTransPath,
            coverArtPath: existingSong.coverArtPath,
            coverArtVersion: existingSong.coverArtVersion,
            originalLanguage: existingSong.originalLanguage,
            language: existingSong.language,
            hasLyrics: hasLyrics || (existingSong.hasLyrics && !currentLrcIsMissing && !currentTransIsMissing),
            isInLibrary: addToLibraryWhenAddingToPlaylist,
            createdAt: existingSong.createdAt,
          );

          if (currentLrcIsMissing || currentTransIsMissing || currentLrcPathInvalid || currentTransPathInvalid ||
              (finalLrcPath != null && finalLrcPath != existingSong.lrcPath) ||
              (finalTransPath != null && finalTransPath != existingSong.translationsPath) ||
              (hasLyrics != existingSong.hasLyrics)) {
            debugPrint('📝 Updating song record for: ${existingSong.title} (LRC: ${finalLrcPath != null}, Trans: ${finalTransPath != null})');
            await _databaseService.updateSong(updatedSong);
            needsUpdate = true;
          }
          
          final existingTranslations = await _databaseService.getTranslationFiles(existingSong.id);
          final existingTranslationsSet = existingTranslations.map((t) => '${t['language']}_${t['type'] ?? 'default'}').toSet();

          for (final tf in translationFiles) {
            final translationKey = '${tf.language}_${tf.type ?? 'default'}';
            if (!existingTranslationsSet.contains(translationKey)) {
              try {
                await _databaseService.addTranslationFile(
                  existingSong.id,
                  tf.language,
                  tf.languageName,
                  tf.filePath,
                  type: tf.type,
                );
                debugPrint('Added new translation for existing song: ${tf.languageName}');
              } catch (e) {
                debugPrint('Error adding translation: $e');
              }
            }
          }

          songsToAdd.add(existingSong.id);
          currentSongPaths.add(file.path);
        } else {
          final prefs = await SharedPreferences.getInstance();
          final addToLibraryWhenAddingToPlaylist = prefs.getBool('addToLibraryWhenAddingToPlaylist') ?? false;

          final song = Song(
            id: songIdForFiles,
            title: title,
            artist: 'Unknown Artist',
            audioPath: file.path,
            lrcPath: lrcPathToSave,
            translationsPath: translationFiles.isNotEmpty ? translationFiles.first.filePath : null,
            originalLanguage: 'unknown',
            hasLyrics: hasLyrics,
            isInLibrary: addToLibraryWhenAddingToPlaylist,
          );
          await _databaseService.insertSong(song);
          songsToAdd.add(song.id);
          currentSongPaths.add(file.path);
          addedCount++;
          
          // Add to local map to prevent duplicates if path is found again (e.g. case sync issues)
          existingSongsByPath[normalizedCurrentPath] = song;

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
        }

        final progress = audioFiles.length > 0 ? (i + 1) / audioFiles.length : 1.0;
        onProgress(FolderRefreshProgress(
          totalFiles: audioFiles.length,
          processedFiles: i + 1,
          foundSongs: i + 1,
          addedSongs: addedCount,
          removedSongs: 0,
          currentFileName: fileName,
          progress: progress,
        ));

        await Future.delayed(const Duration(milliseconds: 1));
      }

      await _databaseService.clearPlaylistSongs(playlist.id);

      final batch = (await _databaseService.database).batch();
      for (int i = 0; i < songsToAdd.length; i++) {
        batch.insert(
          'playlist_songs',
          {
            'playlistId': playlist.id,
            'songId': songsToAdd[i],
            'position': i,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      await (await _databaseService.database).rawUpdate('''
        UPDATE playlists
        SET songCount = ?
        WHERE id = ?
      ''', [songsToAdd.length, playlist.id]);

      removedCount = existingSongPaths.length - currentSongPaths.length;
      removedCount = removedCount > 0 ? removedCount : 0;

      return FolderRefreshResult(
        totalSongs: songsToAdd.length,
        addedSongs: addedCount,
        removedSongs: removedCount,
      );
    } catch (e) {
      debugPrint('Error refreshing playlist folder: $e');
      return FolderRefreshResult(
        totalSongs: 0,
        addedSongs: addedCount,
        removedSongs: removedCount,
        error: e.toString(),
      );
    }
  }

  bool _isAudioFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.mp3', '.wav', '.m4a', '.ogg', '.flac'].contains(extension);
  }

  bool _isSmartMatch(String fileName, String songName) {
    final fName = path.basenameWithoutExtension(fileName).toLowerCase().trim();
    final sName = songName.toLowerCase().trim();
    
    // 1. Exact match
    if (fName == sName) return true;
    
    // 2. Starts with song name (e.g. "Song - En.json" matches "Song")
    if (fName.startsWith(sName)) {
      final remainder = fName.substring(sName.length);
      // Ensure we don't match "Songs" for "Song" - only if followed by separator
      if (remainder.isEmpty || remainder.startsWith(' ') || remainder.startsWith('-') || remainder.startsWith('_')) {
        return true;
      }
    }
    
    // 3. Reverse match (e.g. "Song.json" matches "Song (Live)")
    if (sName.startsWith(fName)) {
      final remainder = sName.substring(fName.length);
      if (remainder.isEmpty || remainder.startsWith(' ') || remainder.startsWith('(') || remainder.startsWith('-')) {
        return true;
      }
    }

    return false;
  }

  Future<List<TranslationFile>> _findTranslationFiles(
    String baseName,
    String searchDir,
    String? lyricsFolderPath,
    Map<String, List<String>> folderCache,
    List<String> extractedFiles,
  ) async {
    final files = <TranslationFile>[];

    // 1. First, search in extracted files (ZIP archives) - HIGHEST PRIORITY
    for (final filePath in extractedFiles) {
      if (filePath.toLowerCase().endsWith('.json')) {
        if (_isSmartMatch(path.basename(filePath), baseName)) {
          final translationFile = await _loadTranslationFile(filePath);
          if (translationFile != null) {
            // Avoid duplicates by language+type
            final exists = files.any((existing) =>
              existing.language == translationFile.language &&
              existing.type == translationFile.type);
            if (!exists) {
              files.add(translationFile);
              debugPrint('✓ Found translation from ZIP: ${translationFile.languageName} for $baseName');
            }
          }
        }
      }
    }

    // Helper to search in a directory using cache
    Future<void> searchDirWithCache(String dirPath) async {
      if (!folderCache.containsKey(dirPath)) return;

      final cachedFiles = folderCache[dirPath]!;
      for (final filePath in cachedFiles) {
        if (filePath.toLowerCase().endsWith('.json')) {
          if (_isSmartMatch(path.basename(filePath), baseName)) {
            final translationFile = await _loadTranslationFile(filePath);
            if (translationFile != null) {
              // Avoid duplicates by language+type
              final exists = files.any((existing) =>
                existing.language == translationFile.language &&
                existing.type == translationFile.type);
              if (!exists) {
                files.add(translationFile);
                debugPrint('✓ Found translation from cache: ${translationFile.languageName} for $baseName');
              }
            }
          }
        }
      }
    }

    // 2. Search in main directory cache
    await searchDirWithCache(searchDir);
    // 3. Search in lyrics folder cache if different
    if (lyricsFolderPath != null && lyricsFolderPath != searchDir) {
      await searchDirWithCache(lyricsFolderPath);
    }

    return files;
  }

  Future<String?> _findLrcInFolder(String folderPath, String baseName, List<String> extractedFiles, Map<String, List<String>> folderCache) async {
    // 1. Try extracted files first
    for (final f in extractedFiles) {
      if (path.extension(f).toLowerCase() == '.lrc') {
        if (_isSmartMatch(path.basename(f), baseName)) {
           return f;
        }
      }
    }

    // 2. Use cached LRC files from folder (MUCH FASTER - no repeated directory scanning)
    if (folderCache.containsKey(folderPath)) {
      final cachedFiles = folderCache[folderPath]!;
      for (final filePath in cachedFiles) {
        if (_isSmartMatch(path.basename(filePath), baseName)) {
          return filePath;
        }
      }
    }

    return null;
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
