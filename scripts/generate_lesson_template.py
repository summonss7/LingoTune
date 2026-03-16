#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Template Script for Creating New LingoTune Lessons
Copy this file and rename to generate_lessonXX.py, then customize the configuration below
"""

import json
import os
import zipfile

# ============================================================
# CONFIGURATION - MODIFY THESE VALUES FOR EACH LESSON
# ============================================================

# Lesson identification
LESSON_ID = "XX"  # Change to: 01, 02, 03, etc.
LESSON_NAME = "Lesson-Name"  # Change to: Alphabet, Numbers, Greetings, etc.
LESSON_TITLE_RU = "Название урока на русском"  # Russian title for README

# File paths
LESSON_DIR = r"D:\ProjectAI\LingoTune\lessons\Arabic"
OUTPUT_DIR = r"D:\ProjectAI\LingoTune\lessons\Arabic\output"

# Timing configuration (adjust based on lesson complexity)
TIMING_STEP = 6.0  # Seconds per line (6.0 = slow/clear, 4.0 = fast)
START_MINUTE = 30.0  # Start time in minutes

# Lesson metadata for README
LESSON_DESCRIPTION = "Краткое описание темы урока"
LESSON_DURATION = "~X минут"  # Estimated duration
LESSON_LINES_COUNT = "XX"  # Number of lines in the lyrics
LESSON_BPM = "75"  # Beats per minute

# Lesson content summary (for README)
LESSON_CONTENT_SUMMARY = """
Структура песни:
- X куплетов
- X припевов
- X строк всего

Примеры тем:
- Буква/слово/фраза 1
- Буква/слово/фраза 2
- ...
"""

# ============================================================
# END OF CONFIGURATION
# The code below should generally not need modification
# ============================================================

def read_file_lines(file_path):
    """Read lines from a file"""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File not found: {file_path}")
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip()]
    return lines

def seconds_to_lrc_time(seconds):
    """Convert seconds to LRC time format"""
    minutes = int(seconds // 60)
    remaining_seconds = seconds % 60
    secs = int(remaining_seconds)
    centis = int((remaining_seconds - secs) * 100)
    return f"{minutes:02d}:{secs:02d}.{centis:02d}"

def create_lrc_file(arabic_lines, output_path):
    """Create LRC file with timestamps"""
    start_time = START_MINUTE * 60.0

    with open(output_path, 'w', encoding='utf-8') as f:
        for line in arabic_lines:
            lrc_time = seconds_to_lrc_time(start_time)
            f.write(f"[{lrc_time}]{line}\n")
            start_time += TIMING_STEP

    return output_path

def create_ru_json(song_title, russian_lines, ipa_lines, output_path):
    """Create JSON file with Russian translation and IPA transcription"""

    start_time = START_MINUTE * 60.0
    json_lines = []

    for i, (ru_text, ipa_text) in enumerate(zip(russian_lines, ipa_lines)):
        json_lines.append({
            "startTime": round(start_time, 2),
            "text": ru_text,
            "translatedText": None,
            "transcript": ipa_text,
            "originalStartTime": None
        })
        start_time += TIMING_STEP

    data = {
        "title": song_title,
        "artist": "LingoTune Arabic Learning",
        "originalLanguage": "ar",
        "translations": [
            {
                "language": "ru",
                "languageName": "Русский",
                "type": "",
                "lines": json_lines
            }
        ]
    }

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    return output_path

def create_trans_json(song_title, arabic_lines, ipa_lines, output_path):
    """Create JSON file with Arabic text and IPA transcription"""

    start_time = START_MINUTE * 60.0
    json_lines = []

    for i, (ar_text, ipa_text) in enumerate(zip(arabic_lines, ipa_lines)):
        json_lines.append({
            "startTime": round(start_time, 2),
            "text": ar_text,
            "translatedText": None,
            "transcript": ipa_text,
            "originalStartTime": None
        })
        start_time += TIMING_STEP

    data = {
        "title": song_title,
        "artist": "LingoTune Arabic Learning",
        "originalLanguage": "ar",
        "translations": [
            {
                "language": "trans",
                "languageName": "Транскрипция",
                "type": "transcript",
                "lines": json_lines
            }
        ]
    }

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    return output_path

def create_zip_archive(lrc_file, ru_json_file, trans_json_file, output_path):
    """Create ZIP archive with all generated files"""

    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipf.write(lrc_file, os.path.basename(lrc_file))
        zipf.write(ru_json_file, os.path.basename(ru_json_file))
        zipf.write(trans_json_file, os.path.basename(trans_json_file))

    return output_path

def create_readme_file():
    """Create README file for the lesson"""

    readme_content = f"""# Урок {LESSON_ID}: {LESSON_TITLE_RU} ({LESSON_NAME})

