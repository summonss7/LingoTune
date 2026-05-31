# LingoTune v4.6.0 — Детальный план разработки

**Дата создания:** 08.04.2026  
**Версия:** 4.6.0  
**VersionCode:** 168  
**Платформа:** Android (Flutter/Dart)  
**Сборка:** `C:\flutter\bin\flutter build apk --release`  
**Выходной APK:** `D:\Ai-Projects\LingoTune\builds\LingoTune-v4.6.12.apk`

---

## ЭТАП 1: Обновление версии приложения

### Задача 1.1 — pubspec.yaml
- **Файл:** `app/pubspec.yaml`
- **Строка:** 5
- **Было:** `version: 4.5.1`
- **Стало:** `version: 4.6.0`

### Задача 1.2 — app_info.dart
- **Файл:** `app/lib/app_info.dart`
- **Строки:** 7-8
- **Было:**
  ```dart
  static const String version = '4.5.1';
  static const String versionCode = '167';
  ```
- **Стало:**
  ```dart
  static const String version = '4.6.0';
  static const String versionCode = '168';
  ```

### Задача 1.3 — build.gradle
- **Файл:** `app/android/app/build.gradle`
- **Строки:** 47, 49
- **Было:**
  ```groovy
  versionCode 167
  archivesBaseName = "LingoTune-v4.5.1"
  ```
- **Стало:**
  ```groovy
  versionCode 168
  archivesBaseName = "LingoTune-v4.6.0"
  ```

### Задача 1.4 — Проверка
- Выполнить `cd app && C:\flutter\bin\flutter pub get`
- Убедиться что нет ошибок

---

## ЭТАП 2: UI диалога создания плейлиста

### Задача 2.1 — Перестроить диалог `_createPlaylist()`
- **Файл:** `app/lib/screens/playlist_screen.dart`
- **Метод:** `_createPlaylist()` (строки 191-327)
- **Что сделать:**
  1. Переместить выбор папки **на самый верх** диалога (перед полем названия)
  2. Заменить `ListTile` на **крупную кнопку** с иконкой `Icons.folder_open`, текстом "Выбрать папку с музыкой" и подзаголовком "Нажмите, чтобы выбрать папку с аудиофайлами"
  3. Если папка выбрана — показывать путь к папке и кнопку очистки (X)
  4. Поле "Название плейлиста" — вторым элементом
  5. Поле "Иконка" — третьим, заменить `TextField` на **Dropdown** с предустановленными иконками:
     - `music_note` (🎵 Нота)
     - `favorite` (❤️ Избранное)
     - `language` (🌐 Язык)
     - `library_music` (📚 Библиотека)
     - `playlist_play` (▶️ Плейлист) — по умолчанию
  6. При выборе папки автоматически подставлять имя папки в название (если пользователь ещё не редактировал)

### Задача 2.2 — Обновить метод `_getIconData()`
- **Файл:** `app/lib/screens/playlist_screen.dart`
- **Метод:** `_getIconData()` (строки 960-973)
- **Что сделать:** Добавить больше вариантов иконок в dropdown и в метод

---

## ЭТАП 3: Исправление бага — Shuffle/Loop сбрасываются

### Задача 3.1 — Синхронизация состояния из AudioService
- **Файл:** `app/lib/screens/player_screen.dart`
- **Метод:** `initState()` (строки 415-454)
- **Проблема:** Локальные переменные `_isShuffleEnabled` и `_loopMode` инициализируются дефолтными значениями (`false` и `LoopMode.off`), игнорируя текущее состояние `AudioService`
- **Что сделать:** После `_currentSong = widget.song;` добавить:
  ```dart
  _isShuffleEnabled = widget.audioService.isShuffleEnabled;
  _loopMode = widget.audioService.loopMode;
  ```

### Задача 3.2 — Сохранение состояния при навигации
- **Файл:** `app/lib/screens/player_screen.dart`
- **Метод:** `dispose()` (строки 624-629)
- **Проблема:** `widget.audioService.pause()` вызывается при ЛЮБОМ закрытии PlayerScreen, включая навигацию между вкладками
- **Что сделать:** Убрать `widget.audioService.pause()` из `dispose()`. Музыка должна продолжать играть через BackgroundAudioHandler

---

## ЭТАП 4: Исправление бага — Перевод исчезает при повороте/простое

