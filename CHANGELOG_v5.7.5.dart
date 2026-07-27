// 📋 ЛИСТ ИЗМЕНЕНИЙ v5.7.5
// ================================================
// ПАТЧ-РЕЛИЗ: исправления по результатам комплексного код-аудита
// Дата: 27.07.2026

// ✅ ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 5.7.4 → 5.7.5

// app/android/app/build.gradle
versionCode: 226 → 227
archivesBaseName: "LingoTune-v5.7.4" → "LingoTune-v5.7.5"

// app/lib/app_info.dart
static const String version    = '5.7.4' → '5.7.5';
static const String versionCode = '226'   → '227';


// 🔍 КОД-АУДИТ (33 447 строк Dart + ~30 Python-скриптов + конфиг)
// ================================================
// Найдено: 1 critical, 3 high, 5 medium, 4 low.
// Сводка аудита: docs/CHANGELOG_v5.7.5.dart (этот файл).


// 🟠 ИСПРАВЛЕНИЯ HIGH-ПРИОРИТЕТА
// ================================================

// 1. ГОНКА В КНОПКЕ PLAY/PAUSE (main.dart:357)
// ----------------------------------------------
// Раньше _togglePlayback() читал состояние через
//   `await _audioService.player.playingStream.first`
// — между await и вызовом pause()/play() состояние могло измениться
// (фоновый handler, study mode, входящий звонок), что приводило к
// инверсии/«мерцанию» кнопки.
// Исправление: используем синхронный снапшот `player.playing`.

// 2. «DATABASE IS LOCKED» ПРИ МАССОВОМ ИМПОРТЕ (database_service.dart)
// ----------------------------------------------
// Статические методы insertBatchSongs / addBatchSongsToPlaylist открывали
// СОБСТВЕННОЕ подключение к lingotune.db через openDatabase(...) параллельно
// singleton-у. На Android sqflite держит одно соединение на файл — второй
// openDatabase мог вызвать SQLITE_BUSY во время массового импорта.
// Исправление: методы переиспользуют singleton `_instance.database`
// (тот же хэндл, тот же retry-on-locked в _initDatabase).

// 3. УТЕЧКА ПАМЯТИ TtsCoordinator ПРИ HOT-RESTART (tts_coordinator.dart)
// ----------------------------------------------
// TtsCoordinator — синглтон, переживал rebuild и при hot-restart удерживал
// ~63 МБ sherpa_onnx-модели (OfflineTtsEngine) на каждой итерации разработки.
// В production не крашило (Android убивает процесс), но замедляло dev-цикл.
// Исправление: добавлен dispose() в TtsCoordinator, вызывается в
// MainScreen.dispose() после всех остальных сервисов.


// 🟡 ИСПРАВЛЕНИЯ MEDIUM
// ================================================

// 4. ЛОГИРОВАНИЕ API-ОТВЕТОВ В РЕЛИЗЕ (deepseek_api_service.dart)
// ----------------------------------------------
// Полное тело ответа DeepSeek (содержит переводы песен — приватный контент
// пользователя) логировалось через debugPrint и в релизной сборке утекало
// в logcat, доступный другим приложениям через ADB.
// Исправление: логирование полного ответа загейтировано под `kDebugMode`.
// Краткие диагностические сообщения (статус, длина) остаются в обоих режимах.


// ⚪ ИСПРАВЛЕНИЯ LOW / STYLE
// ================================================

// 5. НОВЫЙ BUILD-СКРИПТ (build_apk_v5.7.4.ps1)
// ----------------------------------------------
// Прежние скрипты (build_apk_v5.3.0.ps1 и пр.) устарели: таргетили 5.3.0 /
// versionCode 210 при актуальном 5.7.x, содержали жёсткие пути
// D:\Ai-LingoTune\app и C:\flutter\bin\flutter.bat.
// Создан новый актуальный скрипт build_apk_v5.7.4.ps1:
//   - версия и versionCode читаются из pubspec.yaml и build.gradle;
//   - пути вычисляются через $PSScriptRoot (переносим между машинами);
//   - flutter определяется через PATH с fallback на C:\flutter.
// Имя файла сохранено как 5.7.4 (исторически), но собирает любую версию.

