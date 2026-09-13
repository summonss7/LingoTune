// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.5
// ================================================
// ФИКС-РЕЛИЗ: (1) голос режима обучения замолкал до конца песни после звука
// сообщения/уведомления; (2) после телефонного звонка плеер глючил и мог не
// возобновить воспроизведение.
// Дата: 13.09.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.4 → 5.8.5

// app/android/app/build.gradle
versionCode: 232 → 233
archivesBaseName: "LingoTune-v5.8.4" → "LingoTune-v5.8.5"

// app/lib/app_info.dart
static const String version     = '5.8.4' → '5.8.5';
static const String versionCode = '232'   → '233';
+ 2 строки про фиксы в features


// 🐛 ФИКС №1: ЗВУК СООБЩЕНИЯ ГЛУШИЛ ПЕРЕВОД ДО КОНЦА ПЕСНИ
// ================================================
// Симптом: телефон заблокирован, идёт режим обучения. Приходит SMS — песня
// встаёт на паузу, потом играет дальше, но голос перевода (TTS) МОЛЧИТ до
// конца песни; на следующей песне включается. Обычно только ПЕРВЫЙ раз,
// дальнейшие сообщения — без последствий.
//
// Корневая причина (остаток фикса v5.8.1 — тот лечил только звонки):
//   • Из-за androidWillPauseWhenDucked=true звук уведомления приходит как
//     ПОЛНОЦЕННОЕ прерывание: pauseSession(forCall) корректно стопит TTS,
//     interruption-end (~1-2с) → resumeSession запускает runner.
//   • «Второй шанс» из v5.8.1 (resumeSession сбрасывает _speakDisabled)
//     срабатывает ВХОЛОСТУЮ: в момент resume защёлка ещё НЕ выставлена —
//     она flips'ается ПОЗЖЕ, первыми зависаниями возобновлённого runner'а.
//   • Первый speak после такого прерывания может зависнуть (системный движок
//     не реактивирует аудиосессию; OEM «проглатывает» прерванную фразу без
//     completion/error/cancel; офлайн-движок: зависший stop() завешивал
//     TtsCoordinator._interruptCurrent → зависал КАЖДЫЙ следующий speak).
//   • Watchdog дважды → _speakDisabled=true — и внутри песни сброса больше
//     НЕТ: только _ensureTtsReady на следующей песне. Отсюда «молчит до
//     конца трека, на следующей включился». «Только первый раз» — следующее
//     сообщение проходит resumeSession с уже выставленной защёлкой и
//     излечивает её (v5.8.1-путь).
//
// Исправление (study_mode_service.dart + движки):
//   • Self-healing защёлка: отключение ТЕПЕРЬ ВРЕМЕННОЕ. После 2 подряд
//     зависаний TTS молчит cooldown (20с), затем _speak() делает ПРОБУ —
//     если движок ожил, речь продолжается В ТОЙ ЖЕ песне. Повторные неудачи
//     удваивают паузу (backoff 20→40→80→120с, кап). Успешная речь сбрасывает
//     backoff. Пробы НЕ делаются, если язык реально недоступен (нет голосов —
//     segments-only остаётся постоянным).
//   • resumeSession: безусловный сброс _ttsFailStreak (первый speak после
//     resume не «в одном шаге» от защёлки) + ожидание хвоста незавершённой
//     pauseSession (см. фикс №3) — сброс больше не проходит вхолостую.
//   • Таймауты 2с на stop() в SystemTtsEngine и OfflineTtsEngine._stopInternal:
//     зависший stop координатора больше не превращает ОДНО зависание в
//     гарантированную серию (усилитель, запускавший защёлку).
//
// 🐛 ФИКС №2 (сопутствующий): ГОНКА КОРОТКИХ ПЕРЕРЫВАНИЙ
// ================================================
// interruption-end мог прийти, пока pauseSession ещё дренировала kick-цикл
// (до 2с). resumeSession запускала новый runner, а «хвост» старой паузы
// гасил его _cancelSegmentAwait'ом и пере-паузил плеер → перевод и переход
// по строкам замирали до конца песни / watchdog'а.
//
// Исправление (study_mode_service.dart):
//   • pauseSession разделена на обёртку + _pauseSessionInner(gen): future
//     сохраняется в _pauseSessionFuture.
//   • resumeSession ДОЖИДАЕТСЯ этот future (таймаут 3с) перед запуском
//     runner'а; если пауза зависла дольше — инкремент генерации _pauseGen
//     останавливает хвост ДО разрушительного re-pause (хвост видит смену
//     генерации и выходит, не трогая плеер).
//   • stop() тоже инкрементирует _pauseGen — хвост паузы не может тронуть
//     runner новой песни после смены трека.


