# LingoTune - Изучение языков через музыку

**Версия:** 5.7.1
**Разработчики:** Z.AI GLM & Цимбалов Артем
**Платформа:** Android (Flutter)
**Языки интерфейса:** Русский, Английский, Румынский, Французский, Немецкий, Испанский, Итальянский, Португальский, Китайский, Арабский, Украинский

## 🎵 Описание проекта

LingoTune - инновационное приложение для изучения иностранных языков через музыку. Приложение позволяет слушать любимые песни с синхронизированным отображением текста и переводов строк в реальном времени.

### Ключевые особенности

- 🎵 **Воспроизведение музыки** - проигрывание аудиофайлов (MP3, WAV, M4A, OGG)
- 📝 **Синхронизированный текст** - отображение текста песен с точным таймингом (LRC формат)
- 🌍 **Множественные переводы** - поддержка переводов на множество языков
- 📊 **Строчные переводы** - перевод каждой строки песни
- ⏱️ **Точные временные метки** - автоматическое выделение текущей и следующей строки
- ✏️ **Редактирование переводов** - встроенный редактор переводов
- 📝 **Ручное редактирование тайминга** - настройка временных меток
- 🎯 **Настраиваемая автопрокрутка** - вертикальный ползунок фокуса прокрутки (-1000 до +1000 px)
- 🎚️ **Дефолтный фокус** - настройка начального положения фокуса (+50 по умолчанию)
- 🌐 **Мультиязычный интерфейс** - 12 языков интерфейса
- 🎤 **Поддержка транскрипции** - фонетическая транскрипция для всех языков
- ⚡ **Пакетная генерация текстов** - генерация текстов песен с помощью AI
- 🔍 **Поиск текстов** - поиск текстов песен в онлайн-базах данных
- 🤖 **AI переводы (DeepSeek)** - автоматическая генерация переводов
- 💾 **Экспорт/импорт настроек** - резервное копирование настроек
- 📦 **Библиотека песен** - управление плейлистами и песнями
- 🔄 **Фоновое воспроизведение** - воспроизведение в фоне с уведомлением
- 📞 **Пауза при звонке** - автоматическая пауза песни и озвучки перевода во время входящего звонка, возобновление после разговора
- ⏩ **Управление скоростью** - изменение скорости воспроизведения (0.5x - 2.0x)
- 🎧 **Режим изучения** - озвучка перевода (TTS) + фрагмент песни для каждой строки
- 🚗 **Детекция машин** - анализ звука с микрофона (FFT, on-device) и предупреждение бегуна о приближающемся транспорте (звук/вибрация/голос)

## 📦 Структура проекта

```
LingoTune/
├── app/                    # Flutter приложение
│   ├── lib/
│   │   ├── models/         # Модели данных (Song, Translation, LyricLine)
│   │   ├── services/       # Сервисы (AudioService, DatabaseService, TranslationService)
│   │   ├── screens/        # Экраны приложения
│   │   ├── widgets/        # Переиспользуемые компоненты
│   │   │   └── settings/  # Виджеты настроек (FocusOffset, ScrollOffset)
│   │   ├── utils/          # Утилиты
│   │   └── constants/      # Константы
│   ├── assets/             # Ресурсы (шрифты, иконки)
│   └── pubspec.yaml        # Зависимости Flutter
├── scripts/                # Python скрипты для генерации текстов
│   ├── deepseek_generator_v3.py
│   ├── generate_lrc_json.py
│   └── process_excel_songs.py
├── input/                  # Входные файлы для обработки
├── output/                 # Сгенерированные файлы текстов и переводов
├── lessons/                # Уроки по языкам
│   └── Arabic/            # Арабские уроки
├── builds/                 # Собранные APK файлы
└── docs/                   # Документация
```

## 🚀 Быстрый старт

### Требования

- Flutter SDK 3.0+
- Python 3.8+
- Android SDK
- Учетная запись DeepSeek API

### Установка

```bash
# Клонирование репозитория
cd D:\Ai-LingoTune

# Установка зависимостей Flutter
cd app
flutter pub get

# Установка зависимостей Python
cd ../scripts
pip install -r requirements.txt

# Настройка API ключей (создать .env файл)
echo "DEEPSEEK_API_KEY=ваш_ключ_здесь" > ../.env
```

### Сборка APK

```bash
# Из папки app/
flutter build apk --release

# APK будет создан в: build/app/outputs/flutter-apk/app-release.apk

# Копирование в папку builds/
cp build/app/outputs/flutter-apk/app-release.apk builds/LingoTune-v{версия}.apk
```

## 📖 Документация

- [Архитектура системы](ARCHITECTURE.md) - описание архитектуры и компонентов
- [Настройка окружения](SETUP.md) - установка и конфигурация
- [Форматы данных](DATA_FORMATS.md) - LRC, JSON и другие форматы файлов
- [Руководство по API](API_GUIDE.md) - DeepSeek API и интеграции
- [Создание уроков](LESSON_CREATION.md) - генерация текстов песен и уроков
- [Рабочий процесс](WORKFLOW.md) - рабочий процесс приложения
- [Разработка](DEVELOPMENT.md) - конвенции кода и разработка
- [Решение проблем](TROUBLESHOOTING.md) - FAQ и решение проблем
- [Калибровка детекции машин](PLAN_CAR_DETECTION_CALIBRATION.md) - реализация v5.5.0 (эталоны + Mahalanobis)
- [Офлайн-TTS (sherpa_onnx VITS)](PLAN_v5.3.0_offline_tts.md) - реализация v5.5.0 (стабильная озвучка перевода без системного TTS)
- [Избранное по плейлистам](PLAN_v5.7.0_favorites.md) - реализация v5.7.0 (глобальная корзина favorites + режим LoopMode.favorites)

## 🎯 Новое в версии 5.7.1

### 📞 Фикс: настоящая пауза при звонке на ROM с агрессивным системным дакингом (ColorOS/Realme, MIUI)
- **Симптом:** при входящем звонке песня не паузилась, а «тихо играла» весь разговор (ОС приглушала медиапоток), а после отбоя становилась громче. Логично ожидать честную паузу. Особенно воспроизводимо на Realme GT5 (ColorOS/Realme UI).
- **Корень:** в 5.6.1 для паузы при звонке полагались исключительно на `audio_session.interruptionEventStream` + флаг `androidWillPauseWhenDucked: true`. Но звонок на ряде ROM запускает дакинг медиапотока на уровне **AudioPolicyManager/AudioFlinger** (ниже audio-focus framework), который **игнорирует** `willPauseWhenDucked`. В итоге `interruptionEvent` либо приходит с большой задержкой, либо не приходит вовсе → `pause()` не вызывается → системный дакинг слышен как «тихая музыка». Флаг работает только для «обычных» прерываний (другой плеер, будильник), но не для телефонии.
- **Решение:** добавлен **прямой нативный детектор состояния звонка** через `TelephonyManager` (срабатывает в момент `RINGING` — гарантированно раньше системного дакинга) **поверх** существующей audio-focus схемы (та остаётся как фолбэк для не-телефонных прерываний). Дедупликация по флагу `_pausedForCall` гарантирует, что при двойном срабатывании (phone-state + audio-focus по одному звонку) пауза и resume отрабатывают ровно по одному разу.
- **Что делает пользователь:** ничего — при первом входе в плеер один раз запрашивается `READ_PHONE_STATE`; при отказе грациозно остаётся старая audio-focus схема (не хуже, чем было).

### 🔧 Технические изменения
- **`app/android/app/src/main/kotlin/com/lingotune/app/PhoneCallPlugin.kt`** (новый, ~170 строк): `FlutterPlugin` + `EventChannel.StreamHandler` на канале `lingotune/phone_state`. API 31+ — современный `TelephonyCallback.CallStateListener` (основной путь, Realme GT5 = API 33); API < 31 — фолбэк на устаревший `PhoneStateListener.LISTEN_CALL_STATE`. Шлёт строки `ringing` / `offhook` / `idle`. `SecurityException` (нет permission) → ошибка в sink (Dart-сторона откатывается на фолбэк). Listener регистрируется на `onListen`, снимается на `onCancel`/`onDetachedFromEngine`.
- **`app/android/app/src/main/kotlin/com/lingotune/app/MainActivity.kt`**: в `configureFlutterEngine` регистрируется `PhoneCallPlugin` (раньше класс был пустым — только `AudioServiceActivity`).
- **`app/android/app/src/main/AndroidManifest.xml`**: добавлен `<uses-permission android:name="android.permission.READ_PHONE_STATE"/>` (с комментарием зачем).
- **`app/lib/services/phone_call_service.dart`** (новый, ~110 строк): Dart-обёртка над EventChannel; `enum CallState { idle, ringing, offhook }`; синглтон `PhoneCallService.instance` с `start()`/`stop()` и broadcast-стримом `callStates`. На не-Android / недоступности канала `start()` возвращает `false` (грациозный фолбэк).
- **`app/lib/services/background_audio_handler.dart`**:
  - Новое поле `bool _pausedForCall` (дедупликация звонка).
  - Вынесены приватные `_handleCallPause()`/`_handleCallResume()` — единый путь паузы/resume (study-handoff через `onPlaybackInterrupted`, захват `_wasPlayingBeforeInterruption`, `pause()`/`play()` + `onPlaybackResumed`).
  - Новые публичные методы `pauseForCall()`/`resumeAfterCall()` для триггера из `PhoneCallService`.
  - `interruptionEventStream` listener упрощён и теперь зовёт те же `_handleCallPause()`/`_handleCallResume()` → двойное срабатывание (phone-state + audio-focus) безопасно: первый выставляет `_pausedForCall=true`, второй — no-op.
