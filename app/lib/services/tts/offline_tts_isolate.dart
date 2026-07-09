import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

/// Долгоживущий фоновый изолятор, владеющий нативным [sherpa_onnx.OfflineTts].
///
/// `OfflineTts.generate()` синхронен и может блочить вызвавший изолят на
/// сотни миллисекунд (Piper VITS medium). Если вызывать его в main isolate
/// (study mode озвучивает каждую строку перевода), UI stutter'ит. Этот класс
/// держит модель целиком в воркер-изоляторе: запросы `generate` уходят через
/// [SendPort], воркер синтезирует аудио и возвращает `Float32List` samples.
///
/// Объект `OfflineTts` нельзя пересылать между изолятами — поэтому он
/// создаётся, используется и освобождается строго внутри воркера.
///
/// Все методы безопасны: при любой ошибке/таймауте возвращают «неудачу»
/// (null/false), а [OfflineTtsEngine] откатывается на системный TTS.
class OfflineTtsIsolate {
  Isolate? _isolate;
  ReceivePort? _mainPort;
  SendPort? _toWorker;
  // Подписка на _mainPort. Сохранена в поле, чтобы _cleanup мог её явно
  // отменить — закрытие ReceivePort само по себе не гарантирует синхронную
  // отмену стрима, и пара сообщений могла ещё обработаться.
  StreamSubscription<dynamic>? _mainSub;
  final Map<int, Completer<dynamic>> _pending = {};
  int _nextId = 1;
  bool _starting = false;
  bool _disposed = false;

  /// true если воркер запущен и готов принимать команды.
  bool get isReady => _toWorker != null && !_disposed;

  /// Запускает воркер (lazy, идемпотентно). Возвращает false при провале.
  Future<bool> ensureStarted() async {
    if (_disposed) return false;
    if (_toWorker != null) return true;
    if (_starting) {
      // Кто-то уже стартует — подождём немного.
      for (int i = 0; i < 50 && _starting && _toWorker == null; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      return _toWorker != null;
    }
    _starting = true;
    try {
      final mainPort = ReceivePort();
      final iso = await Isolate.spawn(_offlineTtsWorkerMain, mainPort.sendPort);
      _isolate = iso;
      _mainPort = mainPort;
      final handshake = Completer<SendPort>();
      _mainSub = mainPort.listen((msg) {
        if (msg is SendPort) {
          if (!handshake.isCompleted) handshake.complete(msg);
          return;
        }
        _onMessage(msg);
      });
      _mainSub!.onError((e, st) {
        debugPrint('✗ OfflineTtsIsolate: port stream error: $e');
      });
      _toWorker = await handshake.future
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('worker handshake timeout');
      });
      _starting = false;
      debugPrint('✓ OfflineTtsIsolate: worker started');
      return true;
    } catch (e, st) {
      debugPrint('✗ OfflineTtsIsolate: failed to start: $e\n$st');
      _starting = false;
      _cleanup();
      return false;
    }
  }

  void _onMessage(List<dynamic> msg) {
    if (msg.length < 2) return;
    final evt = msg[0] as int;
    final id = msg[1] as int;
    final c = _pending.remove(id);
    if (c == null) return;
    switch (evt) {
      case _kEvtLoadDone:
        c.complete(_LoadResult(
          ok: msg[2] as bool,
          sampleRate: (msg[3] as num).toInt(),
          error: msg[4] as String?,
        ));
        break;
      case _kEvtGenDone:
        final samples = msg[2];
        c.complete(_GenResult(
          samples: samples is Float32List
              ? samples
              : (samples is List
                  ? Float32List.fromList(
                      (samples).map((e) => (e as num).toDouble()).toList())
                  : Float32List(0)),
          sampleRate: (msg[3] as num).toInt(),
        ));
        break;
      case _kEvtGenErr:
        c.complete(_GenResult(
            samples: null, sampleRate: 0, error: msg[2] as String));
        break;
      case _kEvtFreeDone:
        c.complete(true);
        break;
    }
  }

  /// Загружает модель в воркер (предыдущую выгружает). Возвращает результат.
  Future<_LoadResult> loadModel(
      String modelPath, String tokensPath, String dataDir) async {
    if (!await ensureStarted()) {
      return _LoadResult(ok: false, error: 'isolate not started');
    }
    final id = _nextId++;
    final c = Completer<dynamic>();
    _pending[id] = c;
    _toWorker!.send([_kCmdLoad, id, modelPath, tokensPath, dataDir]);
    try {
      final r = await c.future
          .timeout(const Duration(seconds: 30), onTimeout: () {
        return _LoadResult(ok: false, error: 'loadModel timeout');
      });
      return r as _LoadResult;
    } finally {
      _pending.remove(id);
    }
  }

  /// Синтезирует аудио для [text]. Возвращает samples+sampleRate или null
  /// при ошибке/таймауте.
  ///
  /// [gain] — коэффициент усиления сэмплов поверх пик-нормализации (1.0 = без
  /// доп. буста, только нормализация до ~0.98; >1.0 — буст с клиппингом пиков).
  Future<_GenResult> generate(String text, double speed,
      {double gain = 1.0}) async {
    if (_toWorker == null) {
      return _GenResult(samples: null, sampleRate: 0, error: 'not started');
    }
    final id = _nextId++;
    final c = Completer<dynamic>();
    _pending[id] = c;
    _toWorker!.send([_kCmdGen, id, text, speed, gain]);
    try {
      final r = await c.future
          .timeout(const Duration(seconds: 20), onTimeout: () {
        return _GenResult(samples: null, sampleRate: 0, error: 'generate timeout');
      });
      return r as _GenResult;
    } finally {
      _pending.remove(id);
    }
  }

  /// Выгружает модель в воркере (free).
  Future<void> freeModel() async {
    if (_toWorker == null) return;
    final id = _nextId++;
    final c = Completer<dynamic>();
    _pending[id] = c;
    _toWorker!.send([_kCmdFree, id]);
    try {
      await c.future.timeout(const Duration(seconds: 10));
    } catch (_) {}
    _pending.remove(id);
  }

  /// Останавливает воркер и освобождает ресурсы.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final w = _toWorker;
    if (w != null) {
      try {
        w.send([_kCmdDispose, _nextId++]);
      } catch (_) {}
    }
    // Даём воркеру момент на self-exit, затем принудительно убиваем (на случай
    // если он ждёт чего-то).
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      _cleanup();
    });
  }

  void _cleanup() {
    for (final c in _pending.values) {
      if (!c.isCompleted) {
        c.complete(_GenResult(samples: null, sampleRate: 0, error: 'disposed'));
      }
    }
    _pending.clear();
    _mainSub?.cancel();
    _mainSub = null;
    _mainPort?.close();
    _mainPort = null;
    _isolate?.kill(priority: Isolate.beforeNextEvent);
    _isolate = null;
    _toWorker = null;
  }
}

