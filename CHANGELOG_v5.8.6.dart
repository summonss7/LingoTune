// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.8.6
// ================================================
// UX+ФИКС-РЕЛИЗ: разделение кнопок плей/пауза и голосового режима +
// «пауза не работает — само играет дальше» в режиме обучения (пауза
// перебивалась механизмами самовосстановления study mode).
// Дата: 16.09.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.8.5 → 5.8.6

// app/android/app/build.gradle
versionCode: 233 → 234
archivesBaseName: "LingoTune-v5.8.5" → "LingoTune-v5.8.6"

// app/lib/app_info.dart
static const String version     = '5.8.5' → '5.8.6';
static const String versionCode = '233'   → '234';
+ 2 строки в features (разделение кнопок + фикс паузы)


// ✨ UX: РАЗДЕЛЕНИЕ КНОПОК (запрос пользователя)
// ================================================
// Было: в режиме обучения центральная FAB во время озвучки показывала иконку
// record_voice_over (мигала pause↔🎤↔play) — выглядело, будто голосовой режим
// «живёт» на кнопке плей/пауза; верхняя кнопка режима при запаузненной сессии
// молча ПЕРЕЗАПУСКАЛА её вместо выключения.
//
// Стало (player_screen.dart):
//   • FAB — ВСЕГДА транспорт: иконка только pause/play (pause, пока звучит
//     сегмент ИЛИ озвучка study; play — когда всё стоит). «Голосовой» иконки
//     на FAB больше нет; признак режима — верхняя кнопка.
//   • onPressed FAB всегда audioService.pause()/play() — ветки study нет.
//     Единый путь для FAB, мини-плеера, lock-screen и уведомления: при
//     активном study handler.pause()/play() хендоффятся в
//     pauseSession()/resumeSession() (см. фикс №1) — пауза останавливает и
//     музыку, и озвучку; play продолжает с той же строки.
//   • Верхняя кнопка режима — чистое ВКЛ/ВЫКЛ: активная сессия выключается
//     в любом состоянии, включая паузу (раньше пауза + кнопка = рестарт).


// 🐛 ФИКС №1 (КОРНЕВОЙ): ПАУЗА «МИМО FAB» НЕ ДХОДИЛА ДО STUDY
// ================================================
// Симптом: в режиме обучения пауза с lock-screen/уведомления/мини-плеера
// срабатывала на 10–20 секунд, потом плейбек сам продолжался («не могу
// нажать паузу — автоматом играет дальше»). Отмечено в CHANGELOG как
// невылеченный «корневой рассинхрон».
//
// Причина: BackgroundAudioHandler.pause() паузил ТОЛЬКО плеер —
// StudyModeService об этом не знал и оставался «активен, не на паузе»:
// _segmentWatchdog (segLen+10с) решал «зомби», форсировал следующую строку,
// а _kickPlayback() снова жал play. Цикл повторялся бесконечно.
//
// Исправление (по образцу хендоффа onBecomingNoisy из v5.8.1):
//   • background_audio_handler.dart: колбэки onUserPause/onUserPlay. В
//     override pause()/play(): если нет call-паузы и колбэк вернул true —
//     handler НЕ делает собственный _systemPause/play (study сам ставит
//     плеер на паузу после дренирования kick-цикла / сам запускает runner).
//   • player_screen.dart: onUserPause → pauseSession() (стоп TTS + drain
//     kick + честная пауза с обновлением уведомления); onUserPlay на
//     запаузненной сессии → resumeSession(). Колбэки обнуляются в dispose.
//   • Разделение «пользовательское vs служебное»: новые методы
//     BackgroundAudioHandler.pauseFromStudy()/playFromStudy() и обёртки
//     AudioService.systemPause()/systemPlay(). ВСЕ внутренние вызовы study
//     (TTS-фазы runner'а, kick-цикл, финальная пауза pauseSession, stop)
//     переведены на них — служебные паузы/запуски не считаются намерением
//     пользователя и не рекурсируют в колбэки.


