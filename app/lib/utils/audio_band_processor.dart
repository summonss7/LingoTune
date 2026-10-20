import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Обработка кадров реального спектра (от `AudioVisualizerService`) в
/// картинку эквалайзера: «живые» столбики, которые следуют за музыкой.
///
/// Что делает и зачем:
///  • **Атака/спад**: уровень полосы прыгает вверх мгновенно (удар бочки
///    виден сразу) и спадает экспоненциально (~160 мс) — без «дрожания»
///    между кадрами захвата (~20 Гц).
///  • **Адаптивный гейн**: тихая запись не превращается в «пол»,
///    громкая — в «потолок»: нормируем на скользящий пик композиции
///    (спад ~3 с), гейн ограничен 3x.
///  • **Бит**: энергия нижних полос против скользящего среднего (~2 с);
///    скачок в 1.35x — удар: [beat]=1 и экспоненциально гаснет (~120 мс).
///    Отрисовка использует его для пульсации/свечения в такт.
///  • **Пик-шапки**: [peaks] — медленно падающие метки максимума полосы.
///
/// Чистый Dart без Flutter-зависимостей (кроме foundation) → юнит-тесты
/// (`test/audio_band_processor_test.dart`).
class AudioBandProcessor {
  AudioBandProcessor({
    this.bandCount = AudioBandProcessor.defaultBandCount,
    this.releaseTau = const Duration(milliseconds: 160),
    this.peakFallSpeed = 0.55,
    this.beatTau = const Duration(milliseconds: 120),
  })  : levels = List<double>.filled(bandCount, 0),
        peaks = List<double>.filled(bandCount, 0);

  static const int defaultBandCount = 32;

  /// Сколько полос ожидается в кадре нативного FFT.
  final int bandCount;

  /// Постоянная времени спада столбика.
  final Duration releaseTau;

  /// Скорость падения пик-шапок (долей высоты в секунду).
  final double peakFallSpeed;

  /// Постоянная времени затухания огибающей бита.
  final Duration beatTau;

  /// Сглаженные уровни полос 0..1 (атака мгновенная, спад — [tick]).
  final List<double> levels;

  /// Пик-шапки 0..1 — максимум полосы, медленно сползающий вниз.
  final List<double> peaks;

  /// Огибающая последнего удара: 1 в момент бита, экспоненциальный спад.
  double get beat => _beat;
  double _beat = 0;

  double _runningPeak = 0.35;
  double _bassAverage = 0;
  Duration _lastBeatAt = const Duration(days: -1);
  final Duration _beatRefractory = const Duration(milliseconds: 220);

  /// Принимает кадр спектра (байты 0..255).
  void push(Uint8List frame) {
    final n = math.min(bandCount, frame.length);
    for (var i = 0; i < n; i++) {
      levels[i] = math.max(levels[i], _normalize(frame[i]));
      // Шапка прыгает вместе с ударом сразу, не дожидаясь кадра анимации.
      peaks[i] = math.max(peaks[i], levels[i]);
    }

    // Скользящий пик всей композиции → адаптивный гейн при отрисовке.
    var frameMax = 0.0;
    for (var i = 0; i < n; i++) {
      if (levels[i] > frameMax) frameMax = levels[i];
    }
    _runningPeak = math.max(frameMax, _runningPeak * 0.97);
    _runningPeak = _runningPeak.clamp(0.25, 1.0);
  }

  /// Продвигает анимацию на [dt] (вызывать каждый кадр отрисовки):
  /// спад уровней, падение шапок, затухание бита, скользящие средние.
  void tick(Duration now, Duration dt) {
    final dtSec = dt.inMicroseconds / 1e6;
    if (dtSec <= 0) return;
    final releaseK = math.exp(-dtSec / (releaseTau.inMicroseconds / 1e6));

    var maxLevel = 0.0;
    for (var i = 0; i < bandCount; i++) {
      levels[i] *= releaseK;
      peaks[i] = math.max(levels[i], peaks[i] - peakFallSpeed * dtSec);
      if (levels[i] > maxLevel) maxLevel = levels[i];
    }

    // Бас-энергия: нижние четверть полос (лог-шкала — это примерно до
    // 200–300 Гц: бочка и бас).
    const bassBands = 8;
    var bass = 0.0;
    for (var i = 0; i < math.min(bassBands, bandCount); i++) {
      bass += levels[i];
    }
    bass /= math.min(bassBands, bandCount);

    final bassK = math.exp(-dtSec / 2.0); // окно среднего ~2 с
    _bassAverage = _bassAverage * bassK + bass * (1 - bassK);

    // Назначаем бит ПОСЛЕ затухания этого кадра: в тике, где удар случился,
    // огибающая читается как 1, а не как «уже успевшая погаснуть».
    final sinceBeat = now - _lastBeatAt;
    _beat *= math.exp(-dtSec / (beatTau.inMicroseconds / 1e6));
    if (bass > 0.10 &&
        bass > _bassAverage * 1.35 &&
        sinceBeat > _beatRefractory) {
      _beat = 1;
      _lastBeatAt = now;
    }
  }

  /// Адаптивный гейн для отрисовки: тихому треку добавляет высоты,
  /// громкому не даёт уйти в клиппинг.
  double get gain => (0.9 / _runningPeak).clamp(1.0, 3.0);

  /// Нормировка байта: гамма 0.8 растягивает тихие полосы вверх, чтобы
  /// спектр не выглядел «одной большой левой кочкой».
  double _normalize(int byte) => math.pow(byte / 255, 0.8).toDouble();

  @visibleForTesting
  void debugSetRunningPeak(double value) => _runningPeak = value;
}
