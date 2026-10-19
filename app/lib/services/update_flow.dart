import 'dart:async';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../l10n/app_localizations.dart';
import 'update_service.dart';

/// Оркестрация проверки обновлений: авто-чек при запуске (раз в сутки),
/// ручная проверка из настроек, диалог «доступна новая версия», скачивание
/// с прогрессом и запуск установки APK.
///
/// Все диалоги — через rootNavigator, чтобы всплывать поверх любого экрана
/// (включая плеер). Семантические цвета SnackBar (зелёный/красный) — как во
/// всём приложении.
class UpdateFlow {
  static bool _dialogOpen = false;

  /// Автоматическая проверка при старте приложения (не чаще раза в сутки).
  /// Тихая: нет обновления или источник недоступен — ничего не показываем.
  static Future<void> maybeAutoCheck(BuildContext context) async {
    if (!await UpdateService.autoCheckDue()) return;
    await UpdateService.markAutoCheckDone();

    final service = UpdateService();
    AppUpdate? update;
    try {
      update = await service.checkForUpdate();
    } catch (e) {
      debugPrint('ℹ UpdateFlow: auto check failed: $e');
      return;
    }
    if (!context.mounted) return;
    if (update != null) {
      _showUpdateDialog(context, update, service);
    }
  }

  /// Ручная проверка из настроек — всегда с видимым результатом.
  static Future<void> manualCheck(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
          content: Text(l10n.updateChecking),
          duration: const Duration(seconds: 30)),
    );

    final service = UpdateService();
    AppUpdate? update;
    String? error;
    try {
      update = await service.checkForUpdate();
    } catch (e) {
      error = e.toString();
      debugPrint('✗ UpdateFlow: manual check failed: $e');
    }
    messenger.hideCurrentSnackBar();

    if (!context.mounted) return;
    if (update != null) {
      _showUpdateDialog(context, update, service);
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content:
            Text(error != null ? l10n.updateCheckFailed : l10n.noUpdatesAvailable),
        backgroundColor: error != null ? Colors.red : Colors.green,
      ),
    );
  }

  static void _showUpdateDialog(
      BuildContext context, AppUpdate update, UpdateService service) {
    if (_dialogOpen) return;
    _dialogOpen = true;
    final l10n = AppLocalizations.of(context)!;
    final sizeMb = update.sizeBytes != null && update.sizeBytes! > 0
        ? ' (${(update.sizeBytes! / 1024 / 1024).toStringAsFixed(1)} MB)'
        : '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.system_update, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.updateAvailableTitle)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.updateCurrentVersion(AppInfo.version)),
              const SizedBox(height: 4),
              Text(
                '${l10n.updateNewVersion(update.version)}$sizeMb',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (update.notes.trim().isNotEmpty) ...[
                const Divider(height: 24),
                Text(l10n.whatsNew,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  update.notes.trim(),
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.later),
          ),
          if (update.releasePageUrl != null &&
              update.releasePageUrl!.isNotEmpty)
            TextButton(
              onPressed: () =>
                  _openInBrowser(update.releasePageUrl!, dialogContext),
              child: Text(l10n.openReleasePage),
            ),
          if (update.downloadUrl != null && update.downloadUrl!.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _startDownload(context, update, service);
              },
              child: Text(
                l10n.download,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    ).whenComplete(() => _dialogOpen = false);
  }

  static Future<void> _startDownload(
      BuildContext context, AppUpdate update, UpdateService service) async {
    final messenger = ScaffoldMessenger.of(context);
    final onDone = (String? path) {
      if (path == null) {
        final l10n = AppLocalizations.of(context)!;
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.updateDownloadFailed),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (!context.mounted) return;
      _promptInstall(context, path);
    };

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _UpdateProgressDialog(
          update: update,
          service: service,
          onDone: onDone,
        ),
      ),
    );
  }

  static Future<void> _promptInstall(BuildContext context, String path) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final install = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.download_done, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.updateDownloaded)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.later),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.install,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (install != true) return;

    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        debugPrint('✗ UpdateFlow: install start failed: ${result.message}');
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.updateInstallFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('✗ UpdateFlow: OpenFilex error: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.updateInstallFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> _openInBrowser(String url, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateCheckFailed)),
        );
      }
    } catch (e) {
      debugPrint('✗ UpdateFlow: launchUrl error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.updateCheckFailed)),
        );
      }
    }
  }
}

/// Диалог скачивания: сам запускает загрузку, сам себя закрывает по её
/// завершению (единственный путь закрытия — нет гонок «кто первый pop»),
/// отмена лишь прерывает загрузку и дожидается возврата.
class _UpdateProgressDialog extends StatefulWidget {
  const _UpdateProgressDialog({
    required this.update,
    required this.service,
    required this.onDone,
  });

  final AppUpdate update;
  final UpdateService service;
  final void Function(String? path) onDone;

  @override
  State<_UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<_UpdateProgressDialog> {
  final ValueNotifier<(int, int)> _progress = ValueNotifier((0, 0));
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    final path = await widget.service.downloadUpdate(
      widget.update,
      onProgress: (received, total) {
        final knownTotal =
            total > 0 ? total : (widget.update.sizeBytes ?? 0);
        _progress.value = (received, knownTotal);
      },
    );
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    widget.onDone(path);
  }

  @override
  void dispose() {
    widget.service.cancelDownload();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(l10n.downloadingUpdate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            ValueListenableBuilder<(int, int)>(
              valueListenable: _progress,
              builder: (context, value, _) {
                final (received, total) = value;
                final receivedMb = (received / 1024 / 1024).toStringAsFixed(1);
                if (total > 0) {
                  final percent = (received * 100 ~/ total).clamp(0, 100);
                  return Text(
                    '$percent% — $receivedMb / '
                    '${(total / 1024 / 1024).toStringAsFixed(1)} MB',
                    textAlign: TextAlign.center,
                  );
                }
                return Text('$receivedMb MB');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _cancelling
                ? null
                : () {
                    // Не закрываем диалог здесь — прерываем загрузку; диалог
                    // закроет единственный путь: возврат downloadUpdate.
                    setState(() => _cancelling = true);
                    widget.service.cancelDownload();
                  },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
