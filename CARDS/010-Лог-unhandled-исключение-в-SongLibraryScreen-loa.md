---
id: lingotune-010
title: Лог: unhandled-исключение в _SongLibraryScreenState._loadSongs на старте (setState по null state)
status: todo
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
- [ ] Причина гонки локализована и устранена (mounted-проверка или эквивалент)
- [ ] flutter test зелёные, flutter analyze без новых предупреждений
- [ ] На чистом старте (logcat) исключение больше не появляется
- [ ] CHANGELOG.md дополнен

## Журнал
- 31.10.2026: карточка создана по итогам E2E-проверки lingotune-008 (logcat).
