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

## 30.10.2026, 21:35 — Release v5.12.0: повтор отрезка A–B — крути выбранный кусок песни, а не всю (карточка lingotune-007)

- Начало работы: 30.10.2026, 20:05
- Окончание работы: 30.10.2026, 21:35
- Что сделано (пожелание Артёма от 30.10.2026: «повторять песню кусочком —
  не всю песню по кругу, а какую-то часть песни»):
  - новая кнопка «A–B» на панели плеера (справа от кнопки режимов повтора):
    тап — точка A, тап — точка B (отрезок играет по кругу), тап — сброс,
    долгое нажатие — сброс из любого состояния; каждое действие — SnackBar
    со временем точки («Начало отрезка A: 0:12», «Повтор отрезка включён:
    0:12 – 0:25»);
  - отрезок подсвечивается на полосе прогресса (кастомный трекшейп слайдера
    lib/widgets/ab_repeat_slider_track.dart: полоса A..B + метки краёв,
    пока выставлена только A — метка начала);
  - чистая логика — lib/services/ab_repeat_controller.dart (конечный автомат
    idle → A → A..B-цикл; тап-B раньше A переезжает точкой A; минимум 1 с);
  - enforcement цикла — в AudioService по ЧАСТОМУ потоку позиций
    (createPositionStream, maxPeriod 80 мс, перелёт за B на слух незаметен),
    прыжок сырым _player.seek(A) — работает и в фоне; окно 400 мс после
    явного seek'а (скраб слайдера, ±10 с) цикл не срабатывает — не борется
    с перетаскиванием ползунка; сброс при loadAudio (смена песни);
  - при старте study-режима (кнопка / автостарт / рестарт после seek)
    повторитель сбрасывается, кнопка гаснет — сегменты study и цикл
    конфликтуют за seek;
  - точки ставятся по LIVE player.position (wall-clock — тот же домен
    времени, что у меток таймкодов, правило v5.8.4);
  - l10n: 8 ключей × 11 локалей (724 ключа всего); версия 5.12.0/244
    (pubspec, app_info.dart, build.gradle); README.md, AGENTS.md,
    docs/CHANGELOG.md, CHANGELOG_v5.12.0.dart (релизный ритуал).
- Как проверено:
  - flutter test: 84/84 passed, из них 15 новых в
    test/ab_repeat_controller_test.dart (фазы, границы ≥1 с, tooShort,
    переезд A, сброс, shouldLoopBack до/на/после B, уведомления слушателей);
  - flutter analyze: 0 ошибок, 231 info/warning — ровно базовый уровень
    (новых предупреждений нет);
  - сборка release: build_apk_v5.7.4.ps1 → BUILD SUCCESSFUL →
    builds\LingoTune-v5.12.0.apk (225 663 441 байт); сборка debug:
    builds\LingoTune-v5.12.0-debug.apk;
  - publish_release.ps1: релиз опубликован в центр обновлений Aila
    («Опубликовано ✔ lingotune 5.12.0», sha256 492568bf45d7…, манифест
    https://aila.skillcoin.pp.ua/updates/lingotune/manifest.json, уведомление
    в «Хаб ИИ»); GitHub Releases — резервный канал пропущен: токен не задан
    (нет GITHUB_TOKEN/.github_release_token; Aila — источник правды).
- Коммит: 2bed4f5 «Release LingoTune v5.12.0: A-B section repeat — loop any part of a song (button A–B, slider segment highlight, background-safe; card lingotune-007)» — запушен в github.com/summonss7/LingoTune (main).

## 31.10.2026, 06:10 — Release v5.12.1: починка самообновления — баннер «есть новая версия» теперь реально приходит и устанавливается (карточка lingotune-008)

