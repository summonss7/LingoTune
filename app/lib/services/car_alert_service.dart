import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import 'car_detection_service.dart';
import 'settings_provider.dart';
import 'tts_coordinator.dart';

/// Сервис выдачи предупреждений при детекции автомобиля.
///
/// Поддерживает три типа предупреждений (включаются в настройках):
/// - 🔊 Звук (короткий beep из ассета `assets/sounds/car_alert.wav`)
/// - 📳 Вибрация (через [HapticFeedback] — без дополнительных пакетов)
/// - 🗣️ Голос (TTS через [FlutterTts], фраза на языке интерфейса)
///
/// Предупреждения буферизуются и не «наезжают» друг на друга: если предыдущее
/// ещё звучит, новое игнорируется до завершения.
class CarAlertService {
  final SettingsProvider _settings;
  final AudioPlayer _beepPlayer = AudioPlayer();
  // Речь идёт через единый TtsCoordinator: не создаём свой FlutterTts,
  // иначе мы перетрём completion-handler study mode и перевод замолкает.
  // Приоритет alert ниже study — если перевод звучит, голосовой alert
  // автоматически пропускается координатором.
  final TtsCoordinator _tts = TtsCoordinator.instance;
  bool _busy = false;
  bool _initialized = false;

  /// Соответствие языка интерфейса → фраза предупреждения.
  static const Map<String, String> _voicePhrases = <String, String>{
    'en': 'Attention, car approaching',
    'ru': 'Внимание, едет машина',
    'ro': 'Atenție, vine o mașină',
    'fr': 'Attention, voiture',
    'de': 'Achtung, Auto',
    'es': 'Atención, coche',
    'it': 'Attenzione, macchina',
    'pt': 'Atenção, carro',
    'zh': '注意，车来了',
    'ar': 'انتبه، سيارة قادمة',
    'uk': 'Увага, їде машина',
  };

  /// Соответствие языка интерфейса → BCP-47 локаль для TTS.
  static const Map<String, String> _voiceLocales = <String, String>{
    'en': 'en-US',
    'ru': 'ru-RU',
    'ro': 'ro-RO',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'es': 'es-ES',
    'it': 'it-IT',
    'pt': 'pt-PT',
    'zh': 'zh-CN',
    'ar': 'ar-SA',
    'uk': 'uk-UA',
  };

  CarAlertService(this._settings);

  /// Инициализация ресурсов. Безопасно вызвать多次.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _beepPlayer.setAsset('assets/sounds/car_alert.wav');
      await _beepPlayer.setVolume(1.0);
      await _beepPlayer.setLoopMode(LoopMode.off);
      debugPrint('✓ CarAlert: beep asset loaded');
    } catch (e) {
      debugPrint('✗ CarAlert beep init: $e');
    }

    // TtsCoordinator лениво инициализируется при первом speak; заранее
    // прогревать его не нужно (и не должно — study mode сам его инициализирует
    // при старте, если активен).
    debugPrint('✓ CarAlert: ready (TTS via shared coordinator)');
  }

  /// Выдаёт предупреждение для [detection], если включены соответствующие
  /// каналы в настройках.
  Future<void> alert(CarDetection detection) async {
    await ensureInitialized();
    if (_busy) return;
    _busy = true;
    try {
      final List<Future<void>> tasks = <Future<void>>[];
      if (_settings.carAlertSound) {
        tasks.add(_playBeep(detection.level));
      }
      if (_settings.carAlertVibration) {
        tasks.add(_vibrate(detection.level));
      }
      if (_settings.carAlertVoice) {
        tasks.add(_speak(detection.level));
      }
      if (tasks.isEmpty) {
        // Хотя бы вибрация по умолчанию, если все каналы выключены —
        // пользователь всё равно должен заметить срабатывание.
        tasks.add(_vibrate(detection.level));
      }
      await Future.wait(tasks);
    } finally {
      _busy = false;
    }
  }

  Future<void> _playBeep(CarDetectionLevel level) async {
    try {
      final int repeat = level == CarDetectionLevel.high
          ? 2
          : level == CarDetectionLevel.medium
              ? 1
              : 1;
      for (int i = 0; i < repeat; i++) {
        await _beepPlayer.seek(Duration.zero);
        await _beepPlayer.play();
        // 0.63s WAV + запас.
        await Future<void>.delayed(const Duration(milliseconds: 700));
      }
    } catch (e) {
      debugPrint('✗ CarAlert beep play: $e');
    }
  }

  Future<void> _vibrate(CarDetectionLevel level) async {
    try {
      await HapticFeedback.heavyImpact();
      if (level == CarDetectionLevel.high) {
        await Future<void>.delayed(const Duration(milliseconds: 180));
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 180));
        await HapticFeedback.heavyImpact();
      } else if (level == CarDetectionLevel.medium) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  Future<void> _speak(CarDetectionLevel level) async {
    try {
      final String lang = _settings.appLanguage;
      final String phrase = _voicePhrases[lang] ?? _voicePhrases['en']!;
      final String locale = _voiceLocales[lang] ?? 'en-US';
      final String text = level == CarDetectionLevel.high ? '$phrase!' : phrase;
      // Приоритет alert: если study mode сейчас озвучивает перевод, координатор
      // пропустит этот запрос немедленно (без прерывания перевода). Future
      // всё равно дождётся реальной речи, если перевод не активен.
      await _tts.speak(
        text,
        priority: TtsPriority.alert,
        locale: locale,
        rate: 0.9,
      );
    } catch (e) {
      debugPrint('✗ CarAlert TTS speak: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _beepPlayer.dispose();
    } catch (_) {}
    // Координатор общий на приложение — НЕ останавливаем его здесь, иначе
    // прервём перевод study mode, если он активен в момент dispose.
  }
}
