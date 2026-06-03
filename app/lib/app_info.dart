/// Информация о приложении LingoTune
/// Централизованный класс для управления данными о приложении

class AppInfo {
  static const String appName = 'LingoTune';
  static const String packageName = 'com.lingotune.app';
  static const String version = '4.6.16';
  static const String versionCode = '184';

  static const String developerName = 'Z.AI GLM & Цимбалов Артем';
  static const String developerEmail = 'support@lingotune.com';
  static const String website = 'https://lingotune.app';
  static const String privacyPolicyUrl = 'https://lingotune.app/privacy';

  static const String appDescription = 'Learn languages through music with synchronized lyrics. '
      'Study your favorite songs while seeing the original lyrics and translations in real-time. '
      'Perfect for language learners and music lovers!';

  static const String longDescription = 'LingoTune is an innovative language learning application that helps you master new languages through music. '
      'With synchronized song lyrics displaying original text alongside translations, you can understand the meaning behind the words while enjoying your favorite tracks. '
      'Features include audio playback, automatic line highlighting, translation support, and more. '
      'Start learning languages the fun way today!';

  static const List<String> features = [
    '🎵 Play your favorite songs',
    '📝 View synchronized lyrics in real-time',
    '🌍 Multiple translation languages support',
    '📊 Line-by-line text and translations',
    '⏱️ Accurate timing with LRC files',
    '🎯 Highlight current and next lines',
    '✏️ Edit translations in app',
    '📝 Edit timestamps manually',
    '🌐 Multi-language app interface',
    '🎤 Transcription support',
    '⚡ Batch lyrics generator',
    '🔍 Search lyrics from online databases',
    '🤖 AI-powered translation (DeepSeek)',
    '🎯 Batch lyrics generator',
    '💾 Export and import settings',
    '📦 Backup your song library',
  ];

  static const List<String> supportedLanguages = [
    'English',
    'Russian',
    'Romanian',
    'French',
    'German',
    'Spanish',
    'Italian',
    'Portuguese',
    'Chinese',
    'Arabic',
    'Ukrainian',
    'Japanese',
    'Korean',
  ];

  static const List<String> audioFormats = [
    'MP3',
    'WAV',
    'M4A',
    'OGG',
  ];

  static const List<String> fileFormats = [
    'LRC (Lyrics)',
    'JSON (Translations)',
  ];

  static String getFullName() {
    return '$appName v$version';
  }

  static Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'versionCode': versionCode,
      'developerName': developerName,
      'developerEmail': developerEmail,
      'website': website,
      'privacyPolicyUrl': privacyPolicyUrl,
      'appDescription': appDescription,
      'longDescription': longDescription,
      'features': features,
      'supportedLanguages': supportedLanguages,
      'audioFormats': audioFormats,
      'fileFormats': fileFormats,
    };
  }
}
