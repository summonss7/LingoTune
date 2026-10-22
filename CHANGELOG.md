# CHANGELOG — LingoTune 🎵

Изучение языков через музыку (Android, Flutter).
История изменений проекта: каждая правка фиксируется записью — дата и время,
что сделано, как проверено, коммит. Новые записи дописываются **в конец файла**
(хронология: старые вверху, новые внизу).

Релизная история версий v4.6.15 → 5.8.12 — в docs/CHANGELOG.md
(консолидированная версия всех релизов; детальные листы — CHANGELOG_v*.dart
в корне). Этот файл — накопительный журнал диспетчерской эпохи: он не дублирует
релизные секции, а фиксирует каждую правку подряд, как она случалась.

Файл введён 11.10.2026 (карточка scheduler-033): история изменений перенесена
сюда из promt.txt целиком, без потерь — отчёты «## …», детальные блоки
диспетчера «✓ ВЫПОЛНЕНО …» и отметки «✓ …». promt.txt остаётся оперативной
лентой (задания и свежие отчёты), накопительная история — здесь. Правило
ведения — D:\Scheduler\RULES.txt и CODING-STANDARD.md (§9).

---

## 04.10.2026 09:53 — Сортировка заданий в promt.txt по дате (карточка lingotune-001)

- Что сделано:
  - перед изменением создан бэкап проекта: backups/LingoTune_backup_2026-10-04_09-50.zip (backup.bat);
  - promt.txt разбит на 35 блоков «дата + задания», блоки отсортированы по возрастанию даты:
    первая (вверху) 18.02.2026, последняя (внизу) 01.10.2026;
  - сохранены кодировка UTF-8, переводы строк CRLF и отсутствие завершающего перевода строки
    в конце файла (как в оригинале); при перестановке нормализованы терминаторы строк,
    чтобы последний блок исходного файла не склеивался со следующим заголовком даты.
- Как проверено:
  - мультимножество строк результата байт-в-байт совпадает с копией из бэкапа (1969 строк,
    ничего не потеряно и не добавлено — чистая перестановка блоков);
  - программная проверка: 35 заголовков дат идут строго по возрастанию, склеек нет;
  - flutter test (app/): 39/39 passed.
- Коммит: e38031edffbaddde957e362a71b8ec3c540b0838 «Complete task lingotune-001: sort promt.txt
  task entries by date ascending (latest at bottom)» — закоммичена карточка задачи
  CARDS/001 (promt.txt исключён из git правилом .gitignore:85, отчёт ведётся вне коммита).

---

## ✓ 04.10.2026, 09:54:24 — выполнено (задача из TASKS.txt): отсортируй в promt.txt все задания по дате, последняя дата внизу файла — выполнена 04.10.2026, 09:54:24



---

## 04.10.2026 22:05 — Проверка пути сборки APK: всё идёт в D:\LingoTune\builds, не в корень (карточка lingotune-002)

- Что сделано:
  - аудит всех 5 точек сборки (build_apk_v5.7.4.ps1 / build_apk_v5.3.0.ps1 / build_apk_v4.6.12.ps1 / build_v4.6.12.bat / scripts\build_apk.bat) — все копируют итоговый APK в D:\LingoTune\builds\, ни одна в корень; посторонних APK/AAB вне builds\ и app\build не найдено;
  - источник подозрения найден: правки путей Ai-LingoTune → LingoTune (после переименования каталога 01.10) лежали в build-скриптах НЕ закоммиченными — в git была старая версия с путями D:\Ai-LingoTune; закоммичены в этом коммите;
  - scripts\build_apk.bat: относительный cd app заменён на абсолютный cd /d "D:\LingoTune\app" + проверка errorlevel — запуск двойным кликом из scripts\ больше не уводит скрипт в чужой каталог;
  - build_apk_v5.7.4.ps1: после flutter clean вычищается закисший инкрементальный стейт Gradle/Kotlin (android\.gradle, android\.kotlin, android\build, android\app\build) — первый прогон упал на Gradle-задаче :app:packageRelease (IncrementalSplitterRunnable), после полной чистки сборка проходит стабильно;
  - документация: docs/SETUP.md — раздел «Сборка release APK» (канонический скрипт + правило «итоговый APK только в builds\»), AGENTS.md — блок «Release APK destination»; ROADMAP.md в проекте отсутствует;
  - перед изменениями создан бэкап: backups/LingoTune_backup_2026-10-04_21-42.zip (66 МБ).
