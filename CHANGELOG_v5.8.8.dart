// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.8
// ================================================
// ФИКС-РЕЛИЗ: после сброса звонка или beep'а уведомления (в голосовом режиме,
// на заблокированном экране, по Bluetooth) песня доигрывала до конца — а
// следующая сама не включалась; спасали только ручные пауза+play, и так после
// КАЖДОГО прерывания («потом по одной играло»). Второй симптом того же корня:
// перевод (TTS) замолкал после первого звонка до конца песни.
// Дата: 17.09.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.7 → 5.8.8

// app/android/app/build.gradle
versionCode: 235 → 236
archivesBaseName: "LingoTune-v5.8.7" → "LingoTune-v5.8.8"

// app/lib/app_info.dart
static const String version     = '5.8.7' → '5.8.8';
static const String versionCode = '235'   → '236';
+ 2 строки в features


// 🐛 ФИКС №1 (ГЛАВНЫЙ): ЗАЛИПШИЙ АВТОПЕРЕХОД ЛЕЧИТ СЕБЯ САМ
// ================================================
// Симптом (v5.8.7, телефон заблокирован, BT-наушники, голосовой режим):
//   • Случай 1: входящий звонок → сброс → перевод замолчал, песня доиграла —
//     следующая не включилась. Ручные стоп+play помогали. Только при ПЕРВОМ
//     звонке за сессию, дальше звонки обрабатывались чисто.
//   • Случай 2: ~час ровного прослушивания → пришло сообщение → песня
//     доиграла до конца → тишина; дальше «по одной» — каждая следующая
//     только после ручных пауза+play.
//
// Общий корень: после прерывания study-сессия залипала в «паузе»
// (_isUserPaused), при этом плеер ПРОДОЛЖАЛ играть — ин-флайтовый play()
// kick-цикла приземлялся позже 250-мс re-pause (гонка kick vs pauseSession).
// Итог: TTS молчит, детекторы завершения убиты, песня доигрывает →
// onSongComplete → guard (study активен) → _armCompletionWatchdog, который
// при isUserPaused/isPausedForCall/_studyPausedForCall РЕАРМИЛСЯ БЕСКОНЕЧНО
// и никогда не стрелял. Ручной play доходил до onUserPlay → resumeSession —
// потому и лечило. Первый BT-звонок — самый шумный (AVRCP/noisy/SCO-гонки),
// дальше маршрут устаканивается → «только первый раз».
//
// Исправление (player_screen.dart, _armCompletionWatchdog + новые
// _canSelfHealCompletion/_selfHealStuckCompletion):
//   • Счётчик последовательных «грязных» реармов _watchdogStuckRearms
//     (сбрасывается при смене песни / нормальном срабатывании).
//   • Call-ветка (isPausedForCall/_studyPausedForCall): после 5 реармов
//     (~20 с) при подтверждённо свободной линии → самолечение.
//   • User-pause-ветка: после 8 реармов (~32 с), И только если песня УЖЕ
//     completed — пауза при доигравшей песне бессмысленна как «вернуться
//     позже», это именно гонка прерывания; настоящую паузу не перебиваем.
//   • _canSelfHealCompletion: нативный детектор PhoneCallService слушает И
//     подтверждает idle. Без детектора не лечим — иначе нельзя отличить
//     залипший beep от реального разговора (музыка в трубку).
//   • _selfHealStuckCompletion: clearStaleCallPause() (фикс №2), сброс
//     _studyPausedForCall/_studyWasAudibleBeforeCall, форс _playNextSong() —
//     _playSong чисто остановит и перезапустит study на новой песне (TTS
//     вернётся через _ensureTtsReady).


// 🐛 ФИКС №2: ЗАЛИПШАЯ CALL-ПАУЗА (BEGIN БЕЗ END)
// ================================================
// Симптом: beep уведомления/сообщения (androidWillPauseWhenDucked=true
// превращает duck в полное interruption) давал begin, парный end не приходил
// (или эхо отбоя приходило позже 5-с окна дебаунса) → _pausedForCall висел
// вечно: kick-цикл прерывался, play() не доходил до onUserPlay (гейт
// !_pausedForCall), watchdog реармился бесконечно.
//
// Исправление (background_audio_handler.dart):
//   • _callPauseStartedAt фиксируется в _handleCallPause, сбрасывается в
//     _handleCallResume.
//   • Новый clearStaleCallPause(): пауза висит > 30 с И PhoneCallService
//     слушает и подтверждает idle → лог + штатный _handleCallResume() (он сам
//     вызовет onPlaybackResumed → resumeSession). Вызывается из
//     самолечения watchdog'а (фикс №1).


