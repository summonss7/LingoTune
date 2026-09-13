import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

import 'offline_tts_isolate.dart';
import 'tts_catalog.dart';
import 'tts_engine.dart';
import 'tts_model_manager.dart';
import 'system_tts_engine.dart';

/// Офлайн-нейро TTS на `sherpa_onnx` (Piper VITS).
///
/// Поток (по плану v5.5.0 §3):
///   1. Убеждается, что модель текущего языка загружена (lazy; одна модель в
///      RAM — при смене языка предыдущая выгружается через `free()`).
///   2. `_tts.generate(text, sid:0, speed: rate)` → `GeneratedAudio` (CPU).
///   3. `sherpa_onnx.writeWave(tempWav, samples, sampleRate)`.
///   4. `_player.setFilePath(tempWav)` → `_player.play()` → ждём
///      `processingState.completed` → Completer.complete().
///   5. Удаляем temp WAV.
///
/// **Fallback на систему**: для языков без Piper-модели (uk/zh/ar/ja/ko и
/// любые языки, для которых модель не установлена) делегирует во внутренний
/// [SystemTtsEngine]. Это обеспечивает:
///   - alert детекции машин на appLanguage=uk → система (модели uk нет);
///   - плавный переход: если пользователь переключил язык перевода на язык
///     без модели — продолжит озвучку через систему без вылета.
///
/// **Аудиосессия**: TTS играет на **втором** `AudioPlayer` (песня — на
/// отдельном плеере `AudioService`). Оба в `just_audio` → одна сессия,
/// минимум арбитража фокуса. Для translationFirst/originalFirst песня
/// ставится на паузу → TTS-плеер играет в той же сессии. Для overlay —
/// песня ducked (`setVolume(0.3)`) + TTS одновременно.
///
/// **Синтез в изоляторе**: тяжёлая `OfflineTts.generate()` (CPU, сотни мс)
/// выполняется в долгоживущем воркер-изоляторе [OfflineTtsIsolate], чтобы
/// не морозить main/UI изолят. WAV пишется и играется уже в main.
class OfflineTtsEngine extends TtsEngine {
  /// Воркер-изолятор, владеющий нативной OfflineTts и синтезирующий аудио.
  final OfflineTtsIsolate _isolate = OfflineTtsIsolate();

  /// Какой язык сейчас загружен в [_tts] (например 'ru'). null = модель не
  /// загружена (тогда speak идёт в [_fallback]).
  String? _loadedLang;

  /// Текущий целевой язык (последний setLanguage). Используется для решения
  /// грузить модель / fallback.
  String _curLang = 'ru';

  bool _isReady = false;
  bool _langAvailable = false;
  int _genMsValue = 0;

  /// Второй AudioPlayer для TTS-WAV. Создаётся один раз, переиспользуется.
  final AudioPlayer _player = AudioPlayer();

  /// Stream-sub на playback-completed. Хранится, чтобы stop() мог его отменить.
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  Completer<void>? _playCompleter;
  String? _curWavPath;
  bool _disposed = false;

  /// Внутренний системный fallback (для языков без модели и для alert'ов).
  final SystemTtsEngine _fallback = SystemTtsEngine();

  // Кеш для геттеров при fallback — пробрасываем из _fallback.
  // (когда _langAvailable=false, диагностика отдаётся от системы).
  OfflineTtsEngine();

  @override
  bool get isReady => _isReady;

  @override
  bool get isLanguageAvailable => _langAvailable || _fallback.isLanguageAvailable;

  @override
  String? get activeEngine => _langAvailable
      ? 'sherpa_onnx (offline)'
      : _fallback.activeEngine;

  @override
  String? get selectedEngine =>
      _langAvailable ? 'sherpa_onnx' : _fallback.selectedEngine;

  @override
  List<String> get availableEngines =>
      _langAvailable ? const ['sherpa_onnx'] : _fallback.availableEngines;

  @override
  int get lastGenerationMs => _genMsValue;

  @override
  TtsSource get source => TtsSource.offline;

  /// Идемпотентная инициализация. Вызывает sherpa_onnx.initBindings() один
  /// раз за жизнь процесса.
  @override
  Future<void> initialize() async {
    if (_isReady) return;
    try {
      sherpa_onnx.initBindings();
      debugPrint('✓ OfflineTtsEngine: sherpa_onnx bindings initialized');
    } catch (e, st) {
      // Если bindings уже были инициализированы — это норма, не ошибка.
      debugPrint('⚠ OfflineTtsEngine: initBindings (may be already inited): $e');
    }
    _isReady = true;
    notifyListeners();
  }