- Начало работы: 31.10.2026, 04:31
- Окончание работы: 31.10.2026, 06:10
- Что сделано (пожелание Артёма от 30.10.2026: «захожу в программу — она пишет,
  что есть новая версия, я соглашаюсь — и оно её устанавливает. Почему-то пока
  не работает»):
  - диагностика: механизм самообновления (v5.9.0–v5.11.0) исправен; причина
    «не работает» — центр обновлений ни разу не публиковал версию новее
    установленной у Артёма (каждый релиз он ставит вручную из builds/ в момент
    публикации, канал никогда не оказывался «впереди» телефона: пожелание
    пришло 30.10 20:39, v5.12.0 опубликована в 21:33 — центр предлагал ту же
    5.11.0/243, что стояла на телефоне). Доп. факторы: автопроверка раз в сутки,
    «сгорание» проверки при сбое источника, полевая проверка цепочки не
    проводилась со времён v5.11.0; GitHub-резерв недоступен анонимно (приватный
    репозиторий, API 404) — задокументированное ограничение, Aila — источник
    правды;
  - UpdateService.autoCheckInterval: 24 ч → 1 ч — «захожу в программу — она
    пишет» теперь выполняется в тот же час выхода релиза, а не на следующие
    сутки (один GET маленького манифеста в час — бесплатно для семейного
    сервера);
  - UpdateFlow.maybeAutoCheck: метка lastUpdateCheckMs ставится только когда
    источник ОТВЕТИЛ (обновление есть / версия актуальна); временный сбой
    сервера → повтор при следующем запуске (раньше — молчание на сутки);
  - версия 5.12.1/245 (pubspec, app_info.dart — включая строку features,
    build.gradle), сборки builds\LingoTune-v5.12.1.apk (release,
    225 663 437 байт) и builds\LingoTune-v5.12.1-debug.apk;
  - релиз опубликован в центр Aila (publish_release.ps1: манифест 5.12.1/245,
    sha256 c0225bb21917d8ee… побайтово совпал с локальным APK; GitHub-канал
    пропущен — токен не задан, это задокументированный резерв);
  - новые карточки по выявленным ограничениям: lingotune-009 (http://-источник
    обновлений не работает в release — платформа блокирует cleartext),
    lingotune-010 (unhandled-исключение в _SongLibraryScreenState._loadSongs
    в logcat на старте);
  - документация: README.md (версия, частота проверки), AGENTS.md (версия,
    раздел Auto-update: интервал, полевая проверка, ограничения),
    docs/CHANGELOG.md (v5.12.1), CHANGELOG_v5.12.1.dart (релизный ритуал).
- Как проверено:
  - flutter test: 84/84 passed; flutter analyze: 0 ошибок, 231 info/warning —
    ровно базовый уровень (новых нет);
  - ПЕРВАЯ полевая E2E-проверка всей цепочки на эмуляторе Android 16 (API 36)
    против реального центра Aila: установлена v5.12.0/244 → запуск приложения →
    автопроверка через 5 с → баннер «New version available: 5.12.0 → 5.12.1
    (215.2 MB)» с notes → Download → скачано ровно 225 663 437 байт → sha256
    сверен → «Update downloaded» → Install → разовый системный диалог «неизвестные
    источники» → «Do you want to update this app?» → Update → приложение само
    обновилось: dumpsys package → versionCode=245, versionName=5.12.1. Ручная
    проверка из настроек (Settings → Check for updates) — тот же путь, работает;
  - публичный манифест канала: versionName 5.12.1, versionCode 245,
    assets[0].sha256 = c0225bb21917d8ee… (совпадает с локальным APK), размер
    225 663 437 байт; HEAD APK-урла — HTTP 200, Content-Length совпадает.
- Коммит: 7644d5c «Release LingoTune v5.12.1: self-update finally works in the field —
    hourly auto-check, no burn on source failure, first full E2E verify
    (banner→download→sha256→installer→5.12.1/245); cards lingotune-009/010 filed
    (card lingotune-008)» — запушен в github.com/summonss7/LingoTune (main).

