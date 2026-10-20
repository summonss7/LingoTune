import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../services/audio_visualizer_service.dart';
import '../theme/app_gradients.dart';
import '../utils/audio_band_processor.dart';

/// Красивый эквалайзер на месте текста песни.
///
/// Два режима:
///  • **Реальный спектр** (Android): нативный `AudioVisualizerService`
///    отдаёт FFT играющей музыки → столбики танцуют от настоящего звука —
///    ритм, такт, громкость; бит пульсирует свечением и лёгким «подпрыгом»,
///    пик-шапки медленно сползают (v5.10.0).
///  • **Заглушка** (нет разрешения/платформа не Android/ROM не дал создать
///    Visualizer): прежняя псевдо-анимация — высота каждой полосы сумма
///    синусоид, идёт только пока плеер играет.
///
/// Цвета — из темы: primary → transcriptAccent («Аметист») или tertiary
/// (остальные темы).
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

  final AudioBandProcessor _processor = AudioBandProcessor();
  final Stopwatch _clock = Stopwatch();
  Duration _lastTick = Duration.zero;

  StreamSubscription<bool>? _playingSub;
  StreamSubscription<Uint8List>? _barsSub;
  bool _fftActive = false;

  @override
  void initState() {
    super.initState();
    _clock.start();
    _applyPlaying(widget.player.playing);
    _playingSub = widget.player.playingStream.listen(_applyPlaying);
    _initRealSpectrum();
  }

  /// Пробует включить настоящий FFT; при любой неудаче молча остаёмся на
  /// псевдо-анимации (запрос разрешения мог занять время — экран могли
  /// уже закрыть).
  Future<void> _initRealSpectrum() async {
    var ok = false;
    try {
      ok = await AudioVisualizerService.instance.start();
    } catch (e) {
      debugPrint('🎚️ Equalizer: visualizer unavailable: $e');
    }
    if (!mounted) {
      if (ok) AudioVisualizerService.instance.stop();
      return;
    }
    if (!ok) {
      debugPrint('🎚️ Equalizer: falling back to pseudo animation');
      return;
    }
    setState(() => _fftActive = true);
    // В FFT-режиме контроллер крутится всегда (не только при игре):
    // спад столбиков, падение шапок и затухание бита живут в tick().
    _controller.repeat();
    _barsSub = AudioVisualizerService.instance.barStream.listen(
      (frame) => _processor.push(frame),
    );
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
    if (_fftActive) return;
    if (playing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _barsSub?.cancel();
    if (_fftActive) {
      AudioVisualizerService.instance.stop();
    }
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
              builder: (context, _) {
                // Каждый кадр анимации продвигаем сглаживание/бит.
                final now = _clock.elapsed;
                _processor.tick(now, now - _lastTick);
                _lastTick = now;
                return CustomPaint(
                  painter: _fftActive
                      ? _SpectrumPainter(
                          processor: _processor,
                          colorA: colorA,
                          colorB: colorB,
                        )
                      : _EqualizerPainter(
                          animation: _controller,
                          colorA: colorA,
                          colorB: colorB,
                        ),
                  size: Size.infinite,
                );
              },
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

/// Отрисовка реального спектра: зеркальные столбики по центру, адаптивный
/// гейн, пик-шапки с двух сторон, пульс свечения в такт биту.
class _SpectrumPainter extends CustomPainter {
  _SpectrumPainter({
    required this.processor,
    required this.colorA,
    required this.colorB,
  });

  final AudioBandProcessor processor;
  final Color colorA;
  final Color colorB;

  static const double _barWidth = 7.0;
  static const double _gap = 4.0;
  static const double _minHeightFraction = 0.04;
  static const double _maxHeightFraction = 0.94;
  static const double _capHeight = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < _barWidth || size.height <= 0) return;

    final count = ((size.width + _gap) / (_barWidth + _gap)).floor();
    if (count < 2) return;

    final gain = processor.gain;
    final beat = processor.beat;
    final bands = processor.levels;
    final peakBands = processor.peaks;

    // Мягкая пульсация в такт: радиальное свечение за столбиками.
    if (beat > 0.02) {
      final glow = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            colorB.withValues(alpha: 0.16 * beat),
            colorB.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size);
      canvas.drawRect(Offset.zero & size, glow);
    }

    final paint = Paint()..style = PaintingStyle.fill;
    final capPaint = Paint()..style = PaintingStyle.fill;
    final centerY = size.height / 2;
    final usable = _maxHeightFraction - _minHeightFraction;

    for (var i = 0; i < count; i++) {
      // Бандов фиксированное число (32), полос на экране зависит от ширины:
      // линейный ресемпл.
      final fPos =
          i / (count - 1) * (bands.length - 1);
      final i0 = fPos.floor().clamp(0, bands.length - 1);
      final i1 = math.min(i0 + 1, bands.length - 1);
      final frac = fPos - i0;

      var level = (bands[i0] * (1 - frac) + bands[i1] * frac) *
          gain *
          (1 + 0.16 * beat);
      level = level.clamp(0.0, 1.0);
      var peak = (peakBands[i0] * (1 - frac) + peakBands[i1] * frac) * gain;
      peak = peak.clamp(level, 1.0);

      final barHeight =
          size.height * (_minHeightFraction + usable * level);
      final capOffset =
          size.height * (_minHeightFraction + usable * peak) / 2;
      final left = i * (_barWidth + _gap);

      paint.color = Color.lerp(colorA, colorB, i / (count - 1))!
          .withValues(alpha: 0.86 + 0.14 * beat);

      final rect = Rect.fromLTWH(
          left, centerY - barHeight / 2, _barWidth, barHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(_barWidth / 2)),
        paint,
      );

      // Пик-шапки: маленькие чёрточки на максимуме полосы, сверху и снизу.
      capPaint.color = colorB.withValues(alpha: 0.95);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              left, centerY - capOffset - _capHeight, _barWidth, _capHeight),
          const Radius.circular(_capHeight / 2),
        ),
        capPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              left, centerY + capOffset, _barWidth, _capHeight),
          const Radius.circular(_capHeight / 2),
        ),
        capPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpectrumPainter oldDelegate) =>
      oldDelegate.colorA != colorA ||
      oldDelegate.colorB != colorB ||
      oldDelegate.processor != processor;
}

/// Псевдо-анимация (фолбэк): высота каждой полосы — сумма синусоид со
/// своими частотой и фазой (детерминированные от индекса — картинка
/// стабильна между перерисовками). Идёт только пока плеер играет.
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
