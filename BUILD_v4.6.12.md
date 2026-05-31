# LingoTune v4.6.12 - Сборка APK

## ✅ ВЫПОЛНЕНО

### 1. Обновление версии
- `app/pubspec.yaml`: версия 4.6.11 → 4.6.12
- `app/android/app/build.gradle`: versionCode 179 → 180, archivesBaseName → LingoTune-v4.6.12
- `app/lib/app_info.dart`: версия 4.6.11 → 4.6.12, versionCode 179 → 180

### 2. Обновление путей (14 файлов)

**Скрипты сборки и конфигурации:**
✅ `scripts/build.bat` - обновлен путь к D:\Ai-Projects\LingoTune\app
✅ `scripts/build_apk.bat` - обновлена версия на v4.6.12 и путь
✅ `scripts/adb_config.bat` - обновлен LOG_DIR на D:\Ai-Projects\LingoTune\debug

**Python скрипты:**
✅ `scripts/arabic_lrc_generator.py` - LYRICS_DIR, OUTPUT_DIR
✅ `scripts/arabic_songs_generator.py` - PROMPTS_DIR, LYRICS_DIR
✅ `scripts/create_lyrics_from_files.py` - INPUT_DIR, OUTPUT_DIR
✅ `scripts/create_uk_arb.py` - три пути к файлам локализации
✅ `scripts/generate_lesson01.py` - LESSONS_DIR, OUTPUT_DIR
✅ `scripts/generate_lrc_json.py` - input_dir, output_dir
✅ `scripts/deepseek_generator_v3.py` - debug_dir, input_dir, output_dir

**Batch файлы:**
✅ `run_processor.bat` - путь к process_romanian_songs.py

**Документация:**
✅ `docs/SETUP.md` - путь к проекту в инструкции
✅ `docs/PLAN_v4.6.0.md` - путь к выходному APK

## 🚀 СБОРКА APK

Для сборки APK запустите любой из скриптов:

### Вариант 1: Batch файл (рекомендуется)
```
D:\Ai-Projects\LingoTune\build_v4.6.12.bat
```

### Вариант 2: PowerShell скрипт
```powershell
powershell -ExecutionPolicy Bypass -File "D:\Ai-Projects\LingoTune\build_apk_v4.6.12.ps1"
```

### Вариант 3: Ручная сборка
```cmd
cd D:\Ai-Projects\LingoTune\app
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat gen-l10n
C:\flutter\bin\flutter.bat build apk --release

if not exist "..\builds" mkdir "..\builds"
copy /Y "build\app\outputs\flutter-apk\app-release.apk" "..\builds\LingoTune-v4.6.12.apk"
```

## 📦 Результат

APK будет находиться в:
```
D:\Ai-Projects\LingoTune\builds\LingoTune-v4.6.12.apk
```

## 📊 Информация о сборке

- **Версия:** 4.6.12
- **VersionCode:** 180
- **Flutter SDK:** C:\flutter
- **Путь к проекту:** D:\Ai-Projects\LingoTune
- **Путь к выходу:** D:\Ai-Projects\LingoTune\builds

## 🔧 Что включено в версию 4.6.12

### Новые функции:
1. **Настройка смещения временных меток** - пользователь может изменить дефолтное смещение (30 минут) в настройках
2. **Кнопка сброса временных меток** - в редакторе переводов добавлена кнопка для сброса всех меток на дефолтные значения
3. **Улучшенная точность** - заменен `.round()` на `.truncate()` для миллисекунд
4. **Логирование при парсинге LRC** - добавлено отладочное логирование для поиска проблем

### Локализация:
- Добавлены строки локализации для новых функций на 12 языках

---
*Дата сборки: 31.05.2026*
*Статус: Готово к сборке*