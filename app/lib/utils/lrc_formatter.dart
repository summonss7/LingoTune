class LrcFormatter {
  static String formatTimestamp(double seconds) {
    final minutes = (seconds ~/ 60).toInt();
    final secs = (seconds % 60).toInt();
    final milliseconds = ((seconds % 1) * 100).toInt();
    return '${_twoDigits(minutes)}:${_twoDigits(secs)}.${_twoDigits(milliseconds)}';
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
    final milliseconds = (duration.inMilliseconds.remainder(1000) / 10).toInt();
    return '$minutes:$seconds.${_twoDigits(milliseconds)}';
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
