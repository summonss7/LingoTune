// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.11
// ================================================
// ФИКС-релиз: долечены залипания режима обучения после уведомлений
// и «глючит по-чёрному» при включении прослушивания после долгого
// простоя приложения в памяти (Bluetooth + заблокированный телефон).
// Дата: 24.09.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.10 → 5.8.11

// app/android/app/build.gradle
versionCode: 238 → 239
archivesBaseName: "LingoTune-v5.8.10" → "LingoTune-v5.8.11"

// app/lib/app_info.dart
static const String version     = '5.8.10' → '5.8.11';
static const String versionCode = '238'   → '239';
+ 2 строки в features


// 🔎 КОРНЕВЫЕ ПРИЧИНЫ (найдены чтением кода, подтверждены)
// ================================================
// Репро A: beep уведомления при активном прослушивании (BT, блокировка)
//   → голос (TTS) умирает среди песни, песня доигрывает, всё замирает,
//   спасает только СТОП потом ПЛЕЙ (пауза+плей недостаточно).
// Репро B: приложение НЕ закрыто, долго висит в памяти → включаю
//   прослушивание → «глючит по-чёрному очень сильно».
//
// 1) Beep уведомления = audio-focus interruption begin БЕЗ парного end
//    (audio_session держит focus-listener только пока приложение держит
//    фокус, а TTS-хендофф/zombie-recovery регулярно деактивируют сессию —
//    об этом же прямо комментарий в коде про becomingNoisy). Флаг
//    _pausedForCall залипает: play() не доходит до onUserPlay
//    (resumeSession недостижим), kick-циклы абортятся, watchdog
//    автоперехода реармится вечно. На completed обычный play() трек не
//    перезапускает — отсюда «именно стоп, потом плей».
// 2) Самолечение v5.8.8 (clearStaleCallPause + watchdog SELF-HEAL)
//    жёстко требовало PhoneCallService (READ_PHONE_STATE): разрешение не
//    выдано/отозвано, детектор молча умер после заморозки приложения
//    ROM-ом, sticky-состояние не пришло — самолечение отключено НАВСЕГДА.
// 3) Гонка порогов: watchdog самолечится на ~24 с, а clearStaleCallPause
//    требовал 30 с залипания → beep ближе 6 с к концу песни: флаг НЕ
//    снимался, а _playNextSong() уже запускался → следующая песня играла
//    БЕЗ ГОЛОСА (kick study прерывался по isPausedForCall).
// 4) У TTS не было канала «неудачи»: зависший platform-вызов speak()
//    завершался по 3 с таймауту как… УСПЕХ (стринг сбоев сбрасывался) —
//    тишина «успешно» жила до конца песни. Исключение setLanguage лочило
//    _langAvailable=false («пробы бессмысленны»). _ttsFailStreak
//    переносился между песнями (стринг=1 + первый сбой = мгновенная
//    защёлка тишины).
// 5) Долгий простой: Android отвязывает системный TTS-сервис, ROM может
//    заморозить приложение (нативные детекторы умирают молча). На resume
//    НИКТО не перепроверял TTS/детектор/залипшие флаги — только сброс
//    корректора позиции. _ensureTtsReady при ошибке молча лочил
//    segments-only на всю сессию («включаю после простоя — тишина»).
// 6) Watchdog: ветка «playing=true» делала no-op БЕЗ реарма — зомби
//    (playing, позиция замерла, completed не наступает) молча убивал
//    watchdog. LoopMode.one вообще без watchdog (onSongComplete ранний
//    return) — отказ _restartLoopOne = вечная заморозка без страховки.


