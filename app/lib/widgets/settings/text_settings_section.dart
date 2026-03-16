import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import 'font_size_control.dart';
import 'settings_section.dart';

class TextSettingsSection extends StatelessWidget {
  const TextSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return Column(
      children: [
        SettingsSection(title: l10n.fontSettings),
        _LyricsFontSizeTile(settingsProvider: settingsProvider),
        _LyricsBoldTile(settingsProvider: settingsProvider),
        _TranslationFontSizeTile(settingsProvider: settingsProvider),
        _TranslationBoldTile(settingsProvider: settingsProvider),
        _TranscriptFontSizeTile(settingsProvider: settingsProvider),
        _TranscriptBoldTile(settingsProvider: settingsProvider),
        _FontFamilyTile(settingsProvider: settingsProvider),
      ],
    );
  }
}

class _LyricsFontSizeTile extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const _LyricsFontSizeTile({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: Text(l10n.mainTextSize),
      subtitle: Text('${settingsProvider.lyricsFontSize.toInt()} px'),
      trailing: FontSizeControl(
        fontSize: settingsProvider.lyricsFontSize,
        minSize: 10,
        maxSize: 32,
        onChanged: (value) => settingsProvider.setLyricsFontSize(value),
      ),
    );
  }
}

class _LyricsBoldTile extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const _LyricsBoldTile({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.format_bold),
      title: Text(l10n.mainTextBold),
      trailing: Switch(
        value: settingsProvider.lyricsBold,
        onChanged: (value) => settingsProvider.setLyricsBold(value),
      ),
    );
  }
}

class _TranslationFontSizeTile extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const _TranslationFontSizeTile({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.translate),
      title: Text(l10n.translationSize),
      subtitle: Text('${settingsProvider.translationFontSize.toInt()} px'),
      trailing: FontSizeControl(
        fontSize: settingsProvider.translationFontSize,
        minSize: 10,
        maxSize: 32,
        onChanged: (value) => settingsProvider.setTranslationFontSize(value),
      ),
    );
  }
}

class _TranslationBoldTile extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const _TranslationBoldTile({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.format_bold),
      title: Text(l10n.translationBold),
      trailing: Switch(
        value: settingsProvider.translationBold,
        onChanged: (value) => settingsProvider.setTranslationBold(value),
      ),
    );
  }
}

class _TranscriptFontSizeTile extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const _TranscriptFontSizeTile({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.record_voice_over),
      title: Text(l10n.transcriptSize),
      subtitle: Text('${settingsProvider.transcriptFontSize.toInt()} px'),
      trailing: FontSizeControl(
        fontSize: settingsProvider.transcriptFontSize,
        minSize: 8,
        maxSize: 28,
        onChanged: (value) => settingsProvider.setTranscriptFontSize(value),
      ),
    );
  }
}

class _TranscriptBoldTile extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const _TranscriptBoldTile({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.format_bold),
      title: Text(l10n.transcriptBold),
      trailing: Switch(
        value: settingsProvider.transcriptBold,
        onChanged: (value) => settingsProvider.setTranscriptBold(value),
      ),
    );
  }
}

class _FontFamilyTile extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const _FontFamilyTile({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.font_download),
      title: Text(l10n.font),
      subtitle: Text(settingsProvider.fontFamily.isEmpty
          ? l10n.systemFont
          : settingsProvider.fontFamily),
      trailing: DropdownButton<String>(
        value: settingsProvider.fontFamily.isEmpty
            ? 'default'
            : settingsProvider.fontFamily,
        icon: const Icon(Icons.arrow_drop_down),
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(
              value: 'default', child: Text(l10n.systemFont)),
          DropdownMenuItem(
              value: 'Roboto', child: Text(l10n.fontRoboto)),
          DropdownMenuItem(
              value: 'OpenSans', child: Text(l10n.fontOpenSans)),
          DropdownMenuItem(value: 'Lato', child: Text(l10n.fontLato)),
        ],
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setFontFamily(value == 'default' ? '' : value);
          }
        },
      ),
    );
  }
}
