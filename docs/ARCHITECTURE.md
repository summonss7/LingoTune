# Архитектура LingoTune

> Актуально для версии **5.8.2**. Авторитетный источник по конвенциям и
> поведению сервисов — [`AGENTS.md`](../AGENTS.md) (обновляется каждым релизом);
> этот документ даёт структурный обзор. История изменений —
> [`CHANGELOG.md`](CHANGELOG.md).

## Общая архитектура

LingoTune - это гибридный проект, состоящий из двух основных частей:

1. **Flutter приложение** - мобильное приложение для Android
2. **Python скрипты** - утилиты для генерации и обработки текстов песен

```
┌─────────────────────────────────────────────────────────────┐
│                         LingoTune                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐         ┌─────────────────┐           │
│  │  Flutter App    │         │  Python Scripts │           │
│  │  (Android)      │         │  (Utilities)    │           │
│  │                 │         │                 │           │
│  │  - UI Screens   │         │  - Lyrics Gen   │           │
│  │  - Audio Player │         │  - Translation   │           │
│  │  - Database     │         │  - LRC Format   │           │
│  │  - API Service  │         │  - JSON Format  │           │
│  └────────┬────────┘         └─────────────────┘           │
│           │                                                │
│           │                                                │
│  ┌────────▼──────────────────────────────────────┐        │
│  │           Shared Data                          │        │
│  │  - SQLite Database (lingotune.db)             │        │
│  │  - LRC Files (lyrics with timing)             │        │
│  │  - JSON Files (translations)                  │        │
│  │  - ZIP Archives (song packages)                │        │
│  │  - Audio Files (MP3, WAV, M4A, OGG)           │        │
│  └───────────────────────────────────────────────┘        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Архитектура Flutter приложения

### Структура директорий

```
app/lib/
├── main.dart                    # Точка входа приложения
├── app_info.dart                # Информация о приложении
│
├── models/                      # Модели данных
│   ├── song.dart               # Модель песни
│   ├── translation.dart        # Модель перевода
│   ├── lyric_line.dart         # Модель строки текста
│   ├── playlist.dart           # Модель плейлиста
│   └── generation_result.dart  # Результат генерации
│
├── services/                    # Сервисы (бизнес-логика)
│   ├── audio_service.dart      # Аудио плеер
│   ├── background_audio_handler.dart  # Фоновое воспроизведение
│   ├── audio_position_corrector.dart  # Коррекция дрейфа позиции (VBR MP3)
│   ├── phone_call_service.dart # Нативный детектор звонка (TelephonyManager → EventChannel)
│   ├── becoming_noisy_service.dart # Нативный детектор отключения наушников
│   ├── study_mode_service.dart  # Режим изучения (TTS + воспроизведение)
│   ├── tts_coordinator.dart    # Очередь TTS с приоритетами (study > alert)
│   ├── tts/                    # Полиморфные TTS-движки
│   │   ├── tts_engine.dart     #   интерфейс TtsEngine
│   │   ├── system_tts_engine.dart    #   flutter_tts (системный)
│   │   ├── offline_tts_engine.dart   #   sherpa_onnx VITS (офлайн, ~63 МБ)
│   │   ├── offline_tts_isolate.dart  #   синтез в отдельном изоляте
│   │   ├── tts_model_manager.dart    #   загрузка голосовых моделей
│   │   └── tts_catalog.dart    #   каталог доступных голосов
│   ├── car_detection_service.dart # Детекция машин (FFT по микрофону)
│   ├── car_alert_service.dart  # Предупреждение о транспорте (звук/TTS)
│   ├── database_service.dart    # База данных SQLite
│   ├── lyrics_service.dart     # Работа с LRC файлами
│   ├── translation_service.dart # Управление переводами
│   ├── deepseek_api_service.dart # API для AI переводов
│   ├── lyrics_api_service.dart  # Поиск текстов песен онлайн
│   ├── lyrics_generator_service.dart # Генератор текстов
│   ├── theme_provider.dart      # Темы приложения
│   ├── settings_provider.dart   # Настройки пользователя
│   ├── song_import_service.dart # Импорт песен
│   ├── folder_import_service.dart # Импорт папки
│   ├── export_import_service.dart # Экспорт/импорт
│   ├── playlist_service.dart   # Управление плейлистами
│   ├── cover_art_service.dart   # Обложки альбомов
│   ├── folder_config_service.dart # Конфигурация папок
│   └── settings_export_service.dart # Экспорт настроек
│
├── screens/                     # Экраны приложения
│   ├── main.dart               # Главный экран
│   ├── song_library_screen.dart # Библиотека песен
│   ├── player_screen.dart      # Плеер с текстом
│   ├── playlist_screen.dart    # Экран плейлистов
│   ├── playlist_songs_screen.dart # Песни плейлиста
│   ├── settings_screen.dart    # Настройки
│   ├── translation_editor_screen.dart # Редактор переводов
│   ├── lyric_generator_dialog.dart # Диалог генерации текстов
│   ├── text_loader_dialog.dart  # Загрузка текста
│   └── about_app.dart           # О приложении
│
├── widgets/                     # Переиспользуемые компоненты
│   ├── song_list_tile.dart      # Карточка песни
│   ├── lyric_line_widget.dart   # Строка текста
│   ├── empty_library_widget.dart # Пустая библиотека
│   ├── loading_widget.dart      # Индикатор загрузки
│   ├── generation_progress_widget.dart # Прогресс генерации
│   ├── generation_options_widget.dart # Опции генерации
│   ├── batch_selection_widget.dart # Пакетный выбор
│   ├── song_sort_widget.dart    # Сортировка песен
│   ├── selection_mode_actions.dart # Действия выбора
│   ├── lyrics_search_dialog.dart # Поиск текстов
│   ├── library_manager_widget.dart # Управление библиотекой
│   ├── mini_player_widget.dart  # Мини-плеер
│   └── settings/                # Виджеты настроек
│       ├── settings_section.dart
│       ├── api_key_tile.dart
│       ├── api_settings_tile.dart
│       ├── language_settings_tile.dart
│       ├── theme_settings_tile.dart
│       ├── folder_settings_tile.dart
│       ├── font_size_control.dart
│       ├── vertical_focus_offset_slider.dart
│       └── timestamp_offset_control.dart
│
├── utils/                       # Утилиты и хелперы
│   ├── snackbar_helper.dart     # Уведомления
│   ├── lrc_formatter.dart      # Форматирование LRC
│   └── language_helpers.dart    # Хелперы языка
│
├── constants/                   # Константы и конфигурация
│   ├── deepseek_prompts.dart    # Промты для DeepSeek
│   └── generation_constants.dart # Константы генерации
│
├── l10n/                        # Локализация
│   ├── app_localizations.dart
│   ├── app_localizations_en.dart
│   ├── app_localizations_ru.dart
│   ├── app_localizations_ro.dart
│   └── ... (другие языки)
│
└── screens/helpers/              # Хелперы экранов
    ├── song_import_helper.dart
    ├── song_translation_loader.dart
    ├── song_cover_helper.dart
    ├── player_import_helper.dart
    ├── player_export_helper.dart
    ├── player_playlist_helper.dart
    ├── player_translation_helper.dart
    └── playlist_import_helper.dart
