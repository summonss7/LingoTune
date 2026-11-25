import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Единая точка запроса runtime-разрешений (lingotune-019).
///
/// permission_handler на Android кидает `PlatformException(
/// PermissionHandler.PermissionManager, A request for permissions is
/// already running…)`, если один `request()` приходит поверх другого —
/// неважно, какого разрешения. Раньше при открытии плеера их стартовало
/// несколько параллельно: эквалайзер (`AudioVisualizerService.start` →
/// RECORD_AUDIO) и детектор звонка (`_initPhoneCallDetection` →
/// READ_PHONE_STATE) — в logcat падал Unhandled Exception, системный
/// диалог показывался повторно. Все точки запроса идут через
/// [PermissionGate.request]:
///
///  • параллельные запросы одного разрешения присоединяются к живому
///    запросу (один системный диалог на всех);
///  • запросы разных разрешений выстраиваются в очередь — плагин не
///    видит двух `request()` одновременно;
///  • перед диалогом всегда проверяется текущий статус: уже выданное
///    разрешение не переспрашивается.
///
/// Ошибки (нет плагина, платформа не поддерживает) логируются и
/// возвращаются как [PermissionStatus.denied] — вызывающие везде и так
/// трактуют «не выдано» как тихий фолбэк.
class PermissionGate {
  PermissionGate._();

  /// Живые запросы по разрешению: пока будущие выполнено, повторные
  /// вызовы [request] с тем же разрешением получают ЕГО, а не новый
  /// системный диалог.
  static final Map<Permission, Future<PermissionStatus>> _inFlight = {};

  /// Глобальная цепочка: следующий запрос стартует после завершения
  /// предыдущего (успех или ошибка — не важно). Гарантирует, что
  /// permission_handler не увидит двух request() одновременно.
  static Future<void> _chain = Future<void>.value();

  /// Тесты подменяют это поле, чтобы управлять «нативным» ответом и
  /// считать вызовы без плагина. `null` — продакшн-поведение.
  @visibleForTesting
  static Future<PermissionStatus> Function(Permission permission)?
      testRequestHandler;

  /// Возвращает статус разрешения, гарантируя не более одного
  /// системного диалога на вызов: уже выданное — мгновенно,
  /// параллельный запрос того же разрешения — общий результат,
  /// разные разрешения — по очереди.
  static Future<PermissionStatus> request(Permission permission) {
    final inFlight = _inFlight[permission];
    if (inFlight != null) return inFlight;

    final task = _chain.then((_) => _request(permission));
    // Цепочка не должна ломаться ошибкой задачи — очередь продолжается.
    _chain = task.then((_) {}, onError: (Object _) {});
    _inFlight[permission] = task;
    return task;
  }

  static Future<PermissionStatus> _request(Permission permission) async {
    try {
      // Тесты подменяют ВЕСЬ нативный обмен (status + request):
      // без биндинга `permission.status` в unit-тестах падает.
      final handler = testRequestHandler;
      if (handler != null) {
        return await handler(permission);
      }
      var status = await permission.status;
      if (status.isGranted) return status;
      return await permission.request();
    } catch (e) {
      debugPrint('🛡️ PermissionGate($permission): request failed: $e');
      return PermissionStatus.denied;
    } finally {
      _inFlight.remove(permission);
    }
  }

  /// Сброс состояния (только тесты): живые запросы, очередь и хендлер.
  @visibleForTesting
  static void debugReset() {
    _inFlight.clear();
    _chain = Future<void>.value();
    testRequestHandler = null;
  }
}
