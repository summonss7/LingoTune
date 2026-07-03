import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../../services/settings_provider.dart';

/// Тайл выбора источника TTS: «Офлайн» (sherpa_onnx VITS, рекомендуется для
/// стабильности на любом устройстве, особенно китайские ROM) или «Системный»
/// (FlutterTts — поведение версии 5.4.0).
///
/// Переключение заново инициализирует TtsCoordinator (через listener в
/// PlayerScreen._onSettingsChanged), который создаст новый TtsEngine и
/// утилизирует старый. Активная речь прерывается.
class TtsSourceSettingsTile extends StatelessWidget {
  const TtsSourceSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final current = settings.ttsSource; // 'offline' | 'system'

    return ListTile(
      leading: const Icon(Icons.cloud_download_outlined),
      title: Text(l10n.ttsSource),
      subtitle: Text(current == 'offline'
          ? l10n.ttsSourceOfflineSubtitle
          : l10n.ttsSourceSystemSubtitle),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: DropdownButton<String>(
          value: current == 'system' ? 'system' : 'offline',
          icon: const Icon(Icons.arrow_drop_down),
          underline: const SizedBox(),
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: 'offline',
              child: Text(
                l10n.ttsSourceOffline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownMenuItem(
              value: 'system',
              child: Text(
                l10n.ttsSourceSystem,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          onChanged: (value) async {
            if (value == null) return;
            await settings.setTtsSource(value);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.ttsSourceSwitchedHint),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