  /// Настраивает движок на язык перевода. Если для языка есть установленная
  /// Piper-модель — загружает её (выгрузив предыдущую). Иначе —
  /// делегирует в [_fallback] (системный TTS).
  @override
  Future<void> setLanguage(String languageCode) async {
    if (!_isReady) await initialize();

    final lang = _normalizeLang(languageCode);
    _curLang = lang;
    debugPrint('🗣 OfflineTtsEngine: setLanguage($languageCode → $lang)');

    // Если язык не поддерживается каталогом — сразу fallback.
    if (!TtsCatalog.isSupported(lang)) {
      debugPrint(
          '↩ OfflineTtsEngine: no Piper model for "$lang" → system fallback');
      await _maybeUnload();
      _langAvailable = false;
      await _fallback.setLanguage(languageCode);
      notifyListeners();
      return;
    }

    // Проверяем установлена ли модель.
    final installed = await TtsModelManager.instance.isInstalled(lang);
    if (!installed) {
      // Если это bundled-язык (ru) — попробуем автоматически распаковать.
      final voice = TtsCatalog.forLanguage(lang);
      if (voice != null && voice.bundled) {
        debugPrint('📦 OfflineTtsEngine: auto-extracting bundled $lang...');
        final ok = await TtsModelManager.instance.ensureBundledInstalled(lang);
        if (!ok) {
          debugPrint(
              '↩ OfflineTtsEngine: bundled extract failed for "$lang" → fallback');
          _langAvailable = false;
          await _fallback.setLanguage(languageCode);
          notifyListeners();
          return;
        }
      } else {
        debugPrint(
            '↩ OfflineTtsEngine: model not installed for "$lang" → fallback');
        _langAvailable = false;
        await _fallback.setLanguage(languageCode);
        notifyListeners();
        return;
      }
    }

    // Грузим модель (если другая).
    if (_loadedLang != lang) {
      await _maybeUnload();
      final loaded = await _loadModel(lang);
      if (!loaded) {
        debugPrint(
            '↩ OfflineTtsEngine: model load failed for "$lang" → fallback');
        _langAvailable = false;
        await _fallback.setLanguage(languageCode);
        notifyListeners();
        return;
      }
      _loadedLang = lang;
    }
    _langAvailable = true;
    debugPrint('✓ OfflineTtsEngine: ready for "$lang" (model loaded)');
    notifyListeners();
  }

