import 'package:flutter_test/flutter_test.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/models/lyric_line.dart';
import 'package:lingotune/models/translation.dart';

void main() {
  group('Song Model Tests', () {
    test('Song should be created correctly', () {
      final song = Song(
        id: '1',
        title: 'Test Song',
        artist: 'Test Artist',
        audioPath: '/path/to/song.mp3',
        originalLanguage: 'en',
      );

      expect(song.id, '1');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
      expect(song.originalLanguage, 'en');
    });

    test('Song should be serialized to JSON', () {
      final song = Song(
        id: '1',
        title: 'Test Song',
        artist: 'Test Artist',
        audioPath: '/path/to/song.mp3',
        originalLanguage: 'en',
      );

      final json = song.toJson();
      
      expect(json['id'], '1');
      expect(json['title'], 'Test Song');
      expect(json['artist'], 'Test Artist');
    });

    test('Song should be deserialized from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Song',
        'artist': 'Test Artist',
        'audioPath': '/path/to/song.mp3',
        'originalLanguage': 'en',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      final song = Song.fromJson(json);
      
      expect(song.id, '1');
      expect(song.title, 'Test Song');
      expect(song.artist, 'Test Artist');
    });
  });

  group('LyricLine Model Tests', () {
    test('LyricLine should be created correctly', () {
      final line = LyricLine(
        startTime: 10.5,
        text: 'Test line',
        translatedText: 'Test translation',
      );

      expect(line.startTime, 10.5);
      expect(line.text, 'Test line');
      expect(line.translatedText, 'Test translation');
    });

    test('LyricLine should be serialized to JSON', () {
      final line = LyricLine(
        startTime: 10.5,
        text: 'Test line',
      );

      final json = line.toJson();
      
      expect(json['startTime'], 10.5);
      expect(json['text'], 'Test line');
    });
  });

  group('Translation Model Tests', () {
    test('Translation should be created correctly', () {
      final translation = Translation(
        language: 'ru',
        languageName: 'Russian',
        lines: [
          LyricLine(
            startTime: 10.5,
            text: 'Перевод',
          ),
        ],
      );

      expect(translation.language, 'ru');
      expect(translation.languageName, 'Russian');
      expect(translation.lines.length, 1);
    });
  });
}
