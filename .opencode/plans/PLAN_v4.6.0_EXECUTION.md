# LingoTune v4.6.0 — План выполнения (аудит + фиксы + сборка)

**Дата:** 08.04.2026
**Платформа:** Android (Flutter), Windows 11
**Flutter SDK:** C:\flutter
**Выходной APK:** `D:\ProjectAI\LingoTune\builds\LingoTune-v4.6.0.apk`

---

## Фаза 1: Обновление версии (2 файла)

Версия **4.6.0** уже обновлена в:
- `app/pubspec.yaml` ✅
- `app/lib/app_info.dart` ✅
- `app/android/app/build.gradle` ✅
- `app/android/local.properties` ✅

**Требуют исправления:**

| # | Файл | Строка | Было | Стало |
|---|------|--------|------|-------|
| 1 | `app/lib/about_app.dart` | 33 | `'v4.4.10'` | `'v${AppInfo.version}'` (импортировать AppInfo) |
| 2 | `docs/README.md` | 3 | `4.3.11` | `4.6.0` |

---

## Фаза 2: Критические баги (4 фикса) — КРАШИ

### 2.1 Инвертированная проверка null — краш
- **Файл:** `app/lib/widgets/settings/default_auto_scroll_focus_offset_control.dart`
- **Строка:** 42-43
- **Проблема:** `if (parsed != null) return;` — инвертировано. Когда парсинг успешен, метод делает return. Когда null — вызывает `_updateOffset(parsed!)` с крашем.
- **Фикс:** `if (parsed == null) return;`

### 2.2 Потеря данных при сериализации Song
- **Файл:** `app/lib/models/song.dart`
- **Строка:** 70-87
- **Проблема:** `toJson()` не сериализует поле `translations`
- **Фикс:** Добавить `'translations': translations.map((t) => t.toJson()).toList()` в `toJson()`

### 2.3 Краш при десериализации Playlist
- **Файл:** `app/lib/models/playlist.dart`
- **Строка:** 31
- **Проблема:** `json['isSystem'] as int == 1` — краш если JSON хранит bool
- **Фикс:** `isSystem: (json['isSystem'] == 1 || json['isSystem'] == true)`

### 2.4 setState после dispose в диалоге поиска
- **Файл:** `app/lib/widgets/lyrics_search_dialog.dart`
- **Строка:** 39-48
- **Проблема:** `setState` после `await` без `mounted` проверки
- **Фикс:** Добавить `if (!mounted) return;` перед каждым `setState` после async gap

---

## Фаза 3: Утечки памяти (7 фиксов)

### 3.1 Утечка StreamSubscription в BackgroundAudioHandler
- **Файл:** `app/lib/services/background_audio_handler.dart`
- **Строки:** 53, 61
- **Проблема:** Два `StreamSubscription` от `session.interruptionEventStream` и `session.becomingNoisyEventStream` не сохраняются и не могут быть отменены
- **Фикс:** Сохранить в поля `_interruptionSubscription` и `_becomingNoisySubscription`

### 3.2 Нет dispose() в BackgroundAudioHandler
- **Файл:** `app/lib/services/background_audio_handler.dart`
- **Проблема:** Нет метода `dispose()`, 6 подписок чистятся только в `stop()`
- **Фикс:** Добавить метод `dispose()` вызывающий `stop()` + cancel для новых подписок

### 3.3 6 TextEditingController не освобождаются
- **Файл:** `app/lib/services/settings_dialogs.dart`
- **Строки:** 48, 95, 158, 282, 335, 435
- **Проблема:** Контроллеры создаются, но никогда не вызывается `dispose()`
- **Фикс:** Обернуть содержимое диалогов в `StatefulBuilder` и вызывать dispose в его dispose

### 3.4 BackgroundAudioHandler не dispose из main.dart
- **Файл:** `app/lib/main.dart`
- **Строка:** 117
- **Проблема:** `_backgroundHandler` инициализируется, но `dispose()` не вызывается
- **Фикс:** Добавить `_backgroundHandler?.dispose()` в метод `dispose()` стейта

### 3.5 Неограниченный кэш в CoverArtService
- **Файл:** `app/lib/services/cover_art_service.dart`
- **Строка:** 11
- **Проблема:** `_fileExistsCache` растёт без ограничений
- **Фикс:** Добавить лимит (500 записей) с удалением старых при превышении