- Начало работы: 31.10.2026, 07:43
- Окончание работы: 31.10.2026, 11:30
- Что сделано: экономия квоты, шаг 2 (карточка scheduler-064 диспетчера, план согласован Артёмом в «Хабе ИИ» 31.10.2026 «Всё делать»). ZCode подмешивает AGENTS.md в контекст КАЖДОГО вызова сессий проекта, а 99% входных токенов — ре-отправка контекста (замер scheduler-063), поэтому развёрнутая база знаний в AGENTS.md стоила ~9–10 тыс. токенов на каждый ход. База знаний вынесена в KNOWLEDGE.md в корне (37021 байт — сессия читает разделы по необходимости), AGENTS.md оставлен компактным: общий стандарт, протокол диспетчера (канонический PROTOCOL_TEXT), «Карта проекта», ключевые инварианты (темы, сервисы, TTS, тесты) и указатель разделов KNOWLEDGE.md. Размер 42760 → 6025 байт (−86%): ≈ −9,6 тыс. входных токенов на каждый ход сессий проекта.
- Как проверено: все заголовки разделов старого AGENTS.md присутствуют в KNOWLEDGE.md (сверка grep '^#' по git show HEAD:AGENTS.md и KNOWLEDGE.md); маркеры протокола на месте, блок побайтово равен каноническому PROTOCOL_TEXT из scheduler.cjs; сумма AGENTS.md + KNOWLEDGE.md (43046 байт) покрывает старый файл (42760) — потери знаний нет; перед правкой бэкап backups/LingoTune_backup_2026-10-31_07-51.zip, старая версия остаётся в git.
- Коммит: b2bc2cf (AGENTS.md + KNOWLEDGE.md + эта запись).

## 31.10.2026, 13:22 — Семья приняла Sontse: стандарт v1.3 на 15 проектов (карточка scheduler-062)
- Начало работы: 31.10.2026, 13:11
- Окончание работы: 31.10.2026, 13:22
- Что сделано: Sontse (спин-офф «Солнца» Aila, D:\Sontse) подключён к диспетчеру задач как 15-й проект семьи — реестр D:\Scheduler\projects.json (карточка scheduler-062, желание Артёма: «проект стал известный и дай задание на выполнение»). В этом проекте: CODING-STANDARD.md — побайтовая копия канона v1.3: шапка перечисляет 15 проектов (+ Sontse), история версий дополнена строкой v1.3; сами правила стандарта не менялись.
- Как проверено: копия CODING-STANDARD.md сверена с каноном D:\Scheduler\CODING-STANDARD.md (идентичны).
- Коммит: be7704b «Семья приняла Sontse — стандарт v1.3 на 15 проектов: копия канона (карточка scheduler-062)» (+ пуш)

## 31.10.2026, 14:30 — lingotune-009: http-источники обновлений в release — вопрос Артёму (карточка в ожидании)
- Начало работы: 31.10.2026, 14:27
- Окончание работы: 31.10.2026, 14:30
- Что сделано: диагностика по карточке lingotune-009 подтверждена по коду — валидация «Источника обновлений» принимает http/https (settings_screen.dart:192, update_service.dart:198), но в app/android нет ни android:usesCleartextTraffic, ни network security config, а targetSdk 35 в release запрещает весь cleartext-трафик → любой http://URL манифеста всегда даёт «не удалось проверить» (SocketException: Cleartext not permitted). Решение затрагивает security-постуру приложения, поэтому в «Хаб ИИ» отправлен вопрос Артёму (id lingotune009_q_20261031, варианты: А — разрешить cleartext всему приложению; Б — только https с честным отклонением http, рекомендован; В — только документация) и карточка зарегистрирована в хабе пожеланий (w_lt009http20261031). Карточка переведена в blocked/wait до ответа; после ответа — реализация, тесты, release-сборка в builds/, документация.
- Как проверено: grep по app/android (настроек cleartext нет), grep по коду валидации (обе точки принимают http); обе строки доставлены в D:\Aila\server\data\ai-outbox.jsonl (tail).
- Коммит: 8e0bde2 (+ пуш).

