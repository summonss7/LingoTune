/// Корректирует позицию воспроизведения для подсветки строк текста песни,
/// нейтрализуя **линейный дрейф позиции**, характерный для VBR MP3 без
/// Xing/Info-заголовка.
///
/// **Проблема.** ExoPlayer (под капотом `just_audio`) для MP3 без Xing header
/// определяет позицию как `bytes_consumed / битрейт_первого_фрейма` (как будто
/// CBR). На VBR-файлах реальный битрейт к концу трека обычно ниже → позиция
/// **линейно отстаёт** от реального звука → подсветка строк опаздывает, и дрейф
/// растёт со временем. Симптом: «на некоторых песнях подсветка опаздывает,
/// сначала ок, потом глючит».
///
/// **Решение.** Между событиями `_player.positionStream` (~5 раз/сек) позиция
/// интерполируется по **wall-clock времени**: `syncedPos + (now - syncedAt) *
/// speed`. Когда сырая позиция `rawPos` отстаёт от интерполированной больше
/// порога → доверяем wall-clock (нейтрализуем дрейф). Когда `rawPos` скачет
/// вперёд/назад (seek) → доверяем `rawPos`. При паузе/buffering — freeze.
///
/// **Залечивание ложного опережения.** Разовый прорыв доставки событий
/// `positionStream` (загрузка UI-изолирута, TTS-хэндофф audio-session и т.п.)
/// выглядит для корректора как «отставание» raw — он уходит на wall-clock
/// вперёд и раньше возвращался назад только по seek. Если после скачка raw
/// продолжает идти с нормальной скоростью (лид **постоянный**, не растёт) —
/// сырые часы самосогласованы, опережение артефактно, и мы возвращаемся на
/// raw. Настоящий VBR-дрейф отличается тем, что лид **растёт** со временем
/// (≥ ~1 с/мин); такой по-прежнему корректируется wall-clock.
///
/// **Применяется ТОЛЬКО к подсветке строк** (`LyricsService.updatePosition`),
/// не затрагивая slider/индикатор времени (тем остаётся честная `_player.position`).
///
/// Алгоритм устойчив к краевым случаям (см. тест-кейсы в
/// `test/audio_position_corrector_test.dart`).
class AudioPositionCorrector {
  /// Инжектируемый источник времени (для unit-тестов; по умолчанию системный).
  final DateTime Function() _clock;

  /// Последняя «доверенная» позиция (синхронизация).
  Duration _syncedPos = Duration.zero;

  /// Wall-clock момент последней синхронизации.
  DateTime _syncedAt = DateTime.now();

  /// Был ли плеер в состоянии «играет» на прошлом вызове (для детекта
  /// перехода пауза→play, когда надо пересоздать точку синхронизации).
  bool _wasPlaying = false;

  /// Скорость воспроизведения, применённая к wall-clock интерполяции.
  /// 1.0 = реальное время, 0.5 = половина скорости и т.д.
  // ignore: prefer_final_fields
  double _speed = 1.0;

  /// Якорь окна наблюдения за стабильностью лида: значение лида
  /// (interpolated − raw) в момент входа в ветку wall-clock и wall-clock
  /// момент этого входа. `null` — сейчас не в ветке wall-clock.
  int? _leadAnchorMs;
  late DateTime _leadAnchorAt;

  /// Порог расхождения, выше которого решаем кому доверять.
  /// 500 мс — баланс: достаточно велик, чтобы не реагировать на нормальный
  /// джиттер positionStream и небольшие паузы доставки событий; достаточно
  /// мал, чтобы поймать VBR-дрейф раньше, чем он станет заметным (дрейф
  /// ~1с/мин → ловим на ~30-й секунде).
  static const int _thresholdMs = 500;

  /// Окно наблюдения за стабильностью лида: если за это время лид вырос
  /// меньше [_healMaxGrowthMs] — считаем его артефактом и залечиваемся к raw.
  /// Настоящий дрейф ~1 с/мин даёт ~167 мс роста за окно — он не залечивается.
  static const int _healWindowMs = 10000;

  /// Максимальный рост лида за окно, при котором лид считается постоянным
  /// (артефакт разового прорыва событий, а не VBR-дрейф).
  static const int _healMaxGrowthMs = 100;

