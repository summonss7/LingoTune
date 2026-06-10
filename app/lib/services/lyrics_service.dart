import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/lyric_line.dart';

class LyricsService extends ChangeNotifier {
  List<LyricLine> _lyricLines = [];
  int _currentIndex = -1;
  double _positionOffset = 0.15;

  List<LyricLine> get lyricLines => _lyricLines;
  int get currentIndex => _currentIndex;
  double get positionOffset => _positionOffset;
  LyricLine? get currentLyric =>
      _currentIndex >= 0 && _currentIndex < _lyricLines.length
          ? _lyricLines[_currentIndex]
          : null;

  Future<void> loadLrcFile(String lrcPath) async {
    try {
      debugPrint('=== DEBUG: Loading LRC ===');
      debugPrint('LRC path: $lrcPath');

      final file = File(lrcPath);
      final exists = await file.exists();
      debugPrint('LRC file exists: $exists');

      if (!exists) {
        debugPrint('ERROR: LRC file not found at path: $lrcPath');
        return;
      }

      debugPrint('Reading LRC file content...');
      final content = await file.readAsString();
      debugPrint('LRC file content length: ${content.length} characters');

      _lyricLines = _parseLrc(content);
      debugPrint('Parsed ${_lyricLines.length} lyric lines');

      if (_lyricLines.isEmpty) {
        debugPrint('WARNING: No lyric lines parsed from LRC file');
      } else {
        debugPrint('First line: "${_lyricLines.first.text}" at ${_lyricLines.first.startTime}s');
        debugPrint('Last line: "${_lyricLines.last.text}" at ${_lyricLines.last.startTime}s');
      }

      _currentIndex = -1;
      notifyListeners();
      debugPrint('LRC loaded successfully, notified listeners');
    } catch (e) {
      debugPrint('=== ERROR: Failed to load LRC file ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  List<LyricLine> _parseLrc(String content) {
    final lines = <LyricLine>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final line in content.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        try {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final milliseconds = match.group(3)!.length == 2
              ? int.parse(match.group(3)!) * 10
              : int.parse(match.group(3)!);

          final startTime = minutes * 60.0 + seconds + milliseconds / 1000.0;
          final text = match.group(4)!.trim();

          if (text.isNotEmpty) {
            lines.add(LyricLine(startTime: startTime, text: text, originalStartTime: startTime));
          }
        } catch (e) {
          debugPrint('Warning: Failed to parse LRC line: $line, Error: $e');
        }
      }
    }

    lines.sort((a, b) => a.startTime.compareTo(b.startTime));
    return lines;
  }

  void setPositionOffset(double offset) {
    _positionOffset = offset.clamp(0.0, 1.0);
  }

  void updatePosition(double position) {
    final adjustedPosition = position - _positionOffset;
    final newIndex = _findCurrentLineIndex(adjustedPosition >= 0 ? adjustedPosition : 0.0);

    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      notifyListeners();
    }
  }

  int _findCurrentLineIndex(double position) {
    if (_lyricLines.isEmpty) {
      return -1;
    }

    int low = 0;
    int high = _lyricLines.length - 1;
    int result = -1;

    while (low <= high) {
      final mid = low + (high - low) ~/ 2;
      final line = _lyricLines[mid];

      if (line.startTime <= position) {
        result = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return result;
  }

  void clear() {
    _lyricLines.clear();
    _currentIndex = -1;
    notifyListeners();
  }

  List<LyricLine> getLinesBeforeIndex(int count) {
    if (_currentIndex < 0) return [];
    final start = (_currentIndex - count).clamp(0, _lyricLines.length);
    return _lyricLines.sublist(start, _currentIndex);
  }

  List<LyricLine> getLinesAfterIndex(int count) {
    if (_currentIndex < 0) return _lyricLines;
    final end = (_currentIndex + count + 1).clamp(0, _lyricLines.length);
    return _lyricLines.sublist(_currentIndex + 1, end);
  }

  void updateLineTimestamp(int index, double newStartTime) {
    if (index >= 0 && index < _lyricLines.length) {
      final line = _lyricLines[index];
      _lyricLines[index] = line.copyWith(
        startTime: newStartTime,
        originalStartTime: line.originalStartTime ?? line.startTime,
      );
      _lyricLines.sort((a, b) => a.startTime.compareTo(b.startTime));
      notifyListeners();
    }
  }

  void updateLineText(int index, String newText) {
    if (index >= 0 && index < _lyricLines.length) {
      _lyricLines[index].text = newText;
      notifyListeners();
    }
  }

  static Future<bool> hasValidTimestamps(String? lrcPath) async {
    if (lrcPath == null) return false;
    
    try {
      final file = File(lrcPath);
      final exists = await file.exists();
      if (!exists) return false;
      
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;
        
        final regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');
        final match = regex.firstMatch(trimmedLine);
        
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          
          if (minutes == 30 && seconds == 0) {
            return false;
          }
          break;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking timestamps validity: $e');
      return true;
    }
  }
}
