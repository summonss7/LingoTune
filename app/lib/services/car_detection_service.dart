import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../utils/fft.dart';

/// Уровень уверенности детекции автомобиля.
enum CarDetectionLevel { low, medium, high }

/// Результат одного срабатывания детектора.
class CarDetection {
  final DateTime timestamp;
  final CarDetectionLevel level;
  final double score;
  final SpectrumFeatures features;
  final String reason;

  const CarDetection({
    required this.timestamp,
    required this.level,
    required this.score,
    required this.features,
    required this.reason,
  });

  String get levelLabel => switch (level) {
        CarDetectionLevel.low => 'LOW',
        CarDetectionLevel.medium => 'MED',
        CarDetectionLevel.high => 'HIGH',
      };
}

/// Сервис захвата звука с микрофона и детекции приближающегося автомобиля
/// на основе спектрального анализа (низкочастотный гул двигателя/шин).
///
/// Не использует ML-модель: чистый Dart FFT, поэтому работает на любом
/// устройстве без дополнительных ассетов и не нагружает батарею.
///
/// Слушатели [ChangeNotifier] оповещаются при каждом подтверждённом
/// срабатывании ([lastDetection] обновляется).
class CarDetectionService extends ChangeNotifier {
  static const int _sampleRate = 16000;
  static const int _fftSize = 512; // 32 ms @ 16 kHz
  // A2: hop 512 → анализ каждые 32 мс вместо 16 мс (было 256). Снижает
  // нагрузку на main isolate в ~2 раза, что критично для нормальной работы
  // study-таймеров (segmentTimer 150мс, positionTimer 50мс) и TTS handlers.
  static const int _hopSize = 512;

  // Пороги детекции — НЕ const: настраиваются через [_applySensitivity]
  // в зависимости от значения sensitivity (0..1) из настроек. Раньше были
  // const и sensitivity-слайдер в Настройках вообще ни на что не влиял.
  double _minRms = 0.014;
  double _lowDominanceRatio = 2.0;
  double _scoreThresholdLow = 0.45;
  double _scoreThresholdMedium = 0.6;
  double _scoreThresholdHigh = 0.78;
  // Максимальная плоскостность спектра для детекции машины (ниже → больше
  // «пиков», выше → шум/ветер). Настраивается sensitivity.
  double _maxFlatnessForCar = 0.4;
  // Максимальный спектральный центроид (Гц). Настраивается sensitivity.
  double _maxCentroidHz = 800.0;
  // Фильтр ветра/шагов (A4): если flatness высокая и НЧ доминирование слабое
  // — это шум, а не машина. Если очень громко (rms) и центроид умеренно-низкий
  // — это удар/шаг (например телефон трясётся в кармане при беге).
  static const double _windFlatnessThreshold = 0.35;
  static const double _windLowDomThreshold = 2.0;
  static const double _stepRmsThreshold = 0.08;
  static const double _stepCentroidThreshold = 600.0;

  // Throttle между подтверждёнными срабатываниями (базовый).
  static const Duration _minAlertInterval = Duration(seconds: 2);
  // A5: при активном TTS study mode интервал больше, чтобы не «молотить»
  // alert'ами поверх перевода. Используется только если [isStudySpeaking]
  // колбэк установлен и возвращает true.
  static const Duration _minAlertIntervalDuringStudy = Duration(seconds: 5);

  // Скользящее окно для подтверждения: нужно несколько последовательных
  // срабатываний подряд, чтобы избежать ложных на одиночных всплесках.
  // A2: окно 4 кадра × 32 мс = 128 мс (было 6 × 16 мс = 96 мс).
  static const int _confirmWindow = 4;
  static const int _confirmMinHits = 3;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _streamSub;
  bool _isListening = false;

  late final SpectrumAnalyzer _analyzer;
  final Queue<int> _sampleBuffer = Queue<int>(); // int16 PCM
  final Queue<bool> _confirmQueue = Queue<bool>();
  DateTime? _lastAlertAt;

  CarDetection? _lastDetection;
  CarDetection? get lastDetection => _lastDetection;

  bool _isActive = false;
  bool get isActive => _isActive;

  /// Служебная диагностика для оверлея (последний проанализированный кадр).
  SpectrumFeatures? _lastFeatures;
  SpectrumFeatures? get lastFeatures => _lastFeatures;

  /// Текущая «уверенность» в детекции (0..1), экспоненциально затухает.
  double _currentScore = 0.0;
  double get currentScore => _currentScore;

  String _statusLine = 'idle';
  String get statusLine => _statusLine;