// 🐛 ФИКС №2: ГОНКА KICK-ЦИКЛА vs ПАУЗА (FAB «не срабатывала»)
// ================================================
// Причина: pauseSession дренировала kick-цикл с таймаутом 2с, а одна попытка
// kick'а живёт до ~2.4с (setActive 1с + play 1с + delay 400мс), и между
// проверкой флага и play() не было повторной проверки — «хвостовой» play()
// приземлялся УЖЕ ПОСЛЕ паузы и воскрешал песню; на «запаузненной» сессии
// FAB показывала play, а звук шёл.
//
// Исправление (study_mode_service.dart):
//   • Проверка !_isActive || _isUserPaused || _disposed НЕПОСРЕДСТВЕННО
//     перед play() в _kickPlaybackAsync (после setActive — окно между
//     проверкой и запуском закрыто).
//   • Таймаут дренирования kick в _pauseSessionInner 2с → 3с (покрывает
//     одну полную попытку).
//   • Контрольный re-pause: через 250мс после финальной паузы — если хвост
//     актуален (gen совпадает) и player.playing всё ещё true, сырой
//     player.pause() (in-flight play() больше не переживает паузу).


// 🐛 ФИКС №3: COMPLETION WATCHDOG ПЕРЕБИВАЛ ПАУЗУ В КОНЦЕ ПЕСНИ
// ================================================
// Поставил паузу, пока песня договаривает последние секунды → через 4с
// watchdog («stuck = !playing» — истинно при паузе!) форсировал СЛЕДУЮЩУЮ
// песню. v5.8.5 закрыл это только для звонков.
// → Guard: при активной запаузненной study-сессии watchdog переносится
//   (re-arm +4с) вместо форса; после resume study двинется сам.


// 🛡️ СТРАХОВКА: СЕГМЕНТНЫЙ WATCHDOG ОТЛИЧАЕТ ВНЕШНЮЮ ПАУЗУ ОТ ЗОМБИ
// ================================================
// При срабатывании (segLen+10с): если плеер НЕ играет, kick не активен
// (!_debugResuming) и нет call-паузы — это внешняя пауза, пришедшая мимо
// всех известных путей (ROM-специфичные media-button и т.п.) → честная
// pauseSession() вместо форсированного advance+kick (зомби-случай
// playing=true/позиция замерла — форсирует переход как раньше).


// ✅ ТЕСТЫ И АНАЛИЗ
// ================================================
// flutter analyze: 0 ошибок, новых предупреждений нет (предсуществующие
// warning/info не тронуты — сверено с HEAD через git stash).
// flutter test: 25/25 проходят.
// Метки для проверки на устройстве (adb logcat | grep -E "FAB|external|WATCHDOG|post-pause"):
//   'FAB: pressed' / 'external pause → pauseSession (study)' /
//   'external play → resumeSession (study)' /
//   'WATCHDOG — player paused externally' / 'post-pause re-check' /
//   'completion WATCHDOG: study user-paused — re-arming'
// Сценарии: (1) пауза FAB во время озвучки и во время сегмента — полная
// остановка навсегда; (2) пауза lock-screen/уведомления — то же; (3) play с
// lock-screen — продолжает с озвучкой; (4) пауза в конце песни — следующая
// не заигрывает сама; (5) верхняя кнопка — вкл/выкл в любом состоянии.


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/services/background_audio_handler.dart  — колбэки onUserPause/onUserPlay, хендофф в pause()/play(), pauseFromStudy()/playFromStudy()
// app/lib/services/audio_service.dart             — обёртки systemPause()/systemPlay()
// app/lib/services/study_mode_service.dart        — внутренние вызовы через system*, проверка перед play() в kick, drain 3с, post-pause re-check, страховка segment watchdog
// app/lib/screens/player_screen.dart              — FAB чистый транспорт + иконка, _toggleStudyMode вкл/выкл в любом состоянии, колбэки onUserPause/onUserPlay (+dispose), completion watchdog guard
// app/lib/app_info.dart                           — version 5.8.6 + 2 строки фич
// app/pubspec.yaml                                — version 5.8.6
// app/android/app/build.gradle                    — versionCode 234, archivesBaseName v5.8.6
// docs/CHANGELOG.md                               — запись v5.8.6
// AGENTS.md                                       — разделы Study Mode / Audio
// CHANGELOG_v5.8.6.dart                           — этот файл (NEW FILE)