```

### Модели данных

#### Song (Песня)
```dart
class Song {
  final String id;                   // Уникальный ID
  final String title;                // Название
  final String artist;               // Исполнитель
  final String audioPath;            // Путь к аудиофайлу
  final String? lrcPath;             // Путь к LRC файлу
  final String? translationsPath;     // Путь к JSON переводам
  final List<Translation> translations; // Список переводов
  final String originalLanguage;     // Оригинальный язык
  final String? language;             // Язык песни
  final String? selectedLanguage;    // Выбранный язык перевода
  final String? coverArtPath;        // Путь к обложке
  final int coverArtVersion;         // Версия обложки
  final bool hasLyrics;              // Есть ли текст
  final bool isInLibrary;            // В библиотеке
  final DateTime createdAt;          // Дата создания
}
```

#### Translation (Перевод)
```dart
class Translation {
  final String language;              // Код языка (ru, en, de)
  final String languageName;          // Название языка
  final List<LyricLine> lines;        // Строки перевода
  final String? type;                 // Тип (translation/transcript)
  final String? filePath;             // Путь к файлу
}
```

#### LyricLine (Строка текста)
```dart
class LyricLine {
  final double startTime;             // Время начала (секунды)
  final String text;                  // Текст строки
  final String? translatedText;       // Переведенный текст
  final String? transcript;           // Транскрипция
  final double? originalStartTime;    // Оригинальное время
}
```

#### Playlist (Плейлист)
```dart
class Playlist {
  final String id;                    // Уникальный ID
  final String name;                  // Название плейлиста
  final List<String> songIds;         // ID песен
  final String? coverArtPath;         // Обложка
  final int coverArtVersion;          // Версия обложки
  final DateTime createdAt;           // Дата создания
}
```

### Сервисы приложения

#### AudioService
**Ответственность:** Управление аудио воспроизведением

- Воспроизведение/пауза/стоп
- Перемотка
- Переключение песен
- Режимы повтора (off, all, one, allPlaylists; `favorites` — только для
  обратной совместимости настроек, в цикле кнопки его нет — избранное
  слушается открытием плейлиста favorites)
- Перемешивание (shuffle)
- Управление скоростью
- Фоновое воспроизведение с уведомлением
- `currentSongIdNotifier` — ValueNotifier для отслеживания текущей песни
- **Zombie-recovery:** `ensurePlaybackAdvancing` — после TTS-хендоффа аудиосессии
  или звонка just_audio может «думать», что играет, при стоящей позиции;
  корректор реактивирует сессию, ретраит `play()` и проверяет реальный ход позиции

**Зависимости:** just_audio, audio_service, audio_session

#### BackgroundAudioHandler
**Ответственность:** Фоновое воспроизведение (notification-контролы), интеграция с `audio_service`

- `play()`/`pause()`/`seek()`/`skipToNext()`/`skipToPrevious()` через `BaseAudioHandler`
- Цикл loop-режимов (`off → all → one → allPlaylists → off`; `favorites` из цикла
  убран в v5.8.0 — избранное слушается через одноимённый плейлист)
- Колбэки для делегирования next/prev на `PlayerScreen` (`onSkipToNextRequested`/`onSkipToPreviousRequested`)
- **Пауза при прерывании (звонок/будильник/другой плеер):**
  - `interruptionEventStream` (audio_session, флаг `androidWillPauseWhenDucked: true`) — базовый путь.
  - Прямой детектор звонка через `PhoneCallService` (см. ниже) — надёжный путь на ROM с агрессивным системным дакингом (ColorOS/Realme UI, MIUI/HyperOS).
  - Единый путь паузы/resume через `_handleCallPause()`/`_handleCallResume()` с **дедупликацией** по флагу `_pausedForCall`: двойное срабатывание (phone-state + audio-focus) безопасно.
  - Study-handoff: `onPlaybackInterrupted` (возвращает `bool` — взял ли study паузу на себя) / `onPlaybackResumed` — корректно стопают TTS + дренируют kick-цикл study mode.
- **Пауза при отключении наушников (v5.8.1):** нативный `BecomingNoisyService`
  (EventChannel `lingotune/becoming_noisy`) держит receiver независимо от
  audio focus, который приложение регулярно теряет (TTS-хендофф, zombie-recovery);
  подписка audio_session остаётся дублирующим fallback. `becomingNoisy`
  игнорируется при активной паузе на звонок (ROM-ы шлют ложные события при
  смене аудио-маршрута в звонке).

**Зависимости:** just_audio, audio_service, audio_session

#### PhoneCallService
**Ответственность:** Нативный детектор состояния телефонного звонка для надёжной паузы при входящем звонке

- Dart-обёртка над нативным EventChannel `lingotune/phone_state` (плагин `PhoneCallPlugin.kt`).
- `enum CallState { idle, ringing, offhook }` + broadcast-стрим `callStates`.
- Синглтон `PhoneCallService.instance` с `start()`/`stop()`.
- **Зачем нужен:** на ряде ROM (ColorOS/Realme UI, MIUI/HyperOS, EMUI) системный дакинг медиапотока при звонке выполняется на уровне `AudioPolicyManager` и игнорирует флаг `willPauseWhenDucked` плагина `audio_session`. В результате `interruptionEventStream` либо опаздывает, либо не приходит → песня «тихо играет» весь разговор. Прямой слушатель `TelephonyManager` срабатывает на `RINGING` гарантированно раньше системного дакинга.
- **Фолбэк:** при отказе в `READ_PHONE_STATE` / недоступности платформы `start()` возвращает `false` → `PlayerScreen` грациозно остаётся на audio-focus схеме.
- Требует `READ_PHONE_STATE` permission (запрос в рантайме через `permission_handler`, `Permission.phone`).

**Зависимости:** нативный Kotlin `PhoneCallPlugin.kt` (TelephonyManager), permission_handler

#### StudyModeService
**Ответственность:** Режим изучения — озвучивание перевода (TTS) и воспроизведение песни по строкам

- Три режима порядка (`StudyModeOrder`):
  - `translationFirst` — сначала TTS перевода, затем фрагмент оригинала (песня на паузе во время речи)
  - `originalFirst` — сначала фрагмент оригинала, затем TTS перевода (песня на паузе во время речи)
  - `overlay` — песня играет **непрерывно без пауз**, перевод говорит поверх (ducking); триггер речи — опрос позиции плеера каждые 150 мс и сравнение с метками строк
- В режиме `overlay`: выбор момента речи (`OverlayTiming`: start / end / both) и регулируемая громкость оригинала (`duckVolume`, 0–100%)
- Скорость (`speechRate`) и громкость (`speechVolume`) речи TTS
- **Настройки на уровне песни:** order / rate / volume / overlay timing / duck
  можно переопределить для каждой песни (`song_{id}_*` в SharedPreferences,
  при включении переопределения наследуют глобальные значения)
- Надёжность: watchdog-таймаут TTS (отключает речь только после 2 зависаний
  подряд — `_ttsFailStreak`), session/speak-токены против гонок при смене
  песни, zombie-kick реактивация плеера, completion-детектор самой песни
  (продвижение в study блокирует `onSongComplete` плеера)
- `resumeSession()` (после звонка) сбрасывает флаг запрета речи — единичный
  сбой больше не глушит перевод до конца песни
- Старт с текущей позиции; пауза/возобновление сессии через FAB
- Настройки сохраняются в `SharedPreferences`: `studyModeOrder`, `studyModeOverlayTiming`, `studyModeSpeechRate`, `studyModeSpeechVolume`, `studyModeDuckVolume` + пер-песенные `song_{id}_*`

**Зависимости:** TtsCoordinator (речь), just_audio (через AudioService)

#### TtsCoordinator + services/tts/
**Ответственность:** Единая точка озвучки с очередью приоритетов и полиморфным движком

- Синглтон `TtsCoordinator.instance`; движок выбирается настройкой `ttsSource`:
  - `SystemTtsEngine` — системный TTS (flutter_tts), виден в системном пикере движков
  - `OfflineTtsEngine` — офлайн-нейронный VITS через **sherpa_onnx** (модель ~63 МБ,
    скачивается по требованию `TtsModelManager`, синтез — в отдельном изоляте
    `OfflineTtsIsolate`, UI не фризится)
- **Приоритетная очередь:** перевод режима изучения (`TtsPriority.study`) всегда
  доминирует над голосовым предупреждением о транспорте (`TtsPriority.alert`);
  alert, выпавший во время перевода, подавляется
- `_sourceLock` сериализует смену движка/языка — защита от гонки холодного
  старта (два движка = две модели по 63 МБ)
- `dispose()` освобождает нативные ресурсы движка (вызывается в `MainScreen.dispose`,
  иначе ~63 МБ утечки на hot-restart в разработке)

**Зависимости:** flutter_tts, sherpa_onnx, audio_session

#### CarDetectionService + CarAlertService
**Ответственность:** Безопасность бегуна — детекция приближающегося транспорта по звуку

- `CarDetectionService` — on-device FFT-анализ микрофона (`utils/fft.dart`, plugin
  `record`, PCM 16 кГц), детекция приближающегося автомобиля
- `CarCalibrationScreen` — запись собственных образцов шума для
  `CalibrationProfile` (улучшает точность на конкретном устройстве/среде)
- `CarAlertService` — предупреждение звуком (`assets/sounds/car_alert.wav`)
  и/или голосом через `TtsCoordinator` с `TtsPriority.alert` (не перебивает перевод)
- Микрофон опционален (`<uses-feature android:required="false"/>`) — без него
  фича просто недоступна

**Зависимости:** record, permission_handler (микрофон)

#### DatabaseService
**Ответственность:** Управление базой данных SQLite

- CRUD операции для песен
- CRUD операции для плейлистов
- Управление переводами
- Поиск и фильтрация
- Транзакции
- `isSongInPlaylist(playlistId, songId)` — быстрая проверка вхождения (для избранного)

**Таблицы базы данных:**
- `songs` - песни
- `playlists` - плейлисты (включая системные `all_songs` и `favorites`)
- `song_translations` - переводы песен
- `playlist_songs` - песни в плейлистах (junction table, в т.ч. для избранного)

> **Системный плейлист `favorites`** создаётся автоматически при первом запуске (`isSystem=1`). Используется как единая глобальная корзина избранного. Добавление/удаление песни = строка в `playlist_songs` с `playlistId='favorites'`. Слушается открытием плейлиста favorites (ведёт себя как `LoopMode.all`); кнопка-сердечко только добавляет/убирает песню из корзины и не меняет режим воспроизведения (см. [archive/PLAN_v5.7.0_favorites.md](archive/PLAN_v5.7.0_favorites.md)).

#### LyricsService
**Ответственность:** Работа с LRC файлами

- Парсинг LRC файлов
- Отображение строк с таймингом
- Синхронизация с аудио
- Поиск текста песен онлайн

#### TranslationService
**Ответственность:** Управление переводами

- Загрузка переводов из JSON
- Сохранение переводов
- Переключение между языками
- Редактирование переводов

#### DeepSeekApiService
**Ответственность:** AI генерация переводов

- Генерация переводов через DeepSeek API
- Генерация транскрипции
- Управление API ключами
- Обработка ошибок

#### LyricsGeneratorService
**Ответственность:** Пакетная генерация текстов

- Генерация текстов для нескольких песен
- Прогресс генерации
- Управление параметрами

### State Management

Приложение использует **Provider** для управления состоянием:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    // AudioService, LyricsService, TranslationService создаются в screens
  ],
)
```

