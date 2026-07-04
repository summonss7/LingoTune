#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Lesson 01 LRC and JSON Generator for LingoTune
Creates LRC files, JSON files with translations and IPA transcriptions, and ZIP archives
"""

import json
import os
import zipfile
from pathlib import Path

# Directory paths
LESSONS_DIR = str(Path(__file__).resolve().parent.parent / "lessons" / "Arabic")
OUTPUT_DIR = str(Path(__file__).resolve().parent.parent / "lessons" / "Arabic" / "output")

# Timing configuration for educational song (clear pronunciation)
TIMING_STEP = 6.0  # 6 seconds per line for clear pronunciation
START_MINUTE = 30.0  # Start at 30:00

def read_file_lines(file_path):
    """Read lines from a file"""
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

    print(f"✓ Created LRC: {output_path}")
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

    print(f"✓ Created RU JSON: {output_path}")
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

    print(f"✓ Created TRANS JSON: {output_path}")
    return output_path

def create_zip_archive(lrc_file, ru_json_file, trans_json_file, output_path):
    """Create ZIP archive with all generated files"""

    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipf.write(lrc_file, os.path.basename(lrc_file))
        zipf.write(ru_json_file, os.path.basename(ru_json_file))
        zipf.write(trans_json_file, os.path.basename(trans_json_file))

    print(f"✓ Created ZIP: {output_path}")
    return output_path

def process_lesson():
    """Process Lesson 01: read files, generate LRC, JSON, and ZIP"""

    print("=" * 70)
    print("Lesson 01: Arabic Alphabet")
    print("=" * 70)
    print()

    # Read input files
    arabic_file = os.path.join(LESSONS_DIR, "01-alphabet-arabic.txt")
    russian_file = os.path.join(LESSONS_DIR, "01-alphabet-russian.txt")
    ipa_file = os.path.join(LESSONS_DIR, "01-alphabet-ipa.txt")

    if not os.path.exists(arabic_file):
        print(f"✗ Arabic file not found: {arabic_file}")
        return None
    if not os.path.exists(russian_file):
        print(f"✗ Russian file not found: {russian_file}")
        return None
    if not os.path.exists(ipa_file):
        print(f"✗ IPA file not found: {ipa_file}")
        return None

    arabic_lines = read_file_lines(arabic_file)
    russian_lines = read_file_lines(russian_file)
    ipa_lines = read_file_lines(ipa_file)

    print(f"Read {len(arabic_lines)} lines from each file")
    print()

    # Ensure output directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Generate filenames
    song_id = "01"
    song_name = "Alphabet"
    base_filename = f"{song_id}-{song_name}"
    lrc_file = os.path.join(OUTPUT_DIR, f"{base_filename}.lrc")
    ru_json_file = os.path.join(OUTPUT_DIR, f"{base_filename}_ru.json")
    trans_json_file = os.path.join(OUTPUT_DIR, f"{base_filename}_trans.json")
    zip_file = os.path.join(OUTPUT_DIR, f"{base_filename}.zip")

    # Create LRC file
    create_lrc_file(arabic_lines, lrc_file)

    # Create JSON files
    create_ru_json(base_filename, russian_lines, ipa_lines, ru_json_file)
    create_trans_json(base_filename, arabic_lines, ipa_lines, trans_json_file)

    # Create ZIP archive
    create_zip_archive(lrc_file, ru_json_file, trans_json_file, zip_file)

    print()
    print("=" * 70)
    print("✓ Successfully processed Lesson 01: Arabic Alphabet")
    print("=" * 70)
    print()

    # Print summary
    print("📋 Generated Files:")
    print()
    print(f"  LRC: {lrc_file}")
    print(f"  RU JSON: {ru_json_file}")
    print(f"  TRANS JSON: {trans_json_file}")
    print(f"  ZIP: {zip_file}")
    print()
    print(f"📁 All files saved in: {OUTPUT_DIR}")
    print()
    print("🎯 Next steps:")
    print("   1. Use SUNO prompt to generate music")
    print("   2. Import MP3 file into LingoTune")
    print("   3. Copy ZIP file to your phone")
    print("   4. Import ZIP into LingoTune app")
    print("   5. Learn Arabic alphabet with this song!")
    print()

    return {
        'lrc': lrc_file,
        'ru_json': ru_json_file,
        'trans_json': trans_json_file,
        'zip': zip_file
    }

def main():
    """Main function"""
    result = process_lesson()
    if not result:
        print("✗ Failed to process Lesson 01")
        return 1
    return 0

if __name__ == "__main__":
    main()