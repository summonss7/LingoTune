import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lingotune/l10n/app_localizations.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/services/cover_art_service.dart';
import 'package:lingotune/services/database_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';

class CoverArtHelper {
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  Future<void> editCoverArt(
    BuildContext context,
    Song song,
    Function setState,
    List<Song> songs,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.coverArt),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (song.coverArtPath != null && song.coverArtPath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(song.coverArtPath!),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: CoverArtService.getGradientForSong(song.title),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    song.title.isNotEmpty ? song.title[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.selectFromGallery),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            if (song.coverArtPath != null && song.coverArtPath!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(l10n.removeCover),
                onTap: () => Navigator.of(context).pop('delete'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (result == null) return;

    if (result == 'gallery') {
      await _selectFromGallery(context, song, l10n, setState, songs);
    } else if (result == 'delete') {
      await _deleteCoverArt(context, song, l10n, setState, songs);
    }
  }

  Future<void> _selectFromGallery(
    BuildContext context,
    Song song,
    AppLocalizations l10n,
    Function setState,
    List<Song> songs,
  ) async {
    bool permissionGranted = false;
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.photoPermissionDenied),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        permissionGranted = status.isGranted;
      } else {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.photoPermissionDenied),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        permissionGranted = status.isGranted;
      }

      if (!permissionGranted) return;
    } catch (e) {
      debugPrint('Error checking Android permissions: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage('Permission check failed: $e')),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        String imagePath = pickedFile.path;

        if (imagePath.startsWith('content://')) {
          debugPrint('Content URI detected, converting to file path: $imagePath');
          try {
            final xFile = XFile(pickedFile.path);
            final bytes = await xFile.readAsBytes();

            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/temp_cover_${DateTime.now().millisecondsSinceEpoch}.jpg');
            await tempFile.writeAsBytes(bytes);

            imagePath = tempFile.path;
            debugPrint('Converted to temporary file path: $imagePath');
          } catch (e) {
            debugPrint('Failed to convert content URI: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.imageProcessingError),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }

        final newCoverPath = await CoverArtService.saveCoverArt(imagePath, song.title ?? 'unknown');

        final updatedSong = song.copyWith(coverArtPath: newCoverPath, coverArtVersion: song.coverArtVersion + 1);
        await _databaseService.updateSong(updatedSong);

        setState(() {
          final index = songs.indexWhere((s) => s.id == song.id);
          if (index != -1) {
            songs[index] = updatedSong;
            songs = List.from(songs);
          }
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.coverUpdated),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error processing cover art: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorWithMessage(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteCoverArt(
    BuildContext context,
    Song song,
    AppLocalizations l10n,
    Function setState,
    List<Song> songs,
  ) async {
    await CoverArtService.deleteCoverArt(song.coverArtPath);

    final updatedSong = song.copyWith(
      coverArtPath: null,
      coverArtVersion: song.coverArtVersion + 1,
    );
    await _databaseService.updateSong(updatedSong);

    setState(() {
      final index = songs.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        songs[index] = updatedSong;
      }
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.coverRemoved),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
