import 'package:flutter/foundation.dart';

/// Фаза работы повтора отрезка (кнопка A–B на панели плеера).
enum AbRepeatPhase {
  /// Точки не выставлены — обычное воспроизведение.
  idle,

  /// Поставлена только точка A (начало); ждём тап для B (конец).
  startMarked,

  /// Обе точки выставлены — отрезок A..B играет по кругу.
  active,
}

/// Результат тапа по кнопке A–B (сообщение SnackBar выбирается по нему).
enum AbMarkResult {
  /// Поставлена (или передвинута) точка A.
  startSet,

  /// Поставлена точка B — повтор отрезка включён.
  endSet,

  /// Тап-B слишком близко к A (меньше минимальной длины отрезка) —
  /// точка A осталась, B нужно ставить дальше.
  tooShort,

  /// Повтор выключен (сброс точек).
  cleared,
}

/// Чистая логика повтора отрезка A–B: конечный автомат точек
/// (idle → A → A..B-цикл → idle) без привязки к плееру. Сравнения позиций
/// и решение «пора ли прыгнуть назад к A» живут здесь и покрываются
/// unit-тестами (`test/ab_repeat_controller_test.dart`); AudioService
/// делегирует сюда и отвечает только за реальный seek.
class AbRepeatController extends ChangeNotifier {
  /// Минимальная длина отрезка: короче нет смысла крутить (и сложно
  /// отличить случайный двойной тап от намерения).
  static const Duration minSegment = Duration(seconds: 1);

  Duration? _start;
  Duration? _end;

  Duration? get start => _start;
  Duration? get end => _end;

  bool get isActive => _start != null && _end != null;

  AbRepeatPhase get phase {
    if (_start != null && _end != null) return AbRepeatPhase.active;
    if (_start != null) return AbRepeatPhase.startMarked;
    return AbRepeatPhase.idle;
  }

  /// Один тап по кнопке A–B: первый тап ставит A, второй — B (включает
  /// цикл), тап при активном цикле — сброс. Тап-B РАНЬШЕ A не ошибка:
  /// точка A переезжает на новую позицию (юзер передумал, где начало).
  AbMarkResult tap(Duration position) {
    if (isActive) {
      clear();
      return AbMarkResult.cleared;
    }
    final s = _start;
    if (s == null || position <= s) {
      _start = position;
      return AbMarkResult.startSet;
    }
    if (position - s < minSegment) {
      return AbMarkResult.tooShort;
    }
    _end = position;
    return AbMarkResult.endSet;
  }

  /// Пора ли прыгнуть назад к A: позиция дошла до B (или перескочила его
  /// после скачка/буферизации). Работает только при активном цикле.
  bool shouldLoopBack(Duration position) =>
      isActive && position >= _end!;

  void clear() {
    if (_start == null && _end == null) return;
    _start = null;
    _end = null;
    notifyListeners();
  }
}
