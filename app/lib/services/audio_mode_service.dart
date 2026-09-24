import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Режим аудио-линии по `AudioManager.getMode()` (нативный MethodChannel
/// `lingotune/audio_mode`, см. `AudioModePlugin.kt`).
///
/// Зачем: все проверки «идёт ли сейчас звонок» до v5.8.11 опирались на
/// [PhoneCallService] (TelephonyManager, требует READ_PHONE_STATE). Нет
/// разрешения / детектор молча умер / sticky-состояние не пришло — и
/// самолечение залипшей call-паузы (beep уведомления, чей парный end не
/// доставлен) отключалось НАВСЕГДА: watchdog автоперехода реармился вечно,
/// спасал только ручной стоп+плей. `AudioManager.getMode()` не требует
/// разрешений и отвечает в реальном времени: `normal` — звонком линия не
/// занята; `ringtone` / `in_call` / `in_communication` — занята (включая
/// VoIP, который TelephonyManager не видит).
class AudioModeService {
  static const MethodChannel _channel = MethodChannel('lingotune/audio_mode');

  /// TTL кэша ответа: метод дергается из сравнительно горячего пути
  /// (watchdog-тики, play()), а состояние линии за 2 секунды не меняется
  /// настолько, чтобы решение «снимать ли залипшую паузу» стало неверным.
  static const _cacheTtl = Duration(seconds: 2);

  /// Таймаут платформенного вызова: зависший канал не должен блокировать
  /// вызывающих (при таймауте возвращаем null — «неизвестно», вызывающий
  /// трактует консервативно, как будто детектора нет).
  static const _queryTimeout = Duration(seconds: 2);

  AudioModeService._();

  static final AudioModeService instance = AudioModeService._();

  bool? _cachedLineIdle;
  DateTime? _cachedAt;

  /// Последнее известное состояние линии без запроса (null — неизвестно).
  /// Для синхронных путей (дебаунс эха); основной путь — [isLineIdle].
  bool? get lastKnownLineIdle {
    final at = _cachedAt;
    if (at == null) return null;
    if (DateTime.now().difference(at) > _cacheTtl) return null;
    return _cachedLineIdle;
  }

  /// Свободна ли аудио-линия (MODE_NORMAL). `true` — свободна, `false` —
  /// звонок/коммуникация занимает линию, `null` — узнать не удалось
  /// (не Android, канал недоступен/завис): вызывающий НЕ должен снимать
  /// call-паузу по такому ответу.
  Future<bool?> isLineIdle() async {
    final at = _cachedAt;
    if (at != null &&
        DateTime.now().difference(at) <= _cacheTtl &&
        _cachedLineIdle != null) {
      return _cachedLineIdle;
    }
    try {
      final mode = await _channel
          .invokeMethod<String>('getMode')
          .timeout(_queryTimeout);
      if (mode == null) return null;
      final idle = mode == 'normal';
      _cachedLineIdle = idle;
      _cachedAt = DateTime.now();
      return idle;
    } catch (e) {
      // MissingPluginException (не Android / плагин не зарегистрирован),
      // таймаут зависшего канала — трактуем как «неизвестно».
      debugPrint('📞 AudioModeService: getMode failed: $e');
      return null;
    }
  }

  /// Сброс кэша (например, после возобновления приложения из фона —
  /// состояние линии за время простоя могло измениться).
  void invalidateCache() {
    _cachedLineIdle = null;
    _cachedAt = null;
  }
}
