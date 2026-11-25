import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Регресс-тест нижней навигации MainScreen (lingotune-019).
///
/// Старая панель — `BottomAppBar(height: 60)` — внутри добавляла пункту
/// «иконка + подпись» лишь 36px свободной высоты (60 − 12 − 12), при
/// потребных ~60 → на эмуляторе 1080×2400 @ 420dpi debug-баннеры
/// «BOTTOM OVERFLOWED BY 25/27 PIXELS». Новая панель саморазмерается:
/// `Material → SafeArea → Row`, пункты получают высоту от контента при
/// любом dpi и масштабе шрифта. Структура здесь зеркалит
/// `_buildNavItem` + панель из `main.dart`.
Widget _buildApp(TextScaler scaler) {
  final textTheme = TextTheme(
    bodyMedium: const TextStyle(fontSize: 16),
    bodySmall: const TextStyle(fontSize: 14),
  );
  Widget navItem(IconData icon, String label, bool selected) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.deepPurple.withValues(alpha: 0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  return MediaQuery(
    data: MediaQueryData(textScaler: scaler),
    child: MaterialApp(
      theme: ThemeData(useMaterial3: true, textTheme: textTheme),
      home: Scaffold(
        body: const SizedBox.expand(),
        bottomNavigationBar: Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(child: navItem(Icons.library_music, 'Library', false)),
                Flexible(
                    child: navItem(Icons.playlist_play, 'Playlists', true)),
                Flexible(child: navItem(Icons.settings, 'Settings', false)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final scale in [1.0, 1.3, 1.5, 2.0]) {
    testWidgets('нижняя навигация не переполняется, textScale $scale',
        (tester) async {
      // Эмулятор duopulse-e2e: 1080×2400 @ 420dpi (dpr 2.625).
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_buildApp(TextScaler.linear(scale)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'overflow в нижней навигации при textScale $scale');
    });
  }
}
