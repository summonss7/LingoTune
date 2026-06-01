import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lingotune/models/song.dart';
import 'package:lingotune/services/audio_service.dart';
import 'package:lingotune/models/loop_mode.dart';

class PlayerPlaylistHelper {
  final Random _random = Random();

  void generateShuffledIndices(
    List<Song>? playlistSongs,
    String currentSongId,
    dynamic audioService,
  ) {
    if (playlistSongs == null || playlistSongs!.isEmpty) {
      audioService.setShuffledPlaylist(null);
      return;
    }

    final indices = List.generate(playlistSongs!.length, (i) => i);
    final startIndex = playlistSongs!.indexWhere((s) => s.id == currentSongId);
    
    for (int i = indices.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = indices[i];
      indices[i] = indices[j];
      indices[j] = temp;
    }

    if (startIndex >= 0) {
      indices.removeWhere((index) => index == startIndex);
      indices.insert(0, startIndex);
    }

    audioService.setShuffledPlaylist(indices);
  }

  Future<void> playPreviousSong(
    List<Song>? playlistSongs,
    String currentSongId,
    bool isShuffleEnabled,
    LoopMode loopMode,
    dynamic audioService,
    Function playSong,
  ) async {
    if (playlistSongs == null || playlistSongs!.isEmpty) {
      return;
    }

    final currentIndex = playlistSongs!.indexWhere((s) => s.id == currentSongId);
    if (isShuffleEnabled) {
      final previousIndex = audioService.getPreviousShuffledIndex(currentIndex);
      if (previousIndex != null && previousIndex >= 0 && previousIndex < playlistSongs!.length) {
        await playSong(playlistSongs![previousIndex]);
      }
    } else {
      if (currentIndex > 0 && playlistSongs != null) {
        final previousSong = playlistSongs![currentIndex - 1];
        await playSong(previousSong);
      }
    }
  }

  Future<void> playNextSong(
    List<Song>? playlistSongs,
    String currentSongId,
    bool isShuffleEnabled,
    LoopMode loopMode,
    dynamic audioService,
    Function playSong,
    Function? playNextPlaylist,
  ) async {
    if (playlistSongs == null || playlistSongs!.isEmpty) {
      return;
    }

    final currentIndex = playlistSongs!.indexWhere((s) => s.id == currentSongId);
    
    if (loopMode == LoopMode.one) {
      await audioService.seek(Duration.zero);
      await audioService.play();
      return;
    }

    if (isShuffleEnabled) {
      final totalSongs = playlistSongs!.length;
      final nextIndex = audioService.getNextShuffledIndex(currentIndex, totalSongs);
      if (nextIndex != null && nextIndex >= 0 && nextIndex < playlistSongs!.length) {
        await playSong(playlistSongs![nextIndex]);
      } else if (loopMode == LoopMode.all && audioService.shuffledPlaylist != null && audioService.shuffledPlaylist!.isNotEmpty) {
        await playSong(playlistSongs![audioService.shuffledPlaylist!.first]);
      }
    } else {
      if (currentIndex < playlistSongs!.length - 1) {
        final nextSong = playlistSongs![currentIndex + 1];
        await playSong(nextSong);
      } else if (loopMode == LoopMode.all && playlistSongs!.isNotEmpty) {
        await playSong(playlistSongs!.first);
      } else if (loopMode == LoopMode.allPlaylists && playNextPlaylist != null) {
        await playNextPlaylist();
      }
    }
  }

  bool canPlayPrevious(
    List<Song>? playlistSongs,
    String currentSongId,
    bool isShuffleEnabled,
    LoopMode loopMode,
  ) {
    if (playlistSongs == null || playlistSongs!.isEmpty) {
      return false;
    }
    final currentIndex = playlistSongs!.indexWhere((s) => s.id == currentSongId);
    if (isShuffleEnabled || loopMode == LoopMode.all) {
      return true;
    }
    return currentIndex > 0;
  }

  bool canPlayNext(
    List<Song>? playlistSongs,
    String currentSongId,
    bool isShuffleEnabled,
    LoopMode loopMode,
  ) {
    if (playlistSongs == null || playlistSongs!.isEmpty) {
      return false;
    }
    if (loopMode == LoopMode.one || loopMode == LoopMode.all || loopMode == LoopMode.allPlaylists) {
      return true;
    }
    if (isShuffleEnabled) {
      return true;
    }
    final currentIndex = playlistSongs!.indexWhere((s) => s.id == currentSongId);
    return currentIndex >= 0 && currentIndex < playlistSongs!.length - 1;
  }
}
