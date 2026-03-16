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
        items: const [
          DropdownMenuItem(value: 'default', child: Text('Default')),
          DropdownMenuItem(value: 'purple', child: Text('🟣')),
          DropdownMenuItem(value: 'blue', child: Text('🔵')),
          DropdownMenuItem(value: 'green', child: Text('🟢')),
          DropdownMenuItem(value: 'orange', child: Text('🟠')),
          DropdownMenuItem(value: 'red', child: Text('🔴')),
          DropdownMenuItem(value: 'pink', child: Text('🩷')),
          DropdownMenuItem(value: 'deepOrange', child: Text('🟧')),
          DropdownMenuItem(value: 'darkRed', child: Text('🟥')),
          DropdownMenuItem(value: 'teal', child: Text('💠')),
          DropdownMenuItem(value: 'cyan', child: Text('🔷')),
          DropdownMenuItem(value: 'amber', child: Text('🟨')),
          DropdownMenuItem(value: 'lime', child: Text('🟩')),
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
