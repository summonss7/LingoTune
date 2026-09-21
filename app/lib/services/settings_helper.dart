import 'package:flutter/material.dart';
import 'package:lingotune/l10n/app_localizations.dart';

class SettingsHelper {
  static String getLanguageName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'en':
        return l10n.englishLang;
      case 'ru':
        return l10n.russianLang;
      case 'ro':
        return l10n.romanianLang;
      case 'fr':
        return l10n.frenchLang;
      case 'de':
        return l10n.germanLang;
      case 'es':
        return l10n.spanishLang;
      case 'it':
        return l10n.italianLang;
      case 'pt':
        return l10n.portugueseLang;
      case 'uk':
        return l10n.ukrainianLang;
      case 'zh':
        return l10n.chineseLang;
      case 'ar':
        return l10n.arabicLang;
      default:
        return 'Unknown';
    }
  }

  static String getTranslationLanguageName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'uk':
        return l10n.ukrainianLang;
      case 'ru':
        return l10n.russian;
      case 'en':
        return l10n.english;
      case 'ro':
        return l10n.romanian;
      case 'fr':
        return l10n.french;
      case 'de':
        return l10n.german;
      case 'es':
        return l10n.spanish;
      case 'it':
        return l10n.italian;
      case 'pt':
        return l10n.portuguese;
      case 'zh':
        return l10n.chinese;
      case 'ar':
        return l10n.arabic;
      default:
        return 'Unknown';
    }
  }

  static String getThemeColorName(BuildContext context, String colorCode) {
    final l10n = AppLocalizations.of(context)!;
    switch (colorCode) {
      case 'amethyst':
        return l10n.themeNameAmethyst;
      case 'default':
        return 'Default';
      case 'purple':
        return l10n.themeColorPurple;
      case 'blue':
        return l10n.themeColorBlue;
      case 'green':
        return l10n.themeColorGreen;
      case 'orange':
        return l10n.themeColorOrange;
      case 'red':
        return l10n.themeColorRed;
      case 'pink':
        return l10n.themeColorPink;
      case 'deepOrange':
        return l10n.themeColorDeepOrange;
      case 'darkRed':
        return l10n.themeColorDarkRed;
      case 'teal':
        return l10n.themeColorTeal;
      case 'cyan':
        return l10n.themeColorCyan;
      case 'amber':
        return l10n.themeColorAmber;
      case 'lime':
        return l10n.themeColorLime;
      default:
        return 'Default';
    }
  }
}
