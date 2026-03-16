import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/translation.dart';
import '../models/lyric_line.dart';

class TranslationService extends ChangeNotifier {
  Translation? _currentTranslation;
  int _currentLanguageIndex = 0;
  List<Translation> _translations = [];
  Translation? _transcriptTranslation;
  String? _translationsPath;

  Translation? get currentTranslation => _currentTranslation;
  int get currentLanguageIndex => _currentLanguageIndex;
  List<Translation> get translations => _translations;
  Translation? get transcriptTranslation => _transcriptTranslation;
  String? get translationsPath => _translationsPath;

  Future<void> loadTranslations(String translationsPath) async {
    try {
      debugPrint('=== DEBUG: Loading Translations ===');
      debugPrint('Translations path: $translationsPath');

      _translationsPath = translationsPath;
      final file = File(translationsPath);
      final exists = await file.exists();
      debugPrint('Translations file exists: $exists');

      if (!exists) {
        debugPrint('ERROR: Translations file not found at path: $translationsPath');
        return;
      }

      debugPrint('Reading translations file content...');
      final content = await file.readAsString();
      debugPrint('Translations file content length: ${content.length} characters');

      final data = json.decode(content) as Map<String, dynamic>;
      debugPrint('Parsed JSON data, keys: ${data.keys.toList()}');

      if (!data.containsKey('translations')) {
        debugPrint('ERROR: JSON does not contain "translations" key');
        return;
      }

      final allTranslations = (data['translations'] as List?)
          ?.map((t) => Translation.fromJson(t as Map<String, dynamic>))
          .toList() ?? [];

      _translations.clear();
      _transcriptTranslation = null;

      for (final translation in allTranslations) {
        for (final line in translation.lines) {
          if (line.originalStartTime == null) {
            line.originalStartTime = line.startTime;
          }
        }
        
        if (translation.type == 'transcript') {
          debugPrint('Found transcript translation: ${translation.languageName}');
          _transcriptTranslation = translation;
        } else {
          _translations.add(translation);
        }
      }

      debugPrint('Found ${_translations.length} regular translations');
      debugPrint('Found transcript: ${_transcriptTranslation != null}');

      if (_translations.isEmpty) {
        debugPrint('WARNING: No translations found in JSON');
      } else {
        _currentTranslation = _translations[0];
        _currentLanguageIndex = 0;
        debugPrint('Current translation: ${_currentTranslation?.languageName}');
        debugPrint('Translation type: ${_currentTranslation?.type}');
        debugPrint('Translation has ${_currentTranslation?.lines?.length ?? 0} lines');
      }

      _sortTranslationsByPriority();
      notifyListeners();
      debugPrint('Translations loaded successfully, notified listeners');
    } catch (e) {
      debugPrint('=== ERROR: Failed to load translations ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  void addTranslation(Translation translation) {
    final existingIndex = _translations.indexWhere((t) =>
      t.language == translation.language && t.type == translation.type
    );

    if (existingIndex != -1) {
      debugPrint('Replacing existing translation for language: ${translation.language} type: ${translation.type}');
      _translations[existingIndex] = translation;
    } else {
      debugPrint('Adding new translation for language: ${translation.language} type: ${translation.type}');
      _translations.add(translation);
    }

    _sortTranslationsByPriority();
    notifyListeners();
  }

  void _sortTranslationsByPriority() {
    final languagePriority = {
      'trans': 0,
      'ru': 1,
      'en': 2,
      'ro': 3,
      'fr': 4,
      'de': 5,
      'es': 6,
      'it': 7,
      'pt': 8,
    };

    _translations.sort((a, b) {
      final priorityA = languagePriority[a.language.toLowerCase()] ?? 999;
      final priorityB = languagePriority[b.language.toLowerCase()] ?? 999;

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      if (a.type != b.type) {
        if (a.type == null) return -1;
        if (b.type == null) return 1;
        return (a.type ?? '').compareTo(b.type ?? '');
      }

      return 0;
    });

    debugPrint('Translations sorted by priority:');
    for (int i = 0; i < _translations.length; i++) {
      debugPrint('  ${i + 1}. ${_translations[i].languageName} (${_translations[i].language}) type: ${_translations[i].type}');
    }
  }

  void selectLanguage(int index) {
    if (index >= 0 && index < _translations.length) {
      _currentLanguageIndex = index;
      _currentTranslation = _translations[index];
      notifyListeners();
    }
  }

  void selectLanguageByCode(String languageCode) {
    final index = _translations.indexWhere((t) => t.language == languageCode);
    if (index != -1) {
      selectLanguage(index);
    }
  }

  String? _getLineContent(List<LyricLine> lines, double startTime, bool useTranscript) {
    for (final line in lines) {
      if ((line.startTime - startTime).abs() < 0.1) {
        return useTranscript ? line.transcript : line.text;
      }
    }
    return null;
  }

  String? getTranscriptForLine(double startTime) {
    if (_transcriptTranslation == null) return null;
    return _getLineContent(_transcriptTranslation!.lines, startTime, false);
  }

  String? getTranscriptFromCurrentTranslation(double startTime) {
    if (_currentTranslation == null) return null;
    return _getLineContent(_currentTranslation!.lines, startTime, true);
  }

  String? getTranslationForLine(double startTime) {
    if (_currentTranslation == null) return null;
    return _getLineContent(_currentTranslation!.lines, startTime, false);
  }

  Map<String, int> _updateSingleTranslationTimestamps(
    List<LyricLine> translationLines,
    List<LyricLine> lyricLines,
  ) {
    int updatedCount = 0;
    int matchedByTime = 0;
    int matchedByText = 0;

    for (final translationLine in translationLines) {
      bool found = false;

      for (final lyricLine in lyricLines) {
        final originalTime = lyricLine.originalStartTime ?? lyricLine.startTime;
        final translationOriginalTime = translationLine.originalStartTime ?? translationLine.startTime;

        if ((translationLine.startTime - originalTime).abs() < 0.1) {
          translationLine.startTime = lyricLine.startTime;
          if (translationLine.originalStartTime == null) {
            translationLine.originalStartTime = translationOriginalTime;
          }
          updatedCount++;
          matchedByTime++;
          found = true;
          break;
        }
      }

      if (!found) {
        for (final lyricLine in lyricLines) {
          if (translationLine.text.trim() == lyricLine.text.trim()) {
            translationLine.startTime = lyricLine.startTime;
            if (translationLine.originalStartTime == null) {
              translationLine.originalStartTime = translationLine.startTime;
            }
            updatedCount++;
            matchedByText++;
            break;
          }
        }
      }
    }

    return {'total': updatedCount, 'time': matchedByTime, 'text': matchedByText};
  }

  void updateLyricsWithTranslations(List<LyricLine> lyricLines) {
    if (_currentTranslation == null) return;
    
    for (final lyricLine in lyricLines) {
      final translatedText = getTranslationForLine(lyricLine.startTime);
      if (translatedText != null) {
        lyricLine.translatedText = translatedText;
      }
    }
  }

  List<String> getAvailableLanguages() {
    return _translations.map((t) => t.languageName).toList();
  }

  List<String> getAvailableLanguageCodes() {
    return _translations.map((t) => t.language).toList();
  }

  void updateLineTimestamps(List<LyricLine> lyricLines) {
    debugPrint('=== updateLineTimestamps called ===');
    debugPrint('Lyric lines count: ${lyricLines.length}');
    debugPrint('Translations count: ${_translations.length}');
    debugPrint('Transcript available: ${_transcriptTranslation != null}');

    int updatedCount = 0;
    int matchedByTime = 0;
    int matchedByText = 0;

    for (final translation in _translations) {
      debugPrint('Updating translation: ${translation.languageName} (${translation.language})');
      final result = _updateSingleTranslationTimestamps(translation.lines, lyricLines);
      updatedCount += result['total'] ?? 0;
      matchedByTime += result['time'] ?? 0;
      matchedByText += result['text'] ?? 0;
    }

    if (_transcriptTranslation != null) {
      debugPrint('Updating transcript translation: ${_transcriptTranslation!.languageName}');
      final result = _updateSingleTranslationTimestamps(_transcriptTranslation!.lines, lyricLines);
      updatedCount += result['total'] ?? 0;
      matchedByTime += result['time'] ?? 0;
      matchedByText += result['text'] ?? 0;
    }

    debugPrint('Total timestamps updated: $updatedCount');
    debugPrint('Matched by time: $matchedByTime, matched by text: $matchedByText');
    notifyListeners();
  }

  Future<void> saveTranslations() async {
    if (_translationsPath == null) {
      debugPrint('ERROR: No translations path set, cannot save');
      return;
    }
    
    try {
      debugPrint('=== DEBUG: Saving translations ===');
      debugPrint('Translations path: $_translationsPath');
      
      final file = File(_translationsPath!);
      final data = {
        'translations': _translations.map((t) => t.toJson()).toList(),
      };
      
      final jsonString = json.encode(data);
      await file.writeAsString(jsonString, encoding: utf8);
      
      debugPrint('Translations saved successfully');
    } catch (e) {
      debugPrint('ERROR: Failed to save translations: $e');
      rethrow;
    }
  }

  Future<void> saveAllTranslations() async {
    try {
      debugPrint('=== Saving all translations to separate files ===');
      debugPrint('Total translations to save: ${_translations.length}');
      if (_transcriptTranslation != null) {
        debugPrint('Transcript to save: ${_transcriptTranslation!.languageName}');
      }

      int savedCount = 0;
      int errorCount = 0;
      int skippedCount = 0;
      final allTranslations = List<Translation>.from(_translations);
      if (_transcriptTranslation != null) {
        allTranslations.add(_transcriptTranslation!);
      }

      for (final translation in allTranslations) {
        try {
          debugPrint('--- Processing translation: ${translation.languageName} (${translation.language}) type: ${translation.type}');
          debugPrint('Lines count: ${translation.lines.length}');
          debugPrint('File path: ${translation.filePath}');

          final filePath = translation.filePath;

          if (filePath == null || filePath.isEmpty) {
            debugPrint('⚠ WARNING: No filePath for translation ${translation.languageName}');
            errorCount++;
            continue;
          }

          final file = File(filePath);
          if (!await file.exists()) {
            debugPrint('⚠ WARNING: File does not exist: $filePath');
            errorCount++;
            continue;
          }

          final content = await file.readAsString();
          final data = json.decode(content) as Map<String, dynamic>;

          final translations = (data['translations'] as List?) ?? [];
          final existingIndex = translations.indexWhere((t) =>
            (t as Map<String, dynamic>)['language'] == translation.language
          );

          if (existingIndex != -1) {
            debugPrint('Updating existing translation at index $existingIndex');
            translations[existingIndex] = translation.toJson();
          } else {
            debugPrint('Adding new translation');
            translations.add(translation.toJson());
          }

          final newData = {
            'title': data['title'],
            'artist': data['artist'],
            'originalLanguage': data['originalLanguage'],
            'translations': translations,
          };

          final jsonString = json.encode(newData);
          await file.writeAsString(jsonString, encoding: utf8);
          savedCount++;

          debugPrint('✓ Saved translation: ${translation.languageName} to $filePath');
          debugPrint('   Lines saved: ${translation.lines.length}');
        } catch (e) {
          debugPrint('✗ Error saving translation ${translation.languageName}: $e');
          debugPrint('   Stack trace: ${StackTrace.current}');
          errorCount++;
        }
      }

      debugPrint('=== Translation save completed ===');
      debugPrint('Saved: $savedCount files');
      debugPrint('Skipped: $skippedCount files');
      debugPrint('Errors: $errorCount files');
    } catch (e) {
      debugPrint('ERROR: Failed to save all translations: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> saveTranslationFile(String filePath, Translation translation) async {
    try {
      debugPrint('=== Saving translation to file: $filePath ===');
      
      final file = File(filePath);
      final existingData = json.decode(await file.readAsString());
      
      final translations = (existingData['translations'] as List?) ?? [];
      final existingIndex = translations.indexWhere((t) => 
        (t as Map<String, dynamic>)['language'] == translation.language
      );
      
      if (existingIndex != -1) {
        debugPrint('Replacing existing translation at index $existingIndex');
        translations[existingIndex] = translation.toJson();
      } else {
        debugPrint('Adding new translation');
        translations.add(translation.toJson());
      }
      
      final newData = {'translations': translations};
      final jsonString = json.encode(newData);
      await file.writeAsString(jsonString, encoding: utf8);
      
      debugPrint('Translation file saved successfully');
    } catch (e) {
      debugPrint('ERROR: Failed to save translation file: $e');
      rethrow;
    }
  }

  void clear() {
    _currentTranslation = null;
    _currentLanguageIndex = 0;
    _translations = [];
    _transcriptTranslation = null;
    _translationsPath = null;
    notifyListeners();
  }

  void updateTranslationText(double startTime, String newText) {
    if (_currentTranslation == null) return;

    for (final line in _currentTranslation!.lines) {
      if ((line.startTime - startTime).abs() < 0.1) {
        line.text = newText;
        break;
      }
    }
    notifyListeners();
  }

  void shiftTranslationsUp() {
    if (_currentTranslation == null || _currentTranslation!.lines.isEmpty) return;

    for (int i = 0; i < _currentTranslation!.lines.length - 1; i++) {
      final temp = _currentTranslation!.lines[i].text;
      _currentTranslation!.lines[i].text = _currentTranslation!.lines[i + 1].text;
      _currentTranslation!.lines[i + 1].text = temp;
    }
    notifyListeners();
  }

  void shiftTranslationsDown() {
    if (_currentTranslation == null || _currentTranslation!.lines.isEmpty) return;

    for (int i = _currentTranslation!.lines.length - 1; i > 0; i--) {
      final temp = _currentTranslation!.lines[i].text;
      _currentTranslation!.lines[i].text = _currentTranslation!.lines[i - 1].text;
      _currentTranslation!.lines[i - 1].text = temp;
    }
    notifyListeners();
  }

  Future<void> saveCurrentTranslation() async {
    if (_currentTranslation == null) return;

    try {
      final filePath = _currentTranslation!.filePath;
      if (filePath == null || filePath.isEmpty) {
        debugPrint('ERROR: No filePath for current translation');
        return;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('ERROR: File does not exist: $filePath');
        return;
      }

      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;

      final translations = (data['translations'] as List?) ?? [];
      final existingIndex = translations.indexWhere((t) =>
        (t as Map<String, dynamic>)['language'] == _currentTranslation!.language
      );

      if (existingIndex != -1) {
        translations[existingIndex] = _currentTranslation!.toJson();
      } else {
        translations.add(_currentTranslation!.toJson());
      }

      final newData = {
        'title': data['title'],
        'artist': data['artist'],
        'originalLanguage': data['originalLanguage'],
        'translations': translations,
      };

      final jsonString = json.encode(newData);
      await file.writeAsString(jsonString, encoding: utf8);

      debugPrint('Current translation saved successfully to: $filePath');
    } catch (e) {
      debugPrint('ERROR: Failed to save current translation: $e');
      rethrow;
    }
  }

  Translation? getTranslationByLanguageCode(String languageCode) {
    for (final translation in _translations) {
      if (translation.language == languageCode) {
        return translation;
      }
    }
    return null;
  }

  void updateTranscriptText(double startTime, String transcript) {
    if (_currentTranslation == null) return;

    for (final line in _currentTranslation!.lines) {
      if ((line.startTime - startTime).abs() < 0.1) {
        line.transcript = transcript;
        break;
      }
    }
    notifyListeners();
  }

  Future<void> updateTranscriptForTranslation(
    String languageCode,
    List<String> transcriptLines,
  ) async {
    final translation = getTranslationByLanguageCode(languageCode);
    if (translation == null) {
      debugPrint('ERROR: Translation not found for language: $languageCode');
      throw Exception('Translation not found for language: $languageCode');
    }

    if (translation.lines.length != transcriptLines.length) {
      debugPrint('ERROR: Lines mismatch. Translation: ${translation.lines.length}, Transcript: ${transcriptLines.length}');
      throw Exception('Lines mismatch');
    }

    for (int i = 0; i < translation.lines.length; i++) {
      translation.lines[i].transcript = transcriptLines[i];
    }

    try {
      final filePath = translation.filePath;
      if (filePath == null || filePath.isEmpty) {
        debugPrint('ERROR: No filePath for translation');
        return;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('ERROR: File does not exist: $filePath');
        return;
      }

      final content = await file.readAsString();
      final data = json.decode(content) as Map<String, dynamic>;

      final translations = (data['translations'] as List?) ?? [];
      final existingIndex = translations.indexWhere((t) =>
        (t as Map<String, dynamic>)['language'] == translation.language
      );

      if (existingIndex != -1) {
        translations[existingIndex] = translation.toJson();
      } else {
        translations.add(translation.toJson());
      }

      final newData = {
        'title': data['title'],
        'artist': data['artist'],
        'originalLanguage': data['originalLanguage'],
        'translations': translations,
      };

      final jsonString = json.encode(newData);
      await file.writeAsString(jsonString, encoding: utf8);

      debugPrint('Transcript updated successfully for translation: ${translation.languageName}');

      await loadTranslations(filePath);
    } catch (e) {
      debugPrint('ERROR: Failed to update transcript: $e');
      rethrow;
    }
  }
}
