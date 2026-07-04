#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Romanian Songs Processor
Creates LRC and JSON files from Romanian song texts with Russian translations
"""

import os
import json
import zipfile
import re
from pathlib import Path
from typing import List, Tuple


INPUT_DIR = Path(__file__).resolve().parent.parent / "input"
OUTPUT_DIR = Path(__file__).resolve().parent.parent / "output"
START_MINUTE = 30.0
TIME_STEP = 5.0


def parse_line(line: str) -> str:
    line = line.strip()
    
    if line.startswith('\ufeff'):
        line = line[1:]
    
    match = re.match(r'^\d+:\s*', line)
    if match:
        line = line[match.end():]
    
    line = line.strip()
    
    if not line or line.startswith('['):
        return ''
    
    return line


def is_cyrillic(text: str) -> bool:
    return any('\u0400' <= c <= '\u04FF' for c in text)


def read_txt_file(filepath: Path) -> Tuple[List[str], List[str]]:
    original_lines = []
    translation_lines = []
    
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        lines = f.readlines()
    
    parsed_lines = []
    for line in lines:
        parsed = parse_line(line)
        if not parsed:
            continue
        parsed_lines.append(parsed)
    
    for i in range(0, len(parsed_lines) - 1, 2):
        original_lines.append(parsed_lines[i])
        translation_lines.append(parsed_lines[i + 1])
    
    return original_lines, translation_lines


def format_time(seconds: float) -> str:
    minutes = int(seconds // 60)
    secs = int(seconds % 60)
    centis = int((seconds % 1) * 100)
    return f"{minutes:02d}:{secs:02d}.{centis:02d}"


def create_lrc_file(output_path: Path, lines: List[str], start_time: float):
    with open(output_path, 'w', encoding='utf-8') as f:
        current_time = start_time
        for line in lines:
            timestamp = format_time(current_time)
            f.write(f"[{timestamp}]{line}\n")
            current_time += TIME_STEP


def create_json_file(output_path: Path, song_title: str, translation_lines: List[str], start_time: float):
    lines_data = []
    current_time = start_time
    
    for line in translation_lines:
        lines_data.append({
            "startTime": round(current_time, 2),
            "text": line,
            "translatedText": None,
            "transcript": None,
            "originalStartTime": None
        })
        current_time += TIME_STEP
    
    json_data = {
        "title": song_title,
        "artist": "Unknown",
        "originalLanguage": "ro",
        "translations": [
            {
                "language": "ru",
                "languageName": "Русский",
                "type": "",
                "lines": lines_data
            }
        ]
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(json_data, f, ensure_ascii=False, indent=2)


def create_zip_archive(zip_path: Path, files: List[Path]):
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file_path in files:
            if file_path.exists():
                zipf.write(file_path, file_path.name)


def process_song(txt_file: Path) -> bool:
    print(f"\nProcessing: {txt_file.name}")
    print("-" * 50)
    
    try:
        base_name = txt_file.stem
        original_lines, translation_lines = read_txt_file(txt_file)
        
        print(f"  Original lines: {len(original_lines)}")
        print(f"  Translation lines: {len(translation_lines)}")
        
        if len(original_lines) != len(translation_lines):
            min_count = min(len(original_lines), len(translation_lines))
            print(f"  Warning: Line count mismatch, using {min_count} lines")
            original_lines = original_lines[:min_count]
            translation_lines = translation_lines[:min_count]
        
        temp_dir = OUTPUT_DIR / "temp"
        temp_dir.mkdir(parents=True, exist_ok=True)
        
        lrc_path = temp_dir / f"{base_name}.lrc"
        json_path = temp_dir / f"{base_name}_ru.json"
        zip_path = OUTPUT_DIR / f"{base_name}.zip"
        
        start_time = START_MINUTE * 60.0
        
        create_lrc_file(lrc_path, original_lines, start_time)
        print(f"  Created LRC: {lrc_path.name}")
        
        create_json_file(json_path, base_name, translation_lines, start_time)
        print(f"  Created JSON: {json_path.name}")
        
        create_zip_archive(zip_path, [lrc_path, json_path])
        print(f"  Created ZIP: {zip_path.name}")
        
        for file_path in [lrc_path, json_path]:
            if file_path.exists():
                file_path.unlink()
        
        print(f"  Success!")
        return True
        
    except Exception as e:
        print(f"  Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    print("=" * 60)
    print("Romanian Songs Processor")
    print("=" * 60)
    print(f"\nInput directory: {INPUT_DIR}")
    print(f"Output directory: {OUTPUT_DIR}")
    
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    txt_files = sorted([f for f in INPUT_DIR.glob("*.txt")])
    
    if not txt_files:
        print(f"\nNo .txt files found in {INPUT_DIR}")
        return
    
    print(f"\nFound {len(txt_files)} song files")
    print("\nProcessing...")
    
    success_count = 0
    for txt_file in txt_files:
        if process_song(txt_file):
            success_count += 1
    
    print("\n" + "=" * 60)
    print(f"Completed: {success_count}/{len(txt_files)} songs")
    print("=" * 60)
    
    temp_dir = OUTPUT_DIR / "temp"
    if temp_dir.exists():
        try:
            temp_dir.rmdir()
        except:
            pass


if __name__ == "__main__":
    main()