class _LoadResult {
  final bool ok;
  final int sampleRate;
  final String? error;
  const _LoadResult({required this.ok, this.sampleRate = 0, this.error});
}

class _GenResult {
  final Float32List? samples;
  final int sampleRate;
  final String? error;
  const _GenResult({required this.samples, required this.sampleRate, this.error});
}

// --- Wire protocol op-codes (top-level, доступны воркер-функции) ---
const int _kCmdLoad = 1;
const int _kCmdGen = 2;
const int _kCmdFree = 3;
const int _kCmdDispose = 4;

const int _kEvtLoadDone = 1;
const int _kEvtGenDone = 2;
const int _kEvtGenErr = 3;
const int _kEvtFreeDone = 4;

/// Точка входа воркер-изолятора: создаёт OfflineTts по запросу и синтезирует.
void _offlineTtsWorkerMain(SendPort mainPort) {
  final port = ReceivePort();
  mainPort.send(port.sendPort);

  // Инициализация нативных bindings в этом изоляте (OfflineTts требует).
  try {
    sherpa_onnx.initBindings();
  } catch (_) {
    // Уже инициализировано — норма.
  }

  sherpa_onnx.OfflineTts? tts;

  port.listen((dynamic message) async {
    final list = message as List;
    final cmd = list[0] as int;
    final id = list[1] as int;
    switch (cmd) {
      case _kCmdLoad:
        final modelPath = list[2] as String;
        final tokensPath = list[3] as String;
        final dataDir = list[4] as String;
        try {
          if (tts != null) {
            try {
              tts!.free();
            } catch (_) {}
            tts = null;
          }
          final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
            model: modelPath,
            tokens: tokensPath,
            lexicon: '',
            dataDir: dataDir,
          );
          final modelConfig = sherpa_onnx.OfflineTtsModelConfig(
            vits: vits,
            numThreads: 1,
            debug: false,
            provider: 'cpu',
          );
          final config = sherpa_onnx.OfflineTtsConfig(
            model: modelConfig,
            ruleFsts: '',
            ruleFars: '',
            maxNumSenetences: 1, // API опечатка в sherpa_onnx
            silenceScale: 0.2,
          );
          final loaded = sherpa_onnx.OfflineTts(config);
          tts = loaded;
          mainPort.send([_kEvtLoadDone, id, true, loaded.sampleRate, null]);
        } catch (e, st) {
          mainPort.send([_kEvtLoadDone, id, false, 0, '$e\n$st']);
        }
        break;

      case _kCmdGen:
        final text = list[2] as String;
        final speed = (list[3] as num).toDouble();
        final gain = list.length > 4 ? (list[4] as num).toDouble() : 1.0;
        if (tts == null) {
          mainPort.send([_kEvtGenErr, id, 'model not loaded']);
          break;
        }
        try {
          final audio = tts!.generate(text: text, sid: 0, speed: speed);
          // GeneratedAudio.samples — это Float32List.
          // Пик-нормализация до ~0.98 (сэмплы Piper обычно далеко не на пике →
          // речь тихая) и необязательный буст [gain] (>1.0) с жёстким клиппингом.
          final samples = audio.samples;
          if (samples.isNotEmpty) {
            double peak = 0;
            for (int i = 0; i < samples.length; i++) {
              final a = samples[i].abs();
              if (a > peak) peak = a;
            }
            const double normTarget = 0.98;
            final double normGain =
                peak > 1e-6 ? (normTarget / peak) : 1.0;
            final double totalGain = normGain * gain;
            if (totalGain != 1.0) {
              for (int i = 0; i < samples.length; i++) {
                double v = samples[i] * totalGain;
                if (v > 1.0) {
                  v = 1.0;
                } else if (v < -1.0) {
                  v = -1.0;
                }
                samples[i] = v;
              }
            }
          }
          mainPort.send([_kEvtGenDone, id, samples, audio.sampleRate]);
        } catch (e, st) {
          mainPort.send([_kEvtGenErr, id, '$e\n$st']);
        }
        break;

      case _kCmdFree:
        if (tts != null) {
          try {
            tts!.free();
          } catch (_) {}
          tts = null;
        }
        mainPort.send([_kEvtFreeDone, id]);
        break;

      case _kCmdDispose:
        if (tts != null) {
          try {
            tts!.free();
          } catch (_) {}
          tts = null;
        }
        mainPort.send([_kEvtFreeDone, id]);
        Isolate.exit();
      // ignore: unreachable_from_main
    }
  });
}