**Providers:**
- `ThemeProvider` - управление темой (светлая/темная)
- `SettingsProvider` - настройки приложения
- `AudioService` - состояние плеера
- `LyricsService` - текст песни
- `TranslationService` - переводы

### UI Компоненты

#### Главные экраны

**MainScreen** - главный экран с нижней навигацией:
- SongLibraryScreen - библиотека песен
- PlaylistScreen - плейлисты
- SettingsScreen - настройки

**PlayerScreen** - плеер с текстом:
- Аудио контролы
- Синхронизированный текст
- Выбор языка перевода
- Панель инструментов

#### Виджеты

- `SongListTile` - карточка песни в списке
- `LyricLineWidget` - строка текста с подсветкой
- `EmptyLibraryWidget` - состояние пустой библиотеки
- `GenerationProgressWidget` - прогресс генерации
- `LoadingWidget` - индикатор загрузки

### Архитектура Python скриптов

```
scripts/
├── deepseek_generator_v3.py      # Основной генератор
├── deepseek_generator_v2.py      # Предыдущая версия
├── generate_lrc_json.py         # Создание LRC и JSON
├── create_lyrics_from_files.py  # Обработка файлов
├── process_excel_songs.py        # Обработка Excel файлов
├── generate_lesson_template.py  # Генерация шаблонов уроков
├── generate_translation_audio.py # Локальный TTS-пайплайн перевода песен (edge-tts)
├── batch_generate.py            # Пакетная генерация караоке-версий
├── word_align.py                # Выравнивание TTS по словам
├── voices_map.py                # Маппинг языков на голоса edge-tts
├── demucs_service.py            # Разделение стемов (караоке-режим)
├── update_localization.py       # Обновление локализации
├── check_files.py              # Проверка файлов
└── auto_sync_tool.py           # Автоматическая синхронизация
```

