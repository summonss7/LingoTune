import 'dart:math';
import 'dart:typed_data';

/// Radix-2 Cooley-Tukey FFT для действительных входных данных (pure Dart).
///
/// Размер [input] должен быть степенью двойки. Используется для спектрального
/// анализа звука с микрофона в [CarDetectionService] — детекция машин по
/// характерному низкочастотному гулу (двигатель, шины).
class Fft {
  /// Выполняет in-place FFT для комплексных данных [real]/[imag].
  /// Длины массивов должны совпадать и быть степенью двойки.
  static void transform(Float64List real, Float64List imag) {
    final int n = real.length;
    assert(n == imag.length);
    assert(_isPowerOfTwo(n));

    // Bit-reversal permutation.
    for (int i = 1, j = 0; i < n; i++) {
      int bit = n >> 1;
      for (; (j & bit) != 0; bit >>= 1) {
        j ^= bit;
      }
      j ^= bit;
      if (i < j) {
        final double tr = real[i];
        real[i] = real[j];
        real[j] = tr;
        final double ti = imag[i];
        imag[i] = imag[j];
        imag[j] = ti;
      }
    }

    // Danielson-Lanczos.
    for (int len = 2; len <= n; len <<= 1) {
      final double ang = -2.0 * pi / len;
      final double wlenR = cos(ang);
      final double wlenI = sin(ang);
      final int half = len >> 1;
      for (int i = 0; i < n; i += len) {
        double wR = 1.0;
        double wI = 0.0;
        for (int k = 0; k < half; k++) {
          final int a = i + k;
          final int b = i + k + half;
          final double uR = real[a];
          final double uI = imag[a];
          final double vR = real[b] * wR - imag[b] * wI;
          final double vI = real[b] * wI + imag[b] * wR;
          real[a] = uR + vR;
          imag[a] = uI + vI;
          real[b] = uR - vR;
          imag[b] = uI - vI;
          final double nwR = wR * wlenR - wI * wlenI;
          wI = wR * wlenI + wI * wlenR;
          wR = nwR;
        }
      }
    }
  }

  /// Окно Хэннинга длиной [n] (смягчает спектральную утечку на краях окна).
  static Float64List hannWindow(int n) {
    final w = Float64List(n);
    for (int i = 0; i < n; i++) {
      w[i] = 0.5 * (1.0 - cos(2.0 * pi * i / (n - 1)));
    }
    return w;
  }

  static bool _isPowerOfTwo(int x) {
    return x > 0 && (x & (x - 1)) == 0;
  }
}

/// Результат спектрального анализа одного окна аудио.
class SpectrumFeatures {
  /// Энергия в низкочастотной полосе [loHz..midHz] (двигатель/шины).
  final double lowBandEnergy;

  /// Энергия в среднечастотной полосе [midHz..hiHz].
  final double midBandEnergy;

  /// Энергия в высокочастотной полосе [hiHz..nyquist].
  final double highBandEnergy;

  /// Спектральный центроид (Гц) — «центр тяжести» спектра.
  /// Низкое значение → преобладают НЧ (машина), высокое → ВЧ (свист/речь).
  final double spectralCentroid;

  /// Спектральная плоскостность (0..1).
  /// Близко к 1 — белый шум/ветер (равномерный спектр).
  /// Близко к 0 — тональный сигнал с пиками (машина, речь, гул).
  final double spectralFlatness;

  /// Общая RMS-энергия сигнала (громкость).
  final double rms;

  const SpectrumFeatures({
    required this.lowBandEnergy,
    required this.midBandEnergy,
    required this.highBandEnergy,
    required this.spectralCentroid,
    required this.spectralFlatness,
    required this.rms,
  });

  @override
  String toString() =>
      'Spectrum(low=${lowBandEnergy.toStringAsFixed(1)}, mid=${midBandEnergy.toStringAsFixed(1)}, '
      'hi=${highBandEnergy.toStringAsFixed(1)}, centroid=${spectralCentroid.toStringAsFixed(0)}Hz, '
      'flat=${spectralFlatness.toStringAsFixed(2)}, rms=${rms.toStringAsFixed(3)})';
}

/// Извлекатель спектральных признаков из PCM-семплов (Float, моно, 16kHz).
class SpectrumAnalyzer {
  final int _fftSize;
  final int _sampleRate;
  late final Float64List _hann;
  late final Float64List _real;
  late final Float64List _imag;
  late final Float64List _mag;

  /// Границы полос частот для детекции машин.
  final double lowBandHi;
  final double midBandHi;

  SpectrumAnalyzer({
    int fftSize = 512,
    int sampleRate = 16000,
    this.lowBandHi = 300.0,
    this.midBandHi = 2000.0,
  })  : _fftSize = fftSize,
        _sampleRate = sampleRate {
    assert(Fft._isPowerOfTwo(_fftSize));
    _hann = Fft.hannWindow(_fftSize);
    _real = Float64List(_fftSize);
    _imag = Float64List(_fftSize);
    _mag = Float64List(_fftSize ~/ 2);
  }

  /// Анализирует окно [samples] длиной [_fftSize].
  /// [samples] — Float-значения амплитуды в диапазоне [-1.0, 1.0].
  SpectrumFeatures analyze(Float32List samples) {
    assert(samples.length == _fftSize);

    // 1. Применяем окно Хэннинга + считаем RMS.
    double sumSq = 0.0;
    for (int i = 0; i < _fftSize; i++) {
      final double s = samples[i] * _hann[i];
      _real[i] = s;
      _imag[i] = 0.0;
      sumSq += samples[i] * samples[i];
    }
    final double rms = sqrt(sumSq / _fftSize);

    // 2. FFT.
    Fft.transform(_real, _imag);

    // 3. Magnitude spectrum (только первая половина — спектр симметричен).
    final int half = _fftSize ~/ 2;
    for (int i = 0; i < half; i++) {
      _mag[i] = sqrt(_real[i] * _real[i] + _imag[i] * _imag[i]);
    }

    // 4. Энергии по полосам частот.
    final double binHz = _sampleRate / _fftSize;
    final int lowBinEnd = (lowBandHi / binHz).round().clamp(1, half);
    final int midBinEnd = (midBandHi / binHz).round().clamp(lowBinEnd + 1, half);

    double lowE = 0.0;
    double midE = 0.0;
    double highE = 0.0;
    double weightedSum = 0.0;
    double totalMag = 0.0;
    double logSum = 0.0;
    int nonZero = 0;

    for (int i = 1; i < half; i++) {
      final double m = _mag[i];
      final double freq = i * binHz;
      if (i < lowBinEnd) {
        lowE += m * m;
      } else if (i < midBinEnd) {
        midE += m * m;
      } else {
        highE += m * m;
      }
      weightedSum += freq * m;
      totalMag += m;
      if (m > 1e-9) {
        logSum += log(m);
        nonZero++;
      }
    }

    final double centroid = totalMag > 0 ? weightedSum / totalMag : 0.0;
    final double flatness = (nonZero > 0 && totalMag > 0)
        ? exp(logSum / nonZero) / (totalMag / nonZero)
        : 1.0;

    return SpectrumFeatures(
      lowBandEnergy: lowE,
      midBandEnergy: midE,
      highBandEnergy: highE,
      spectralCentroid: centroid,
      spectralFlatness: flatness.clamp(0.0, 1.0),
      rms: rms,
    );
  }

  int get fftSize => _fftSize;
  int get sampleRate => _sampleRate;
}
