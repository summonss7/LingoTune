import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Состояние телефонной линии по данным нативного [TelephonyManager].
enum CallState {
  /// Линия свободна (звонка нет / разговор завершён).
  idle,

  /// Входящий звонок — телефон звонит.
  ringing,

  /// Разговор идёт (трубка снята / исходящий набор).
  offhook,
}

/// Dart-обёртка над нативным EventChannel `lingotune/phone_state`
/// (см. `PhoneCallPlugin.kt`).
///
/// Зачем: на ряде ROM (ColorOS/Realme UI, MIUI/HyperOS, EMUI) системный дакинг
/// медиапотока при звонке выполняется на уровне AudioPolicyManager и НЕ
/// управляется флагом `willPauseWhenDucked` плагина `audio_session`. В итоге
/// `audio_session.interruptionEventStream` либо присылает событие с большой
/// задержкой, либо не присылает вовсе → песня «тихо играет» весь разговор вместо
/// честной паузы. Прямой слушатель `TelephonyManager` срабатывает в момент
/// начала звонка — гарантированно раньше системного дакинга.
///
/// Сервис переиспользуем: подписка [start] устанавливается один раз, отписка —
/// [stop]. На iOS / десктопе EventChannel недоступен → [start] возвращает false
/// (вызывающий грациозно откатывается на `audio_session` interruption-схему).
class PhoneCallService {
  static const EventChannel _channel =
      EventChannel('lingotune/phone_state');

  PhoneCallService._();

  static final PhoneCallService instance = PhoneCallService._();

  StreamSubscription<dynamic>? _subscription;
  final StreamController<CallState> _stateController =
      StreamController<CallState>.broadcast();

  /// Последнее известное состояние линии (обновляется каждым событием
  /// нативного детектора; плагин шлёт sticky-состояние сразу при подписке).
  /// null — событий ещё не было. Используется дебаунсом эха interruption-
  /// событий в BackgroundAudioHandler и проверками «идёт ли звонок сейчас».
  CallState? _current;

  /// Поток состояний звонка. Эмитит `ringing` / `offhook` / `idle`.
  Stream<CallState> get callStates => _stateController.stream;

  /// Текущее состояние линии, или null если детектор ещё не прислал ни одного
  /// события (не запущен / нет permission).
  CallState? get current => _current;

  /// Активна ли подписка на нативный детектор.
  bool get isListening => _subscription != null;

  /// Запускает слушатель. Возвращает `true` при успехе, `false` если платформа
  /// не поддерживается (не Android) или канал недоступен.
  bool start() {
    if (_subscription != null) return true;
    try {
      _subscription = _channel.receiveBroadcastStream().listen(
        (dynamic event) {
          final parsed = _parseState(event);
          if (parsed != null) {
            debugPrint('📞 PhoneCallService: state -> ${parsed.name}');
            _current = parsed;
            _stateController.add(parsed);
          }
        },
        onError: (Object error) {
          // Чаще всего — MissingPluginException (не Android) или
          // SecurityException (нет permission). Логируем и останавливаем
          // подписку; вызывающий откатывается на audio-focus схему.
          debugPrint('📞 PhoneCallService: stream error: $error');
          _subscription?.cancel();
          _subscription = null;
        },
      );
      debugPrint('📞 PhoneCallService: started (native listener active)');
      return true;
    } catch (e) {
      debugPrint('📞 PhoneCallService: failed to start: $e');
      return false;
    }
  }

  /// Останавливает слушатель (например, в dispose экрана-владельца).
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    debugPrint('📞 PhoneCallService: stopped');
  }

  CallState? _parseState(dynamic event) {
    if (event is! String) return null;
    switch (event) {
      case 'ringing':
        return CallState.ringing;
      case 'offhook':
        return CallState.offhook;
      case 'idle':
        return CallState.idle;
      default:
        return null;
    }
  }

  void dispose() {
    stop();
    _stateController.close();
  }
}
