import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_gate.dart';

/// Dart-обёртка над нативным анализатором звука (см. `AudioVisualizerPlugin.kt`):
/// MethodChannel `lingotune/audio_visualizer` + EventChannel
/// `lingotune/audio_visualizer/events`.
///
/// Отдаёт поток кадров реального спектра играющей музыки: каждый кадр —
/// `Uint8List` из 32 байт (0..255), логарифмические частотные полосы,
/// ~20 кадров/сек. Используется эквалайзером плеера, чтобы он «танцевал»
/// от настоящей музыки (ритм, такт, громкость), а не от заглушки.
///
/// `start()` сам запрашивает RECORD_AUDIO (через [PermissionGate] — один
/// диалог на все параллельные запросы, lingotune-019). Не Android / нет
/// разрешения / ROM не дал создать Visualizer → `false`, вызывающий
/// остаётся на псевдо-анимации.
class AudioVisualizerService {
  static const MethodChannel _methods =
      MethodChannel('lingotune/audio_visualizer');
  static const EventChannel _events =
      EventChannel('lingotune/audio_visualizer/events');

  AudioVisualizerService._();

  static final AudioVisualizerService instance = AudioVisualizerService._();

  static const int bandCount = 32;

  StreamSubscription<dynamic>? _subscription;

  /// Живой `start()` — параллельные вызовы (два экземпляра эквалайзера,
  /// горячий rebuild) делят один запрос, а не дублируют нативный старт.
  Future<bool>? _starting;

  final StreamController<Uint8List> _barsController =
      StreamController<Uint8List>.broadcast();

  /// Поток кадров спектра (байт 0..255 на полосу).
  Stream<Uint8List> get barStream => _barsController.stream;

  /// Активен ли нативный захват.
  bool get isRunning => _subscription != null;

  /// Запускает захват. `true` — спектр пойдёт в [barStream]. Повторные
  /// (в том числе параллельные) вызовы не плодят запросы разрешений и
  /// нативные старты.
  Future<bool> start() {
    if (_subscription != null) return Future.value(true);
    return _starting ??= _start();
  }

  Future<bool> _start() async {
    try {
      final status = await PermissionGate.request(Permission.microphone);
      if (!status.isGranted) {
        debugPrint(
            '🎚️ AudioVisualizerService: RECORD_AUDIO denied — fallback');
        return false;
      }

      final ok = await _methods.invokeMethod<bool>('start');
      if (ok != true) return false;

      _subscription = _events.receiveBroadcastStream().listen((dynamic frame) {
        if (frame is Uint8List && frame.isNotEmpty) {
          _barsController.add(frame);
        }
      }, onError: (Object error) {
        debugPrint('🎚️ AudioVisualizerService: stream error: $error');
        _subscription?.cancel();
        _subscription = null;
      });
      debugPrint('🎚️ AudioVisualizerService: started (real FFT stream)');
      return true;
    } catch (e) {
      debugPrint('🎚️ AudioVisualizerService: native start failed: $e');
      return false;
    } finally {
      _starting = null;
    }
  }

  /// Останавливает захват (экономит батарею, когда эквалайзер не виден).
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    try {
      unawaited(_methods.invokeMethod<void>('stop'));
    } catch (e) {
      debugPrint('🎚️ AudioVisualizerService: native stop failed: $e');
    }
  }

  void dispose() {
    stop();
    _barsController.close();
  }
}
