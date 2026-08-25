// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.1
// ================================================
// ПАТЧ-РЕЛИЗ: два бага реального использования на заблокированном телефоне —
// пропадание перевода (TTS) после звонка и пауза при отключении наушников.
// Дата: 25.08.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.0 → 5.8.1

// app/android/app/build.gradle
versionCode: 228 → 229
archivesBaseName: "LingoTune-v5.8.0" → "LingoTune-v5.8.1"

// app/lib/app_info.dart
static const String version    = '5.8.0' → '5.8.1';
static const String versionCode = '228'   → '229';


// 🔴 БАГ №1: ПОСЛЕ ЗВОНКА ПЕРЕВОД (TTS) МОЛЧИТ ДО КОНЦА ТЕКУЩЕЙ ПЕСНИ
// ================================================
// Симптом: на заблокированном телефоне в режиме обучения (говорит перевод на
// русском) входящий звонок отрабатывает корректно (пауза/возобновление), но
// перевод больше НЕ звучит до конца текущей песни — играют только сегменты.
// На следующей песне перевод снова работает.
//
// Корневые причины (каскад из 2 стадий):
//   1) ПЕРВЫЙ speak ПОСЛЕ ОТБОЯ ВИСНЕТ. Аудиосессия деактивирована телефонией,
//      и:
//      • OfflineTtsEngine: `setFilePath`/`play()` без таймаутов и БЕЗ
//        реактивации сессии — just_audio-фьючерсы висят вечно (тот же
//        zombie-класс, что документирован для плеера песни), completer
//        завершается только по processingState.completed, который не приходит;
//      • SystemTtsEngine: зарегистрированы только completion/error handler —
//        фраза, ОТМЕНЁННАЯ потерей фокуса (звонком), не порождает ни одного
//        события → completer висит вечно.
//   2) WATCHDOG ГАСИТ TTS НА ВСЮ СЕССИЮ. `_speak()` имеет спасательный
//      timeout 5–12с, который по одному зависанию вызывал
//      setSpeakDisabled(true) — НАВСЕГДА до конца сессии. Сегменты при этом
//      играют (их спасает zombie-kick), перевод молчит. Сброс флага есть
//      только в _ensureTtsReady → на следующей песне всё «чудом» лечилось.
//
// Исправления (эшелонированная защита):
//   • study_mode_service.dart — resumeSession(): сброс _speakDisabled (если
//     язык доступен) + обнуление счётчика неудач — watchdog мог сработать ещё
//     ВО ВРЕМЯ звонка, теперь переводу даётся второй шанс в ЭТОЙ же песне.
//   • study_mode_service.dart — _speak(): watchdog отключает TTS только после
//     2 ПОДРЯД зависаний (_ttsFailStreak), а не после первого; успешный speak
//     сбрасывает счётчик. Единичный транзиентный сбой больше не лишает
//     перевода всю песню.
//   • tts/offline_tts_engine.dart — speak(): перед воспроизведением
//     реактивируется аудиосессия (AudioSession.setActive(true) с timeout 1с —
//     паттерн _kickPlaybackAsync), setFilePath/play обёрнуты в timeout
//     (3с/1с); при таймауте/ошибке _onPlaybackDone() развязывает completer и
//     чистит WAV/плеер. Это устраняет саму причину зависания.
//   • tts/system_tts_engine.dart — initialize(): добавлен setCancelHandler
//     (отменённая фраза завершает completer); speak(): проверка результата
//     flutter_tts.speak (при != 1 completion-события не будет — завершаем
//     сразу).