## 31.10.2026, 16:29 — lingotune-010: починен unhandled-исключение в SongLibraryScreen._loadSongs (setState по disposed state)
- Начало работы: 31.10.2026, 16:13
- Окончание работы: 31.10.2026, 16:29
- Что сделано: устранена гонка из logcat-лога полевой проверки (карточка lingotune-008, release v5.12.0): «Unhandled Exception: Null check operator used on a null value» дважды после старта, трейс State.setState ← _SongLibraryScreenState._loadSongs (song_library_screen.dart:140). Причина: _loadSongs() вызывается дважды при создании экрана (initState + didChangeDependencies), а catch-блок содержал незащищённый setState (оригинальная строка 140); в release (assertions сняты) setState на disposed state падает на _element! → «Null check operator». Фикс (song_library_screen.dart): mounted-проверка после каждого await — в _loadSongs после getAllSongs() и в catch (setState + SnackBar под if (mounted), ошибка через debugPrint — стандарт AGENTS.md), в _loadSortPreference после getInstance(), в _checkTimestampsValidity после каждого await и if (mounted) setState в конце.
- Как проверено: flutter analyze — 231 issues (базовый уровень, 0 ошибок, новых нет); flutter test — 84 passed; собран release builds\LingoTune-v5.12.1.apk (build_apk_v5.7.4.ps1, 215,21 МБ), установлен на эмулятор (AVD lecards_test, API 35): серия холодных стартов (в т.ч. после pm clear — условия свежей установки) и 3 прогона «старт → вкладка Library на 5-й секунде → быстрое переключение вкладок» — grep по logcat «Unhandled Exception|Null check operator» = 0 во всех прогонах. Наблюдение (не блокер, вне карточки): тап по «Default Start Screen» в настройках не открывал диалог выбора при UI-автоматизации — проверить руками.
- Коммит: d73919e (+ пуш).

## 31.10.2026, 21:50 — lingotune-009: «Источник обновлений» — только https в release (вариант Б), http отклоняется с пояснением
- Начало работы: 31.10.2026, 17:56
- Окончание работы: 31.10.2026, 21:50
- Что сделано: реализован согласованный с Артёмом вариант Б («Хаб ИИ», 31.10 14:44, кнопка 2). Валидация «Источника обновлений»: новый enum UpdateSourceValidation {ok, httpBlocked, invalid} + UpdateService.validateCustomManifestUrl() и parseCustomManifestUri(allowHttp:) — в release принимается только https, http-URL честно отклоняется отдельным красным снекбаром-пояснением (новая строка l10n updateSourceHttpBlocked добавлена во все 11 локалей, updateSourceInvalid и подпись настройки переформулированы под https-only); в debug (!kReleaseMode) http остался разрешённым для LAN-тестов. Android-конфиг: добавлен app/android/app/src/debug/AndroidManifest.xml с usesCleartextTraffic="true" (только debug-сборки; release-манифест чист — закреплено тестом). Попутно починен .gitignore: широкий паттерн «debug/» съедал android debug-манифест — заменён на «/debug/» (корневая черновая папка), файл теперь под git. Документация: KNOWLEDGE.md, раздел «Custom update source» (база знаний, вынесенная из AGENTS.md карточкой scheduler-064). Версия приложения не поднималась: публикация фикса — отдельным релиз-циклом (publish_release.ps1).
- Как проверено: flutter analyze — 231 issues (базовый уровень, 0 ошибок); flutter test — 91 passed (84 + 7 новых: https/http × allowHttp, валидация диалога, сохранённый http-URL в debug-цепочке проверок, отсутствие cleartext-флагов в release-манифесте); сборки в builds/: LingoTune-v5.12.1-release-lingotune009-rc.apk (215,2 МБ) и LingoTune-v5.12.1-debug-lingotune009-rc.apk (322,2 МБ). P2E на эмуляторе (AVD lecards_test, API 35, перед работой backup.bat): RELEASE — http://192.168.1.10/manifest.json → диалог остаётся открытым, снекбар «HTTP URLs are not supported: the app blocks unencrypted traffic. Use an https://… address» (подтверждён скриншотом), https://example.com/manifest.json → принят и отображён в настройках, Reset → возврат к «Aila update center (default)»; DEBUG — http://127.0.0.1:8377/manifest.json (локальный python http.server + adb reverse) → принят диалогом и сохранён, «Check for updates» скачал манифест по незашифрованному http (GET /manifest.json 200 в логе сервера) и показал диалог «New version: 9.9.9» — debug-overrides работают. Временные файлы (temp/lt009http, adb reverse, сервер) удалены, эмулятор остановлен.
- Коммит: 1dda135 (+ пуш).

