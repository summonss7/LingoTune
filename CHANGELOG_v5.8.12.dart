// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.12
// ================================================
// ФИКС-релиз: « ставлю режим одной песни по кругу, а она не играет».
// LoopMode.one получил страховочную сеть завершения, рестарт перестал
// драться со study-перезагрузкой, а кнопка play на доигравшей песне
// больше не молчит.
// Дата: 10.10.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.11 → 5.8.12

// app/android/app/build.gradle
versionCode: 239 → 240
archivesBaseName: "LingoTune-v5.8.11" → "LingoTune-v5.8.12"

// app/lib/app_info.dart
static const String version     = '5.8.11' → '5.8.12'
static const String versionCode = '239'   → '240'
+ 1 строка в features


// 🔎 КОРНЕВАЯ ПРИЧИНА
// ================================================
// «В плеере не играет песня одна по кругу: устанавливаю режим игры по
// кругу одной песни — но она не играет» (репорт от 10.10.2026).
//
// LoopMode.one был единственным режимом БЕЗ страховки завершения:
//
// 1) AudioService._onSongCompleted при loop-one делал РАННИЙ return —
//    onSongComplete экрана не вызывался вообще → completion watchdog
//    PlayerScreen никогда не вооружался. Единственным перезапуском был
//    _restartLoopOne хендлера (seek(0)+play с 4 ретраями).
// 2) Ловушка just_audio: play() на плеере в состоянии completed — ТИХИЙ
//    no-op (playing=true переживает completed, звука нет; об этом же
//    прямо писалось в корневых причинах v5.8.11: «на completed обычный
//    play() трек не перезапускает»). Любой путь, который заканчивался
//    голым play() на completed (провалившийся рестарт, kick study после
//    зависшего setFilePath, play после снятия залипшей call-паузы) —
//    означал вечную тишину до ручных стоп+плей.
// 3) Study-режим: детектор study (onStudyCompleted → _playSong(current)
//    — полная перезагрузка) и сырой _restartLoopOne хендлера ЗАПУСКАЛИСЬ
//    ОДНОВРЕМЕННО и гонялись за одним плеером: сырой play() играл «голую»
//    песню поверх остановленной сессии, seek-натыды ломали перезагрузку.
//    Если перезагрузка спотыкалась (setFilePath-таймаут после TTS-
//    хендоффа), kick-цикл долбил play() в completed → study навсегда
//    уходил в паузу через segment-watchdog («внешняя пауза»).
// 4) onLoopOneRestartFailed форсил _playSong, но при _isSongLoading=true
//    перезагрузка молча отбрасывалась БЕЗ ретрая — loop-one замирал.


// 🔁 ФИКС 1: COMPLETION WATCHDOG ДЛЯ LOOP-ONE
// ================================================
// AudioService._onSongCompleted больше не делает ранний return: экран
// получает событие завершения ВСЕГДА. В PlayerScreen.onSongComplete
// добавлена ветка LoopMode.one: сам рестарт по-прежнему делают хендлер
// (_restartLoopOne) или study (onStudyCompleted → _playSong), а watchdog
// (~4 с) — страховочная сеть:
//   • не completed → рестарт/перезагрузка состоялись (seek снял
//     completed): позиция двигается — пост стихаем; зомби (playing,
//     позиция замерла) — ждём ретраи хендлера, потом полная перезагрузка;
//   • completed и не играет → пауза на доигравшей песне (call-ветка выше
//     уже отработала звонки) — намерение пользователя, стихаем;
//   • completed и играет → классический no-op trap → ПОЛНАЯ ПЕРЕЗАГРУЗКА
//     песни (_playSong: перезагружает трек + чисто рестартует study).
// Лимит force-перезагрузок — 5 на эпизод завершения (сбрасывается на
// каждом новом completed), чтобы заклинивший плеер не долбился вечно.
// Существующие call- и user-pause-ветки работают ДО loop-one ветки:
// звонок/пауза пользователя уважаются как раньше (включая самолечение
// v5.8.8 залипших пауз — в loop-one оно тоже теперь доезживает).


// 🤝 ФИКС 2: РЕСТАРТ LOOP-ONE БОЛЬШЕ НЕ ДРАЛСЯ СО STUDY
// ================================================
// Новый колбэк BackgroundAudioHandler.isStudySessionActive (wired в
// PlayerScreen._initBackgroundAudio, снимается в dispose). При активной
// study-сессии хендлер НЕ запускает сырой seek(0)+play: переходом владеет
// onStudyCompleted экрана — полная перезагрузка _playSong + чистый
// рестарт study с строки 0. Если study-детектор умер — догоняет watchdog
// из фикса 1 (completed && playing → force reload).
// Дополнительно _restartLoopOne теперь абортится при активной call-паузе
// (не играет музыку поверх рингтона; переход догоняют call-машина +
// watchdog).


// ▶️ ФИКС 3: PLAY() НА ДОИГРАВШЕЙ ПЕСНЕ БОЛЬШЕ НЕ МОЛЧИТ
// ================================================
// BackgroundAudioHandler._seekToStartIfCompleted(): play() и
// playFromStudy() при processingState == completed сначала делают
// seek(Duration.zero) (таймаут 1 с, best-effort) — тот самый no-op trap.
// Покрывает: кнопку play (FAB / lock-screen / уведомление / мини-плеер),
// авто-resume после звонка/снятой залипшей паузы, kick study. Раньше в
// этих точках требовался «стоп, потом плей».


// ⏳ ФИКС 4: РЕТРАЙ LOOP-ONE ПРИ ЗААНЯТОЙ ЗАГРУЗКЕ
// ================================================
// onLoopOneRestartFailed: если _playSong отброшен из-за идущей загрузки
// (_isSongLoading), перезагрузка переносится на 1.5 с — и выполняется,
// если плеер всё ещё completed (раньше — молчаливый dead-end навсегда).


// ✅ ПРОВЕРКИ
// ================================================
// flutter analyze: 231 info/warning — все существовали до релиза, 0 ошибок
// flutter test: 39/39 passed
// Сборка release APK: build_apk_v5.7.4.ps1 → builds\LingoTune-v5.8.12.apk


// 📁 ИЗМЕНЁННЫЕ ФАЙЛЫ
// ================================================
// app/lib/services/audio_service.dart
//   - _onSongCompleted: убран ранний return для LoopMode.one (+комментарий)
// app/lib/services/background_audio_handler.dart
//   - isStudySessionActive (новый колбэк), isRestartingLoopOne (новый геттер)
//   - completion-листенер: skip сырого рестарта при активной study-сессии
//   - _restartLoopOne: аборт при активной call-паузе
//   - _seekToStartIfCompleted (новый) + вызовы в play() и playFromStudy()
// app/lib/screens/player_screen.dart
//   - _loopOneForceReloads/_loopOneForceReloadLimit (новые поля)
//   - _armCompletionWatchdog: ветка LoopMode.one (v5.8.12)
//   - onSongComplete: ветка LoopMode.one — arm watchdog + сброс счётчика
//   - onLoopOneRestartFailed: ретрай через 1.5 с при _isSongLoading
//   - _initBackgroundAudio: wiring isStudySessionActive; dispose: снятие
// app/lib/app_info.dart, app/pubspec.yaml, app/android/app/build.gradle
//   - версия 5.8.12 / versionCode 240
