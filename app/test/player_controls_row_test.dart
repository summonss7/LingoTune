import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingotune/widgets/player_controls_metrics.dart';

/// Регресс-тест ряда кнопок управления плеером (lingotune-020).
///
/// Старый расчёт в player_screen.dart оценивал ширину ряда как
/// «48px на кнопку + два спейсинга», но IconButton по умолчанию занимает
/// минимум 48×48 (kMinInteractiveDimension) независимо от iconSize —
/// сжатие иконок ряд фактически не сжимало. При 1080×2400 @ 420dpi
/// (ширина 411.43 лог. px; панель управления с паддингом 16 → доступно
/// ~379px) правый край ряда переполнялся: debug-баннер
/// «A RenderFlex overflowed by 3.4 pixels» поверх кнопки A–B.
///
/// Новая схема: размеры считает PlayerControlsMetrics.fit (фиксированная
/// часть — паддинги кнопок и рамки подсветок — не масштабируется), каждая
/// кнопка закрепляет их констрейнтом BoxConstraints.tightFor, метка «A–B»
/// не раздувается системным масштабом шрифта. Структура ниже зеркалит ряд
/// из player_screen.dart, причём shuffle/loop/A–B показаны активными
/// (рамки по 2px с каждой стороны — худший случай ширины).

const _panelPaddingPortrait = 16.0;

Widget _highlighted(bool active, Widget child) {
  return Container(
    decoration: BoxDecoration(
      color: active ? Colors.deepPurple.shade100 : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: active ? Border.all(color: Colors.deepPurple, width: 2) : null,
    ),
    child: child,
  );
}

IconButton _ctrlButton(
    IconData icon, PlayerControlsFit fit, BoxConstraints constraints) {
  return IconButton(
    icon: Icon(icon),
    onPressed: () {},
    iconSize: fit.iconSize,
    padding: const EdgeInsets.all(4.0),
    constraints: constraints,
    // M3 IconButton расширяет кнопку до 48×48 через _InputPadding
    // (MaterialTapTargetSize.padded) — shrinkWrap отдаёт расчётный размер.
    style: IconButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );
}

Widget _buildApp(TextScaler scaler) {
  return MediaQuery(
    data: MediaQueryData(textScaler: scaler),
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(_panelPaddingPortrait),
            color: Colors.black12,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fit = PlayerControlsMetrics.fit(
                  constraints.maxWidth,
                  isLandscape: false,
                );
                final buttonConstraints = BoxConstraints.tightFor(
                  width: fit.buttonSize,
                  height: fit.buttonSize,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _highlighted(
                      true,
                      _ctrlButton(Icons.shuffle, fit, buttonConstraints),
                    ),
                    _ctrlButton(Icons.skip_previous, fit, buttonConstraints),
                    _ctrlButton(Icons.replay_10, fit, buttonConstraints),
                    SizedBox(
                      width: fit.fabSize,
                      height: fit.fabSize,
                      child: FloatingActionButton(
                        onPressed: () {},
                        child: Icon(Icons.play_arrow, size: fit.fabIconSize),
                      ),
                    ),
                    _ctrlButton(Icons.forward_10, fit, buttonConstraints),
                    _ctrlButton(Icons.skip_next, fit, buttonConstraints),
                    _highlighted(
                      true,
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _ctrlButton(Icons.repeat, fit, buttonConstraints),
                          const Positioned(
                            right: 4,
                            bottom: 4,
                            child: Icon(Icons.list, size: 10),
                          ),
                        ],
                      ),
                    ),
                    _highlighted(
                      true,
                      IconButton(
                        // Метка A–B — графический элемент, не читаемый
                        // текст: системный масштаб шрифта её не раздувает.
                        icon: Text(
                          'A–B',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            fontSize: (fit.iconSize * 0.42).clamp(9.0, 14.0),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        onPressed: () {},
                        iconSize: fit.iconSize,
                        padding: const EdgeInsets.all(4.0),
                        constraints: buttonConstraints,
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // Эмулятор duopulse-e2e: 1080×2400 @ 420dpi (dpr 2.625): тот же экран,
  // на котором E2E lingotune-019 поймал «overflowed by 3.4 pixels».
  for (final scale in [1.0, 1.3, 1.5, 2.0]) {
    testWidgets('ряд кнопок не переполняется при textScale $scale',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_buildApp(TextScaler.linear(scale)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'overflow ряда кнопок плеера при textScale $scale');
    });
  }

  test('fit: при 420dpi (доступно ~379px) размеры не сжимаются', () {
    final available = 1080 / 2.625 - 2 * _panelPaddingPortrait;
    final fit = PlayerControlsMetrics.fit(available, isLandscape: false);
    expect(fit.iconSize, 32.0);
    expect(fit.buttonSize, 40.0);
    expect(fit.fabSize, 56.0);
    // Худший случай (все рамки активны) влезает с запасом на зазоры.
    expect(fit.worstCaseWidth, lessThanOrEqualTo(available));
  });

  test('fit: худший случай влезает во все практические ширины', () {
    // От 248px (уже узких 320dp-экранов минус паддинги) до 1400px
    // (планшеты/ландскейп); ниже 248px упираются минимумы иконки/FAB —
    // таких экранов у телефона в портрете не бывает.
    for (final isLandscape in [false, true]) {
      final from = isLandscape ? 236.0 : 248.0;
      for (double w = from; w <= 1400; w += 0.25) {
        final fit = PlayerControlsMetrics.fit(w, isLandscape: isLandscape);
        expect(fit.worstCaseWidth, lessThanOrEqualTo(w + 1e-9),
            reason: 'overflow при ширине $w (landscape=$isLandscape)');
      }
    }
  });
}
