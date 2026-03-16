#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DeepSeek Lyrics Generator
Generates translations for lyrics using DeepSeek API
"""

import requests
import json
import os
from typing import List, Dict
import time
from dotenv import load_dotenv

load_dotenv()

# Configuration
API_KEY = os.getenv("DEEPSEEK_API_KEY")
if not API_KEY:
    raise ValueError("DEEPSEEK_API_KEY not found in environment variables")
BASE_URL = "https://api.deepseek.com/v1"
MODEL = "deepseek-chat"
DEFAULT_START_TIME = 1800.0  # 30:00.00
TIMING_STEP = 5.0  # 5 seconds per line

# Languages configuration
LANGUAGES = {
    'trans': 'Транскрипция',
    'ru': 'Русский',
    'ru_literal': 'Русский дословный',
    'en': 'English',
    'de': 'German',
}

LANGUAGE_NAMES = {
    'ro': 'Romanian',
    'ru': 'Russian',
    'ru_literal': 'Russian (Literal)',
    'en': 'English',
    'de': 'German',
    'trans': 'Transcription',
}

def get_prompt(source_lang: str, target_lang: str, text: str, translation_type: str = None) -> str:
    """Generate prompt for DeepSeek API"""
    if translation_type == 'transcript':
        return f'''You are a professional phonetic transcription expert. Your task is to create a phonetic transcription of Romanian text using Russian letters (transliteration).

Rules:
1. Use Russian Cyrillic letters to represent Romanian sounds
2. Keep the pronunciation natural and accurate
3. Use standard Russian phonetic conventions
4. Preserve word boundaries with spaces
5. Do not add any explanations, just return the transcription

Source text (Romanian):
{text}

Return ONLY the phonetic transcription using Russian letters, nothing else.'''
    
    if translation_type == 'literal':
        return f'''You are a professional translator specializing in literal (word-for-word) translation. Your task is to translate the following Romanian text to Russian as literally as possible.

Rules:
1. Translate word-for-word where possible
2. Maintain the exact word order of the original
3. Preserve grammatical structure
4. Use literal meaning even if it sounds awkward
5. Do not localize or adapt idioms
6. Return ONLY the translation, nothing else

Source text (Romanian):
{text}

Return ONLY the literal Russian translation, nothing else.'''
    
    return f'''You are a professional translator specializing in songs and poetry. Your task is to translate the following Romanian text to {target_lang} while preserving the poetic style and emotional tone.

Rules:
1. Maintain the poetic flow and rhythm
2. Preserve the emotional meaning and intent
3. Use natural, expressive language
4. Adapt idioms appropriately
5. Keep the translation concise and powerful
6. Return ONLY the translation, nothing else

Source text (Romanian):
{text}

Return ONLY the {target_lang} translation, nothing else.'''

def translate_text(text: str, source_lang: str = 'ro', target_lang: str = 'ru', 
                translation_type: str = None, max_retries: int = 3) -> str:
    """Translate a single text using DeepSeek API"""
    if not text.strip():
        return ""
    
    prompt = get_prompt(source_lang, target_lang, text, translation_type)
    
    for attempt in range(max_retries):
        try:
            response = requests.post(
                f"{BASE_URL}/chat/completions",
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {API_KEY}"
                },
                json={
                    "model": MODEL,
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": 0.7,
                    "max_tokens": 500
                },
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                choices = data.get('choices', [])
                if choices:
                    return choices[0]['message']['content'].strip()
            else:
                print(f"  API Error: {response.status_code} - {response.text}")
        
        except Exception as e:
            print(f"  Attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                time.sleep(1)
    
    return ""

def generate_translations(lines: List[str], languages: List[str]) -> Dict[str, List[str]]:
    """Generate translations for all lines in all requested languages"""
    translations = {}
    total_requests = len(lines) * len(languages)
    current_request = 0
    
    print(f"\nGenerating translations for {len(lines)} lines in {len(languages)} languages")
    print(f"Total requests: {total_requests}\n")
    
    for lang in languages:
        print(f"\n=== Generating {LANGUAGE_NAMES.get(lang, lang)} ===")
        
        translation_type = None
        target_lang = lang
        
        if lang == 'trans':
            translation_type = 'transcript'
            target_lang = 'ro'
        elif lang == 'ru_literal':
            translation_type = 'literal'
            target_lang = 'ru'
        
        lang_translations = []
        for i, line in enumerate(lines):
            current_request += 1
            progress = (current_request / total_requests) * 100
            print(f"  [{progress:.1f}%] Line {i+1}/{len(lines)}: {line[:40]}...", end='\r')
            
            translation = translate_text(
                text=line,
                source_lang='ro',
                target_lang=target_lang,
                translation_type=translation_type
            )
            
            lang_translations.append(translation)
            time.sleep(0.1)  # Rate limiting
        
        translations[lang] = lang_translations
        print(f"\n  ✓ Completed {LANGUAGE_NAMES.get(lang, lang)}")
    
    return translations

def create_lyric_lines(lines: List[str]) -> List[Dict]:
    """Create lyric lines with timings starting from 30:00.00"""
    lyric_lines = []
    start_time = DEFAULT_START_TIME
    
    for line in lines:
        if line.strip():
            lyric_lines.append({
                "startTime": start_time,
                "text": line,
                "translatedText": None,
                "transcript": None,
                "originalStartTime": None
            })
            start_time += TIMING_STEP
    
    return lyric_lines

def save_json_file(output_path: str, song_title: str, original_lang: str, 
                  translations: Dict[str, List[str]]):
    """Save translations to JSON file"""
    data = {
        "title": song_title,
        "artist": "Unknown",
        "originalLanguage": original_lang,
        "translations": []
    }
    
    for lang, texts in translations.items():
        lyric_lines = create_lyric_lines(texts)
        
        translation_type = None
        if lang == 'trans':
            translation_type = 'transcript'
        elif lang == 'ru_literal':
            translation_type = 'literal'
        
        data["translations"].append({
            "language": lang,
            "languageName": LANGUAGES.get(lang, lang),
            "type": translation_type,
            "lines": lyric_lines
        })
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✓ Saved: {output_path}")

def save_lrc_file(output_path: str, lines: List[str]):
    """Save lyrics to LRC file"""
    start_time = DEFAULT_START_TIME
    
    with open(output_path, 'w', encoding='utf-8') as f:
        for line in lines:
            if line.strip():
                adjusted_time = start_time - 1800.0
                minutes = int(adjusted_time // 60)
                seconds = int(adjusted_time % 60)
                centiseconds = int((adjusted_time % 1) * 100)
                
                f.write(f"[{minutes:02d}:{seconds:02d}.{centiseconds:02d}]{line}\n")
                start_time += TIMING_STEP
    
    print(f"✓ Saved: {output_path}")

def main():
    """Main function"""
    # Read input file
    input_file = r"D:\ProjectAI\LingoTune\input\Alexia - Două Linii.txt"
    output_dir = r"D:\ProjectAI\LingoTune\output"
    song_title = "Alexia - Două Linii"
    
    print("=" * 60)
    print("DeepSeek Lyrics Generator")
    print("=" * 60)
    print(f"\nInput file: {input_file}")
    print(f"Output directory: {output_dir}")
    print(f"Song title: {song_title}")
    
    # Read lines
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip() and not line.startswith('﻿')]
    
    print(f"Lines found: {len(lines)}")
    
    # Generate translations
    languages = ['trans', 'ru', 'ru_literal', 'en', 'de']
    translations = generate_translations(lines, languages)
    
    # Save files
    print("\n" + "=" * 60)
    print("Saving files...")
    print("=" * 60)
    
    # Save LRC file
    lrc_path = os.path.join(output_dir, f"{song_title}.lrc")
    save_lrc_file(lrc_path, lines)
    
    # Save JSON files for each language
    for lang in languages:
        lang_translations = {lang: translations[lang]}
        json_path = os.path.join(output_dir, f"{song_title}_{lang}.json")
        save_json_file(json_path, song_title, 'ro', lang_translations)
    
    print("\n" + "=" * 60)
    print("✓ Generation completed successfully!")
    print("=" * 60)

if __name__ == "__main__":
    main()
