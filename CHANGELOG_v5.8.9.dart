// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.9
// ================================================
// ДИЗАЙН-РЕЛИЗ: новая тема «Аметист» — фиолетовый градиентный дизайн
// (по образцу флагманского фиолетового скина приложения Ai-LeCards,
// D:\Ai-LeCards\app\src\main\java\com\ailecards\app\ui\theme\Theme.kt).
// Дата: 21.09.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.8 → 5.8.9

// app/android/app/build.gradle
versionCode: 236 → 237
archivesBaseName: "LingoTune-v5.8.8" → "LingoTune-v5.8.9"

// app/lib/app_info.dart
static const String version     = '5.8.8' → '5.8.9';
static const String versionCode = '236'   → '237';
+ 2 строки в features


// 💜 НОВАЯ ТЕМА «АМЕТИСТ» (ключ 'amethyst', первый пункт в списке тем)
// ================================================
// Вид (точные hex из Ai-LeCards Theme.kt):
//   • Один полноэкранный ВЕРТИКАЛЬНЫЙ градиент за всеми экранами:
//     светлый режим #5E3FE6 → #4125C2 (яркий фиолетовый flood),
//     тёмный — #1A1428 → #0F0B19 (глубокий фиолетово-чёрный).
//     Переключатель светлого/тёмного меняет насыщенность фона.
//   • Scaffold'ы и аппбары ПРОЗРАЧНЫЕ — градиент течёт от статус-бара до
//     навигационной панели (аналог full-screen Box + transparentBars
//     в Ai-LeCards; статус-бар — светлые иконки).
//   • Карточки-градиенты ТЕМНЕЕ фона: #4A2AD1 → #331FA8 (светлый) /
//     #251C3B → #1B1430 (тёмный) с бордером outlineVariant: мини-плеер,
//     панель управления плеера, выбранный пункт нижней навигации.
//     Диалоги/menus/поля ввода — глубокий фиолетовый surfaceContainerLow,
//     радиус 28, поля — filled с радиусом 16 (убирает копипасту
//     OutlineInputBorder по диалогам).
//   • ColorScheme — dark-схемы в ОБОИХ режимах (поверхности тёмные, весь
//     текст светлый, как в исходнике): primary #D6C8FF / onPrimary #3A1D8F
//     (лавандовые CTA с тёмной иконкой), primaryContainer #5B3BC9,
//     secondaryContainer #493E80, surfaceContainer-ступени
//     #3A22B4…#5232D4 (светлый) / #0F0B19…#33284C (тёмный).
//   • Тема ВКЛЮЧЕНА ПО УМОЛЧАНИЮ: prefs 'themeColor' отсутствует →
//     'amethyst' (новая установка + те, кто ни разу не выбирал цвет).
//     Ранее выбранный цвет НЕ трогаем; все 13 старых цветов остались.
//
// Архитектура:
//   • НОВЫЙ app/lib/theme/app_gradients.dart:
//     - ThemeExtension<AppGradients> (backdrop / card / transcriptAccent);
//       НАЛИЧИЕ extension в теме = маркер скина для гейтов экранов.
//     - AmethystPalette: обе палитры + buildTheme() (полный ThemeData:
//       прозрачные scaffold/appbar/bottomAppBar, card/dialog/bottomSheet/
//       inputDecoration/divider/FAB-темы, extensions).
//     - BuildContext-хелперы: isAmethystSkin, appBarColor(fallback),
//       amethystCardDecoration(context, {radius}).
//   • ThemeProvider + SettingsProvider (дубль themeColor синхронизирован):
//     кейс 'amethyst', дефолт, геттер isAmethystSkin.
//   • main.dart: дублировавшийся inline-TextTheme вынесен в
//     _buildTextTheme(); обычные seed-темы — через _seededTheme()
//     (их вид НЕ изменился); градиентная обёртка MaterialApp.builder
//     (DecoratedBox c backdrop — только когда extension в теме);
//     выбранный пункт навигации — градиентная карточка.
//
// Сопутствующие правки читаемости (гейт на скин, кроме ролей темы):
//   • LyricLineWidget: неактивные строки Colors.black87/grey[600] →
//     onSurfaceVariant (чинит и обычный тёмный режим всех тем);
//     транскрипция на «Аметисте» — мятный акцент #A5F3E2/#9BD8C9
//     (синий Flutter на фиолетовом не читается).
//   • About-экран и EmptyLibraryWidget: deepPurple/серые → роли темы.
//   • Аппбары с явным backgroundColor (библиотека, настройки, редактор
//     перевода, плеер, about) — прозрачные на «Аметисте» через
//     context.appBarColor(fallback); оранжевый edit-mode плеера сохранён.
//   • НЕ тронуто (сознательно): семантические снекбары
//     зелёный/красный/оранжевый, красные delete-кнопки — это статусы,
//     не брендинг; пользовательские цвета строк лирики продолжают
//     перекрывать тему (фичей и задумано).