- Как проверено:
  - flutter test (app/): 39/39 passed;
  - сквозной прогон build_apk_v5.7.4.ps1 (clean → pub get → build → copy): BUILD SUCCESSFUL, APK лёг в D:\LingoTune\builds\LingoTune-v5.8.11.apk (225 088 531 байт — размер байт-в-байт как у релизной сборки от 24.09, код app/ не менялся);
  - список файлов в корне проекта до/после сборки идентичен (diff), поиск посторонних *.apk по всему проекту — 0;
  - резолвинг пути ..\builds из app\ проверен явно = D:\LingoTune\builds.
- Коммит: 8864ffc «Complete task lingotune-002: APK builds land in D:\LingoTune\builds, never project root» (16 файлов: build-скрипты, l10n-скрипты, docs/SETUP.md, docs/CONTENT_PIPELINE.md, AGENTS.md, CHANGELOG_v5.7.5.dart, карточка CARDS/002; promt.txt вне git по .gitignore).✓ 04.10.2026, 22:07:00 — выполнено (задача из TASKS.txt): Проверь или сборка идет точно в D:\LingoTune\builds а то есть подозрение что в корень идет, если что исправь — выполнена 04.10.2026, 22:07:00

---

## ✓ 05.10.2026, 10:57:52 — выполнено (задача из TASKS.txt): Проверь или сборка идет точно в D:\LingoTune\builds а то есть подозрение что в корень идет, если что исправь — выполнена 05.10.2026, 10:57:52



---

## ✓ ВЫПОЛНЕНО — 05.10.2026, 15:25:14 (задание из TASKS.txt, карточка lingotune-002)

