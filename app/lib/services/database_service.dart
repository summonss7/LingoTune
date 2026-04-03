import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/song.dart';
import '../models/playlist.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static Completer<Database>? _databaseCompleter;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (_databaseCompleter != null) {
      return _databaseCompleter!.future;
    }
    
    _databaseCompleter = Completer<Database>();
    try {
      _database = await _initDatabase();
      _databaseCompleter!.complete(_database);
      return _database!;
    } catch (e) {
      _databaseCompleter!.completeError(e);
      _databaseCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final databasePath = path.join(dbPath, 'lingotune.db');

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        return await openDatabase(
          databasePath,
      version: 11,
          onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE songs (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            audioPath TEXT NOT NULL,
            lrcPath TEXT,
            translationsPath TEXT,
            coverArtPath TEXT,
            coverArtVersion INTEGER DEFAULT 0,
            originalLanguage TEXT,
            language TEXT,
            selectedLanguage TEXT,
            hasLyrics INTEGER DEFAULT 1,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE song_translations (
            id TEXT PRIMARY KEY,
            songId TEXT NOT NULL,
            language TEXT NOT NULL,
            languageName TEXT NOT NULL,
            filePath TEXT NOT NULL,
            type TEXT,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE playlists (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT,
            isSystem INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            songCount INTEGER DEFAULT 0,
            musicFolderPath TEXT,
            lyricsFolderPath TEXT,
            coverArtPath TEXT,
            coverArtVersion INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE playlist_songs (
            playlistId TEXT,
            songId TEXT,
            position INTEGER,
            PRIMARY KEY (playlistId, songId),
            FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE,
            FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
          )
        ''');

        await _insertDefaultPlaylists(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE songs ADD COLUMN language TEXT');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS playlists (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              icon TEXT,
              isSystem INTEGER DEFAULT 0,
              createdAt TEXT NOT NULL,
              songCount INTEGER DEFAULT 0
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS playlist_songs (
              playlistId TEXT,
              songId TEXT,
              position INTEGER,
              PRIMARY KEY (playlistId, songId),
              FOREIGN KEY (playlistId) REFERENCES playlists(id) ON DELETE CASCADE,
              FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
            )
          ''');

          await _insertDefaultPlaylists(db);
        }

        if (oldVersion < 3) {
          await db.execute('ALTER TABLE playlists ADD COLUMN songCount INTEGER DEFAULT 0');
        }

        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS song_translations (
              id TEXT PRIMARY KEY,
              songId TEXT NOT NULL,
              language TEXT NOT NULL,
              languageName TEXT NOT NULL,
              filePath TEXT NOT NULL,
              type TEXT,
              createdAt TEXT NOT NULL,
              FOREIGN KEY (songId) REFERENCES songs(id) ON DELETE CASCADE
            )
          ''');
        }

        if (oldVersion < 5) {
          await db.execute('ALTER TABLE songs ADD COLUMN selectedLanguage TEXT');
        }

        if (oldVersion < 6) {
          await db.execute('ALTER TABLE songs ADD COLUMN coverArtPath TEXT');
        }

        if (oldVersion < 7) {
          await db.execute('ALTER TABLE playlists ADD COLUMN musicFolderPath TEXT');
          await db.execute('ALTER TABLE playlists ADD COLUMN lyricsFolderPath TEXT');
        }

        if (oldVersion < 8) {
          await db.execute('ALTER TABLE songs ADD COLUMN coverArtVersion INTEGER DEFAULT 0');
        }

        if (oldVersion < 9) {
          await db.execute('ALTER TABLE playlists ADD COLUMN coverArtPath TEXT');
          await db.execute('ALTER TABLE playlists ADD COLUMN coverArtVersion INTEGER DEFAULT 0');
        }

        if (oldVersion < 10) {
          await db.execute('ALTER TABLE songs ADD COLUMN hasLyrics INTEGER DEFAULT 1');

          await db.execute('''
            UPDATE songs
            SET hasLyrics = CASE
              WHEN lrcPath IS NOT NULL AND lrcPath != '' THEN 1
              ELSE 0
            END
          ''');
        }

        if (oldVersion < 11) {
          await db.execute('ALTER TABLE songs ADD COLUMN isInLibrary INTEGER DEFAULT 1');
        }
      },
    );
      } on DatabaseException catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('database is locked') || errorStr.contains('code 5')) {
          retryCount++;
          debugPrint('Database locked during init, retrying ($retryCount/$maxRetries)...');
          await Future.delayed(Duration(milliseconds: 100 * retryCount));
        } else {
          rethrow;
        }
      }
    }
    
    throw Exception('Failed to initialize database after $maxRetries retries');
  }

  Future<void> _insertDefaultPlaylists(Database db) async {
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'playlists',
      {
        'id': 'all_songs',
        'name': 'All Songs',
        'icon': 'library_music',
        'isSystem': 1,
        'createdAt': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await db.insert(
      'playlists',
      {
        'id': 'favorites',
        'name': 'Favorites',
        'icon': 'favorite',
        'isSystem': 1,
        'createdAt': now,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<bool> insertSong(Song song) async {
    try {
      final db = await database;
      final id = await db.insert(
        'songs',
        song.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('=== DatabaseService: Inserted song ===');
      debugPrint('Song ID: ${song.id}');
      debugPrint('Song Title: ${song.title}');
      debugPrint('Insert result ID: $id');
      return true;
    } catch (e) {
      debugPrint('=== ERROR: Failed to insert song ===');
      debugPrint('Song ID: ${song.id}');
      debugPrint('Song Title: ${song.title}');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'isInLibrary = ?',
      whereArgs: [1],
    );

    return List.generate(maps.length, (i) {
      final hasLyricsValue = maps[i]['hasLyrics'];
      final hasLyrics = hasLyricsValue == 1 || hasLyricsValue == true;

      return Song(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        artist: maps[i]['artist'] as String,
        audioPath: maps[i]['audioPath'] as String,
        lrcPath: maps[i]['lrcPath'] as String?,
        translationsPath: maps[i]['translationsPath'] as String?,
        coverArtPath: maps[i]['coverArtPath'] as String?,
        coverArtVersion: maps[i]['coverArtVersion'] as int? ?? 0,
        originalLanguage: maps[i]['originalLanguage'] as String? ?? 'unknown',
        language: maps[i]['language'] as String?,
        hasLyrics: hasLyrics,
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
      );
    });
  }

  Future<Song?> getSong(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final hasLyricsValue = maps[0]['hasLyrics'];
    final hasLyrics = hasLyricsValue == 1 || hasLyricsValue == true;

    final isInLibraryValue = maps[0]['isInLibrary'];
    final isInLibrary = isInLibraryValue == null || isInLibraryValue == 1 || isInLibraryValue == true;

    return Song(
      id: maps[0]['id'] as String,
      title: maps[0]['title'] as String,
      artist: maps[0]['artist'] as String,
      audioPath: maps[0]['audioPath'] as String,
      lrcPath: maps[0]['lrcPath'] as String?,
      translationsPath: maps[0]['translationsPath'] as String?,
      coverArtPath: maps[0]['coverArtPath'] as String?,
      coverArtVersion: maps[0]['coverArtVersion'] as int? ?? 0,
      originalLanguage: maps[0]['originalLanguage'] as String? ?? 'unknown',
      language: maps[0]['language'] as String?,
      hasLyrics: hasLyrics,
      isInLibrary: isInLibrary,
      createdAt: DateTime.parse(maps[0]['createdAt'] as String),
    );
  }

  Future<void> updateSong(Song song) async {
    final db = await database;
    await db.update(
      'songs',
      song.toJson(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<void> deleteSong(String id) async {
    final db = await database;
    await db.delete(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllSongs() async {
    final db = await database;
    await db.delete('songs');
  }

  Future<int> getSongCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('playlists');

    return List.generate(maps.length, (i) {
      return Playlist(
        id: maps[i]['id'] as String,
        name: maps[i]['name'] as String,
        icon: maps[i]['icon'] as String?,
        isSystem: maps[i]['isSystem'] as int == 1,
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
        songCount: maps[i]['songCount'] as int? ?? 0,
        musicFolderPath: maps[i]['musicFolderPath'] as String?,
        lyricsFolderPath: maps[i]['lyricsFolderPath'] as String?,
        coverArtPath: maps[i]['coverArtPath'] as String?,
        coverArtVersion: maps[i]['coverArtVersion'] as int? ?? 0,
      );
    });
  }

  Future<Playlist?> getPlaylist(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    return Playlist(
      id: maps[0]['id'] as String,
      name: maps[0]['name'] as String,
      icon: maps[0]['icon'] as String?,
      isSystem: maps[0]['isSystem'] as int == 1,
      createdAt: DateTime.parse(maps[0]['createdAt'] as String),
      songCount: maps[0]['songCount'] as int? ?? 0,
      musicFolderPath: maps[0]['musicFolderPath'] as String?,
      lyricsFolderPath: maps[0]['lyricsFolderPath'] as String?,
      coverArtPath: maps[0]['coverArtPath'] as String?,
      coverArtVersion: maps[0]['coverArtVersion'] as int? ?? 0,
    );
  }

  Future<void> insertPlaylist(Playlist playlist) async {
    final db = await database;
    await db.insert(
      'playlists',
      playlist.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    final db = await database;
    await db.update(
      'playlists',
      playlist.toJson(),
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<void> deletePlaylist(String id) async {
    final db = await database;
    await db.delete(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Song>> getSongsInPlaylist(String playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.* FROM songs s
      INNER JOIN playlist_songs ps ON s.id = ps.songId
      WHERE ps.playlistId = ?
      ORDER BY ps.position
    ''', [playlistId]);

    return List.generate(maps.length, (i) {
      final hasLyricsValue = maps[i]['hasLyrics'];
      final hasLyrics = hasLyricsValue == 1 || hasLyricsValue == true;

      return Song(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        artist: maps[i]['artist'] as String,
        audioPath: maps[i]['audioPath'] as String,
        lrcPath: maps[i]['lrcPath'] as String?,
        translationsPath: maps[i]['translationsPath'] as String?,
        coverArtPath: maps[i]['coverArtPath'] as String?,
        coverArtVersion: maps[i]['coverArtVersion'] as int? ?? 0,
        originalLanguage: maps[i]['originalLanguage'] as String? ?? 'unknown',
        language: maps[i]['language'] as String?,
        hasLyrics: hasLyrics,
        createdAt: DateTime.parse(maps[i]['createdAt'] as String),
      );
    });
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final db = await database;

    final existing = await db.query(
      'playlist_songs',
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
    );

    if (existing.isEmpty) {
      final maxPosition = await db.rawQuery('''
        SELECT MAX(position) as maxPos FROM playlist_songs
        WHERE playlistId = ?
      ''', [playlistId]);

      final position = (maxPosition[0]['maxPos'] as int? ?? 0) + 1;

      await db.insert(
        'playlist_songs',
        {
          'playlistId': playlistId,
          'songId': songId,
          'position': position,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      await db.rawUpdate('''
        UPDATE playlists SET songCount = songCount + 1 WHERE id = ?
      ''', [playlistId]);
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final db = await database;
    await db.delete(
      'playlist_songs',
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
    );

    await db.rawUpdate('''
      UPDATE playlists SET songCount = songCount - 1 WHERE id = ? AND songCount > 0
    ''', [playlistId]);
  }

  Future<void> clearPlaylistSongs(String playlistId) async {
    final db = await database;
    await db.delete(
      'playlist_songs',
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );

    await db.rawUpdate('''
      UPDATE playlists
      SET songCount = 0
      WHERE id = ?
    ''', [playlistId]);

    debugPrint('Cleared all songs from playlist: $playlistId');
  }

  Future<void> updatePlaylistSongsOrder(String playlistId, List<String> songIds) async {
    final db = await database;
    final batch = db.batch();

    for (int i = 0; i < songIds.length; i++) {
      batch.update(
        'playlist_songs',
        {'position': i},
        where: 'playlistId = ? AND songId = ?',
        whereArgs: [playlistId, songIds[i]],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> getPlaylistSongCount(String playlistId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM playlist_songs
      WHERE playlistId = ?
    ''', [playlistId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> updateSongAudioPath(String songId, String newAudioPath) async {
    final db = await database;
    await db.update(
      'songs',
      {'audioPath': newAudioPath},
      where: 'id = ?',
      whereArgs: [songId],
    );
    debugPrint('Updated audio path for song $songId: $newAudioPath');
  }

  Future<int> updateAllSongPaths(Map<String, String> fileNameToPathMap) async {
    final db = await database;
    int updatedCount = 0;

    debugPrint('=== Updating all song paths ===');
    debugPrint('Files to update: ${fileNameToPathMap.length}');

    for (final entry in fileNameToPathMap.entries) {
      final fileName = entry.key.toLowerCase().replaceAll(RegExp(r'\.(mp3|wav|m4a|ogg|flac)$', caseSensitive: false), '');
      final newPath = entry.value;

      final fileNameEscaped = fileName.replaceAll(RegExp(r"[\\%_']"), r"\\$0");
      final result = await db.update(
        'songs',
        {'audioPath': newPath},
        where: 'LOWER(audioPath) LIKE ? OR LOWER(title) LIKE ?',
        whereArgs: ['%$fileNameEscaped%', '%$fileNameEscaped%'],
      );

      if (result > 0) {
        updatedCount++;
        debugPrint('✓ Updated path for filename: ${entry.key}');
      } else {
        debugPrint('✗ No match found for filename: ${entry.key}');
      }
    }

    debugPrint('=== Total paths updated: $updatedCount ===');
    return updatedCount;
  }

  Future<void> mergeDatabase(String importedDbPath, {String? newFolderPath}) async {
    debugPrint('=== Merging database from: $importedDbPath ===');
    debugPrint('Rebase paths to: $newFolderPath');

    try {
      final db = await database;
      final importedDb = await openDatabase(
        importedDbPath,
        readOnly: true,
      );

      await db.transaction((txn) async {
        // 1. Merge songs
        final importedSongs = await importedDb.query('songs');

        for (final songMap in importedSongs) {
          final songId = songMap['id'] as String;
          final existingSong = await txn.query(
            'songs',
            where: 'id = ?',
            whereArgs: [songId],
          );

          if (existingSong.isEmpty) {
            Map<String, dynamic> songToInsert = Map.from(songMap);
            
            if (newFolderPath != null) {
              final audioPath = songToInsert['audioPath'] as String;
              songToInsert['audioPath'] = path.join(newFolderPath, path.basename(audioPath));
              
              final lrcPath = songToInsert['lrcPath'] as String?;
              if (lrcPath != null && lrcPath.isNotEmpty) {
                songToInsert['lrcPath'] = path.join(newFolderPath, path.basename(lrcPath));
              }
              
              final coverArtPath = songToInsert['coverArtPath'] as String?;
              if (coverArtPath != null && coverArtPath.isNotEmpty) {
                songToInsert['coverArtPath'] = path.join(newFolderPath, path.basename(coverArtPath));
              }
            }

            await txn.insert('songs', songToInsert, conflictAlgorithm: ConflictAlgorithm.replace);
            debugPrint('Added new song: ${songToInsert['title']}');
          }
        }

        // 2. Merge song_translations
        final importedTranslations = await importedDb.query('song_translations');
        for (final transMap in importedTranslations) {
          final transId = transMap['id'] as String;
          final existingTrans = await txn.query(
            'song_translations',
            where: 'id = ?',
            whereArgs: [transId],
          );

          if (existingTrans.isEmpty) {
            Map<String, dynamic> transToInsert = Map.from(transMap);
            
            if (newFolderPath != null) {
              final filePath = transToInsert['filePath'] as String;
              transToInsert['filePath'] = path.join(newFolderPath, path.basename(filePath));
            }
            
            await txn.insert('song_translations', transToInsert, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }

        // 3. Merge playlists
        final importedPlaylists = await importedDb.query('playlists');

        for (final playlistMap in importedPlaylists) {
          final playlistId = playlistMap['id'] as String;
          final existingPlaylist = await txn.query(
            'playlists',
            where: 'id = ?',
            whereArgs: [playlistId],
          );

          if (existingPlaylist.isEmpty) {
            Map<String, dynamic> playlistToInsert = Map.from(playlistMap);
            
            if (newFolderPath != null) {
              final musicFolder = playlistToInsert['musicFolderPath'] as String?;
              if (musicFolder != null && musicFolder.isNotEmpty) {
                playlistToInsert['musicFolderPath'] = newFolderPath;
              }
              
              final lyricsFolder = playlistToInsert['lyricsFolderPath'] as String?;
              if (lyricsFolder != null && lyricsFolder.isNotEmpty) {
                playlistToInsert['lyricsFolderPath'] = newFolderPath;
              }
              
              final coverArtPath = playlistToInsert['coverArtPath'] as String?;
              if (coverArtPath != null && coverArtPath.isNotEmpty) {
                playlistToInsert['coverArtPath'] = path.join(newFolderPath, path.basename(coverArtPath));
              }
            }

            await txn.insert('playlists', playlistToInsert, conflictAlgorithm: ConflictAlgorithm.replace);
            debugPrint('Added new playlist: ${playlistToInsert['name']}');
          }
        }

        // 4. Merge playlist_songs
        final importedPlaylistSongs = await importedDb.query('playlist_songs');

        for (final psMap in importedPlaylistSongs) {
          final playlistId = psMap['playlistId'] as String;
          final songId = psMap['songId'] as String;

          final existing = await txn.query(
            'playlist_songs',
            where: 'playlistId = ? AND songId = ?',
            whereArgs: [playlistId, songId],
          );

          if (existing.isEmpty) {
            await txn.insert('playlist_songs', psMap, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });

      await importedDb.close();
      debugPrint('Database merge completed');
    } catch (e) {
      debugPrint('Error merging database: $e');
      rethrow;
    }
  }

  Future<void> addTranslationFile(String songId, String language, String languageName, String filePath, {String? type}) async {
    final db = await database;
    final id = '${songId}_${language}_${type ?? 'default'}';
    final now = DateTime.now().toIso8601String();

    await db.insert(
      'song_translations',
      {
        'id': id,
        'songId': songId,
        'language': language,
        'languageName': languageName,
        'filePath': filePath,
        'type': type,
        'createdAt': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('Added translation: $languageName for song $songId');
  }

  Future<List<Map<String, dynamic>>> getTranslationFiles(String songId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'song_translations',
      where: 'songId = ?',
      whereArgs: [songId],
      orderBy: 'language ASC, type ASC',
    );

    debugPrint('Found ${maps.length} translation files for song $songId');
    return maps;
  }

  Future<void> removeTranslationFile(String songId, String language, {String? type}) async {
    final db = await database;

    String whereClause = 'songId = ? AND language = ?';
    List<dynamic> whereArgs = [songId, language];

    if (type != null) {
      whereClause += ' AND type = ?';
      whereArgs.add(type);
    } else {
      whereClause += ' AND type IS NULL';
    }

    await db.delete(
      'song_translations',
      where: whereClause,
      whereArgs: whereArgs,
    );

    debugPrint('Removed translation: $language for song $songId');
  }

  Future<void> clearTranslationsForSong(String songId) async {
    final db = await database;
    await db.delete(
      'song_translations',
      where: 'songId = ?',
      whereArgs: [songId],
    );

    debugPrint('Cleared all translations for song $songId');
  }

  Future<int> getTranslationCount(String songId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM song_translations
      WHERE songId = ?
    ''', [songId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> setSelectedLanguage(String songId, String language) async {
    final db = await database;
    await db.update(
      'songs',
      {'selectedLanguage': language},
      where: 'id = ?',
      whereArgs: [songId],
    );
    debugPrint('Selected language saved: $language for song $songId');
  }

  Future<String?> getSelectedLanguage(String songId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'songs',
      columns: ['selectedLanguage'],
      where: 'id = ?',
      whereArgs: [songId],
      limit: 1,
    );
    if (result.isNotEmpty && result[0]['selectedLanguage'] != null) {
      return result[0]['selectedLanguage'] as String;
    }
    return null;
  }

  Future<void> clearAllSelectedLanguages() async {
    final db = await database;
    final count = await db.update(
      'songs',
      {'selectedLanguage': null},
      where: 'selectedLanguage IS NOT NULL',
    );
    debugPrint('Cleared selected languages for $count songs');
  }

  static Future<List<Song>> insertBatchSongs(List<Map<String, dynamic>> songsData) async {
    final dbPath = await getDatabasesPath();
    final databasePath = path.join(dbPath, 'lingotune.db');

    final db = await openDatabase(
      databasePath,
      version: 11,
      readOnly: false,
    );

    try {
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final songData in songsData) {
          batch.insert('songs', songData, conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      });

      return List.generate(songsData.length, (i) {
        final songData = songsData[i];
        final hasLyricsValue = songData['hasLyrics'];
        final hasLyrics = hasLyricsValue == 1 || hasLyricsValue == true;

        return Song(
          id: songData['id'] as String,
          title: songData['title'] as String,
          artist: songData['artist'] as String,
          audioPath: songData['audioPath'] as String,
          lrcPath: songData['lrcPath'] as String?,
          translationsPath: songData['translationsPath'] as String?,
          coverArtPath: songData['coverArtPath'] as String?,
          coverArtVersion: songData['coverArtVersion'] as int? ?? 0,
          originalLanguage: songData['originalLanguage'] as String? ?? 'unknown',
          language: songData['language'] as String?,
          hasLyrics: hasLyrics,
          createdAt: DateTime.parse(songData['createdAt'] as String),
        );
      });
    } finally {
      await db.close();
    }
  }

  static Future<void> addBatchSongsToPlaylist(String playlistId, List<String> songIds) async {
    final dbPath = await getDatabasesPath();
    final databasePath = path.join(dbPath, 'lingotune.db');

    final db = await openDatabase(
      databasePath,
      version: 11,
      readOnly: false,
    );

    try {
      await db.transaction((txn) async {
        final maxPositionResult = await txn.rawQuery('''
          SELECT MAX(position) as maxPos FROM playlist_songs
          WHERE playlistId = ?
        ''', [playlistId]);
        final maxPosition = (maxPositionResult.isNotEmpty && maxPositionResult[0]['maxPos'] != null)
            ? (maxPositionResult[0]['maxPos'] as int? ?? 0) + 1
            : 1;

        final batch = txn.batch();
        for (int i = 0; i < songIds.length; i++) {
          batch.insert('playlist_songs', {
            'playlistId': playlistId,
            'songId': songIds[i],
            'position': maxPosition + i,
          });
        }
        await batch.commit(noResult: true);
      });
    } finally {
      await db.close();
    }
  }

  String normalizePathForSync(String rawPath) {
    if (rawPath.isEmpty) return rawPath;
    
    // Standardize slashes and lowercase
    String norm = path.normalize(rawPath).toLowerCase().replaceAll('\\', '/');
    
    // Remove common Android root stems for consistent matching across different symlinks
    final stems = [
      '/storage/emulated/0/',
      '/sdcard/',
      '/mnt/sdcard/',
      '/data/media/0/',
    ];
    
    for (final stem in stems) {
      final stemLower = stem.toLowerCase();
      if (norm.startsWith(stemLower)) {
        norm = norm.substring(stemLower.length);
        break;
      }
    }
    
    // Strip leading slash if any after stem removal
    if (norm.startsWith('/')) {
      norm = norm.substring(1);
    }
    
    return norm;
  }

  /// Deduplicates the 'songs' table by 'audioPath'. Keeps first, updates playlist associations, removes others.
  Future<int> deduplicateSongs() async {
    final db = await database;
    try {
      debugPrint('🔍 Starting song deduplication...');
      final List<Map<String, dynamic>> allSongs = await db.query('songs', columns: ['id', 'audioPath', 'createdAt']);
      
      final Map<String, List<Map<String, dynamic>>> pathMap = {};
      for (final song in allSongs) {
        final normalized = normalizePathForSync(song['audioPath'] as String);
        if (!pathMap.containsKey(normalized)) {
          pathMap[normalized] = [];
        }
        pathMap[normalized]!.add(song);
      }
      
      int deletedCount = 0;
      await db.transaction((txn) async {
        for (final entry in pathMap.entries) {
          final records = entry.value;
          if (records.length > 1) {
            // Sort by creation date to keep the oldest one
            records.sort((a, b) => (a['createdAt'] as String).compareTo(b['createdAt'] as String));
            
            final keepId = records[0]['id'] as String;
            final toDelete = records.skip(1).map((r) => r['id'] as String).toList();
            
            for (final otherId in toDelete) {
              debugPrint('♻️ Merging duplicate song: $otherId -> $keepId');
              
              // 1. Move songs in playlists to the kept ID (ignore duplicates in same playlist via SQL)
              await txn.rawUpdate('''
                UPDATE OR IGNORE playlist_songs 
                SET songId = ? 
                WHERE songId = ?
              ''', [keepId, otherId]);
              
              // 2. Remove remaining links to the dupe if the above IGNORE'd some (i.e. dupe was already in playlist)
              await txn.delete('playlist_songs', where: 'songId = ?', whereArgs: [otherId]);
              
              // 3. Delete the duplicate song (translations will be deleted by CASCADE)
              await txn.delete('songs', where: 'id = ?', whereArgs: [otherId]);
              deletedCount++;
            }
          }
        }
      });
      
      if (deletedCount > 0) {
        debugPrint('✅ Deduplication complete: removed $deletedCount duplicates.');
      }
      return deletedCount;
    } catch (e) {
      debugPrint('❌ Error during deduplication: $e');
      return 0;
    }
  }

  Future<void> updateSongLrcPath(String songId, String lrcPath) async {
    final db = await database;
    await db.update(
      'songs',
      {
        'lrcPath': lrcPath,
        'hasLyrics': 1,
      },
      where: 'id = ?',
      whereArgs: [songId],
    );
    debugPrint('Updated LRC path for song $songId: $lrcPath (hasLyrics set to true)');
  }

  Future<void> updateSongOriginalLanguage(String songId, String originalLanguage) async {
    final db = await database;
    await db.update(
      'songs',
      {'originalLanguage': originalLanguage},
      where: 'id = ?',
      whereArgs: [songId],
    );
    debugPrint('Updated originalLanguage for song $songId: $originalLanguage');
  }

  Future<void> updateSongHasLyrics(String songId, bool hasLyrics) async {
    final db = await database;
    await db.update(
      'songs',
      {'hasLyrics': hasLyrics ? 1 : 0},
      where: 'id = ?',
      whereArgs: [songId],
    );
    debugPrint('Updated hasLyrics for song $songId: $hasLyrics');
  }

  Future<void> addTranslation({
    required String songId,
    required String language,
    required String languageName,
    required String filePath,
    String? type,
  }) async {
    final db = await database;
    final id = '${songId}_$language';

    await db.insert(
      'song_translations',
      {
        'id': id,
        'songId': songId,
        'language': language,
        'languageName': languageName,
        'filePath': filePath,
        'type': type,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.update(
      'songs',
      {'hasLyrics': 1},
      where: 'id = ?',
      whereArgs: [songId],
    );

    debugPrint('Added translation: $language for song $songId (hasLyrics set to true)');
  }

  Future<void> rebaseAllPaths(String newFolderPath) async {
    final db = await database;
    try {
      debugPrint('🚀 Starting path rebasing to: $newFolderPath');

      await db.transaction((txn) async {
        // 1. Update songs table (audioPath, lrcPath, coverArtPath)
        final songs = await txn.query('songs', columns: ['id', 'audioPath', 'lrcPath', 'coverArtPath']);
        for (final song in songs) {
          final id = song['id'] as String;
          final audioPath = song['audioPath'] as String;
          final lrcPath = song['lrcPath'] as String?;
          final coverArtPath = song['coverArtPath'] as String?;

          final newAudioPath = path.join(newFolderPath, path.basename(audioPath));
          String? newLrcPath;
          if (lrcPath != null && lrcPath.isNotEmpty) {
            newLrcPath = path.join(newFolderPath, path.basename(lrcPath));
          }
          String? newCoverArtPath;
          if (coverArtPath != null && coverArtPath.isNotEmpty) {
            newCoverArtPath = path.join(newFolderPath, path.basename(coverArtPath));
          }

          await txn.update(
            'songs',
            {
              'audioPath': newAudioPath,
              if (newLrcPath != null) 'lrcPath': newLrcPath,
              if (newCoverArtPath != null) 'coverArtPath': newCoverArtPath,
            },
            where: 'id = ?',
            whereArgs: [id],
          );
        }

        // 2. Update song_translations table (filePath)
        final translations = await txn.query('song_translations', columns: ['id', 'filePath']);
        for (final trans in translations) {
          final id = trans['id'] as String;
          final filePath = trans['filePath'] as String;
          final newFilePath = path.join(newFolderPath, path.basename(filePath));

          await txn.update(
            'song_translations',
            {'filePath': newFilePath},
            where: 'id = ?',
            whereArgs: [id],
          );
        }

        // 3. Update playlists table (musicFolderPath, lyricsFolderPath, coverArtPath)
        // Since we are moving everything to the new configured folder, we might as well update these
        final playlists = await txn.query('playlists', columns: ['id', 'musicFolderPath', 'lyricsFolderPath', 'coverArtPath']);
        for (final playlist in playlists) {
          final id = playlist['id'] as String;
          final musicFolder = playlist['musicFolderPath'] as String?;
          final lyricsFolder = playlist['lyricsFolderPath'] as String?;
          final coverArtPath = playlist['coverArtPath'] as String?;

          await txn.update(
            'playlists',
            {
              if (musicFolder != null && musicFolder.isNotEmpty) 'musicFolderPath': newFolderPath,
              if (lyricsFolder != null && lyricsFolder.isNotEmpty) 'lyricsFolderPath': newFolderPath,
              if (coverArtPath != null && coverArtPath.isNotEmpty) 
                'coverArtPath': path.join(newFolderPath, path.basename(coverArtPath)),
            },
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      });

      debugPrint('✅ Path rebasing completed.');
    } catch (e) {
      debugPrint('❌ Error during path rebasing: $e');
    }
  }
}