## 📋 Обзор

{LESSON_DESCRIPTION}

## 🎵 Характеристики песни

- **Жанр:** Egyptian Folk Rock
- **Темп:** {LESSON_BPM} BPM (умеренный для чёткого произношения)
- **Длительность:** {LESSON_DURATION}
- **Инструменты:** электрическая гитара, ударные, дудук, скрипка, виолончель, флейта, орган
- **Количество строк:** {LESSON_LINES_COUNT}
- **Время на строку:** {TIMING_STEP} секунд (для чёткого произношения)

## 📁 Структура файлов

### Основные файлы в `D:\\ProjectAI\\LingoTune\\lessons\\Arabic\\`:

1. **{LESSON_ID}-{LESSON_NAME.lower()}-arabic.txt** - Текст песни на арабском языке (египетский диалект)
2. **{LESSON_ID}-{LESSON_NAME.lower()}-russian.txt** - Перевод на русский язык
3. **{LESSON_ID}-{LESSON_NAME.lower()}-ipa.txt** - IPA транскрипция (фонетическая)
4. **{LESSON_ID}-{LESSON_NAME.lower()}-suno-style.txt** - Стиль для SUNO (поле Style/Description)
5. **{LESSON_ID}-{LESSON_NAME.lower()}-suno-lyrics.txt** - Текст для SUNO (поле Lyrics/Text)
5. **{LESSON_ID}-{LESSON_NAME}-README.md** - Этот файл

### Файлы для импорта в LingoTune (в папке `output/`):

6. **{LESSON_ID}-{LESSON_NAME}.lrc** - LRC файл с таймингами
7. **{LESSON_ID}-{LESSON_NAME}_ru.json** - JSON с переводом на русский и IPA
8. **{LESSON_ID}-{LESSON_NAME}_trans.json** - JSON с арабским текстом и IPA
9. **{LESSON_ID}-{LESSON_NAME}.zip** - ZIP архив для импорта в LingoTune

### Итоговый архив:

10. **{LESSON_ID}-{LESSON_NAME}-Lesson.zip** - Полный архив со всеми материалами урока

## 🎯 Содержание песни

{LESSON_CONTENT_SUMMARY}

## 📖 Инструкции по использованию

### Шаг 1: Генерация музыки в SUNO

1. Откройте файл `{LESSON_ID}-{LESSON_NAME.lower()}-suno-style.txt`
2. Скопируйте содержимое и вставьте в поле **"Style / Description"** в SUNO
3. Откройте файл `{LESSON_ID}-{LESSON_NAME.lower()}-suno-lyrics.txt`
4. Скопируйте содержимое и вставьте в поле **"Lyrics / Text"** в SUNO
5. Нажмите "Generate" для создания музыки
6. Скачайте MP3 файл сгенерированной песни

**Важно:** SUNO имеет два отдельных поля:
- **Style / Description** - используйте `{LESSON_ID}-{LESSON_NAME.lower()}-suno-style.txt`
- **Lyrics / Text** - используйте `{LESSON_ID}-{LESSON_NAME.lower()}-suno-lyrics.txt`

### Шаг 2: Импорт в LingoTune (на телефоне)

**Вариант А: Использование ZIP архива**
1. Скопируйте файл `{LESSON_ID}-{LESSON_NAME}.zip` на телефон
2. Откройте приложение LingoTune
3. Нажмите "Импорт" → выберите ZIP файл
4. Всё готово! Песня появится в приложении

**Вариант Б: Ручной импорт**
1. Скопируйте MP3 файл на телефон
2. Скопируйте файлы `{LESSON_ID}-{LESSON_NAME}.lrc`, `{LESSON_ID}-{LESSON_NAME}_ru.json`, `{LESSON_ID}-{LESSON_NAME}_trans.json` в нужную папку
3. Откройте LingoTune и добавьте песню вручную

