#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Arabic LRC and JSON Generator for LingoTune
Creates LRC files, JSON files with translations and IPA transcriptions, and ZIP archives
"""

import json
import os
import zipfile
from pathlib import Path

# Directory paths
LYRICS_DIR = r"D:\ProjectAI\LingoTune\lyrics\arabic"
OUTPUT_DIR = r"D:\ProjectAI\LingoTune\output\arabic"

# Timing configuration
TIMING_STEP = 5.0  # 5 seconds per line
START_MINUTE = 0.0  # Start at 0:00

# Song configurations
SONGS_CONFIG = [
    {
        "id": "01",
        "name": "Alphabet Song",
        "arabic_name": "أغنية الحروف الأبجدية",
        "files": {
            "arabic": "01-alphabet-arabic.txt",
            "russian": "01-alphabet-russian.txt",
            "ipa": "01-alphabet-ipa.txt"
        }
    },
    {
        "id": "02",
        "name": "Numbers Song",
        "arabic_name": "أغنية الأرقام",
        "files": {
            "arabic": "02-numbers-arabic.txt",
            "russian": "02-numbers-russian.txt",
            "ipa": "02-numbers-ipa.txt"
        }
    },
    {
        "id": "03",
        "name": "Greetings Song",
        "arabic_name": "أغنية التحيات",
        "files": {
            "arabic": "03-greetings-arabic.txt",
            "russian": "03-greetings-russian.txt",
            "ipa": "03-greetings-ipa.txt"
        }
    },
    {
        "id": "04",
        "name": "Politeness Phrases Song",
        "arabic_name": "أغنية عبارات اللطف",
        "files": {
            "arabic": "04-politeness-arabic.txt",
            "russian": "04-politeness-russian.txt",
            "ipa": "04-politeness-ipa.txt"
        }
    }
]

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

def process_song(song_config):
    """Process a single song: read files, generate LRC, JSON, and ZIP"""

    print(f"\n{'='*70}")
    print(f"Processing: {song_config['id']}. {song_config['name']}")
    print(f"{'='*70}\n")

    # Read input files
    arabic_file = os.path.join(LYRICS_DIR, song_config['files']['arabic'])
    russian_file = os.path.join(LYRICS_DIR, song_config['files']['russian'])
    ipa_file = os.path.join(LYRICS_DIR, song_config['files']['ipa'])

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

    print(f"Read {len(arabic_lines)} lines from each file\n")

    # Ensure output directory exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Generate filenames
    base_filename = f"{song_config['id']}-{song_config['name'].replace(' ', '-')}"
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

    # Clean up individual files (optional - comment out if you want to keep them)
    # for file_to_remove in [lrc_file, ru_json_file, trans_json_file]:
    #     if os.path.exists(file_to_remove):
    #         os.remove(file_to_remove)

    print(f"\n✓ Successfully processed: {song_config['name']}")

    return {
        'config': song_config,
        'lrc': lrc_file,
        'ru_json': ru_json_file,
        'trans_json': trans_json_file,
        'zip': zip_file
    }

def main():
    """Main function to process all songs"""

    print("=" * 70)
    print("Arabic LRC and JSON Generator for LingoTune")
    print("=" * 70)
    print(f"\nLyrics directory: {LYRICS_DIR}")
    print(f"Output directory: {OUTPUT_DIR}")
    print(f"Timing step: {TIMING_STEP} seconds per line")
    print(f"Songs to process: {len(SONGS_CONFIG)}\n")

    # Process all songs
    results = []
    for song_config in SONGS_CONFIG:
        result = process_song(song_config)
        if result:
            results.append(result)

    print("\n" + "=" * 70)
    print(f"✓ COMPLETED: Processed {len(results)}/{len(SONGS_CONFIG)} songs")
    print("=" * 70)

    # Print summary
    print("\n📋 Generated Files:")
    for result in results:
        print(f"\n  {result['config']['id']}. {result['config']['name']}")
        print(f"    - LRC: {result['lrc']}")
        print(f"    - RU JSON: {result['ru_json']}")
        print(f"    - TRANS JSON: {result['trans_json']}")
        print(f"    - ZIP: {result['zip']}")

    print(f"\n📁 All files saved in: {OUTPUT_DIR}")
    print(f"\n🎯 Next steps:")
    print(f"   1. Copy ZIP files to your phone")
    print(f"   2. Import them into LingoTune app")
    print(f"   3. Learn Arabic with these songs!")
    print(f"\n🎵 Or use SUNO prompts to generate music first")
    print(f"   Prompts are in: {LYRICS_DIR}")
    print(f"   Then import MP3 files into LingoTune\n")

if __name__ == "__main__":
    main()
