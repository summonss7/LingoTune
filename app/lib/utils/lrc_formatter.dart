class LrcFormatter {
  static String formatTimestamp(double seconds) {
    final minutes = (seconds ~/ 60).toInt();
    final secs = (seconds % 60).toInt();
    final milliseconds = ((seconds % 1) * 1000).round().clamp(0, 999);
    return '${_twoDigits(minutes)}:${_twoDigits(secs)}.${_threeDigits(milliseconds)}';
  }

  static String generateLrcContent(List<dynamic> lines) {
    final buffer = StringBuffer();
    for (final line in lines) {
      final startTime = line.startTime;
      final formattedTime = formatTimestamp(startTime);
      buffer.writeln('[$formattedTime]${line.text}');
    }
    return buffer.toString();
  }

  static String formatDuration(Duration duration) {
    final minutes = _twoDigits(duration.inMinutes.remainder(60));
    final seconds = _twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = duration.inMilliseconds.remainder(1000);
    return '$minutes:$seconds.${_threeDigits(milliseconds)}';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
  static String _threeDigits(int n) => n.toString().padLeft(3, '0');
}