// 🐛 ФИКС №3: ПОСЛЕ ЗВОНКА ПЛЕЕР ГЛЮЧИТ И НЕ ВОЗОБНОВЛЯЕТСЯ
// ================================================
// Симптом: заблокированный экран, режим обучения, входящий звонок — плеер
// «глючит» (звук поверх рингтона / рывки) и после отбоя может не возобновить
// воспроизведение. Иногда — прочие однократные глюки.
//
// Причины и исправления (background_audio_handler.dart + сопутствующие):
//
// (a) Запоздалое ЭХО interruption-begin (главный подозреваемый «не
//     возобновляется»): нативный TelephonyManager даёт idle → мы делаем
//     полный resume → и ТОЛЬКО ПОТОМ приходит отложенный audio_session begin
//     ТОГО ЖЕ звонка → _handleCallPause беззащитно делает НОВУЮ паузу, а
//     парный end уже не приходит → плеер замер навсегда.
//     → Дебаунс: interruption-begin в пределах 5с после resume ПРИ
//       подтверждении PhoneCallService (линия idle) считается эхом и
//       игнорируется. Без детектора (нет permission / не Android) — событие
//       принимается как раньше (безопасный фолбэк).
//     → PhoneCallPlugin.kt: sticky-состояние при подписке (onListen сразу
//       шлёт текущий callState) — чинит и переподписку посреди звонка
//       (пересоздание экрана): раньше ringing/offhook пропускались.
//     → PhoneCallService: геттер current (последнее состояние линии).
//
// (b) Resume-kick сдавался навсегда: _ensureAdvancingAfterResume делал 3
//     попытки (~1.5-6с) и больше НЕ ретраил — а на части ROM in-call UI
//     возвращает аудиофокус позже нашего кика.
//     → Второй отложенный раунд через 5с (ещё 3 попытки), с гейтами: новый
//       звонок или ЯВНАЯ пауза пользователя (fresh _lastUserPauseAt) раунд
//       пропускают. Общий горизонт ~15с, ограничен.
//
// (c) Completion watchdog стрелял ВО ВРЕМЯ разговора: «stuck = !playing»
//     истинно при ЛЕГИТИМНОЙ паузе звонка → следующая песня запускалась
//     прямо посреди звонка (тот самый «глюк»).
//     → Guard: при isPausedForCall / _studyPausedForCall watchdog переносится
//       (re-arm +4с) вместо форса следующей песни.
//
// (d) Kick-цикл study боролся с паузой звонка: залетевший play() после
//     _systemPause давал ~1-2с музыки поверх рингтона.
//     → _kickPlaybackAsync прерывается (isPausedForCall) на каждой итерации
//       и после 400мс-проверки позиции; добавлен публичный геттер
//       BackgroundAudioHandler.isPausedForCall.


// ✅ ТЕСТЫ И АНАЛИЗ
// ================================================
// flutter analyze: 0 ошибок, новых предупреждений нет (предсуществующие
// warning/info не тронуты). flutter test: 25/25 проходят.
// Метки для проверки на устройстве (adb logcat | grep -E "probe|echo|WATCHDOG|kick"):
//   'TTS probe after cooldown' / 'stale interruption echo' /
//   'completion WATCHDOG: call/interruption in progress' /
//   'kick aborted (call/interruption in progress)'


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/services/study_mode_service.dart        — self-healing защёлка TTS (cooldown+backoff), pause/resume re-entrancy guard, abort kick при звонке, безусловный сброс стрика
// app/lib/services/background_audio_handler.dart  — дебаунс эха interruption-begin, isPausedForCall, resume-kick 2 раунда + гейты, _lastUserPauseAt
// app/lib/services/phone_call_service.dart        — геттер current (последнее состояние линии)
// app/android/.../PhoneCallPlugin.kt              — sticky callState при подписке
// app/lib/screens/player_screen.dart              — completion watchdog: перенос при активном звонке
// app/lib/services/tts/system_tts_engine.dart     — таймаут 2с на flutter_tts.stop()
// app/lib/services/tts/offline_tts_engine.dart    — таймаут 2с на player.stop() в _stopInternal
// app/lib/app_info.dart                           — version 5.8.5 + 2 строки фиксов
// app/pubspec.yaml                                — version 5.8.5
// app/android/app/build.gradle                    — versionCode 233, archivesBaseName v5.8.5
// docs/CHANGELOG.md                               — запись v5.8.5
// AGENTS.md                                       — разделы Study Mode / Phone calls / TTS
// CHANGELOG_v5.8.5.dart                           — этот файл (NEW FILE)
