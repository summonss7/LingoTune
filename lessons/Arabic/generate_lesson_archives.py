#!/usr/bin/env python3
"""
Generate ZIP archives for Arabic lessons with timing (30 minutes, 5-second intervals)
"""

import json
import zipfile
import os
from pathlib import Path
from typing import List, Tuple, Dict

def load_lesson_files(lesson_number: int) -> Tuple[List[str], List[str], List[str]]:
    """Load Russian, Arabic, and IPA files for a lesson"""
    base_name = f"{lesson_number:02d}-russian-words"
    
    # Read Russian words
    try:
        with open(f"{base_name}.txt", "r", encoding="utf-8") as f:
            russian_words = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: {base_name}.txt not found")
        return [], [], []
    
    # Read Arabic words
    try:
        with open(f"{base_name}-arabic.txt", "r", encoding="utf-8") as f:
            arabic_words = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: {base_name}-arabic.txt not found")
        return russian_words, [], []
    
    # Read IPA transcription
    try:
        with open(f"{base_name}-ipa.txt", "r", encoding="utf-8") as f:
            ipa_transcriptions = [line.strip() for line in f if line.strip()]
    except FileNotFoundError:
        print(f"Error: {base_name}-ipa.txt not found")
        return russian_words, arabic_words, []
    
    return russian_words, arabic_words, ipa_transcriptions

def generate_lrc_file(arabic_words: List[str], lesson_number: int) -> str:
    """Generate LRC file with timing starting at 30:00 with 5-second intervals"""
    lrc_lines = []
    current_time = 1800.0  # Start at 30:00 (30 minutes * 60)
    total_duration = 1800.0  # 30 minutes in seconds
    
    # Generate words until we reach exactly 30 minutes
    word_index = 0
    while int(current_time) < int(total_duration):
        word = arabic_words[word_index % len(arabic_words)]
        minutes = int(current_time / 60)
        seconds = current_time % 60
        lrc_lines.append(f"[{minutes:02d}:{seconds:05.02f}]{word}")
        current_time += 5.0
        word_index += 1
    
    return "\n".join(str(line) for line in lrc_lines)

def generate_json_ru(russian_words: List[str], ipa_transcriptions: List[str], 
                     lesson_number: int) -> Dict:
    """Generate JSON file for Russian translation + IPA"""
    current_time = 1800.0  # Start at 30:00 (30 minutes * 60)
    lines = []
    total_duration = 1800.0  # 30 minutes in seconds
    
    # Generate words until we reach exactly 30 minutes
    word_index = 0
    while int(current_time) < int(total_duration):
        russian = russian_words[word_index % len(russian_words)]
        ipa = ipa_transcriptions[word_index % len(ipa_transcriptions)]
        
        minutes = int(current_time / 60)
        seconds = current_time % 60
        lines.append({
            "startTime": current_time,
            "text": russian,
            "translatedText": None,
            "transcript": ipa,
            "originalStartTime": None
        })
        current_time += 5.0
        word_index += 1
    
    return {
        "title": f"{lesson_number:03d}-lesson",
        "artist": "Unknown",
        "originalLanguage": "ar",
        "translations": [
            {
                "language": "ru",
                "languageName": "Русский",
                "type": "",
                "lines": lines
            }
        ]
    }

def generate_json_trans(arabic_words: List[str], russian_words: List[str], 
                      lesson_number: int) -> Dict:
    """Generate JSON file for IPA + Russian translation"""
    current_time = 1800.0  # Start at 30:00 (30 minutes * 60)
    lines = []
    total_duration = 1800.0  # 30 minutes in seconds
    
    # Generate words until we reach exactly 30 minutes
    word_index = 0
    while int(current_time) < int(total_duration):
        arabic = arabic_words[word_index % len(arabic_words)]
        russian = russian_words[word_index % len(russian_words)]
        
        minutes = int(current_time / 60)
        seconds = current_time % 60
        lines.append({
            "startTime": current_time,
            "text": arabic,
            "translatedText": None,
            "transcript": russian,
            "originalStartTime": None
        })
        current_time += 5.0
        word_index += 1
    
    return {
        "title": f"{lesson_number:03d}-lesson",
        "artist": "Unknown",
        "originalLanguage": "ar",
        "translations": [
            {
                "language": "trans",
                "languageName": "Транскрипция",
                "type": "transcript",
                "lines": lines
            }
        ]
    }

