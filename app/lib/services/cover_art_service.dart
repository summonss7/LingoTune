import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CoverArtService {
  static final Map<String, bool> _fileExistsCache = {};
  static const int _maxCacheSize = 500;

  static final List<List<Color>> _gradients = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFF5576C)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFFa8edea), Color(0xFFfed6e3)],
    [Color(0xFFff9a9e), Color(0xFFfecfef)],
    [Color(0xFFffecd2), Color(0xFFfcb69f)],
    [Color(0xFFa1c4fd), Color(0xFFc2e9fb)],
    [Color(0xFFd299c2), Color(0xFFfef9d7)],
    [Color(0xFF89f7fe), Color(0xFF66a6ff)],
    [Color(0xFFfddb92), Color(0xFFd1fdff)],
  ];

  static Color _generateColor(String title) {
    final hash = title.hashCode;
    final absHash = hash >= 0 ? hash : -hash;
    final random = math.Random(absHash);
    return Color.fromARGB(
      255,
      100 + random.nextInt(156),
      100 + random.nextInt(156),
      100 + random.nextInt(156),
    );
  }

  static List<Color> getGradientForSong(String title) {
    final hash = title.hashCode;
    final absHash = hash >= 0 ? hash : -hash;
    final index = absHash % _gradients.length;
    return _gradients[index];
  }

  static Widget generateCoverArt(String title, {double size = 56}) {
    final gradient = getGradientForSong(title);
    final initial = title.isNotEmpty ? title[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static img.Image _smartCropImage(img.Image image) {
    final width = image.width;
    final height = image.height;
    final cropSize = math.min(width, height);

    if (width == height) {
      return image;
    }

    final cropX = (width - cropSize) ~/ 2;
    final cropY = (height - cropSize) ~/ 2;

    return img.copyCrop(image, x: cropX, y: cropY, width: cropSize, height: cropSize);
  }

  static Future<String> saveCoverArt(String imagePath, String songTitle, {String? oldCoverPath}) async {
    Directory? directory;

    try {
      directory = await getApplicationDocumentsDirectory();
      debugPrint('Application documents directory: ${directory.path}');
    } catch (e) {
      debugPrint('Error getting application documents directory: $e');
      throw Exception('Cannot access storage directory');
    }

    try {
      final coversFolder = Directory(path.join(directory.path, 'LingoTune_Covers'));
      debugPrint('Covers folder path: ${coversFolder.path}');

      if (!coversFolder.existsSync()) {
        await coversFolder.create(recursive: true);
        debugPrint('Created covers folder');
      }

      if (oldCoverPath != null && oldCoverPath.isNotEmpty) {
        try {
          final oldFile = File(oldCoverPath);
          if (oldFile.existsSync()) {
            await oldFile.delete();
            debugPrint('Old cover art deleted: $oldCoverPath');
          }
        } catch (e) {
          debugPrint('Error deleting old cover art: $e');
        }
      }

      final fileName = '${songTitle.replaceAll(RegExp(r'[^\w\s-]'), '_')}_${DateTime.now().millisecondsSinceEpoch}_cover.png';
      final outputPath = path.join(coversFolder.path, fileName);

      debugPrint('Reading image from: $imagePath');
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Source image file does not exist');
      }

      final bytes = await file.readAsBytes();
      debugPrint('Image size: ${bytes.length} bytes');

      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');

      debugPrint('Image dimensions: ${image.width}x${image.height}');

      if (image.width > 2000 || image.height > 2000) {
        debugPrint('Image is large, resizing...');
        final maxSize = math.min(image.width, image.height);
        final scale = 2000.0 / maxSize;
        final newWidth = (image.width * scale).toInt();
        final newHeight = (image.height * scale).toInt();
        image = img.copyResize(image, width: newWidth, height: newHeight);
      }

      final croppedImage = _smartCropImage(image);
      debugPrint('Cropped image dimensions: ${croppedImage.width}x${croppedImage.height}');

      final thumbnail = img.copyResize(
        croppedImage,
        width: 56,
        height: 56,
        interpolation: img.Interpolation.linear,
      );

      final thumbnailPath = outputPath.replaceFirst('_cover.png', '_thumb.png');
      final thumbnailBytes = img.encodePng(thumbnail);
      await File(thumbnailPath).writeAsBytes(thumbnailBytes);
      debugPrint('Thumbnail saved: $thumbnailPath');

      final finalBytes = img.encodePng(croppedImage);
      await File(outputPath).writeAsBytes(finalBytes);

      debugPrint('Cover art saved: $outputPath');
      _fileExistsCache[outputPath] = true;
      if (_fileExistsCache.length > _maxCacheSize) {
        final keysToRemove = _fileExistsCache.keys.take(_fileExistsCache.length - _maxCacheSize ~/ 2);
        for (final key in keysToRemove) {
          _fileExistsCache.remove(key);
        }
      }
      if (oldCoverPath != null) _fileExistsCache.remove(oldCoverPath);
      return outputPath;
    } catch (e) {
      debugPrint('Error saving cover art: $e');
      rethrow;
    }
  }

  static Future<void> deleteCoverArt(String? coverArtPath) async {
    if (coverArtPath == null || coverArtPath.isEmpty) return;

    try {
      final file = File(coverArtPath);
      if (file.existsSync()) {
        await file.delete();
        debugPrint('Cover art deleted: $coverArtPath');
      }

      _fileExistsCache.remove(coverArtPath);

      final thumbPath = coverArtPath.replaceAll('_cover.png', '_thumb.png');
      final thumbFile = File(thumbPath);
      if (thumbFile.existsSync()) {
        await thumbFile.delete();
        debugPrint('Thumbnail deleted: $thumbPath');
      }
    } catch (e) {
      debugPrint('Error deleting cover art: $e');
    }
  }

  static Widget buildCoverArtWidget({
    required String title,
    String? coverArtPath,
    int coverArtVersion = 0,
    double size = 56,
    Key? key,
  }) {
    final widgetKey = key ?? ValueKey('${coverArtPath}_v$coverArtVersion');

    if (coverArtPath != null && coverArtPath.isNotEmpty) {
      final exists = _fileExistsCache.putIfAbsent(
        coverArtPath,
        () => File(coverArtPath).existsSync(),
      );
      if (!exists) {
        debugPrint('Cover art file does not exist: $coverArtPath');
        return generateCoverArt(title, size: size);
      }

      return RepaintBoundary(
        key: widgetKey,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(coverArtPath),
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: size.toInt(),
            cacheHeight: size.toInt(),
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return generateCoverArt(title, size: size);
            },
          ),
        ),
      );
    }

    return generateCoverArt(title, size: size);
  }
}