### Шаг 3: Изучение

1. Слушайте песню и следите за текстом
2. Используйте транскрипцию для правильного произношения
3. Сравнивайте с переводом на русский
4. Повторяйте за вокалистом
5. Практикуйтесь в произношении

## 🎼 Музыкальные особенности

- **Инструменты:** Сочетание рок-инструментов и восточных
- **Вокал:** Чёткий, мелодичный, египетское произношение
- **Припевы:** Запоминающиеся, повторяющиеся
- **Инструментальные вставки:** Мелодичные, с дудуком и скрипкой

## 📊 Статистика

- **Общее количество строк:** {LESSON_LINES_COUNT}
- **Время на строку:** {TIMING_STEP} секунд
- **Общее время песни:** {LESSON_DURATION}

## 📝 Дополнительные материалы

Для генерации файлов использован скрипт `scripts/generate_lesson{LESSON_ID}.py`

Конфигурация:
- **TIMING_STEP:** {TIMING_STEP} секунд на строку
- **START_MINUTE:** {START_MINUTE} (начало с {START_MINUTE}:00)
- **Output directory:** `lessons/Arabic/output`

## 🎓 Уровень сложности

- **Для начинающих:** ✅ Да
- **Требует предварительных знаний:** ❌ Нет
- **Рекомендуемое время изучения:** 1-2 недели
- **Количество повторений:** 10-15

## 📞 Поддержка

Для вопросов и предложений по этому уроку, пожалуйста, свяжитесь с разработчиком проекта LingoTune.

---

**Создано:** 14 марта 2026
**Урок №{LESSON_ID}:** {LESSON_TITLE_RU}
**Версия:** 1.0

