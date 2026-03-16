import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class FolderUsageTile extends StatelessWidget {
  final bool useCustomFolder;
  final ValueChanged<bool> onChanged;

  const FolderUsageTile({
    super.key,
    required this.useCustomFolder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.folder_open),
      title: Text(l10n.useLyricsFolder),
      subtitle: useCustomFolder
          ? const Text('Custom folder')
          : Text(l10n.useLyricsFolderDisabled),
      trailing: Switch(
        value: useCustomFolder,
        onChanged: onChanged,
      ),
    );
  }
}

class FolderSettingsTile extends StatelessWidget {
  final String customFolder;
  final VoidCallback onReset,
                  onShowCurrent,
                  onEdit;

  const FolderSettingsTile({
    super.key,
    required this.customFolder,
    required this.onReset,
    required this.onShowCurrent,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(l10n.lyricsFolder),
      subtitle: Text(
        customFolder.isEmpty
            ? l10n.defaultFolder
            : customFolder,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customFolder.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onReset,
              tooltip: l10n.resetToDefault,
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onShowCurrent,
            tooltip: l10n.showCurrentFolder,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
            tooltip: l10n.changeFolder,
          ),
        ],
      ),
    );
  }
}
