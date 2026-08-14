import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingotune/utils/lyric_colors.dart';
import 'package:lingotune/services/settings_provider.dart';

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
}
