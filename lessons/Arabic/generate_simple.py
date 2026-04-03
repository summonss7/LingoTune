#!/usr/bin/env python3
"""
Generate ZIP archives for Arabic lessons with timing (30 minutes, 5-second intervals)
Simple and reliable version
"""

import json
import zipfile

def load_words(filename):
    """Load words from file"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return [line.strip() for line in f if line.strip()]
    except:
        print(f"Error loading {filename}")
        return []

def generate_lrc(arabic_words):
    """Generate LRC content"""
    lines = []
    time = 1800.0 # 30 minutes in seconds
    
    # Generate 360 words (1800 seconds / 5 = 360 iterations)
    for i in range(360):
        word = arabic_words[i % len(arabic_words)]
        minutes = int(time / 60)
        seconds = time % 60
        lines.append(f"[{minutes:02d}:{seconds:05.02f}]{word}")
        time += 5.0
    
    # Add final marker at exactly 60:00.00
    lines.append(f"[60:00.00]END")
    
    return '\n'.join(lines)

def generate_json_ru(russian_words, ipa_words):
    """Generate JSON for Russian"""
    lines = []
    time = 1800.0
    
    for i in range(360):
        russian = russian_words[i % len(russian_words)]
        ipa = ipa_words[i % len(ipa_words)]
        
        lines.append({
            "startTime": time,
            "text": russian,
            "translatedText": None,
            "transcript": ipa,
            "originalStartTime": None
        })
        time += 5.0
    
    return {
        "title": "001-lesson",
        "artist": "Unknown",
        "originalLanguage": "ar",
        "translations": [{
            "language": "ru",
            "languageName": "Русский",
            "type": "",
            "lines": lines
        }]
    }

def generate_json_trans(arabic_words, russian_words):
    """Generate JSON for transcription"""
    lines = []
    time = 1800.0
    
    for i in range(360):
        arabic = arabic_words[i % len(arabic_words)]
        russian = russian_words[i % len(russian_words)]
        
        lines.append({
            "startTime": time,
            "text": arabic,
            "translatedText": None,
            "transcript": russian,
            "originalStartTime": None
        })
        time += 5.0
    
    return {
        "title": "001-lesson",
        "artist": "Unknown",
        "originalLanguage": "ar",
        "translations": [{
            "language": "trans",
            "languageName": "Транскрипция",
            "type": "transcript",
            "lines": lines
        }]
    }

def create_lesson_zip(lesson_num, lesson_name):
    """Create ZIP archive for a lesson"""
    print(f"\nProcessing Lesson {lesson_num}")
    print("=" * 40)
    
    # Load files
    russian = load_words(f"{lesson_num:02d}-russian-words.txt")
    arabic = load_words(f"{lesson_num:02d}-russian-words-arabic.txt")
    ipa = load_words(f"{lesson_num:02d}-russian-words-ipa.txt")
    
    if not russian or not arabic or not ipa:
        print(f"Error: Missing files for lesson {lesson_num}")
        return
    
    # Truncate to match
    min_len = min(len(russian), len(arabic), len(ipa))
    russian = russian[:min_len]
    arabic = arabic[:min_len]
    ipa = ipa[:min_len]
    
    print(f"Words: {min_len}")
    print(f"Total lines to generate: 360")
    print(f"Duration: 1800 seconds (30 minutes)")
    
    # Generate content
    lrc_content = generate_lrc(arabic)
    json_ru = generate_json_ru(russian, ipa)
    json_trans = generate_json_trans(arabic, russian)
    
    # Update title
    json_ru["title"] = f"{lesson_num:03d}-lesson"
    json_trans["title"] = f"{lesson_num:03d}-lesson"
    
    print(f"LRC lines: {len(lrc_content.split(chr(10)))}")
    print(f"JSON RU lines: {len(json_ru['translations'][0]['lines'])}")
    print(f"JSON TRANS lines: {len(json_trans['translations'][0]['lines'])}")
    
    # Create ZIP
    zip_name = f"{lesson_num:03d}-lesson.zip"
    with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(f"{lesson_num:03d}-lesson.lrc", lrc_content.encode('utf-8'))
        zf.writestr(f"{lesson_num:03d}-lesson_ru.json", json.dumps(json_ru, ensure_ascii=False, indent=2).encode('utf-8'))
        zf.writestr(f"{lesson_num:03d}-lesson_trans.json", json.dumps(json_trans, ensure_ascii=False, indent=2).encode('utf-8'))
    
    # Verify
    with zipfile.ZipFile(zip_name, 'r') as verify:
        print(f"ZIP files: {len(verify.namelist())}")
    
    print(f"✓ Created: {zip_name}")
    return zip_name

def main():
    """Generate all lessons"""
    print("=" * 40)
    print("Arabic Lessons ZIP Generator")
    print("=" * 40)
    
    zip_files = []
    for lesson_num in [1, 2, 3]:
        zip_file = create_lesson_zip(lesson_num, f"Lesson {lesson_num}")
        if zip_file:
            zip_files.append(zip_file)
    
    print("\n" + "=" * 40)
    print("Summary")
    print("=" * 40)
    print("ZIP files created:")
    for zf in zip_files:
        print(f"  {zf}")
    
    print("\nTiming format:")
    print("  [30:00.00] - word 1")
    print("  [30:05.00] - word 2")
    print("  [30:10.00] - word 3")
    print("  ...")
    print("  [60:00.00] - word 73")
    print("  ...")
    print("  [60:00.00] - word 360 (end)")
    
    print("\n✓ All ZIP archives created successfully!")

if __name__ == "__main__":
    main()
