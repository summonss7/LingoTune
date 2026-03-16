import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../constants/generation_constants.dart';
import '../models/lyric_line.dart';
import '../models/generation_result.dart';
import 'deepseek_api_service.dart';

class LyricsGeneratorService {
  final DeepSeekApiService apiService;

  LyricsGeneratorService({required this.apiService});

  Future<List<LyricLine>> parseLrcFile(String filePath) async {
    debugPrint('=== Parsing LRC file: $filePath ===');

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('File does not exist: $filePath');
        throw Exception('File not found: $filePath');
      }

      final content = await file.readAsString();
      final lines = <LyricLine>[];
      final regex = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.+)');

      for (final line in content.split('\n')) {
        final match = regex.firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final centiseconds = int.parse(match.group(3)!);
          final text = match.group(4)!.trim();

          final startTime = minutes * 60.0 + seconds + centiseconds / 100.0;

          if (text.isNotEmpty) {
            lines.add(LyricLine(
              startTime: startTime + 1800.0,
              text: text,
            ));
          }
        }
      }

      debugPrint('Parsed ${lines.length} lines from LRC file');
      return lines;
    } catch (e) {
      debugPrint('Error parsing LRC file: $e');
      rethrow;
    }
  }

  Future<List<LyricLine>> parseTextFile(String filePath) async {
    debugPrint('=== Parsing text file: $filePath ===');

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('File does not exist: $filePath');
        throw Exception('File not found: $filePath');
      }

      final content = await file.readAsString();
      final lines = <LyricLine>[];

      double startTime = GenerationConstants.defaultStartTime;

      for (final line in content.split('\n')) {
        final text = line.trim();

        if (text.isNotEmpty && !text.startsWith('﻿')) {
          lines.add(LyricLine(
            startTime: startTime,
            text: text,
          ));
          startTime += GenerationConstants.timingStep;
        }
      }

      debugPrint('Parsed ${lines.length} lines from text file');
      return lines;
    } catch (e) {
      debugPrint('Error parsing text file: $e');
      rethrow;
    }
  }

  List<LyricLine> parseTextString(String text) {
    debugPrint('=== Parsing text string ===');
    final lines = <LyricLine>[];
    double startTime = GenerationConstants.defaultStartTime;

    for (final line in text.split('\n')) {
      final trimmed = line.trim();

      if (trimmed.isNotEmpty && !trimmed.startsWith('﻿')) {
        lines.add(LyricLine(
          startTime: startTime,
          text: trimmed,
        ));
        startTime += GenerationConstants.timingStep;
      }
    }

    debugPrint('Parsed ${lines.length} lines from text string');
    return lines;
  }

  Future<GenerationResult> generateForSong({
    required String songId,
    required String songTitle,
    required List<LyricLine> originalLines,
    required List<String> languages,
    required Function(int current, int total)? onProgress,
    Function(String message)? onStatus,
  }) async {
    debugPrint('=== Generating translations for: $songTitle ===');
    debugPrint('Languages: ${languages.join(", ")}');
    debugPrint('Lines: ${originalLines.length}');

    final startTime = DateTime.now();
    final translations = <String, List<LyricLine>>{};
    final errors = <String>[];
    int successCount = 0;
    int errorCount = 0;

    final originalTexts = originalLines.map((line) => line.text).toList();

    for (final lang in languages) {
      onStatus?.call('Генерация ${GenerationConstants.getTargetLanguageName(lang)}...');

      try {
        String? type;
        String targetLanguage = lang;
        String alphabet = 'latin';

        if (lang == 'trans') {
          type = 'transcript';
          targetLanguage = 'ro';
        } else if (lang == 'ru_literal') {
          type = 'literal';
          targetLanguage = 'ru';
          alphabet = 'cyrillic';
        } else if (lang == 'ru') {
          alphabet = 'cyrillic';
        }

        final translatedTexts = await apiService.translateBatch(
          texts: originalTexts,
          sourceLanguage: 'ro',
          targetLanguage: targetLanguage,
          type: type,
          onProgress: (current, total) {
            onProgress?.call(current, total * languages.length);
          },
        );

        if (lang == 'trans') {
          final translatedLines = <LyricLine>[];
          for (int i = 0; i < originalLines.length; i++) {
            translatedLines.add(LyricLine(
              startTime: originalLines[i].startTime,
              text: translatedTexts[i] ?? '',
            ));
          }
          translations[lang] = translatedLines;
        } else {
          final futures = <Future<String?>>[];
          for (int i = 0; i < originalLines.length; i++) {
            final translation = translatedTexts[i] ?? '';
            if (translation.trim().isEmpty) {
              futures.add(Future.value(null));
            } else {
              futures.add(apiService.translateLine(
                text: translation,
                sourceLanguage: targetLanguage,
                targetLanguage: alphabet == 'cyrillic' ? 'ru' : 'en',
                type: 'transcript',
              ));
            }
          }

          final transcripts = await Future.wait(futures, eagerError: false);

          final translatedLines = <LyricLine>[];
          for (int i = 0; i < originalLines.length; i++) {
            translatedLines.add(LyricLine(
              startTime: originalLines[i].startTime,
              text: translatedTexts[i] ?? '',
              transcript: transcripts[i],
            ));
          }
          translations[lang] = translatedLines;
        }

        successCount += translatedTexts.length;
        debugPrint('✓ Generated $lang: ${translatedTexts.length} lines');
      } catch (e) {
        final error = 'Error generating $lang: $e';
        errors.add(error);
        errorCount++;
        debugPrint('✗ $error');
      }
    }

    final duration = DateTime.now().difference(startTime);

    return GenerationResult(
      songId: songId,
      songTitle: songTitle,
      translations: translations,
      errors: errors,
      successCount: successCount,
      errorCount: errorCount,
      duration: duration,
      completed: errors.isEmpty,
    );
  }

  Future<List<GenerationResult>> generateBatch({
    required List<Map<String, dynamic>> songs,
    required List<String> languages,
    required Function(int current, int total)? onProgress,
    Function(String message)? onStatus,
  }) async {
    debugPrint('=== Batch generating translations for ${songs.length} songs ===');

    final results = <GenerationResult>[];
    int totalLines = 0;

    for (final song in songs) {
      final songId = song['id'] as String;
      final songTitle = song['title'] as String;
      final filePath = song['filePath'] as String;
      final isLrc = song['isLrc'] as bool;

      onStatus?.call('Обработка: $songTitle');

      try {
        final originalLines = isLrc
            ? await parseLrcFile(filePath)
            : await parseTextFile(filePath);

        totalLines += originalLines.length;

        final result = await generateForSong(
          songId: songId,
          songTitle: songTitle,
          originalLines: originalLines,
          languages: languages,
          onProgress: (current, total) {
            onProgress?.call(results.length * total + current, songs.length * total);
          },
          onStatus: onStatus,
        );

        results.add(result);
      } catch (e) {
        debugPrint('✗ Error processing song $songTitle: $e');
        results.add(GenerationResult(
          songId: songId,
          songTitle: songTitle,
          translations: {},
          errors: ['Error: $e'],
          successCount: 0,
          errorCount: 1,
          duration: Duration.zero,
        ));
      }
    }

    return results;
  }

  Future<void> saveToJsonFile({
    required String filePath,
    required String songTitle,
    required String originalLanguage,
    required Map<String, List<LyricLine>> translations,
  }) async {
    debugPrint('=== Saving translations to: $filePath ===');

    try {
      final translationList = translations.entries.map((entry) {
        final language = entry.key;
        final lines = entry.value;

        String? type;
        String languageName = GenerationConstants.supportedLanguages[language] ?? language;

        if (language == 'trans') {
          type = 'transcript';
        } else if (language == 'ru_literal') {
          type = 'literal';
        }

        final lineData = lines.map((line) {
          final map = <String, dynamic>{
            'startTime': line.startTime,
            'text': line.text,
            'translatedText': null,
            'transcript': line.transcript,
            'originalStartTime': null,
          };
          return map;
        }).toList();

        return {
          'language': language,
          'languageName': languageName,
          if (type != null) 'type': type,
          'lines': lineData,
        };
      }).toList();

      final data = {
        'title': songTitle,
        'artist': 'Unknown',
        'originalLanguage': originalLanguage,
        'translations': translationList,
      };

      final file = File(filePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final jsonString = json.encode(data);
      await file.writeAsString(jsonString, encoding: utf8);

      debugPrint('✓ Saved ${translations.length} translations to $filePath');
    } catch (e) {
      debugPrint('✗ Error saving translations: $e');
      rethrow;
    }
  }

  Future<void> saveToLrcFile({
    required String filePath,
    required List<LyricLine> lines,
  }) async {
    debugPrint('=== Saving LRC file: $filePath ===');

    try {
      final file = File(filePath);
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final buffer = StringBuffer();

      for (final line in lines) {
        final adjustedTime = line.startTime - 1800.0;
        if (adjustedTime < 0) {
          debugPrint('Warning: Negative time ${line.startTime}s adjusted to 0s');
          continue;
        }
        final minutes = adjustedTime ~/ 60;
        final seconds = (adjustedTime % 60).toInt();
        final centiseconds = ((adjustedTime % 1) * 100).toInt();

        buffer.write('[${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}.'
            '${centiseconds.toString().padLeft(2, '0')}]');
        buffer.writeln(line.text);
      }

      await file.writeAsString(buffer.toString(), encoding: utf8);
      debugPrint('✓ Saved ${lines.length} lines to LRC file');
    } catch (e) {
      debugPrint('✗ Error saving LRC file: $e');
      rethrow;
    }
  }
}
