import 'package:flutter/foundation.dart';

/// Метрики ряда кнопок управления плеером (lingotune-020).
///
/// Ряд: 7 IconButton (shuffle, prev, −10с, +10с, next, loop, A–B) +
/// центральный FloatingActionButton, раскладка `spaceEvenly`. IconButton
/// по умолчанию занимает минимум `kMinInteractiveDimension` = 48×48
/// «regardless of the actual iconSize» — поэтому в player_screen.dart
/// размеры кнопок обязательно закрепляются констрейнтами
/// `BoxConstraints.tightFor(buttonSize)`, иначе сжатие иконок ряд не
/// сжимает, и на 1080×2400 @ 420dpi он переполняется (debug-баннер
/// «A RenderFlex overflowed by 3.4 pixels»).
///
/// Активные подсветки shuffle/loop/A–B рисуют рамку 2px с каждой
/// стороны (+4px на кнопку; до трёх активных одновременно) — учтено
/// запасом [activeBorderAllowance], чтобы худший случай не переполнял.
@immutable
class PlayerControlsMetrics {
  const PlayerControlsMetrics._();

  /// Число IconButton в ряду (без центрального FAB).
  static const int buttonCount = 7;

  /// Паддинг IconButton: по 4 с каждой стороны.
  static const double buttonPadding = 8.0;

  /// Запас на рамки активных подсветок: 3 кнопки × (2px слева + 2px справа).
  static const double activeBorderAllowance = 12.0;

  /// Фиксированная часть ширины ряда — не масштабируется: паддинги кнопок
  /// (`buttonCount × buttonPadding`) + рамки активных подсветок.
  static const double _fixedWidth =
      buttonCount * buttonPadding + activeBorderAllowance;

  /// Масштабируемая часть ширины ряда: иконки всех кнопок + FAB.
  static double _scalableWidth({required bool isLandscape}) =>
      buttonCount * (isLandscape ? landscapeIconSize : portraitIconSize) +
      baseFabSize;

  /// Минимумы сжатия: иконка и FAB.
  static const double minIconSize = 18.0;
  static const double minFabSize = 36.0;

  /// Базовые размеры: иконка в портрете/ландскейпе и центральный FAB.
  static const double portraitIconSize = 32.0;
  static const double landscapeIconSize = 24.0;
  static const double baseFabSize = 56.0;

  /// Иконка внутри FAB — половина его размера в пределах 18–28.
  static const double minFabIconSize = 18.0;
  static const double maxFabIconSize = 28.0;

  /// Подбирает размеры ряда под [availableWidth] (ширина панели минус её
  /// паддинги; обычно даёт LayoutBuilder над рядом). При нехватке места
  /// пропорционально уменьшаются иконки и FAB — но не паддинги кнопок и
  /// не рамки подсветок, поэтому ratio считается от одной лишь
  /// масштабируемой части (иконки + FAB), а фиксированная вычитается
  /// заранее: так сжатый ряд гарантированно не переполняется.
  static PlayerControlsFit fit(
    double availableWidth, {
    required bool isLandscape,
  }) {
    final baseIconSize = isLandscape ? landscapeIconSize : portraitIconSize;
    final scalable = _scalableWidth(isLandscape: isLandscape);
    double iconSize;
    double fabSize;
    if (_fixedWidth + scalable <= availableWidth) {
      iconSize = baseIconSize;
      fabSize = baseFabSize;
    } else {
      final ratio = (availableWidth - _fixedWidth) / scalable;
      iconSize = (baseIconSize * ratio).clamp(minIconSize, baseIconSize);
      fabSize = (baseFabSize * ratio).clamp(minFabSize, baseFabSize);
    }
    return PlayerControlsFit(
      iconSize: iconSize,
      buttonSize: iconSize + buttonPadding,
      fabSize: fabSize,
      fabIconSize: (fabSize * 0.5).clamp(minFabIconSize, maxFabIconSize),
    );
  }
}

/// Размеры одного состояния ряда кнопок.
@immutable
class PlayerControlsFit {
  const PlayerControlsFit({
    required this.iconSize,
    required this.buttonSize,
    required this.fabSize,
    required this.fabIconSize,
  });

  /// Размер иконки IconButton.
  final double iconSize;

  /// Полная ширина/высота IconButton (иконка + паддинги); именно это
  /// значение передаётся в `BoxConstraints.tightFor`.
  final double buttonSize;

  /// Размер центрального FAB (SizedBox вокруг FloatingActionButton).
  final double fabSize;

  /// Размер иконки внутри FAB.
  final double fabIconSize;

  /// Худший случай ширины ряда: все кнопки + FAB + рамки активных подсветок.
  double get worstCaseWidth =>
      PlayerControlsMetrics.buttonCount * buttonSize +
      fabSize +
      PlayerControlsMetrics.activeBorderAllowance;
}