## 03.11.2026, 14:35 — lingotune-011: глюки прерываний на замкнутом телефоне — beep SMS глушит перевод, звонок+сообщение застревает песню (v5.12.2)
- Начало работы: 03.11.2026, 11:47
- Окончание работы: 03.11.2026, 14:35
- Что сделано (v5.12.2, versionCode 246): починены два независимых глюка из карточки lingotune-011 («в наушниках на заблокированном телефоне после сообщения перестаёт говорить перевод; звонок + сообщение — песня застревает, через минуту играет новую»). (1) «Перестаёт говорить перевод»: первый speak после резюма прерывания легитимно медленный (drain движка, синтез офлайн-модели, реактивация аудиосессии на замкнутом телефоне) — два ложных срабатывания TTS-watchdog подряд защёлкивали cooldown-глушение на 20–120 с. Фикс: грейс-окно 20 с после resume/старта сессии — запас watchdog'а +8 с (кап 16) вместо +3 (кап 12); drain-таймауты движков укорочены (OfflineTtsEngine.stop 750 мс, SystemTtsEngine.stop 1 с). (2) «Застревает песня»: залипший interruption-begin без end СЕРЕДИНЫ песни вообще не самолечился (только completion-watchdog у конца трека — отсюда «через минуту играет новую»). Фикс: sweep-таймер (тик 2 с) снимает залипшую паузу штатным resume с той же строки, пороги по источнику — эхо-подозрение 6 с / beep 12 с / звонок 20 с (stalePauseThresholdFor); interruption-end при занятой линии больше не резюмит музыку посреди разговора (guard _confirmedNoCall); beep в окне эха при активном просроушивании принимается как echo-suspect (раньше игнорировался → парный end терялся → пауза вечно висела). (3) Попутно найден и починен до-существующий баг: assert androidNotificationOngoing+androidStopForegroundOnPause валил AudioService.init во ВСЕХ debug-сборках с первого коммита (BackgroundAudioHandler не создавался) — флаг убран из main.dart, на release-поведении не сказывается (сервис всегда foreground, уведомление и так ongoing; на API<33 исчезает cancel-кнопка media-style). Документация: KNOWLEDGE.md — новый раздел «Interruption policy»; версии в AGENTS.md/README.
- Как проверено: flutter analyze — 231 issues (базовый уровень, 0 ошибок); flutter test — 97 passed (91 + 6 новых в app/test/interruption_policy_test.dart: пороги stalePauseThresholdFor × 3 сценария, окно ttsWatchdogSeconds обычное/грейс/монотонность); сборки в builds/: LingoTune-v5.12.2.apk (release, 215,2 МБ) и LingoTune-v5.12.2-debug.apk (322,2 МБ). P2E на эмуляторе (AVD lecards_test, API 36, перед работой backup.bat 11:53): debug-сборка — AudioService.init проходит (фикс main.dart), импорт Test Song (wav+zip с RU-переводом), study mode активен на заблокированном экране; сценарий A (SMS на замкнутом экране): interruption begin 14:18:58 → пауза study, end через 2,6 с → резюм с той же строки (line 9), перевод синтезируется дальше; сценарий B (звонок 6 с + SMS во время звонка + SMS сразу после отбоя): ringing → пауза от детектора, begin рингтона deduped, idle → resumeAfterCall → резюм line 11, эхо-end через 1 с корректно no-op («no prior pause»), сегменты 11–12 доиграны с переводом, конец песни «GUARDED (study active)» — штатная обработка StudyModeService; за всю сессию 0 срабатываний «⚠ StudyMode TTS watchdog», 0 cooldown-глушений. Сценарий «begin без end» на эмуляторе не воспроизводится (ROM шлёт пары begin/end) — прикрыт юнит-тестами порогов + sweep-логикой.
- Коммит: 61be93f (+ пуш)

