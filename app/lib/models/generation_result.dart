import '../models/lyric_line.dart';

class GenerationResult {
  final String songId;
  final String songTitle;
  final Map<String, List<LyricLine>> translations;
  final List<String> errors;
  final int successCount;
  final int errorCount;
  final Duration duration;
  final bool completed;

  GenerationResult({
    required this.songId,
    required this.songTitle,
    required this.translations,
    required this.errors,
    required this.successCount,
    required this.errorCount,
    required this.duration,
    this.completed = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'songId': songId,
      'songTitle': songTitle,
      'translations': translations.map((key, value) => MapEntry(key, value.map((line) => line.toJson()).toList())),
      'errors': errors,
      'successCount': successCount,
      'errorCount': errorCount,
      'durationMs': duration.inMilliseconds,
      'completed': completed,
    };
  }

  GenerationResult copyWith({
    String? songId,
    String? songTitle,
    Map<String, List<LyricLine>>? translations,
    List<String>? errors,
    int? successCount,
    int? errorCount,
    Duration? duration,
    bool? completed,
  }) {
    return GenerationResult(
      songId: songId ?? this.songId,
      songTitle: songTitle ?? this.songTitle,
      translations: translations ?? this.translations,
      errors: errors ?? this.errors,
      successCount: successCount ?? this.successCount,
      errorCount: errorCount ?? this.errorCount,
      duration: duration ?? this.duration,
      completed: completed ?? this.completed,
    );
  }

  static GenerationResult empty(String songId, String songTitle) {
    return GenerationResult(
      songId: songId,
      songTitle: songTitle,
      translations: {},
      errors: [],
      successCount: 0,
      errorCount: 0,
      duration: Duration.zero,
      completed: false,
    );
  }
}
