import 'package:flutter_test/flutter_test.dart';
import 'package:lingotune/utils/lrc_formatter.dart';

void main() {
  group('LrcFormatter.formatDuration', () {
    test('короткая длительность — без часов', () {
      expect(
        LrcFormatter.formatDuration(const Duration(minutes: 3, seconds: 5, milliseconds: 120)),
        '03:05.120',
      );
    });

    test('длительность с часами — добавляет часы', () {
      expect(
        LrcFormatter.formatDuration(const Duration(hours: 2, minutes: 34, seconds: 56, milliseconds: 789)),
        '02:34:56.789',
      );
    });

    test('ровно час — показывает часы', () {
      expect(
        LrcFormatter.formatDuration(const Duration(hours: 1)),
        '01:00:00.000',
      );
    });
  });
}