  AudioPositionCorrector({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  /// Сброс состояния (при смене песни / seek / stop).
  void reset() {
    _syncedPos = Duration.zero;
    _syncedAt = _clock();
    _wasPlaying = false;
    _leadAnchorMs = null;
  }

  /// Принудительно установить точку синхронизации (например, после seek,
  /// когда позиция известна точно).
  void syncTo(Duration pos) {
    _syncedPos = pos;
    _syncedAt = _clock();
    _leadAnchorMs = null;
  }

  /// Вычисляет скорректированную позицию для подсветки строк.
  ///
  /// [rawPos] — позиция из `_player.position` (через `AudioService.position`).
  /// [playing] — `_player.playing`.
  /// [isReady] — `processingState == ProcessingState.ready` (не buffering/idle).
  /// [speed] — текущая скорость воспроизведения.
  ///
  /// Возвращает позицию, которую надо передать в `LyricsService.updatePosition`.
  Duration correct(
    Duration rawPos, {
    required bool playing,
    required bool isReady,
    double speed = 1.0,
  }) {
    _speed = speed;
    final now = _clock();

    // Не играем или буферизируемся — позиция «честная» (заморожена или только
    // что обновлена seek'ом). Сбрасываем точку синхронизации: при следующем
    // play интерполяция стартует с актуального rawPos.
    if (!playing || !isReady) {
      _syncedPos = rawPos;
      _syncedAt = now;
      _wasPlaying = false;
      _leadAnchorMs = null;
      return rawPos;
    }

    // Переход пауза→play: пересоздаём точку синхронизации с текущей позиции.
    // Иначе wall-clock «накрутил бы» время паузы поверх frozen позиции.
    if (!_wasPlaying) {
      _syncedPos = rawPos;
      _syncedAt = now;
      _wasPlaying = true;
      _leadAnchorMs = null;
      return rawPos;
    }

    // Интерполяция по wall-clock (защита от VBR-дрейфа).
    final elapsedMs = now.difference(_syncedAt).inMilliseconds;
    final interpolatedMs =
        _syncedPos.inMilliseconds + (elapsedMs * _speed).round();
    final interpolated = Duration(milliseconds: interpolatedMs);

    final diffMs = interpolated.inMilliseconds - rawPos.inMilliseconds;

    // Seek НАЗАД: rawPos заметно меньше syncPos (пользователь отмотал, либо
    // авто-seek в study mode). Доверяем rawPos.
    if (rawPos.inMilliseconds < _syncedPos.inMilliseconds - _thresholdMs) {
      _syncedPos = rawPos;
      _syncedAt = now;
      _leadAnchorMs = null;
      return rawPos;
    }

    // Seek ВПЕРЁД: rawPos заметно больше интерполированного (перемотка). Доверяем rawPos.
    if (diffMs < -_thresholdMs) {
      _syncedPos = rawPos;
      _syncedAt = now;
      _leadAnchorMs = null;
      return rawPos;
    }

    // VBR-дрейф или короткое buffering: rawPos отстаёт от wall-clock выше
    // порога. Доверяем wall-clock — продолжаем по интерполированной траектории,
    // НЕ подхватывая дрейф. Продвигаем sync по wall-clock.
    if (diffMs > _thresholdMs) {
      // Наблюдаем за стабильностью лида: разовый артефакт (прорыв доставки
      // событий) даёт постоянный лид, настоящий VBR-дрейф — растущий.
      final anchor = _leadAnchorMs;
      if (anchor == null) {
        _leadAnchorMs = diffMs;
        _leadAnchorAt = now;
      } else {
        final growth = diffMs - anchor;
        final windowMs = now.difference(_leadAnchorAt).inMilliseconds;
        if (windowMs >= _healWindowMs && growth.abs() < _healMaxGrowthMs) {
          // Лид постоянный: сырые часы самосогласованы, опережение артефактно.
          // Возвращаемся на raw — подсветка больше не забегает вперёд.
          _syncedPos = rawPos;
          _syncedAt = now;
          _leadAnchorMs = null;
          return rawPos;
        }
        if (growth.abs() >= _healMaxGrowthMs) {
          // Лид растёт — пересоздаём якорь, окно наблюдения начинается заново.
          _leadAnchorMs = diffMs;
          _leadAnchorAt = now;
        }
      }

      _syncedPos = interpolated;
      _syncedAt = now;
      return interpolated;
    }

    // Норма (|diff| <= threshold): периодическая пересинхронизация с rawPos,
    // чтобы компенсировать мелкие отклонения wall-clock (CPU jank и т.п.).
    _syncedPos = rawPos;
    _syncedAt = now;
    _leadAnchorMs = null;
    return rawPos;
  }
}
