import 'package:flutter_test/flutter_test.dart';
import 'package:lingotune/services/ab_repeat_controller.dart';

void main() {
  group('AbRepeatController phase', () {
    test('should start idle', () {
      final c = AbRepeatController();
      expect(c.phase, AbRepeatPhase.idle);
      expect(c.isActive, false);
      expect(c.start, isNull);
      expect(c.end, isNull);
    });

    test('first tap marks start A', () {
      final c = AbRepeatController();
      final res = c.tap(const Duration(seconds: 10));
      expect(res, AbMarkResult.startSet);
      expect(c.phase, AbRepeatPhase.startMarked);
      expect(c.start, const Duration(seconds: 10));
      expect(c.end, isNull);
      expect(c.isActive, false);
    });

    test('second tap beyond min segment activates the loop', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      final res = c.tap(const Duration(seconds: 25));
      expect(res, AbMarkResult.endSet);
      expect(c.phase, AbRepeatPhase.active);
      expect(c.isActive, true);
      expect(c.start, const Duration(seconds: 10));
      expect(c.end, const Duration(seconds: 25));
    });

    test('third tap clears the loop', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      c.tap(const Duration(seconds: 25));
      final res = c.tap(const Duration(seconds: 30));
      expect(res, AbMarkResult.cleared);
      expect(c.phase, AbRepeatPhase.idle);
      expect(c.isActive, false);
      expect(c.start, isNull);
      expect(c.end, isNull);
    });
  });

  group('AbRepeatController edge cases', () {
    test('tap B within min segment returns tooShort and keeps A', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      final res = c.tap(const Duration(milliseconds: 10500));
      expect(res, AbMarkResult.tooShort);
      expect(c.phase, AbRepeatPhase.startMarked);
      expect(c.start, const Duration(seconds: 10));
      expect(c.end, isNull);
    });

    test('tap B exactly 1s after A activates (boundary is inclusive)', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      final res = c.tap(const Duration(seconds: 11));
      expect(res, AbMarkResult.endSet);
      expect(c.isActive, true);
    });

    test('tap before A while waiting for B moves A instead of failing', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 30));
      final res = c.tap(const Duration(seconds: 12));
      expect(res, AbMarkResult.startSet);
      expect(c.phase, AbRepeatPhase.startMarked);
      expect(c.start, const Duration(seconds: 12));
      expect(c.end, isNull);
    });

    test('after tooShort the next tap can still set B correctly', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      c.tap(const Duration(seconds: 10, milliseconds: 500)); // tooShort
      final res = c.tap(const Duration(seconds: 40));
      expect(res, AbMarkResult.endSet);
      expect(c.isActive, true);
      expect(c.end, const Duration(seconds: 40));
    });
  });

  group('AbRepeatController shouldLoopBack', () {
    test('false when idle', () {
      final c = AbRepeatController();
      expect(c.shouldLoopBack(const Duration(minutes: 5)), false);
    });

    test('false when only start is marked', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      expect(c.shouldLoopBack(const Duration(minutes: 5)), false);
    });

    test('false before end, true at and after end', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      c.tap(const Duration(seconds: 25));
      expect(c.shouldLoopBack(const Duration(seconds: 20)), false);
      expect(c.shouldLoopBack(const Duration(seconds: 24, milliseconds: 999)),
          false);
      expect(c.shouldLoopBack(const Duration(seconds: 25)), true);
      expect(c.shouldLoopBack(const Duration(seconds: 30)), true);
    });

    test('false after clear', () {
      final c = AbRepeatController();
      c.tap(const Duration(seconds: 10));
      c.tap(const Duration(seconds: 25));
      c.tap(const Duration(seconds: 26)); // clear
      expect(c.shouldLoopBack(const Duration(seconds: 30)), false);
    });

    test('clear notifies listeners only when something was set', () {
      final c = AbRepeatController();
      var notifications = 0;
      c.addListener(() => notifications++);
      c.clear(); // idle — no notification
      expect(notifications, 0);
      c.tap(const Duration(seconds: 1));
      c.clear();
      expect(notifications, 1);
    });
  });
}
