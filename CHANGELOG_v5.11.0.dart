// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.11.0
// ================================================
// Релиз по карточке lingotune-006 (план «Центр обновлений Aila»,
// scheduler-056, канон — D:\Scheduler\UPDATES-SYSTEM.md §3–5): источник
// обновлений по умолчанию — семейный центр Aila (манифест v2), GitHub
// Releases — автоматический резерв; явная «✓ У вас последняя версия»;
// сверка sha256 скачанного APK; publish-скрипт релиза в оба канала.
// Дата: 23.10.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.10.0 → 5.11.0
+ crypto: ^3.0.3 (sha256 скачанного APK)

// app/android/app/build.gradle
versionCode: 242 → 243
archivesBaseName: "LingoTune-v5.10.0" → "LingoTune-v5.11.0"

// app/lib/app_info.dart
static const String version     = '5.10.0' → '5.11.0'
static const String versionCode = '242'   → '243'
features: строки про GitHub-канал переписаны под Aila + 2 новые

// 🔄 ФИЧА: ИСТОЧНИК ОБНОВЛЕНИЙ — ЦЕНТР AILA (ОСНОВНОЙ), GITHUB — РЕЗЕРВ
// ================================================
// lib/services/update_service.dart:
//   • default-цепочка проверки: ручной URL (если задан в Настройках) →
//     манифест Aila
//     https://aila.skillcoin.pp.ua/updates/lingotune/manifest.json →
//     GitHub Releases (api.github.com/…/releases/latest);
//   • манифест v2 (UPDATES-SYSTEM.md §4): versionName, versionCode,
//     notes, assets[{name,url,size,sha256,kind,abi}]; из assets клиент
//     берёт свой APK (при нескольких — kind:release); web-релиз без
//     APK-asset для этого клиента «не существует» → идёт резерв;
//   • сравнение Android — по versionCode (у GitHub — по тегу релиза):
//     одинаковый versionName с большим code = обновление;
//   • ОТВЕТИВШИЙ источник авторитетен: «нет обновления» не переключает
//     на резерв (резерв — только от недоступности);
//   • UpdateCheckResult (updateAvailable / upToDate /
//     sourceUnavailable) вместо AppUpdate?-null «обо всём»: ручная
//     проверка честно различает «✓ последняя версия» (зелёный) и
//     «не удалось проверить» (красный) — пожелание Артёма;
//   • downloadUpdate: после загрузки sha256 файла сверяется с манифестом
//     (регистронезависимо); несовпадение = файл повреждён → удалить и
//     «не удалось скачать» (целостность, UPDATES-SYSTEM.md §5).
//     Источники без sha256 (старый GitHub/простой манифест) — без сверки.
//
// lib/services/update_flow.dart:
//   • manualCheck: три исхода — диалог обновления / зелёная строка
//     «✓ У вас последняя версия» / красная «Не удалось проверить
//     обновления» (раньше недоступность источника маскировалась под
//     «обновлений нет»);
//   • maybeAutoCheck — как прежде тихий (нет источника ≠ ошибка).
//
// l10n: значения 3 ключей × 11 локалей (noUpdatesAvailable с «✓»,
// updateSourceDefault «Центр обновлений Aila (по умолчанию)»,
// updateSourceSubtitle про запасной канал); ключей по-прежнему 716.

// 🚀 publish_release.ps1 (новый, корень проекта)
// ================================================
// Публикация релиза ОДНОЙ командой в оба канала:
//   1) Aila: node D:\Scheduler\tools\publish-update.cjs lingotune
//      --version --code --notes-file CHANGELOG.md (последняя запись «## …»);
//   2) GitHub Releases (резерв): REST API — релиз с тегом v<версия> +
//      upload APK-asset (перезаливка: существующий asset удаляется);
//      токен: GITHUB_TOKEN или .github_release_token в корне
//      (в .gitignore); нет токена → канал пропущен с предупреждением,
//      релиз всё равно опубликован (Aila — источник правды);
//   • -Version/-Code по умолчанию из pubspec/build.gradle, -DryRun,
//     -SkipAila/-SkipGitHub; выход 0 = основной канал ОК.

// 📖 Документация
// ================================================
// README.md (версия, раздел обновлений), AGENTS.md (версия, раздел
// «Auto-update», publish-скрипт), docs/CHANGELOG.md (v5.11.0),
// CHANGELOG.md (запись задачи).
