import 'package:flutter/material.dart';

/// Дорожка слайдера позиции с подсветкой отрезка повтора A–B (v5.12.0).
///
/// Наследует штатную отрисовку Material ([RoundedRectSliderTrackShape] —
/// активная/неактивная части дорожки рисуются как обычно), а поверх
/// дорисовывает сегмент A..B: залитая полоса чуть выше дорожки + тонкие
/// метки на краях. Пока выставлена только точка A — рисуется одна метка
/// начала (пользователь видит, от куда начнётся отрезок).
///
/// Геометрия берётся из [getPreferredRect] — той же, которой пользуется
/// базовая отрисовка, поэтому подсветка совпадает с дорожкой пиксель
/// в пиксель при любой теме/плотности.
class AbRepeatSliderTrackShape extends RoundedRectSliderTrackShape {
  const AbRepeatSliderTrackShape({
    this.segmentStart,
    this.segmentEnd,
    this.duration,
  });

  /// Начало отрезка (точка A) или null, если повтор не размечается.
  final Duration? segmentStart;

  /// Конец отрезка (точка B); null, пока не выставлен.
  final Duration? segmentEnd;

  /// Общая длительность песни (для пересчёта времени в долю дорожки).
  final Duration? duration;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    double additionalActiveTrackHeight = 0,
    required Animation<double> enableAnimation,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    super.paint(
      context,
      offset,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
      enableAnimation: enableAnimation,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
      textDirection: textDirection,
    );

    final total = duration?.inMilliseconds ?? 0;
    final start = segmentStart;
    if (total <= 0 || start == null) return;

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final canvas = context.canvas;
    final accent = sliderTheme.activeTrackColor ?? const Color(0xFF522DDB);
    final tickColor = sliderTheme.thumbColor ?? accent;
    final radius = Radius.circular(trackRect.height / 2 + 2);

    double fraction(int ms) =>
        (ms / total).clamp(0.0, 1.0) * trackRect.width + trackRect.left;

    final end = segmentEnd;
    if (end == null || end <= start) {
      // Только точка A — метка начала будущего отрезка.
      _drawTick(canvas, fraction(start.inMilliseconds), trackRect, tickColor);
      return;
    }

    // Полоса A..B: чуть выше дорожки, чтобы читалась и на неактивной части.
    final left = fraction(start.inMilliseconds);
    final right = fraction(end.inMilliseconds);
    final bar = Rect.fromLTRB(
      left,
      trackRect.top - 2,
      right,
      trackRect.bottom + 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, radius),
      Paint()..color = accent.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bar, radius),
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    _drawTick(canvas, left, trackRect, tickColor);
    _drawTick(canvas, right, trackRect, tickColor);
  }

  void _drawTick(Canvas canvas, double x, Rect trackRect, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, trackRect.center.dy),
          width: 3,
          height: trackRect.height + 8,
        ),
        const Radius.circular(1.5),
      ),
      Paint()..color = color,
    );
  }
}