- **`app/lib/screens/player_screen.dart`**:
  - Новое поле `StreamSubscription<CallState>? _phoneCallSub` + импорты `permission_handler`, `phone_call_service.dart`.
  - `_initBackgroundAudio`: после подключения interruption-колбэков зовёт (fire-and-forget через `unawaited`) новый `_initPhoneCallDetection()`.
  - `_initPhoneCallDetection()`: проверка `Platform.isAndroid`; запрос `Permission.phone` (READ_PHONE_STATE); при гранте — `PhoneCallService.instance.start()` + подписка: `ringing`/`offhook` → `handler.pauseForCall()`, `idle` → `handler.resumeAfterCall()` (study-handoff идёт через те же колбэки handler'а).
  - `dispose()`: отмена `_phoneCallSub` + `PhoneCallService.instance.stop()` (снимает нативный listener — иначе утечка + phantom pause/resume).
- **`pubspec.yaml`/`app_info.dart`/`build.gradle`/`local.properties`** — 5.7.1 (versionCode 223).

### ⚠️ Известные ограничения
- **Покрытие = lifecycle PlayerScreen:** нативный детектор живёт, пока жив `PlayerScreen` (как и колбэки study-mode). При активном прослушивании и в фоне (app backgrounded, экран не disposing) — работает. При возврате в библиотеку (pop экрана) PhoneCallService останавливается, но остаётся audio-focus фолбэк handler'а (базовая пауза песни без study-TTS-handoff — но study mode и так неактивен без экрана).
- **Только Android:** нативный детектор через `TelephonyManager` доступен только на Android (целевая платформа проекта). На других платформах `PhoneCallService.start()` возвращает `false`, используется audio-focus схема.
- **READ_PHONE_STATE permission:** при отказе приложение работает на старой audio-focus схеме (т.е. на проблемных ROM баг может остаться — но это осознанный выбор пользователя, без принуждения).
- **Двойной триггер на стоках:** на «чистом» Android звонок может породить и phone-state, и audio-focus события — дедуп по `_pausedForCall` корректно отрабатывает (пауза/resume по разу).

---

## 🎯 Новое в версии 5.7.0

### ❤ Новая фича: Избранное по плейлистам (глобальная корзина + режим «играть только избранное»)
- **Задача:** пользователь хотел отмечать любимые песни и слушать их отдельно от текущего плейлиста, не собирая вручную отдельный плейлист.
- **Архитектурное решение (без миграции БД):** в БД уже существовал автоматически создаваемый системный плейлист `favorites` (`isSystem=1`, `database_service.dart`), но он нигде не использовался. Переиспользовали его: избранное = обычные строки в существующей junction table `playlist_songs` с `playlistId='favorites'`. Никакой миграции БД не потребовалось. Локализационные ключи `addToFavorites`/`removeFromFavorites`/`favorites` тоже уже были определены на всех 11 языках, но не вызывались.
- **Что может пользователь:**
  - **Кнопка-сердечко в плеере** на текущей песне (слева от индикатора позиции) — добавляет/убирает песню из избранного одним тапом.
  - **Кнопка-сердечко в списке песен плейлиста** (`PlaylistSongsScreen`) — массово отмечать песни прямо в списке.
  - **Новый режим петли `LoopMode.favorites`** — 5-е состояние в цикле кнопки loop (`off → all → one → allPlaylists → favorites → off`). При активации грузит все избранные песни и делает их активным списком воспроизведения. Если текущая песня уже в избранном — продолжает с неё; иначе переключается на первую.
- **Особенности:**
  - **Глобальная корзина:** одна коллекция избранного на всё приложение независимо от того, из какого плейлиста отметили песню (т.к. это единый системный плейлист `favorites`).
  - **Wrap-around:** в режиме `favorites` следующая/предыдущая песни зацикливаются по списку избранных (как `LoopMode.all`), включая при включённом shuffle.
  - **Transient-режим:** `favorites` НЕ персистится в `SharedPreferences` (т.к. требует динамической загрузки списка из БД, что делается только через явный тап на кнопку loop). При холодном старте режим всегда сбрасывается в `off`.
  - **Плейлист `favorites` редактируемый:** в `PlaylistSongsScreen` он показывается с кнопкой удаления (а не `play_arrow`, как прочие системные), т.к. удалить из избранного = убрать из этого плейлиста.
  - **Удаление текущей песни из избранного во время игры в режиме `favorites`** синхронно обновляет активный список, чтобы next не ушёл в удалённую песню; если список опустел — режим автоматически откатывается в `off`.

### 🔧 Технические изменения
- **`lib/models/loop_mode.dart`**: `enum LoopMode { off, all, one, allPlaylists, favorites }` (новое значение в конце, чтобы сохранить `.index` существующих режимов).
- **`lib/services/audio_service.dart`**:
  - `toggleLoop()`: цикл продлён `allPlaylists → favorites → off`. `_savePlaybackSettings()` вызывается только для non-favorites режимов (transient).
  - `_loadPlaybackSettings()`: если из prefs загрузился `favorites` (устаревшее значение) — сброс в `off`.
  - `getNextShuffledIndex`/`getPreviousShuffledIndex`: wrap-around при `loopMode == all || favorites`.
  - `playNextSong`/`playPreviousSong` (fallback-путь): wrap-around при `all || favorites`.
- **`lib/services/background_audio_handler.dart`**: `setRepeatMode` зеркально продлён `allPlaylists → favorites → off`.
- **`lib/services/database_service.dart`**: новый метод `isSongInPlaylist(playlistId, songId)` — быстрый `SELECT 1 ... LIMIT 1` (без загрузки всего списка песен).
- **`lib/screens/helpers/player_playlist_helper.dart`**: `playNextSong`/`canPlayPrevious`/`canPlayNext` — `favorites` обрабатывается как `all` (wrap-around по единому плоскому списку).
- **`lib/screens/player_screen.dart`**:
  - Новое state-поле `bool _isCurrentSongFavorite`.
  - `_switchToFavoritesMode()`: грузит `getSongsInPlaylist('favorites')`; пусто → SnackBar `noFavoriteSongs` + откат в `off`; иначе `_activePlaybackList = favSongs` + `setCurrentPlaylist` + найти текущую или играть первую.
  - `_refreshCurrentSongFavoriteStatus()`: обновляет флаг при смене песни.
  - `_toggleCurrentSongFavorite()`: add/remove + sync `_activePlaybackList` если играем в режиме favorites (+ авто-откат если опустел).
  - `_toggleLoop()`: при переходе в `favorites` → `_switchToFavoritesMode()`; при выходе из `favorites` → восстановление `widget.playlistSongs` как активного списка.
  - `_canPlayNext()`: `true` для `favorites`.
  - `_buildLoopButton()`: кейс `favorites` — иконка `Icons.favorite`, красный цвет, tooltip `playFavoritesOnly`.
  - В transport-Row (position | title | duration) добавлена компактная кнопка-сердечко слева + симметричный spacer справа.
  - `initState`: защита — если persisted loopMode = favorites → сброс в off.
- **`lib/screens/playlist_songs_screen.dart`**:
  - Новое state-поле `Set<String> _favoriteSongIds` + загрузка в `_loadSongs` (один запрос `getSongsInPlaylist('favorites')`).
  - `_toggleFavorite(Song)` / `_buildFavoriteButton(Song, l10n)`.
  - В trailing каждой строки: сердечко показывается всегда, КРОМЕ случая когда сам плейлист = `favorites` (там оно избыточно — там есть remove_circle). Плейлист `favorites` теперь ведёт себя как редактируемый (remove вместо play_arrow).
- **`lib/l10n/app_*.arb`** (11) + `app_localizations*.dart` (реген через `flutter gen-l10n`): 2 новых ключа `playFavoritesOnly`, `noFavoriteSongs` × 11 языков (`addToFavorites`/`removeFromFavorites`/`favorites` уже были).
- **`pubspec.yaml`/`app_info.dart`/`build.gradle`/`local.properties`** — 5.7.0 (versionCode 222); features += «❤ Favorites playlist + play-favorites-only loop mode».

### ⚠️ Известные ограничения
- **Глобальная, не per-playlist:** модель — одна корзина избранного на всё приложение (по решению разработки). Если нужна отдельная отметка внутри каждого плейлиста — потребовалось бы новое поле в БД (миграция v12).
- **`favorites` не персистится:** после холодного старта приложения режим всегда `off` (сознательное решение — transient-режим).
- **Системный плейлист `favorites` виден** в списке плейлистов `PlaylistScreen` (если системные показываются) — это ожидаемо и даже полезно (можно открыть и посмотреть весь список избранных).

---

## 🎯 Новое в версии 5.6.3

### 🐛 Фикс: на некоторых песнях подсветка строк опаздывала (накопительный дрейф)
- **Симптом:** на некоторых песнях (формат MP3) подсветка строк шла **позже** таймингов LRC-файла. Сначала всё синхронно, но со временем дрейф нарастал — «какое-то время работает хорошо, потом начинает глючить». На одних песнях заметно, на других — нет.
- **Корень №1 (VBR MP3):** ExoPlayer (под капотом `just_audio`) для MP3 без Xing/Info-заголовка определяет позицию как `bytes_consumed / битрейт_первого_фрейма` (как будто CBR). На VBR-файлах реальный битрейт к концу трека ниже → позиция **линейно отстаёт** от реального звука → подсветка опаздывает, дрейф растёт со временем. Зависит от конкретного файла → «на некоторых песнях».
- **Корень №2 (UI jank):** `_positionTimer` (50мс) вызывал `setState(() {})` на **каждый** тик = 20 rebuild'ов `PlayerScreen`/сек. Тяжёлый экран → UI-изолят перегружен → колбэк `_player.positionStream` (в том же изоляте) обрабатывался с задержкой → `_position` устаревал → подсветка опаздывала. Эффект нарастал при долгом прослушивании / активном car-detection.
- **Корень №3 (фон-режим):** `_positionTimer` не отменялся при сворачивании приложения → после возврата из фона позиция могла быть stale.
- **Решение (Корень №1) — коррекция позиции по wall-clock:** новый класс `AudioPositionCorrector` интерполирует позицию между событиями `positionStream` по wall-clock времени (`syncedPos + (now − syncedAt) × speed`). Когда сырая позиция `_player.position` отстаёт от интерполированной больше порога (500мс) → доверяем wall-clock (нейтрализуем VBR-дрейф). При seek вперёд/назад или паузе/buffering → доверяем `rawPos`. Применяется **только к подсветке строк** (`LyricsService.updatePosition`); slider/индикатор времени используют честную `_player.position`. Отключаемо в Настройках (`timingCorrection`, по умолчанию ВКЛ).
- **Решение (Корень №2):** `setState` throttling до ~8/сек (вместо 20) — для индикатора времени/AppBar этого достаточно, а подсветка строк обновляется через `AnimatedBuilder` над `lyricsService` независимо.
- **Решение (Корень №3):** `_positionTimer` отменяется при уходе в фон, перезапускается + reset корректора при `resumed`.

### 🔧 Технические изменения
- **`lib/services/audio_position_corrector.dart`** (новый, ~150 строк): класс `AudioPositionCorrector` — wall-clock интерполяция с защитой от seek/pause/buffering; порог 500мс; `reset()`/`syncTo()`/`correct()`.
- **`lib/services/settings_provider.dart`**: новое поле `_timingCorrection` (bool, дефолт `true`), геттер `timingCorrection`, `setTimingCorrection`, persist в `_save`/`loadSettings`.
- **`lib/screens/player_screen.dart`**:
  - Поле `_positionCorrector` + `_lastSetStateTime`.
  - `_startPositionUpdates`: коррекция позиции для подсветки (если `timingCorrection` включён) + throttle `setState` до ~8/сек.
  - `didChangeAppLifecycleState`: отмена `_positionTimer` в фоне, reset корректора + перезапуск при `resumed`.
  - `_playSong`: `_positionCorrector.reset()` при смене песни.
- **`pubspec.yaml`/`app_info.dart`/`build.gradle`/`local.properties`** — 5.6.3 (versionCode 221).

### ⚠️ Известные ограничения
- **Коррекция не лечит CBR-файлы с неверными LRC.** Если тайминги в LRC физически не совпадают с аудио (например, тайминги сделаны по другой версии трека), коррекция не поможет — это не позиция, а сам LRC.
- **Wall-clock при долгом buffering.** На стримах/медленных источниках при затяжном buffering wall-clock может кратковременно уйти вперёд (до восстановления sync при `processingState.ready`). Для локальных файлов это неактуально.
- **Отключение:** если коррекция на конкретном устройстве ведёт себя странно — выключить в Настройках (`timingCorrection`).
- **Тумблер в UI Настроек** не добавлен в этом релизе (настройка доступна через prefs); UI-тайл — фаза 2.

---



### 🐛 Фикс: в overlay-режиме подсветка строки «убегала» вперёд перевода (потеря перевода на коротких строках)
- **Симптом:** в режиме изучения «перевод поверх песни» (overlay) на некоторых песнях подсветка текущей строки перепрыгивала на следующую раньше, чем заканчивал звучать перевод текущей. Причём перевод произносился правильно — просто для предыдущей строки, а на новой строке перевод мог вообще не зазвучать. Глюк проявлялся **не на всех песнях и не всегда**, закономерность было сложно уловить.
- **Корень:** в `_speakOver` (fire-and-forget speak для overlay) стоял guard `if (_isSpeaking) return` — пока TTS говорил перевод строки N, триггер перевода строки N+1 при смене границы **молча пропускался**. `StudyModeService._currentIndex` (и UI-подсветка по позиции аудио) уходили на N+1, а перевод N продолжал звучать; триггер для N+1 больше не повторялся → перевод N+1 терялся. Проявлялось именно когда длительность перевода > длины строки (короткие строки / длинный текст / медленный TTS), поэтому на «плотных» песнях глюк виден, а на просторных — нет.
- **Решение (Вариант A — прерывать старый перевод):** `_speakOver` больше не skip'ает. При смене строки координатор через `_interruptCurrent` прерывает перевод предыдущей строки и запускает перевод новой → перевод всегда соответствует текущей подсветке. Новый токен `_speakToken` гарантирует, что `.then`-колбэк прерванного speak не сбросит `_isSpeaking` поверх запущенного нового speak. На длинных строках обрыва нет (перевод успевает закончиться), на коротких — перевод аккуратно обрывается на полуслове ради синхрона с подсветкой.

### 🐛 Фикс: зависание study-сессии (TF/OF) при zombie-state `just_audio`
- **Симптом:** в режимах «перевод-сначала» / «оригинал-сначала» после некоторых прерываний аудиосессии study mode мог намертво остановиться — ни перехода на следующую строку, ни реакции.
- **Корень:** `_segmentCompleter` в `_playSegmentAndAwait` завершался только из `_segmentTimer`/`_playerStateSub`. При zombie-state just_audio (`processingState != completed`, но позиция не двигается) ни то, ни другое не срабатывало → `_playSegmentAndAwait` висел вечно (watchdog был только на `_speak`, не на сегменте).
- **Решение:** добавлен watchdog-таймер `_segmentWatchdog`, который через `(длина сегмента + 10с)` форсит `_cancelSegmentAwait(true)` → study-цикл продолжает переходить по строкам вместо вечного await'а.

### 🐛 Фиксы утечек ресурсов и race-conditions
- **`_playerStateSub` переназначался без cancel** в `_playSegmentAndAwait` и `_runContinuousOverlay` → возможна висящая подписка и двойное `onStudyCompleted`. Теперь перед назначением всегда `?.cancel()`.
- **`SystemTtsEngine.dispose()`** не complete'ил `_speakCompleter` → awaiter висел, если dispose звался во время речи. Теперь completer complete'ится синхронно.
- **`OfflineTtsEngine.dispose()`** не останавливал `_fallback` перед dispose → зависший completer fallback. Теперь `_fallback.stop()` перед dispose.
- **`OfflineTtsIsolate`**: подписка на main-port сохранена в поле `_mainSub` и явно cancel'ится в `_cleanup` (раньше только `_mainPort?.close()`, что не гарантирует синхронную отмену стрима).
- **`PlayerScreen.dispose()`**: очищаются `audioService.onSongComplete` и `studyModeService.onStudyCompleted` (владельцы переживают экран и держали замыкания на disposed screen).
- Удалён мёртвый код: поле `_posSub` (никогда не назначалось, только cancel'илось).

### 🔧 Технические изменения
- **`lib/services/study_mode_service.dart`**:
  - Новое поле `int _speakToken = 0` + `Timer? _segmentWatchdog`.
  - `_speakOver` переписан: убран `if (_isSpeaking) return`, добавлены проверки `_speakToken` в `.then`.
  - `_playSegmentAndAwait`: cancel старых таймеров/подписок перед setup + запуск watchdog.
  - `_runContinuousOverlay`: cancel `_overlayTimer`/`_playerStateSub` перед назначением.
  - `stop()`/`pauseSession()` инкрементируют `_speakToken`; `_cancelSegmentAwait`/`dispose` отменяют watchdog.
  - Удалено мёртвое поле `_posSub`.
- **`lib/services/tts/system_tts_engine.dart`**: `dispose()` complete'ит `_speakCompleter`.
- **`lib/services/tts/offline_tts_engine.dart`**: `dispose()` зовёт `_fallback.stop()`.
- **`lib/services/tts/offline_tts_isolate.dart`**: поле `_mainSub`, cancel в `_cleanup`.
- **`lib/screens/player_screen.dart`**: `dispose()` чистит `onSongComplete`/`onStudyCompleted`.
- **`pubspec.yaml`/`app_info.dart`/`build.gradle`/`local.properties`** — 5.6.2 (versionCode 220).

### ⚠️ Известные ограничения
- **Обрыв перевода на коротких строках:** при overlay на песнях с очень короткими строками (< длительности перевода) перевод будет обрываться на полуслове ради синхрона с подсветкой. Это сознательное решение (Вариант A) — лучше чёткий синхрон, чем отстающий/теряющийся перевод. На строках обычной длины обрыва нет.
- **overlay `both`**: при `OverlayTiming.both` два speak'а (конец N + начало N+1) идут подряд — второй немедленно прерывает первый. Это не хуже прежнего поведения (со skip первый всё равно пропадал). Семантика `both` на плотных песнях неоднозначна и оставлена как есть.

---



### 🐛 Фикс: после полного закрытия приложения офлайн-TTS «слетал» на системный
- **Симптом:** при свернутом приложении всё работало, но после **полного выхода** (свайп из шторки/убийство процесса) и повторного входа озвучка перевода шла через **системный** TTS, а не через офлайн (sherpa_onnx). Причём открытие и закрытие настроек «чинило» поведение до следующего перезапуска.
- **Корень (гонка при холодном старте):** `TtsCoordinator.setTtsSource` не был сериализован. На холодном старте его **одновременно** дёргают два пути:
  1. `StudyModeService._initTts()` → `ensureInitialized()` → `setTtsSource(offline, 'ru')` (из конструктора `PlayerScreen.initState`);
  2. `PlayerScreen.didChangeDependencies` → post-frame → `_applyTtsSource()` → `setTtsSource(offline, lang)`.
  
  Проверка `_initialized && _source == source && _engine != null` читает состояние, которое меняется на `await`-ах, поэтому **оба** вызова видели `_initialized=false` и шли в полный путь: создавалось **два** `OfflineTtsEngine`, каждый со своим `OfflineTtsIsolate`, и оба грузили 63 МБ модель. Под холодным стартом (memory/CPU pressure спавна двух изоляторов) один `_loadModel` падал/таймаутил → в «проигравшем» гонку движке `_langAvailable=false` → `OfflineTtsEngine.speak` делегировал во внутренний `_fallback` (SystemTtsEngine) → **системный TTS**.
- **Почему открытие настроек чинило:** повторный `_applyTtsSource` уходил в no-op ветку `setTtsSource`, которая вызывает `_engine.setLanguage(_languageCode)` ещё раз → `_loadedLang != lang` (модель не загрузилась) → `_loadModel` **ретраится** без конкуренции → успех → `_langAvailable=true` → офлайн.
- **Решение:** Future-chain мьютекс `_sourceLock` в `TtsCoordinator` сериализует `setTtsSource`/`setLanguage`. Второй вызов ждёт первый, видит `_initialized=true, _source=offline` → no-op → создаётся ровно **один** движок/изолятор. Дедлоков нет (методы не реентерят лок).

### 📞 Новая фича: пауза песни (и озвучки перевода) при входящем звонке
- **Симптом:** во время разговора песня была «тихонько слышно» (ОС делала приглушение/дакинг, а не паузу); озвучка перевода (study mode) вообще продолжала звучать на отдельном `AudioPlayer`.
- **Корень (песня):** `AudioSessionConfiguration.music()` не задаёт `androidWillPauseWhenDucked` (поле `null` → `false`). При звонке ОС получает `AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK` и **сама снижает громкость** медиапотока, не присылая interruption-событие приложению → `pause()` в обработчике не гарантированно срабатывал над уже-дакнутым потоком (особенно на ColorOS China).
- **Корень (озвучка):** TTS играет на **втором** `AudioPlayer` (`OfflineTtsEngine._player`), который interruption-обработчик не трогает; простой `TtsCoordinator.stop()` здесь не подходит — он завершает `_speak()`, после чего study-runner запускает `_kickPlayback()` и пытается играть песню прямо во время звонка.
- **Решение:**
  - `androidWillPauseWhenDucked: true` в конфигурации сессии → ОС **не дакит сама**, а присылает событие → существующий обработчик честно паузит (`begin`) и возобновляет (`end`). См. маппинг `lossTransientCanDuck` в `audio_session-0.1.25/lib/src/core.dart`.
  - Новые колбэки `onPlaybackInterrupted` (возвращает `bool` — взял ли study на себя паузу) / `onPlaybackResumed` на `BackgroundAudioHandler`. `PlayerScreen` подключает их к `StudyModeService.pauseSession()` / `resumeSession()` — корректно стопает TTS + дренирует kick-цикл через `_isUserPaused`, а после звонка поднимает сессию. Если колбэк вернул `true`, handler НЕ делает авто-resume песни (этим занимается `resumeSession`), избегая double-resume.

### 🔧 Технические изменения
- **`lib/services/tts_coordinator.dart`**:
  - Новое поле `Future<void>? _sourceLock`.
  - `setTtsSource` стал обёрткой: захватывает очередь (`prev` → `done`), ждёт предыдущий вызов, делегирует в `_setTtsSourceInner` (тело без изменений), освобождает в `finally`.
  - `setLanguage` обёрнут в ту же очередь — иначе `setLanguage` мог вызваться на движке, который в этот момент пересоздаётся/утилизируется.
- **`lib/services/background_audio_handler.dart`**:
  - `_initAudioSession`: `session.configure(AudioSessionConfiguration.music().copyWith(androidWillPauseWhenDucked: true))`.
  - Новые поля `bool Function()? onPlaybackInterrupted` / `Function()? onPlaybackResumed`.
  - Interruption-listener: на `begin` вызывает `onPlaybackInterrupted` (если вернул `true` — не захватывает `_wasPlayingBeforeInterruption`), затем `pause()`; на `end` — `play()` (если было playing) + `onPlaybackResumed`. Добавлены debug-логи `📞`.
- **`lib/screens/player_screen.dart`**:
  - Новое поле `bool _studyPausedForCall = false`.
  - В `_initBackgroundAudio`: подключение `onPlaybackInterrupted` (если study активен и не на паузе → `_studyPausedForCall=true`, `pauseSession()` fire-and-forget, возврат `true`) и `onPlaybackResumed` (`resumeSession()` если `_studyPausedForCall`).
  - В `dispose()`: очистка обоих колбэков (вместе с `onSkipToNextRequested`).
- **`pubspec.yaml`/`app_info.dart`/`build.gradle`/`local.properties`** — 5.6.1 (versionCode 219).

### ⚠️ Известные ограничения
- **Car detection во время звонка:** детектор машин использует микрофон, который во время разговора занят телефонией; анализа не будет. После звонка детектор автоматически возобновляет захват (если был активен). Специальной паузы car detection на звонок не делается — это редкий кейс (бегун обычно не разговаривает по телефону во время бега).
- **Double interruption:** при быстрой серии прерываний флаг `_studyPausedForCall` защищает от двойного resume, но пауза `pauseSession()` идемпотентна (`_isUserPaused` проверяется).

---

## 🎯 Новое в версии 5.6.0

### 🐛 Фикс: зависание/краш при открытии песни + ошибка «TTS model integrity check failed»
- **Симптомы:** после внедрения офлайн-TTS (5.5.0) приложение зависало при открытии песни, перемотка не работала, воспроизведение «слетало» через пару секунд; при установке русского голосового пакета появлялась ошибка `FileSystemException: TTS model integrity check failed`.
- **Корень (integrity):** бандл `assets/tts/ru_RU.tar.bz2` содержит модель под реальным именем `ru_RU-irina-medium.onnx` (+ `ru_RU-irina-medium.onnx.json`), а `TtsModelManager` везде искал каноническое `model.onnx`. Распаковка Strip'ала верхнюю папку, но не переименовывала файл → integrity-чек не находил `model.onnx` → бросал `FileSystemException` → модель никогда не устанавливалась.
- **Корень (зависание):** т.к. `isInstalled('ru')` всегда возвращал `false`, а дефолтный `ttsSource='offline'`, при **каждом** открытии песни заново распаковывался 64 МБ архив синхронно в главном изоляте (`BZip2Decoder`+`TarDecoder`) → UI вставал на секунды → перемотка не отвечала → watchdog'и/session-трэш глушили воспроизведение.
- **Решение:**
  - В `_extractTarBz2` реальные `*.onnx` и `*.onnx.json` **переименовываются** в канонические `model.onnx` / `model.onnx.json` (sherpa_onnx выводит имя `.json` из пути модели) → integrity-чек проходит, `isInstalled` возвращает `true`, повторная распаковка прекращается.
  - Декодирование BZip2+Tar и запись ~300 файлов вынесены в **фоновый изолятор** через `compute` (top-level `_extractTtsArchiveInIsolate`) — главный изолят больше не морозится. Эталон — `compute(_decodeArchive, …)` из `settings_export_service.dart`.

### 🚀 Ускорение: генерация речи (sherpa_onnx) в воркер-изоляторе
- **Задача:** `OfflineTts.generate()` синхронна и блочит вызвавший изолят на сотни миллисекунд на каждую строку перевода в study-режиме → UI stutter. Объект `OfflineTts` нельзя пересылать между изолятами.
- **Решение:** новый `lib/services/tts/offline_tts_isolate.dart` — **долгоживущий воркер-изолятор**, владеющий `OfflineTts`. Запросы `generate` уходят через `SendPort`/`ReceivePort` (handshake + op-codes + request-id), воркер синтезирует и возвращает `Float32List` samples + sampleRate. `OfflineTtsEngine.speak` вызывает `_isolate.generate(text, rate, gain)`, WAV пишется и играется уже в main. При ошибке/таймауте — откат на системный TTS (как раньше).
- `_loadModel`/`_maybeUnload` делегируют в изолятор (`loadModel`/`freeModel`); `_tts` поле удалено из движка.

### 🔊 Новая фича: громкость речи + буст до 3.0x (нормализация)
- **Задача:** раньше громкость сгенерированной речи не регулировалась (`volume` в `speak()` всегда был `null`), а `setVolume` ограничен 1.0 — речь была тише «мастеренной» песни даже на максимуме.
- **Решение:**
  - Новая настройка **«Громкость речи»** в диалоге study-режима (⚙) — ползунок **0.0–3.0x** (множитель, единообразно с ползунком скорости). Хранится в `studyModeSpeechVolume` (глобально) / `song_{id}_speechVolume` (per-song), дефолт **1.0x**, с поддержкой per-song override (наследуется при первом включении).
  - Скорость речи переделана с ChoiceChip'ов (0.3–1.1) на **ползунок 0.3–2.5x**.
  - **Пик-нормализация:** сэмплы речи всегда нормализуются до ~0.98 в воркере (Piper-выход обычно далеко не на пике) → даже на **1.0x** речь в ~2–3 раза громче прежнего.
  - **Буст >1.0x:** значения ползунка выше 1.0 усиливают сэмплы (`gain`) с жёстким клиппингом пиков → можно выкрутить очень громко (на 2.5–3.0x возможны искажения). До 1.0 — обычное ослабление через `setVolume`.
  - **Поток:** `StudyModeService._speechVolume` → `TtsCoordinator.speak(volume:)` → офлайн: `_isolate.generate(gain:)` + `_player.setVolume(min(V,1.0))`; система: `FlutterTts.setVolume` (клампится до 1.0, буст физически невозможен — fallback-путь).
- **Локализация:** 1 новый ключ `studyModeSpeechVolume` × 11 языков (через `flutter gen-l10n`).

### 🐛 Фикс: зацикливание режима `LoopMode.allPlaylists`
- **Симптом:** в режиме проигрывания по разным плейлистам играл весь текущий плейлист → одна песня из другого → снова весь текущий → та же песня из другого → ∞ (вместо последовательного перехода по плейлистам).
- **Корень:** `_playNextFromAllPlaylists` искал текущую песню в **устаревшем** `widget.playlistSongs` (фиксируется при создании экрана). Когда играла песня B0 из другого плейлиста, `indexWhere` = −1 → играл `playlistSongs[0]` (прыжок в начало исходного плейлиста A). Дополнительно `_playSong` безусловно сбрасывал `audioService.currentPlaylist` обратно на `widget.playlistSongs`, затирая переход.
- **Решение:**
  - Заведён живой state-флаг `_activePlaybackList` (изначально = `widget.playlistSongs`), который **обновляется** при смене плейлиста. Все операции next/prev/queue работают с ним, а не с устаревшим `widget.playlistSongs`.
  - Новый `_switchToNextPlaylist`: доиграли плейлист → выбираем **другой**. **Shuffle ВЫКЛ** → следующий по `createdAt` с wrap-around, пустые пропускаются; **Shuffle ВКЛ** → случайный (≠ текущему). `_playSong` больше не сбрасывает очередь.
  - `DatabaseService.getAllPlaylists()` → `orderBy: 'createdAt ASC'` (детерминированный порядок).
  - Трейс теперь: A (целиком) → B (целиком) → C → A… или случайные плейлисты при shuffle.

### 🔧 Технические изменения
- **`lib/services/tts/tts_model_manager.dart`**:
  - `_extractTarBz2` переписан: распаковка через `compute(_extractTtsArchiveInIsolate, _ExtractJob)` (новые top-level классы `_ExtractJob`/`_ExtractResult` + функция); внутри — переименование реального `*.onnx`/`*.onnx.json` в `model.onnx`/`model.onnx.json`; integrity-чек в main после `compute`.
  - Документация класса/каталога обновлена под реальную структуру архива.
- **`lib/services/tts/offline_tts_isolate.dart`** (новый, ~320 строк): `OfflineTtsIsolate` (persistent worker) + `_LoadResult`/`_GenResult` + top-level `_offlineTtsWorkerMain` + op-code константы. Методы `ensureStarted`/`loadModel`/`generate({gain})`/`freeModel`/`dispose` с request-id и таймаутами. Воркер: `initBindings` + lazy `OfflineTts` + `generate` с пик-нормализацией (0.98) × gain и clamp.
- **`lib/services/tts/offline_tts_engine.dart`**: поле `_tts` → `_isolate`; `_loadModel`/`_maybeUnload` делегируют в изолятор; `speak` вызывает `_isolate.generate(text, rate, gain: gain)`, маппит `volume` (0–3) → `playerVol=min(V,1.0)` + `gain=V>1?V:1`, применяет `_player.setVolume(playerVol)`; генерация/`writeWave`/play в main.
- **`lib/services/tts/system_tts_engine.dart`**: поле `_lastVolume`; `volume` кешируется и переприменяется в `speak`/`initialize`/`applyConfiguredEngine` (раньше хардкод 1.0).
- **`lib/services/study_mode_service.dart`**: новое поле `_speechVolume=1.0`, геттер `speechVolume`, `setSpeechVolume` (кламп 0–3), загрузка/наследование per-song (`studyModeSpeechVolume` / `song_{id}_speechVolume`); в `_speak` передаётся `volume: _speechVolume`.
- **`lib/screens/player_screen.dart`**:
  - `_studySpeechRates` (ChoiceChip'ы) удалён → ползунок скорости 0.3–2.5 (divisions 22).
  - Новый ползунок громкости речи 0.0–3.0 (divisions 30, множитель) + переменная `currentVolume` (синхронизируется при per-song toggle).
  - `_activePlaybackList` (живой список) + `_switchToNextPlaylist`; `_playNextFromAllPlaylists`/`_playSong`/`_playNextSong`/`_playPreviousSong`/`_canPlayNext`/`_canPlayPrevious` переведены на `_activePlaybackList ?? widget.playlistSongs`.
- **`lib/services/database_service.dart`**: `getAllPlaylists()` → `orderBy: 'createdAt ASC'`.
- **`lib/services/tts/tts_catalog.dart`**: комментарий о структуре архива исправлен (реальные имена `*.onnx`/`*.onnx.json`).
- **`lib/l10n/app_*.arb`** (11) + `app_localizations*.dart` (реген через `flutter gen-l10n`): ключ `studyModeSpeechVolume` × 11 языков.
- **`pubspec.yaml`/`app_info.dart`/`build.gradle`/`local.properties`** — 5.6.0 (versionCode 218); features += «🔊 TTS speech volume boost up to 3.0x».

### ⚠️ Известные ограничения
- **Буст речи >1.0x** работает только для офлайн-TTS (системный FlutterTts физически ограничен `setVolume(1.0)`); на 2.5–3.0x возможны искажения (клиппинг пиков) — плата за громкость выше пиковой.
- **Системный TTS rate** при значениях >1.0 ведёт себя ROM-зависимо (для дефолтного офлайн-источника это неактуально — там 1.0=норма маппится 1-в-1 в sherpa `speed`).
- **Per-song `speechVolume`** не включён в экспорт/импорт настроек (как и остальные per-song ключи) — фаза 2.

---

## 🎯 Новое в версии 5.5.0

### 🎯 Новая фича: Калибровка детектора машин (эталоны + Mahalanobis)
- **Задача:** в 5.3.x детектор машин срабатывал на любой шум (ветер, шаги, голоса, музыка из наушников) — пороговая логика (lowDom + centroid + flatness + RMS) не способна надёжно отличить машину от других звуков. Пользователь не мог повлиять на это, кроме как уменьшить sensitivity (что убирает и полезные срабатывания)
- **Решение:** вместо одной пороговой логики — **две ветви** в `CarDetectionService._analyzeFrame`:
  - **Пороговая** (улучшенная, Часть A) — работает, когда у пользователя нет сохранённых эталонов
  - **Mahalanobis-классификация** (Часть B) — включается автоматически при наличии ≥1 car + ≥1 noise эталона; для каждого кадра вычисляется расстояние до каждого профиля, и кадр считается «машина», если ближайший профиль — автомобильный и расстояние меньше адаптивного порога
- **Что может пользователь:**
  - Открыть **экран калибровки** (Настройки → Детекция машин → Калибровка) — отдельный экран с live-спектром
  - **Записать эталон** (5 секунд, выбор класса из 10, имя): carClose/carFar/carTruck/carMotorcycle (триггерят alert), wind/steps/voice/street/music/other (не триггерят). После записи ≥1 car + ≥1 noise — детектор автоматически переключается на Mahalanobis
  - **Загрузить демо-эталоны** одной кнопкой (7 синтетических классов в `assets/calibration/default_profiles.json`, без WAV — пресчитанные mean/std из акустических характеристик)
  - **Удалить** отдельный эталон или **сбросить всё**
- **Улучшения пороговой логики (Часть A, работают и без эталонов):**
  - Окно подтверждения 5 кадров ПОДРЯД (любой miss сбрасывает счётчик) — раньше считались hits в скользящем окне
  - Moving average score за 8 кадров — сглаживает короткие всплески
  - Бонус `lowFrac × 0.15` только если `lowFrac > 0.6` — раньше давался всегда, и шум с лёгким НЧ-уклоном мог добрать score
  - **Adaptive noise floor**: первые ~3 сек после старта пишется фоновый `lowBandEnergy`, затем `_minLowBandEnergy = средний_фон × 3`. Alert выдаётся только если `lowBandEnergy > _minLowBandEnergy` — тихий шум с правильным спектром отсеивается
- **Приватность:** эталоны (только JSON mean/std, без исходного аудио) хранятся локально в SharedPreferences (`carCalibrationProfiles`). Звук анализируется on-device, ничего не записывается и не отправляется

### 🔧 Технические изменения
- `lib/services/calibration_profile.dart` (новый, ~270 строк): `enum ProfileClass` (10 значений) с `extension ProfileClassX` (isCar, icon, wireName); `class CalibrationProfile` с Mahalanobis `distanceTo(SpectrumFeatures)` (диагональная ковариация, ε=1e-6), `toJson`/`fromJson`/`fromSamples` (вычисление mean/std по 6 признакам)
- `lib/services/car_detection_service.dart`:
  - Константы `_confirmMinHits 3→5` (подряд), `_scoreWindowSize=8` (moving average), `_noiseFloorFrames=90` (~3 сек warmup)
  - Новые поля `_consecutiveHits`, `_scoreWindow`, `_minLowBandEnergy`, `_noiseFloorCalibrated`, `_noiseFloorSamples`, `_profiles`, `_useClassification`, `_maxDistance`, `_nearestClass`, `_nearestDistance`
  - `_applySensitivity` теперь также масштабирует `_maxDistance` (sens=0 → 2.0, sens=1 → 6.0)
  - Метод `_analyzeFrame` разбит: общие пред-фильтры (noise floor/silence/wind/step/absolute low band threshold) + ветвление `_classifyFrame` (Mahalanobis) vs `_thresholdFrame` (улучшенная пороговая)
  - `loadCalibrationProfiles()` / `setProfiles()` / `_recomputeClassificationFlag()` — управление эталонами
  - Статический реестр `_activeInstances` + `reloadProfilesInAllActive()` — экран калибровки после изменений обновляет и свой live-сервис, и активный сервис плеера
  - Геттеры для UI калибровки: `profiles`, `useClassification`, `nearestClass`, `nearestDistance`, `maxDistance`
- `lib/screens/car_calibration_screen.dart` (новый, ~780 строк): экран с live-визуализацией спектра (3 bars + flatness/centroid/rms/low-mid), записью эталона (5 сек, dropdown класса, имя), списком эталонов с удалением, кнопками загрузки демо и сброса. Создаёт собственный `CarDetectionService` (изолированный от плеера)
- `app/assets/calibration/default_profiles.json` (новый): 7 синтетических демо-профилей (carClose/carFar/carTruck/wind/steps/street/voice) с теоретическими mean/std в единицах SpectrumFeatures
- `lib/widgets/settings/car_detection_settings_tile.dart`: внутри ExpansionTile добавлен ListTile «Калибровка» (icon tune) → `Navigator.push(CarCalibrationScreen())`
- `pubspec.yaml`: ассет `assets/calibration/`
- `lib/l10n/app_*.arb` (11 файлов) + `app_localizations*.dart` (12 файлов): 35 новых ключей (24 carCalibration* + 10 profileClass* + 1 subtitle) × 11 языков. Генерация через `scripts/add_calibration_l10n.py` (без внешних зависимостей)
- `pubspec.yaml`/`app_info.dart`/`build.gradle`/`local.properties` — 5.5.0 (versionCode 217); features += «🎯 Car detector calibration»

### ⚠️ Известные ограничения
- **Демо-эталоны синтетические** — значения mean/std вычислены теоретически из акустических характеристик (не из реальных записей). На точность Mahalanobis-классификации это влияет: демо-эталоны — стартовая точка, для реальной точности пользователь должен записать свои
- **CPU при классификации**: Mahalanobis distance через 6 признаков × N профилей на каждом кадре. При N=10 и ~30 кадрах/сек = ~180 операций/сек — приемлемо для main isolate
- **Запись своих WAV** для воспроизведения кнопкой ▶ не реализована (по решению разработки) — список эталонов только показывает профиль с кнопкой удаления
- **Per-song калибровка** не реализована — эталоны глобальные на всё приложение

### 🗣️ Новая фича: Офлайн нейро-TTS (sherpa_onnx VITS)
- **Задача:** на realme GT8 Pro (ColorOS China) системный TTS нестабилен в режиме изучения — озвучка «выбивает» через половину песни. Корень: study-режим делает десятки передач аудиофокуса за песню (пауза песни → системный TTS grabs focus → completion → реактивация сессии), что на китайских ROM деградирует в зомби-состояния
- **Решение:** встроенный офлайн-нейро TTS на `sherpa_onnx` (Piper VITS). Аудио TTS проигрывается тем же `just_audio` (второй `AudioPlayer`), что и песня → нет OS-level арбитража фокуса между двумя подсистемами. Системный TTS-сервис не участвует вовсе
- **Архитектура (вариант A — TtsEngine внутри TtsCoordinator):**
  - `TtsCoordinator` (синглтон) сохраняет приоритетную очередь `study > alert` (введена в 5.3.2), но теперь держит **полиморфный `TtsEngine`** вместо прямого `FlutterTts`
  - `SystemTtsEngine` — точная копия логики 5.4.0 (handlers/engine-config/getVoices fallback). Поведение 1-в-1
  - `OfflineTtsEngine` — sherpa_onnx Piper VITS + второй `AudioPlayer` + `writeWave` + Completer + lazy load/`free()`. Для языков без Piper-модели (uk/zh/ar/ja/ko) автоматически fallback'ает на внутренний `SystemTtsEngine`
  - `CarAlertService` остался **без изменений** — координатор сам маршрутизирует alert в активный движок с учётом приоритета
- **Каталог моделей (Piper VITS medium, ~63 МБ/язык):**
  - **ru** — бандл в APK (`assets/tts/ru_RU.tar.bz2`), распаковка при первом включении
  - en/de/es/fr/it/pt/ro — докачка из «Голосовых пакетов» по требованию
  - uk/zh/ar — fallback на системный TTS (нет Piper-моделей)
- **UI:**
  - В Настройках新增 тайл **«Источник озвучки»** (Офлайн / Системный) + тайл **«Голосовые пакеты»** (переход на экран управления моделями)
  - Экран «Голосовые пакеты»: список 8 языков с статусами (готов / не установлено / скачивается / ошибка), кнопки «Скачать/Установить/Удалить», прогресс-бар
  - Диагностический оверлей плеера расширено: `src=offline|system`, `gen=...ms` (время генерации sherpa)
- **Локализация:** 21 новый ключ (`ttsSource*`, `voicePackages*`, `voicePackage*`) × 11 языков через `scripts/add_tts_l10n.py`

### 🔧 Технические изменения (офлайн-TTS)
- **Новые файлы:**
  - `lib/services/tts/tts_engine.dart` — абстракция `TtsEngine` (extends ChangeNotifier): `isReady`/`isLanguageAvailable`/`activeEngine`/`selectedEngine`/`availableEngines`/`lastGenerationMs`/`source`; методы `initialize`/`setLanguage`/`speak({rate,pitch,volume})`/`stop`/`applyConfiguredEngine`/`dispose`
  - `lib/services/tts/system_tts_engine.dart` — перенос логики FlutterTts из `tts_coordinator.dart` 5.4.0 (handlers/engine-config/voice-fallback/locale-mapping), speak через `Completer` + `setCompletionHandler`/`setErrorHandler`
  - `lib/services/tts/offline_tts_engine.dart` — sherpa `OfflineTts` (VITS) + второй `AudioPlayer` + `writeWave` + lazy load/`free()` + внутренний `SystemTtsEngine` fallback для языков без модели
  - `lib/services/tts/tts_catalog.dart` — карта 8 языков: `TtsVoiceInfo` (localeCode, voiceName, speakerName, url, bundled?)
  - `lib/services/tts/tts_model_manager.dart` — ChangeNotifier: статусы моделей, распаковка bundled-ассета (BZip2+Tar через `archive 3.6`), докачка с прогрессом, удаление, атомарный rename через `.tmp`
  - `lib/screens/voice_packages_screen.dart` — UI списка моделей с прогрессом/статусами
  - `lib/widgets/settings/tts_source_tile.dart` — тайл «Источник озвучки» (Dropdown)
  - `lib/widgets/settings/voice_packages_tile.dart` — тайл-переход на экран
- **Изменяемые:**
  - `tts_coordinator.dart` — `FlutterTts _tts` → `TtsEngine _engine`; новая `setTtsSource(source, {languageCode})` создаёт/утилизирует engine (с fallback'ом на system если offline init упал); speak/stop делегируют; handlers переехали в `SystemTtsEngine`; координатор стал `ChangeNotifier` (проксирует `notifyListeners` из engine)
  - `study_mode_service.dart` — убран геттер `_tts` (FlutterTts) и все прямые `setSpeechRate`/`setPitch`/`setVolume`/`setLanguage`/`isLanguageAvailable`/`getVoices`/`setVoice`; `_initTts`/`_setTtsLanguage`/`applyConfiguredEngine` делегируют в координатор; `_trySetVoiceByLocale` удалён (переехал в SystemTtsEngine); watchdog и `_kickPlaybackAsync` остались (safety-net; для офлайна kick выходит на 1-й попытке — сессия не деактивируется)
  - `car_alert_service.dart` — **без изменений** (координатор сам маршрутизирует alert в активный engine)
  - `settings_provider.dart` — `+ttsSource` ('offline'\|'system', дефолт **'offline'**) + persistence
  - `player_screen.dart` — поле `_ttsCoordinator`, `_currentTtsSource`; `_onSettingsChanged` реагирует на смену `ttsSource` → `_applyTtsSource()` → `coordinator.setTtsSource`; overlay показывает `src` и `gen`
  - `pubspec.yaml` — `+sherpa_onnx: ^1.13.3`, `assets: - assets/tts/`, версия 5.5.0
  - `proguard-rules.pro` — `-keep class com.k2fsa.sherpa.onnx.**` для нативных символов
  - `app_info.dart`/`build.gradle` — 5.5.0/versionCode 217; features += «🗣️ Offline neural TTS (sherpa_onnx VITS)»

### ⚠️ Известные ограничения (офлайн-TTS)
- **Размер APK ~214 МБ** (вместо ~64): бандл ru (64 МБ) + нативные `.so` sherpa_onnx для 4 Android ABI (arm64-v8a/armeabi-v7a/x86/x86_64). Митигация: `flutter build apk --split-per-ABI` → arm64 APK ~110 МБ, либо `appbundle` для Play Store
- **Генерация в main isolate** — `sherpa_onnx.generate()` синхронный, блокирует UI на ~0.3–0.5 с на короткую строку перевода (study mode и так паузит песню в этот момент). Isolate-генерация (готовый паттерн `isolate_tts` от sherpa) — будущая оптимизация
- **`ttsSource` не в экспорте настроек** — при переносе настроек на другое устройство источник озвучки не переедет (только глобальные `studyMode*`). Фаза 2
- **`AndroidAudioAttributes(usage: speech)`** на TTS-плеере не проставлен (план §9 mitigation) — теоретически может конфликтовать за фокус с плеером песни, но на практике оба в одной `just_audio` сессии и конфликтов не наблюдалось
- **ProGuard keep-rules для `com.k2fsa.sherpa.onnx.**`** — добавлены превентивно; точный package name Dart-биндингов не верифицирован декомпиляцией. Если release упадёт с `UnsatisfiedLinkError` на первом `OfflineTts()` — корректировать здесь
- **uk/zh/ar через matcha/MMS-модели** — будущая работа (другая конфигурация sherpa, lexicon)

---

## 🎯 Новое в версии 5.3.5

### 🎚️ Новая фича: индивидуальные настройки прослушивания для каждой песни (per-song)
- **Задача:** скорость аудио, скорость речи TTS, порядок (перевод/оригинал/поверх), overlay timing и duck volume были **глобальными** на всё приложение — одни и те же для всех песен. Для разных песен часто нужны разные параметры (медленную балладу хочется слушать на 1.0x, быстрый рэп — на 0.8x; сложный текст — перевод-сначала, лёгкий — overlay)
- **Решение:** для каждой песни появился переключатель **«Свои настройки для этой песни»** в диалоге настроек режима изучения (⚙ в AppBar плеера). При включении все 5 параметров привязываются к конкретной песне; при выключении — действуют общие настройки приложения
- **Параметры, настраиваемые per-song:**
  - ⏩ **Скорость воспроизведения** (0.50x–2.00x, слайдер в диалоге) — теперь в том же диалоге, что и study-настройки
  - 🗣️ **Скорость речи TTS** (ChoiceChip'ы)
  - 🔀 **Порядок** (перевод-сначала / оригинал-сначала / overlay)
  - ⏱️ **Overlay timing** (начало / конец / оба) — только в режиме overlay
  - 🔉 **Duck volume** (громкость приглушённой песни в overlay) — только в режиме overlay
- **Логика переопределения (3-state):** для каждой песни по умолчанию действуют глобальные настройки. Пользователь чекбоксом включает per-song override → при первом включении **текущие глобальные значения наследуются** как стартовые per-song (не надо начинать с нуля) → дальше меняет под песню. При выключении — немедленный откат к глобальным
- **Хранение:** `SharedPreferences` с ключами `song_{id}_override` (master-флаг) + `song_{id}_playbackSpeed/speechRate/order/overlayTiming/duckVolume`. **БД не затронута** — никаких миграций, версия БД осталась 11. Глобальные настройки (`studyMode*`, `playbackSpeed`) не перетираются per-song значениями
- **Применение при смене песни:** `PlayerScreen._playSong` и `_initSongData` вызывают `StudyModeService.applyPerSongSettings(songId)` + `AudioService.applyPerSongSettings(songId)` ДО загрузки аудио — к моменту `loadAudio`/`handler.playSong` скорость и study-параметры уже корректны для новой песни. Это работает и при ручном next/prev, и при авто-переходе (background notification → callback → `_playSong`)

### 🐛 Фикс: study mode (озвучка перевода) и car detection не убирались из режима редактирования меток
- **Симптом:** в режиме простановки таймстампов (⋮ → «Редактировать метки») кнопки 🎤 (study mode) и 🚗 (car detection) оставались в AppBar и активными. Озвучка перевода продолжала работать поверх установки меток, мешая; пользователь не мог от неё избавиться (она там логически не нужна)
- **Причина:** `_buildAppBarContent` показывал `_buildCarDetectionButton` и `_buildStudyModeButton` безусловно (без проверки `_isEditMode`); переключатель edit mode только менял флаг и добавлял кнопку 💾 save, не трогая study/car
- **Решение:**
  - При входе в edit mode активный study mode **автоматически останавливается** (`_studyModeService.stop(userRequested: true)` — сбрасывает и persist-флаг, чтобы авто-restart не перезапустил озвучку). Car detection НЕ глушится (он не мешает простановке меток)
  - Кнопки 🎤 и 🚗 **скрыты** из AppBar пока активен edit mode (взаимоисключение с кнопкой 💾 save)
  - Адаптивный счётчик `cnt` пересчитан: в edit mode теперь 5 кнопок (tune, save, swap, transcription, popup) вместо 7 — размер `bs` корректный, никаких визуальных скачков
  - При выходе из edit mode: 🎤 и 🚗 возвращаются; study mode **НЕ перезапускается** автоматически (пользователь сам включит если нужно)

### 🐛 Фикс: race condition «зомби-цикла» _kickPlayback при смене песни с per-song настройками
- **Симптом:** при переходе на песню с включёнными per-song настройками звук «шёл параллельно и не так» (накладывающийся/рассинхронизированный). Открытие и закрытие диалога study-настроек «чинило» воспроизведение
- **Корень:** `_kickPlaybackAsync()` — fire-and-forget цикл до 6 попыток с `await`-ами по 400мс–1с (реактивация audio-сессии после TTS). Он проверял только общие флаги `_isActive`/`_isUserPaused` без «токена поколения». При смене песни: `_playSong` → `stop()` сбрасывал `_isActive=false`, но `_kickPlaybackAsync` старой песни **ещё крутился** внутри своего `await`. Затем `applyPerSongSettings` + загрузка аудио + `_restartStudyIfNeeded` → `start()` снова поднимал `_isActive=true`. Зомби-цикл просыпался, видел `_isActive=true` и **продолжал работать** поверх нового цикла: вызывал `play()`/`seek()` уже над новым плеером, по старым таймингам → накладывающийся звук. `stop()` не дожидался завершения kick-цикла
- **Почему диалог чинил:** `_openStudyModeSettings` перед показом вызывает `pauseSession()`, который ставил `_isUserPaused=true` → зомби вылетали на проверке; после закрытия диалога `resumeSession()` поднимал один чистый цикл
- **Решение (минимальное, без переписывания архитектуры):**
  - Новое поле `Future<void>? _kickPlaybackFuture` хранит активный kick-цикл
  - `_kickPlayback()` сохраняет Future в поле при запуске
  - `stop()` и `pauseSession()` **сначала сбрасывают флаги** (`_isActive=false` / `_isUserPaused=true`), затем **await-ят `_kickPlaybackFuture` с таймаутом 2с** — зомби гарантированно завершается до возврата из stop/pause, а значит до нового `start()` при смене песни
  - **Дополнение (session-token для `_speakOver().then`):** второй fire-and-forget — `_speak(text).then(...)` в `_speakOver`. Когда stop() резольбит speak Future через `_ttsCoordinator.stop()`, `.then`-колбэк попадает в очередь и мог дожить до нового `start()` (проверка `_isActive` уже TRUE от новой песни) → вызывал `_kickPlayback()` и создавал **новый** зомби-kick уже после drain. Это давало остаточный симптом «несколько секунд каши в начале, потом ок». Решение: поле `int _sessionToken = 0`, инкрементируется в `stop()`; `_speakOver` захватывает токен при старте и проверяет `token == _sessionToken` в трёх точках `.then`-колбэка (вход, после `_restoreVolume`, после `Future.delayed`) — при несовпадении мгновенно выходит, не создавая зомби
- **Результат:** при смене песни `stop()` не возвращается, пока старый kick-цикл реально не завершится, а висящие `.then`-колбэки инвалидируются токеном → к моменту `start()` новой песни ноль зомби → чистое воспроизведение с первой секунды, без диалога-«костыля» и без «каши»

### 🔧 Технические изменения
- `lib/services/audio_service.dart`:
  - новые поля `_globalPlaybackSpeed` (дефолт, не затирается per-song), `_perSongOverride`, `_perSongSongId`
  - геттеры `globalPlaybackSpeed`, `perSongOverride`
  - `_loadPlaybackSettings`/`_savePlaybackSettings` работают с `_globalPlaybackSpeed` (не с активной `_playbackSpeed`) — глобальный дефолт не портится per-song переопределением
  - новый `applyPerSongSettings(String songId)`: читает `song_{id}_override`, выставляет `_playbackSpeed` из per-song или глобального, live-применяет к `_player` и `_backgroundHandler`. Должен вызываться ДО `loadAudio`
  - новый `setPerSongOverride(bool)`: пишет флаг, при включении наследует текущую скорость как стартовую per-song, при выключении откатывается к глобальной
  - `setPlaybackRate(double)`: при активном override пишет в `song_{id}_playbackSpeed` (глобальный не трогает), иначе как раньше в `playbackSpeed`
- `lib/services/study_mode_service.dart`:
  - новые поля `_perSongOverride`, `_perSongSongId`; геттер `perSongOverride`
  - `_loadSettings` рефакторен: вынесен `_loadValuesFromPrefs({perSong, songId})` — грузит 4 значения (order/speechRate/overlayTiming/duckVolume) из per-song или глобальных ключей
  - новый `applyPerSongSettings(String songId)`: определяет override, грузит значения, live-применяет `_tts.setSpeechRate`. `enabledPersist` остаётся глобальным
  - новый `setPerSongOverride(bool)`: пишет флаг, при первом включении наследует текущие (глобальные) значения в per-song ключи, перезагружает значения
  - `setOrder`/`setSpeechRate`/`setOverlayTiming`/`setDuckVolume`: при активном override (`_usePerSong`) пишут в `song_{id}_*` ключи, иначе как раньше в `studyMode*`
- `lib/screens/player_screen.dart`:
  - `_initSongData`: в самом начале (до любой загрузки аудио) вызывает `applyPerSongSettings` для обоих сервисов + синхронизирует локальную `_playbackSpeed`
  - `_playSong`: после установки `_currentSong` и до `loadAudio`/`handler.playSong` — те же вызовы `applyPerSongSettings` + `setState(_playbackSpeed)`
  - `_showStudyModeSettingsDialog`: сверху новый `SwitchListTile` «Свои настройки для этой песни»; при переключении вызывает `setPerSongOverride` для обоих сервисов и обновляет локальные переменные диалога; внизу новый `Slider` скорости воспроизведения (0.50–2.00x); при закрытии диалога синхронизирует локальную `_playbackSpeed` с сервисом; индикатор названия песни когда override активен
- `lib/l10n/app_*.arb` (11 языков) + сгенерированные `app_localizations*.dart`: 2 новых ключа `studyPerSongOverride` / `studyPerSongOverrideSubtitle` (через `flutter gen-l10n`)
- `app_info.dart`: versionCode 212 → 215 (синхронизация с gradle/pubspec); features += «🎚️ Per-song study settings»

### ⚠️ Известные ограничения
- **Export/Import настроек** (`settings_export_service.dart`): per-song ключи `song_*` пока НЕ включены в экспорт — при переносе настроек на другое устройство per-song параметры не переедут (только глобальные). Фаза 2
- **Fallback background-перехода** (`skipToQueueItem` в `BackgroundAudioHandler`, когда `PlayerScreen` уже dispose'нут): per-song скорость не применяется (используется текущая активная). Это редкий случай (приложение долго в фоне без UI), и текущее поведение там и так не гарантировало корректную скорость. Не регрессия
- **Удаление песни:** осиротевшие ключи `song_{id}_*` остаются в SharedPreferences (~0.5 КБ на песню). Можно чистить в `DatabaseService.deleteSong` — не критично

---

## 🎯 Новое в версии 5.3.4

### 🐛 Фикс: кнопка выбора языка всё-таки уезжала за правый край AppBar плеера
- **Симптом (после 5.3.3):** на узких телефонах кнопка выбора языка перевода по-прежнему обрезалась/уезжала за правый край, а между стрелкой «назад» и кластером кнопок (🚗/🎤/…) оставалось большое пустое место
- **Почему 5.3.3 не помог полностью:** тот фикс лишь прижал размер кнопок car/study к адаптивному `bs` (48→bs), но **не трогал структуру Row**. Зазор создавало `mainAxisAlignment: MainAxisAlignment.end` (контент прижат вправо, пустота слева), а язык уезжал за край, потому что дропдаун выбора языка был **последним (самым правым) ребёнком** Row — при любом переполнении/узком экране именно он срезается правым краем
- **Решение (перепроектирование Row в `_buildAppBarContent`):**
  - Дропдаун выбора языка **перенесён в начало Row** (первый ребёнок, сразу после стрелки «назад») — теперь он якорится слева и физически не может уехать за правый край
  - `mainAxisAlignment: MainAxisAlignment.end` → **`MainAxisAlignment.start`** — кластер кнопок прижат к стрелке «назад», зазор устранён
  - Верхний clamp `bs` поднят **44 → 52** — на широких экранах кнопки заполняют ширину, меньше пустого места
  - Сам блок языка вынесен в локальную переменную `langPicker` (читаемость, без дублирования)
- **Результат на экране:** `[←] [🇬🇧 English ▾] [🚗][🎤][⚙][⇅][A][⋮]` — язык всегда видим слева, между «назад» и 🚗 нет зазора, тумблеры ⇅/A остаются на месте

### 🔧 Технические изменения
- `lib/screens/player_screen.dart`: в `_buildAppBarContent` — локальная `langPicker` (бывший инлайн-Container выбора языка); порядок детей Row изменён (`if (hd) langPicker` + `if (hd) SizedBox(8)` перенесены в начало); `MainAxisAlignment.end` → `MainAxisAlignment.start`; `bs` clamp `.clamp(18.0, 44.0)` → `.clamp(18.0, 52.0)`; удалён хвостовой `const SizedBox(width: 4)`
- `pubspec.yaml`/`app_info.dart`/`build.gradle` — 5.3.4 (versionCode 214)

---

## 🎯 Новое в версии 5.3.3

### 🐛 Фикс: AppBar плеера и тайл TTS-движка не влезали на узких экранах
- **Симптом 1:** в интерфейсе чтения текста песни между стрелкой «назад» и кластером кнопок (детекция машин / режим изучения / …) оставалось большое пустое место, а **кнопка выбора языка перевода не помещалась** и обрезалась на узких телефонах
- **Корень 1:** в `_buildAppBarContent` рассчитывается адаптивный размер кнопок `bs` (чтобы все кнопки + дропдаун языка укладывались в ширину экрана), но `_buildStudyModeButton` и `_buildCarDetectionButton` создавали `IconButton` **без `constraints`** → Material по умолчанию отводил им минимум **48×48** (`kMinInteractiveDimension`) вместо расчётных ~30px. Остальные кнопки имели `BoxConstraints.tightFor(bs)` и слушались. Итог: 2 кнопки «съедали» ~35 лишних px → дропдаун выбора языка уходил в overflow
- **Решение 1:** в обе кнопки добавлены `boxSize`-параметр, `constraints: BoxConstraints.tightFor(width: boxSize, height: boxSize)` и `padding: EdgeInsets.zero` — теперь они занимают ровно `bs` как и все остальные, и выбор языка помещается на узких экранах
- **Симптом 2:** в Настройках выбор TTS-движка (Motor TTS / Google TTS / …) на узких экранах расписывался **по одной букве в строку**, занимая весь экран
- **Корень 2:** `TtsEngineSettingsTile` использовал `trailing: DropdownButton(isExpanded: false)`. Самый широкий item («Авто (рекомендуется)» + длинные лейблы движков) раздувал дропдаун, а `ListTile` на узком экране сжимал `trailing` до совсем малой ширины — `Text` без `maxLines`/`overflow` переносился посимвольно
- **Решение 2:** `DropdownButton` обёрнут в `ConstrainedBox(maxWidth: 130)`, установлен `isExpanded: true`, а всем `Text` item'ов — `maxLines: 1, overflow: TextOverflow.ellipsis`. Ширина дропдауна фиксирована и не зависит от того, как `ListTile` делит место между title/subtitle/trailing

### 🔧 Технические изменения
- `lib/screens/player_screen.dart`: `_buildStudyModeButton` и `_buildCarDetectionButton` — новый параметр `boxSize`, `IconButton` теперь с `padding: EdgeInsets.zero` + `constraints: BoxConstraints.tightFor(width: boxSize, height: boxSize)`; вызовы в `_buildAppBarContent` передают `boxSize: bs`
- `lib/widgets/settings/tts_engine_settings_tile.dart`: `trailing` обёрнут в `ConstrainedBox(maxWidth: 130)`; `DropdownButton` → `isExpanded: true`; `Text` item'ов → `maxLines: 1, overflow: TextOverflow.ellipsis`
- `pubspec.yaml`/`app_info.dart`/`build.gradle` — 5.3.3 (versionCode 213)

---

## 🎯 Новое в версии 5.3.2

### 🐛 Фикс: детекция машин ломала озвучку перевода + ложные срабатывания на шорохи
- **Симптом 1:** после включения кнопки 🚗 TTS-озвучка перевода в study mode полностью замолкала до конца сессии
- **Симптом 2:** детектор срабатывал от любого шороха/шага/ветра; слайдер «чувствительность» в Настройках не влиял на поведение
- **Корень 1 (TTS-конфликт):** `flutter_tts` использует единый `MethodChannel('flutter_tts')` на всё приложение — два экземпляра `FlutterTts` (`StudyModeService._tts` и `CarAlertService._tts`) перетирали друг другу `setCompletionHandler`. Когда детекция вызывала `CarAlert._tts.speak("Внимание, машина")`, completion-handler study mode терялся → watchdog (12с) срабатывал → `setSpeakDisabled(true)` → TTS перевод отключался до конца песни
- **Корень 2 (CPU-конфликт):** FFT-анализ в main isolate каждые 16 мс (60 Гц) мешал study-таймерам (`segmentTimer` 150мс, `positionTimer` 50мс) и TTS handlers вовремя срабатывать
- **Корень 3 (sensitivity):** параметр `sensitivity` принимался в `start()`, но не использовался в decision-логике — пороги были `static const`
- **Решение (Phase A):**
  - **A1 — Единый `TtsCoordinator` (новый файл `tts_coordinator.dart`):** один `FlutterTts` на всё приложение, единая пара `setCompletionHandler/setErrorHandler`. Запросы `speak()` упорядочены по приоритету (`study > alert`): если study mode озвучивает перевод, голосовой alert **автоматически пропускается** координатором, не прерывая речь. `StudyModeService` и `CarAlertService` инжектят координатор вместо своих `FlutterTts()`
  - **A2 — Снижение частоты FFT:** `_hopSize 256 → 512` (анализ каждые 32 мс вместо 16 мс, **−50% CPU в main isolate**), окно подтверждения 6→4 кадра. Таймеры study mode снова успевают нормально срабатывать
  - **A3 — Реальная чувствительность:** пороги переведены из `static const` в instance fields, метод `_applySensitivity(sensitivity)` линейно интерполирует пороги (sens=0 → строгие 0.60 score / 2.8× lowDom / 0.020 rms; sens=1 → мягкие 0.30 / 1.4× / 0.008; sens=0.5 → средние 0.45 / 2.1× / 0.014). Дефолт поднят с 0.5 до **0.4** (чуть строже, чтобы убрать ложные на шорохи)
  - **A4 — Фильтр ветра/шагов:** в `_analyzeFrame` добавлены 2 пред-фильтра перед основным decision:
    - **Ветер/шорох:** если `flatness > 0.35` и `low/mid < 2.0` → равномерный шум с лёгким НЧ-уклоном → score=0
    - **Шаг/удар:** если `rms > 0.08` (очень громко) и `centroid > 600 Hz` → широкополосный всплеск (телефон трясётся в кармане) → score=0
    - Настоящая машина = узкий НЧ-пик: lowDom сильный + peaked (flat<порог) + низкий центроид + длительность
  - **A5 — Адаптивный throttle:** при активном TTS study mode интервал между alert'ами растёт с 2 сек до **5 сек** (через callback `isStudySpeaking`, который PlayerScreen подключает к `StudyModeService.isSpeaking`). Beep и вибрация остаются (не перебивают TTS так грубо, как голосовой alert)

### 🔧 Технические изменения
- `lib/services/tts_coordinator.dart` (новый, ~210 строк): синглтон `TtsCoordinator.instance`, один `FlutterTts`, enum `TtsPriority { study, alert }`, `_TtsRequest` с completer, методы `speak(text, {priority, locale, rate, pitch, volume})` и `stop()`, `_applyConfiguredEngine()` (Google TTS приоритет, делегировано из StudyModeService), единые handlers `_handleCompletion/_handleError`
- `lib/services/study_mode_service.dart`: `_tts` теперь геттер к `TtsCoordinator.instance.tts` для конфигурации; речь — через `_ttsCoordinator.speak(text, priority: study)`; `_speak` переписан — watchdog через `.timeout()` на future координатора; убраны `_speakCompleter`/`_resolveSpeak`; `_applyConfiguredEngine` делегирует в координатор; `_initTts` теперь просто прогревает координатор
- `lib/services/car_alert_service.dart`: `_tts` теперь `TtsCoordinator.instance`; `_speak` вызывает `_tts.speak(text, priority: alert, ...)` — координатор сам пропустит запрос если study mode говорит; убран собственный `FlutterTts()`/`setSpeechRate`/`setLanguage`; dispose больше не вызывает `_tts.stop()` (координатор общий, нельзя останавливать чужую речь)
- `lib/services/car_detection_service.dart`:
  - `_hopSize 256 → 512`; `_confirmWindow 6 → 4`
  - пороги `_minRms`/`_lowDominanceRatio`/`_scoreThresholdLow/Medium/High`/`_maxFlatnessForCar`/`_maxCentroidHz` переведены в instance fields (не const)
  - новый метод `_applySensitivity(double)` с линейной интерполяцией порогов; вызывается в `start()`
  - 2 новых фильтра в `_analyzeFrame`: wind-noise (`flatness>0.35 + low/mid<2.0`) и step-impact (`rms>0.08 + centroid>600`)
  - `_maybeFireAlert` использует адаптивный throttle: 5 сек если `isStudySpeaking()==true`, иначе 2 сек
  - новое public поле `bool Function()? isStudySpeaking`
- `lib/services/settings_provider.dart`: дефолт `carDetectionSensitivity` 0.5 → **0.4**
- `lib/screens/player_screen.dart`: `_carDetectionService.isStudySpeaking = () => _studyModeService.isSpeaking` (даёт детектору знать, когда не молоть alert'ами поверх перевода)
- `pubspec.yaml`/`app_info.dart`/`build.gradle` — 5.3.2 (versionCode 212)

### ⚠️ Что НЕ вошло в Phase A (запланировано в Phase B)
- **B1 — FFT в отдельный Isolate** (long-lived через `Isolate.spawn` + SendPort) — пока FFT остаётся в main, но частота снижена в 2 раза, что достаточно для нормальной работы study mode
- **B2 — Beep через SoundPool** вместо второго `just_audio` AudioPlayer — пока beep играет через отдельный AudioPlayer, может слегка «конкурировать» с основным плеером в моменты kickPlayback
- **B3 — Co-ownership AudioSession** — пока полагаемся на `audioInterruption: none` в `RecordConfig`

---

## 🎯 Новое в версии 5.3.1

### 🐛 Фикс: кнопка детекции машин останавливала музыку и TTS study mode
- **Симптом:** при включении детекции (кнопка 🚗) музыка ставилась на паузу, а TTS-озвучка перевода прерывалась
- **Причина:** в `RecordConfig` пакета `record` дефолтные настройки вмешивались в аудио-сессию Android:
  - `audioInterruption: AudioInterruptionMode.pause` (дефолт) → `record_android` вызывает `AudioManager.requestAudioFocus(AUDIOFOCUS_GAIN)` с атрибутами `USAGE_MEDIA + CONTENT_TYPE_SPEECH` → **полный захват фокуса**, остальные источники приглушаются/останавливаются
  - `BackgroundAudioHandler._initAudioSession()` подписан на `interruptionEventStream` → при потере фокуса вызывает `pause()` → музыка встаёт, TTS теряет возможность говорить
  - `androidConfig.manageBluetooth: true` (дефолт) → пытается переключиться на Bluetooth SCO, ломает A2DP routing наушников
- **Решение:** в `CarDetectionService.start()` RecordConfig явно настроен «ненавязчиво»:
  - `audioInterruption: AudioInterruptionMode.none` → НЕ запрашивать audio focus
  - `androidConfig: AndroidRecordConfig(manageBluetooth: false, audioSource: mic, audioManagerMode: modeNormal)` → не трогать bt routing и audio mode
- Микрофон пишет параллельно с музыкой и TTS без каких-либо конфликтов фокуса

### 🔧 Технические изменения
- `lib/services/car_detection_service.dart`: `RecordConfig` расширен параметрами `audioInterruption`/`androidConfig` с подробным комментарием-обоснованием; дефолт `start({sensitivity = 0.4})` (синхронизировано с дефолтом настроек)
- `pubspec.yaml`/`app_info.dart`/`build.gradle` — 5.3.1 (versionCode 211)

---

## 🎯 Новое в версии 5.3.0

### 🚗 Новая фича: Детекция машин через микрофон (безопасность бегуна)
- **Задача:** при беге с музыкой в наушниках бегун не слышит приближающийся транспорт и вынужден постоянно оборачиваться
- **Решение:** фоновый спектральный анализ звука с микрофона + предупреждение бегуна (звук/вибрация/голос)
- **Технический подход:** чистый Dart FFT (Cooley-Tukey, radix-2) на потоке PCM 16kHz моно; ML-модель НЕ используется (YAMNet .tflite недоступна для прямой загрузки, а tflite_flutter нестабилен на новых NDK). Вместо этого:
  - Скользящее окно 512 семплов (32 ms) с перекрытием 50% → анализ каждые 16 ms
  - Hann window → FFT → magnitude spectrum
  - Извлечение признаков: энергии полос (low 20-300 Гц, mid 300-2000, high 2k-8k), спектральный центроид, spectral flatness, RMS
  - Decision-логика: доминирование НЧ (`lowDom`) + низкий центроид + пиковый (не шумовой) спектр → score 0..1
  - Подтверждение: нужно N≥3 срабатываний в окне 6 кадров (~96 ms), иначе одиночные всплески отсеиваются
  - Throttle: не чаще раза в 2 сек
  - 3 уровня уверенности: low / medium / high
- **Предупреждения (настраиваются в Настройках):**
  - 🔊 **Звук** — короткий beep (880 Гц × 3) из `assets/sounds/car_alert.wav` поверх музыки
  - 📳 **Вибрация** — `HapticFeedback.heavyImpact` (1-3 раза по уровню)
  - 🗣️ **Голос** — TTS-фраза на языке интерфейса («Внимание, едет машина» / «Attention, car approaching» и т.д. — 11 языков)
- **Приватность:** звук анализируется **только on-device**, ничего не записывается и не отправляется
- **UI:**
  - Кнопка 🚗 в AppBar плеера (как «Изучение») с подсветкой активности и красным миганием при срабатывании
  - Persist-флаг: один раз включил — держится между запусками и песнями
  - Overlay-индикатор над текстом песни: статус listening + последний score/класс
  - ExpansionTile в Настройках: главный переключатель + слайдер чувствительности (0-100%, 10 шагов) + 3 переключателя типов предупреждений + privacy-нота
- **Локализация:** 15 новых ключей (`carDetection*`, `carAlert*`) во всех 11 языках (`.arb` + `app_localizations_*.dart`)

### 🔧 Технические изменения
- `AndroidManifest.xml`: 4 новых permission — `RECORD_AUDIO`, `MODIFY_AUDIO_SETTINGS`, `FOREGROUND_SERVICE_MICROPHONE`, `VIBRATE`
- `pubspec.yaml`: `record: ^7.1.1` (захват микрофона через `AudioRecorder.startStream(RecordConfig)`); `share_plus` 9 → 10.1.4 (требуется для совместимости `record 7.x` ↔ `web 1.x`); ассеты `assets/sounds/`
- `lib/utils/fft.dart` (новый, ~210 строк): `Fft.transform` (radix-2 Cooley-Tukey in-place), `Fft.hannWindow`, классы `SpectrumFeatures` и `SpectrumAnalyzer` (полосные энергии, centroid, flatness, RMS)
- `lib/services/car_detection_service.dart` (новый): `CarDetectionService extends ChangeNotifier` — потоковый захват PCM 16-bit LE, sliding-window FFT с hop=256, decision-логика (lowDom/centroid/flatness → score), окно подтверждения, throttle, геттеры диагностики
- `lib/services/car_alert_service.dart` (новый): `CarAlertService` — beep через отдельный `just_audio.AudioPlayer`, вибрация через `HapticFeedback`, TTS через `FlutterTts`; фразы/локали на 11 языках
- `assets/sounds/car_alert.wav` (новый, 55 КБ, 0.63 с): 3 beep 880 Гц с attack/decay envelope; генерируется `scripts/gen_car_alert.py`
- `lib/services/settings_provider.dart`: 5 новых полей (`carDetectionEnabled`, `carDetectionSensitivity`, `carAlertSound`, `carAlertVibration`, `carAlertVoice`) + геттеры/сеттеры/persistence по существующему паттерну
- `lib/widgets/settings/car_detection_settings_tile.dart` (новый): `ExpansionTile` с переключателем, слайдером чувствительности и 3 `SwitchListTile` для типов предупреждений
- `screens/settings_screen.dart`: импорт + вставка `CarDetectionSettingsTile` рядом с TTS-движком
- `screens/player_screen.dart`: импорты; поля `_carDetectionService`/`_carAlertService`; инициализация в `initState` + авто-старт по persist (`_maybeAutoStartCarDetection` через post-frame); dispose; `_onCarDetection` listener → `_carAlertService.alert`; `_toggleCarDetection`; `_buildCarDetectionButton` (AnimatedBuilder с активным/алертным состояниями); кнопка в `_buildAppBarContent` (cnt 5→6); overlay-индикатор над текстом песни
- `lib/l10n/app_*.arb` + `lib/l10n/app_localizations*.dart`: 15 × 11 = 165 новых строк (генерация `scripts/add_car_l10n.py` + `scripts/add_car_l10n_dart.py`)
- `pubspec.yaml` и `app_info.dart` — 5.3.0 (versionCode 209); features += «🚗 Car detection via microphone (safety for runners)»

### ⚠️ Известные ограничения (Фаза 1 MVP)
- **Фоновый режим при выключенном экране** пока не реализован — детекция работает пока экран включён и LingoTune на переднем плане. Полноценный foreground service с типом `microphone` — Фаза 3
- **Ducking музыки** при beep не делается (beep играет поверх) — Фаза 2
- **Wind-noise фильтр** базовый (через spectral flatness) — тюнинг под бег потребуется после полевых тестов
- Тюнинг порогов (`_lowDominanceRatio`, `_maxCentroidHz`, `_confirmMinHits`) выполнен «по теории» — реальные значения подбираются после тестов на бегу

---

## 🎯 Новое в версии 5.2.0

### 🐛 Фикс: TTS-движок не находился на Android 11+ (китайские ROM, realme GT8 Pro)
- **Симптом:** на устройствах с китайской ROM (realme GT8 Pro China, ColorOS) приложение «не видит» системный TTS — озвучка перевода в режиме изучения молчит. При этом Duolingo на том же телефоне говорит
- **Причина 1 (манифест):** в `AndroidManifest.xml` отсутствовал `<queries>` для `android.intent.action.TTS_SERVICE`. На Android 11+ (API 30+, у realme GT8 Pro — API 35) действует package visibility: без этого объявления приложение физически не может перечислить/опросить системные TTS-движки
- **Причина 2 (движок по умолчанию):** код использовал только движок по умолчанию — на ColorOS China это «Heytap Speech Engine», который часто врёт в isLanguageAvailable и/или молча не синтезирует. getEngines/setEngine/getVoices/setVoice не использовались вовсе
- **Решение:**
  - `<queries>` TTS_SERVICE — движки снова видны приложению
  - Перебор движков (getEngines + setEngine): приоритет Google TTS (`com.google.android.tts`) над кривым дефолтным; режим «Авто»
  - Fallback на getVoices/setVoice: когда isLanguageAvailable врёт (голос установлен, но движок сообщает «недоступно») — ищем голос по локали и выставляем напрямую
  - Настройка «Движок TTS» в Настройках: выпадающий список («Авто (рекомендуется)» + все движки системы с человекочитаемыми именами)
- Диагностический оверлей расширен: engine=/engines=/langAvail=/speakDisabled=
- Подтверждено на realme GT8 Pro: озвучка работает локально через Google TTS (без интернета)

### 🔧 Технические изменения
- `AndroidManifest.xml`: `<queries>` → TTS_SERVICE
- `study_mode_service.dart`: поля `_availableEngines`/`_selectedEngine`; `_applyConfiguredEngine` (чтение `ttsEngine` из prefs, приоритет Google TTS, `setEngine`); `_trySetVoiceByLocale` (fallback `getVoices`/`setVoice`); `applyConfiguredEngine` (применение при старте study)
- `settings_provider.dart`: поле `ttsEngine` (String, дефолт `''` = Авто) + getter/setter/persistence
- `utils/tts_engine_helper.dart` (новый): `enumerateTtsEngines()` + карта человекочитаемых меток движков
- `widgets/settings/tts_engine_settings_tile.dart` (новый): тайл выбора движка (DropdownButton)
- `settings_screen.dart`: тайл «Движок TTS» рядом с «Служебные данные»
- `player_screen.dart`: оверлей расширен (`engine`/`engines`/`langAvail`/`speakDisabled`)
- Локализация: 4 новых ключа (`ttsEngine`, `ttsEngineSubtitle`, `ttsEngineAuto`, `ttsEngineReloadHint`) во всех 11 языках
- `pubspec.yaml` и `app_info.dart` — 5.2.0 (versionCode 208)

---

## 🎯 Новое в версии 5.1.0

### 🐛 Фикс: на устройствах без русского TTS-голоса озвучка молчала и приложение жутко тормозило
- **Симптом:** на некоторых устройствах (особенно китайские ROM, напр. Realme GT8 Pro China) озвучка перевода не работала — в моменты TTS была тишина и приложение сильно лагало. На устройствах с установленным русским голосом (напр. Realme GT 5) всё работает
- **Причина:** `FlutterTts` использует системный TTS-движок. Если нужный язык не установлен (китайский ColorOS часто идёт без Google TTS и без русского голоса), движок принимает `speak()`, но не говорит и не шлёт completion → `_speak` висел до watchdog-таймаута **до 66 секунд на каждую строку**. В режиме «после оригинала» аудио на это время ставится на паузу → тишина + лаги строка за строкой. При этом `_ttsReady` оставался `true` независимо от наличия языка
- **Решение:**
  - **Детект доступности языка** (`checkLanguageAvailable` / `isLanguageAvailable` / `activeEngine`): проверка `isLanguageAvailable` для текущего языка перевода
  - **Диалог при ручном включении study:** если голос не установлен — диалог «Нет голоса для этого языка» с инструкцией установить TTS-движок (Google/Yandex) и кнопками «Продолжить без озвучки» (режим только фрагменты) / «Отмена». При авто-старте/рестарте — автоматический переход в режим «только фрагменты» без диалога
  - **Fail-fast watchdog:** таймаут сокращён с ~66с до **≤12с**, при срабатывании TTS авто-отключается на сессию → больше никаких долгих зависаний (раннер идёт по сегментам)
  - **Режим «только фрагменты»** (`speakDisabled`): `_speak` становится no-op, study проигрывает сегменты без озвучки — приложение не виснет
- Диагностический оверлей расширен: `TTS engine=… langAvail=… speakDisabled=…`

### 🔧 Технические изменения
- `study_mode_service.dart`: поля `_langAvailable`/`_speakDisabled`/`_activeEngine` + геттеры + `setSpeakDisabled` + `checkLanguageAvailable`; `_setTtsLanguage` записывает доступность; `_initTts` запоминает движок (`getDefaultEngine`); `_speak` — early-return при `_speakDisabled`, watchdog ≤12с + авто-disable при срабатывании
- `player_screen.dart`: `_ensureTtsReady({fromUser})` pre-flight + `_showTtsUnavailableDialog()`; вызов в `_toggleStudyMode`/`_maybeAutoStartStudy`/`_restartStudyIfNeeded`; поля в оверлее
- Локализация: 4 новых ключа (`studyModeStartedNoVoice`, `ttsLangMissingTitle`, `ttsLangMissingBody`, `ttsContinueNoVoice`) во всех 11 языках (`.arb` + сгенерированные `.dart`)
- `pubspec.yaml` и `app_info.dart` — 5.1.0 (versionCode 207)

---

## 🎯 Новое в версии 5.0.9

### 🐛 Фикс: после переключения песни первая фраза повторялась (проигрывалась без study, потом study отматывал и играл заново)
- **Симптом (появился после фикса 5.0.8):** при авто/ручном переходе на следующую/предыдущую песню аудио начинало играть (~2-3с кнопка study ещё не горела), затем study включался и **отматывал к началу строки 0 и проигрывал её заново**
- **Причина:** после таймаут-фикса 5.0.8 `handler.playSong` стал возвращать управление, но между запуском аудио и стартом study (через `ensurePlaybackAdvancing` + задержку restart) проходило ~2-3с — за это время позиция уходила на ~1-2с внутрь строки 0. Затем study стартовал и в `_playSegmentAndAwait(0)` безусловно делал `seek(lines[0].startTime = 0с)` → отматывал назад → повтор
- **Решение:**
  - **Guard на seek к началу строки** (`_playSegmentAndAwait` и `_handleTranslationFirst`): seek делается только если текущая позиция ДО начала сегмента. На нормальных переходах строка→строка позиция уже ≈ startMs (seek и так избыточен) → поведение не меняется. На старте после переключения (позиция уже внутри строки 0) → seek назад не делается, study мягко подхватывает с текущей позиции — **без повтора**
  - Сокращено «окно» без активного study: таймаут `_player.play()` в `handler.playSong` 2с → 1с; задержка `_restartStudyIfNeeded` 150мс → 50мс
- Диагностика 5.0.7 (оверлей + хлебные крошки) оставлена для подтверждения; будет почищена в следующем релизе

### 🔧 Технические изменения
- `study_mode_service.dart`: `_playSegmentAndAwait` и `_handleTranslationFirst` — seek к началу строки только при `position < startMs`
- `background_audio_handler.dart`: `_player.play().timeout(...)` 2с → 1с
- `player_screen.dart`: `_restartStudyIfNeeded` delay 150мс → 50мс
- `pubspec.yaml` и `app_info.dart` — 5.0.9 (versionCode 206)

---

## 🎯 Новое в версии 5.0.8

### 🐛 Фикс: после авто-перехода песни study-режим оставался неактивным, пока не нажмёшь play/pause (КОРНЕВАЯ причина)
- **Симптом (подтверждён диагностической 5.0.7):** после авто-перехода на следующую песню study не активен (`active=false`), новая песня реально играет (`pos` растёт), но `_playSong` «висит» (`load=true`), перевода нет. Нажатие play/pause оживляло всё
- **Корень:** `BackgroundAudioHandler.playSong()` после деактивации Android audio-сессии плитом TTS делал голые `await session.setActive(true)` / `await _player.setFilePath()` / **`await _player.play()`** без таймаутов. На Android `play()` после TTS **запускает аудио, но его Future зависает навсегда** → `await handler.playSong()` в `_playSong` не возвращается → `_playSong` не доходит до `ensurePlaybackAdvancing` и `_restartStudyIfNeeded` → study остаётся выключенным. Нажатие FAB (новый `play()/pause()`) разрешал зависший Future → `_playSong` продолжает → study стартует. Именно поэтому поведение было одинаковым в 5.0.4–5.0.7: фиксы были НИЖЕ по потоку от зависшего await и просто не выполнялись
- **Решение:** все критичные await'ы в `playSong` (и `loadSong`) обёрнуты в `.timeout()`: `setActive` — 2с, `setUrl/setFilePath` — 5с, `play()` — 2с. Future больше не может висеть → метод всегда возвращает управление → `_playSong` доходит до `ensurePlaybackAdvancing` (верифицирует реальное движение) и `_restartStudyIfNeeded` (перезапускает study)
- Диагностика 5.0.7 (оверлей + хлебные крошки) оставлена на этот релиз для подтверждения на устройстве, что `active=true` после переключения; будет почищена в следующем

### 🔧 Технические изменения
- `background_audio_handler.dart`: `loadSong` и `playSong` — `.timeout()` на `setActive`/`setUrl`/`setFilePath`/`play()` (внутри существующего try-catch, таймауты логируются)
- `pubspec.yaml` и `app_info.dart` — 5.0.8 (versionCode 205)

---

## 🎯 Новое в версии 5.0.7

### 🔍 ДИАГНОСТИЧЕСКАЯ сборка (не финальный фикс)
- **Цель:** после фиксов 5.0.5/5.0.6 (версия на устройстве подтверждена 5.0.6) симптом «после авто-перехода study не активен, оживает только кнопкой play/pause» сохраняется. Статически код выглядит корректно, поэтому добавлена инструментация для точного определения разрыва в runtime
- **Что добавлено:**
  - Отладочный оверлей («Служебные данные») теперь показывается **всегда** (не только когда study активен) — чтобы видеть состояние даже в момент сбоя, когда study не активен
  - Новые поля в оверлее: `active` (isActive), `persist` (enabledPersist), `load` (_isSongLoading), и `EVT:` (последнее событие жизненного цикла)
  - Хлебные крошки (`_studyEvt`) в ключевых точках с живым обновлением UI: `_playSong` (enter/post-stop/post-start/post-kick/post-restart/finally/skip), `_restartStudyIfNeeded` (каждая причина early-return + результат `start()`), `_onStudySongCompleted`, `onSongComplete` (guarded?), FAB onPressed
- **Как использовать:** включить «Служебные данные» → воспроизвести сбой (дойти до конца песни с study) → в момент зависания прочитать поле `EVT:` в плашке и прислать разработчику. Последнее событие точно укажет, где оборвалась цепочка перезапуска study
- Это промежуточная сборка: после получения данных будет выпущен целевой фикс

### 🔧 Технические изменения
- `player_screen.dart`: поле `_lastStudyEvent` + хелпер `_studyEvt` (с живым `setState`); оверлей всегда виден и расширен; хлебные крошки в `_playSong`/`_restartStudyIfNeeded`/`_onStudySongCompleted`/`onSongComplete`/FAB
- `pubspec.yaml` и `app_info.dart` — 5.0.7 (versionCode 204)

---

## 🎯 Новое в версии 5.0.6

### 🐛 Фикс: после авто-перехода на следующую песню не двигался текст и не озвучивался перевод
- **Проблема:** в режиме говорения после того, как песня доигрывала до конца (последняя строка озвучивалась после окончания времени песни), переключение на следующую песню «замирало» — текст не двигался, перевод не произносился. Помогало только вручную нажать play/pause (иногда дважды). Проявлялось во всех режимах порядка (перевод/оригинал/поверх)
- **Причина:** на последней строке TTS озвучивает перевод ПОСЛЕ того, как песня дошла до `ProcessingState.completed`. Во время речи Android деактивирует audio session. Переключение песни шло через `BackgroundAudioHandler.playSong()`, который делал только `session.setActive(true)` + `play()` — **без проверки реального движения позиции**. В итоге just_audio уходил в зомби-состояние (`playing == true`, а позиция стоит) → нет подсветки строк, study-раннер не детектит границы сегмента → нет перевода. Ручной play/pause оживлял, потому что второй тап → `resumeSession` → `_kickPlayback()` (с retry и seek-nudge), к которому сессия уже успевала «устаканиться»
- **Решение:** добавлен `AudioService.ensurePlaybackAdvancing()` — верифицированный запуск воспроизведения по образцу `_kickPlaybackAsync`: реактивация сессии → `play()` → проверка реального движения позиции за ~400мс → при отсутствии retry + seek-nudge (заставляет just_audio перебуферизоваться и выйти из зомби). Метод **no-op при здоровом воспроизведении** (выходит на первой проверке)
- В `_playSong` после загрузки/запуска новой песни вызывается `ensurePlaybackAdvancing()` (в зоне `enabledPersist` — единственный путь, где TTS деактивирует сессию), и сокращена задержка restart `_restartStudyIfNeeded` (500мс → 150мс, т.к. кик уже гарантирует движение)
- Теперь после авто-перехода и ручного next **песня реально играет с первой секунды** — текст бежит, перевод озвучивается, без ручных нажатий

### 🔧 Технические изменения
- `audio_service.dart`: импорт `audio_session`; новый метод `ensurePlaybackAdvancing({maxAttempts = 5})` (setActive → play → verify position → retry + seek-nudge, с досрочным выходом по `ProcessingState.completed`)
- `player_screen.dart`: в `_playSong` после `handler.playSong()`/`loadAudio()` — `ensurePlaybackAdvancing()` при `enabledPersist`; `_restartStudyIfNeeded` delay 500мс → 150мс
- `pubspec.yaml` и `app_info.dart` — 5.0.6 (versionCode 203)

---

## 🎯 Новое в версии 5.0.5

### 🐛 Фикс: режим говорения не возобновлялся после переключения песни
- **Проблема:** в режиме говорения (study mode) после переключения песни кнопка «Изучение» не подсвечивалась и перевод не озвучивался:
  - при ручном переходе «следующая песня» — помогало нажать play/pause;
  - при автоматическом переходе (loop/завершение песни) — play/pause не помогал, нужно было перемотать песню, чтобы режим оживал
- **Причина 1 (авто-переход):** в `_onStudySongCompleted()` после `_playNextSong()` проверялось `_studyModeService.isActive` для обнаружения случая «ничего не переключилось». Но к этому моменту `_playSong` уже перезапустил study mode через persist для НОВОЙ песни → `isActive` всегда `true` → `stop()` убивал только что запущенную сессию. Флаг persist оставался включённым, но никто режим больше не поднимал → play/pause (при неактивном study просто крутит аудио) не помогал, а перемотка помогала, т.к. её `onChangeEnd` вызывает `_restartStudyIfNeeded`
- **Причина 2 (ручной переход / UI):** кнопка «Изучение» в AppBar (`_buildStudyModeButton`) не была обёрнута в `AnimatedBuilder` — она обновлялась только через `setState` 50мс-таймера, который гасится на всё время `_playSong`. В окне переключения подсветка могла оставаться устаревшей, пока pause/play не «пнёт» runner
- **Решение:**
  - `_onStudySongCompleted` сравнивает `_currentSong.id` до/после `_playNextSong()` — `stop()` срабатывает только если песня реально не сменилась (LoopMode.off, последняя), а не по `isActive`
  - `_buildStudyModeButton` обёрнут в `AnimatedBuilder(animation: _studyModeService, …)` — подсветка реагирует на `notifyListeners()` напрямую (как FAB), больше не зависит от 50мс-таймера
- Теперь режим говорения **корректно перезапускается и подсвечивает кнопку** после ручного и автоматического переключения песни без необходимости жать play/pause или перематывать

### 🔧 Технические изменения
- `player_screen.dart`: `_onStudySongCompleted()` — сравнение `_currentSong.id` вместо `_studyModeService.isActive`; `_buildStudyModeButton` — обёрнут в `AnimatedBuilder`
- `pubspec.yaml` и `app_info.dart` — 5.0.5 (versionCode 202)

---

## 🎯 Новое в версии 5.0.4

### 🐛 Фикс: текст песни уезжал за зону видимости при смене песни
- **Проблема:** после переключения песни (в т.ч. по loop) текст оказывался за пределами видимой области — скролл-позиция оставалась от предыдущей (длинной) песни
- **Решение:** в `_playSong` добавлен сброс скролла в топ (`_scrollController.jumpTo(0)`) через post-frame callback после загрузки нового текста — новые Lyrics теперь сразу видны с первой строки

### 🔧 Технические изменения
- `player_screen.dart`: `_scrollController.jumpTo(0.0)` на смене песни (post-frame, с guard `hasClients`)
- `pubspec.yaml` и `app_info.dart` — 5.0.4 (versionCode 201)

---

## 🎯 Новое в версии 5.0.3

### 🔄 Фикс: повтор песен (loop) не работал в режиме изучения
- **Проблема:** в режиме изучения при окончании песни последняя фраза озвучивалась в самом конце и воспроизведение останавливалось (пауза) — loop/переход на следующую не срабатывал
- **Причина:** `onSongComplete` заблокирован пока study mode активен, а сам study mode по завершении песни вызывал `stop()` (пауза) вместо того, чтобы запустить loop/переход
- **Решение:** добавлен callback `StudyModeService.onStudyCompleted`. Когда study mode доходит до конца песни естественно — вызывает callback (НЕ паузит), а PlayerScreen в колбэке триггерит нормальный поток завершения: `_playNextSong()` (для LoopMode.all/allPlaylists/shuffle — переход/зацикливание) или `_playSong(currentSong)` (для LoopMode.one — повтор с начала). `_playSong` при этом перезапускает study mode через persist. Если следующей песни нет (LoopMode.off, последняя) — study mode корректно останавливается

### 🔧 Технические изменения
- `study_mode_service.dart`: поле `VoidCallback? onStudyCompleted`; natural completion в `_runLoop` и `_runContinuousOverlay` (poll + playerStateSub) вызывает callback вместо `stop()` (fallback на `stop()` если callback не задан)
- `player_screen.dart`: `_onStudySongCompleted()` (loop-one → `_playSong(current)`, иначе `_playNextSong`, при отсутствии перехода — `stop()`); подключение `_studyModeService.onStudyCompleted`
- `pubspec.yaml` и `app_info.dart` — 5.0.3 (versionCode 200)

---

## 🎯 Новое в версии 5.0.2

### 🎚️ Уточнённые пресеты скорости речи
- Пресеты скорости речи в настройках режима изучения: `0.3 · 0.4 · 0.5 · 0.6 · 0.7 · 0.8 · 0.9 · 1.0 · 1.1` (равномерный шаг 0.1; было `0.3/0.5/0.7/0.85/1.0/1.25`)

### 🔧 Технические изменения
- `player_screen.dart`: `_studySpeechRates` обновлён на 9 значений с шагом 0.1
- `pubspec.yaml` и `app_info.dart` — 5.0.2 (versionCode 199)

---

## 🎯 Новое в версии 5.0.1

### 🔁 Persist режима говорения — авто-возобновление на смене песни и перемотке
- **Проблема:** хотя флаг persist сохранялся, режим не перезапускался автоматически после переключения песни (кнопка не горела) и после перемотки — нужно было нажимать вручную
- **Причина:** restart в `_playSong` вызывался сразу после `handler.playSong()` — события запуска новой песни конфликтовали с seek+pause режима изучения (race), поэтому старт не «приживался». На перемотке режим просто останавливался без перезапуска
- **Решение:**
  - Новый централизованный helper `_restartStudyIfNeeded({delay})` — проверяет `enabledPersist` + наличие текста + `!isActive`, опционально ждёт, затем `start()` + `setState`
  - **Смена песни:** restart с задержкой ~500мс (даёт воспроизведению «устаканиться» — тот же эффект, что при ручном нажатии)
  - **Тап по строке:** restart сразу после seek
  - **Слайдер-перемотка:** stop на `onChanged` (на старте drag), restart на `onChangeEnd` (после отпускания)
- Теперь при включённом persist режим **корректно перезапускается** и подсвечивает кнопку после смены песни и перемотки без ручного нажатия

### 🎉 Переход на мажор 5.x
- Версия поднята до **5.0.1** (с 4.6.x) — отражает завершённость режима изучения (3 режима TTS, persist, диагностика)

### 🔧 Технические изменения
- `player_screen.dart`: `_restartStudyIfNeeded()`; вызов с задержкой в `_playSong`; restart в обработчике тапа по строке; `onChangeEnd` на слайдере
- `pubspec.yaml` и `app_info.dart` — 5.0.1 (versionCode 198)

---

## 🎯 Новое в версии 4.6.29

### 🔁 Persist режима говорения
- **Проблема:** режим говорения слетал на каждой следующей песне (нужно было включать заново)
- **Решение:** добавлен persist-флаг `studyModeEnabled` в SharedPreferences. Один раз включил — режим **держится при смене песен и после перезапуска приложения**:
  - `_playSong` после загрузки новой песни **перезапускает** study mode (`stop` → `start`), если флаг включён. Чистый stop+start сбрасывает `_isSpeaking`/громкость/фазу → нет «наложений» от предыдущей песни в overlay-режиме
  - При инициализации плеера — авто-старт study mode, если флаг включён
  - Флаг сбрасывается только когда пользователь **сам** выключает режим кнопкой (`stop(userRequested: true)`); внутренние стопы (смена песни, окончание, ошибки) флаг сохраняют

### 🐛 Фикс: перевод/подсветка/индикатор языка не появлялись после смены песни
- **Проблема:** после переключения песни нет перевода, не бежит подсветка строки, нет индикатора языка —直到 pause/play или toggle study mode
- **Решение:** в `_playSong` добавлен `setState` сразу после загрузки переводов (индикатор/перевод обновляются немедленно, без ожидания position-timer); в `_startPositionUpdates` `setState` вынесен из-под условия `isInitialized` — UI обновляется всегда

### 🔧 Технические изменения
- `study_mode_service.dart`: поле `_enabledPersist` + load/save (`studyModeEnabled`); `start()` → `_persistEnabled(true)`; `stop({bool userRequested = false})` сбрасывает флаг только при `userRequested`; `toggle()` → `stop(userRequested: true)`; геттер `enabledPersist`
- `player_screen.dart`: `_maybeAutoStartStudy()` (читает флаг из prefs, стартует study mode); вызов в обоих путях `_initSongData`; перезапуск в `_playSong`; `setState` после `_updateAllLyricsWithTranslations`; relax `isInitialized` в position-timer
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.29

---

## 🎯 Новое в версии 4.6.27 + 4.6.28

### 🐛 Фикс: режим изучения зависал после первой фразы (4.6.27)
- **Проблема:** озвучивалась только первая фраза, далее песня играла без перевода; ручной pause/play повторял ту же фразу
- **Корень (подтверждён диагностическим оверлеем):** таймер границы сегмента создавался ПОСЛЕ `await _resumePlayback()`, а тот вис на `play()` в зомби-состоянии just_audio после перехвата аудиосессии TTS (`playing=true, state=ready`, но позиция не двигалась) → граница никогда не детектилась
- **Решение:**
  - В `_playSegmentAndAwait` таймер границы теперь создаётся **первым**, а `_kickPlayback()` запущен **в фоне (non-blocking)** — детект границы больше не зависит от того, быстро ли очнётся плеер
  - `_kickPlayback`: таймауты (по 1с) на все `await` (`AudioSession`, `setActive`, `play`, `seek`) — виснущий `play()` не держит цикл вечно
  - **Seek-удар по зомби:** если после 2 попыток `play()` позиция не двигается — `_audio.seek(текущая позиция)` заставляет just_audio перебуферизоваться и выйти из зомби
  - Применено в режимах 1/2 (`_playSegmentAndAwait`), режиме 3 (`_runContinuousOverlay`) и overlay (`_speakOver`)

### 🎛️ Настройка «Служебные данные» (4.6.28)
- Диагностический оверлей режима изучения (фаза/индекс/позиция/состояние плеера) теперь **скрыт по умолчанию** и показывается только при включении тумблера «Служебные данные» в Настройках (рядом с «Служебные сообщения»)
- Локализация нового ключа (`serviceData`/`serviceDataSubtitle`) на 11 языков

### 🔧 Технические изменения
- `study_mode_service.dart`: `_kickPlayback` (non-blocking, замена `_resumePlayback`), seek-nudge, таймауты; отладочные геттеры оставлены для оверлея
- `settings_provider.dart`: `showServiceData` + `setShowServiceData` + персистентность
- `settings_screen.dart`: новый `SwitchListTile` (иконка `bug_report_outlined`)
- `player_screen.dart`: условие оверлея через `Provider.of<SettingsProvider>(context).showServiceData`
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.28

---

## 🎯 Новое в версии 4.6.24

### 🐛 Фикс: песня не возобновлялась после озвучки перевода
- **Проблема:** после первой фразы песня замолкала, позиция не двигалась; каждый pause/play стартовал с той же точки (режим 1). Режимы «Сначала оригинал» и «Поверх» не работали. Фикс 4.6.23 (опрос позиции вместо `positionStream`) ловил границу корректно, но фундамент оставался: `play()` после TTS не поднимал воспроизведение
- **Причина:** на Android FlutterTts деактивирует аудиосессию во время речи. Вызов `AudioService.play()` сразу после TTS не возобновлял песню, а старый `_ensurePlaybackResumed` проверял флаг `_audio.player.playing` (он `true` даже когда ОС держит паузу фокуса) → ретрай никогда не срабатывал. Песня молчала, `_currentIndex` не двигался
- **Решение:** новый awaited `_resumePlayback()` — реактивирует `AudioSession`, вызывает `play()` и **проверяет реальное движение позиции** (а не флаг), с ретраями до 5 раз. Применён в `_playSegmentAndAwait` (режимы 1 и 2), `_runContinuousOverlay` (режим 3) и `_speakOver` (возобновление песни после TTS в overlay — чинит «не играет поверх»). Заодно убрана гонка pause/seek на границе сегмента (fire-and-forget паузу из таймера убрали — следующая итерация сама делает `await seek + pause`)

### 🔧 Технические изменения
- `study_mode_service.dart`: импорт `audio_session`; `_resumePlayback()` (замена `_ensurePlaybackResumed`); `_playSegmentAndAwait`/`_runContinuousOverlay`/`_speakOver` используют `_resumePlayback`; убран fire-and-forget `_audio.pause()` из таймера границы
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.24

---

## 🎯 Новое в версии 4.6.23

### 🐛 Фикс: режим изучения не двигался дальше первой фразы
- **Проблема:** в режиме «Сначала перевод» озвучивалась только первая фраза, далее песня играла непрерывно (ручной pause/resume давал ещё по одной фразе); режимы «Сначала оригинал» и «Поверх» не работали вообще
- **Причина:** детект границы сегмента/смены строки был построен на динамической подписке `just_audio.positionStream.listen` — после передачи аудиосессии TTS этот колбэк не срабатывал, и цикл зависал в ожидании. Третий режим (непрерывный overlay) это подтверждал независимо — он целиком на этом потоке и не выдавал ни слова
- **Решение:** граница и смена строки теперь детектятся опросом `_audio.position` через `Timer.periodic` (150 мс) — тот же надёжный источник, что уже используется для подсветки текущей строки (`AudioService` держит постоянную подписку). Заменены `_playSegmentAndAwait` (режимы 1 и 2) и `_runContinuousOverlay` (режим 3); добавлен poll-fallback по `processingState.completed`
- Таймеры гасятся в `_cancelSegmentAwait`, `pauseSession`, `stop`, `dispose`

### 🔧 Технические изменения
- `study_mode_service.dart`: поля `_segmentTimer`/`_overlayTimer`; `_playSegmentAndAwait` и `_runContinuousOverlay` переписаны с `positionStream.listen` на `Timer.periodic` + `_audio.position`; `_cancelSegmentAwait`/`dispose` отменяют новые таймеры
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.23

---

## 🎯 Новое в версии 4.6.22

### 🎧 Режим изучения v3: три режима, исправления, новые настройки
- **3 режима порядка** (в диалоге настроек):
  1. **Сначала перевод** — TTS → фрагмент (пауза во время речи)
  2. **Сначала оригинал** — фрагмент → TTS (пауза во время речи)
  3. **Поверх** — песня играет **непрерывно без пауз**, перевод говорит поверх (ducking); sub-опция «когда говорить»: в начале строки / в конце / в начале и в конце (дефолт — в начале)
- **🐛 Фикс:** после первой фразы режим зависал (аудиосессия деактивировалась во время TTS → `play()` не возобновлялся). Добавлены: watchdog-таймаут TTS, ретрай `play()` до 3 раз, fallback по завершению песни, детальные логи фаз
- **Скорость речи:** дефолт снижен до **0.5** (раньше 1.0 было слишком быстро), пресеты `[0.3, 0.5, 0.7, 0.85, 1.0, 1.25]`
- **Громкость оригинала** в режиме «Поверх» — слайдер 0–100% (дефолт 30%)
- **Регулировка скорости песни** осталась доступной (теперь в меню «...»)

### 🎛️ Перегруппировка AppBar (больше места)
- Из AppBar убраны: autoScroll-toggle и songSpeed
- Добавлена **кнопка-шестерёнка** (`Icons.tune`) рядом с «Изучение» — открывает диалог настроек режима (видимо, не на long-press)
- В меню «...» добавлены: «Автопрокрутка» (чекбокс) + «Скорость песни» (→ диалог speed)

### 🔧 Технические изменения
- `study_mode_service.dart`: enum `OverlayTiming`, поля `_overlayTiming`/`_duckVolume` + персистентность; `_speak` watchdog; `_playSegmentAndAwait` ретрай + fallback; новый `_runContinuousOverlay()` + `_speakOver()`; `start()`/`resumeSession()` ветвятся по режиму через `_startRunner()`
- `player_screen.dart`: AppBar перегруппирован (шестерёнка, убраны autoScroll/songSpeed); popup расширен (autoScroll/songSpeed/share/editMode/...); диалог настроек с timing + слайдер громкости + новые пресеты скорости речи
- Локализация: 6 новых ключей (`studyModeOverlayTiming/AtStart/AtEnd/AtBoth`, `studyModeDuckVolume`, `studyModeOpenSettings`) на 11 языков
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.22

---

## 🎯 Новое в версии 4.6.21

### 🎛️ Перегруппировка кнопок плеера
- **Проблема:** после добавления режима изучения в нижнем ряду стало 9 кнопок — на узких экранах правая («Изучение») уходила за видимую область
- **Решение:** перенесли **«Скорость»** и **«Изучение»** из нижнего ряда в **верхний AppBar** (рядом с autoScroll, с фиксированным размером ≥20px для читаемости «1x»)
- **«Поделиться»** и **«Правка меток»** (toggle режима правки таймингов) переехали в меню **«...»** (плюс разделитель)
- Нижний ряд снова **7 кнопок**: shuffle · prev · replay10 · FAB · forward10 · next · loop — помещается на любых экранах
- Меню «...» теперь: Экспорт песни · Правка меток / Выйти из правки · — · Правка переводов · Импорт ZIP · Загрузить текст · Удалить перевод

### 🔧 Технические изменения
- `player_screen.dart`: из Row нижней панели убраны `_buildSpeedButton`/`_buildStudyModeButton`, `buttonCount` 8 → 7; `AnimatedBuilder(_studyModeService)` сохранён (FAB реагирует на study-состояние)
- `_buildAppBarContent`: убраны `btn(share)` и `btn(edit-toggle)`, добавлены `_buildStudyModeButton(hdrBtnSize)` + `_buildSpeedButton(hdrBtnSize)` после autoScroll
- `PopupMenuButton`: новые ветки `share` → `_exportCurrentSong()`, `editMode` → toggle `_isEditMode`; `PopupMenuDivider` между группами
- Локализация: новый ключ `exportCurrentSong` на 11 языков (`editTimestamps`/`exitEditMode` уже были)
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.21

---

## 🎯 Новое в версии 4.6.20

### 🎧 Настройки режима изучения: порядок и скорость речи
- **Порядок «перевод ↔ оригинал»** — долгое нажатие на кнопке «Изучение» открывает диалог с тремя режимами:
  - **Сначала перевод** (по умолчанию) — TTS озвучивает перевод → играет фрагмент оригинала
  - **Сначала оригинал** — играет фрагмент оригинала → TTS озвучивает перевод
  - **Поверх (ducking)** — перевод звучит одновременно с приглушённым оригиналом (громкость оригинала ~30%), режим ждёт окончания и TTS, и фрагмента без обрезки слов
- **Скорость речи перевода** — ChoiceChip-пресеты: `0.75x · 1.0x (дефолт) · 1.15x · 1.25x · 1.5x · 1.75x`. Применяется мгновенно (`flutter_tts.setSpeechRate`)
- Настройки сохраняются в `SharedPreferences` (`studyModeOrder`, `studyModeSpeechRate`) и применяются к новой сессии

### 🔧 Технические изменения
- `study_mode_service.dart`: enum `StudyModeOrder { translationFirst, originalFirst, overlay }`, свойства `order`/`speechRate`, `_loadSettings()`, `setOrder()`/`setSpeechRate()` с персистентностью; `_runLoop` ветвится по `order` на три обработчика (`_handleTranslationFirst`/`_handleOriginalFirst`/`_handleOverlay`); ducking через `_audio.player.setVolume()` с восстановлением в `pauseSession`/`stop`
- `player_screen.dart`: `_openStudyModeSettings()` (паузит сессию при открытии), `_showStudyModeSettingsDialog()` (StatefulBuilder с RadioListTile + ChoiceChip'ами), `onLongPress` на кнопке study, tooltip с подсказкой о долгом нажатии
- Локализация на 11 языков: ключи `studyModeSettings`, `studyModeOrder`, `studyModeOrderTranslationFirst`, `studyModeOrderOriginalFirst`, `studyModeOrderOverlay`, `studyModeSpeechRate`, `studyModeLongPressHint`
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.20

---

## 🎯 Новое в версии 4.6.19

### 🎧 Режим изучения (Study Mode) — песня с озвучкой перевода
- **Возможность:** кнопка «Изучение» в панели плеера включает режим, в котором для каждой строки песни сначала **озвучивается перевод** (TTS), а затем **проигрывается соответствующий фрагмент песни** — и так до конца трека
- **Сценарий:** русская фраза → кусочек песни с этой фразой → следующий перевод → следующий фрагмент … всю песню
- **Особенности:**
  - Язык озвучки определяется по выбранному переводу (русский → `ru-RU`, английский → `en-US` и т.д.)
  - Строки без перевода просто проигрываются (TTS пропускается)
  - Старт с текущей позиции (ближайшая строка к курсу воспроизведения)
  - Подсветка текущей строки синхронизирована и во время озвучки, и во время фрагмента
  - Главная кнопка Play/Pause в режиме изучения ставит сессию на паузу и возобновляет (FAB: 🎤 при озвучке, ⏸ при фрагменте, ▶ при паузе)
  - Ручной seek (слайдер или тап по строке), смена песни завершают режим изучения
  - Авто-переход к следующей песне при окончании suppressed, пока активен режим изучения

### 🔧 Технические изменения
- Новая зависимость `flutter_tts: ^4.2.0`
- Новый сервис `services/study_mode_service.dart` (`StudyModeService`): координатор TTS + сегментное воспроизведение, состояние `StudyPhase { idle, speaking, playingSegment }`, корректная отмена ожиданий через `Completer` (надёжно на Android, где `stop()` может не резолвить Future от `speak()`)
- `player_screen.dart`: инстанцирование `StudyModeService`, кнопка `_buildStudyModeButton`, обновлённый FAB с учётом study-состояния, остановка режима при смене песни/seek, guard в `onSongComplete`
- Локализация на 11 языков: ключи `studyMode`, `studyModeTooltip`, `studyModeStarted`, `studyModeStopped`, `studyModeNoLyrics`
- Версии синхронизированы: `pubspec.yaml` и `app_info.dart` — 4.6.19

---

## 🎯 Новое в версии 4.6.18

### 🎚️ Настройка задержки синхронизации текста (Position Offset)
- **Проблема:** при воспроизведении подсветка строки переходила раньше, чем реально звучал фрагмент (отчасти лечилось фиксом в 4.6.17 с offset 150мс, но фиксированного значения хватало не всем)
- **Решение:** добавлена **ручная настройка** «Задержка синхронизации текста» в Settings → Display (рядом со Scroll Offset)
  - Диапазон: 0.00–1.00с, шаг 0.05с, дефолт 0.15с
  - Значение применяется мгновенно через подписку `PlayerScreen` на `SettingsProvider` — можно прямо во время прослушивания подбирать под песню
- Локализация на 11 языков: ключи `lyricsPositionOffset`, `lyricsPositionOffsetSubtitle`

### 🎯 Автопрокрутка списка к играющей песне
- **Проблема:** при возврате из плеера в список песен (библиотека/плейлист) активная (играющая) песня оказывалась за пределами видимой зоны — приходилось искать её вручную
- **Решение:** при открытии/возврате в `SongLibraryScreen` и `PlaylistSongsScreen` список автоматически прокручивается к текущей песне
  - Песня позиционируется в верхней трети экрана (над ней остаются ~1–2 песни для контекста)
  - Прокрутка мгновенная (`jumpTo`), срабатывает один раз за открытие экрана (флаг `_didInitialScroll`), не мешает ручному скроллу
  - Источник правды — `AudioService.currentSongIdNotifier`

### 🔧 Технические изменения
- `SettingsProvider`: добавлены `_lyricsPositionOffset`, getter, `setLyricsPositionOffset()`, загрузка/сохранение в prefs
- Новый виджет `widgets/settings/lyrics_position_offset_control.dart` (+/- контрол с шагом 0.05с)
- `settings_screen.dart`: новый ListTile в Display-секции
- `player_screen.dart`: в `_loadSettings()` и через `addListener` на `SettingsProvider` вызывается `LyricsService.setPositionOffset()`
- `playlist_songs_screen.dart` / `song_library_screen.dart`: добавлены `ScrollController`, метод `_scrollToCurrentSong()`, `dispose()`
- Синхронизированы версии: `pubspec.yaml` и `app_info.dart` — обе 4.6.18

---

## 🎯 Новое в версии 4.6.17

### 🐛 Фикс: преждевременный переход на следующую строку текста
- **Проблема:** при воспроизведении подсветка текста переходила на следующую строку раньше, чем реально звучал соответствующий фрагмент
- **Причина:** `just_audio` может сообщать позицию с небольшим опережением из-за буферизации и интерполяции позиции, особенно при скорости >1x
- **Решение:** в `LyricsService.updatePosition()` добавлен offset 150мс — поиск строки теперь по `position - offset`, что гарантирует переключение подсветки только когда аудио действительно дошло до метки
- Настройка: `setPositionOffset(double)` в `LyricsService`, дефолт 0.15с, clamp 0-1с

### 🐛 Фикс: рассинхрон песни — текст одной, играет другая
- **Проблема:** текст показывал одну песню, а реально воспроизводилась другая; при переключении кнопкой "следующая песня" мог играть неправильный трек
- **Причины и решения:**
  - **Race condition при быстром переключении:** добавлен мьютекс `_isSongLoading` — если `_playSong()` уже выполняется, новый вызов игнорируется
  - **Двойная загрузка аудио:** убрана повторная загрузка через `handler.playSong()` — теперь аудио загружается ровно один раз
  - **Уведомление прерывало воспроизведение:** `handler.setPlaylist()` + `updateNotification()` вызывались после `play()` и через `mediaItem.add()` могли сбивать воспроизведение — переписано: сначала грузим тексты/переводы, затем **атомарно** `handler.playSong()` (setFilePath + mediaItem + play без async-разрыва)
  - **Skip из уведомления менял песню без ведома PlayerScreen:** добавлены коллбэки `onSkipToNextRequested`/`onSkipToPreviousRequested` в `BackgroundAudioHandler` — нажатие next/prev в уведомлении системы делегируется в `PlayerScreen._playNextSong()`/`_playPreviousSong()`

### 🐛 Фикс: не работало автовключение следующей песни (loop/shuffle)
- **Проблема:** после завершения песни следующая не начинала играть, loop и shuffle не работали
- **Причина:** между `_player.setFilePath()` (loadAudio) и `_player.play()` проходила секунда+ из-за async загрузки переводов — за это время audio session могла деактивироваться, и `play()` не срабатывал
- **Решение:** `_playSong()` переписан — тексты и переводы загружаются **до** загрузки аудио; `handler.playSong()` вызывается **последним** как атомарная операция (load + metadata + play подряд, без async-разрыва)

### 🔧 Технические изменения
- `LyricsService`: добавлен `_positionOffset`, `setPositionOffset()`, `positionOffset` getter
- `BackgroundAudioHandler`: добавлен `updateNotification()` (metadata без reload), `onSkipToNextRequested`/`onSkipToPreviousRequested` коллбэки, `skipToNext()`/`skipToPrevious()` делегируют через коллбэки
- `PlayerScreen._playSong()`: мьютекс `_isSongLoading`, остановка/перезапуск таймера позиций, сброс `_lastScrolledIndex`/`_lastProcessedIndex`/`_lastProcessedLanguageIndex` при переключении песни
- `PlayerScreen._initBackgroundAudio()`: подписка на skip-коллбэки handler'а
- `PlayerScreen.dispose()`: очистка skip-коллбэков

---

## 🎯 Новое в версии 4.6.16

### 🐛 Фикс: перевод виден только на первых строках при переключении песни
- **Проблема:** при переключении на следующую/предыдущую песню перевод отображался только на 3 первых строках, остальные подтягивались по мере воспроизведения
- **Причина:** метод обновления переводов передавал `focusIndex` (текущая строка), из-за чего обновлялись только соседние строки
- **Решение:** разделение на `_updateAllLyricsWithTranslations()` (полная загрузка всех строк) и `_updateLyricsWithTranslations()` (оптимизированное обновление в таймере)
- Полная загрузка применяется при: загрузке песни, смене языка, импорте переводов, возврате из фона

### ⏩ Управление скоростью воспроизведения
- Кнопка скорости "1x" в панели управления плеера (между Forward 10 и Skip Next)
- Диалог выбора из 9 пресетов: 0.5x, 0.75x, 0.8x, 0.9x, **1.0x** (по умолчанию), 1.1x, 1.25x, 1.5x, 2.0x
- Скорость сохраняется между сессиями (SharedPreferences)
- Поддержка фонового воспроизведения — скорость синхронизируется с BackgroundAudioHandler
- Подсветка кнопки при нестандартной скорости (как Shuffle/Loop)
- Локализация на 11 языков: ключи `playbackSpeed`, `speedNormal`

---

## 🎯 Новое в версии 4.6.15

### 🔄 Режим повтора всех плейлистов
- Новый режим `LoopMode.allPlaylists` — после последней песни плейлиста переходит к следующему
- Цикл переключения: off → all → one → allPlaylists → off
- Иконка списка в углу кнопки повтора при активном режиме

### 🎵 Подсветка текущей песни в плейлисте
- Играющая песня подсвечивается цветом `primaryContainer`
- Рамка вокруг карточки цветом `primary`
- Иконка эквалайзера на обложке
- Оптимизировано через `ValueNotifier<String?>` — rebuild только при смене песни

### 🎚️ Настройка смещения временных меток
- Settings → Display → Timestamp Offset (0-180 минут, дефолт 30)
- Сброс временных меток в Translation Editor

### 🐛 Исправления
- **Критический фикс:** серый экран в плейлистах из-за `AnimatedBuilder` внутри `itemBuilder`
- **Фикс:** Slider краш в PlayerScreen при `duration = 0`
- **Фикс:** отсутствующие ключи локализации (11 языков)
- **Фикс:** несуществующая иконка `Icons.timer_reset` → `Icons.restore`

---

## 🎯 Поддерживаемые языки

### Языки интерфейса
- 🇬🇧 English
- 🇷🇺 Русский
- 🇷🇴 Română
- 🇫🇷 Français
- 🇩🇪 Deutsch
- 🇪🇸 Español
- 🇮🇹 Italiano
- 🇵🇹 Português
- 🇨🇳 中文
- 🇸🇦 العربية
- 🇺🇦 Українська

### Языки для переводов
Все языки интерфейса плюс:
- Японский
- Корейский
- Дословный перевод на русский
- Транскрипция (фонетическая)

## 🎼 Форматы файлов

- **LRC** - текст песни с временными метками
- **JSON** - переводы и транскрипция
- **ZIP** - архив с текстом, переводами и транскрипцией
- **MP3/WAV/M4A/OGG** - аудиофайлы

## 🔧 Команды Flutter

```bash
# Запуск приложения
flutter run

# Запуск тестов
flutter test

# Анализ кода
flutter analyze

# Форматирование кода
dart format .

# Сборка APK
flutter build apk --release

# Сборка App Bundle
flutter build appbundle --release
```

## 🔧 Команды Python

```bash
# Генерация текста песен с переводами
python scripts/deepseek_generator_v3.py --text "текст песни" --languages de,en,ru,trans

# Создание LRC и JSON файлов
python scripts/generate_lrc_json.py --input input/song.txt

# Обработка Excel файла с песнями
python scripts/process_excel_songs.py --excel input/songs.xlsx
```

## 🤝 Вклад в проект

Вклад в проект приветствуется! Пожалуйста, следуйте инструкциям в [DEVELOPMENT.md](DEVELOPMENT.md).

## 📄 Лицензия

Этот проект является частным и предназначен для личного использования.

## 📞 Поддержка

**Email:** support@lingotune.com  
**Веб-сайт:** https://lingotune.app

## 🎓 Для кого это приложение?

- Учащиеся иностранным языкам
- Любители музыки
- Преподаватели языков
- Все, кто хочет учить языки через любимые песни

## 🌟 Особенности обучения

- **Естественное запоминание** - через музыку слова запоминаются легче
- **Визуальная привязка** - текст синхронизирован с аудио
- **Множественные переводы** - понимание нюансов перевода
- **Транскрипция** - помощь в произношении
- **Контекстное обучение** - слова и фразы в естественном контексте

---

**LingoTune** - учите языки через музыку! 🎵🌍
