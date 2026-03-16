import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../app_info.dart';
import '../services/settings_provider.dart';
import '../services/folder_config_service.dart';

class SettingsDialogs {
  static Future<void> showAboutDialog2(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    showAboutDialog(
      context: context,
      applicationName: AppInfo.appName,
      applicationVersion: AppInfo.version,
      applicationLegalese: '© 2026 Z.AI GLM & Цимбалов Артем',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppInfo.appDescription),
            const SizedBox(height: 16),
            Text(
              '${l10n.version}: ${AppInfo.version}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text('${l10n.developer} Z.AI GLM & Цимбалов Артем'),
            const SizedBox(height: 8),
            Text(AppInfo.website),
            Text(l10n.languageLearning),
          ],
        ),
      ],
    );
  }

  static void showApiKeyDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final controller = TextEditingController(
        text: settingsProvider.deepseekApiKey ?? '');
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deepseekApiKey),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            labelText: l10n.apiKeyHint,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                controller.text = controller.text;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              settingsProvider.setDeepseekApiKey(controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.apiKeySaved)),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  static void showDeepseekPromptDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: settingsProvider.deepseekPrompt ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deepSeekPromptTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                maxLines: 15,
                decoration: InputDecoration(
                  labelText: l10n.customPromptLabel,
                  border: const OutlineInputBorder(),
                  hintText: l10n.leaveEmptyToUseDefault,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.leaveEmptyToUseDefaultPrompt,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              settingsProvider.setDeepseekPrompt('');
              Navigator.pop(context);
            },
            child: Text(l10n.resetToDefault),
          ),
          ElevatedButton(
            onPressed: () {
              settingsProvider.setDeepseekPrompt(controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.promptSaved)),
              );
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  static void showPromptEditDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    String initialPrompt,
    bool isCustom,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: initialPrompt);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit_note),
            const SizedBox(width: 8),
            Text(isCustom ? l10n.editCustomPrompt : l10n.editPresetPrompt),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCustom) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            l10n.editingPreset,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.anyChangesSaveAsCustom,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: controller,
                maxLines: 15,
                decoration: InputDecoration(
                  labelText: l10n.prompt,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${controller.text.length} ${l10n.characters}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (!isCustom)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                settingsProvider.setDeepseekPrompt('');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.usingPresetPrompt),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(l10n.resetToPreset),
            ),
          ElevatedButton(
            onPressed: () {
              final editedPrompt = controller.text.trim();
              if (editedPrompt.isNotEmpty) {
                settingsProvider.setDeepseekPrompt(editedPrompt);
                settingsProvider.setSelectedPromptPreset('custom');
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.customPrompt),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                Navigator.pop(context);
                settingsProvider.setDeepseekPrompt('');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.usingPresetPrompt),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  static void showCustomTimeoutDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: settingsProvider.deepseekTimeout.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.customTimeout),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: l10n.timeoutSeconds,
            border: const OutlineInputBorder(),
            hintText: l10n.enterTimeout,
            suffixText: 's',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value != null && value > 0 && value <= 3600) {
                settingsProvider.setDeepseekTimeout(value);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.timeoutSetTo('$value').replaceAll('{value}', '$value'))),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.validTimeoutRange),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  static void showCustomModelDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: settingsProvider.deepseekModel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.customModel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.modelName,
                border: const OutlineInputBorder(),
                hintText: l10n.modelHint,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.enterExactModelName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                settingsProvider.setDeepseekModel(value);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.modelSetTo(value).replaceAll('{value}', value))),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.pleaseEnterModelName),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  static Future<void> showCurrentFolder(BuildContext context) async {
    final folderPath = await FolderConfigService.getFolderDisplayPath();
    final l10n = AppLocalizations.of(context)!;

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.lyricsFolder),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.currentFolder,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  folderPath,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    }
  }

  static Future<String?> selectCustomFolder(
    BuildContext context,
    String currentPath,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentPath);
    String selectedPath = currentPath;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setLyricsFolder),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectFolder),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: l10n.folderPath,
                  hintText: '/storage/emulated/0/LingoTune_Lyrics',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: () async {
                      try {
                        final path = await FilePicker.platform.getDirectoryPath(
                          dialogTitle: l10n.selectFolder,
                        );

                        if (path != null && path.isNotEmpty) {
                          controller.text = path;
                        }
                      } catch (e) {
                        debugPrint('Error picking folder: $e');
                      }
                    },
                    tooltip: l10n.browse,
                  ),
                ),
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  selectedPath = value;
                },
              ),
              const SizedBox(height: 12),
              Text(
                l10n.examples,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                '/storage/emulated/0/Lyrics',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const Text(
                '/storage/emulated/0/Download/LingoTune',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap folder icon to browse',
                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result != null && result!.isNotEmpty) {
      debugPrint('=== Settings: Selecting custom folder ===');
      debugPrint('Selected path: $result');

      final success = await FolderConfigService.setCustomFolder(result);

      if (success) {
        debugPrint('Folder successfully set');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.folderSetSuccessfully(result)),
              backgroundColor: Colors.green,
            ),
          );
        }
        return result;
      } else {
        debugPrint('Failed to set folder');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.folderSetFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    return null;
  }

  static Future<void> resetToDefaultFolder(
    BuildContext context,
    Function(String) onFolderChanged,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    debugPrint('=== Settings: Resetting to default folder ===');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customLrcJsonFolder', '');

    onFolderChanged('');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.resetToDefaultFolder),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
