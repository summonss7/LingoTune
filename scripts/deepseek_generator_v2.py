#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DeepSeek Lyrics Generator v2
Generates translations with transcriptions using DeepSeek API
"""

import requests
import json
import os
import zipfile
from typing import List, Dict, Tuple
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

# Transcription alphabet for different languages
TRANSCRIPTION_ALPHABET = {
    'ru': 'cyrillic',  # Russian -> Cyrillic
    'ru_literal': 'cyrillic',  # Russian literal -> Cyrillic
    'en': 'latin',  # English -> Latin
    'de': 'latin',  # German -> Latin
    'es': 'latin',
    'fr': 'latin',
    'it': 'latin',
    'pt': 'latin',
    'zh': 'latin',
    'ar': 'latin',
    'uk': 'cyrillic',
    'default': 'latin',
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

def get_transcription_prompt(text: str, alphabet: str = 'latin') -> str:
    """Generate prompt for transcription"""
    if alphabet == 'cyrillic':
        letters = "Russian Cyrillic letters"
    else:
        letters = "Latin letters"
    
    return f'''Create a phonetic transcription of the following text using {letters}.

Rules:
1. Use {letters}
2. Keep the pronunciation natural and accurate
3. Preserve word boundaries with spaces
4. Do not add any explanations

Text:
{text}

Return ONLY the transcription, nothing else.'''

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

def translate_with_transcription(text: str, source_lang: str, target_lang: str, 
                              translation_type: str = None, 
                              transcription_alphabet: str = 'latin') -> Tuple[str, str]:
    """Translate text and generate transcription in parallel"""
    if not text.strip():
        return "", ""
    
    # Get translation
    translation = translate_text(
        text=text,
        source_lang=source_lang,
        target_lang=target_lang,
        translation_type=translation_type
    )
    
    # Generate transcription for the translation
    if translation.strip():
        transcript_prompt = get_transcription_prompt(translation, transcription_alphabet)
        
        for attempt in range(3):
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
                                "content": transcript_prompt
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
                        transcription = choices[0]['message']['content'].strip()
                        return translation, transcription
                else:
                    print(f"  Transcription API Error: {response.status_code}")
            except Exception as e:
                print(f"  Transcription attempt {attempt + 1} failed: {e}")
                if attempt < 2:
                    time.sleep(1)
    
    return translation, ""

def generate_translations(lines: List[str], languages: List[str]) -> Dict[str, Dict[str, List[str]]]:
    """Generate translations and transcriptions for all lines in all requested languages
    
    Returns:
        {
            'trans': {'translations': [...], 'transcriptions': []},
            'ru': {'translations': [...], 'transcriptions': [...]},
            ...
        }
    """
    results = {}
    total_requests = len(lines) * len(languages)
    current_request = 0
    
    print(f"\nGenerating translations for {len(lines)} lines in {len(languages)} languages")
    print(f"Total requests: {total_requests}\n")
    
    for lang in languages:
        print(f"\n=== Generating {LANGUAGE_NAMES.get(lang, lang)} ===")
        
        translation_type = None
        target_lang = lang
        transcription_alphabet = TRANSCRIPTION_ALPHABET.get(lang, 'latin')
        
        if lang == 'trans':
            translation_type = 'transcript'
            target_lang = 'ro'
        elif lang == 'ru_literal':
            translation_type = 'literal'
            target_lang = 'ru'
        
        if lang == 'trans':
            # For 'trans', only generate transcription (no translation needed)
            lang_translations = []
            for i, line in enumerate(lines):
                current_request += 1
                progress = (current_request / total_requests) * 100
                print(f"  [{progress:.1f}%] Line {i+1}/{len(lines)}: {line[:40]}...", end='\r')
                
                transcription = translate_text(
                    text=line,
                    source_lang='ro',
                    target_lang='ru',
                    translation_type='transcript'
                )
                
                lang_translations.append(transcription)
                time.sleep(0.1)
            
            results[lang] = {'translations': lang_translations, 'transcriptions': []}
        else:
            # For other languages, generate translation + transcription in parallel
            lang_translations = []
            lang_transcriptions = []
            
            for i, line in enumerate(lines):
                current_request += 1
                progress = (current_request / total_requests) * 100
                print(f"  [{progress:.1f}%] Line {i+1}/{len(lines)}: {line[:40]}...", end='\r')
                
                translation, transcription = translate_with_transcription(
                    text=line,
                    source_lang='ro',
                    target_lang=target_lang,
                    translation_type=translation_type,
                    transcription_alphabet=transcription_alphabet
                )
                
                lang_translations.append(translation)
                lang_transcriptions.append(transcription)
                time.sleep(0.1)
            
            results[lang] = {
                'translations': lang_translations,
                'transcriptions': lang_transcriptions
            }
        
        print(f"\n  ✓ Completed {LANGUAGE_NAMES.get(lang, lang)}")
    
    return results

def create_lyric_lines(lines: List[str], use_text_field: bool = True) -> List[Dict]:
    """Create lyric lines with timings starting from 30:00.00"""
    lyric_lines = []
    start_time = DEFAULT_START_TIME
    
    for line in lines:
        if line.strip():
            if use_text_field:
                lyric_lines.append({
                    "startTime": start_time,
                    "text": line,
                    "translatedText": None,
                    "transcript": None,
                    "originalStartTime": None
                })
            else:
                lyric_lines.append({
                    "startTime": start_time,
                    "text": "",
                    "translatedText": None,
                    "transcript": line,
                    "originalStartTime": None
                })
            start_time += TIMING_STEP
    
    return lyric_lines

def create_translation_lines(translations: List[str], transcriptions: List[str]) -> List[Dict]:
    """Create lyric lines for translations with transcriptions"""
    lyric_lines = []
    start_time = DEFAULT_START_TIME
    
    for translation, transcript in zip(translations, transcriptions):
        if translation.strip() or transcript.strip():
            lyric_lines.append({
                "startTime": start_time,
                "text": translation,
                "translatedText": None,
                "transcript": transcript,
                "originalStartTime": None
            })
            start_time += TIMING_STEP
    
    return lyric_lines

def save_json_file(output_path: str, song_title: str, original_lang: str, 
                  translations: Dict[str, Dict[str, List[str]]]):
    """Save translations to JSON file"""
    data = {
        "title": song_title,
        "artist": "Unknown",
        "originalLanguage": original_lang,
        "translations": []
    }
    
    for lang, lang_data in translations.items():
        if lang == 'trans':
            # For 'trans' type - use text field for transcription
            lines = create_lyric_lines(lang_data['translations'], use_text_field=True)
            data["translations"].append({
                "language": lang,
                "languageName": LANGUAGES.get(lang, lang),
                "type": "transcript",
                "lines": lines
            })
        else:
            # For other languages - use text for translation, transcript field for transcription
            lines = create_translation_lines(
                lang_data['translations'],
                lang_data['transcriptions']
            )
            
            translation_type = None
            if lang == 'ru_literal':
                translation_type = 'literal'
            
            data["translations"].append({
                "language": lang,
                "languageName": LANGUAGES.get(lang, lang),
                "type": translation_type,
                "lines": lines
            })
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✓ Saved: {output_path}")

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

def create_zip_archive(output_dir: str, song_title: str, json_files: List[str], lrc_file: str):
    """Create ZIP archive with all generated files"""
    zip_path = os.path.join(output_dir, f"{song_title}.zip")
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for json_file in json_files:
            zipf.write(json_file, os.path.basename(json_file))
        if lrc_file:
            zipf.write(lrc_file, os.path.basename(lrc_file))
    
    print(f"✓ Created ZIP: {zip_path}")
    return zip_path

def main():
    """Main function"""
    # Read input file
    input_file = r"D:\ProjectAI\LingoTune\input\Alexia - Două Linii.txt"
    output_dir = r"D:\ProjectAI\LingoTune\output"
    song_title = "Alexia - Două Linii"
    
    print("=" * 60)
    print("DeepSeek Lyrics Generator v2")
    print("=" * 60)
    print(f"\nInput file: {input_file}")
    print(f"Output directory: {output_dir}")
    print(f"Song title: {song_title}")
    
    # Read lines
    with open(input_file, 'r', encoding='utf-8') as f:
        lines = [line.strip() for line in f if line.strip() and not line.startswith('﻿')]
    
    print(f"Lines found: {len(lines)}")
    
    # Generate translations with transcriptions
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
    json_files = []
    for lang in languages:
        lang_translations = {lang: translations[lang]}
        json_path = os.path.join(output_dir, f"{song_title}_{lang}.json")
        save_json_file(json_path, song_title, 'ro', lang_translations)
        json_files.append(json_path)
    
    # Create ZIP archive
    create_zip_archive(output_dir, song_title, json_files, lrc_path)
    
    print("\n" + "=" * 60)
    print("✓ Generation completed successfully!")
    print("=" * 60)

if __name__ == "__main__":
    main()
