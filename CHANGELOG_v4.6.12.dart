// 📋 ЛИСТ ИЗМЕНЕНИЙ v4.6.12
// ================================================

// ✅ ВЕРСИЯ 4.6.12 - НОВАЯ ФУНКЦИОНАЛЬНОСТЬ И УЛУЧШЕНИЯ
// Дата: 31.05.2026

// 1. ВЕРСИЯ ПРИЛОЖЕНИЯ ОБНОВЛЕНА
// ================================================
// app/pubspec.yaml
version: 4.6.11 → 4.6.12

// app/android/app/build.gradle
versionCode: 179 → 180
archivesBaseName: "LingoTune-v4.6.11" → "LingoTune-v4.6.12"

// app/lib/app_info.dart
static const String version = '4.6.11' → '4.6.12';
static const String versionCode = '179' → '180';


// 2. НОВЫЕ ФАЙЛЫ
// ================================================
// app/lib/widgets/settings/timestamp_offset_control.dart
// - Виджет управления смещением временных меток
// - Кнопки + / - для изменения (0-180 минут)
// - Сохранение в SharedPreferences


// 3. ОБНОВЛЕННЫЕ ФАЙЛЫ
// ================================================

// app/lib/services/settings_provider.dart
// + double _defaultTimestampOffset = 1800.0;
// + double get defaultTimestampOffset
// + Future<void> setDefaultTimestampOffset(double value)
// + Загрузка/сохранение defaultTimestampOffset

// app/lib/screens/settings_screen.dart
// + ListTile для настройки Timestamp Offset
// + Импорт TimestampOffsetControl виджета

// app/lib/screens/translation_editor_screen.dart
// + Импорт shared_preferences
// + Импорт generation_constants
// + IconButton(timer_reset) в AppBar
// + _showResetTimestampsDialog() функция
//   - Подтверждение сброса
//   - Сброс startTime и originalStartTime
//   - Вопрос о сохранении

// app/lib/services/lyrics_generator_service.dart
// - .round() → .truncate() для миллисекунд
// + Логирование при парсинге LRC

// app/lib/screens/lyric_generator_dialog.dart
// - .round() → .truncate() для миллисекунд

// Локализация (12 файлов):
// + timestampOffset
// + timestampOffsetSubtitle
// + resetTimestamps
// + resetTimestampsConfirm
// + resetTimestampsSuccess
// + saveAfterReset
// + saveAfterResetConfirm


// 4. ОБНОВЛЕННЫЕ ПУТИ (ProjectAI → Ai-Projects)
// ================================================
// Скрипты сборки (3 файла):
// scripts/build.bat
// scripts/build_apk.bat
// scripts/adb_config.bat

// Python скрипты (7 файлов):
// scripts/arabic_lrc_generator.py
// scripts/arabic_songs_generator.py
// scripts/create_lyrics_from_files.py
// scripts/create_uk_arb.py
// scripts/generate_lesson01.py
// scripts/generate_lrc_json.py
// scripts/deepseek_generator_v3.py

// Прочее (4 файла):
// run_processor.bat
// docs/SETUP.md
// docs/PLAN_v4.6.0.md


// 5. НОВЫЕ СКРИПТЫ СБОРКИ
// ================================================
// build_v4.6.12.bat - Автоматическая сборка APK
// build_apk_v4.6.12.ps1 - PowerShell скрипт для сборки
// BUILD_v4.6.12.md - Документация сборки


// 6. ФУНКЦИОНАЛЬНОСТЬ
// ================================================

// ✅ Настройка смещения временных меток
// Settings → Display → Timestamp Offset
// - Минимум: 0 минут
// - Максимум: 180 минут
// - Дефолт: 30 минут (1800 секунд)
// - Шаг: 1 минута

// ✅ Сброс временных меток
// Translation Editor → Кнопка timer_reset
// - Сбрасывает startTime на дефолтное значение
// - Сбрасывает originalStartTime на дефолтное значение
// - Использует настройку смещения из Settings
// - Шаг между строками: 5 секунд
// - Запрашивает подтверждение перед сбросом
// - Запрашивает сохранение после сброса

// ✅ Улучшенная точность
// - .round() заменен на .truncate() для миллисекунд
// - Стандартизирован формат (всегда 3 цифры)
// - Добавлено отладочное логирование


// 7. ИСПРАВЛЕНИЯ ПРОБЛЕМ
// ================================================

// ⚠️ Потеря точности при округлении миллисекунд
// ФИКС: Использован .truncate() вместо .round()
// ПРИЧИНА: .round() может давать разные результаты при floating-point ошибках

// ⚠️ Нет UI для сброса меток
// ФИКС: Добавлена кнопка и диалог подтверждения
// МЕСТО: Translation Editor AppBar

// ⚠️ Нет настройки смещения по умолчанию
// ФИКС: Добавлен виджет TimestampOffsetControl в настройки
// МЕСТО: Settings → Display Settings

// ⚠️ Проблемы с путями ProjectAI
// ФИКС: Обновлены все пути на Ai-Projects
// ФАЙЛОВ: 14


// 8. СТАТИСТИКА ИЗМЕНЕНИЙ
// ================================================
// Файлов создано: 3
// Файлов изменено: 24
// Новых строк кода: ~500
// Новых строк локализации: ~100 (на 12 языках)
// Обновленных путей: 18+


// ================================================
// ✅ ГОТОВО К СБОРКЕ APK v4.6.12
// ================================================

// Запустить сборку:
// D:\Ai-Projects\LingoTune\build_v4.6.12.bat

// APK будет в:
// D:\Ai-Projects\LingoTune\builds\LingoTune-v4.6.12.apk