### Задача 4.1 — Последовательная загрузка в initState
- **Файл:** `app/lib/screens/player_screen.dart`
- **Метод:** `initState()` (строки 426-437)
- **Проблема:** `widget.lyricsService.loadLrcFile()` вызывается БЕЗ `await`, затем `_updateLyricsWithTranslations()` тоже без `await`. Возникает race condition — переводы применяются к пустому списку строк
- **Что сделать:** Переписать загрузку как `async` последовательность:
  ```dart
  // Было (race condition):
  widget.lyricsService.loadLrcFile(widget.song.lrcPath!);
  _scanAndAddTranslations(widget.song.id, widget.song.title);
  _updateLyricsWithTranslations();
  
  // Стало (последовательно):
  if (widget.song.lrcPath != null && widget.song.lrcPath!.isNotEmpty) {
    await widget.lyricsService.loadLrcFile(widget.song.lrcPath!);
  }
  await _loadAllTranslations(widget.song.id, widget.song.title);
  await _updateLyricsWithTranslations();
  ```

### Задача 4.2 — Пересоздание при повороте экрана
- **Файл:** `app/lib/screens/player_screen.dart`
- **Метод:** `didChangeDependencies()` (строки 81-123)
- **Проблема:** Метод `async`, что некорректно для lifecycle метода Flutter. Асинхронные операции могут завершиться после того, как виджет уже пересоздан
- **Что сделать:** Обернуть async-операции в проверку `mounted`, добавить `return` после каждого `setState` если `!mounted`

---

## ЭТАП 5: Исправление критического бага — `shuffledPlaylist` crash

### Задача 5.1 — Добавить геттер в AudioService
- **Файл:** `app/lib/services/audio_service.dart`
- **Строка:** после 36
- **Проблема:** `player_playlist_helper.dart:89` ссылается на `audioService.shuffledPlaylist`, но этого геттера нет — вызовет `NoSuchMethodError`
- **Что сделать:** Добавить геттер:
  ```dart
  List<int>? get shuffledPlaylist => _shuffledIndices;
  ```

---

## ЭТАП 6: Оптимизация таймера позиций

### Задача 6.1 — Кэшировать SharedPreferences значения
- **Файл:** `app/lib/screens/player_screen.dart`
- **Метод:** `_startPositionUpdates()` (строки 601-621)
- **Проблема:** Каждые 100мс вызывается:
  - `SharedPreferences.getInstance()` — чтение из диска
  - `_updateLyricsWithTranslations()` — полный обход всех строк
  - `setState(() {})` — полная перерисовка
- **Что сделать:**
  1. Увеличить интервал с 100мс до 200мс
  2. Кэшировать `showTranscription` значение в поле класса, обновлять только при смене
  3. Вызывать `_updateLyricsWithTranslations()` ТОЛЬКО при смене `currentIndex`
  4. Не вызывать `setState()` если позиция не изменилась визуально

### Задача 6.2 — Оптимизация _updateLyricsWithTranslations
- **Файл:** `app/lib/screens/helpers/player_translation_helper.dart`
- **Метод:** `updateLyricsWithTranslations()` (строки 289-339)
- **Проблема:** Каждые 100мс обходит ВСЕ строки и ВСЕ переводы
- **Что сделать:** Добавить флаг "нужно обновление" — обновлять только при смене песни или языка

---

## ЭТАП 7: Безопасность — Path traversal в ZIP extraction

### Задача 7.1 — Валидация имён файлов в ZIP
- **Файл:** `app/lib/services/export_import_service.dart`
- **Метод:** `importFromZip()` (строка ~312) и `extractSongArchive()` (строки ~422-438)
- **Проблема:** `path.join(folder.path, fileName)` без проверки `../` в имени файла — может записать файл за пределами целевой папки
- **Что сделать:** Добавить валидацию:
  ```dart
  bool _isSafePath(String basePath, String candidate) {
    final resolved = path.canonicalize(path.join(basePath, candidate));
    return resolved.startsWith(path.canonicalize(basePath));
  }
  ```
  Применить перед каждым `path.join` с именем из ZIP

---

## ЭТАП 8: Исправление Cover Art Service

### Задача 8.1 — Асинхронная проверка файла
- **Файл:** `app/lib/services/cover_art_service.dart`
- **Метод:** `buildCoverArtWidget()` (строка ~204)
- **Проблема:** `coverFile.existsSync()` — синхронный I/O в момент `build()` виджета, блокирует UI
- **Что сделать:** Переписать метод как `static Future<Widget>` и использовать `FutureBuilder`, либо кэшировать результат проверки

### Задача 8.2 — Удаление thumbnail при удалении обложки
- **Файл:** `app/lib/services/cover_art_service.dart`
- **Метод:** `deleteCoverArt()` (строки ~179-191)
- **Проблема:** Удаляется только основной файл обложки, но `_thumb.png` остаётся
- **Что сделать:** Также удалять файл с суффиксом `_thumb`:
  ```dart
  final thumbFile = File(coverArtPath!.replaceAll('.png', '_thumb.png'));
  if (await thumbFile.exists()) await thumbFile.delete();
  ```

---

## ЭТАП 9: Исправление Folder Config Service