// 🐛 ФИКС №3: ГОНКА «ПОЗДНИЙ play() ПРОТИВ ПАУЗЫ» ЗАКУПОРЕНА
// ================================================
// Первопричина «песня играет на запаузненной сессии»: drain kick-цикла ждал
// максимум 3 с, активная попытка kick'а живёт до ~2.4 с, а контрольный
// re-pause был один, через 250 мс — ин-флайтовый play() приземлялся ПОЗЖЕ и
// воскресил песню при _isUserPaused=true (именно это состояние потом ломало
// автопереход — см. фикс №1).
//
// Исправление (study_mode_service.dart, _pauseSessionInner):
//   • После 250-мс re-check добавлены отложенные контрольные точки ~1 с и
//     ~3 с: пока хвост паузы актуален (gen == _pauseGen) и плеер играет —
//     сырой re-pause. После resume (gen не совпадает) выходим, не трогая
//     новый runner.
//   • Лог-метка: '🔒 StudyModeService: late play-race re-pause'.


// 🐛 ФИКС №4: ЗАВИСАЮЩИЙ СИСТЕМНЫЙ TTS НЕ МУТИТ ПЕРЕВОД НАВСЕГДА
// ================================================
// Симптом: «перевод перестал говорить» после звонка — до конца песни. После
// звонка/beep'а системный TTS-сервис переподключается; param-вызовы
// (setLanguage/setSpeechRate/setPitch/setVolume) и сам platform speak() НЕ
// имели таймаута → speak вис на param-шаге до study-watchdog, один инцидент
// дважды набивал _ttsFailStreak → setSpeakDisabled(true) → тишина до конца
// трека (self-healing cooldown v5.8.5 не спасал, если кулдаун продлевался).
//
// Исправление (system_tts_engine.dart, speak + новый _safeParam):
//   • Все param-вызовы и platform speak() обёрнуты в .timeout(3 с):
//     param-таймаут → просто идём дальше; speak-таймаут → completer
//     завершается «неудачей», стрик набирается максимум одной ошибкой.
//   • Самолечение watchdog'а (фикс №1) дополнительно сбрасывает защёлку на
//     следующей песне (resumeSession/_ensureTtsReady уже умели).


// ✅ ТЕСТЫ И АНАЛИЗ
// ================================================
// flutter analyze: 0 ошибок, новых предупреждений нет.
// flutter test: все проходят.
// Метки для проверки на устройстве (adb logcat):
//   '🔧 PlayerScreen: completion watchdog SELF-HEAL' /
//   '📞 BackgroundAudioHandler: stale call-pause cleared' /
//   '🔒 StudyModeService: late play-race re-pause' /
//   '⚠ SystemTtsEngine: <param> timed out'
// Сценарии: (1) BT + локскрин + голосовой режим → входящий звонок → сброс →
// дождаться конца песни → следующая должна включиться сама (допустимо до
// ~20 с; ранее — только ручные пауза+play); (2) то же с принятым звонком;
// (3) длинное прослушивание → сообщение в середине песни → конец песни →
// авто-переход; (4) настоящая пауза (FAB/локскрин) в середине песни →
// паузу НЕ перебивает никакой watchdog, play возобновляет как раньше;
// (5) во время РЕАЛЬНОГО разговора ничего не форсится (детектор не idle).


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/screens/player_screen.dart              — самолечение watchdog: _watchdogStuckRearms, пороги 5/8, _canSelfHealCompletion, _selfHealStuckCompletion
// app/lib/services/background_audio_handler.dart  — _callPauseStartedAt, _staleCallPauseTimeout(30с), clearStaleCallPause()
// app/lib/services/study_mode_service.dart        — отложенные re-pause контрольные точки (~1с/~3с) в _pauseSessionInner
// app/lib/services/tts/system_tts_engine.dart     — _safeParam + таймаут platform speak() (3с)
// app/lib/app_info.dart                           — version 5.8.8 + 2 строки фич
// app/pubspec.yaml                                — version 5.8.8
// app/android/app/build.gradle                    — versionCode 236, archivesBaseName v5.8.8
// docs/CHANGELOG.md                               — запись v5.8.8
// AGENTS.md                                       — версия, Track completion (самолечение), Zombie-state recovery (clearStaleCallPause)
// CHANGELOG_v5.8.8.dart                           — этот файл (NEW FILE)
