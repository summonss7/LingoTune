# План v5.7.0: Избранное по плейлистам (глобальная корзина + режим «играть только избранное»)

**Статус:** ✅ Реализовано в v5.7.0 (APK `LingoTune-v5.7.0.apk`)
**Дата:** 2026-07-09
**Версия:** 5.7.0 (versionCode 222)
**Цель:** Позволить пользователю отмечать любимые песни и слушать их отдельной очередью, не собирая вручную отдельный плейлист.

---

## 1. Контекст и проблема

Пользователь хочет отмечать песни «сердечком» и иметь возможность слушать только избранное, не зависимо от того, в каком плейлисте он сейчас находится. До v5.7.0 единственный путь — вручную создать плейлист и добавлять туда песни через диалог «Add to playlist».

**Открытие при анализе кода:** ~70% groundwork'а уже существовало, но не было подключено:
1. В БД **уже создавался** системный плейлист `favorites` (`isSystem=1`, `database_service.dart:230`) при первом запуске, но **нигде не использовался** — песни в него никогда не добавлялись.
2. Локализационные ключи `favorites`, `favorite`, `addToFavorites`, `removeFromFavorites` **уже были определены** на всех 11 языках, но **ни один экран их не вызывал**.
3. Механика `_activePlaybackList` + `LoopMode.allPlaylists` (`player_screen.dart`) — готовый образец «режима воспроизведения поверх динамического списка».

---

## 2. Зафиксированные решения

| Развилка | Решение |
|---|---|
| Модель избранного | **Глобальная корзина** — одна коллекция на всё приложение (системный плейлист `favorites`). Не per-playlist. |
| Способ хранения | **Без миграции БД** — избранное = обычные строки в существующей junction table `playlist_songs` с `playlistId='favorites'`. |
| Активация режима | **Новый `LoopMode.favorites`** — 5-е состояние в цикле кнопки loop (`off → all → one → allPlaylists → favorites → off`). Единообразно с `allPlaylists`. |
| Persist | **Transient** — режим НЕ сохраняется в `SharedPreferences` (требует динамической загрузки списка из БД). При холодном старте всегда `off`. |
| Wrap-around | `favorites` ведёт себя как `all` (зацикливание по списку избранных, включая shuffle). |
| Расположение UI | Кнопка-сердечко **в плеере** (на текущей песне) + **в `PlaylistSongsScreen`** (на каждой строке). |

---

## 3. Архитектура

### Поток данных

```
Пользователь жмёт ♥ (плеер или список)
    ↓
_toggleCurrentSongFavorite() / _toggleFavorite()
    ↓
DatabaseService.addSongToPlaylist('favorites', songId)   // junction table playlist_songs
    ↓
setState(_isCurrentSongFavorite = true / _favoriteSongIds.add(id))


Пользователь жмёт кнопку loop до ♥ (режим favorites)
    ↓
_toggleLoop() → audioService.toggleLoop() → _loopMode = favorites
    ↓
_switchToFavoritesMode()
    ↓
db.getSongsInPlaylist('favorites')
    ↓
пусто?  ─── да ──→ SnackBar(noFavoriteSongs) + откат в off
   │
   нет
   ↓
_activePlaybackList = favSongs
audioService.setCurrentPlaylist(favSongs)
текущая в избранном? ─── да ──→ handler.setPlaylist(favSongs, currentIndex)  // продолжаем с текущей
   │                                                                              
   нет                                                                             
   ↓                                                                               
_playSong(favSongs.first)                                                          
```

### Интеграция с существующей механикой `_activePlaybackList`

Ключевая точка расширения — поле `_activePlaybackList` (введённое в v5.6.0 для `LoopMode.allPlaylists`). Все операции next/prev/queue работают с ним, а не с устаревшим `widget.playlistSongs`. Режим `favorites` использует тот же механизм: просто заменяет содержимое `_activePlaybackList` на список избранных.

### Persist-защита

`AudioService._savePlaybackSettings()` использует `_loopMode.index`. Чтобы добавление `favorites` в enum не сломало сохранение:
- `favorites` добавлен **в конец** enum (`{ off, all, one, allPlaylists, favorites }`) → `.index` существующих режимов не меняется.
- В `toggleLoop` вызов `_savePlaybackSettings()` **пропускается** для `favorites` (transient).
- В `_loadPlaybackSettings` — если из prefs загрузился `favorites` (устаревшее значение), сброс в `off`.

