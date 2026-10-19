import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../theme/app_gradients.dart';

/// Красивый анимированный эквалайзер — заглушка на месте текста песни,
/// когда у трека нет LRC/перевода (раньше там был просто голый экран).
///
/// Полосы «живые»: высота каждой — сумма синусоид со своими частотой и
/// фазой (псевдослучайные, но детерминированные от индекса — картинка
/// стабильна между перерисовками). Анимация идёт только пока плеер играет:
/// на паузе полосы замирают. Цвета — из темы: primary → transcriptAccent
/// («Аметист») или tertiary (остальные темы).
class AudioEqualizerWidget extends StatefulWidget {
  const AudioEqualizerWidget({
    super.key,
    required this.player,
    this.hint,
  });

  final AudioPlayer player;

  /// Подпись под эквалайзером (например, «у этой песни пока нет текста»).
  final String? hint;

  @override
  State<AudioEqualizerWidget> createState() => _AudioEqualizerWidgetState();
}

class _AudioEqualizerWidgetState extends State<AudioEqualizerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  StreamSubscription<bool>? _playingSub;

  @override
  void initState() {
    super.initState();
    _applyPlaying(widget.player.playing);
    _playingSub = widget.player.playingStream.listen(_applyPlaying);
  }

  @override
  void didUpdateWidget(AudioEqualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player != widget.player) {
      _playingSub?.cancel();
      _applyPlaying(widget.player.playing);
      _playingSub = widget.player.playingStream.listen(_applyPlaying);
    }
  }

  void _applyPlaying(bool playing) {
    if (playing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gradients = context.appGradients;
    final colorA = scheme.primary;
    final colorB = gradients?.transcriptAccent ?? scheme.tertiary;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _EqualizerPainter(
                  animation: _controller,
                  colorA: colorA,
                  colorB: colorB,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        if (widget.hint != null && widget.hint!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lyrics_outlined,
                  size: 18,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.hint!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter({
    required this.animation,
    required this.colorA,
    required this.colorB,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color colorA;
  final Color colorB;

  static const double _barWidth = 6.0;
  static const double _gap = 4.0;
  static const double _minHeightFraction = 0.06;
  static const double _maxHeightFraction = 0.92;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < _barWidth || size.height <= 0) return;

    final count = ((size.width + _gap) / (_barWidth + _gap)).floor();
    if (count < 2) return;
    final t = animation.value * 2 * math.pi;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      // Детерминированные «случайные» параметры полосы (золотое сечение).
      final r1 = ((i * 2654435761) & 0xFFFF) / 0xFFFF;
      final r2 = ((i * 40503) & 0xFFFF) / 0xFFFF;
      final w1 = 1.3 + r1 * 2.1;
      final w2 = 2.3 + r2 * 2.7;
      final phase1 = (i * 2.399963) % (2 * math.pi);
      final phase2 = (i * 1.618034) % (2 * math.pi);

      // Рельеф «горкой» к центру: у краёв полосы ниже.
      final edge = ((2.0 * i) / (count - 1) - 1.0).abs();
      final envelope = 0.62 + 0.38 * math.pow(1 - edge, 0.8);

      final wave =
          (0.42 * math.sin(w1 * t + phase1) + 0.58 * math.sin(w2 * t + phase2))
                  .abs() *
              0.78 +
          0.22;
      var fraction = _minHeightFraction +
          (_maxHeightFraction - _minHeightFraction) * wave * envelope;
      fraction = fraction.clamp(_minHeightFraction, _maxHeightFraction);

      final barHeight = size.height * fraction;
      final left = i * (_barWidth + _gap);
      final top = (size.height - barHeight) / 2;

      paint.color = Color.lerp(colorA, colorB, i / (count - 1))!
          .withValues(alpha: 0.9);

      final rect = Rect.fromLTWH(left, top, _barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(_barWidth / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_EqualizerPainter oldDelegate) =>
      oldDelegate.colorA != colorA || oldDelegate.colorB != colorB;
}
