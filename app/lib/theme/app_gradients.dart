import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Тема «Аметист»: фиолетовый градиентный дизайн (v5.8.9).
///
/// Механика — один полноэкранный градиент за всем приложением (см.
/// `LingoTuneApp.builder`), прозрачные Scaffold/аппбары и карточки-градиенты
/// темнее фона. Цветовые роли и градиенты перенесены с флагманского
/// фиолетового скина приложения Ai-LeCards (ui/theme/Theme.kt).
///
/// Оба варианта (яркий flood и тёмный фиолетово-чёрный) используют
/// `Brightness.dark`-схемы: поверхности у обоих тёмные, весь текст светлый —
/// как и в исходнике. Переключатель светлого/тёмного режима меняет лишь
/// насыщенность фона.
class AppGradients extends ThemeExtension<AppGradients> {
  const AppGradients({
    required this.backdrop,
    required this.card,
    required this.transcriptAccent,
    required this.activeLineHighlight,
  });

  /// Градиент фона приложения (вертикальный, сверху вниз).
  final LinearGradient backdrop;

  /// Градиент «карточки темнее фона» для ключевых поверхностей.
  final LinearGradient card;

  /// Акцент для транскрипции: синий Flutter на фиолетовом не читается.
  final Color transcriptAccent;

  /// Фон активной (подсвеченной) строки текста песни. На ярком flood
  /// `primaryContainer` сливается с градиентом фона — активная строка
  /// затемняется полупрозрачным чёрным (всегда темнее фона в любой точке
  /// градиента); в тёмном варианте виден и прежний `primaryContainer`.
  final Color activeLineHighlight;

  /// Яркий фиолетовый flood (светлый режим).
  static const AppGradients light = AppGradients(
    backdrop: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5E3FE6), Color(0xFF4125C2)],
    ),
    card: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4A2AD1), Color(0xFF331FA8)],
    ),
    transcriptAccent: Color(0xFFA5F3E2),
    activeLineHighlight: Color(0x4D000000),
  );

  /// Глубокий фиолетово-чёрный (тёмный режим).
  static const AppGradients dark = AppGradients(
    backdrop: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1A1428), Color(0xFF0F0B19)],
    ),
    card: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF251C3B), Color(0xFF1B1430)],
    ),
    transcriptAccent: Color(0xFF9BD8C9),
    activeLineHighlight: Color(0xFF522DDB),
  );

  @override
  AppGradients copyWith({
    LinearGradient? backdrop,
    LinearGradient? card,
    Color? transcriptAccent,
    Color? activeLineHighlight,
  }) {
    return AppGradients(
      backdrop: backdrop ?? this.backdrop,
      card: card ?? this.card,
      transcriptAccent: transcriptAccent ?? this.transcriptAccent,
      activeLineHighlight: activeLineHighlight ?? this.activeLineHighlight,
    );
  }

  @override
  ThemeExtension<AppGradients> lerp(
      ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    // Тема переключается целиком (цвет/режим), промежуточные состояния не нужны.
    return t < 0.5 ? this : other;
  }
}

/// Все константы палитры «Аметист» и сборка ColorScheme/ThemeData.
class AmethystPalette {
  // ── Яркий фиолетовый flood (светлый режим) ─────────────────────────
  static const Color lightPrimary = Color(0xFFD6C8FF);
  static const Color lightOnPrimary = Color(0xFF3A1D8F);
  static const Color lightPrimaryContainer = Color(0xFF5B3BC9);
  static const Color lightOnPrimaryContainer = Color(0xFFE9DDFF);
  static const Color lightSecondary = Color(0xFFCBBEF2);
  static const Color lightOnSecondary = Color(0xFF322469);
  static const Color lightSecondaryContainer = Color(0xFF493E80);
  static const Color lightOnSecondaryContainer = Color(0xFFE6DFFF);
  static const Color lightTertiary = Color(0xFFE6B9F0);
  static const Color lightOnTertiary = Color(0xFF40174E);
  static const Color lightTertiaryContainer = Color(0xFF5D3168);
  static const Color lightOnTertiaryContainer = Color(0xFFFFD8F3);
  static const Color lightSurface = Color(0xFF4F32D4);
  static const Color lightOnSurface = Color(0xFFF6F2FF);
  static const Color lightSurfaceVariant = Color(0xFF3D24BD);
  static const Color lightOnSurfaceVariant = Color(0xFFE4DDFF);
  static const Color lightContainerLowest = Color(0xFF3A22B4);
  static const Color lightContainerLow = Color(0xFF4026BC);
  static const Color lightContainer = Color(0xFF462AC4);
  static const Color lightContainerHigh = Color(0xFF4C2ECC);
  static const Color lightContainerHighest = Color(0xFF5232D4);
  static const Color lightSurfaceDim = Color(0xFF2E1C9A);
  static const Color lightSurfaceBright = Color(0xFF6A4FE0);
  static const Color lightOutline = Color(0xFF9C8FEA);
  static const Color lightOutlineVariant = Color(0xFF7A63DE);