// 6. УБРАН ДУБЛЬ В FEATURES (app_info.dart)
// ----------------------------------------------
// В списке features дважды встречался "Batch lyrics generator"
// (разные эмодзи ⚡ и 🎯). Удалён дублирующий пункт.

// 7. PYTHON: bare except → except Exception (5 файлов)
// ----------------------------------------------
// Заменено 7 мест bare `except:` на `except Exception:` — теперь не глотают
// KeyboardInterrupt / SystemExit (можно корректно прервать скрипт Ctrl+C).
// Файлы: create_lyrics_from_files.py, deepseek_generator_v3.py,
// icon_generator.py (×3), process_romanian_songs.py, test_single_song.py.


// ✅ ПРОВЕРЕНО И В ПОРЯДКЕ (не требует правок)
// ================================================
// - l10n: все 11 локалей (en/ru/de/es/fr/it/pt/ro/uk/zh/ar) — по 667 ключей,
//   пропусков и лишних нет.
// - Python: все json.dump используют ensure_ascii=False (✓ для кириллицы);
//   with open(..., encoding='utf-8'); нет shell=True в subprocess; нет injections.
// - Dart dispose: все State-классы имеют dispose(), контроллеры отменяются.
// - StudyModeService: аккуратная работа с _sessionToken / _speakToken против
//   гонок; watchdog-таймеры защищают от zombie-состояний just_audio.
// - AndroidManifest: все нужные permissions присутствуют
//   (FOREGROUND_SERVICE_MEDIA_PLAYBACK для Android 14+, POST_NOTIFICATIONS
//   для 13+, READ_PHONE_STATE с обоснованием, RECORD_AUDIO с required=false).
// - SQL: нет инъекций — все запросы используют ?-плейсхолдеры; дедупликация и
//   rebase путей обёрнуты в transaction.
// - API-кэш: с TTL и лимитом 200 записей (_cleanExpiredCache).
// - audio_service.dispose(): корректно отменяет все 4 подписки.
// - СЕКРЕТНОСТЬ: ключ DEEPSEEK_API_KEY НИКОГДА не попадал в git-историю
//   (проверено `git log --all -S`), .env корректно в .gitignore.


// 📌 ОТЛОЖЕНО (низкий приоритет — на будущее)
// ================================================
// - M2: кастомный _Semaphore в DeepSeekApiService → pool-пакет.
// - M3: вынести чтение importedDb из транзакции в mergeDatabase.
// - M4: O(n²) _updateSingleTranslationTimestamps → two-pointer.
// - M5: _loadPlaybackSettings() fire-and-forget в конструкторе AudioService
//   (визуальный баг прыжка UI первого показа).
// - L4: docs/AGENTS.md обновлён в этом релизе (добавлены недостающие секции).
// - 8 pre-existing warning'ов от flutter analyze (неиспользуемые импорты/поля).
// - Обновить AGP 8.9.1 → 8.11.1 и Kotlin 2.1.0 → 2.2.20 (предупреждение сборки).


// 📦 ФАЙЛЫ, ИЗМЕНЁННЫЕ В ЭТОМ РЕЛИЗЕ
// ================================================
// app/lib/main.dart                              — H1 (toggle race) + H3 (TtsCoordinator dispose)
// app/lib/services/database_service.dart         — H2 (batch methods → singleton)
// app/lib/services/tts_coordinator.dart          — H3 (dispose method)
// app/lib/services/deepseek_api_service.dart     — M1 (kDebugMode gating)
// app/lib/app_info.dart                          — L3 (remove duplicate) + version bump
// app/pubspec.yaml                               — version 5.7.5
// app/android/app/build.gradle                   — versionCode 227, archivesBaseName v5.7.5
// build_apk_v5.7.4.ps1                           — L1 (new build script, NEW FILE)
// scripts/create_lyrics_from_files.py            — L2 (except Exception)
// scripts/deepseek_generator_v3.py               — L2 (except Exception)
// scripts/icon_generator.py                      — L2 (except Exception, ×3)
// scripts/process_romanian_songs.py              — L2 (except Exception)
// scripts/test_single_song.py                    — L2 (except Exception)
// docs/AGENTS.md                                 — L4 (sync doc with code reality)
// CHANGELOG_v5.7.5.dart                          — этот файл (NEW FILE)