  /// A5: колбэк «сейчас ли звучит TTS study mode». Устанавливается извне
  /// (PlayerScreen-ом), чтобы детектор мог увеличить throttle при активном
  /// переводе и не «молотить» alert'ами поверх речи.
  bool Function()? isStudySpeaking;

  /// Применяет значение sensitivity (0..1) к порогам детекции.
  ///
  /// Карта (линейная интерполяция между крайними значениями):
  /// - sensitivity = 0.0 → очень строгие пороги (мало срабатываний, только
  ///   уверенные близкие машины)
  /// - sensitivity = 0.5 → средние (стартовая рекомендованная)
  /// - sensitivity = 1.0 → мягкие (много срабатываний, возможны ложные)
  void _applySensitivity(double sensitivity) {
    final s = sensitivity.clamp(0.0, 1.0);
    // Вспомогательная линейная интерполяция.
    double lerp(double low, double high) => low + (high - low) * s;
    // Порог score: при sens=0 нужно 0.60, при sens=1 нужно 0.30.
    _scoreThresholdLow = lerp(0.60, 0.30);
    _scoreThresholdMedium = (_scoreThresholdLow + 0.15).clamp(0.0, 1.0);
    _scoreThresholdHigh = (_scoreThresholdLow + 0.32).clamp(0.0, 1.0);
    // НЧ-доминирование: при sens=0 нужно 2.8x, при sens=1 нужно 1.4x.
    _lowDominanceRatio = lerp(2.8, 1.4);
    // Минимальная громкость: при sens=0 нужно 0.020, при sens=1 нужно 0.008.
    _minRms = lerp(0.020, 0.008);
    // Плоскостность: при sens=0 максимум 0.30 (строгий пик), при sens=1
    // максимум 0.50 (терпимее к шуму).
    _maxFlatnessForCar = lerp(0.30, 0.50);
    // Центроид: при sens=0 максимум 600 Гц, при sens=1 максимум 1000 Гц.
    _maxCentroidHz = lerp(600.0, 1000.0);
    debugPrint('🎚 CarDetection: sensitivity=$s → '
        'scoreLow=${_scoreThresholdLow.toStringAsFixed(2)} '
        'lowDom=${_lowDominanceRatio.toStringAsFixed(1)} '
        'rms=${_minRms.toStringAsFixed(3)} '
        'flat=${_maxFlatnessForCar.toStringAsFixed(2)} '
        'cent=${_maxCentroidHz.toStringAsFixed(0)}Hz');
  }

  CarDetectionService() {
    _analyzer = SpectrumAnalyzer(
      fftSize: _fftSize,
      sampleRate: _sampleRate,
      lowBandHi: 300.0,
      midBandHi: 2000.0,
    );
  }

  // ---------------------------------------------------------------------------
  // Запуск / остановка
  // ---------------------------------------------------------------------------