// 🌐 ЛОКАЛИЗАЦИЯ
// ================================================
// Новая строка themeNameAmethyst («Аметист») во всех 11 локалях:
// en Amethyst, ru Аметист, de Amethyst, es Amatista, fr Améthyste,
// it Ametista, pt Ametista, ro Ametist, uk Аметист, zh 紫水晶, ar جمشت.
// + flutter gen-l10n (сгенерированные app_localizations*.dart закоммичены).


// ✅ ТЕСТЫ И АНАЛИЗ
// ================================================
// flutter analyze: 0 ошибок (230 info/warning — все существовали до релиза).
// flutter test: 31 тест, все зелёные. Новые (test/amethyst_theme_test.dart):
//   • дефолт 'amethyst' при отсутствии ключа; сохранение выбранного цвета;
//   • переключение скина туда-обратно + персистентность;
//   • темы прозрачны (scaffold/appbar) и несут extension AppGradients;
//   • тёмный вариант темнее светлого; onPrimary темнее primary.
// Проверка на устройстве: Настройки → Цветовая тема → «💜 Аметист»;
// переключить светлый/тёмный — фон меняется с яркого фиолетового на
// фиолетово-чёрный; мини-плеер/панель плеера/навигация — градиентные
// карточки; выбрать старый цвет — прежний вид возвращается целиком.


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/theme/app_gradients.dart                 — NEW: AppGradients + AmethystPalette + хелперы
// app/test/amethyst_theme_test.dart                — NEW: 4 группы тестов скина
// app/lib/main.dart                                — _buildTextTheme/_seededTheme, ветка amethyst, градиент в builder, нав-пилл
// app/lib/services/theme_provider.dart             — кейс/дефолт/getter amethyst
// app/lib/services/settings_provider.dart          — дефолт themeColor 'amethyst' (синхрон с ThemeProvider)
// app/lib/services/settings_helper.dart            — кейс 'amethyst' в getThemeColorName
// app/lib/widgets/settings/theme_settings_tile.dart — пункт «💜 Аметист» первым в списке
// app/lib/widgets/mini_player_widget.dart          — градиентная карточка
// app/lib/widgets/lyric_line_widget.dart           — роли темы для неактивных строк + мятная транскрипция
// app/lib/widgets/empty_library_widget.dart        — роли темы вместо серых
// app/lib/screens/settings_screen.dart             — appBarColor(transparent на скине)
// app/lib/screens/song_library_screen.dart         — appBarColor для обоих режимов аппбара
// app/lib/screens/translation_editor_screen.dart   — appBarColor
// app/lib/screens/player_screen.dart               — appBarColor (edit-mode сохранён) + градиентная панель управления
// app/lib/about_app.dart                           — appBarColor + роли темы вместо deepPurple/grey
// app/lib/l10n/app_*.arb ×11 + app_localizations*.dart — themeNameAmethyst
// app/lib/app_info.dart                            — version 5.8.9 + 2 строки фич
// app/pubspec.yaml                                 — version 5.8.9
// app/android/app/build.gradle                     — versionCode 237, archivesBaseName v5.8.9
// docs/CHANGELOG.md                                — запись v5.8.9
// AGENTS.md                                        — версия + раздел Theming
// CHANGELOG_v5.8.9.dart                            — этот файл (NEW FILE)
