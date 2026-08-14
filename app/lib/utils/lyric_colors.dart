import 'package:flutter/material.dart';

/// Палитра и пресеты цветов для подсветки строк оригинала/перевода.
///
/// Хранение: цвет сохраняется как `int` (`Color.value`). Сентинель
/// [LyricColorPalette.autoValue] означает «авто» — использовать цвет темы
/// приложения (без пользовательского переопределения).
///
/// Новых зависимостей нет: палитра переиспользует набор Material-цветов,
/// близкий к [ThemeProvider] (`services/theme_provider.dart`).

class LyricColorSwatch {
  final Color color;
  final String nameKey;

  const LyricColorSwatch(this.color, this.nameKey);
}

class LyricColorPalette {
  LyricColorPalette._();

  /// Сентинель «авто»: цвет берётся из темы, переопределения нет.
  static const int autoValue = -1;

  /// Восстанавливает [Color] из сохранённого int-значения.
  /// Возвращает `null` для [autoValue] (→ цвет темы).
  static Color? colorFromValue(int value) =>
      value == autoValue ? null : Color(value);

  /// Палитра свотчей, доступных для ручного выбора каждого типа текста.
  /// Имена цветов локализуются через [nameKey].
  static const List<LyricColorSwatch> swatches = [
    LyricColorSwatch(Color(0xFFE53935), 'lyricColorRed'),
    LyricColorSwatch(Color(0xFFD81B60), 'lyricColorPink'),
    LyricColorSwatch(Color(0xFF8E24AA), 'lyricColorPurple'),
    LyricColorSwatch(Color(0xFF1E88E5), 'lyricColorBlue'),
    LyricColorSwatch(Color(0xFF3949AB), 'lyricColorIndigo'),
    LyricColorSwatch(Color(0xFF00897B), 'lyricColorTeal'),
    LyricColorSwatch(Color(0xFF43A047), 'lyricColorGreen'),
    LyricColorSwatch(Color(0xFFFB8C00), 'lyricColorOrange'),
    LyricColorSwatch(Color(0xFFFDD835), 'lyricColorYellow'),
    LyricColorSwatch(Color(0xFF6D4C41), 'lyricColorBrown'),
    LyricColorSwatch(Color(0xFF455A64), 'lyricColorGrey'),
    LyricColorSwatch(Color(0xFF212121), 'lyricColorBlack'),
    LyricColorSwatch(Color(0xFFFFFFFF), 'lyricColorWhite'),
  ];
}

/// Готовая пара цветов (оригинал + перевод) для быстрого выбора одним тапом.
class LyricColorPreset {
  final String nameKey;
  final int originalValue;
  final int translationValue;

  const LyricColorPreset(this.nameKey, this.originalValue, this.translationValue);
}

class LyricColorPresets {
  LyricColorPresets._();

  static const List<LyricColorPreset> all = [
    // «Авто»: цвет темы приложения (переопределения нет).
    LyricColorPreset('lyricPresetDefault',
        LyricColorPalette.autoValue, LyricColorPalette.autoValue),
    LyricColorPreset('lyricPresetBlueRed', 0xFF1E88E5, 0xFFE53935),
    LyricColorPreset('lyricPresetRedBlue', 0xFFE53935, 0xFF1E88E5),
    LyricColorPreset('lyricPresetGreenOrange', 0xFF43A047, 0xFFFB8C00),
    LyricColorPreset('lyricPresetContrast', 0xFF212121, 0xFF455A64),
  ];
}