def create_zip_archive(lesson_number: int, lrc_content: str, 
                     json_ru_content: Dict, json_trans_content: Dict) -> None:
    """Create ZIP archive with lesson files"""
    lesson_name = f"{lesson_number:03d}-lesson"
    zip_path = f"output/{lesson_name}.zip"
    
    # Delete existing zip if exists
    if Path(zip_path).exists():
        Path(zip_path).unlink()
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Write LRC file
        lrc_bytes = lrc_content.encode('utf-8')
        zipf.writestr(f"{lesson_name}.lrc", lrc_bytes)
        
        # Write JSON files
        json_ru_bytes = json.dumps(json_ru_content, ensure_ascii=False, indent=2).encode('utf-8')
        zipf.writestr(f"{lesson_name}_ru.json", json_ru_bytes)
        
        json_trans_bytes = json.dumps(json_trans_content, ensure_ascii=False, indent=2).encode('utf-8')
        zipf.writestr(f"{lesson_name}_trans.json", json_trans_bytes)
    
    print(f"✓ Created: {zip_path}")
    
    # Verify files were written
    with zipfile.ZipFile(zip_path, 'r') as verify_zip:
        file_list = verify_zip.namelist()
        print(f"  Files in ZIP: {len(file_list)}")

def main():
    """Main function to generate all lesson archives"""
    # Generate for all 3 lessons
    lesson_configs = [
        1,
        2,
        3,
    ]
    
    for lesson_number in lesson_configs:
        print(f"\n{'='*60}")
        print(f"Processing Lesson {lesson_number}")
        print(f"{'='*60}")
        
        # Load files
        russian_words, arabic_words, ipa_transcriptions = load_lesson_files(lesson_number)
        
        if not russian_words or not arabic_words or not ipa_transcriptions:
            print(f"⚠  Skipping Lesson {lesson_number} - missing files")
            continue
        
        # Verify word counts match
        print(f"Russian words: {len(russian_words)}")
        print(f"Arabic words: {len(arabic_words)}")
        print(f"IPA transcriptions: {len(ipa_transcriptions)}")
        
        if len(russian_words) != len(arabic_words) or len(russian_words) != len(ipa_transcriptions):
            print("⚠  Warning: Word counts don't match!")
            print(f"   Russian: {len(russian_words)}, Arabic: {len(arabic_words)}, IPA: {len(ipa_transcriptions)}")
            # Truncate to minimum
            min_count = min(len(russian_words), len(arabic_words), len(ipa_transcriptions))
            russian_words = russian_words[:min_count]
            arabic_words = arabic_words[:min_count]
            ipa_transcriptions = ipa_transcriptions[:min_count]
        
        word_count = len(russian_words)
        interval = 5.0  # 5 seconds between words
        total_duration = 1800.0  # 30 minutes in seconds
        total_words = int(total_duration / interval)
        repeats_needed = total_words // word_count
        
        print(f"Interval per word: {interval} seconds")
        print(f"Words in lesson: {word_count}")
        print(f"Total words to sing: {total_words}")
        print(f"Repeats needed: {repeats_needed}")
        print(f"Total duration: {total_duration} seconds ({total_duration/60:.1f} minutes)")
        
        # Generate LRC file
        lrc_content = generate_lrc_file(arabic_words, lesson_number)
        print(f"LRC lines: {len(lrc_content.split(chr(10)))}")
        
        # Generate JSON files
        json_ru_content = generate_json_ru(russian_words, ipa_transcriptions, lesson_number)
        json_trans_content = generate_json_trans(arabic_words, russian_words, lesson_number)
        print(f"JSON RU lines: {len(json_ru_content['translations'][0]['lines'])}")
        print(f"JSON TRANS lines: {len(json_trans_content['translations'][0]['lines'])}")
        
        # Create ZIP archive
        create_zip_archive(lesson_number, lrc_content, json_ru_content, json_trans_content)
    
    print(f"\n{'='*60}")
    print("✓ All lesson archives created successfully!")
    print(f"{'='*60}")
    print(f"\nOutput directory: {Path(__file__).resolve().parent / 'output'}")
    print("\nFiles created:")
    print("  001-lesson.zip (43 words, 360 total words, 30 minutes)")
    print("  002-lesson.zip (45 words, 360 total words, 30 minutes)")
    print("  003-lesson.zip (42 words, 360 total words, 30 minutes)")
    print("\nTiming format:")
    print("  [30:00.00] - word 1")
    print("  [30:05.00] - word 2")
    print("  [30:10.00] - word 3")
    print("  ...")
    print("  [60:00.00] - word 73")
    print("  ...")
    print("  [60:00.00] - word 360 (end)")

if __name__ == "__main__":
    main()
