class LanguageHelper {
  static String getLanguageName(String code) {
    final names = {
      'ru': 'русский',
      'en': 'английский',
      'de': 'немецкий',
      'fr': 'французский',
      'es': 'испанский',
      'it': 'итальянский',
      'pt': 'португальский',
      'ro': 'румынский',
      'zh': 'китайский',
      'ar': 'арабский',
      'uk': 'українська',
      'sk': 'словацкий',
    };
    return names[code] ?? code;
  }

  static String getShortLanguageName(String languageName, String languageCode) {
    if (languageName.toLowerCase() == 'transcript' || 
        languageName.toLowerCase() == 'транскрипция') {
      return 'TR';
    }
    
    switch (languageCode.toLowerCase()) {
      case 'ru':
        return 'RU';
      case 'en':
        return 'EN';
      case 'de':
        return 'DE';
      case 'fr':
        return 'FR';
      case 'es':
        return 'ES';
      case 'it':
        return 'IT';
      case 'pt':
        return 'PT';
      case 'ro':
        return 'RO';
      case 'zh':
        return 'ZH';
      case 'ar':
        return 'AR';
      case 'uk':
        return 'UK';
      case 'sk':
        return 'SK';
      default:
        if (languageName.length <= 3) {
          return languageName.toUpperCase();
        }
        return languageName.substring(0, 3).toUpperCase();
    }
  }

  static String getLanguageEmoji(String language, String? type) {
    final lowerLang = language.toLowerCase();

    if (type == 'transcript') {
      return '🎤';
    }

    if (lowerLang.contains('рус') || lowerLang == 'ru') return '🇷🇺';
    if (lowerLang.contains('english') || lowerLang == 'en') return '🇬🇧';
    if (lowerLang.contains('german') || lowerLang == 'de') return '🇩🇪';
    if (lowerLang.contains('french') || lowerLang == 'fr') return '🇫🇷';
    if (lowerLang.contains('spanish') || lowerLang == 'es') return '🇪🇸';
    if (lowerLang.contains('italian') || lowerLang == 'it') return '🇮🇹';
    if (lowerLang.contains('portuguese') || lowerLang == 'pt') return '🇵🇹';
    if (lowerLang.contains('romanian') || lowerLang == 'ro') return '🇷🇴';
    if (lowerLang.contains('chinese') || lowerLang == 'zh') return '🇨🇳';
    if (lowerLang.contains('arabic') || lowerLang == 'ar') return '🇸🇦';
    if (lowerLang.contains('ukrainian') || lowerLang == 'uk') return '🇺🇦';
    if (lowerLang.contains('slovak') || lowerLang == 'sk') return '🇸🇰';

    return '🌐';
  }

  static String getTypeLabel(String type) {
    switch (type) {
      case 'author':
        return '(авт.)';
      case 'poetic':
        return '(поэт.)';
      case 'literal':
        return '(досл.)';
      case 'transcript':
        return '';
      default:
        return '';
    }
  }
}
