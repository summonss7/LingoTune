import 'dart:io';
import 'package:flutter/material.dart';
import '../models/song.dart';
import '../utils/snackbar_helper.dart';

class SongListTile extends StatelessWidget {
  final Song song;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget? trailing;
  final bool showCoverArt;
  final VoidCallback? onGenerateLyrics;

  const SongListTile({
    super.key,
    required this.song,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    this.trailing,
    this.showCoverArt = true,
    this.onGenerateLyrics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildLeading(context),
        title: Text(
          song.title,
          style: const TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          song.artist,
          style: const TextStyle(fontSize: 14),
        ),
        trailing: trailing ?? _buildTrailing(context),
        selected: isSelected,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!showCoverArt) {
      return null;
    }

    if (song.coverArtPath != null && song.coverArtPath!.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(song.coverArtPath!),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stackTrace) {
              return _buildDefaultLeading(context);
            },
          ),
        );
      } catch (e) {
        return _buildDefaultLeading(context);
      }
    }

    return _buildDefaultLeading(context);
  }

  Widget _buildDefaultLeading(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.music_note,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onGenerateLyrics != null)
          IconButton(
            icon: Icon(Icons.auto_awesome, size: 20, color: Theme.of(context).colorScheme.primary),
            onPressed: onGenerateLyrics,
            tooltip: 'Generate lyrics',
          ),
        if (song.lrcPath != null)
          Icon(Icons.lyrics, size: 20, color: Colors.grey),
        if (song.translationsPath != null)
          Icon(Icons.translate, size: 20, color: Colors.grey),
      ],
    );
  }
}
