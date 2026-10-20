import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lingotune/utils/audio_band_processor.dart';

/// Кадр спектра: байты 0..255 на полосу.
Uint8List _frame(List<int> bytes) => Uint8List.fromList(bytes);

void main() {
  group('attack and release', () {
    test('push raises levels instantly to the normalized value', () {
      final p = AudioBandProcessor(bandCount: 8);
      p.push(_frame([255, 0, 0, 0, 0, 0, 0, 0]));
      expect(p.levels[0], greaterThan(0.99));
      expect(p.levels[1], 0);
    });

    test('tick decays levels exponentially toward zero', () {
      final p = AudioBandProcessor(bandCount: 8);
      p.push(_frame([255, 255, 255, 255, 255, 255, 255, 255]));
      final before = p.levels[0];
      p.tick(const Duration(seconds: 10), const Duration(seconds: 10));
      expect(p.levels[0], lessThan(before));
      expect(p.levels[0], lessThan(0.001));
    });

    test('push does not lower a still-high level (max, not assign)', () {
      final p = AudioBandProcessor(bandCount: 8);
      p.push(_frame([255, 0, 0, 0, 0, 0, 0, 0]));
      p.push(_frame([64, 0, 0, 0, 0, 0, 0, 0]));
      expect(p.levels[0], greaterThan(0.99));
    });

    test('shorter frames than bandCount do not throw', () {
      final p = AudioBandProcessor(bandCount: 32);
      p.push(_frame([10, 20, 30]));
      p.tick(const Duration(seconds: 1), const Duration(milliseconds: 16));
      expect(p.levels.length, 32);
    });
  });

  group('peak caps', () {
    test('peaks follow the level up and fall slower than levels', () {
      final p = AudioBandProcessor(bandCount: 8);
      p.push(_frame([255, 255, 255, 255, 255, 255, 255, 255]));
      final peakAtHit = p.peaks[0];
      expect(peakAtHit, greaterThan(0.99));

      // Полсекунды тишины: уровень давно упал, шапка всё ещё заметна.
      for (var i = 0; i < 30; i++) {
        p.tick(Duration(milliseconds: 500 + i * 16),
            const Duration(milliseconds: 16));
      }
      expect(p.levels[0], lessThan(0.05));
      expect(p.peaks[0], greaterThan(p.levels[0]));
    });
  });

  group('beat detection', () {
    test('bass jump triggers beat which then decays', () {
      final p = AudioBandProcessor(bandCount: 16);
      // «Тихий фон»: все полосы низкие — качаем скользящее среднее.
      for (var i = 0; i < 60; i++) {
        p.push(_frame(List.filled(16, 30)));
        p.tick(Duration(milliseconds: i * 50),
            const Duration(milliseconds: 50));
      }
      expect(p.beat, lessThan(0.5));

      // Удар: бас резко вверх.
      p.push(_frame([220, 220, 220, 220, 30, 30, 30, 30, 30, 30, 30, 30, 30,
          30, 30, 30]));
      p.tick(const Duration(seconds: 5), const Duration(milliseconds: 50));
      expect(p.beat, greaterThan(0.9));

      // Через секунду после удара огибающая почти погасла.
      for (var i = 0; i < 20; i++) {
        p.tick(Duration(milliseconds: 5050 + i * 50),
            const Duration(milliseconds: 50));
      }
      expect(p.beat, lessThan(0.1));
    });

    test('refractory: an immediate repeat of the same frame does not '
        're-trigger', () {
      final p = AudioBandProcessor(bandCount: 16);
      // Тихий фон ниже порога срабатывания — прогрев скользящего среднего.
      for (var i = 0; i < 40; i++) {
        p.push(_frame(List.filled(16, 10)));
        p.tick(Duration(milliseconds: i * 25), const Duration(milliseconds: 25));
      }
      expect(p.beat, 0.0);

      final loud = [230, 230, 230, 230, 10, 10, 10, 10, 10, 10, 10, 10, 10,
          10, 10, 10];
      p.push(_frame(loud));
      p.tick(const Duration(seconds: 1), const Duration(milliseconds: 25));
      expect(p.beat, 1.0);

      // Тот же кадр сразу за ударом (25 мс < рефрактерных 220 мс) — бит
      // не «перезажигается», только продолжает гаснуть.
      p.push(_frame(loud));
      p.tick(const Duration(milliseconds: 1025), const Duration(milliseconds: 25));
      expect(p.beat, lessThan(0.95));
    });
  });

  group('adaptive gain', () {
    test('loud material keeps gain at 1x', () {
      final p = AudioBandProcessor(bandCount: 8);
      p.push(_frame([255, 255, 255, 255, 255, 255, 255, 255]));
      expect(p.gain, 1.0);
    });

    test('quiet material is boosted up to 3x', () {
      final p = AudioBandProcessor(bandCount: 8);
      p.push(_frame([51, 51, 51, 51, 51, 51, 51, 51])); // ~0.2 после гаммы
      expect(p.gain, greaterThan(1.0));
      expect(p.gain, lessThanOrEqualTo(3.0));
    });
  });
}
