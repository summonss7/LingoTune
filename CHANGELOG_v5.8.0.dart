// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.0
// ================================================
// МИНОРНЫЙ РЕЛИЗ: надёжность фонового воспроизведения/звонков + новая фича —
// подсветка строк оригинала/перевода выбираемыми цветами.
// Дата: 14.08.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.7.5 → 5.8.0

// app/android/app/build.gradle
versionCode: 227 → 228
archivesBaseName: "LingoTune-v5.7.5" → "LingoTune-v5.8.0"

// app/lib/app_info.dart
static const String version    = '5.7.5' → '5.8.0';
static const String versionCode = '227'   → '228';


// 🔴 БАГ №1: ПОСЛЕ ЗВОНКА (В РЕЖИМЕ STUDY) ИГРАЕТ ОДНА ПЕСНЯ И ВСТАЁТ ПАУЗА
// ================================================
// Симптом: на заблокированном телефоне в наушниках при входящем звонке музыка
// ставится на паузу (✓), после разговора песня возобновляется, доигрывает — и
// дальше воспроизведение останавливается вместо перехода к следующей. Нажатие
// play «лечит» состояние до следующего звонка / отключения наушников / долгого
// простоя.
//
// Корневая причина: ДЕДЛОК ДВОЙНОГО ТРИГГЕРА завершения трека. Переход «песня
// закончилась → следующая» построен на двух независимых путях:
//   1) AudioService.onSongComplete (по processingState == completed) — но он
//      ЗАБЛОКИРОВАН пока study активен (player_screen.dart).
//   2) СВОЙ детектор study (segmentTimer/playerStateSub) ловит completed и
//      дёргает onStudyCompleted. После звонка аудиосессия сброшена, и этот
//      детектор срабатывает ненадёжно → НИ ОДИН путь не запускает следующую
//      песню → воспроизведение встаёт.
//
// Исправление: WATCHDOG дедлока завершения (player_screen.dart).
// Когда песня доигрывает в study-режиме, обычный путь onSongComplete (вместо
// молчаливого return) вооружает Timer ~4с. Если за это время study сам не
// продвинулся (песня та же + плеер completed/не играет) — принудительно
// _playNextSong(). Дедуп по id песни + гвард _isSongLoading защищают от
// двойного срабатывания. Повторяет идиому watchdog'ов кодовой базы
// (segment/TTS watchdog, kick-retry). Диагностика пишется в _studyEvt.


// 🔴 БАГ №2: ПОВТОР ОДНОЙ ПЕСНИ (LoopMode.one) — НЕ РАБОТАЕТ СНАЧАЛА, ИНОГДА РАБОТАЕТ
// ================================================
// Корневые причины (2):
//   (а) Race init: _loadPlaybackSettings() асинхронен и НЕ пушил восстановленный
//       режим в BackgroundAudioHandler после загрузки prefs. Если prefs
//       разрешались ПОСЛЕ setBackgroundHandler — handler оставался на дефолте
//       off и loop-one не срабатывал до первого ручного тапа
//       («сначала не работает»). Это отложенный пункт M5 из аудита v5.7.5.
//   (б) _isHandlingCompletion мог ЗАЛИПНУТЬ true навсегда: цепочка
//       seek().then(play().then(...)) была БЕЗ обработки ошибок, и висящий/
//       падающий Future (типично после деактивации сессии TTS/звонком) оставлял
//       флаг true → loop-one навсегда отключался («иногда работает»).
//
// Исправления:
//   (а) audio_service.dart: _loadPlaybackSettings теперь пушит восстановленные
//       loop/shuffle в background handler, если он уже подключён (ликвидация race).
//   (б) background_audio_handler.dart: рестарт loop-one вынесен в async-метод
//       _restartLoopOne() с try/finally + timeout — _isHandlingCompletion
//       гарантированно сбрасывается даже при висящем/падающем Future.


// 🟠 БАГ №3: РЕЖИМЫ Воспроизведения ГЛЮЧАТ В ФОНЕ (на заблокированном телефоне)
// ================================================
// Корневая причина: режим хранился в ТРЁХ независимых копиях (AudioService,
// BackgroundAudioHandler, PlayerScreen) без единого источника истины; смена
// режима с экрана блокировки НЕ синхронизировалась в PlayerScreen и НЕ
// персистилась; setLoopMode (5 мест PlayerScreen) не персистил.
//
// Исправления (консолидация состояния):
//   • audio_service.dart: колбэки onLoopToggled/onShuffleToggled (из notification)
//     теперь персистят (_savePlaybackSettings); setLoopMode тоже персистит
//     (кроме transient favorites). AudioService остаётся каноническим владельцем.
//   • player_screen.dart: добавлен слушатель audioService.addListener, который
//     синхронизирует локальные _loopMode/_isShuffleEnabled — смена режима с
//     экрана блокировки теперь отражается на кнопках и в логике next/prev.
//   • background_audio_handler.dart: цикл setRepeatMode с уведомления ограничен
//     off→all→one→off (allPlaylists/favorites требуют setup в PlayerScreen,
//     недоступный из notification — раньше попадание в них ломало очередь).
//
// Дополнительно (звонки/наушники, тот же симптом):
//   • becomingNoisy при активном звонке теперь игнорируется (раньше pause()
//     выставлял _userPausedDuringCall и блокировал авто-resume после звонка).
//   • После resume-`play()` в _handleCallResume добавлен лёгкий zombie-recovery
//     (_ensureAdvancingAfterResume) — после звонка аудиосессия сброшена, и play()
//     мог оставить just_audio в состоянии «playing=true, позиция не двигается»
//     → песня не доходит до completed → следующая не начинается. (Для study этот
//     путь не выполняется — там resume делает _kickPlayback.)


