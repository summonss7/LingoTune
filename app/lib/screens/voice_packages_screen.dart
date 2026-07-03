import 'package:flutter/material.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import '../services/tts/tts_catalog.dart';
import '../services/tts/tts_model_manager.dart';

/// Экран «Голосовые пакеты» — управление офлайн-TTS моделями.
///
/// Для каждого языка из [TtsCatalog]:
/// - показывает статус (готово / не установлено / скачивается / ошибка);
/// - даёт кнопку «Скачать» (для не-bundled) или «Извлечь» (для bundled);
/// - во время операции показывает прогресс-бар (0–100 %);
/// - готовые модели можно удалить (кнопка «Удалить»).
///
/// Слушает [TtsModelManager] (ChangeNotifier) для live-обновления статусов.
class VoicePackagesScreen extends StatefulWidget {
  const VoicePackagesScreen({super.key});

  @override
  State<VoicePackagesScreen> createState() => _VoicePackagesScreenState();
}

class _VoicePackagesScreenState extends State<VoicePackagesScreen> {
  final TtsModelManager _mgr = TtsModelManager.instance;

  @override
  void initState() {
    super.initState();
    // Обновляем кеш статусов (ready/absent) при открытии экрана.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _mgr.refreshAllStatuses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final voices = TtsCatalog.all;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.voicePackages),
      ),
      body: AnimatedBuilder(
        animation: _mgr,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // Информационная плашка.
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Text(
                  l10n.voicePackagesDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const Divider(height: 1),
              for (final v in voices) _VoiceTile(voice: v),
            ],
          );
        },
      ),
    );
  }
}

class _VoiceTile extends StatelessWidget {
  final TtsVoiceInfo voice;
  const _VoiceTile({required this.voice});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mgr = TtsModelManager.instance;
    final status = mgr.statusOf(voice.languageCode);
    final progress = mgr.progressOf(voice.languageCode);
    final error = mgr.errorOf(voice.languageCode);
    final sizeMb = (voice.estimatedSizeBytes / 1000000).toStringAsFixed(0);

    String statusText;
    Widget? trailing;
    IconData leadingIcon = Icons.language;

    switch (status) {
      case TtsModelStatus.ready:
        statusText = l10n.voicePackageReady;
        leadingIcon = Icons.check_circle;
        trailing = IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: l10n.voicePackageDelete,
          onPressed: () => _confirmDelete(context, voice),
        );
        break;
      case TtsModelStatus.absent:
        if (voice.bundled) {
          statusText = l10n.voicePackageBundled;
          leadingIcon = Icons.archive_outlined;
        } else {
          statusText = '${l10n.voicePackageDownload} · ~$sizeMb MB';
          leadingIcon = Icons.cloud_download_outlined;
        }
        trailing = FilledButton.tonal(
          onPressed: () => _install(context, voice),
          child: Text(voice.bundled
              ? l10n.voicePackageInstall
              : l10n.voicePackageDownload),
        );
        break;
      case TtsModelStatus.extractingBundle:
        statusText = l10n.voicePackageExtracting;
        leadingIcon = Icons.downloading;
        trailing = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case TtsModelStatus.downloading:
        statusText = l10n.voicePackageDownloading;
        leadingIcon = Icons.cloud_download;
        trailing = SizedBox(
          width: 50,
          child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
        );
        break;
      case TtsModelStatus.extracting:
        statusText = l10n.voicePackageExtracting;
        leadingIcon = Icons.downloading;
        trailing = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case TtsModelStatus.error:
        statusText = error != null
            ? '${l10n.voicePackageError}: ${_shortError(error)}'
            : l10n.voicePackageError;
        leadingIcon = Icons.error_outline;
        trailing = FilledButton.tonal(
          onPressed: () => _install(context, voice),
          child: Text(l10n.voicePackageRetry),
        );
        break;
    }

    return ListTile(
      leading: Icon(leadingIcon),
      title: Text('${voice.languageLabel} · ${voice.speakerName}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(statusText,
          maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: trailing,
      isThreeLine: true,
    );
  }

  String _shortError(String e) {
    if (e.length > 60) return '${e.substring(0, 57)}...';
    return e;
  }

  Future<void> _install(BuildContext context, TtsVoiceInfo v) async {
    final l10n = AppLocalizations.of(context)!;
    final scaffold = ScaffoldMessenger.of(context);
    bool ok;
    if (v.bundled) {
      ok = await TtsModelManager.instance.extractBundle(v.languageCode);
    } else {
      ok = await TtsModelManager.instance.downloadAndInstall(v.languageCode);
    }
    if (!context.mounted) return;
    scaffold.showSnackBar(
      SnackBar(
        content: Text(ok
            ? l10n.voicePackageInstalledSuccess(v.languageLabel)
            : l10n.voicePackageInstalledFailed(v.languageLabel)),
        duration: Duration(seconds: ok ? 2 : 4),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TtsVoiceInfo v) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.voicePackageDelete),
        content: Text(l10n.voicePackageDeleteConfirm(v.languageLabel)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.voicePackageDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await TtsModelManager.instance.delete(v.languageCode);
    }
  }
}
