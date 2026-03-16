import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';
import '../../services/settings_dialogs.dart';
import '../../services/deepseek_api_service.dart';
import '../../constants/deepseek_prompts.dart';
import '../../l10n/app_localizations.dart';

class ApiSettingsTile extends StatelessWidget {
  const ApiSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.key),
          title: Text(l10n.deepseekApiKey),
          subtitle: Text(settingsProvider.deepseekApiKey.isEmpty
              ? l10n.notSet
              : '••••••••••••'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () => SettingsDialogs.showApiKeyDialog(context, settingsProvider),
                tooltip: l10n.showOrEditApiKey,
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _validateApiKey(context, settingsProvider),
                tooltip: l10n.validateKey,
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.psychology),
          title: Text(l10n.promptPreset),
          subtitle: Text(_getPresetName(l10n, settingsProvider.selectedPromptPreset)),
          trailing: DropdownButton<String>(
            value: settingsProvider.selectedPromptPreset == 'custom' ? 'custom' : settingsProvider.selectedPromptPreset,
            items: [
              DropdownMenuItem(value: 'balanced', child: Text(l10n.balanced)),
              DropdownMenuItem(value: 'poetic', child: Text(l10n.poetic)),
              DropdownMenuItem(value: 'literal', child: Text(l10n.literal)),
              DropdownMenuItem(value: 'custom', child: Text(l10n.customPromptOption)),
            ],
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setSelectedPromptPreset(value);
                if (value != 'custom') {
                  settingsProvider.setDeepseekPrompt('');
                }
              }
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.edit_note),
          title: Text(l10n.editPrompt),
          subtitle: Text(
            settingsProvider.deepseekPrompt.isNotEmpty
                ? l10n.customPromptChars(settingsProvider.deepseekPrompt.length)
                : l10n.usingPreset(_getPresetName(l10n, settingsProvider.selectedPromptPreset)),
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (settingsProvider.selectedPromptPreset != 'custom')
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _resetToPreset(context, settingsProvider),
                  tooltip: l10n.resetToPreset,
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editPrompt(context, settingsProvider),
                tooltip: l10n.editPrompt,
              ),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: Text(l10n.timeout),
          subtitle: Text('${settingsProvider.deepseekTimeout}s'),
          trailing: DropdownButton<int>(
            value: settingsProvider.deepseekTimeout,
            items: [
              const DropdownMenuItem(value: 60, child: Text('60s')),
              const DropdownMenuItem(value: 120, child: Text('120s')),
              const DropdownMenuItem(value: 180, child: Text('180s')),
              const DropdownMenuItem(value: 300, child: Text('300s')),
              const DropdownMenuItem(value: 600, child: Text('600s')),
              DropdownMenuItem(value: -1, child: Text(l10n.customTimeout)),
            ],
            onChanged: (value) {
              if (value == -1) {
                SettingsDialogs.showCustomTimeoutDialog(context, settingsProvider);
              } else if (value != null) {
                settingsProvider.setDeepseekTimeout(value);
              }
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.token),
          title: Text(l10n.maxTokensRegular),
          subtitle: Text('${settingsProvider.deepseekMaxTokensRegular}'),
          trailing: DropdownButton<int>(
            value: settingsProvider.deepseekMaxTokensRegular,
            items: [
              const DropdownMenuItem(value: 200, child: Text('200')),
              const DropdownMenuItem(value: 400, child: Text('400')),
              const DropdownMenuItem(value: 500, child: Text('500')),
              const DropdownMenuItem(value: 800, child: Text('800')),
              const DropdownMenuItem(value: 1000, child: Text('1000')),
              const DropdownMenuItem(value: 1500, child: Text('1500')),
              const DropdownMenuItem(value: 2000, child: Text('2000')),
            ],
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setDeepseekMaxTokensRegular(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.maxTokensRegularSetTo(value.toString())),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.token),
          title: Text(l10n.maxTokensJson),
          subtitle: Text('${settingsProvider.deepseekMaxTokensJson}'),
          trailing: DropdownButton<int>(
            value: settingsProvider.deepseekMaxTokensJson,
            items: [
              const DropdownMenuItem(value: 2000, child: Text('2000')),
              const DropdownMenuItem(value: 4000, child: Text('4000')),
              const DropdownMenuItem(value: 6000, child: Text('6000')),
              const DropdownMenuItem(value: 8000, child: Text('8000')),
              const DropdownMenuItem(value: 12000, child: Text('12000')),
              const DropdownMenuItem(value: 16000, child: Text('16000')),
            ],
            onChanged: (value) {
              if (value != null) {
                settingsProvider.setDeepseekMaxTokensJson(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.maxTokensJsonSetTo(value.toString())),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.model_training),
          title: Text(l10n.model),
          subtitle: Text(settingsProvider.deepseekModel),
          trailing: DropdownButton<String>(
            value: settingsProvider.deepseekModel,
            items: [
              const DropdownMenuItem(value: 'deepseek-reasoner', child: Text('deepseek-reasoner')),
              const DropdownMenuItem(value: 'deepseek-chat', child: Text('deepseek-chat')),
              const DropdownMenuItem(value: 'deepseek-coder', child: Text('deepseek-coder')),
              DropdownMenuItem(value: 'custom', child: Text(l10n.customModel)),
            ],
            onChanged: (value) {
              if (value == 'custom') {
                SettingsDialogs.showCustomModelDialog(context, settingsProvider);
              } else if (value != null) {
                settingsProvider.setDeepseekModel(value);
              }
            },
          ),
        ),
      ],
    );
  }

  String _getPresetName(AppLocalizations l10n, String preset) {
    switch (preset) {
      case 'poetic':
        return l10n.poetic;
      case 'literal':
        return l10n.literal;
      case 'balanced':
      default:
        return l10n.balanced;
    }
  }

  void _resetToPreset(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    settingsProvider.setDeepseekPrompt('');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.resetToDefault.replaceAll('{preset}', _getPresetName(l10n, settingsProvider.selectedPromptPreset))),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editPrompt(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    String initialPrompt;
    bool isCustom;

    if (settingsProvider.deepseekPrompt.isNotEmpty) {
      initialPrompt = settingsProvider.deepseekPrompt;
      isCustom = true;
    } else {
      initialPrompt = DeepSeekPrompts.getPromptForPreset(
        settingsProvider.selectedPromptPreset,
        '',
        ['trans', 'ru'],
        'ro',
        'ru',
      );
      isCustom = false;
    }

    SettingsDialogs.showPromptEditDialog(
      context,
      settingsProvider,
      initialPrompt,
      isCustom,
    );
  }

  Future<void> _validateApiKey(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final apiKey = settingsProvider.deepseekApiKey;

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterApiKeyFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final apiService = DeepSeekApiService(
      apiKey: apiKey,
      customPrompt: settingsProvider.deepseekPrompt,
      timeout: settingsProvider.deepseekTimeout,
      model: settingsProvider.deepseekModel,
      promptPreset: settingsProvider.selectedPromptPreset,
      maxTokensRegular: settingsProvider.deepseekMaxTokensRegular,
      maxTokensJson: settingsProvider.deepseekMaxTokensJson,
    );
    final isValid = await apiService.validateApiKey();

    if (context.mounted) {
      Navigator.pop(context);
      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.keyIsValid),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.keyIsInvalid),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