// 📞 ФИКС 1: AUDIO-MODE ФОЛБЭК БЕЗ РАЗРЕШЕНИЙ (AudioManager.getMode)
// ================================================
// Новые файлы:
//   • android/.../AudioModePlugin.kt — MethodChannel "lingotune/audio_mode",
//     getMode() → normal / ringtone / in_call / in_communication /
//     call_other (редкие call-режимы консервативно «занято»). Разрешений
//     НЕ требует, видит и VoIP-звонки, которые TelephonyManager не видит.
//   • lib/services/audio_mode_service.dart — AudioModeService.instance:
//     isLineIdle() (Future<bool?>, таймаут 2 с, TTL-кэш 2 с), синхронный
//     lastKnownLineIdle для горячего пути, invalidateCache().
// Регистрация в MainActivity.kt рядом с PhoneCallPlugin.
//
// Применение (детектор idle ИЛИ аудио-линия NORMAL):
//   • BackgroundAudioHandler._confirmedNoCall() — единая проверка;
//   • clearStaleCallPause() — теперь async, без жёсткой зависимости
//     от PhoneCallService;
//   • PlayerScreen._canSelfHealCompletion() — теперь async, тот же ИЛИ;
//   • дебаунс эха в _handleCallPause — синхронный кэш (греется на
//     resume / в _handleCallResume / watchdog'ом / pre-flight play).
// «Не знаем» (канал недоступен) — консервативно «звонок возможен»,
// музыку посреди возможного разговора не форсим.


// ▶️ ФИКС 2: PRE-FLIGHT В play() — «ВКЛЮЧАЮ, А ОНО ГЛЮЧИТ»
// ================================================
// BackgroundAudioHandler.play(): если _pausedForCall и _confirmedNoCall()
// → _clearCallPauseFlags() ДО воспроизведения (снимает флаги, штампует
// _lastResumeAt против эха, греет кэш аудио-линии; БЕЗ onPlaybackResumed —
// единый resumeSession запустит штатный onUserPlay, двойной вызов мог
// запустить два study-runner'а). Реальный звонок (детектор/ringtone/
// in_call) паузу сохраняет.
// PlayerScreen.onUserPlay: сбрасывает устаревшие _studyPausedForCall /
// _studyWasAudibleBeforeCall («пользователь хочет слушать»).


// ⏱️ ФИКС 3: ГОНКА ПОРОГОВ САМОЛЕЧЕНИЯ
// ================================================
// _staleCallPauseTimeout: 30 с → 20 с (обязан быть НИЖЕ ~24 с watchdog'а).
// _selfHealStuckCompletion(): если clearStaleCallPause() отказал (возраст)
// → forceClearCallPauseIfNoCall() — принудительное снятие при подтверждённо
// свободной линии. Иначе флаг оставался висеть и kick study на СЛЕДУЮЩЕЙ
// песне прерывался (голос не возвращался).


// 🗣️ ФИКС 4: КАНАЛ «НЕУДАЧИ» TTS + ВОЗВРАЩЕНИЕ ГОЛОСА
// ================================================
// Контракт TtsEngine.speak изменён: genuine-сбой движка завершает Future
// ОШИБКОЙ (документация интерфейса обновлена). Наши собственные
// stop()-прерывания ошибкой НЕ считаются (TtsCoordinator._interruptCurrent
// завершает нормально — false strike не даёт; CarAlert уже в try-catch).
//   • SystemTtsEngine.speak(): platform-таймаут → _tts.stop() (2 с бокс) +
//     completer.completeError; result==0 → completeError; поздний
//     completion брошенного выговора съедается флагом _dropNextCompletion
//     (раньше мог закрыть completer СЛЕДУЮЩЕЙ фразы → фальшивый успех и
//     ранний переход строки; брошенная фраза могла прозвучать поверх).
//   • _handleError движка → completeError (раньше — успех).
//   • setLanguage: исключение платформенного вызова (переподключение
//     сервиса) ≠ «язык недоступен» — доступность НЕ лочится в false;
//     лочится только честное «нет голосов».
//   • StudyModeService._speak(): catch → engineFailed → инкремент стринга
//     (как watchdog-таймаут) → срабатывает существующий cooldown-механизм
//     (20→120 с, проба в той же песне) — голос ВОЗВРАЩАЕТСЯ сам.
//   • StudyModeService.stop(): _ttsFailStreak = 0 (стринг не переносится
//     на следующую песню).