// 🔴 БАГ №2: ОТКЛЮЧЕНИЕ НАУШНИКОВ — ПЕСНЯ ИГРАЕТ В ДИНАМИКЕ ВМЕСТО ПАУЗЫ
// ================================================
// Симптом: выдёргиваешь наушники — музыка продолжается в динамике. Ожидалась
// пауза.
//
// Корневая причина: приложение слушало только audio_session.
// becomingNoisyEventStream, но audio_session регистрирует нативный receiver
// на ACTION_AUDIO_BECOMING_NOISY ТОЛЬКО пока держит audio focus — и снимает
// его при каждой деактивации сессии. Приложение регулярно деактивирует сессию
// (TTS-хендофф режима обучения, zombie-recovery, setActive(false)), плюс
// событие игнорировалось при залипшем _pausedForCall. В момент выдёргивания
// наушников receiver'а просто НЕТ → событие некому поймать.
//
// Исправление: СОБСТВЕННЫЙ НАТИВНЫЙ ДЕТЕКТОР (вне зависимости от audio focus):
//   • BecomingNoisyPlugin.kt (NEW) — EventChannel `lingotune/becoming_noisy`,
//     BroadcastReceiver на ACTION_AUDIO_BECOMING_NOISY (на SDK 33+ — с флагом
//     RECEIVER_NOT_EXPORTED, это защищённый системный broadcast). Receiver
//     живёт, пока Dart подписан — независимо от фокуса. Регистрация в
//     MainActivity рядом с PhoneCallPlugin.
//   • becoming_noisy_service.dart (NEW) — Dart-обёртка (singleton, broadcast
//     stream, start()/stop()), зеркало PhoneCallService.
//   • background_audio_handler.dart — подписка в _initAudioSession() +
//     _handleBecomingNoisy():
//       - гейт «реально что-то звучит» (playing || wasPlayingRecently) —
//         покрывает ложные noisy при смене аудио-маршрута во время звонка
//         (защита v5.7.4 сохранена);
//       - сначала onBecomingNoisy-колбэк экрана (study сам ставит паузу через
//         pauseSession — стоп TTS + drain kick-цикла);
//       - при активном звонке — только _systemPause (не портим авто-resume);
//       - иначе обычный pause() (обновляется уведомление).
//     Подписка audio_session.becomingNoisyEventStream остаётся дублирующим
//     fallback (пауза идемпотентна). Нативная подписка снимается только в
//     dispose() handler'а, НЕ в stop() — иначе после остановки/повторного
//     запуска воспроизведения детектор снова терялся бы.
//   • player_screen.dart — onBecomingNoisy: в study mode пауза тем же путём,
//     что кнопка FAB (pauseSession); колбэк обнулён в dispose.


// ✅ ТЕСТЫ И АНАЛИЗ
// ================================================
// flutter analyze: 0 ошибок, НОВЫХ предупреждений нет (163 предсуществующих
// warning/info не тронуты — unused imports/elements, deprecated withOpacity).
// flutter test: 15/15 проходят (существующий набор; нативные каналы
// unit-тестами не покрываются).


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/services/study_mode_service.dart       — Б1: сброс _speakDisabled в resumeSession, streak-политика watchdog (_ttsFailStreak)
// app/lib/services/tts/offline_tts_engine.dart   — Б1: реактивация аудиосессии + timeout setFilePath/play + импорт audio_session
// app/lib/services/tts/system_tts_engine.dart    — Б1: setCancelHandler + проверка результата speak
// app/android/.../BecomingNoisyPlugin.kt         — Б2: NEW (нативный noisy-детектор)
// app/android/.../MainActivity.kt                — Б2: регистрация плагина
// app/lib/services/becoming_noisy_service.dart   — Б2: NEW (Dart-обёртка)
// app/lib/services/background_audio_handler.dart — Б2: onBecomingNoisy-колбэк, нативная подписка, _handleBecomingNoisy, очистка в dispose
// app/lib/screens/player_screen.dart             — Б2: study-обработка onBecomingNoisy + сброс в dispose
// app/lib/app_info.dart                          — version 5.8.1 + feature-строки
// app/pubspec.yaml                               — version 5.8.1
// app/android/app/build.gradle                   — versionCode 229, archivesBaseName v5.8.1
// CHANGELOG_v5.8.1.dart                          — этот файл (NEW FILE)