Описание пайплайна контента — [`CONTENT_PIPELINE.md`](CONTENT_PIPELINE.md).

### Основной Python генератор (deepseek_generator_v3.py)

**Функциональность:**
- Генерация переводов через DeepSeek API
- Генерация транскрипции
- Создание LRC файлов с временными метками
- Создание JSON файлов с переводами
- Создание ZIP архивов с материалами

**Параметры:**
- `--text` - текст песни
- `--languages` - список языков (de,en,ru,trans)
- `--start_minute` - начальное время (30.0 по умолчанию)
- `--timing_step` - шаг времени (5.0 секунд)

**Режимы перевода:**
- `poetic` - художественный перевод
- `literal` - дословный перевод
- `balanced` - сбалансированный (по умолчанию)

### Потоки данных

#### Добавление новой песни

```
1. Выбор аудиофайла
   ↓
2. Поиск текста онлайн или загрузка LRC
   ↓
3. Генерация переводов через DeepSeek API
   ↓
4. Создание JSON файла с переводами
   ↓
5. Сохранение в базу данных
   ↓
6. Отображение в библиотеке
```

#### Воспроизведение песни

```
1. Выбор песни из библиотеки
   ↓
2. Загрузка аудиофайла в AudioService
   ↓
3. Загрузка LRC файла в LyricsService
   ↓
4. Загрузка переводов в TranslationService
   ↓
5. Начало воспроизведения
   ↓
6. Синхронизация текста с аудио (каждую секунду)
   ↓
7. Подсветка текущей строки
```

