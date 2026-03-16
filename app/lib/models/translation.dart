import 'lyric_line.dart';

class Translation {
  final String language;
  final String languageName;
  final List<LyricLine> lines;
  final String? type;
  final String? filePath;

  Translation({
    required this.language,
    required this.languageName,
    required this.lines,
    this.type,
    this.filePath,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      language: json['language'] as String,
      languageName: json['languageName'] as String,
      lines: (json['lines'] as List)
          .map((line) => LyricLine.fromJson(line as Map<String, dynamic>))
          .toList(),
      type: json['type'] as String?,
      filePath: json['filePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'language': language,
      'languageName': languageName,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
    if (type != null) {
      data['type'] = type as String;
    }
    if (filePath != null) {
      data['filePath'] = filePath;
    }
    return data;
  }

  Translation copyWith({
    String? language,
    String? languageName,
    List<LyricLine>? lines,
    String? type,
    String? filePath,
  }) {
    return Translation(
      language: language ?? this.language,
      languageName: languageName ?? this.languageName,
      lines: lines ?? this.lines,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
    );
  }
}
