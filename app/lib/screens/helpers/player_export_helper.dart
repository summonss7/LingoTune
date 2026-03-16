import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/services/export_import_service.dart';

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
        await ExportImportService.shareExportFile(
          zipFile,
          'LingoTune экспорт: ${song.title} с лирикой и переводами',
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export successful!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to export song'),
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
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
