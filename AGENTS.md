# AGENTS.md

<!-- ОБЩИЙ-СТАНДАРТ-КОДИРОВАНИЯ -->
## Общий стандарт программирования

Правила кода и процесса — **CODING-STANDARD.md** в корне проекта (общий для всех 14 проектов,
канон — D:\Scheduler\CODING-STANDARD.md). Главное: копия проекта через backup.bat перед
серьёзными изменениями; тесты после правок; сборки в builds/ (версия + debug/release);
временные файлы удаляем; проблема — мгновенный фикс или карточка; идеи новшеств —
на согласование в чат Aila «Хаб ИИ»; коммит → push в том же сеансе; отчётность по задачам —
только записью в CHANGELOG.md с датой и временем начала и окончания работы
(promt.txt заморожен, карточка scheduler-035).
<!-- /ОБЩИЙ-СТАНДАРТ-КОДИРОВАНИЯ -->

<!-- ДИСПЕТЧЕР-ПРОТОКОЛ-КАРТОЧЕК -->
## Система карточек задач (диспетчер)

Проектом управляет диспетчер задач (D:\Scheduler, scheduler.cjs). Задания — карточки-файлы
NNN-название.md в CARDS/: шапка между --- (id, title, status, priority, created, updated,
session), затем разделы «Задача», «Критерии готовности» (чек-лист), «Журнал». Статусы:
todo | in_progress | review | done | blocked.

1. Получив задание — прочитай карточку целиком; поставь status: in_progress и обнови
   updated (поля id и session не менять).
2. Выполни задачу полностью; существенные шаги кратко фиксируй в «Журнале»; перед завершением
   проверь КАЖДЫЙ критерий готовности по факту и отметь [x]; все отмечены — status: done;
   упёрся в блокер — status: blocked с причиной в журнале.
3. Других больших задач вне карточки не начинай; выявленные работы — отдельными карточками
   в CARDS/ (status: todo, с конкретными критериями готовности). Номер и id новой карточки
   (id: <проект>-NNN) — по факту папки: МАКСИМАЛЬНЫЙ номер в CARDS/ + 1; «номер родителя
   + 1» и номера из старых планов дают дубль id — он роняет «Все задания» Aila (aila-274),
   диспетчер перенумеровывает такие дубли сам.
4. Нужен ответ хозяина — вопрос в «Хаб ИИ» Aila (JSON-строка kind:question в
   D:\Aila\server\data\ai-outbox.jsonl, протокол — в шапке ai-hub.md), в шапке карточки
   wait: <id вопроса> и status: blocked — диспетчер сам подшьёт ответ Артёма в «Журнал»
   и вернёт карточку в очередь.
<!-- /ДИСПЕТЧЕР-ПРОТОКОЛ-КАРТОЧЕК -->

## Карта проекта

- LingoTune — Flutter/Dart 3.0+ приложение для изучения языков через музыку + Python-утилиты.
  Версия 5.12.2: `app/pubspec.yaml`, `app/lib/app_info.dart`, `app/android/app/build.gradle`.
- Папки: `app/` (Flutter), `scripts/` (Python), `input/`+`output/` (песни), `docs/`
  (ARCHITECTURE, CONTENT_PIPELINE, CHANGELOG, SETUP, DATA_FORMATS, TROUBLESHOOTING, plans/,
  archive/), `CARDS/` (карточки), `builds/` (релизные APK, только сюда).
- Команды (из `app/`): `flutter pub get` · `flutter test` · `flutter analyze` ·
  `dart format .` · `flutter build apk --release`.
- Релиз: `build_apk_v5.7.4.ps1` (APK → `builds\`), публикация — `publish_release.ps1`
  (Aila + GitHub Releases).

## Ключевые инварианты

- `ThemeData` — только в `main.dart`; статусные цвета (зелёный/красный/оранжевый) не менять.
- Сервисы — `ChangeNotifier` + `notifyListeners()`, освобождение в `dispose()`.
- Async в UI: `try-catch` + `debugPrint`, `mounted` после await; модели — `fromJson`/`toJson`/
  `copyWith`; импорты: core → package → local.
- `AudioService` — источник истины по воспроизведению и циклу; метки времени — живой
  `player.position` через `AudioPositionCorrector`.
- Паузы режима обучения — через `onUserPause`/`onUserPlay`, внутренние вызовы —
  `pauseFromStudy()`/`playFromStudy()`.
- `TtsCoordinator` — синглтон, приоритет study > alert, смены под `_sourceLock`.
- Строки — `AppLocalizations.of(context)`; БД — `DatabaseService`, записи в транзакциях.
- После правок — `flutter analyze` + `flutter test`; pubspec → `flutter pub get`.

## База знаний

Подробная база знаний — **KNOWLEDGE.md** в корне (вынесена из AGENTS.md, карточка
scheduler-064). Разделы:

- **Project Structure** — назначение папок.
- **Code Style Guidelines** — код Dart/Python.
- **Testing** — тесты.
- **Localization** — строки UI, l10n.
- **Theming** — темы, «Аметист».
- **State Management** — Provider.
- **Database** — sqflite.
- **Audio** — плеер, циклы, звонки.
- **Study Mode** — режим обучения.
- **Text-to-Speech** — TTS-движки.
- **Phone-call Detection** — звонки.
- **Car Detection** — детектор машин.
- **Auto-update** — обновления, релизы.
- **Audio visualizer** — эквалайзер.
- **Key Patterns** — async, null safety.
- **Dependencies Management** — зависимости.
- **File Organization** — где что лежит.
