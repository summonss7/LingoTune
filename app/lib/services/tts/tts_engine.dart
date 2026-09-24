import 'package:flutter/foundation.dart';

/// Источник TTS — выбирается пользователем в Настройках.
///
/// 'offline' (дефолт) — встроенный нейро-TTS на sherpa_onnx (Piper VITS).
/// Стабилен на любом устройстве (особенно китайские ROM), не зависит от
/// системного TTS-сервиса. Для языков без модели (uk/zh/ar) автоматически
/// fallback'ает на систему (см. [OfflineTtsEngine]).
///
/// 'system' — системный движок Android (FlutterTts). Поведение идентично
/// версии 5.4.0 (TtsCoordinator с одним FlutterTts + handlers + приоритеты).
enum TtsSource { offline, system }

/// Абстракция над конкретным TTS-движком.
///
/// Реализации:
/// - [SystemTtsEngine] — обёртка над `FlutterTts` (точная копия логики
///   `TtsCoordinator` версии 5.4.0: handlers/engine-config/voice-fallback).
/// - [OfflineTtsEngine] — `sherpa_onnx` (Piper VITS) + второй `AudioPlayer`
///   (just_audio). Для языков без модели делегирует во внутренний
///   `SystemTtsEngine`.
///
/// Геттеры `isLanguageAvailable`, `activeEngine`, ... возвращают значения,
/// актуальные ПОСЛЕ последнего [setLanguage] / [initialize]. speak() resolves
/// по завершению речи (для системы — `setCompletionHandler` → completer,
/// для офлайна — `processingState.completed` у AudioPlayer).
abstract class TtsEngine extends ChangeNotifier {
  /// Инициализирован ли движок (после [initialize]).
  bool get isReady;

  /// Доступен ли язык, установленный последним [setLanguage].
  /// Для офлайна = true только если есть установленная модель И она
  /// поддерживает этот язык (иначе [speak] сделает fallback на систему).
  bool get isLanguageAvailable;

  /// Активный движок (для диагностики в overlay):
  /// - SystemTtsEngine: package name (например 'com.google.android.tts').
  /// - OfflineTtsEngine: 'sherpa_onnx (offline)' либо package при fallback.
  String? get activeEngine;

  /// Выбранный пользователем движок (для SystemTtsEngine).
  /// Для OfflineTtsEngine = null (не применимо).
  String? get selectedEngine;

  /// Все движки системы (для SystemTtsEngine).
  /// Для OfflineTtsEngine = const [].
  List<String> get availableEngines;

  /// Время последней генерации речи в миллисекундах.
  /// Для SystemTtsEngine всегда 0 (системный API не сообщает).
  /// Для OfflineTtsEngine — длительность sherpa_onnx.generate() в мс.
  /// Используется для диагностики в overlay (`gen=...ms`).
  int get lastGenerationMs;

  /// Источник, который представляет этот движок.
  TtsSource get source;

  /// Ленивая идемпотентная инициализация. Должна вызываться до первого
  /// speak() / setLanguage(). Повторные вызовы — no-op.
  Future<void> initialize();

  /// Настраивает движок на указанный язык перевода.
  ///
  /// [languageCode] — код из [TranslationService]: 'ru', 'en', 'de', 'trans'
  /// или 'ru-RU' (с локалью). Реализация сама маппит код → нужный формат
  /// (locale для системы, путь к модели для офлайна).
  ///
  /// После завершения геттер [isLanguageAvailable] актуален.
  Future<void> setLanguage(String languageCode);

  /// Произносит [text]. Future завершается, когда речь закончена, либо когда
  /// вызван [stop]. Ошибки движка (v5.8.11) могут ЗАВЕРШАТЬСЯ ОШИБКОЙ —
  /// genuine-сбой (platform-вызов завис/отвергнут, TTS-сервис умер) обязан
  /// доходить до study как НЕУДАЧА: раньше все ошибки проглатывались и
  /// завершались успехом, из-за чего стринг сбоев не рос и перевод после
  /// звонка/уведомления/долгого простоя молчал до конца песни. Наши
  /// собственные stop()-прерывания ошибкой НЕ считаются (см. TtsCoordinator).
  ///
  /// [rate] — скорость речи:
  /// - Для системы: 0.0–1.0+ (FlutterTts.setSpeechRate).
  /// - Для офлайна: 1.0 = норма, < 1.0 медленнее, > 1.0 быстрее (sherpa).
  /// [pitch]/[volume] опциональны; для офлайна игнорируются (pitch нет в
  /// базовом Piper API, volume всегда 1.0 через AudioPlayer).
  Future<void> speak(
    String text, {
    required double rate,
    double? pitch,
    double? volume,
  });

  /// Полная остановка речи. Future завершается, когда движок реально
  /// прекратил воспроизведение. Никогда не кидает.
  Future<void> stop();

  /// Полный пересбор подключения движка (v5.8.11). После долгого простоя
  /// приложения в памяти Android отвязывает системный TTS-сервис: связь
  /// протухает, а ленивый [initialize] (идемпотентный) её не чинит. Вызывается
  /// координатором при провале health-probe. Дефолт — no-op (движки без
  /// протухающего подключения ничего не делают).
  Future<void> reset() async {}

  /// Повторно применяет выбранный в настройках движок.
  /// Для SystemTtsEngine — setEngine на FlutterTts. Для OfflineTtsEngine — no-op.
  Future<void> applyConfiguredEngine();

  /// Освобождает ресурсы (нативная память у sherpa, dispose FlutterTts).
  /// После dispose движок нельзя использовать (создаётся новый instance).
  void dispose();
}
