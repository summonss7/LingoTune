# LingoTune v4.6.15 - Сборка APK

## ✅ ВЫПОЛНЕНО

### 1. Обновление версии
- `app/pubspec.yaml`: версия 4.6.14 → 4.6.15
- `app/android/app/build.gradle`: versionCode 182 → 183, archivesBaseName → LingoTune-v4.6.15
- `app/lib/app_info.dart`: версия 4.6.14 → 4.6.15, versionCode 182 → 183

### 2. Исправления критических багов

**Серый экран в плейлистах (критический баг):**
- Причина: `AnimatedBuilder(animation: widget.audioService)` внутри каждого `itemBuilder` в `playlist_songs_screen.dart` вызывал rebuild всех видимых Card ~20 раз/сек при воспроизведении, что приводило к крашу рендера
- Фикс: Заменён на `ValueListenableBuilder<String?>` с отдельным `ValueNotifier<String?>` (`currentSongIdNotifier`) в `AudioService`, который стреляет только при смене песни
- Новый метод `_buildSongList()` вынесен из `build()` для чистоты кода

**Slider краш в PlayerScreen:**
- Причина: `Slider(value: position, max: duration)` крашился когда `duration = Duration.zero` (max=0) или `position > duration`
- Фикс: Добавлен clamp значения и min max=1.0

**Отсутствующие ключи локализации:**
- Добавлены `repeatOff`, `repeatAll`, `repeatOne`, `repeatAllPlaylists` во все 11 ARB файлов
- Добавлены `timestampOffset`, `timestampOffsetSubtitle`, `resetTimestamps`, `resetTimestampsConfirm`, `resetTimestampsSuccess`, `saveAfterReset`, `saveAfterResetConfirm`

**Несуществующая иконка:**
- `Icons.timer_reset` → `Icons.restore` в `translation_editor_screen.dart`

### 3. Новая функциональность

**Режим повтора всех плейлистов (LoopMode.allPlaylists):**
- Новый enum: `LoopMode { off, all, one, allPlaylists }`
- Цикл переключения: off → all → one → allPlaylists → off
- `_playNextFromAllPlaylists()` - переход к следующему плейлисту при окончании текущего
- Визуальная индикация: иконка списка в углу кнопки повтора
- Tooltip'ы локализованы: repeatOff, repeatAll, repeatOne, repeatAllPlaylists

**Подсветка текущей песни в плейлисте:**
- Card с фоном `primaryContainer.withOpacity(0.5)`
- Рамка `primary` цветом
- Иконка эквалайзера `Icons.graphic_eq` на обложке
- Название песни цветом `primary`
- Оптимизировано через `ValueNotifier<String?>` — rebuild только при смене песни

**Настройка смещения временных меток:**
- Settings → Display → Timestamp Offset (0-180 минут)
- Сброс временных меток в Translation Editor
- Виджет `TimestampOffsetControl`

### 4. Обновлённые файлы

**Модели:**
- `app/lib/models/loop_mode.dart` — добавлен `allPlaylists`

**Сервисы:**
- `app/lib/services/audio_service.dart` — `LoopMode.allPlaylists`, `currentSongIdNotifier`
- `app/lib/services/background_audio_handler.dart` — `LoopMode.allPlaylists` в switch
- `app/lib/services/settings_provider.dart` — `defaultTimestampOffset`

**Экраны:**
- `app/lib/screens/player_screen.dart` — LoopMode.allPlaylists, Slider fix
- `app/lib/screens/playlist_songs_screen.dart` — `_buildSongList()` с подсветкой
- `app/lib/screens/settings_screen.dart` — TimestampOffsetControl
- `app/lib/screens/translation_editor_screen.dart` — reset timestamps, Icons.restore

**Хелперы:**
- `app/lib/screens/helpers/player_playlist_helper.dart` — allPlaylists support

**Локализация (11 ARB файлов + сгенерированные):**
- app_en, app_ru, app_de, app_fr, app_es, app_it, app_pt, app_ro, app_uk, app_zh, app_ar

## 📦 Результат

APK находится в:
```
D:\Ai-Projects\LingoTune\builds\LingoTune-v4.6.15.apk
```

## 📊 Информация о сборке

- **Версия:** 4.6.15
- **VersionCode:** 183
- **Flutter SDK:** C:\flutter (3.44.0)
- **Размер APK:** 62.6 MB

---
*Дата сборки: 01.06.2026*
