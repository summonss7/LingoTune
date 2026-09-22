// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.10
// ================================================
// ФИЧА-релиз: цвет ФОНА активной (подсвеченной при воспроизведении)
// строки лирики настраивается пользователем + активная строка стала
// видна на светлом «Аметисте» без всякой настройки.
// Дата: 22.09.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.9 → 5.8.10

// app/android/app/build.gradle
versionCode: 237 → 238
archivesBaseName: "LingoTune-v5.8.9" → "LingoTune-v5.8.10"

// app/lib/app_info.dart
static const String version     = '5.8.9' → '5.8.10';
static const String versionCode = '237'   → '238';
+ 1 строка в features


// 🖍️ ФИЧА: ЦВЕТ АКТИВНОЙ СТРОКИ
// ================================================
// Контекст: в диалоге «Цвета строк» (меню плеера, с v5.7.x) настраивался
// только ЦВЕТ ТЕКСТА оригинала/перевода. Фон подсвеченной при проигрывании
// строки всегда брался из colorScheme.primaryContainer — на светлом
// «Аметисте» #5B3BC9 почти совпадает с градиентом экрана #5E3FE6→#4125C2,
// активная строка «не видно нормально» (запрос пользователя).
//
// Что добавлено:
//   • SettingsProvider: activeLineColor / activeLineColorValue /
//     setActiveLineColor(Color?), prefs-ключ 'lyricActiveLineColor',
//     сентинел LyricColorPalette.autoValue (-1 = «авто»). ВНИМАНИЕ:
//     применяется БЕЗ тумблера useCustomLyricColors — независимая
//     настройка (можно менять подсветку, не включая «Свои цвета»).
//   • Диалог «Цвета строк» (PlayerScreen._showLyricColorsDialog):
//     третий ряд свотчей «Активная строка» — всегда виден (вне ветки
//     if (useCustom)); предпросмотр вынесен из-под тумблера и стал
//     честным: фон = активная строка (тот же приоритет цвета, что в
//     LyricLineWidget), тексты = выбранные/тема. Мгновенное применение.
//   • LyricLineWidget: приоритет фона isCurrent:
//       activeCustom (выбор пользователя)
//       → «Аметист»: appGradients.activeLineHighlight (см. ниже)
//       → прочие темы: colorScheme.primaryContainer (как раньше).
//     isNext = тот же цвет с opacity 0.3 (как раньше); isEditMode
//     (оранжевый) не тронут.
//
// Пресеты LyricColorPresets НЕ тронуты — они про цвет текста;
// выбранный цвет подсветки сохраняется при применении пресета.


// 💜 ДЕФОЛТ «АМЕТИСТА»: activeLineHighlight
// ================================================
// Новое поле в AppGradients (theme/app_gradients.dart):
//   • light:  Color(0x4D000000) — полупрозрачный чёрный ~30 %.
//     Затемнение ГАРАНТИРОВАННО темнее фона в любой точке вертикального
//     градиента (в отличие от фиксированного hex, который у верха экрана
//     сливается, а у низа нет); светлый текст лирики читается отлично.
//     Стиль — «тёмное стекло», в духе карточек-темнее-фона скина.
//   • dark: Color(0xFF522DDB) — прежний darkPrimaryContainer: на
//     фиолетово-чёрном фоне подсветка и так контрастна, вид не меняется.
//   • Прочие темы: прежний primaryContainer (M3 pastel) — не тронуто.


// 🌐 ЛОКАЛИЗАЦИЯ
// ================================================
// Новая строка lyricColorsActive («Активная строка») во всех 11 локалях:
// en Active line, ru Активная строка, de Aktive Zeile, es Línea activa,
// fr Ligne active, it Riga attiva, pt Linha ativa, ro Rând activ,
// uk Активний рядок, zh 当前行, ar السطر النشط.
// + flutter gen-l10n (сгенерированные app_localizations*.dart закоммичены).


// ✅ ТЕСТЫ И АНАЛИЗ
// ================================================
// flutter analyze: 0 ошибок (231 info/warning — все существовали до
// релиза, новые строки следуют тем же паттернам, что соседние).
// flutter test: 39 тестов, все зелёные. Новые (test/lyric_colors_test.dart):
//   • дефолт activeLineColor = авто; персистентность + перечитывание
//     вторым провайдером; сброс null → авто;
//   • применяется без включённого useCustomLyricColors;
//   • LyricLineWidget: авто → primaryContainer обычной темы; авто на
//     «Аметисте» → AppGradients.light.activeLineHighlight; кастомный
//     цвет перекрывает тему; неактивная строка прозрачна.
// Проверка на устройстве: плеер → меню (⋮) → «Цвета строк» → ряд
// «Активная строка»: тап по свотчу мгновенно красит подсветку; «A»
// возвращает дефолт (на «Аметисте» — тёмное стекло); выключенный
// тумблер «Свои цвета» НЕ прячет ряд и не сбрасывает выбор.


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/services/settings_provider.dart        — activeLineColor* + setActiveLineColor + load/save
// app/lib/theme/app_gradients.dart               — поле activeLineHighlight (light/dark) + copyWith
// app/lib/widgets/lyric_line_widget.dart         — приоритет фона активной строки
// app/lib/screens/player_screen.dart             — ряд свотчей «Активная строка» + честный предпросмотр
// app/lib/l10n/app_*.arb ×11 + app_localizations*.dart — lyricColorsActive
// app/test/lyric_colors_test.dart                — +2 группы тестов (провайдер + виджет)
// app/lib/app_info.dart                          — version 5.8.10 + строка фич
// app/pubspec.yaml                               — version 5.8.10
// app/android/app/build.gradle                   — versionCode 238, archivesBaseName v5.8.10
// docs/CHANGELOG.md                              — запись v5.8.10
// AGENTS.md                                      — версия + Theming/utils
// CHANGELOG_v5.8.10.dart                         — этот файл (NEW FILE)
