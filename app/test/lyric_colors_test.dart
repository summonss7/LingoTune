import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingotune/utils/lyric_colors.dart';
import 'package:lingotune/services/settings_provider.dart';
import 'package:lingotune/models/lyric_line.dart';
import 'package:lingotune/theme/app_gradients.dart';
import 'package:lingotune/widgets/lyric_line_widget.dart';

void main() {
  group('LyricColorPalette', () {
    test('colorFromValue returns null for autoValue', () {
      expect(LyricColorPalette.colorFromValue(LyricColorPalette.autoValue),
          isNull);
    });

    test('colorFromValue round-trips a Color', () {
      const c = Color(0xFF1E88E5);
      expect(LyricColorPalette.colorFromValue(c.value), c);
    });

    test('all swatches have distinct values', () {
      final values =
          LyricColorPalette.swatches.map((s) => s.color.value).toSet();
      expect(values.length, LyricColorPalette.swatches.length);
    });

    test('preset nameKeys are unique', () {
      final names = LyricColorPresets.all.map((p) => p.nameKey).toSet();
      expect(names.length, LyricColorPresets.all.length);
    });

    test('default preset uses auto values', () {
      final d = LyricColorPresets.all.first;
      expect(d.originalValue, LyricColorPalette.autoValue);
      expect(d.translationValue, LyricColorPalette.autoValue);
    });

    test('non-default presets set concrete colors', () {
      for (final p in LyricColorPresets.all.skip(1)) {
        expect(p.originalValue, isNot(LyricColorPalette.autoValue));
        expect(p.translationValue, isNot(LyricColorPalette.autoValue));
      }
    });
  });

  group('SettingsProvider lyric colors', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults: custom off, colors null (auto)', () async {
      final p = SettingsProvider();
      await p.loadSettings();
      expect(p.useCustomLyricColors, isFalse);
      expect(p.originalTextColor, isNull);
      expect(p.translationTextColor, isNull);
    });

    test('setters persist and reload', () async {
      final p = SettingsProvider();
      await p.loadSettings();
      await p.setUseCustomLyricColors(true);
      await p.setOriginalTextColor(const Color(0xFFE53935));
      await p.setTranslationTextColor(const Color(0xFF1E88E5));

      expect(p.useCustomLyricColors, isTrue);
      expect(p.originalTextColor, const Color(0xFFE53935));
      expect(p.translationTextColor, const Color(0xFF1E88E5));

      // Новый провайдер с тем же хранилищем должен увидеть сохранённые значения.
      final p2 = SettingsProvider();
      await p2.loadSettings();
      expect(p2.useCustomLyricColors, isTrue);
      expect(p2.originalTextColor, const Color(0xFFE53935));
      expect(p2.translationTextColor, const Color(0xFF1E88E5));
    });

    test('setting null resets to auto', () async {
      final p = SettingsProvider();
      await p.loadSettings();
      await p.setOriginalTextColor(const Color(0xFFE53935));
      expect(p.originalTextColor, const Color(0xFFE53935));
      await p.setOriginalTextColor(null);
      expect(p.originalTextColor, isNull);
      expect(p.originalTextColorValue, LyricColorPalette.autoValue);
    });
  });

  group('SettingsProvider active line color', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults: active line color null (auto)', () async {
      final p = SettingsProvider();
      await p.loadSettings();
      expect(p.activeLineColor, isNull);
      expect(p.activeLineColorValue, LyricColorPalette.autoValue);
    });

    test('active line color persists and reloads', () async {
      final p = SettingsProvider();
      await p.loadSettings();
      await p.setActiveLineColor(const Color(0xFF1E88E5));
      expect(p.activeLineColor, const Color(0xFF1E88E5));

      final p2 = SettingsProvider();
      await p2.loadSettings();
      expect(p2.activeLineColor, const Color(0xFF1E88E5));
    });

    test('active line color: null resets to auto', () async {
      final p = SettingsProvider();
      await p.loadSettings();
      await p.setActiveLineColor(const Color(0xFF1E88E5));
      await p.setActiveLineColor(null);
      expect(p.activeLineColor, isNull);
      expect(p.activeLineColorValue, LyricColorPalette.autoValue);
    });

    test('active line color applies without useCustomLyricColors', () async {
      final p = SettingsProvider();
      await p.loadSettings();
      expect(p.useCustomLyricColors, isFalse);
      await p.setActiveLineColor(const Color(0xFF43A047));
      expect(p.useCustomLyricColors, isFalse);
      expect(p.activeLineColor, const Color(0xFF43A047));
    });
  });

  group('LyricLineWidget active line highlight', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Future<SettingsProvider> pumpLine(
      WidgetTester tester, {
      required ThemeData theme,
      bool isCurrent = true,
    }) async {
      final settings = SettingsProvider();
      await settings.loadSettings();
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
          child: MaterialApp(
            theme: theme,
            home: Scaffold(
              body: LyricLineWidget(
                line: LyricLine(startTime: 1.0, text: 'Hello'),
                isCurrent: isCurrent,
              ),
            ),
          ),
        ),
      );
      return settings;
    }

    BoxDecoration lineDecoration(WidgetTester tester) {
      final container = tester.widget<Container>(
        find.descendant(
            of: find.byType(LyricLineWidget), matching: find.byType(Container)),
      );
      return container.decoration! as BoxDecoration;
    }

    testWidgets('auto: primaryContainer on a regular theme', (tester) async {
      final theme =
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));
      await pumpLine(tester, theme: theme);
      expect(lineDecoration(tester).color, theme.colorScheme.primaryContainer);
    });

    testWidgets('auto: Amethyst uses activeLineHighlight', (tester) async {
      final theme = AmethystPalette.buildTheme(
        darkVariant: false,
        textTheme: ThemeData(brightness: Brightness.dark).textTheme,
      );
      await pumpLine(tester, theme: theme);
      expect(
          lineDecoration(tester).color, AppGradients.light.activeLineHighlight);
    });

    testWidgets('custom color overrides the theme default', (tester) async {
      final theme =
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));
      final settings = await pumpLine(tester, theme: theme);
      await settings.setActiveLineColor(const Color(0xFF43A047));
      await tester.pumpAndSettle();
      expect(lineDecoration(tester).color, const Color(0xFF43A047));
    });

    testWidgets('inactive line stays transparent', (tester) async {
      final theme =
          ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue));
      await pumpLine(tester, theme: theme, isCurrent: false);
      expect(lineDecoration(tester).color, Colors.transparent);
    });
  });
}