---

## 4. Точки вмешательства

| Подзадача | Файл | Тип работы |
|---|---|---|
| Enum + цикл loop | `loop_mode.dart`, `audio_service.dart` (`toggleLoop`), `background_audio_handler.dart` (`setRepeatMode`) | +значение enum, +case в switch |
| Shuffle wrap | `audio_service.dart` (`getNextShuffledIndex`, `getPreviousShuffledIndex`, fallback `playNext/PreviousSong`) | `all || favorites` |
| Helper next/prev/canPlay | `player_playlist_helper.dart` | `all || favorites` для wrap |
| Быстрая проверка вхождения | `database_service.dart` | новый метод `isSongInPlaylist` |
| Логика режима | `player_screen.dart`: `_switchToFavoritesMode`, `_refreshCurrentSongFavoriteStatus`, `_toggleCurrentSongFavorite`, `_toggleLoop`, `_canPlayNext`, `initState`, `_playSong` | ~120 новых строк |
| UI кнопки loop | `player_screen.dart` (`_buildLoopButton`) | +case favorites (иконка ♥, красный) |
| UI сердечко в плеере | `player_screen.dart` (transport Row) | компактная IconButton слева + spacer справа |
| UI сердечко в списке | `playlist_songs_screen.dart` | `Set<String> _favoriteSongIds` + `_buildFavoriteButton` |
| Локализация | 11× `app_*.arb` + реген `app_localizations*.dart` | 2 новых ключа (`playFavoritesOnly`, `noFavoriteSongs`); `addToFavorites`/`removeFromFavorites` уже были |
| Версия | `pubspec.yaml`, `app_info.dart`, `build.gradle`, `local.properties` | 5.6.3 → 5.7.0 (versionCode 222) |

---

## 5. Особые случаи (edge cases)

1. **Пустое избранное при активации режима** — SnackBar `noFavoriteSongs` + откат `_loopMode` в `off` (как в локальном state, так и в `audioService`).
2. **Удаление текущей песни из избранного во время игры в режиме favorites** — синхронное обновление `_activePlaybackList` (фильтрация удалённой песни), чтобы next не ушёл в неё. Если список опустел — авто-откат режима в `off` + восстановление `widget.playlistSongs`.
3. **Сам плейлист `favorites`** открыт в `PlaylistSongsScreen` — кнопка-сердечко **не показывается** (избыточна), вместо `play_arrow` показывается `remove_circle` (удалить из избранного = убрать из этого плейлиста).
4. **Холодный старт** — `initState` проверяет `_loopMode == favorites` и сбрасывает в `off` (двойная защита помимо persist-skip).
5. **Выход из режима favorites** (toggle loop: favorites → off) — `_activePlaybackList` восстанавливается из `widget.playlistSongs`.

---

## 6. Проверка

- `flutter gen-l10n` — регенерация `app_localizations*.dart` прошла без ошибок, геттеры `playFavoritesOnly`/`noFavoriteSongs` сгенерированы во всех 11 языках.
- `flutter analyze` — **0 errors** (215 pre-existing warnings/info; в новом коде замечаний нет).
- Все три `switch` по `LoopMode` (`player_screen.dart`, `audio_service.dart`, `background_audio_handler.dart`) покрывают все 5 значений enum.

---

## 7. Известные ограничения

- **Глобальная, не per-playlist модель** — одна корзина избранного на всё приложение (по решению разработки). Per-playlist потребовал бы миграции БД v12 (новое поле в `playlist_songs` или таблица).
- **`favorites` не персистится** — после холодного старта приложения режим всегда `off` (сознательное решение — transient-режим, требует динамической загрузки из БД).
- **Системный плейлист `favorites` виден** в списке плейлистов `PlaylistScreen` (если системные показываются) — это ожидаемо и полезно (можно открыть и просмотреть весь список избранных).
- **Кнопка-сердечко не добавлена в `SongLibraryScreen`** (вся библиотека) и в `SongListTile` — по решению разработки достаточно двух точек (плеер + список плейлиста).