  /// Генерация + проигрывание. Использует модель если [_langAvailable],
  /// иначе делегирует в [_fallback].
  @override
  Future<void> speak(
    String text, {
    required double rate,
    double? pitch,
    double? volume,
  }) async {
    if (!_isReady) await initialize();
    if (text.trim().isEmpty) return;

    // Если модель не активна — fallback на систему.
    if (!_langAvailable) {
      return _fallback.speak(text, rate: rate, pitch: pitch, volume: volume);
    }

    // Останавливаем любой активный play.
    await _stopInternal();

    final sw = Stopwatch()..start();

    // Громкость речи V (0.0–3.0): часть до 1.0 → setVolume плеера, всё что
    // выше 1.0 → буст сэмплов (gain) в воркере, т.к. setVolume ограничен 1.0.
    final double v = volume ?? 1.0;
    final double playerVol = v < 1.0 ? v : 1.0;
    final double gain = v > 1.0 ? v : 1.0;

    // === Generate (в фоновом изоляторе, main не блочится) ===
    final gen = await _isolate.generate(text, rate, gain: gain);
    sw.stop();
    _genMsValue = sw.elapsedMilliseconds;

    if (gen.samples == null || gen.samples!.isEmpty) {
      debugPrint(
          '⚠ OfflineTtsEngine: generate failed/empty (${gen.error}) → fallback (${_genMsValue}ms)');
      return _fallback.speak(text, rate: rate, pitch: pitch, volume: volume);
    }
    final Float32List samples = gen.samples!;
    final int sampleRate = gen.sampleRate;
    debugPrint(
        '🎤 OfflineTtsEngine: generated ${samples.length} samples '
        '(${_genMsValue}ms, rate=$rate)');

    // === Write WAV to temp ===
    final tempDir = await getTemporaryDirectory();
    final wavPath = p.join(
        tempDir.path, 'tts_${DateTime.now().microsecondsSinceEpoch}.wav');
    try {
      sherpa_onnx.writeWave(
        filename: wavPath,
        samples: samples,
        sampleRate: sampleRate,
      );
    } catch (e, st) {
      debugPrint('✗ OfflineTtsEngine: writeWave() failed: $e\n$st');
      try {
        final f = File(wavPath);
        if (await f.exists()) await f.delete();
      } catch (_) {}
      return _fallback.speak(text, rate: rate, pitch: pitch, volume: volume);
    }
    _curWavPath = wavPath;

    // === Play ===
    final completer = Completer<void>();
    _playCompleter = completer;

    _stateSub = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onPlaybackDone();
      }
    });
    _positionSub = _player.positionStream.listen((_) {});

    try {
      // Реактивируем аудиосессию: после телефонного звонка (или TTS-хендоффа)
      // сессия деактивирована, и just_audio-фьючерсы (setFilePath/play) могут
      // висеть вечно — тот же zombie-паттерн, что и в
      // StudyModeService._kickPlaybackAsync / AudioService.ensurePlaybackAdvancing.
      try {
        final session = await AudioSession.instance;
        await session.setActive(true).timeout(const Duration(seconds: 1));
      } catch (_) {}
      await _player
          .setFilePath(wavPath)
          .timeout(const Duration(seconds: 3), onTimeout: () {
        throw TimeoutException('OfflineTtsEngine: setFilePath hung');
      });
      // Громкость сгенерированной речи. setVolume ограничен 1.0; всё что выше
      // уже заложено в сэмплах через gain (нормализация + буст).
      try {
        await _player.setVolume(playerVol.clamp(0.0, 1.0));
      } catch (_) {}
      // ВАЖНО: Future play() в just_audio завершается НЕ при старте
      // воспроизведения, а когда оно ЗАКОНЧИЛОСЬ/поставлено на паузу. Поэтому
      // таймаут здесь — норма («фраза ещё говорит»), а НЕ сбой: его нужно
      // проглотить и НЕ трогать плеер, иначе речь обрывалась бы через секунду
      // (регрессия v5.8.1). Завершение фразы приходит через playerStateStream
      // → _onPlaybackDone; истинный завис ловит study-watchdog (streak-политика
      // v5.8.1 — максимум одна потерянная строка, без отключения TTS).
      try {
        await _player.play().timeout(const Duration(seconds: 1));
      } on TimeoutException {
        // Ещё играет — так и должно быть.
      }
    } catch (e, st) {
      // Реальная ошибка загрузки/старта (в т.ч. таймаут setFilePath):
      // развязываем completer и чистим плеер/WAV, чтобы TtsCoordinator.speak
      // не завис навсегда.
      debugPrint('✗ OfflineTtsEngine: play() failed: $e\n$st');
      _onPlaybackDone();
    }
    return completer.future;
  }

  void _onPlaybackDone() {
    final c = _playCompleter;
    _playCompleter = null;
    _stateSub?.cancel();
    _stateSub = null;
    _positionSub?.cancel();
    _positionSub = null;
    // Чистим WAV.
    final path = _curWavPath;
    _curWavPath = null;
    if (path != null) {
      File(path).delete().catchError((_) => File(path));
    }
    // Сбрасываем плеер для следующего play.
    _player.stop().catchError((_) {});
    if (c != null && !c.isCompleted) c.complete();
  }

  Future<void> _stopInternal() async {
    final c = _playCompleter;
    _playCompleter = null;
    _stateSub?.cancel();
    _stateSub = null;
    _positionSub?.cancel();
    _positionSub = null;
    final path = _curWavPath;
    _curWavPath = null;
    if (path != null) {
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    try {
      // Таймаут обязателен (v5.8.5): у зомби-плеера (после потери аудиофокуса)
      // stop() может не разрешиться никогда — тогда виснет TtsCoordinator.
      // _interruptCurrent, и КАЖДЫЙ следующий speak зависает ещё до движка
      // (гарантированный watchdog-timeout и глушение речи до конца песни).
      // Следующий speak всё равно пересоздаст источник через setFilePath.
      await _player.stop().timeout(const Duration(seconds: 2));
    } catch (_) {}
    if (c != null && !c.isCompleted) c.complete();
  }

  @override
  Future<void> stop() async {
    await _stopInternal();
    await _fallback.stop();
  }

  @override
  Future<void> applyConfiguredEngine() async {
    // Для офлайна не применимо — движок фиксирован. Но fallback может
    // применить свой engine (для согласованности при переключении источника).
    await _fallback.applyConfiguredEngine();
  }

  // -------------------------------------------------------------------
  // Загрузка/выгрузка моделей (lazy, одна модель в RAM)
  // -------------------------------------------------------------------

  /// Загружает модель для языка в воркер-изоляторе. Возвращает false при ошибке.
  Future<bool> _loadModel(String lang) async {
    try {
      final paths = await TtsModelManager.instance.modelPaths(lang);
      if (paths == null) {
        debugPrint('✗ OfflineTtsEngine: no model paths for $lang');
        return false;
      }
      final res =
          await _isolate.loadModel(paths.model, paths.tokens, paths.dataDir);
      if (!res.ok) {
        debugPrint(
            '✗ OfflineTtsEngine: _loadModel($lang) failed in isolate: ${res.error}');
        return false;
      }
      debugPrint(
          '✓ OfflineTtsEngine: model loaded for "$lang" in isolate (sampleRate=${res.sampleRate})');
      return true;
    } catch (e, st) {
      debugPrint('✗ OfflineTtsEngine: _loadModel($lang) failed: $e\n$st');
      return false;
    }
  }

  Future<void> _maybeUnload() async {
    if (_loadedLang != null) {
      await _isolate.freeModel();
      _loadedLang = null;
      debugPrint('🧹 OfflineTtsEngine: model freed (isolate)');
    }
  }

  String _normalizeLang(String code) {
    final lc = code.toLowerCase();
    if (TtsCatalog.isSupported(lc)) return lc;
    final key = lc.split('-').first;
    return key;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    // Сначала останавливаем fallback (complete'ит его _speakCompleter
    // синхронно), иначе _fallback.dispose() оставлял awaiter висеть, если
    // речь шла через систему в момент dispose.
    _fallback.stop();
    _stopInternal();
    _maybeUnload();
    _isolate.dispose();
    _player.dispose();
    _fallback.dispose();
    _isReady = false;
    super.dispose();
  }
}