### 3.6 Неограниченный кэш в DeepSeekApiService
- **Файл:** `app/lib/services/deepseek_api_service.dart`
- **Строка:** 25
- **Проблема:** `_cache` растёт без ограничений
- **Фикс:** Добавить очистку истёкших записей + лимит (200 записей)

### 3.7 TextEditingController в playlist_screen
- **Файл:** `app/lib/screens/playlist_screen.dart`
- **Строка:** 193
- **Проблема:** `TextEditingController` в `_createPlaylist` не освобождается
- **Фикс:** Добавить `controller.dispose()` после закрытия диалога

---

## Фаза 4: Баги логики (5 фиксов)

### 4.1 onSongComplete вызывается при старте песни
- **Файл:** `app/lib/services/audio_service.dart`
- **Строка:** 309
- **Проблема:** `onSongComplete?.call()` внутри `_playSongAtIndex` — может вызвать бесконечный пропуск
- **Фикс:** Убрать вызов `onSongComplete?.call()` из `_playSongAtIndex`

### 4.2 Visibility toggle не работает
- **Файл:** `app/lib/services/settings_dialogs.dart`
- **Строки:** 64-66
- **Проблема:** Кнопка делает `controller.text = controller.text` — ничего не делает
- **Фикс:** Добавить `StatefulBuilder` с `obscureText` состоянием и переключать его

### 4.3 Отмена импорта папки не работает
- **Файл:** `app/lib/services/folder_import_service.dart`
- **Строки:** 108-172
- **Проблема:** `shouldCancel` никогда не становится `true`, onCancel не используется
- **Фикс:** Назначить `onCancel` callback на `shouldCancel = true`

### 4.4 DropdownButton не обновляет UI
- **Файл:** `app/lib/screens/helpers/player_import_helper.dart`
- **Строки:** 302-311
- **Проблема:** Нет `setState` при выборе значения в dropdown внутри диалога
- **Фикс:** Обернуть в `StatefulBuilder` и использовать его `setState`

### 4.5 Мутация state внутри build()
- **Файл:** `app/lib/screens/player_screen.dart`
- **Строка:** 1436
- **Проблема:** `_lineKeys.add()` вызывается внутри builder'а — антипаттерн
- **Фикс:** Вынести мутацию в `didUpdateWidget` или метод перед `build()`

---

## Фаза 5: Безопасность + Null Safety

### 5.1 Path Traversal в export_import_service
- **Файл:** `app/lib/services/export_import_service.dart`
- **Строки:** 223-256
- **Проблема:** `extractMp3Files` не проверяет пути через `_isSafePath()`
- **Фикс:** Добавить `_isSafePath()` проверку перед записью файлов

### 5.2 substring краш на коротких строках
- **Файл:** `app/lib/services/deepseek_api_service.dart`
- **Строки:** 55, 85, 290
- **Проблема:** `.substring(0, 30)` / `.substring(0, 500)` крашат если строка короче
- **Фикс:** Использовать `text.length < 30 ? text : text.substring(0, 30)`

### 5.3 double? cast краш на int
- **Файл:** `app/lib/models/lyric_line.dart`
- **Строка:** 22
- **Проблема:** `json['originalStartTime'] as double?` крашнет если значение `int`
- **Фикс:** `(json['originalStartTime'] as num?)?.toDouble()`

### 5.4 Утечка DB подключения в mergeDatabase
- **Файл:** `app/lib/services/database_service.dart`
- **Строки:** 596-713
- **Проблема:** `importedDb` не закрывается при исключении
- **Фикс:** Добавить `finally { await importedDb.close(); }`

---

## Фаза 6: Сборка APK

```batch
cd D:\ProjectAI\LingoTune\app
C:\flutter\bin\flutter build apk --release

mkdir D:\ProjectAI\LingoTune\builds 2>nul
copy D:\ProjectAI\LingoTune\app\build\app\outputs\flutter-apk\app-release.apk D:\ProjectAI\LingoTune\builds\LingoTune-v4.6.0.apk
```

**Выходной файл:** `D:\ProjectAI\LingoTune\builds\LingoTune-v4.6.0.apk`

---

## Итого

| Категория | Кол-во фиксов | Файлов |
|-----------|---------------|--------|
| Версия | 2 | 2 |
| Критические баги | 4 | 4 |
| Утечки памяти | 7 | 5 |
| Баги логики | 5 | 5 |
| Безопасность/Null Safety | 4 | 4 |
| **ВСЕГО** | **22** | **~15** |
