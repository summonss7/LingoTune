import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;

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
class OfflineTtsEngine extends TtsEngine {
  sherpa_onnx.OfflineTts? _tts;

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
    if (!_langAvailable || _tts == null) {
      return _fallback.speak(text, rate: rate, pitch: pitch, volume: volume);
    }

    // Останавливаем любой активный play.
    await _stopInternal();

    final sw = Stopwatch()..start();

    // === Generate ===
    sherpa_onnx.GeneratedAudio audio;
    try {
      audio = _tts!.generate(text: text, sid: 0, speed: rate);
    } catch (e, st) {
      debugPrint('✗ OfflineTtsEngine: generate() failed: $e\n$st');
      // Fallback на систему при ошибке генерации.
      return _fallback.speak(text, rate: rate, pitch: pitch, volume: volume);
    }
    sw.stop();
    _genMsValue = sw.elapsedMilliseconds;
    debugPrint(
        '🎤 OfflineTtsEngine: generated ${audio.samples.length} samples '
        '(${_genMsValue}ms, rate=$rate)');

    if (audio.samples.isEmpty) {
      debugPrint('⚠ OfflineTtsEngine: empty samples → fallback');
      return _fallback.speak(text, rate: rate, pitch: pitch, volume: volume);
    }

    // === Write WAV to temp ===
    final tempDir = await getTemporaryDirectory();
    final wavPath = p.join(
        tempDir.path, 'tts_${DateTime.now().microsecondsSinceEpoch}.wav');
    try {
      sherpa_onnx.writeWave(
        filename: wavPath,
        samples: audio.samples,
        sampleRate: audio.sampleRate,
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
      await _player.setFilePath(wavPath);
      await _player.play();
    } catch (e, st) {
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
      await _player.stop();
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

  /// Загружает модель для языка. Возвращает false при ошибке.
  Future<bool> _loadModel(String lang) async {
    try {
      final paths = await TtsModelManager.instance.modelPaths(lang);
      if (paths == null) {
        debugPrint('✗ OfflineTtsEngine: no model paths for $lang');
        return false;
      }
      final vits = sherpa_onnx.OfflineTtsVitsModelConfig(
        model: paths.model,
        tokens: paths.tokens,
        lexicon: '',
        dataDir: paths.dataDir,
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
      _tts = sherpa_onnx.OfflineTts(config);
      debugPrint(
          '✓ OfflineTtsEngine: model loaded for "$lang" (sampleRate=${_tts!.sampleRate})');
      return true;
    } catch (e, st) {
      debugPrint('✗ OfflineTtsEngine: _loadModel($lang) failed: $e\n$st');
      _tts = null;
      return false;
    }
  }

  Future<void> _maybeUnload() async {
    final tts = _tts;
    _tts = null;
    _loadedLang = null;
    if (tts != null) {
      try {
        tts.free();
        debugPrint('🧹 OfflineTtsEngine: model freed');
      } catch (e) {
        debugPrint('⚠ OfflineTtsEngine: free() error: $e');
      }
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
    _stopInternal();
    _maybeUnload();
    _player.dispose();
    _fallback.dispose();
    _isReady = false;
    super.dispose();
  }
}
