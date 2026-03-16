class LyricLine {
  double startTime;
  String text;
  String? translatedText;
  String? transcript;
  double? originalStartTime;

  LyricLine({
    required this.startTime,
    required this.text,
    this.translatedText,
    this.transcript,
    this.originalStartTime,
  });

  factory LyricLine.fromJson(Map<String, dynamic> json) {
    return LyricLine(
      startTime: (json['startTime'] as num).toDouble(),
      text: json['text'] as String,
      translatedText: json['translatedText'] as String?,
      transcript: json['transcript'] as String?,
      originalStartTime: json['originalStartTime'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'text': text,
      'translatedText': translatedText,
      'transcript': transcript,
      'originalStartTime': originalStartTime,
    };
  }

  LyricLine copyWith({
    double? startTime,
    String? text,
    String? translatedText,
    String? transcript,
    double? originalStartTime,
  }) {
    return LyricLine(
      startTime: startTime ?? this.startTime,
      text: text ?? this.text,
      translatedText: translatedText ?? this.translatedText,
      transcript: transcript ?? this.transcript,
      originalStartTime: originalStartTime ?? this.originalStartTime,
    );
  }
}
