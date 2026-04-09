import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/services/export_import_service.dart';
import 'package:lingotune/l10n/app_localizations.dart';

class PlayerExportHelper {
  Future<void> exportCurrentSong(
    BuildContext context,
    Song song,
  ) async {
    try {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      final zipFile = await ExportImportService.exportSong(song);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (zipFile != null) {
        final l10n = AppLocalizations.of(context)!;
        await ExportImportService.shareExportFile(
          zipFile,
          l10n.exportShareSubject(song.title),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.exportSuccessful),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToExportSong),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error exporting song: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.errorWithMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
