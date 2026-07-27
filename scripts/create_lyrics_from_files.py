#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Lyrics Files Generator
Creates LRC and JSON files from existing translation files
"""

import os
import json
import zipfile
from pathlib import Path
from typing import List, Dict, Tuple

# Project root (this file is in <root>/scripts/)
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Configuration
INPUT_DIR = str(PROJECT_ROOT / "input")
OUTPUT_DIR = str(PROJECT_ROOT / "output")
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

def process_song(base_name: str, original_path: str, ru_path: str, trans_path: str):
    """Process a single song"""
    print(f"\n{'='*60}")
    print(f"Processing: {base_name}")
    print(f"{'='*60}")
    
    # Read all files
    original_lines = read_file_content(original_path)
    ru_lines = read_file_content(ru_path)
    trans_lines = read_transcription_file(trans_path)
    
    print(f"  Original lines: {len(original_lines)}")
    print(f"  Russian lines: {len(ru_lines)}")
    print(f"  Transcription lines: {len(trans_lines)}")
    
    # Validate line counts
    if len(original_lines) != len(ru_lines) or len(original_lines) != len(trans_lines):
        print(f"  ⚠ Warning: Line counts don't match!")
        print(f"    Using minimum count: {min(len(original_lines), len(ru_lines), len(trans_lines))}")
        min_lines = min(len(original_lines), len(ru_lines), len(trans_lines))
        original_lines = original_lines[:min_lines]
        ru_lines = ru_lines[:min_lines]
        trans_lines = trans_lines[:min_lines]
    
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
    
    print(f"\n✓ Successfully processed: {base_name}")

def find_complete_songs(input_dir: str) -> List[Tuple[str, str, str, str]]:
    """Find all complete song file sets"""
    files = [f for f in os.listdir(input_dir) if f.endswith('.txt')]
    
    # Group by base name
    groups = {}
    for f in files:
        if f == 'INSTRUCTION_TRANSLATION.txt':
            continue
        
        base = f.split('_')[0] if '_' in f else f.replace('.txt', '')
        if base.endswith('.txt'):
            base = base.replace('.txt', '')
        
        if base not in groups:
            groups[base] = []
        groups[base].append(f)
    
    # Find complete sets
    complete_songs = []
    for base, file_list in groups.items():
        has_original = any(not ('_ru' in f or '_trans' in f) for f in file_list)
        has_ru = any('_ru' in f for f in file_list)
        has_trans = any('_trans' in f for f in file_list)
        
        if has_original and has_ru and has_trans:
            # Get full paths
            original_path = None
            ru_path = None
            trans_path = None
            
            for f in file_list:
                full_path = os.path.join(input_dir, f)
                if '_ru' in f:
                    ru_path = full_path
                elif '_trans' in f:
                    trans_path = full_path
                else:
                    original_path = full_path
            
            complete_songs.append((base, original_path, ru_path, trans_path))
    
    return complete_songs

def main():
    """Main function"""
    print("=" * 60)
    print("Lyrics Files Generator")
    print("=" * 60)
    
    # Check input directory
    if not os.path.exists(INPUT_DIR):
        print(f"\n✗ Input directory not found: {INPUT_DIR}")
        return
    
    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Find all complete songs
    complete_songs = find_complete_songs(INPUT_DIR)
    
    print(f"\nFound {len(complete_songs)} complete song(s)")
    
    if not complete_songs:
        print("\n✗ No complete song sets found!")
        return
    
    # Process each song
    success_count = 0
    for base_name, original_path, ru_path, trans_path in complete_songs:
        try:
            process_song(base_name, original_path, ru_path, trans_path)
            success_count += 1
        except Exception as e:
            print(f"\n✗ Error processing {base_name}: {e}")
            import traceback
            traceback.print_exc()
    
    print("\n" + "=" * 60)
    print(f"✓ COMPLETED: {success_count}/{len(complete_songs)} songs")
    print("=" * 60)

if __name__ == "__main__":
    main()
