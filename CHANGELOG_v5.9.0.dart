// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.9.0
// ================================================
// ФИЧА-релиз по пожеланию из хаба Aila (карточка lingotune-004):
// «сделай возможность переименования плейлиста, если нету текста на
// песни — сделай чтоб был во время игры песни красивый эквалайзер
// вместо текста... и самое важное сделай автообновление приложения».
// Дата: 19.10.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.12 → 5.9.0
+ open_filex: ^4.5.0, url_launcher: ^6.3.1 (автообновление)

// app/android/app/build.gradle
versionCode: 240 → 241
archivesBaseName: "LingoTune-v5.8.12" → "LingoTune-v5.9.0"

// app/lib/app_info.dart
static const String version     = '5.8.12' → '5.9.0'
static const String versionCode = '240'   → '241'
+ 3 строки в features

// app/android/app/src/main/AndroidManifest.xml
+ <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES"/>
+ <queries> https VIEW (url_launcher — открытие страницы релиза)


// ✏️ ФИЧА 1: ПЕРЕИМЕНОВАНИЕ ПЛЕЙЛИСТОВ
// ================================================
// PlaylistService.renamePlaylist(id, newName):
//   • guard: плейлист не найден или isSystem → false (системные
//     all_songs / favorites / lang_* не переименовываются);
//   • пустое имя → false; имя без изменений → true (no-op);
//   • запись через updatePlaylist(copyWith(name)) — обычный UPDATE.
//
// UI — два входа:
//   • PlaylistScreen: пункт «Переименовать» в меню ⋮ карточки плейлиста
//     (первый пункт, над «Обложка плейлиста»);
//   • PlaylistSongsScreen: пункт «✏️ Переименовать» в меню сортировки
//     (после разделителя, только для несистемных); заголовок AppBar
//     обновляется через локальную копию _playlist (late final →
//     обычное поле, widget.playlist иммутабелен).
//
// Диалог: TextField с предзаполненным именем, maxLength 60, autofocus.
// Пост-валидация: пустое/неизменённое — тихий выход; дубликат имени
// (без учёта регистра, среди остальных плейлистов) — оранжевый
// SnackBar; успех — зелёный SnackBar «Плейлист переименован».


// 🎚️ ФИЧА 2: ЭКВАЛАЙЗЕР ДЛЯ ПЕСЕН БЕЗ ТЕКСТА
// ================================================
// widgets/audio_equalizer_widget.dart (AudioEqualizerWidget):
//   • раньше: песня без LRC/перевода → lyricLines пуст → пустой
//     ListView → «голый экран» (жалоба из пожелания);
//   • теперь: PlayerScreen в ветке lines.isEmpty рисует эквалайзер;
//   • столбики: CustomPainter, ширина 6 + зазор 4, высота = сумма
//     синусоид с детерминированными от индекса частотами/фазами
//     (золотое сечение) × огибающая «горкой» к центру — картинка
//     стабильна между перерисовками, «живая» как настоящий спектр;
//   • анимация: AnimationController.repeat() ТОЛЬКО пока
//     player.playing (слушаем playingStream); на паузе — stop(),
//     картинка замирает;
//   • цвета: lerp primary → transcriptAccent («Аметист») или
//     tertiary (остальные темы), alpha 0.9, скруглённые концы;
//   • подпись «У этой песни пока нет текста» (l10n noLyricsHint)
//     с иконкой lyrics_outlined.


// ⬆️ ФИЧА 3: АВТООБНОВЛЕНИЕ ПРИЛОЖЕНИЯ
// ================================================
// services/update_service.dart (UpdateService):
//   • источник по умолчанию — GitHub Releases:
//     https://api.github.com/repos/summonss7/LingoTune/releases/latest
//     (тег релиза + APK-asset + body + html_url + size);
//   • альтернатива — простой JSON-манифест
//     {"version","notes","downloadUrl","size","url"}; адрес
//     переопределяется SharedPreferences-ключом updateManifestUrl;
//   • сравнение версий — числовое, по частям (compareVersions):
//     терпит префикс «v», суффиксы пререлиза/сборки, неполные номера
//     (5.9 == 5.9.0), 5.10.0 > 5.9.12;
//   • ВАЖНО: репозиторий сейчас ПРИВАТНЫЙ → анонимный GitHub API
//     отвечает 404 → checkForUpdate() тихо возвращает null («нет
//     обновления»). Как только хозяин сделает репо публичным и
//     создаст Release с APK — механизм заработает БЕЗ правок
//     приложения. До тех пор проверка всегда «у вас последняя
//     версия»;
//   • скачивание: стриминговый GET в <externalStorageDir>/updates/
//     LingoTune-v<version>.apk (каталог приложения — без пермиссий
//     на запись), колбэк прогресса, cancelDownload() прерывает
//     и подчищает файл.
//
// services/update_flow.dart (UpdateFlow):
//   • авто-чек: MainScreen.initState → post-frame → 5 с задержка →
//     maybeAutoCheck (троттлинг раз в 24 ч, lastUpdateCheckMs);
//     тихий: нет обновления/сеть недоступна — ничего не показываем;
//   • ручной чек: Настройки → «Проверить обновления» (сабтайтл с
//     текущей версией) → SnackBar «Проверяю…» → результат;
//   • диалог «Доступна новая версия»: текущая/новая версия, размер
//     APK, «Что нового» (тело релиза), кнопки Позже / Открыть
//     страницу релиза (url_launcher) / Скачать;
//   • прогресс-диалог скачивания: проценты + МБ, отмена; закрытие
//     ТОЛЬКО по завершению загрузки (единственный pop — нет гонок
//     «кто первый закрыл»), dispose дублирует отмену;
//   • установка: OpenFilex.open(apk) → системный инсталлер;
//     Android 8+ спросит разовое разрешение «устанавливать
//     неизвестные приложения» для LingoTune; провал запуска —
//     красный SnackBar «откройте скачанный APK вручную»;
//   • все диалоги через rootNavigator — всплывают над плеером.


// 🔧 ТЕХНИЧЕСКИЕ ДЕТАЛИ
// ================================================
// l10n: +22 ключа × 11 локалей (renamePlaylist*, playlistName*,
//   noLyricsHint, checkForUpdates, update*, download/later/install,
//   openReleasePage, whatsNew...); генерация flutter gen-l10n.
// Тесты: test/update_service_test.dart — 12 тестов (сравнение
//   версий, GitHub-релиз, простой манифест, 404/битый JSON → null,
//   override URL, троттлинг). Итого 51/51 passed.
// flutter analyze: 231 info/warning — все существовали до правок
//   (базовый уровень), 0 ошибок.


// 📦 СБОРКА
// ================================================
// build_apk_v5.7.4.ps1 → D:\LingoTune\builds\LingoTune-v5.9.0.apk (release)
// flutter build apk --debug → builds\LingoTune-v5.9.0-debug.apk
