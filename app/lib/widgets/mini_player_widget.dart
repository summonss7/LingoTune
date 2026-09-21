import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/cover_art_service.dart';
import '../theme/app_gradients.dart';

class MiniPlayerWidget extends StatelessWidget {
  final AudioService audioService;
  final VoidCallback onTap;
  final VoidCallback? onPlayPause;

  const MiniPlayerWidget({
    super.key,
    required this.audioService,
    required this.onTap,
    this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final song = audioService.currentSong;
    if (song == null || !audioService.hasActiveSong) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // «Аметист»: мини-плеер — градиентная карточка темнее фона.
    final skinCard = amethystCardDecoration(context, radius: 16);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: skinCard ??
            BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: CoverArtService.buildCoverArtWidget(
                  title: song.title,
                  coverArtPath: song.coverArtPath,
                  coverArtVersion: song.coverArtVersion,
                  size: 36,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              _buildPositionIndicator(colorScheme),
              const SizedBox(width: 4),
              _buildPlayPauseButton(colorScheme),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionIndicator(ColorScheme colorScheme) {
    return StreamBuilder<Duration>(
      stream: audioService.player.positionStream,
      builder: (context, positionSnapshot) {
        return StreamBuilder<Duration?>(
          stream: audioService.player.durationStream,
          builder: (context, durationSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final duration = durationSnapshot.data ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;
            return SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 2.5,
                backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlayPauseButton(ColorScheme colorScheme) {
    return StreamBuilder<bool>(
      stream: audioService.player.playingStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        if (isLoading) {
          return SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.circle,
                size: 12,
                color: colorScheme.onSecondaryContainer.withOpacity(0.3),
              ),
            ),
          );
        }

        return SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            onPressed: onPlayPause,
            padding: EdgeInsets.zero,
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: colorScheme.onSecondaryContainer,
              size: 22,
            ),
          ),
        );
      },
    );
  }
}