#### Генерация уроков

```
1. Создание текста песни
   ↓
2. Генерация переводов через DeepSeek
   ↓
3. Создание LRC файла
   ↓
4. Создание JSON файлов с переводами
   ↓
5. Создание ZIP архива
   ↓
6. Сохранение в lessons/
```

## База данных

### Таблица songs

| Колонка | Тип | Описание |
|---------|-----|----------|
| id | TEXT PRIMARY KEY | Уникальный ID |
| title | TEXT NOT NULL | Название |
| artist | TEXT NOT NULL | Исполнитель |
| audioPath | TEXT NOT NULL | Путь к аудио |
| lrcPath | TEXT | Путь к LRC |
| translationsPath | TEXT | Путь к переводам |
| coverArtPath | TEXT | Путь к обложке |
| coverArtVersion | INTEGER | Версия обложки |
| originalLanguage | TEXT | Оригинальный язык |
| language | TEXT | Язык |
| selectedLanguage | TEXT | Выбранный язык |
| hasLyrics | INTEGER | Есть текст (0/1) |
| createdAt | TEXT NOT NULL | Дата создания |

### Таблица playlists

| Колонка | Тип | Описание |
|---------|-----|----------|
| id | TEXT PRIMARY KEY | Уникальный ID |
| name | TEXT NOT NULL | Название |
| coverArtPath | TEXT | Обложка |
| coverArtVersion | INTEGER | Версия обложки |
| createdAt | TEXT NOT NULL | Дата создания |

