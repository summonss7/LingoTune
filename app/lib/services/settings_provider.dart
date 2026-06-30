import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _fontSize = 16.0;
  String _defaultTranslationLanguage = 'ru';
  String _defaultSourceLanguage = 'en';
  bool _autoScroll = true;
  bool _highlightNextLine = true;
  String _appLanguage = 'en';
  bool _showTranscript = true;
  bool _showTranslationFirst = false;
  bool _showTranslationMessages = false;
  String _themeColor = 'default';
  String _defaultStartScreen = 'playlists';

  double _lyricsFontSize = 19.0;
  double _translationFontSize = 18.0;
  double _transcriptFontSize = 16.0;
  bool _lyricsBold = true;
  bool _translationBold = false;
  bool _transcriptBold = false;
  String _fontFamily = '';
  String _deepseekApiKey = '';
  String _deepseekPrompt = '';
  int _deepseekTimeout = 180;
  String _deepseekModel = 'deepseek-chat';
  int _deepseekMaxTokensRegular = 500;
  int _deepseekMaxTokensJson = 8000;
  String _selectedPromptPreset = 'balanced';
  bool _addToLibraryWhenAddingToPlaylist = false;
  bool _showVerticalSlider = false;
  double _defaultTimestampOffset = 1800.0;
  double _lyricsPositionOffset = 0.15;

  double get fontSize => _fontSize;
  String get defaultTranslationLanguage => _defaultTranslationLanguage;
  String get defaultSourceLanguage => _defaultSourceLanguage;
  bool get autoScroll => _autoScroll;
  bool get highlightNextLine => _highlightNextLine;
  String get appLanguage => _appLanguage;
  bool get showTranscript => _showTranscript;
  bool get showTranslationFirst => _showTranslationFirst;
  bool get showTranslationMessages => _showTranslationMessages;
  String get themeColor => _themeColor;
  String get defaultStartScreen => _defaultStartScreen;
  double get lyricsFontSize => _lyricsFontSize;
  double get translationFontSize => _translationFontSize;
  double get transcriptFontSize => _transcriptFontSize;
  bool get lyricsBold => _lyricsBold;
  bool get translationBold => _translationBold;
  bool get transcriptBold => _transcriptBold;
  String get fontFamily => _fontFamily;
  String get deepseekApiKey => _deepseekApiKey;
  String get deepseekPrompt => _deepseekPrompt;
  int get deepseekTimeout => _deepseekTimeout;
  String get deepseekModel => _deepseekModel;
  int get deepseekMaxTokensRegular => _deepseekMaxTokensRegular;
  int get deepseekMaxTokensJson => _deepseekMaxTokensJson;
  String get selectedPromptPreset => _selectedPromptPreset;
  bool get addToLibraryWhenAddingToPlaylist => _addToLibraryWhenAddingToPlaylist;
  bool get showVerticalSlider => _showVerticalSlider;
  double get defaultTimestampOffset => _defaultTimestampOffset;
  double get lyricsPositionOffset => _lyricsPositionOffset;

  Future<void> loadSettings() async {
    debugPrint('=== SettingsProvider: Loading settings ===');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _defaultTranslationLanguage = prefs.getString('defaultTranslationLanguage') ?? 'ru';
      _defaultSourceLanguage = prefs.getString('defaultSourceLanguage') ?? 'en';
      _autoScroll = prefs.getBool('autoScroll') ?? true;
      _highlightNextLine = prefs.getBool('highlightNextLine') ?? true;
      _appLanguage = prefs.getString('appLanguage') ?? 'en';
      _showTranscript = prefs.getBool('showTranscript') ?? true;
      _showTranslationFirst = prefs.getBool('showTranslationFirst') ?? false;
      _showTranslationMessages = prefs.getBool('showTranslationMessages') ?? false;
      _defaultStartScreen = prefs.getString('defaultStartScreen') ?? 'playlists';

      final String? savedSettingsVersion = prefs.getString('settingsVersion');
      const String currentSettingsVersion = '4.2.1';

      if (savedSettingsVersion == null || savedSettingsVersion != currentSettingsVersion) {
        debugPrint('=== Settings migration needed: $savedSettingsVersion -> $currentSettingsVersion ===');

        if (savedSettingsVersion == null || _versionLessThan(savedSettingsVersion, '4.2.1')) {
          final double currentLyricsFontSize = prefs.getDouble('lyricsFontSize') ?? 19.0;
          final double currentTranslationFontSize = prefs.getDouble('translationFontSize') ?? 18.0;
          final double currentTranscriptFontSize = prefs.getDouble('transcriptFontSize') ?? 16.0;

          if (currentLyricsFontSize <= 17.0) {
            await prefs.setDouble('lyricsFontSize', 19.0);
            debugPrint('Migrated lyricsFontSize: $currentLyricsFontSize -> 19.0');
          }
          if (currentTranslationFontSize <= 16.0) {
            await prefs.setDouble('translationFontSize', 18.0);
            debugPrint('Migrated translationFontSize: $currentTranslationFontSize -> 18.0');
          }
          if (currentTranscriptFontSize <= 14.0) {
            await prefs.setDouble('transcriptFontSize', 16.0);
            debugPrint('Migrated transcriptFontSize: $currentTranscriptFontSize -> 16.0');
          }
        }

        await prefs.setString('settingsVersion', currentSettingsVersion);
        debugPrint('=== Settings migration complete ===');
      }

      _lyricsFontSize = prefs.getDouble('lyricsFontSize') ?? 19.0;
      _translationFontSize = prefs.getDouble('translationFontSize') ?? 18.0;
      _transcriptFontSize = prefs.getDouble('transcriptFontSize') ?? 16.0;

      if (savedSettingsVersion != currentSettingsVersion) {
        debugPrint('✓ Settings migrated from $savedSettingsVersion to $currentSettingsVersion');
      }

      _lyricsBold = prefs.getBool('lyricsBold') ?? true;
      _translationBold = prefs.getBool('translationBold') ?? false;
      _transcriptBold = prefs.getBool('transcriptBold') ?? false;
      _fontFamily = prefs.getString('fontFamily') ?? '';
      _themeColor = prefs.getString('themeColor') ?? 'default';
      _deepseekApiKey = prefs.getString('deepseekApiKey') ?? '';
      _deepseekPrompt = prefs.getString('deepseekPrompt') ?? '';
      _deepseekTimeout = prefs.getInt('deepseekTimeout') ?? 180;
      _deepseekModel = prefs.getString('deepseekModel') ?? 'deepseek-chat';
      _deepseekMaxTokensRegular = prefs.getInt('deepseekMaxTokensRegular') ?? 500;
      _deepseekMaxTokensJson = prefs.getInt('deepseekMaxTokensJson') ?? 8000;
      _selectedPromptPreset = prefs.getString('selectedPromptPreset') ?? 'balanced';
      _addToLibraryWhenAddingToPlaylist = prefs.getBool('addToLibraryWhenAddingToPlaylist') ?? false;
      _showVerticalSlider = prefs.getBool('showVerticalSlider') ?? false;
      _defaultTimestampOffset = prefs.getDouble('defaultTimestampOffset') ?? 1800.0;
      _lyricsPositionOffset = prefs.getDouble('lyricsPositionOffset') ?? 0.15;

      debugPrint('Font size: $_fontSize');
      debugPrint('Translation language: $_defaultTranslationLanguage');
      debugPrint('Source language: $_defaultSourceLanguage');
      debugPrint('App language: $_appLanguage');
      debugPrint('Auto scroll: $_autoScroll');
      debugPrint('Highlight next line: $_highlightNextLine');
      debugPrint('Show transcript: $_showTranscript');
      debugPrint('Show translation first: $_showTranslationFirst');
      debugPrint('Show translation messages: $_showTranslationMessages');
      debugPrint('Default start screen: $_defaultStartScreen');
      debugPrint('Lyrics font size: $_lyricsFontSize, bold: $_lyricsBold');
      debugPrint('Translation font size: $_translationFontSize, bold: $_translationBold');
      debugPrint('Transcript font size: $_transcriptFontSize, bold: $_transcriptBold');
      debugPrint('Font family: ${_fontFamily.isEmpty ? "system" : _fontFamily}');
      debugPrint('Theme color: $_themeColor');
      debugPrint('DeepSeek API key: ${_deepseekApiKey.isNotEmpty ? "configured" : "not configured"}');
      debugPrint('DeepSeek prompt: ${_deepseekPrompt.isNotEmpty ? "custom" : "default"}');
      debugPrint('DeepSeek timeout: $_deepseekTimeout sec');
      debugPrint('DeepSeek model: $_deepseekModel');
      debugPrint('DeepSeek max tokens (regular): $_deepseekMaxTokensRegular');
      debugPrint('DeepSeek max tokens (JSON): $_deepseekMaxTokensJson');
      debugPrint('DeepSeek prompt preset: $_selectedPromptPreset');
      debugPrint('Add to library when adding to playlist: $_addToLibraryWhenAddingToPlaylist');
      debugPrint('Show vertical slider: $_showVerticalSlider');
      debugPrint('Default timestamp offset: $_defaultTimestampOffset (${(_defaultTimestampOffset / 60).toInt()} min)');
      debugPrint('Lyrics position offset: $_lyricsPositionOffset s');

      notifyListeners();
      debugPrint('Settings loaded and notified listeners');
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setFontSize(double value) async {
    debugPrint('=== SettingsProvider: Setting font size ===');
    debugPrint('Old: $_fontSize, New: $value');
    
    _fontSize = value;
    await _save();
    notifyListeners();
    
    debugPrint('Font size updated and notified listeners');
  }

  Future<void> setDefaultTranslationLanguage(String value) async {
    debugPrint('=== SettingsProvider: Setting language ===');
    debugPrint('Old: $_defaultTranslationLanguage, New: $value');
    
    _defaultTranslationLanguage = value;
    await _save();
    notifyListeners();
    
    debugPrint('Language updated and notified listeners');
  }

  Future<void> setDefaultSourceLanguage(String value) async {
    debugPrint('=== SettingsProvider: Setting default source language ===');
    debugPrint('Old: $_defaultSourceLanguage, New: $value');
    
    _defaultSourceLanguage = value;
    await _save();
    notifyListeners();
    
    debugPrint('Default source language updated and notified listeners');
  }

  Future<void> setAutoScroll(bool value) async {
    debugPrint('=== SettingsProvider: Setting auto scroll ===');
    debugPrint('Old: $_autoScroll, New: $value');
    
    _autoScroll = value;
    await _save();
    notifyListeners();
    
    debugPrint('Auto scroll updated and notified listeners');
  }

  Future<void> setHighlightNextLine(bool value) async {
    debugPrint('=== SettingsProvider: Setting highlight next line ===');
    debugPrint('Old: $_highlightNextLine, New: $value');
    
    _highlightNextLine = value;
    await _save();
    notifyListeners();
    
    debugPrint('Highlight next line updated and notified listeners');
  }

  Future<void> setAppLanguage(String value) async {
    debugPrint('=== SettingsProvider: Setting app language ===');
    debugPrint('Old: $_appLanguage, New: $value');
    
    _appLanguage = value;
    await _save();
    notifyListeners();
    
    debugPrint('App language updated and notified listeners');
  }

  Future<void> setShowTranscript(bool value) async {
    debugPrint('=== SettingsProvider: Setting show transcript ===');
    debugPrint('Old: $_showTranscript, New: $value');
    
    _showTranscript = value;
    await _save();
    notifyListeners();
    
    debugPrint('Show transcript updated and notified listeners');
  }

  Future<void> setShowTranslationFirst(bool value) async {
    debugPrint('=== SettingsProvider: Setting show translation first ===');
    debugPrint('Old: $_showTranslationFirst, New: $value');

    _showTranslationFirst = value;
    await _save();
    notifyListeners();

    debugPrint('Show translation first updated and notified listeners');
  }

  Future<void> setShowTranslationMessages(bool value) async {
    debugPrint('=== SettingsProvider: Setting show translation messages ===');
    debugPrint('Old: $_showTranslationMessages, New: $value');

    _showTranslationMessages = value;
    await _save();
    notifyListeners();

    debugPrint('Show translation messages updated and notified listeners');
  }

  Future<void> setLyricsFontSize(double value) async {
    debugPrint('=== SettingsProvider: Setting lyrics font size ===');
    debugPrint('Old: $_lyricsFontSize, New: $value');

    _lyricsFontSize = value;
    await _save();
    notifyListeners();

    debugPrint('Lyrics font size updated and notified listeners');
  }

  Future<void> setTranslationFontSize(double value) async {
    debugPrint('=== SettingsProvider: Setting translation font size ===');
    debugPrint('Old: $_translationFontSize, New: $value');

    _translationFontSize = value;
    await _save();
    notifyListeners();

    debugPrint('Translation font size updated and notified listeners');
  }

  Future<void> setTranscriptFontSize(double value) async {
    debugPrint('=== SettingsProvider: Setting transcript font size ===');
    debugPrint('Old: $_transcriptFontSize, New: $value');

    _transcriptFontSize = value;
    await _save();
    notifyListeners();

    debugPrint('Transcript font size updated and notified listeners');
  }

  Future<void> setLyricsBold(bool value) async {
    debugPrint('=== SettingsProvider: Setting lyrics bold ===');
    debugPrint('Old: $_lyricsBold, New: $value');

    _lyricsBold = value;
    await _save();
    notifyListeners();

    debugPrint('Lyrics bold updated and notified listeners');
  }

  Future<void> setTranslationBold(bool value) async {
    debugPrint('=== SettingsProvider: Setting translation bold ===');
    debugPrint('Old: $_translationBold, New: $value');

    _translationBold = value;
    await _save();
    notifyListeners();

    debugPrint('Translation bold updated and notified listeners');
  }

  Future<void> setTranscriptBold(bool value) async {
    debugPrint('=== SettingsProvider: Setting transcript bold ===');
    debugPrint('Old: $_transcriptBold, New: $value');

    _transcriptBold = value;
    await _save();
    notifyListeners();

    debugPrint('Transcript bold updated and notified listeners');
  }

  Future<void> setFontFamily(String value) async {
    debugPrint('=== SettingsProvider: Setting font family ===');
    debugPrint('Old: $_fontFamily, New: $value');

    _fontFamily = value;
    await _save();
    notifyListeners();

    debugPrint('Font family updated and notified listeners');
  }

  Future<void> setThemeColor(String value) async {
    debugPrint('=== SettingsProvider: Setting theme color ===');
    debugPrint('Old: $_themeColor, New: $value');

    _themeColor = value;
    await _save();
    notifyListeners();

    debugPrint('Theme color updated and notified listeners');
  }

  Future<void> setDefaultStartScreen(String value) async {
    debugPrint('=== SettingsProvider: Setting default start screen ===');
    debugPrint('Old: $_defaultStartScreen, New: $value');

    _defaultStartScreen = value;
    await _save();
    notifyListeners();

    debugPrint('Default start screen updated and notified listeners');
  }

  Future<void> setDeepseekApiKey(String value) async {
    debugPrint('=== SettingsProvider: Setting DeepSeek API key ===');
    debugPrint('New key: ${value.isNotEmpty ? "configured" : "empty"}');

    _deepseekApiKey = value;
    await _save();
    notifyListeners();

    debugPrint('DeepSeek API key updated and notified listeners');
  }

  Future<void> setDeepseekPrompt(String value) async {
    debugPrint('=== SettingsProvider: Setting DeepSeek prompt ===');

    _deepseekPrompt = value;
    await _save();
    notifyListeners();

    debugPrint('DeepSeek prompt updated and notified listeners');
  }

  Future<void> setDeepseekTimeout(int value) async {
    debugPrint('=== SettingsProvider: Setting DeepSeek timeout ===');
    debugPrint('New timeout: $value seconds');

    _deepseekTimeout = value;
    await _save();
    notifyListeners();

    debugPrint('DeepSeek timeout updated and notified listeners');
  }

  Future<void> setDeepseekModel(String value) async {
    debugPrint('=== SettingsProvider: Setting DeepSeek model ===');
    debugPrint('New model: $value');

    _deepseekModel = value;
    await _save();
    notifyListeners();

    debugPrint('DeepSeek model updated and notified listeners');
  }

  Future<void> setDeepseekMaxTokensRegular(int value) async {
    debugPrint('=== SettingsProvider: Setting DeepSeek max tokens (regular) ===');
    debugPrint('New max tokens (regular): $value');

    _deepseekMaxTokensRegular = value;
    await _save();
    notifyListeners();

    debugPrint('DeepSeek max tokens (regular) updated and notified listeners');
  }

  Future<void> setDeepseekMaxTokensJson(int value) async {
    debugPrint('=== SettingsProvider: Setting DeepSeek max tokens (JSON) ===');
    debugPrint('New max tokens (JSON): $value');

    _deepseekMaxTokensJson = value;
    await _save();
    notifyListeners();

    debugPrint('DeepSeek max tokens (JSON) updated and notified listeners');
  }

  Future<void> setSelectedPromptPreset(String value) async {
    debugPrint('=== SettingsProvider: Setting prompt preset ===');
    debugPrint('New preset: $value');

    _selectedPromptPreset = value;
    await _save();
    notifyListeners();

    debugPrint('Prompt preset updated and notified listeners');
  }

  Future<void> setAddToLibraryWhenAddingToPlaylist(bool value) async {
    debugPrint('=== SettingsProvider: Setting add to library when adding to playlist ===');
    debugPrint('Old: $_addToLibraryWhenAddingToPlaylist, New: $value');

    _addToLibraryWhenAddingToPlaylist = value;
    await _save();
    notifyListeners();

    debugPrint('Add to library when adding to playlist updated and notified listeners');
  }

  Future<void> setShowVerticalSlider(bool value) async {
    _showVerticalSlider = value;
    await _save();
    notifyListeners();
  }

  Future<void> setDefaultTimestampOffset(double value) async {
    debugPrint('=== SettingsProvider: Setting default timestamp offset ===');
    debugPrint('Old: $_defaultTimestampOffset (${(_defaultTimestampOffset / 60).toInt()} min), New: $value (${(value / 60).toInt()} min)');

    _defaultTimestampOffset = value;
    await _save();
    notifyListeners();

    debugPrint('Default timestamp offset updated and notified listeners');
  }

  Future<void> setLyricsPositionOffset(double value) async {
    debugPrint('=== SettingsProvider: Setting lyrics position offset ===');
    debugPrint('Old: $_lyricsPositionOffset s, New: $value s');

    _lyricsPositionOffset = value;
    await _save();
    notifyListeners();

    debugPrint('Lyrics position offset updated and notified listeners');
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('fontSize', _fontSize);
      await prefs.setString('defaultTranslationLanguage', _defaultTranslationLanguage);
      await prefs.setString('defaultSourceLanguage', _defaultSourceLanguage);
      await prefs.setBool('autoScroll', _autoScroll);
      await prefs.setBool('highlightNextLine', _highlightNextLine);
      await prefs.setString('appLanguage', _appLanguage);
      await prefs.setBool('showTranscript', _showTranscript);
      await prefs.setBool('showTranslationFirst', _showTranslationFirst);
      await prefs.setBool('showTranslationMessages', _showTranslationMessages);
      await prefs.setString('defaultStartScreen', _defaultStartScreen);
      await prefs.setDouble('lyricsFontSize', _lyricsFontSize);
      await prefs.setDouble('translationFontSize', _translationFontSize);
      await prefs.setDouble('transcriptFontSize', _transcriptFontSize);
      await prefs.setBool('lyricsBold', _lyricsBold);
      await prefs.setBool('translationBold', _translationBold);
      await prefs.setBool('transcriptBold', _transcriptBold);
      await prefs.setString('fontFamily', _fontFamily);
      await prefs.setString('themeColor', _themeColor);
      await prefs.setString('deepseekApiKey', _deepseekApiKey);
      await prefs.setString('deepseekPrompt', _deepseekPrompt);
      await prefs.setInt('deepseekTimeout', _deepseekTimeout);
      await prefs.setString('deepseekModel', _deepseekModel);
      await prefs.setInt('deepseekMaxTokensRegular', _deepseekMaxTokensRegular);
      await prefs.setInt('deepseekMaxTokensJson', _deepseekMaxTokensJson);
      await prefs.setString('selectedPromptPreset', _selectedPromptPreset);
      await prefs.setBool('addToLibraryWhenAddingToPlaylist', _addToLibraryWhenAddingToPlaylist);
      await prefs.setBool('showVerticalSlider', _showVerticalSlider);
      await prefs.setDouble('defaultTimestampOffset', _defaultTimestampOffset);
      await prefs.setDouble('lyricsPositionOffset', _lyricsPositionOffset);
      await prefs.setString('settingsVersion', '4.2.1');
      debugPrint('Settings saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  bool _versionLessThan(String version1, String version2) {
    final v1 = version1.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final v2 = version2.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (int i = 0; i < v1.length && i < v2.length; i++) {
      if (v1[i] < v2[i]) return true;
      if (v1[i] > v2[i]) return false;
    }
    return v1.length < v2.length;
  }
}