// 🔄 ФИКС 5: РЕАКТИВАЦИЯ ПОСЛЕ ДОЛГОГО ПРОСТОЯ (репро B)
// ================================================
//   • TtsEngine.reset() (дефолт no-op) + SystemTtsEngine.reset():
//     пересоздаёт FlutterTts (свежий bind к переподключённому сервису),
//     заново ставит handlers/движок/язык; _tts стал не-final.
//   • TtsCoordinator.revalidateAfterIdle(): health-probe (setLanguage с
//     таймаутом 4 с); завис/упал → engine.reset() (15 с бокс). Офлайн-
//     движок от системного сервиса не зависит — сразу true.
//   • PlayerScreen.didChangeAppLifecycleState: _wentToBackgroundAt
//     (первый штамп серии paused/inactive); простой > 5 мин →
//     _revalidateAfterIdle(): TTS probe+reset, перезапуск телефонного
//     детектора если подписка умерла, clearStaleCallPause для давнего
//     beep'а, invalidateCache + прогрев кэша аудио-линии.
//   • _ensureTtsReady: checkLanguageAvailable под таймаутом 6 с; «не
//     доступен» → revalidateAfterIdle() (reset движка) и повторная
//     проверка — раньше transient-состояние молча лочило segments-only
//     на всю сессию.


// ⏰ ФИКС 6: WATCHDOG — ЗОМБИ-ВЕТКА И LOOP-ONE
// ================================================
//   • Финальная ветка completion watchdog'а (playing=true): теперь реарм
//     с контролем позиции (_watchdogLastPosMs) — два подряд тика без
//     движения (≈8 с) → форс следующей песни. Раньше безусловный no-op
//     без реарма навсегда убивал watchdog при «playing, позиция замерла».
//   • BackgroundAudioHandler.onLoopOneRestartFailed (новый колбэк):
//     _restartLoopOne исчерпал попытки / упал → PlayerScreen форсит
//     _playSong(_currentSong) (полная перезагрузка + чистый перезапуск
//     study). Loop-one — единственный режим без completion watchdog'а,
//     «сдался молча» означал вечную заморозку. Колбэк снимается в dispose.


// ✅ ТЕСТЫ И АНАЛИЗ
// ================================================
// flutter analyze: 0 ошибок (231 info/warning — все существовали до
// релиза; в изменённых файлах новых замечаний нет).
// flutter test: 39 тестов, все зелёные.
// Проверка на устройстве:
//   A) BT + блокировка + режим обучения → сообщения себе в середине песни
//      и за ~5 с до конца → автопереход сам в течение ~25 с, голос
//      возвращается максимум через один cooldown-цикл (20 с).
//   B) Приложение в памяти 30-60 мин (экран выкл, BT), за это время
//      пара сообщений → открыть, включить прослушивание → голос с первой
//      строки, автопереход работает, стоп+плей не требуется.


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/android/.../AudioModePlugin.kt               — NEW: getMode() MethodChannel
// app/android/.../MainActivity.kt                  — регистрация AudioModePlugin
// app/lib/services/audio_mode_service.dart         — NEW: AudioModeService
// app/lib/services/background_audio_handler.dart   — _confirmedNoCall, async clearStaleCallPause,
//                                                    forceClearCallPauseIfNoCall, _clearCallPauseFlags,
//                                                    play() pre-flight, порог 20 с, дебаунс эха с кэшем,
//                                                    прогрев кэша на resume, onLoopOneRestartFailed
// app/lib/screens/player_screen.dart               — async watchdog+self-heal, зомби-ветка с позицией,
//                                                    _canSelfHealCompletion (ИЛИ аудио-линия),
//                                                    force-clear гонки порогов, onUserPlay сброс флагов,
//                                                    _revalidateAfterIdle + lifecycle-хук, _ensureTtsReady
//                                                    retry, onLoopOneRestartFailed wiring
// app/lib/services/study_mode_service.dart         — engineFailed-стрик, _ttsFailStreak=0 в stop()
// app/lib/services/tts/tts_engine.dart             — контракт speak() + reset() (дефолт no-op)
// app/lib/services/tts/system_tts_engine.dart      — ошибки вместо «успеха», _dropNextCompletion,
//                                                    reset(), setLanguage transient, mutable _tts
// app/lib/services/tts_coordinator.dart            — catchError прокидывает ошибку, revalidateAfterIdle()
// app/lib/app_info.dart                            — version 5.8.11 + 2 строки фич
// app/pubspec.yaml                                 — version 5.8.11
// app/android/app/build.gradle                     — versionCode 239, archivesBaseName v5.8.11
// docs/CHANGELOG.md                                — запись v5.8.11
// AGENTS.md                                        — версия + Audio/Study/TTS-разделы
// CHANGELOG_v5.8.11.dart                           — этот файл (NEW FILE)
