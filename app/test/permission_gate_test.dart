import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lingotune/services/permission_gate.dart';

void main() {
  setUp(PermissionGate.debugReset);
  tearDown(PermissionGate.debugReset);

  group('PermissionGate (lingotune-019)', () {
    test('параллельные запросы одного разрешения делят один диалог', () async {
      var nativeCalls = 0;
      final Completer<PermissionStatus> native = Completer<PermissionStatus>();
      PermissionGate.testRequestHandler = (_) async {
        nativeCalls++;
        return native.future;
      };

      final a = PermissionGate.request(Permission.microphone);
      final b = PermissionGate.request(Permission.microphone);
      final c = PermissionGate.request(Permission.microphone);

      native.complete(PermissionStatus.granted);
      final results = await Future.wait([a, b, c]);

      expect(nativeCalls, 1,
          reason: 'три параллельных вызова — один запрос к permission_handler');
      expect(results, everyElement(PermissionStatus.granted));
    });

    test('запросы разных разрешений идут по очереди, не параллельно', () async {
      final order = <String>[];
      final started = <String>[];
      final Completer<void> releaseMic = Completer<void>();

      PermissionGate.testRequestHandler = (p) async {
        final key = p == Permission.microphone ? 'mic' : 'phone';
        started.add(key);
        if (p == Permission.microphone) {
          await releaseMic.future;
        }
        order.add('$key-done');
        return PermissionStatus.granted;
      };

      final mic = PermissionGate.request(Permission.microphone);
      final phone = PermissionGate.request(Permission.phone);
      // Даём обоим запросам стартовать в микротасках.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(started, ['mic'],
          reason: 'phone-запрос не должен стартовать, пока микрофонный живой');

      releaseMic.complete();
      final statuses = await Future.wait([mic, phone]);
      expect(order, ['mic-done', 'phone-done']);
      expect(statuses, everyElement(PermissionStatus.granted));
    });

    test('ошибка запроса не роняет очередь и возвращается как denied',
        () async {
      var calls = 0;
      PermissionGate.testRequestHandler = (p) async {
        calls++;
        if (p == Permission.microphone) {
          throw Exception('permission_handler unavailable');
        }
        return PermissionStatus.granted;
      };

      final mic = await PermissionGate.request(Permission.microphone);
      final phone = await PermissionGate.request(Permission.phone);

      expect(mic, PermissionStatus.denied);
      expect(phone, PermissionStatus.granted,
          reason: 'очередь пережила ошибку предыдущего запроса');
      expect(calls, 2);
    });

    test('после завершения запроса новый вызов идёт заново (не кэш)', () async {
      var nativeCalls = 0;
      PermissionGate.testRequestHandler = (_) async {
        nativeCalls++;
        return PermissionStatus.denied;
      };

      await PermissionGate.request(Permission.microphone);
      await PermissionGate.request(Permission.microphone);

      expect(nativeCalls, 2,
          reason: 'отказ не кэшируется: следующий вызов вправе спросить снова');
    });
  });
}