  // ── Фиолетово-чёрный (тёмный режим) ────────────────────────────────
  static const Color darkPrimary = Color(0xFFC4B5FD);
  static const Color darkOnPrimary = Color(0xFF2E1065);
  static const Color darkPrimaryContainer = Color(0xFF522DDB);
  static const Color darkOnPrimaryContainer = Color(0xFFE9DDFF);
  static const Color darkSecondary = Color(0xFFC9BEEE);
  static const Color darkOnSecondary = Color(0xFF322A55);
  static const Color darkSecondaryContainer = Color(0xFF33284C);
  static const Color darkOnSecondaryContainer = Color(0xFFE6DFFF);
  static const Color darkTertiary = Color(0xFFE2B9F0);
  static const Color darkOnTertiary = Color(0xFF40274A);
  static const Color darkTertiaryContainer = Color(0xFF5D3168);
  static const Color darkOnTertiaryContainer = Color(0xFFFFD8F3);
  static const Color darkSurface = Color(0xFF14101F);
  static const Color darkOnSurface = Color(0xFFEAE6F8);
  static const Color darkSurfaceVariant = Color(0xFF231B38);
  static const Color darkOnSurfaceVariant = Color(0xFFCBC2DE);
  static const Color darkContainerLowest = Color(0xFF0F0B19);
  static const Color darkContainerLow = Color(0xFF1C162B);
  static const Color darkContainer = Color(0xFF221A33);
  static const Color darkContainerHigh = Color(0xFF2A2140);
  static const Color darkContainerHighest = Color(0xFF33284C);
  static const Color darkSurfaceDim = Color(0xFF0B0813);
  static const Color darkSurfaceBright = Color(0xFF3A3244);
  static const Color darkOutline = Color(0xFF948F9E);
  static const Color darkOutlineVariant = Color(0xFF494452);

  // Семантика ошибок одинаковая: поверхности у обоих вариантов тёмные.
  static const Color errorRed = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerRed = Color(0xFF93000A);
  static const Color onErrorContainerLight = Color(0xFFFFDAD6);

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    onSecondaryContainer: lightOnSecondaryContainer,
    tertiary: lightTertiary,
    onTertiary: lightOnTertiary,
    tertiaryContainer: lightTertiaryContainer,
    onTertiaryContainer: lightOnTertiaryContainer,
    error: errorRed,
    onError: onErrorDark,
    errorContainer: errorContainerRed,
    onErrorContainer: onErrorContainerLight,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceDim: lightSurfaceDim,
    surfaceBright: lightSurfaceBright,
    surfaceContainerLowest: lightContainerLowest,
    surfaceContainerLow: lightContainerLow,
    surfaceContainer: lightContainer,
    surfaceContainerHigh: lightContainerHigh,
    surfaceContainerHighest: lightContainerHighest,
    onSurfaceVariant: lightOnSurfaceVariant,
    surfaceVariant: lightSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFF6F2FF),
    onInverseSurface: Color(0xFF3A22B4),
    inversePrimary: Color(0xFF5B3BC9),
    surfaceTint: lightPrimary,
  );

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    error: errorRed,
    onError: onErrorDark,
    errorContainer: errorContainerRed,
    onErrorContainer: onErrorContainerLight,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceDim: darkSurfaceDim,
    surfaceBright: darkSurfaceBright,
    surfaceContainerLowest: darkContainerLowest,
    surfaceContainerLow: darkContainerLow,
    surfaceContainer: darkContainer,
    surfaceContainerHigh: darkContainerHigh,
    surfaceContainerHighest: darkContainerHighest,
    onSurfaceVariant: darkOnSurfaceVariant,
    surfaceVariant: darkSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFEAE6F8),
    onInverseSurface: Color(0xFF1A1428),
    inversePrimary: Color(0xFF522DDB),
    surfaceTint: darkPrimary,
  );

  /// Полный ThemeData темы «Аметист». [darkVariant] — тёмный режим
  /// (фиолетово-чёрный), иначе яркий фиолетовый flood.
  static ThemeData buildTheme({
    required bool darkVariant,
    required TextTheme textTheme,
    String? fontFamily,
  }) {
    final scheme = darkVariant ? darkScheme : lightScheme;
    final gradients = darkVariant ? AppGradients.dark : AppGradients.light;
    final dialogColor = scheme.surfaceContainerLow;
    final fieldFill = scheme.surfaceContainerHighest;

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: dialogColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: dialogColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dialogColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dialogColor,
        modalBackgroundColor: dialogColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: dialogColor,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      extensions: [gradients],
    );
  }
}

/// Доступ к градиентам скина и гейты для точечных правок экранов.
extension AmethystSkinContext on BuildContext {
  /// Тема «Аметист» активна (в теме есть расширение AppGradients).
  bool get isAmethystSkin => Theme.of(this).extension<AppGradients>() != null;

  AppGradients? get appGradients => Theme.of(this).extension<AppGradients>();

  /// Цвет фона AppBar: прозрачный на «Аметисте» (градиент течёт под ним),
  /// иначе — прежнее значение экрана.
  Color appBarColor(Color fallback) =>
      isAmethystSkin ? Colors.transparent : fallback;
}

/// Декорация «карточка темнее фона» для ключевых поверхностей (мини-плеер,
/// панель плеера, выбранный пункт навигации). null, если «Аметист» не активен —
/// вызывающий код оставляет своё прежнее оформление.
BoxDecoration? amethystCardDecoration(
  BuildContext context, {
  double radius = 16,
}) {
  final gradients = context.appGradients;
  if (gradients == null) return null;
  return BoxDecoration(
    gradient: gradients.card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
