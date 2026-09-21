import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/theme_provider.dart';
import '../../services/settings_provider.dart';
import '../../services/settings_helper.dart';
import '../../l10n/app_localizations.dart';

class ThemeSettingsTile extends StatelessWidget {
  const ThemeSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return ListTile(
      leading: const Icon(Icons.dark_mode),
      title: Text(
          themeProvider.isDarkMode ? l10n.darkMode : l10n.lightMode),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) async {
          await themeProvider.setIsDarkMode(value);
        },
      ),
    );
  }
}

class ColorThemeTile extends StatelessWidget {
  const ColorThemeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return ListTile(
      leading: const Icon(Icons.palette),
      title: Text(l10n.colorTheme),
      subtitle: Text(SettingsHelper.getThemeColorName(context, settingsProvider.themeColor)),
      trailing: DropdownButton<String>(
        value: settingsProvider.themeColor.isEmpty
            ? 'default'
            : settingsProvider.themeColor,
        items: [
          DropdownMenuItem(value: 'amethyst', child: Text('💜 ${l10n.themeNameAmethyst}')),
          const DropdownMenuItem(value: 'default', child: Text('Default')),
          const DropdownMenuItem(value: 'purple', child: Text('🟣')),
          const DropdownMenuItem(value: 'blue', child: Text('🔵')),
          const DropdownMenuItem(value: 'green', child: Text('🟢')),
          const DropdownMenuItem(value: 'orange', child: Text('🟠')),
          const DropdownMenuItem(value: 'red', child: Text('🔴')),
          const DropdownMenuItem(value: 'pink', child: Text('🩷')),
          const DropdownMenuItem(value: 'deepOrange', child: Text('🟧')),
          const DropdownMenuItem(value: 'darkRed', child: Text('🟥')),
          const DropdownMenuItem(value: 'teal', child: Text('💠')),
          const DropdownMenuItem(value: 'cyan', child: Text('🔷')),
          const DropdownMenuItem(value: 'amber', child: Text('🟨')),
          const DropdownMenuItem(value: 'lime', child: Text('🟩')),
        ],
        onChanged: (value) {
          if (value != null) {
            settingsProvider.setThemeColor(value);
            themeProvider.setThemeColor(value);
          }
        },
      ),
    );
  }
}