### Задача 9.1 — Null safety для getDefaultFolder
- **Файл:** `app/lib/services/folder_config_service.dart`
- **Метод:** `getDefaultFolder()` (строки ~33-34)
- **Проблема:** `directory!.parent.path` — crash если `getExternalStorageDirectory()` вернёт `null`
- **Что сделать:** Добавить null-check:
  ```dart
  final directory = await getExternalStorageDirectory();
  if (directory == null) return await getApplicationDocumentsDirectory();
  ```

### Задача 9.2 — Убрать hardcoded 'Транскрипция'
- **Файл:** `app/lib/services/folder_config_service.dart`
- **Строка:** ~138
- **Проблема:** `languageName == 'Транскрипция'` — не будет работать для английского UI
- **Что сделать:** Проверять по `type == 'transcript'` вместо имени

---

## ЭТАП 10: Локализация — вынести захардкоженные строки

### Задача 10.1 — Добавить ключи в ARB файлы
- **Файлы:** `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_ru.arb`, и все остальные ARB
- **Добавить ключи (примеры):**

| Ключ | EN | RU |
|------|----|----|
| `transcriptionEnabled` | "Transcription enabled" | "Транскрипция включена" |
| `transcriptionDisabled` | "Transcription disabled" | "Транскрипция выключена" |
| `languageSelected` | "Selected language: {language}" | "Выбран язык: {language}" |
| `noTranslationsScanning` | "No translations found, scanning folder..." | "Переводов нет, сканируем папку..." |
| `translationsLoaded` | "Loaded translations: {count}" | "Загружено переводов: {count}" |
| `translationsNotFound` | "No translations found for this song" | "Переводов не найдено для этой песни" |
| `errorLoadingTranslations` | "Error loading translations: {error}" | "Ошибка загрузки переводов: {error}" |
| `languageNotAvailable` | "{settingLang} selected in settings but not available. Opening: {availableLang}" | "В настройках выбран {settingLang}, но перевода нет. Открываю первый доступный: {availableLang}" |
| `errorAudioService` | "Audio Service Error" | "Ошибка Audio Service" |
| `audioServiceFailed` | "Failed to initialize background audio playback." | "Не удалось инициализировать фоновое воспроизведение музыки." |
| `notificationMayNotAppear` | "This means the player notification may not appear." | "Это означает, что уведомление с управлением плеером может не появляться." |
| `errorLabel` | "Error:" | "Ошибка:" |
| `selectMusicFolderTitle` | "Select Music Folder" | "Выбрать папку с музыкой" |
| `tapToSelectFolder` | "Tap to select a folder with audio files" | "Нажмите, чтобы выбрать папку с аудиофайлами" |
| `selectIcon` | "Select Icon" | "Выбрать иконку" |
| `lrcAndTranslationsSaved` | "LRC and all translations saved successfully!" | "LRC и все переводы сохранены!" |
| `noLrcAssociated` | "No LRC file associated with this song" | "Нет LRC файла для этой песни" |
| `translationDeleted` | "Translation \"{name}\" deleted successfully" | "Перевод \"{name}\" успешно удалён" |
| `failedToDeleteTranslation` | "Failed to delete translation: {error}" | "Ошибка удаления перевода: {error}" |
| `generatingTranslations` | "Generating translations" | "Генерация переводов" |
| `selectTranslationLanguages` | "Select translation languages" | "Выберите языки перевода" |

### Задача 10.2 — Заменить строки в player_screen.dart
- **Файл:** `app/lib/screens/player_screen.dart`
- **Строки:** 766, 897, 1403, 1417, 1422, 1443, 1797 и др.
- **Пример:**
  ```dart
  // Было:
  Text('Транскрипция включена')
  // Стало:
  Text(AppLocalizations.of(context)!.transcriptionEnabled)
  ```

### Задача 10.3 — Заменить строки в player_translation_helper.dart
- **Файл:** `app/lib/screens/helpers/player_translation_helper.dart`
- **Строки:** 45, 112, 125, 186-188, 237, 253

### Задача 10.4 — Заменить строки в main.dart
- **Файл:** `app/lib/main.dart`
- **Строки:** 201, 204, 209-215, 221

### Задача 10.5 — Заменить строки в settings_screen.dart
- **Файл:** `app/lib/screens/settings_screen.dart`
- **Строки:** 341-342

### Задача 10.6 — Заменить строки в player_export_helper.dart
- **Файл:** `app/lib/screens/helpers/player_export_helper.dart`
- Найти и заменить все захардкоженные строки

### Задача 10.7 — Заменить строки в folder_config_service.dart
- **Файл:** `app/lib/services/folder_config_service.dart`
- **Строка:** 138

### Задача 10.8 — Заменить строки в других файлах
- Проверить: `generation_progress_widget.dart`, `generation_options_widget.dart`, `playlist_songs_screen.dart`

---

## ЭТАП 11: Рефакторинг — убрать дублирование кода