**Удачи в изучении арабского языка! 🎵**
"""

    readme_path = os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME}-README.md")
    with open(readme_path, 'w', encoding='utf-8') as f:
        f.write(readme_content)

    return readme_path

def validate_files(arabic_lines, russian_lines, ipa_lines):
    """Validate that all files have the same number of lines"""

    print("\n" + "="*70)
    print("Validating files...")
    print("="*70)
    print(f"Arabic lines: {len(arabic_lines)}")
    print(f"Russian lines: {len(russian_lines)}")
    print(f"IPA lines: {len(ipa_lines)}")

    if len(arabic_lines) != len(russian_lines) or len(arabic_lines) != len(ipa_lines):
        print("\n✗ ERROR: Files have different number of lines!")
        print("Please ensure all three files have the same number of lines.")
        return False

    if not (40 <= len(arabic_lines) <= 60):
        print(f"\n⚠ WARNING: {len(arabic_lines)} lines is outside recommended range (40-60)")
        print("Consider adjusting the lesson length.")

    print("\n✓ Files validated successfully")
    return True

def create_final_archive():
    """Create final ZIP archive with all lesson materials"""

    archive_name = f"{LESSON_ID}-{LESSON_NAME}-Lesson.zip"
    archive_path = os.path.join(LESSON_DIR, archive_name)

    with zipfile.ZipFile(archive_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add main lesson files
        zipf.write(os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-arabic.txt"),
                   f"{LESSON_ID}-{LESSON_NAME.lower()}-arabic.txt")
        zipf.write(os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-russian.txt"),
                   f"{LESSON_ID}-{LESSON_NAME.lower()}-russian.txt")
        zipf.write(os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-ipa.txt"),
                   f"{LESSON_ID}-{LESSON_NAME.lower()}-ipa.txt")
        zipf.write(os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-suno-style.txt"),
                   f"{LESSON_ID}-{LESSON_NAME.lower()}-suno-style.txt")
        zipf.write(os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-suno-lyrics.txt"),
                   f"{LESSON_ID}-{LESSON_NAME.lower()}-suno-lyrics.txt")
        zipf.write(os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME}-README.md"),
                   f"{LESSON_ID}-{LESSON_NAME}-README.md")

        # Add output files
        for root, dirs, files in os.walk(OUTPUT_DIR):
            for file in files:
                if file.startswith(f"{LESSON_ID}-{LESSON_NAME}"):
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, LESSON_DIR)
                    zipf.write(file_path, arcname)

    return archive_path

def main():
    """Main function"""

    print("="*70)
    print(f"Lesson {LESSON_ID}: {LESSON_NAME}")
    print("="*70)
    print()

    # Construct file paths
    arabic_file = os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-arabic.txt")
    russian_file = os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-russian.txt")
    ipa_file = os.path.join(LESSON_DIR, f"{LESSON_ID}-{LESSON_NAME.lower()}-ipa.txt")

    # Read input files
    try:
        arabic_lines = read_file_lines(arabic_file)
        russian_lines = read_file_lines(russian_file)
        ipa_lines = read_file_lines(ipa_file)
    except FileNotFoundError as e:
        print(f"✗ Error: {e}")
        print("\nPlease ensure the following files exist:")
        print(f"  - {arabic_file}")
        print(f"  - {russian_file}")
        print(f"  - {ipa_file}")
        return 1

    # Validate files
    if not validate_files(arabic_lines, russian_lines, ipa_lines):
        return 1

    print()

    # Ensure output directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Generate filenames
    base_filename = f"{LESSON_ID}-{LESSON_NAME}"
    lrc_file = os.path.join(OUTPUT_DIR, f"{base_filename}.lrc")
    ru_json_file = os.path.join(OUTPUT_DIR, f"{base_filename}_ru.json")
    trans_json_file = os.path.join(OUTPUT_DIR, f"{base_filename}_trans.json")
    zip_file = os.path.join(OUTPUT_DIR, f"{base_filename}.zip")

    # Create files
    print("="*70)
    print("Generating LRC, JSON, and ZIP files...")
    print("="*70)
    print()

    create_lrc_file(arabic_lines, lrc_file)
    print(f"✓ Created LRC: {lrc_file}")

    create_ru_json(base_filename, russian_lines, ipa_lines, ru_json_file)
    print(f"✓ Created RU JSON: {ru_json_file}")

    create_trans_json(base_filename, arabic_lines, ipa_lines, trans_json_file)
    print(f"✓ Created TRANS JSON: {trans_json_file}")

    create_zip_archive(lrc_file, ru_json_file, trans_json_file, zip_file)
    print(f"✓ Created ZIP: {zip_file}")

    # Create README
    print()
    print("="*70)
    print("Creating README file...")
    print("="*70)
    print()

    readme_file = create_readme_file()
    print(f"✓ Created README: {readme_file}")

    # Create final archive
    print()
    print("="*70)
    print("Creating final archive...")
    print("="*70)
    print()

    final_archive = create_final_archive()
    print(f"✓ Created final archive: {final_archive}")
    print(f"  Size: {os.path.getsize(final_archive)} bytes")

    # Print summary
    print()
    print("="*70)
    print("✓ SUCCESS: Lesson {LESSON_ID} created successfully!")
    print("="*70)
    print()
    print("📋 Generated Files:")
    print()
    print(f"  Main files:")
    print(f"    - {os.path.basename(arabic_file)}")
    print(f"    - {os.path.basename(russian_file)}")
    print(f"    - {os.path.basename(ipa_file)}")
    print(f"    - {LESSON_ID}-{LESSON_NAME.lower()}-suno-style.txt")
    print(f"    - {LESSON_ID}-{LESSON_NAME.lower()}-suno-lyrics.txt")
    print(f"    - {os.path.basename(readme_file)}")
    print()
    print(f"  Import files (in output/):")
    print(f"    - {os.path.basename(lrc_file)}")
    print(f"    - {os.path.basename(ru_json_file)}")
    print(f"    - {os.path.basename(trans_json_file)}")
    print(f"    - {os.path.basename(zip_file)}")
    print()
    print(f"  Final archive:")
    print(f"    - {os.path.basename(final_archive)}")
    print()
    print(f"📁 All files saved in: {LESSON_DIR}")
    print()
    print("🎯 Next steps:")
    print("   1. Use SUNO style file (Style/Description field) and lyrics file (Lyrics/Text field) to generate music")
    print("   2. Download MP3 from SUNO")
    print("   3. Import ZIP file into LingoTune")
    print("   4. Learn Arabic with this song!")
    print()

    return 0

if __name__ == "__main__":
    main()