## 03.11.2026, 17:46 — lingotune-012: приложение не видело новый релиз v5.12.2 — опубликован в центр обновлений, самообновление проверено в поле
- Начало работы: 03.11.2026, 17:09
- Окончание работы: 03.11.2026, 17:46
- Что сделано: диагностика жалобы «вышла новая версия, приложение не увидело обновление ни при запуске, ни по ручной проверке». Причина найдена: релиз v5.12.2 (code 246) был собран и закоммичен (61be93f, lingotune-011), но НЕ опубликован в центр обновлений Aila — публичный манифест всё ещё раздавал 5.12.1/245, и приложение честно отвечало «обновлений нет»; код самообновления исправен (окно «что нового» + кнопки «Скачать»/«Позже» — lingotune-006/008). Лечение: перед работой backup.bat, затем publish_release.ps1 — v5.12.2/246 опубликована в центр Aila с краткими человекочитаемыми notes (первая заливка прошла; перезаливка с новыми notes упёрлась в EPERM-rename на сервере — антивирус держал свежий APK, повтор через ~1 мин прошёл успешно; GitHub-канал пропущен — токена нет, задокументированный резерв). Верификация источника: манифест versionName 5.12.2, versionCode 246, asset sha256 9902c5a3a063… и размер 225 679 825 байт побайтово совпадают с builds/LingoTune-v5.12.2.apk, APK-урл отвечает 200 с тем же Content-Length. Код приложения не менялся — тесты/analyze не требовались.
- Как проверено: полевой E2E на эмуляторе (AVD lecards_test, API 36, cold boot) по сценарию Артёма: установлена v5.12.1/245 (uninstall 5.12.2, оставшейся с прошлой сессии) → запуск → автопроверка → всплыло окно «New version available», Current 5.12.1 → New 5.12.2 (215.2 MB), блок What's new с notes, кнопки Later/Download (скриншот) → Download → прогресс → скачано ровно 225 679 825 байт, «sha256 verified» в логах → «Update downloaded» → Install → разовый системный грант «Allow from this source» (сбросился при uninstall) → «Do you want to update this app?» → Update → dumpsys: versionCode=246, versionName=5.12.2 — приложение самообновилось в поле. На 5.12.2: настройки показывают «Check for updates — Current version: 5.12.2» и «Update source — Aila update center (default)»; ручная проверка → зелёный снекбар «✓ You have the latest version» (подтверждён кадром screencap). Попутное наблюдение, разобрано и закрыто: uiautomator-дамп Flutter-семантик однажды показал фантомную строку «You are on the latest version — 3.16.0» — такой строки в коде/локалях нет, на реальных скриншотах её нет, артефакт дампера скрытых узлов, не баг приложения. Замечание процессу (сообщено Артёму в «Хаб ИИ»): после релизного коммита обязателен шаг publish_release.ps1 — без него центр не узнаёт о версии.
- Коммит: 44c5d18 «lingotune-012: публикация v5.12.2 в центр обновлений Aila…» (+ пуш)

## 06.11.2026, 05:35 — lingotune-013: музыка «лёгким фоном» играла во время мессенджерского звонка (Viber) — наблюдатель VoIP-линии (v5.12.3)