### Задача 11.1 — Вынести `_getTranslationLanguageName` в утилиту
- **Файлы-источники:**
  - `app/lib/screens/player_screen.dart` (строка 218)
  - `app/lib/screens/helpers/player_translation_helper.dart` (строка 266)
- **Целевой файл:** `app/lib/utils/language_helpers.dart` (создать если нет)
- **Что сделать:**
  1. Создать/обновить `language_helpers.dart` с методом:
     ```dart
     String getTranslationLanguageName(String code) { ... }
     ```
  2. Заменить вызовы в `player_screen.dart` и `player_translation_helper.dart` на импорт из утилиты

### Задача 11.2 — Убрать неиспользуемый код
- **Файл:** `app/lib/screens/player_screen.dart`
- `_shuffledIndices` (строка 64) — поле нигде не читается, shuffle управляется через AudioService
- `_getTypeLabel()` (строки 155-168) — метод не вызывается

---

## ЭТАП 12: Финальная сборка и тестирование

### Задача 12.1 — Flutter analyze
```bash
cd app
C:\flutter\bin\flutter analyze
```
Исправить все warnings и errors

### Задача 12.2 — Сборка APK
```bash
cd app
C:\flutter\bin\flutter build apk --release
```

### Задача 12.3 — Копирование APK
```bash
copy app\build\app\outputs\flutter-apk\*.apk D:\ProjectAI\LingoTune\builds\
```

### Задача 12.4 — Проверка
- Убедиться что APK создан: `LingoTune-v4.6.0.apk`
- Размер APK должен быть сопоставим с предыдущей версией

---

## Приложение: Полный список файлов для изменения

| # | Файл | Этапы |
|---|------|-------|
| 1 | `app/pubspec.yaml` | 1.1 |
| 2 | `app/lib/app_info.dart` | 1.2 |
| 3 | `app/android/app/build.gradle` | 1.3 |
| 4 | `app/lib/screens/playlist_screen.dart` | 2.1, 2.2 |
| 5 | `app/lib/screens/player_screen.dart` | 3.1, 3.2, 4.1, 4.2, 6.1, 10.2, 11.2 |
| 6 | `app/lib/services/audio_service.dart` | 5.1 |
| 7 | `app/lib/screens/helpers/player_playlist_helper.dart` | проверка после 5.1 |
| 8 | `app/lib/screens/helpers/player_translation_helper.dart` | 6.2, 10.3, 11.1 |
| 9 | `app/lib/services/export_import_service.dart` | 7.1 |
| 10 | `app/lib/services/cover_art_service.dart` | 8.1, 8.2 |
| 11 | `app/lib/services/folder_config_service.dart` | 9.1, 9.2, 10.7 |
| 12 | `app/lib/l10n/app_en.arb` | 10.1 |
| 13 | `app/lib/l10n/app_ru.arb` | 10.1 |
| 14 | `app/lib/l10n/app_de.arb` | 10.1 |
| 15 | `app/lib/l10n/app_fr.arb` | 10.1 |
| 16 | `app/lib/l10n/app_es.arb` | 10.1 |
| 17 | `app/lib/l10n/app_it.arb` | 10.1 |
| 18 | `app/lib/l10n/app_pt.arb` | 10.1 |
| 19 | `app/lib/l10n/app_ro.arb` | 10.1 |
| 20 | `app/lib/l10n/app_uk.arb` | 10.1 |
| 21 | `app/lib/l10n/app_zh.arb` | 10.1 |
| 22 | `app/lib/l10n/app_ar.arb` | 10.1 |
| 23 | `app/lib/main.dart` | 10.4 |
| 24 | `app/lib/screens/settings_screen.dart` | 10.5 |
| 25 | `app/lib/screens/helpers/player_export_helper.dart` | 10.6 |
| 26 | `app/lib/utils/language_helpers.dart` | 11.1 |
| 27 | `app/lib/screens/playlist_songs_screen.dart` | 10.8 |

---

## Приоритет выполнения

```
Этап 1  (версия)          → быстро, 5 минут
Этап 5  (shuffledPlaylist) → критический баг, 2 минуты  
Этап 3  (shuffle/loop)     → критический баг, 10 минут
Этап 4  (перевод исчезает) → критический баг, 15 минут
Этап 2  (UI плейлиста)     → UX улучшение, 30 минут
Этап 6  (таймер)           → производительность, 20 минут
Этап 7  (path traversal)   → безопасность, 15 минут
Этап 8  (cover art)        → исправление, 15 минут
Этап 9  (folder config)    → исправление, 10 минут
Этап 11 (рефакторинг)      → чистота кода, 15 минут
Этап 10 (локализация)      → объёмная работа, 60 минут
Этап 12 (сборка)           → финал, 10 минут
```

**Общее время оценки: ~3.5 часа**