### Таблица song_translations

| Колонка | Тип | Описание |
|---------|-----|----------|
| id | TEXT PRIMARY KEY | Уникальный ID |
| songId | TEXT NOT NULL | ID песни |
| language | TEXT NOT NULL | Код языка |
| languageName | TEXT NOT NULL | Название языка |
| filePath | TEXT NOT NULL | Путь к файлу |
| type | TEXT | Тип |
| createdAt | TEXT NOT NULL | Дата создания |

### Таблица playlist_songs

| Колонка | Тип | Описание |
|---------|-----|----------|
| playlistId | TEXT NOT NULL | ID плейлиста |
| songId | TEXT NOT NULL | ID песни |
| position | INTEGER NOT NULL | Позиция |

## API интеграции

### DeepSeek API

**Эндпоинт:** `https://api.deepseek.com/v1/chat/completions`

**Модель:** `deepseek-reasoner`

**Функции:**
- Генерация переводов
- Генерация транскрипции
- Создание текстов песен

### Lyrics API

**Используемые сервисы:**
- lyrics.wikia.com
- genius.com
- azlyrics.com

## Конфигурация

### Файл .env

```
DEEPSEEK_API_KEY=your_api_key_here
```

### Настройки приложения

Сохраняются в SharedPreferences:
- Тема приложения
- Размер шрифта
- Стиль шрифта
- Язык интерфейса
- Начальный экран
- Пути к папкам
- API ключи

## Безопасность

- API ключи хранятся в .env файле
- Пароли не сохраняются
- Пути к файлам не содержат чувствительных данных
- SQLite база данных локальная

## Производительность

- Lazy loading для больших списков
- Кэширование переводов
- Асинхронные операции для UI
- Оптимизация базы данных (индексы)
- Сжатие изображений для обложек

## Логирование

Используется `debugPrint()` для отладки:
- Состояние аудио сервиса
- Загрузка файлов
- Ошибки API
- Состояние базы данных

## Тестирование

- Unit тесты для моделей
- Widget тесты для UI
- Интеграционные тесты для сервисов

---

Дополнительная информация:
- [Настройка окружения](SETUP.md)
- [Форматы данных](DATA_FORMATS.md)
- [Пайплайн контента](CONTENT_PIPELINE.md)
- [История версий](CHANGELOG.md)
- [AGENTS.md](../AGENTS.md) — конвенции и поведение сервисов (актуализируется каждым релизом)
