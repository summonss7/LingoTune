#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Test script for processing a single song
"""

import os
import json
import zipfile
from pathlib import Path
from typing import List, Dict, Tuple

# Project root (this file is in <root>/scripts/)
_PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Configuration
INPUT_DIR = str(_PROJECT_ROOT / "input")
OUTPUT_DIR = str(_PROJECT_ROOT / "output")
TIMING_STEP = 5.0
START_MINUTE = 30.0

def parse_line(line: str) -> str:
    """Parse line, remove line numbers and clean whitespace"""
    line = line.strip()
    
    # Remove line numbers like "1:", "10:", "100:" at the start
    import re
    match = re.match(r'^\d+:\s*', line)
    if match:
        line = line[match.end():]
    
    return line.strip()

def parse_transcription_line(line: str) -> str:
    """Parse transcription line, remove slashes /.../"""
    line = line.strip()
    
    # Remove line numbers
    import re
    match = re.match(r'^\d+:\s*', line)
    if match:
        line = line[match.end():]
    
    # Remove surrounding slashes /.../
    line = line.strip()
    if line.startswith('/') and line.endswith('/'):
        line = line[1:-1]
    
    return line.strip()

def read_file_content(filepath: str) -> List[str]:
    """Read file and return list of non-empty lines"""
    if not os.path.exists(filepath):
        return []
    
    lines = []
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        for line in f:
            parsed = parse_line(line)
            if parsed:
                lines.append(parsed)
    return lines

def read_transcription_file(filepath: str) -> List[str]:
    """Read transcription file and return list of non-empty lines (slashes removed)"""
    if not os.path.exists(filepath):
        return []
    
    lines = []
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        for line in f:
            parsed = parse_transcription_line(line)
            if parsed:
                lines.append(parsed)
    return lines

def format_time(seconds: float) -> str:
    """Format seconds to MM:SS.ms format"""
    minutes = int(seconds // 60)
    secs = int(seconds % 60)
    centis = int((seconds % 1) * 100)
    return f"{minutes:02d}:{secs:02d}.{centis:02d}"

def create_lrc_file(output_path: str, lines: List[str], start_minute: float):
    """Create LRC file with timestamps"""
    start_time = start_minute * 60.0
    
    with open(output_path, 'w', encoding='utf-8') as f:
        current_time = start_time
        for line in lines:
            timestamp = format_time(current_time)
            f.write(f"[{timestamp}]{line}\n")
            current_time += TIMING_STEP
    
    print(f"  ✓ Created LRC: {output_path}")

def create_json_lines_with_timestamps(lines: List[str], start_minute: float) -> List[Dict]:
    """Create list of line objects with timestamps"""
    line_objects = []
    start_time = start_minute * 60.0
    current_time = start_time
    
    for line in lines:
        line_objects.append({
            "startTime": current_time,
            "text": line,
            "translatedText": None,
            "transcript": None,
            "originalStartTime": None
        })
        current_time += TIMING_STEP
    
    return line_objects

def create_json_file(output_path: str, song_title: str, text_lines: List[str], 
                     transcript_lines: List[str], start_minute: float, 
                     language: str, language_name: str, type_value: str):
    """Create JSON file in the required format"""
    
    # Create lines with timestamps
    line_objects = create_json_lines_with_timestamps(text_lines, start_minute)
    
    # Add transcripts to each line
    for i, line_obj in enumerate(line_objects):
        if i < len(transcript_lines):
            line_obj["transcript"] = transcript_lines[i]
    
    # Create JSON structure
    translation_data = {
        "language": language,
        "languageName": language_name,
        "type": type_value,
        "lines": line_objects
    }
    
    data = {
        "title": song_title,
        "artist": "Unknown",
        "originalLanguage": "en",
        "translations": [translation_data]
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"  ✓ Created JSON ({language}): {output_path}")

def create_zip_archive(zip_path: str, files: List[str]):
    """Create ZIP archive with all files"""
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file_path in files:
            if os.path.exists(file_path):
                zipf.write(file_path, os.path.basename(file_path))
    
    print(f"  ✓ Created ZIP: {zip_path}")

# Test with one song
print("=" * 60)
print("TEST: Processing single song")
print("=" * 60)

base_name = "Billie Eilish - bad guy"
original_path = os.path.join(INPUT_DIR, f"{base_name}.txt")
ru_path = os.path.join(INPUT_DIR, f"{base_name}_ru.txt")
trans_path = os.path.join(INPUT_DIR, f"{base_name}_trans.txt")

# Read all files
original_lines = read_file_content(original_path)
ru_lines = read_file_content(ru_path)
trans_lines = read_transcription_file(trans_path)

print(f"  Original lines: {len(original_lines)}")
print(f"  Russian lines: {len(ru_lines)}")
print(f"  Transcription lines: {len(trans_lines)}")

# Create output directory if needed
os.makedirs(OUTPUT_DIR, exist_ok=True)

# File paths
temp_dir = OUTPUT_DIR
lrc_path = os.path.join(temp_dir, f"{base_name}.lrc")
ru_json_path = os.path.join(temp_dir, f"{base_name}_ru.json")
trans_json_path = os.path.join(temp_dir, f"{base_name}_trans.json")
zip_path = os.path.join(OUTPUT_DIR, f"{base_name}.zip")

# Create LRC file
create_lrc_file(lrc_path, original_lines, START_MINUTE)

# Create Russian JSON (text = Russian, transcript = transcription)
create_json_file(
    ru_json_path,
    base_name,
    ru_lines,          # text = Russian translation
    trans_lines,       # transcript = transcription
    START_MINUTE,
    "ru",
    "Русский",
    ""
)

# Create Transcription JSON (text = transcription, transcript = Russian)
create_json_file(
    trans_json_path,
    base_name,
    trans_lines,       # text = transcription
    ru_lines,          # transcript = Russian translation
    START_MINUTE,
    "trans",
    "Транскрипция",
    "transcript"
)

# Create ZIP archive
create_zip_archive(zip_path, [lrc_path, ru_json_path, trans_json_path])

# Clean up temporary files
for file_path in [lrc_path, ru_json_path, trans_json_path]:
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
    except Exception:
        pass

print("\n" + "=" * 60)
print("✓ TEST COMPLETED")
print("=" * 60)

# Show first few lines of generated files
print("\nPreview of generated files:")
print("\n--- LRC (first 3 lines) ---")
with open(zip_path, 'r') as f:
    import zipfile
    with zipfile.ZipFile(zip_path, 'r') as zf:
        with zf.open(f"{base_name}.lrc") as lrc_file:
            content = lrc_file.read().decode('utf-8')
            for i, line in enumerate(content.split('\n')[:3]):
                print(f"{line}")

print("\n--- JSON structure ---")
with open(zip_path, 'r') as f:
    with zipfile.ZipFile(zip_path, 'r') as zf:
        with zf.open(f"{base_name}_ru.json") as json_file:
            content = json_file.read().decode('utf-8')
            data = json.loads(content)
            print(f"Title: {data['title']}")
            print(f"Language: {data['translations'][0]['language']}")
            print(f"Lines count: {len(data['translations'][0]['lines'])}")
            print(f"First line: {data['translations'][0]['lines'][0]}")
