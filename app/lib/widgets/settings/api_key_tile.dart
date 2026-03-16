import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';
import '../../services/settings_dialogs.dart';
import '../../services/deepseek_api_service.dart';
import '../../l10n/app_localizations.dart';

class ApiKeyTile extends StatelessWidget {
  const ApiKeyTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = context.watch<SettingsProvider>();

    return ListTile(
      leading: const Icon(Icons.key),
      title: Text(l10n.deepseekApiKey),
      subtitle: Text(settingsProvider.deepseekApiKey?.isEmpty ?? true
          ? 'Not set'
          : '••••••••••••'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => SettingsDialogs.showApiKeyDialog(context, settingsProvider),
            tooltip: 'Show/Edit API key',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _validateApiKey(context, settingsProvider),
            tooltip: l10n.validateKey,
          ),
        ],
      ),
    );
  }

  Future<void> _validateApiKey(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final apiKey = settingsProvider.deepseekApiKey;

    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter API key first'),
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
