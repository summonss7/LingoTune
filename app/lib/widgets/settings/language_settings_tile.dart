import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';
import '../../services/settings_helper.dart';
import '../../l10n/app_localizations.dart';
import '../../constants/generation_constants.dart';

class AppLanguageTile extends StatelessWidget {
  const AppLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.appLanguage),
      subtitle: Text(SettingsHelper.getLanguageName(context, settingsProvider.appLanguage)),
      trailing: DropdownButton<String>(
        value: settingsProvider.appLanguage,
        items: [
          DropdownMenuItem(
              value: 'en', child: Text(l10n.englishLang)),
          DropdownMenuItem(
              value: 'ru', child: Text(l10n.russianLang)),
          DropdownMenuItem(
              value: 'ro', child: Text(l10n.romanianLang)),
          DropdownMenuItem(value: 'fr', child: Text(l10n.frenchLang)),
          DropdownMenuItem(value: 'de', child: Text(l10n.germanLang)),
          DropdownMenuItem(
              value: 'es', child: Text(l10n.spanishLang)),
          DropdownMenuItem(
              value: 'it', child: Text(l10n.italianLang)),
          DropdownMenuItem(
              value: 'pt', child: Text(l10n.portugueseLang)),
          DropdownMenuItem(
              value: 'uk', child: Text(l10n.ukrainianLang)),
          DropdownMenuItem(
              value: 'zh', child: Text(l10n.chineseLang)),
          DropdownMenuItem(value: 'ar', child: Text(l10n.arabicLang)),
        ],
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setAppLanguage(value);
          }
        },
      ),
    );
  }
}

class TranslationLanguageTile extends StatelessWidget {
  const TranslationLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.defaultTranslationLanguage),
      subtitle: Text(SettingsHelper.getTranslationLanguageName(
          context, settingsProvider.defaultTranslationLanguage)),
      trailing: DropdownButton<String>(
        value: settingsProvider.defaultTranslationLanguage,
        items: [
          DropdownMenuItem(value: 'ru', child: Text(l10n.russian)),
          DropdownMenuItem(value: 'en', child: Text(l10n.english)),
          DropdownMenuItem(value: 'ro', child: Text(l10n.romanian)),
          DropdownMenuItem(value: 'fr', child: Text(l10n.french)),
          DropdownMenuItem(value: 'de', child: Text(l10n.german)),
          DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
          DropdownMenuItem(value: 'it', child: Text(l10n.italian)),
          DropdownMenuItem(value: 'pt', child: Text(l10n.portuguese)),
          DropdownMenuItem(
              value: 'uk', child: Text(l10n.ukrainianLang)),
          DropdownMenuItem(value: 'zh', child: Text(l10n.chinese)),
          DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),
        ],
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setDefaultTranslationLanguage(value);
          }
        },
      ),
    );
  }
}

class SourceLanguageTile extends StatelessWidget {
  const SourceLanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return ListTile(
      leading: const Icon(Icons.source),
      title: Text(l10n.defaultOriginalLanguage),
      subtitle: Text(GenerationConstants.sourceLanguageNames[settingsProvider.defaultSourceLanguage] ?? settingsProvider.defaultSourceLanguage),
      trailing: DropdownButton<String>(
        value: settingsProvider.defaultSourceLanguage,
        items: GenerationConstants.sourceLanguages.map((lang) {
          return DropdownMenuItem(
            value: lang,
            child: Text(GenerationConstants.sourceLanguageNames[lang] ?? lang),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setDefaultSourceLanguage(value);
          }
        },
      ),
    );
  }
}