  /// Запрашивает разрешение и запускает захват микрофона + анализ.
  Future<bool> start({double sensitivity = 0.4}) async {
    if (_isActive) return true;
    _statusLine = 'requesting mic';

    // A3: реально применяем sensitivity к порогам — раньше параметр
    // принимался, но ни на что не влиял.
    _applySensitivity(sensitivity);

    try {
      // Используем permission_handler для запроса доступа к микрофону
      // (record 5.x не имеет отдельного метода запроса — только hasPermission).
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
        if (!status.isGranted) {
          _statusLine = 'no permission';
          debugPrint('✗ CarDetection: microphone permission denied');
          return false;
        }
      }

      // ВАЖНО: audioInterruption: none → НЕ запрашивать Android audio focus.
      // Иначе record_android вызывает requestAudioFocus(AUDIOFOCUS_GAIN), что
      // заставляет BackgroundAudioHandler.pause() (через interruptionEventStream)
      // и блокирует TTS study-mode. manageBluetooth: false → не переключать
      // наушники на Bluetooth SCO (ломает A2DP routing). audioManagerMode:
      // modeNormal → НЕ уходить в IN_COMMUNICATION (нарушает TTS).
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        autoGain: false,
        echoCancel: false,
        noiseSuppress: false,
        audioInterruption: AudioInterruptionMode.none,
        androidConfig: AndroidRecordConfig(
          useLegacy: false,
          muteAudio: false,
          manageBluetooth: false,
          audioSource: AndroidAudioSource.mic,
          speakerphone: false,
          audioManagerMode: AudioManagerMode.modeNormal,
        ),
      ));

      _streamSub = stream.listen(_onAudioData, onError: (Object e) {
        debugPrint('✗ CarDetection stream error: $e');
        _statusLine = 'stream err';
      });

      _isActive = true;
      _isListening = true;
      _currentScore = 0.0;
      _sampleBuffer.clear();
      _confirmQueue.clear();
      _statusLine = 'listening';
      debugPrint('✓ CarDetection: started (sensitivity=$sensitivity)');
      notifyListeners();
      return true;
    } on PlatformException catch (e) {
      debugPrint('✗ CarDetection start PlatformException: ${e.code} ${e.message}');
      _statusLine = 'err: ${e.code}';
      return false;
    } catch (e) {
      debugPrint('✗ CarDetection start error: $e');
      _statusLine = 'err';
      return false;
    }
  }

  Future<void> stop() async {
    if (!_isActive) return;
    _isActive = false;
    _isListening = false;
    _statusLine = 'stopped';
    try {
      await _streamSub?.cancel();
    } catch (_) {}
    _streamSub = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    _currentScore = 0.0;
    debugPrint('✓ CarDetection: stopped');
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Обработка аудио
  // ---------------------------------------------------------------------------

  void _onAudioData(Uint8List bytes) {
    if (!_isListening) return;

    // PCM 16-bit LE → int16 samples.
    final int frameCount = bytes.length ~/ 2;
    final ByteData byteData = bytes.buffer.asByteData(bytes.offsetInBytes, frameCount * 2);
    for (int i = 0; i < frameCount; i++) {
      _sampleBuffer.addLast(byteData.getInt16(i * 2, Endian.little));
    }

    // Извлекаем окна фиксированного размера с перекрытием (hop).
    while (_sampleBuffer.length >= _fftSize) {
      // Берём первые _fftSize семплов.
      final Float32List frame = Float32List(_fftSize);
      final Iterator<int> it = _sampleBuffer.iterator;
      for (int i = 0; i < _fftSize && it.moveNext(); i++) {
        frame[i] = it.current / 32768.0;
      }

      _analyzeFrame(frame);

      // Сдвигаем буфер на hopSize (оставляем overlap).
      for (int i = 0; i < _hopSize && _sampleBuffer.isNotEmpty; i++) {
        _sampleBuffer.removeFirst();
      }
    }
  }

  void _analyzeFrame(Float32List frame) {
    final SpectrumFeatures f = _analyzer.analyze(frame);
    _lastFeatures = f;

    // Релаксация текущей уверенности (экспоненциальный спад).
    _currentScore *= 0.85;

    if (f.rms < _minRms) {
      // Тишина — пропускаем, обновляем только диагностику.
      _pushConfirm(false);
      _statusLine = 'silent rms=${(f.rms * 1000).toStringAsFixed(1)}m';
      return;
    }

    // ---- A4: фильтр шума ветра ----
    // Ветер/шорох дают равномерный (высокий flatness) спектр с небольшим
    // уклоном в НЧ. Машина же даёт явный пик в НЧ → низкий flatness И сильное
    // доминирование НЧ над средними. Если flatness высокая и НЧ-доминирование
    // умеренное (< 2× mid) — это шум, а не машина.
    final double lowOverMid =
        f.midBandEnergy > 1e-9 ? f.lowBandEnergy / f.midBandEnergy : 999.0;
    if (f.spectralFlatness > _windFlatnessThreshold &&
        lowOverMid < _windLowDomThreshold) {
      _pushConfirm(false);
      _statusLine = 'wind filt flat=${f.spectralFlatness.toStringAsFixed(2)} '
          'lo/mid=${lowOverMid.toStringAsFixed(1)}';
      return;
    }

    // ---- A4: фильтр шагов/ударов ----
    // Шаги/удары телефона (бег в кармане) дают очень громкий (rms высокий)
    // широкополосный всплеск с умеренно-низким центроидом. Настоящая машина
    // звучит «гулом» с центроидом < 600 Гц. Если очень громко и центроид выше
    // порога — это удар, не машина.
    if (f.rms > _stepRmsThreshold &&
        f.spectralCentroid > _stepCentroidThreshold) {
      _pushConfirm(false);
      _statusLine = 'step filt rms=${(f.rms * 1000).toStringAsFixed(0)}m '
          'cent=${f.spectralCentroid.toStringAsFixed(0)}';
      return;
    }

    // ---- Decision logic ----
    // 1. Доминирование НЧ: low должна быть больше mid и high с запасом.
    final bool lowDom = f.lowBandEnergy > f.midBandEnergy * _lowDominanceRatio &&
        f.lowBandEnergy > f.highBandEnergy * _lowDominanceRatio;

    // 2. Низкий центроид (преобладают НЧ).
    final bool lowCentroid = f.spectralCentroid < _maxCentroidHz;

    // 3. Низкая плоскостность (есть пики, не белый шум/ветер).
    final bool peaked = f.spectralFlatness < _maxFlatnessForCar;

    // Нормированная сила НЧ относительно общего спектра (0..1).
    final double totalE = f.lowBandEnergy + f.midBandEnergy + f.highBandEnergy + 1e-9;
    final double lowFrac = (f.lowBandEnergy / totalE).clamp(0.0, 1.0);

    double score = 0.0;
    final List<String> reasons = <String>[];
    if (lowDom) {
      score += 0.4;
      reasons.add('lowDom');
    }
    if (lowCentroid) {
      score += 0.25;
      reasons.add('lowCentroid');
    }
    if (peaked) {
      score += 0.2;
      reasons.add('peaked');
    }
    score += lowFrac * 0.15; // бонус за высокую долю НЧ
    score = score.clamp(0.0, 1.0);

    final bool isHit = score >= _scoreThresholdLow;
    _pushConfirm(isHit);

    // Текущая «мгновенная» уверенность.
    if (score > _currentScore) {
      _currentScore = score;
    }

    _statusLine = 'score=${score.toStringAsFixed(2)} '
        'low=${(f.lowBandEnergy).toStringAsFixed(0)} '
        'cent=${f.spectralCentroid.toStringAsFixed(0)} '
        'flat=${f.spectralFlatness.toStringAsFixed(2)}';

    // Подтверждение: N срабатываний в окне → триггер.
    if (isHit) {
      _maybeFireAlert(score, f, reasons.join('+'));
    }
  }

  void _pushConfirm(bool hit) {
    _confirmQueue.addLast(hit);
    while (_confirmQueue.length > _confirmWindow) {
      _confirmQueue.removeFirst();
    }
  }

  int get _confirmHits => _confirmQueue.where((h) => h).length;

  void _maybeFireAlert(double score, SpectrumFeatures f, String reason) {
    final bool enoughHits = _confirmHits >= _confirmMinHits;
    if (!enoughHits) return;

    // A5: адаптивный throttle. Если study mode сейчас озвучивает перевод,
    // увеличиваем интервал между alert'ами до 5 сек (вместо 2) — даём
    // переводу говорить, не перебивая каждые 2 сек.
    final bool studySpeaking = isStudySpeaking?.call() ?? false;
    final Duration interval =
        studySpeaking ? _minAlertIntervalDuringStudy : _minAlertInterval;

    final DateTime now = DateTime.now();
    final DateTime? last = _lastAlertAt;
    if (last != null && now.difference(last) < interval) {
      return; // throttle
    }

    _lastAlertAt = now;

    final CarDetectionLevel level;
    if (score >= _scoreThresholdHigh) {
      level = CarDetectionLevel.high;
    } else if (score >= _scoreThresholdMedium) {
      level = CarDetectionLevel.medium;
    } else {
      level = CarDetectionLevel.low;
    }

    _lastDetection = CarDetection(
      timestamp: now,
      level: level,
      score: score,
      features: f,
      reason: reason,
    );

    debugPrint('🚗 CarDetection ALERT: ${level.name} score=${score.toStringAsFixed(2)} '
        'reason=$reason rms=${(f.rms * 1000).toStringAsFixed(1)}m '
        'cent=${f.spectralCentroid.toStringAsFixed(0)}Hz flat=${f.spectralFlatness.toStringAsFixed(2)}');

    // Сбрасываем очередь подтверждения, чтобы следующее срабатывание
    // требовало нового набора попаданий.
    _confirmQueue.clear();

    notifyListeners();
  }

  /// Сериализация последней детекции для диагностического оверлея.
  String debugDump() {
    final f = _lastFeatures;
    final buf = StringBuffer();
    buf.writeln('CAR detect ${_isActive ? "ON" : "OFF"}');
    buf.writeln('status: $_statusLine');
    if (f != null) {
      buf.writeln('low=${f.lowBandEnergy.toStringAsFixed(0)} '
          'mid=${f.midBandEnergy.toStringAsFixed(0)} '
          'hi=${f.highBandEnergy.toStringAsFixed(0)}');
      buf.writeln('centroid=${f.spectralCentroid.toStringAsFixed(0)}Hz '
          'flat=${f.spectralFlatness.toStringAsFixed(2)} '
          'rms=${(f.rms * 1000).toStringAsFixed(1)}m');
    }
    buf.writeln('hits=$_confirmHits/$_confirmWindow score=${_currentScore.toStringAsFixed(2)}');
    final d = _lastDetection;
    if (d != null) {
      buf.writeln('last: ${d.levelLabel} ${d.score.toStringAsFixed(2)} '
          '@${d.timestamp.toIso8601String().substring(11, 19)}');
    }
    return buf.toString().trimRight();
  }
}
