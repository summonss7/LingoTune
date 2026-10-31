---
id: lingotune-010
title: Лог: unhandled-исключение в _SongLibraryScreenState._loadSongs на старте (setState по null state)
status: done
priority: 7
created: 2026-10-31
updated: 2026-10-31
session: ""
---
## Задача
Выявлено в logcat при полевой проверке на эмуляторе (карточка lingotune-008,
API 36, release v5.12.0): сразу после старта приложения дважды пишется
«Unhandled Exception: Null check operator used on a null value» с трейсом
`State.setState (framework.dart:1219)` ←
`_SongLibraryScreenState._loadSongs (song_library_screen.dart:140)`.
На работу не влияет (экран библиотеки живёт), но засоряет лог и указывает на
гонку: `_loadSongs` вызывает setState после потери/до готовности state
(вероятно, отсутствует проверка `mounted` после await).

Починить: добавить `mounted`-проверку (стандарт проекта, см. AGENTS.md
«Async/Error Handling»), воспроизвести/проверить на свежем старте приложения.

## Критерии готовности
- [x] Причина гонки локализована и устранена (mounted-проверка или эквивалент)
- [x] flutter test зелёные, flutter analyze без новых предупреждений
- [x] На чистом старте (logcat) исключение больше не появляется
- [x] CHANGELOG.md дополнен

## Журнал
- 31.10.2026: карточка создана по итогам E2E-проверки lingotune-008 (logcat).


- 31.10.2026, 14:32:31: диспетчер взял задачу в работу (новый запуск).
- 31.10.2026, 16:14–16:29: причина локализована: `_loadSongs()` вызывается дважды при
  создании экрана (initState + didChangeDependencies), а в catch-блоке стоял
  незащищённый setState (оригинальная строка 140) — в release (assertions сняты)
  setState на disposed state падает на `_element!` → «Null check operator used on a
  null value»; двойной вызов объясняет две записи в логе. Фикс (начат в предыдущем
  сеансе, верифицирован и оформлен в этом): mounted-проверка после каждого await в
  `_loadSongs` (в т.ч. catch: setState + SnackBar под `if (mounted)`, ошибка —
  debugPrint), `_loadSortPreference` и `_checkTimestampsValidity` (mounted после
  каждого await + `if (mounted) setState`). Проверка: flutter analyze 231 issues
  (базовый уровень, 0 ошибок, новых нет); flutter test 84 passed; release v5.12.1
  собран в builds\LingoTune-v5.12.1.apk, установлен на эмулятор (AVD lecards_test,
  API 35): серия холодных стартов (в т.ч. после pm clear — условия свежей установки)
  и 3 прогона «старт → вкладка Library на 5-й секунде → быстрое переключение
  вкладок» — grep по logcat «Unhandled Exception|Null check operator» дал 0 во всех
  прогонах. Наблюдение (не блокер): тап по «Default Start Screen» в настройках
  не открывал диалог выбора при UI-автоматизации — при случае проверить руками.
  Карточка закрыта.
