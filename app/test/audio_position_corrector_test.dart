import 'package:flutter_test/flutter_test.dart';
import 'package:lingotune/services/audio_position_corrector.dart';

/// Подменные часы: корректор читает время только через [now].
class _FakeClock {
  DateTime _now = DateTime(2026, 1, 1, 12);
  DateTime now() => _now;
  void advanceMs(int ms) => _now = _now.add(Duration(milliseconds: ms));
}

/// Хранилище сырой позиции + helper одного «тика» корректора:
/// wall-clock идет на [clockMs], сырая позиция — на [rawMs].
class _Harness {
  final _FakeClock clock = _FakeClock();
  late final AudioPositionCorrector corrector;
  int rawMs = 0;

  _Harness() {
    corrector = AudioPositionCorrector(clock: clock.now);
  }

  /// Возвращает скорректированную позицию (мс).
  int tick({
    int clockMs = 50,
    int rawMs = 50,
    bool playing = true,
    bool isReady = true,
    double speed = 1.0,
  }) {
    clock.advanceMs(clockMs);
    this.rawMs += rawMs;
    return corrector
        .correct(
          Duration(milliseconds: this.rawMs),
          playing: playing,
          isReady: isReady,
          speed: speed,
        )
        .inMilliseconds;
  }
}

void main() {
  group('AudioPositionCorrector Tests', () {
    test('should return raw position during normal playback', () {
      final h = _Harness();
      // Первый тик — переход pause→play, дальше нормальная игра.
      for (var i = 0; i < 100; i++) {
        final result = h.tick();
        expect(result, h.rawMs, reason: 'tick $i');
      }
    });

    test('should absorb small jitter without switching to wall-clock', () {
      final h = _Harness();
      h.tick();
      // Джиттер доставки событий ±30 мс — все равно возвращаем raw.
      for (var i = 0; i < 100; i++) {
        final result = h.tick(rawMs: i.isEven ? 20 : 80);
        expect(result, h.rawMs, reason: 'tick $i');
      }
    });

    test('should return raw position when paused or buffering', () {
      final h = _Harness();
      h.tick();
      h.tick();
      final paused = h.tick(playing: false);
      expect(paused, h.rawMs);
      final buffering = h.tick(isReady: false);
      expect(buffering, h.rawMs);
      // Возврат к игре — пересинхронизация с raw.
      final resumed = h.tick();
      expect(resumed, h.rawMs);
    });

    test('should trust raw position on backward seek', () {
      final h = _Harness();
      for (var i = 0; i < 50; i++) {
        h.tick();
      }
      final result = h.tick(rawMs: -5000);
      expect(result, h.rawMs);
      // И продолжает играть дальше от новой точки.
      final next = h.tick();
      expect(next, h.rawMs);
    });

    test('should trust raw position on forward seek', () {
      final h = _Harness();
      for (var i = 0; i < 50; i++) {
        h.tick();
      }
      final result = h.tick(rawMs: 5000);
      expect(result, h.rawMs);
    });

    test('should bridge a large one-off event gap and resync to raw', () {
      final h = _Harness();
      for (var i = 0; i < 40; i++) {
        h.tick();
      }
      // Разовый прорыв доставки событий: wall-clock ушел на 1500 мс,
      // сырая позиция продвинулась только на 50. На самом гэпе доверяем
      // wall-clock (интерполяция = raw + 1450)...
      final during = h.tick(clockMs: 1500, rawMs: 50);
      expect(during, h.rawMs + 1450);
      // ...а уже со следующего тика ветка «seek назад» возвращает raw.
      final after = h.tick();
      expect(after, h.rawMs);
      expect(h.tick(), h.rawMs);
    });

    test('should heal a pinned constant lead after the observation window', () {
      final h = _Harness();
      for (var i = 0; i < 40; i++) {
        h.tick();
      }
      // Затык, оставляющий лид ровно в «мёртвой зоне» 500–550 мс:
      // ветка «seek назад» такое не подчищает (строгое неравенство на
      // границе), лид висел бы всю песню — подсветка переключалась бы
      // раньше на ~0.4 с (минус lyricsPositionOffset 0.15 с).
      final leadMs = 530;
      final during = h.tick(clockMs: leadMs + 50, rawMs: 50);
      expect(during, h.rawMs + leadMs);
      // Лид постоянный: внутри окна наблюдения (10 с = 200 тиков) всё ещё
      // ведём raw вперёд...
      for (var i = 0; i < 199; i++) {
        final r = h.tick();
        expect(r, h.rawMs + leadMs, reason: 'tick $i');
      }
      // ...но после окна лид признан артефактом — залечиваемся к raw.
      for (var i = 0; i < 30; i++) {
        final r = h.tick();
        expect(r, h.rawMs, reason: 'after heal tick $i');
      }
    });

    test('should not heal when the lead keeps growing (real drift)', () {
      final h = _Harness();
      for (var i = 0; i < 40; i++) {
        h.tick();
      }
      // Начальный лид в «мёртвой зоне», но сырая позиция продолжает
      // отставать (5 мс за тик): лид растёт, это не постоянный артефакт.
      h.tick(clockMs: 580, rawMs: 50); // лид ~530
      int maxLead = 0;
      for (var i = 0; i < 30; i++) {
        final r = h.tick(rawMs: 45);
        maxLead = (r - h.rawMs) > maxLead ? r - h.rawMs : maxLead;
      }
      // Растущий лид быстро выходит за границу ~545 мс и подчищается
      // веткой «seek назад» — постоянного опережения не остаётся.
      expect(maxLead, lessThanOrEqualTo(560));
      expect(h.tick(rawMs: 45), h.rawMs);
    });

    test('should resync to raw after reset', () {
      final h = _Harness();
      for (var i = 0; i < 40; i++) {
        h.tick();
      }
      h.tick(clockMs: 580, rawMs: 50); // лид ~530, ветка wall-clock
      h.corrector.reset();
      h.rawMs = 250000; // новая песня
      expect(h.tick(), h.rawMs);
    });

    test('should interpolate with playback speed', () {
      final h = _Harness();
      h.tick(speed: 2.0, clockMs: 50, rawMs: 100);
      // При скорости 2x сырая позиция идет вдвое быстрее wall-clock —
      // интерполяция согласована, возвращаем raw.
      for (var i = 0; i < 100; i++) {
        final result = h.tick(speed: 2.0, rawMs: 100);
        expect(result, h.rawMs, reason: 'tick $i');
      }
    });
  });
}
