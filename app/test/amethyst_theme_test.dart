import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:lingotune/services/theme_provider.dart';
import 'package:lingotune/theme/app_gradients.dart';

void main() {
  group('ThemeProvider Amethyst Skin Tests', () {
    test('ThemeProvider should default to amethyst when no theme color was saved', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = ThemeProvider();
      await provider.loadSettings();

      expect(provider.isAmethystSkin, isTrue,
          reason: 'Новая установка (ключ themeColor отсутствует) должна получать «Аметист»');
    });

    test('ThemeProvider should keep a previously chosen color', () async {
      SharedPreferences.setMockInitialValues({'themeColor': 'green'});
      final provider = ThemeProvider();
      await provider.loadSettings();

      expect(provider.isAmethystSkin, isFalse);
      expect(provider.seedColor, Colors.green);
    });

    test('ThemeProvider should switch to amethyst skin and back', () async {
      SharedPreferences.setMockInitialValues({'themeColor': 'blue'});
      final provider = ThemeProvider();
      await provider.loadSettings();

      await provider.setThemeColor('amethyst');
      expect(provider.isAmethystSkin, isTrue);
      expect(provider.seedColor, Colors.deepPurple, reason: 'сид — фолбэк для amethyst');

      await provider.setThemeColor('default');
      expect(provider.isAmethystSkin, isFalse);
      expect(provider.seedColor, Colors.deepPurple);

      final persisted = await SharedPreferences.getInstance();
      expect(persisted.getString('themeColor'), 'default');
    });
  });

  group('AmethystPalette Theme Tests', () {
    test('Amethyst themes must be transparent and carry gradients', () {
      final textTheme = ThemeData.light().textTheme;
      for (final darkVariant in [false, true]) {
        final theme = AmethystPalette.buildTheme(
          darkVariant: darkVariant,
          textTheme: textTheme,
        );

        expect(theme.scaffoldBackgroundColor, Colors.transparent,
            reason: 'Scaffold прозрачен — за ним градиент из MaterialApp.builder');
        expect(theme.appBarTheme.backgroundColor, Colors.transparent);
        expect(theme.extension<AppGradients>(), isNotNull,
            reason: 'расширение AppGradients — маркер скина для гейтов экранов');
        expect(theme.extension<AppGradients>()!.backdrop.colors.length, 2);
        expect(theme.extension<AppGradients>()!.card.colors.length, 2);
      }
    });

    test('Amethyst gradients: dark variant must be darker than light', () {
      // Компоненты Color в Flutter — 0..1; «люма» без нормализации, 0..1000.
      double luma(Color c) => c.r * 299 + c.g * 587 + c.b * 114;
      double avg(List<Color> colors) =>
          colors.map(luma).reduce((a, b) => a + b) / colors.length;

      expect(avg(AppGradients.dark.backdrop.colors),
          lessThan(avg(AppGradients.light.backdrop.colors)),
          reason: 'тёмный режим — фиолетово-чёрный, светлее яркого flood быть не может');
    });

    test('Amethyst schemes keep light text on dark purple surfaces', () {
      for (final scheme in [AmethystPalette.lightScheme, AmethystPalette.darkScheme]) {
        expect(scheme.brightness, Brightness.dark,
            reason: 'оба варианта — dark-схемы: поверхности тёмные, текст светлый');
        // Контраст onPrimary на primary должен быть заметным (грубая проверка
        // яркости, не полный WCAG).
        double luma(Color c) => c.r * 299 + c.g * 587 + c.b * 114;
        expect(luma(scheme.onPrimary), lessThan(luma(scheme.primary)));
      }
    });
  });
}
