import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart-обёртка над нативным EventChannel `lingotune/becoming_noisy`
/// (см. `BecomingNoisyPlugin.kt`).
///
/// Зачем: `audio_session.becomingNoisyEventStream` регистрирует нативный
/// receiver на ACTION_AUDIO_BECOMING_NOISY только пока ДЕРЖИТ audio focus —
/// и снимает его при каждой деактивации сессии (TTS-хендофф в режиме
/// обучения, zombie-recovery, звонок). В этих состояниях выдёргивание
/// наушников не доставляет событие в Dart → песня продолжает играть в
/// динамике вместо паузы. Нативный плагин держит receiver независимо от
/// audio focus, пока эта подписка активна.
///
/// Сервис переиспользуем: подписка [start] устанавливается один раз, отписка —
/// [stop]. На iOS / десктопе EventChannel недоступен → [start] возвращает
/// false (вызывающий остаётся на `audio_session.becomingNoisyEventStream`).
class BecomingNoisyService {
  static const EventChannel _channel =
      EventChannel('lingotune/becoming_noisy');

  BecomingNoisyService._();

  static final BecomingNoisyService instance = BecomingNoisyService._();

  StreamSubscription<dynamic>? _subscription;
  final StreamController<void> _noisyController =
      StreamController<void>.broadcast();

  /// Поток событий «наушники отключены» (одно событие на каждое
  /// ACTION_AUDIO_BECOMING_NOISY).
  Stream<void> get noisyEvents => _noisyController.stream;

  /// Активна ли подписка на нативный детектор.
  bool get isListening => _subscription != null;

  /// Запускает слушатель. Возвращает `true` при успехе, `false` если платформа
  /// не поддерживается (не Android) или канал недоступен.
  bool start() {
    if (_subscription != null) return true;
    try {
      _subscription = _channel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event == 'noisy') {
            debugPrint('🎧 BecomingNoisyService: headphones unplugged');
            _noisyController.add(null);
          }
        },
        onError: (Object error) {
          // Чаще всего — MissingPluginException (не Android). Логируем и
          // останавливаем подписку; вызывающий остаётся на audio_session.
          debugPrint('🎧 BecomingNoisyService: stream error: $error');
          _subscription?.cancel();
          _subscription = null;
        },
      );
      debugPrint('🎧 BecomingNoisyService: started (native listener active)');
      return true;
    } catch (e) {
      debugPrint('🎧 BecomingNoisyService: failed to start: $e');
      return false;
    }
  }

  /// Останавливает слушатель (снимает нативный receiver).
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('🎧 BecomingNoisyService: stopped');
  }

  void dispose() {
    stop();
    _noisyController.close();
  }
}