Задание (оригинал):
Проверь или сборка идет точно в D:\LingoTune\builds а то есть подозрение что в корень идет, если что исправь
Начало выполнения: 04.10.2026, 21:36:46
Окончание: 05.10.2026, 15:25:14
Сделано:
- 04.10.2026, 21:37–21:45: аудит всех точек входа сборки (build_apk_v5.7.4.ps1,
- 04.10.2026, 21:42: бэкап проекта: backups/LingoTune_backup_2026-10-04_21-42.zip (66 МБ).
- 04.10.2026, 21:44: flutter test — 39/39 passed.
- 04.10.2026, 21:45: scripts/build_apk.bat: относительный `cd app` заменён на абсолютный
- 04.10.2026, 21:47–21:53: прогон build_apk_v5.7.4.ps1 целиком упал на Gradle-задаче
- 04.10.2026, 21:56–21:58: финальный скрипт-прогон целиком (clean + pub get + build +
- 04.10.2026, 21:59: документация: docs/SETUP.md — раздел «Сборка release APK» описывает
- 04.10.2026, 22:00: статус done, отчёт в promt.txt, коммит (правки скриптов + docs +
Полный журнал и критерии — в карточке CARDS/002-Проверь-или-сборка-идет-точно-в-D-LingoTune-buil.md.

---

## 10.10.2026 13:40 — Фикс: режим «одна песня по кругу» не перезапускал песню (карточка lingotune-003)

- Что сделано (v5.8.12, versionCode 240):
  - бэкап до изменений: backups/LingoTune_backup_2026-10-10_13-12.zip (backup.bat);
  - корневая причина: LoopMode.one был единственным режимом без страховки завершения —
    AudioService._onSongCompleted делал ранний return → onSongComplete экрана не вызывался →
    completion watchdog никогда не вооружался; плюс ловушка just_audio «play() на completed —
    тихий no-op» добивала любой сбой рестарта вечной тишиной; в study-режиме сырой рестарт
    хендлера гонялся с перезагрузкой _playSong от study-детектора;
  - исправления: (1) completion watchdog для loop-one — no-op trap / замершая позиция → полная
    перезагрузка песни (до 5 попыток на эпизод, пауза пользователя уважается); (2) хендлер не
    запускает сырой рестарт при активной study-сессии (новый колбэк isStudySessionActive),
    _restartLoopOne абортится при call-паузе; (3) play()/playFromStudy() при completed сначала
    seek(0) — кнопка play на доигравшей песне больше не молчит; (4) onLoopOneRestartFailed
    переносится на 1.5 с при занятой загрузке вместо молчаливого отбрасывания;
  - версия 5.8.11 → 5.8.12 (pubspec.yaml, app_info.dart +1 feature, build.gradle);
    CHANGELOG_v5.8.12.dart, docs/CHANGELOG.md, AGENTS.md (раздел Track completion),
    README.md (строка версии отставала с 5.8.3). ROADMAP.md в проекте отсутствует.
- Как проверено:
  - flutter analyze: 231 info/warning — все существовали до правок, 0 ошибок;
  - flutter test: 39/39 passed;
  - сборка release: build_apk_v5.7.4.ps1 → BUILD SUCCESSFUL,
    D:\LingoTune\builds\LingoTune-v5.8.12.apk (225 104 915 байт, release); в корне проекта
    посторонних APK/AAB нет;
  - ручная проверка на устройстве не выполнялась (нет подключённого телефона) — логика
    проверена трассировкой кода по всем путям завершения (обычный, study, звонок, пауза).
- Коммит: 882daeb «Release LingoTune v5.8.12: repeat-one mode reliably restarts the finished
  song» (11 файлов), запушен в github.com/summonss7/LingoTune (main).

## 11.10.2026, 12:03 — Отчётность диспетчера переведена на CHANGELOG.md, promt.txt заморожен (карточка scheduler-035)

- Начало работы: 11.10.2026, 07:59
- Окончание работы: 11.10.2026, 12:03
- Что сделано: по заданию хозяина вся отчётность по задачам диспетчера теперь ведётся только в CHANGELOG.md — запись обязана нести дату и время НАЧАЛА и ОКОНЧАНИЯ работы; в promt.txt проекты больше ничего не пишут, файл заморожен как архив. В этом проекте: AGENTS.md — блок «Общий стандарт программирования» заменён на версию с новым правилом (стандарт теперь на 14 проектов, вошёл Synchro); CODING-STANDARD.md — побайтовая копия канона v1.2 (D:\Scheduler\CODING-STANDARD.md): §2.5 и §9 переписаны под CHANGELOG-отчётность, чек-лист §11 обновлён. README (абзац про накопительный журнал: вся отчётность в CHANGELOG.md с датой-временем начала и окончания, promt.txt заморожен).
- Как проверено: синхронизация выполнялась скриптом с проверкой каждой замены (замена не найдена — громкий FAIL, таких не было); копия CODING-STANDARD.md сверена с каноном (идентичны); в диспетчере node --check и все 18 тестов tests/ зелёные, смоук-тесты 019/020 адаптированы под CHANGELOG-формат с обязательными строками «Начало/Окончание работы».
- Коммит: b7062f4 «Документация: отчётность диспетчера — только в CHANGELOG.md с датой-временем начала и окончания работы; promt.txt заморожен; стандарт v1.2 на 14 проектов (карточка scheduler-035)» (+ пуш)

## 19.10.2026, 23:48 — Release v5.9.0: переименование плейлистов, эквалайзер без текста, автообновление (карточка lingotune-004)

- Начало работы: 19.10.2026, 23:16
- Окончание работы: 19.10.2026, 23:48
- Что сделано:
  - Бэкап проекта до изменений: backup.bat → backups/LingoTune_backup_2026-10-19_23-19.zip (66 МБ).
  - Фича 1 «переименование плейлиста»: PlaylistService.renamePlaylist (guard на системные
    all_songs/favorites/lang_*; папочные — можно, имя лишь метка); UI — пункт «Переименовать»
    в меню ⋮ карточки плейлиста (PlaylistScreen) и в меню сортировки внутри открытого плейлиста
    (PlaylistSongsScreen; заголовок AppBar обновляется локальным состоянием _playlist);
    диалог с предзаполненным именем (≤60 симв.), дубликаты имён отклоняются.
  - Фича 2 «красивый эквалайзер вместо голого экрана»: widgets/audio_equalizer_widget.dart —
    в PlayerScreen при пустых lyricLines рисуется анимированный эквалайзер (CustomPainter,
    суммы синусоид с детерминированными фазами, рельеф к центру; цвета primary →
    transcriptAccent на «Аметисте»/tertiary в остальных темах); анимируется только пока
    player.playing; подпись «У этой песни пока нет текста».
  - Фича 3 «автообновление» (главная): services/update_service.dart — проверка последнего
    GitHub-релиза summonss7/LingoTune (+ простой JSON-манифест, URL переопределяется ключом
    updateManifestUrl), числовое compareVersions (терпит v-префикс/пререлизы), стриминговое
    скачивание APK в каталог приложения с прогрессом и отменой; services/update_flow.dart —
    авто-чек при старте через 5 с (троттлинг 24 ч), диалог «Доступна новая версия» с «Что
    нового», прогресс-диалог с единственным путём закрытия, установка через open_filex
    (пермиссия REQUEST_INSTALL_PACKAGES в манифесте), фолбэк «Открыть страницу релиза»
    (url_launcher, https-<queries>); Настройки → «Проверить обновления». Зависимости:
    open_filex ^4.5.0, url_launcher ^6.3.1. ВАЖНО: репозиторий приватный — анонимный GitHub API
    отвечает 404, проверка тихо даёт «нет обновлений»; заработает без правок приложения, когда
    хозяин сделает репо публичным и создаст Release с APK (или укажет иной манифест-URL).
  - 22 новых l10n-ключа × 11 локалей (переименование/эквалайзер/обновления), gen-l10n.
  - Версия 5.8.12 → 5.9.0, versionCode 240 → 241 (pubspec, app_info, build.gradle +3 features);
    CHANGELOG_v5.9.0.dart (релизный ритуал), docs/CHANGELOG.md (запись v5.9.0), README.md
    (версия + 3 пункта возможностей), AGENTS.md (версия, раздел Auto-update, File Organization,
    706 l10n-ключей). ROADMAP.md в проекте отсутствует — не требовался.
- Как проверено:
  - flutter test: 51/51 passed, из них 12 новых (test/update_service_test.dart: сравнение
    версий, GitHub-релиз, простой манифест, 404/битый JSON → «нет обновления», override URL,
    троттлинг авто-чека);
  - flutter analyze: 231 info/warning — ровно базовый уровень до правок, 0 ошибок;
  - сборка release: build_apk_v5.7.4.ps1 → BUILD SUCCESSFUL → builds\LingoTune-v5.9.0.apk
    (225 499 517 байт); сборка debug: builds\LingoTune-v5.9.0-debug.apk (322 098 867 байт);
    в корне проекта посторонних APK нет (builds/ в .gitignore);
  - ручная проверка на устройстве не выполнялась (телефон не подключён, AVD эмуляторов нет) —
    логика покрыта юнит-тестами и трассировкой кода; визуальную/полевую проверку (эквалайзер,
    диалоги обновления, установка APK) выполнит Артём при установке LingoTune-v5.9.0.apk.
- Коммит: 6c801b0 «Release LingoTune v5.9.0: playlist rename, no-lyrics equalizer, in-app
  auto-update (card lingotune-004)» (43 файла), запушен в github.com/summonss7/LingoTune (main).

## 20.10.2026, 14:25 — Release v5.10.0: эквалайзер от настоящего звука + кнопка на любой песне, свой адрес манифеста обновлений (карточка lingotune-005)

- Начало работы: 20.10.2026, 10:06
- Окончание работы: 20.10.2026, 14:25
- Что сделано:
  - Бэкап проекта до изменений: backups/LingoTune_backup_2026-10-20_10-37.zip (сеанс реализации).
  - Фича 1 «эквалайзер погружает в музыку» (ритм, такт, громкость): нативный
    AudioVisualizerPlugin.kt — системный android.media.audiofx.Visualizer на глобальном выходном
    миксе отдаёт НАСТОЯЩИЙ FFT играющей музыки (~20 кадров/с → 32 логарифмические полосы 0..255,
    EventChannel lingotune/audio_visualizer/events); Dart-обёртка AudioVisualizerService
    (runtime-запрос RECORD_AUDIO — то же разрешение, что у car detection); чистый Dart-процессор
    AudioBandProcessor: мгновенная атака + экспоненциальный спад (~160 мс), адаптивный гейн
    (тихий трек не «пол», громкий не «потолок», ≤3x), детектор бита (бас против скользящего
    среднего ~2 с, рефрактерные 220 мс), пик-шапки; AudioEqualizerWidget переписан — зеркальные
    столбики, свечение-пульс и «подпрыг» в такт биту; прежняя синусоидная заглушка осталась
    фолбэком (нет разрешения / не Android / ROM не дал создать Visualizer); захват
    останавливается, когда эквалайзер не виден (батарея).
  - Фича 2 «вызвать эквалайзер кнопкой даже на песне с текстом»: кнопка в шапке плеера
    (graphic_eq ↔ lyrics) переключает текст ↔ эквалайзер на любой песне С текстом («надоело
    читать»); выбор переживает перезапуск (prefs playerShowEqualizer); в режиме редактирования
    меток текст показывается принудительно; тултипы + подсветка активного состояния.
  - Фича 3 «автообновление — вариант (б): любой адрес-манифест»: UpdateService
    .getCustomManifestUrl/.setCustomManifestUrl (JSON {"version","downloadUrl",...} или GitHub
    API; пустое/null → сброс на GitHub Releases по умолчанию); Настройки → «Источник обновлений»:
    диалог с валидацией http(s), кнопка «Сбросить», зелёный SnackBar подтверждения.
  - 10 новых l10n-ключей × 11 локалей (updateSource*, showEqualizerTooltip, showLyricsTooltip);
    706 → 716 ключей; gen-l10n.
  - Версия 5.9.0 → 5.10.0, versionCode 241 → 242 (pubspec, app_info +3 features, build.gradle
    archivesBaseName); CHANGELOG_v5.10.0.dart (релизный ритуал), docs/CHANGELOG.md (запись
    v5.10.0), README.md (версия + пункты возможностей), AGENTS.md (версия, раздел «Audio
    visualizer», Custom update source, File Organization, 716 l10n-ключей). ROADMAP.md в проекте
    отсутствует — не требовался. Мелкий фикс: в MainActivity регистрируется поле
    audioVisualizerPlugin (а не новый экземпляр) — единый стиль с остальными нативными плагинами.
- Как проверено:
  - flutter test: 63/63 passed, из них 11 новых (test/audio_band_processor_test.dart — 8:
    атака/спад, шапки, бит + рефрактерность, гейн; test/update_service_test.dart — 3: round-trip
    кастомного URL, сброс пустой строкой и null);
  - flutter analyze: 231 info/warning — ровно базовый уровень до правок, 0 ошибок, новых
    замечаний не внесено;
  - сборка release: build_apk_v5.7.4.ps1 → BUILD SUCCESSFUL → builds\LingoTune-v5.10.0.apk
    (225 614 289 байт); сборка debug: builds\LingoTune-v5.10.0-debug.apk (322 127 551 байт);
    в корне проекта посторонних APK нет (builds/*.apk в .gitignore);
  - ручная проверка на устройстве не выполнялась (телефон не подключён, AVD эмуляторов нет) —
    логика покрыта юнит-тестами и трассировкой кода; визуальную/полевую проверку (танцующий
    эквалайзер, кнопка текст↔эквалайзер, смена источника обновлений) выполнит Артём при
    установке LingoTune-v5.10.0.apk.
- Коммит: de0ec15 «Release LingoTune v5.10.0: real-spectrum equalizer (beat/rhythm),
  lyrics↔equalizer toggle, custom update manifest URL (card lingotune-005)» (40 файлов) —
  запушен в github.com/summonss7/LingoTune (main).

## 23.10.2026, 01:16 — Release v5.11.0: источник обновлений — центр Aila (манифест v2), GitHub — резерв; «✓ последняя версия», sha256, publish-скрипт (карточка lingotune-006)

- Начало работы: 23.10.2026, 00:51
- Окончание работы: 23.10.2026, 01:16
- Что сделано:
  - Бэкап до изменений: backups/LingoTune_backup_2026-10-23_00-51.zip.
  - UpdateService: источник по умолчанию — манифест v2 центра Aila
    (https://aila.skillcoin.pp.ua/updates/lingotune/manifest.json), GitHub Releases —
    автоматический резерв при недоступности канала; ответивший источник авторитетен
    («нет обновления» не переключает на резерв). Настройка «Источник обновлений»
    сохранена: ручной URL проверяется первым, при его недоступности — обычная цепочка.
  - Поддержка формата v2 (versionName/versionCode/notes/assets[{url,size,sha256,kind}]);
    сравнение Android по versionCode (у GitHub — по тегу); web-манифест без APK-asset
    для клиента «не существует».
  - downloadUpdate: сверка sha256 скачанного APK с манифестом (пакет crypto);
    несовпадение — файл удалён, скачивание считается неудачным.
  - UpdateCheckResult (updateAvailable/upToDate/sourceUnavailable): ручная проверка
    теперь честно различает «✓ У вас последняя версия» (зелёный) и «не удалось
    проверить» (красный) — раньше недоступность маскировалась под «обновлений нет».
  - publish_release.ps1 (новый, корень): публикация релиза в ОБА канала одной
    командой — центр Aila (node D:\Scheduler\tools\publish-update.cjs lingotune,
    манифест v2 + sha256 + история + «📦 Обновление» в «Хабе ИИ») и GitHub Releases
    (REST API, тег v<версия> + APK-asset; токен GITHUB_TOKEN или .github_release_token,
    файл в .gitignore; нет токена — канал пропущен с предупреждением). -DryRun,
    -SkipAila/-SkipGitHub, -Version/-Code из pubspec/build.gradle по умолчанию.
  - l10n: значения 3 ключей × 11 локалей (noUpdatesAvailable с «✓», updateSourceDefault
    «Центр обновлений Aila (по умолчанию)», updateSourceSubtitle); ключей 716, gen-l10n.
  - Версия 5.10.0 → 5.11.0, versionCode 242 → 243 (pubspec, app_info +2 features,
    build.gradle archivesBaseName); CHANGELOG_v5.11.0.dart (релизный ритуал),
    docs/CHANGELOG.md (запись v5.11.0), README.md (версия + пункт обновлений),
    AGENTS.md (версия, раздел «Auto-update», publish-скрипт).
- Как проверено:
  - flutter test: 71/71 passed, из них 8 новых в test/update_service_test.dart
    (v2-манифест: больший/равный versionCode, versionName==но code>, фолбэк Aila→GitHub
    по 404 и по исключению, sourceUnavailable, ручной URL приоритетнее и его фолбэк,
    sha256: совпал/не совпал/нет хэша);
  - flutter analyze: 231 info/warning — ровно базовый уровень, 0 ошибок;
  - publish_release.ps1 -DryRun: план публикации 5.10.0 (code 242) в Aila корректен,
    GitHub-канал честно сообщает об отсутствии токена;
  - сборка release: build_apk_v5.7.4.ps1 → BUILD SUCCESSFUL → builds\LingoTune-v5.11.0.apk
    (225 630 673 байт); сборка debug: builds\LingoTune-v5.11.0-debug.apk (322 139 531 байт);
  - живая проверка канала: publish_release.ps1 опубликовал v5.11.0 (code 243) в центр Aila
    («Опубликовано ✔ lingotune 5.11.0, 1 файл, sha256 f29d2e22…»); публичный манифест
    …/updates/lingotune/manifest.json отдаёт v2 (versionName 5.11.0, versionCode 243,
    assets[0].sha256) — sha256 манифеста побайтово совпал с локальным APK; НАСТОЯЩИЙ
    манифест (живые байты канала) прогнан через настоящий UpdateService → вердикт
    «у вас последняя версия» (upToDate, 243 == 243); сценарий «подменённый манифест с
    большей versionCode → баннер/скачивание» покрыт юнит-тестами (code 999, sha256
    совпал/не совпал). Прямой HTTP-запрос из Dart-теста на этой машине блокирует
    локальный web-фильтр (пустой 400 всем Dart-процессам, curl проходит) — полевую
    проверку на телефоне (баннер + установка) выполнит Артём при установке
    LingoTune-v5.11.0.apk.
- Коммит: 3ec874e «Release LingoTune v5.11.0: Aila update center as default source (manifest v2), GitHub fallback, explicit latest-version status, sha256 verification, dual-channel publish script (card lingotune-006)» (39 файлов) — запушен в github.com/summonss7/LingoTune (main).
