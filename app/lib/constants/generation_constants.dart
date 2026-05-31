class GenerationConstants {
  static const String deepseekBaseUrl = 'https://api.deepseek.com/v1';
  static const String deepseekModel = 'deepseek-chat';

  static const int maxConcurrentRequests = 5;
  static const int timeoutSeconds = 30;
  static const int maxRetries = 3;
  static const int requestDelayMs = 100;

  static const double defaultStartTime = 1800.0;
  static const double timingStep = 5.0;

  static const Map<String, String> supportedLanguages = {
    'ro': 'Română',
    'ru': 'Русский',
    'ru_literal': 'Русский дословный',
    'en': 'English',
    'de': 'German',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
    'zh': '中文',
    'ar': 'العربية',
    'uk': 'Українська',
    'trans': 'Транскрипция',
  };

  static const List<String> defaultLanguages = ['trans', 'ru', 'ru_literal', 'en', 'de'];

  static const Map<String, String> languageNames = {
    'ro': 'Romanian',
    'ru': 'Russian',
    'ru_literal': 'Russian (Literal)',
    'en': 'English',
    'de': 'German',
    'es': 'Spanish',
    'fr': 'French',
    'it': 'Italian',
    'pt': 'Portuguese',
    'zh': 'Chinese',
    'ar': 'Arabic',
    'uk': 'Ukrainian',
    'trans': 'Transcription',
  };

  static const Map<String, String> translationTypes = {
    'literal': 'Дословный',
    'transcript': 'Транскрипция',
  };

  static String getPromptForTranslation(String sourceLang, String targetLang, {String? type}) {
    if (type == 'transcript') {
      return '''You are a professional phonetic transcription expert. Your task is to create a phonetic transcription of Romanian text using Russian letters (transliteration).

Rules:
1. Use Russian Cyrillic letters to represent Romanian sounds
2. Keep the pronunciation natural and accurate
3. Use standard Russian phonetic conventions
4. Preserve word boundaries with spaces
5. Do not add any explanations, just return the transcription

Source text (Romanian):
{text}

Return ONLY the phonetic transcription using Russian letters, nothing else.''';
    }

    if (type == 'literal') {
      return '''You are a professional translator specializing in literal (word-for-word) translation. Your task is to translate the following Romanian text to Russian as literally as possible.

Rules:
1. Translate word-for-word where possible
2. Maintain the exact word order of the original
3. Preserve grammatical structure
4. Use literal meaning even if it sounds awkward
5. Do not localize or adapt idioms
6. Return ONLY the translation, nothing else

Source text (Romanian):
{text}

Return ONLY the literal Russian translation, nothing else.''';
    }

    return '''You are a professional translator specializing in songs and poetry. Your task is to translate the following Romanian text to {$targetLang} while preserving the poetic style and emotional tone.

Rules:
1. Maintain the poetic flow and rhythm
2. Preserve the emotional meaning and intent
3. Use natural, expressive language
4. Adapt idioms appropriately
5. Keep the translation concise and powerful
6. Return ONLY the translation, nothing else

Source text (Romanian):
{text}

Return ONLY the {$targetLang} translation, nothing else.''';
  }

  static String? getTargetLanguageName(String code) {
    return supportedLanguages[code];
  }

  static const List<String> sourceLanguages = ['ro', 'en', 'ru', 'de', 'es', 'fr', 'it', 'pt', 'zh', 'ar', 'uk', 'sk'];

  static const Map<String, String> sourceLanguageNames = {
    'ro': 'Română',
    'en': 'English',
    'ru': 'Русский',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
    'zh': '中文',
    'ar': 'العربية',
    'uk': 'Українська',
    'sk': 'Slovenčina',
  };
}