// 🟢 НОВАЯ ФИЧА №4: ПОДСВЕТКА СТРОК РАЗНЫМИ ЦВЕТАМИ (оригинал/перевод)
// ================================================
// Пользователь может выбрать цвета оригинала и перевода: готовые пресеты одним
// тапом + точная настройка каждого типа из палитры (без новых зависимостей —
// переиспользована палитра приложения). Доступ: меню «⋯» на экране плеера →
// «Цвета строк». Живой preview. Цвета применяются ко всем строкам (текущая —
// жирная + фон, неактивные — с прозрачностью); «Авто» = цвет темы.
//
// Файлы:
//   • app/lib/utils/lyric_colors.dart (NEW) — палитра LyricColorPalette + пресеты
//     LyricColorPresets (5 шт.), сентинель autoValue = -1.
//   • app/lib/services/settings_provider.dart — useCustomLyricColors,
//     originalTextColor/translationTextColor (getter'ы + setter'ы + persist).
//   • app/lib/widgets/lyric_line_widget.dart — применение кастомных цветов к
//     Text оригинала/перевода (с прозрачностью для неактивных строк).
//   • app/lib/screens/player_screen.dart — пункт меню «Цвета строк» + диалог
//     _showLyricColorsDialog (мастер-переключатель, пресеты, свотчи, preview).
//   • Локализация: 13 новых ключей × 11 локалей (en/ru/de/es/fr/it/pt/ro/uk/zh/ar)
//     в .arb и сгенерированных app_localizations*.dart.


// ✅ ТЕСТЫ
// ================================================
// Добавлен test/lyric_colors_test.dart (9 тестов): LyricColorPalette
// (colorFromValue round-trip, уникальность свотчей/пресетов, auto-семантика) +
// SettingsProvider (дефолты, персистенция с перечитыванием, сброс в auto).
// Полный набор: 15 тестов (6 существующих + 9 новых), все проходят.
// flutter analyze: 0 ошибок (только предсуществующие warning/info).


// 📌 ОТЛОЖЕНО (низкий приоритет — на будущее)
// ================================================
// - Двойной рестарт loop-one + study (handler seek+play И _playSong(_currentSong))
//   — известное minor-взаимодействие; A3 (_restartLoopOne) повышает надёжность,
//   но полную унификацию модели завершения оставляю на отдельный проход.
// - AudioService.playNextSong/playPreviousSong (dead code с расходящейся логикой
//   wrap) — не тронут (живой путь через PlayerPlaylistHelper).
// - Предсуществующие warning'и flutter analyze (deprecated withOpacity и пр.).


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/services/audio_service.dart          — A1 (init-race push), A2 (persist), A5 (setLoopMode persist), P3 (favorites out of cycle)
// app/lib/services/background_audio_handler.dart — A3 (_restartLoopOne), A6 (notification cycle), C1 (becomingNoisy), C2 (resume-kick), P2 (loop-one zombie-recovery)
// app/lib/screens/player_screen.dart           — B1/B2 (completion watchdog), A4 (audioService listener), D4 (colors dialog + menu), import, P3 (favorites removed from cycle + heart no longer switches mode)
// app/lib/widgets/lyric_line_widget.dart       — D3 (custom colors)
// app/lib/services/settings_provider.dart      — D1 (color settings + persist)
// app/lib/utils/lyric_colors.dart              — D2 (NEW: palette + presets)
// app/lib/l10n/app_*.arb (×11)                 — D5 (13 keys × 11 locales)
// app/lib/l10n/app_localizations.dart          — D5 (13 abstract getters)
// app/lib/l10n/app_localizations_*.dart (×11)  — D5 (13 overrides each)
// app/lib/app_info.dart                        — version 5.8.0 + feature line
// app/pubspec.yaml                             — version 5.8.0
// app/android/app/build.gradle                 — versionCode 228, archivesBaseName v5.8.0
// app/test/lyric_colors_test.dart              — tests (NEW FILE)
// CHANGELOG_v5.8.0.dart                        — этот файл (NEW FILE)


// 🔧 ДОРАБОТКИ ПОСЛЕ ТЕСТИРОВАНИЯ v5.8.0
// ================================================
// P2. LOOP-ONE: «переключается, но плей не включается»
//     После completed seek(0) сбрасывал позицию в начало («переключилось»),
//     но play() в зомби-состоянии just_audio НЕ запускал звук. _restartLoopOne
//     теперь проверяет движение позиции от 0; если стоит — реактивирует
//     аудиосессию и nudge'ит seek'ом к текущей позиции (force re-buffer), до 4
//     попыток. (background_audio_handler.dart)
// P3. РЕЖИМ «СЕРДЕЧКО» УБРАН ИЗ ЦИКЛА ПЕРЕКЛЮЧЕНИЯ
//     Цикл теперь: off → all → one → allPlaylists → off (без favorites).
//     Избранные песни слушаются через отдельную закладку (открываешь плейлист
//     избранного — играет по кругу как LoopMode.all). Тап на сердечко теперь
//     только добавляет/убирает песню из избранного и НЕ переключает режим
//     воспроизведения (раньше уводил активность в избранное). Удалён мёртвый
//     _switchToFavoritesMode; кнопка loop больше не показывает красную иконку
//     сердечка. (audio_service.dart, player_screen.dart)

