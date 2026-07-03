import 'package:flutter/material.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../../screens/voice_packages_screen.dart';

/// Тайл-переход на экран «Голосовые пакеты», где пользователь может
/// скачать/удалить офлайн-TTS модели для языков перевода.
///
/// Сам тайл не содержит логики — только переход на [VoicePackagesScreen].
class VoicePackagesTile extends StatelessWidget {
  const VoicePackagesTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.library_music_outlined),
      title: Text(l10n.voicePackages),
      subtitle: Text(l10n.voicePackagesSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const VoicePackagesScreen(),
          ),
        );
      },
    );
  }
}