- Начало работы: 06.11.2026, 04:35
- Окончание работы: 06.11.2026, 05:35
- Что сделано (v5.12.3, versionCode 247): починен остаточный глюк из карточки lingotune-013 — при звонке по мессенджеру (Viber и др.) музыка не останавливалась, а «лёгким фоном» играла весь разговор и мешала говорить. Диагноз: VoIP-звонок невидим для TelephonyManager (нативный детектор PhoneCallService молчит), а ROM-дакинг медиапотока на целевых устройствах не присылает interruption-событие audio_session — пауза вообще ничем не ставилась, оставался системный приглушённый звук. Единственный сигнал, видящий мессенджерские звонки, — AudioManager.getMode() (in_call/in_communication), но до сих пор он опрашивался только точечно (при решениях о снятии залипших пауз). Фикс (app/lib/services/background_audio_handler.dart, остальная логика прерываний lingotune-011 НЕ менялась): (1) VoIP-наблюдатель — пока звук звучал (или звучал последние ~2 мин), раз в секунду опрашивается СВЕЖИЙ режим линии; линия занята → пауза ЕДИНЫМ существующим путём _handleCallPause(fromPhoneDetector: true) — study-хендофф, дедупликация, echo-дебаунс, sweep, resumeSession работают как для сотового звонка; уже висящую паузу (от детектора/beep-события) наблюдатель «усыновляет»; линия освободилась → resumeAfterCall, но только «свою»/усыновлённую паузу — beep-пауза сообщения (линию не занимает, режим normal) живёт по прежним порогам audio_session-end + sweep, политика v5.12.2 не тронута; канал режима недоступен (не Android/плагин умер) → после 3 отказов наблюдатель отключается, поведение полностью откатывается к прежнему. Решение вынесено в чистую функцию voipLineWatchDecision (@visibleForTesting). (2) _confirmedNoCall() ужесточён: idle телефонного детектора больше НЕ считается «звонка нет» (детектор не видит VoIP и честно отвечает idle весь мессенджерский разговор) — теперь требуется детектор-idle И свежий MODE_NORMAL; иначе sweep через 20 с снял бы паузу и запустил музыку посреди разговора; при недоступности канала — прежняя семантика. Документация: KNOWLEDGE.md (Phone-call Detection — VoIP line watcher; Interruption policy), версии в AGENTS.md/README.
- Как проверено: flutter analyze — 231 issues (базовый уровень, 0 ошибок, новых нет); flutter test — 103 passed (97 + 6 новых voipLineWatchDecision: пауза при занятой линии/тишина-нет-паузы/усыновление/резюм «своей»/чужая beep-пауза НЕ трогается/null-no-op); сборки в builds/: LingoTune-v5.12.3.apk (release, 225 679 825 байт) и LingoTune-v5.12.3-debug.apk (322,2 МБ). E2E на эмуляторе (AVD lecards_test, API 36; папка AVD оказалась пуста после чистки 05.11 — пересоздан вручную из установленного образа, без загрузок): VoIP-звонок симулирован нативным AudioManager.setMode(MODE_IN_COMMUNICATION) живым процессом (временный dex-хелпер app_process+d8, после проверки удалён; режим держится только пока процесс жив — хелпер спал всё «время звонка»); за весь сценарий не пришло НИ ОДНОГО audio_session-прерывания — наблюдатель был единственным триггером, точная реплика Viber на ROM Артёма. Результаты: пауза встаёт <1 с после занятия линии; удержание 40 c и 25 c при пороге sweep 20 c — без ложного резюма (0 self-heal), позиция замерла (45 920 мс, state=PAUSED); по освобождению линии резюм через ~1 c С ТОЙ ЖЕ позиции (45 920 → 52 067 → 58 218); резюм по доигравшему треку корректно идёт через seek(0)+play («playback advancing after resume»). Регресс сотового звонка: adb emu gsm call → ringing → пауза от детектора + «усыновление» наблюдателем; cancel → idle → резюм (гонка двух источников разрешается штатным дедупом). Полная публикация: publish_release.ps1 — v5.12.3/247 в центр обновлений Aila с краткими notes; манифест сверен (versionCode 247, sha256 и размер совпадают с builds/LingoTune-v5.12.3.apk).
- Коммит: (хеш ниже)
