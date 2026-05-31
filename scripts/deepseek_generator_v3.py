#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DeepSeek Lyrics Generator v3
Generates translations and transcriptions for song lyrics using DeepSeek API
"""

import requests
import json
import os
import zipfile
import sys
from typing import List, Dict, Tuple
import time
from dotenv import load_dotenv
from langdetect import detect

load_dotenv()

# Configuration
API_KEY = os.getenv("DEEPSEEK_API_KEY")
if not API_KEY:
    raise ValueError("DEEPSEEK_API_KEY not found in environment variables")
BASE_URL = "https://api.deepseek.com/v1"
MODEL = "deepseek-reasoner"
TIMING_STEP = 5.0  # 5 seconds per line

# Default values from command line arguments
DEFAULT_LANGUAGES = "de,en,ru,ru_literal,trans"
DEFAULT_START_MINUTE = 30.0
DEFAULT_TRANSCRIPTION_LANGUAGE = "ru"

# Languages configuration
LANGUAGE_NAMES = {
    'ro': 'Română',
    'ru': 'Русский',
    'ru_literal': 'Русский (Дословный)',
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
    'zh': '中文',
    'ar': 'العربية',
    'uk': 'Українська',
    'trans': 'Транскрипция',
}

TRANSCRIPTION_ALPHABET_NAMES = {
    'ru': 'Русскими буквами',
    'en': 'Английскими буквами',
    'de': 'Немецкими буквами',
}

def detect_source_language(text: str) -> str:
    """Detect source language from text using langdetect"""
    try:
        detected_lang = detect(text)
        # Map detected language codes to our format
        lang_map = {
            'ro': 'ro',  # Romanian
            'ru': 'ru',  # Russian
            'en': 'en',  # English
            'de': 'de',  # German
            'es': 'es',  # Spanish
            'fr': 'fr',  # French
            'it': 'it',  # Italian
            'pt': 'pt',  # Portuguese
            'uk': 'uk',  # Ukrainian
        }
        detected_code = lang_map.get(detected_lang.lower(), detected_lang)
        lang_name = LANGUAGE_NAMES.get(detected_code, detected_code) or detected_code
        print(f"✓ Detected source language: {detected_code} ({lang_name})")
        return detected_code
    except Exception as e:
        print(f"✗ Language detection failed: {e}")
        print(f"  Using default language: ro (Romanian)")
        return 'ro'

def parse_arguments():
    """Parse command line arguments"""
    languages = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_LANGUAGES
    start_minute = float(sys.argv[2]) if len(sys.argv) > 2 else DEFAULT_START_MINUTE
    transcription_language = sys.argv[3] if len(sys.argv) > 3 else DEFAULT_TRANSCRIPTION_LANGUAGE

    return languages, start_minute, transcription_language

def get_generation_prompt(text: str, languages: List[str], source_language: str = 'ro', transcription_language: str = 'ru') -> str:
    """Generate prompt for DeepSeek API"""

    # Build language descriptions
    lang_descriptions = []
    for lang in languages:
        if lang == 'trans':
            lang_descriptions.append(f"- trans: phonetic transcription in standard notation")
        elif lang == 'ru_literal':
            lang_descriptions.append(f"- ru_literal: literal word-for-word translation to Russian")
        elif lang in LANGUAGE_NAMES:
            lang_descriptions.append(f"- {lang}: poetic translation to {LANGUAGE_NAMES[lang]}")

    languages_str = '\n'.join(lang_descriptions)

    trans_alpha_name = TRANSCRIPTION_ALPHABET_NAMES.get(transcription_language, transcription_language)

    return f'''You are a professional translator and transcription expert specializing in song lyrics. Generate the following for the provided song text:

REQUEST:
Generate for these language variants:
{languages_str}

ALWAYS generate these transcriptions:
1. Transcription of original text using Russian Cyrillic letters (for ALL languages)
2. Transcription of original text using Latin letters in standard IPA-like notation (for ALL languages)
3. Transcription of original text using {trans_alpha_name} (ONLY for "trans" file in transcript field)

RULES FOR TRANSLATIONS:
- Provide natural, poetic translation suitable for singing
- Preserve emotional tone and rhythm
- Maintain the flow and style of original lyrics
- Use expressive, musical language
- Make it fit the rhythm if possible

RULES FOR TRANSCRIPTIONS:
- Russian Cyrillic: Use standard Russian phonetic conventions, represent original sounds accurately
- Latin (standard): Use standard IPA-like notation with Latin letters
- {trans_alpha_name}: Use {trans_alpha_name} to represent pronunciation
- CRITICAL: ALL transcriptions MUST preserve the exact same line structure as the source text
- Each line of source text must have a corresponding line in all transcriptions
- Use \\n characters to separate lines in JSON strings
- Do NOT merge multiple lines into single lines

CRITICAL JSON FORMAT RULES:
- Return ONLY valid JSON, no markdown, no code blocks, no explanations
- Ensure all strings are properly escaped: quotes ("), backslashes (\\), newlines (\\n), tabs (\\t)
- Do NOT use unescaped special characters in JSON strings
- All keys and string values MUST be enclosed in double quotes
- The JSON must be complete and parseable
- Do NOT truncate or cut off the response
- CRITICAL: All transcriptions MUST use \\n to separate lines matching source text structure

OPTIMIZATION: Generate transcriptions ONLY ONCE for the original text, not per language

Return ONLY valid JSON in this exact format:
{{
  "transcriptions": {{
    "ru": "...",
    "en": "...",
    "latin": "..."
  }},
  "de": {{"translation": "..."}},
  "en": {{"translation": "..."}},
  "ru": {{"translation": "..."}},
  "ru_literal": {{"translation": "..."}}
}}

NOTE:
- "transcriptions" contains ONLY THREE transcriptions of the ORIGINAL text
- Each language only has "translation", no transcriptions inside
- Transcriptions MUST use \\n line breaks to match each line of source text

SOURCE TEXT [{LANGUAGE_NAMES.get(source_language, source_language)}]:
{text}

Return ONLY the valid JSON, nothing else.'''

def save_raw_response(content: str, filename: str):
    """Save raw API response to file for debugging"""
    debug_dir = r"D:\Ai-Projects\LingoTune\debug"
    os.makedirs(debug_dir, exist_ok=True)
    debug_file = os.path.join(debug_dir, filename)
    with open(debug_file, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✓ Saved raw response to: {debug_file}")

def clean_json_content(content: str) -> str:
    """Clean and fix common JSON issues"""
    content = content.strip()

    # Remove markdown code blocks
    if content.startswith('```json'):
        content = content[7:]
    elif content.startswith('```'):
        content = content[3:]
    if content.endswith('```'):
        content = content[:-3]

    content = content.strip()

    # Fix common issues
    import re

    # Replace trailing commas before closing brackets/braces
    content = re.sub(r',(\s*[}\]])', r'\1', content)

    # Fix invalid escape sequences like \М, \С, \И (Russian letters after backslash)
    # These should just be the letters without backslash
    content = re.sub(r'\\([А-Яа-яЁё])', r'\1', content)

    # Fix escaped quotes that might be double-escaped
    content = content.replace('\\"', '"')

    return content

def generate_all_translations(text: str, languages: List[str], source_language: str, transcription_language: str) -> Dict:
    """Generate all translations and transcriptions in one API call"""
    prompt = get_generation_prompt(text, languages, source_language, transcription_language)
    raw_content = ""

    print(f"\n{'='*60}")
    print(f"Generating translations for {len(languages)} languages")
    print(f"Source language: {LANGUAGE_NAMES.get(source_language, source_language)}")
    print(f"Text length: {len(text)} characters")
    print(f"{'='*60}\n")

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
                "response_format": {"type": "json_object"},
                "max_tokens": 16000
            },
            timeout=300
        )

        if response.status_code == 200:
            data = response.json()
            choices = data.get('choices', [])
            if choices:
                raw_content = choices[0]['message']['content'].strip()

                # Save raw response for debugging
                import datetime
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                save_raw_response(raw_content, f"api_response_{timestamp}.txt")

                # Clean the content
                content = clean_json_content(raw_content)

                result = json.loads(content)
                print(f"✓ Successfully generated translations")
                return result
            else:
                print(f"✗ No choices in response")
                return {}
        else:
            print(f"✗ API Error: {response.status_code}")
            print(f"Response: {response.text}")
            return {}

    except json.JSONDecodeError as e:
        print(f"✗ JSON Parse Error: {e}")
        print(f"   Line {e.lineno}, Column {e.colno}")
        print(f"   {e.msg}")

        if raw_content:
            print(f"\n   Content length: {len(raw_content)} chars")
            print(f"   First 200 chars: {raw_content[:200]}")
            print(f"   Last 200 chars: {raw_content[-200:]}")

        return {}
    except Exception as e:
        print(f"✗ Error generating translations: {e}")
        import traceback
        traceback.print_exc()
        return {}

def parse_lines(text: str) -> List[str]:
    """Parse text into lines"""
    lines = []
    for line in text.split('\n'):
        stripped = line.strip()
        if stripped:
            lines.append(stripped)
    return lines

def create_lyric_lines_with_timestamps(lines: List[str], start_minute: float) -> List[Dict]:
    """Create lyric lines with timestamps starting from given minute"""
    lyric_lines = []
    start_time = start_minute * 60.0

    for line in lines:
        lyric_lines.append({
            "startTime": start_time,
            "text": line,
            "translatedText": None,
            "transcript": None,
            "originalStartTime": None
        })
        start_time += TIMING_STEP

    return lyric_lines

def create_translation_lines(translation: str, transcription: str, start_minute: float) -> List[Dict]:
    """Create lyric lines for translations with transcriptions"""
    lines = []
    start_time = start_minute * 60.0

    # Split translation by newlines
    lines_data = translation.split('\n')

    # Split transcription by newlines for matching
    transcription_lines = transcription.split('\n') if transcription else []

    for i, line in enumerate(lines_data):
        transcript_value = None
        if i < len(transcription_lines):
            transcript_value = transcription_lines[i].strip()

        lines.append({
            "startTime": start_time,
            "text": line,
            "translatedText": None,
            "transcript": transcript_value,
            "originalStartTime": None
        })
        start_time += TIMING_STEP

    return lines

def save_lrc_file(output_path: str, lines: List[str], start_minute: float):
    """Save lyrics to LRC file"""
    start_time = start_minute * 60.0

    with open(output_path, 'w', encoding='utf-8') as f:
        for line in lines:
            minutes = int(start_time // 60)
            seconds = int(start_time % 60)
            centiseconds = int((start_time % 1) * 100)

            f.write(f"[{minutes:02d}:{seconds:02d}.{centiseconds:02d}]{line}\n")
            start_time += TIMING_STEP

    print(f"✓ Saved LRC: {output_path}")

def save_json_file(output_path: str, song_title: str, language: str, language_name: str, type_value: str, lines: List[Dict], source_language: str = 'ro'):
    """Save translations to JSON file"""
    translation_data = {
        "language": language,
        "languageName": language_name,
        "type": type_value,
        "lines": lines
    }

    # Remove None values
    translation_data = {k: v for k, v in translation_data.items() if v is not None}

    data = {
        "title": song_title,
        "artist": "Unknown",
        "originalLanguage": source_language,
        "translations": [translation_data]
    }

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✓ Saved JSON ({language}): {output_path}")

def create_zip_archive(output_dir: str, song_title: str, files: List[str]) -> str:
    """Create ZIP archive with all generated files"""
    zip_path = os.path.join(output_dir, f"{song_title}.zip")

    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file_path in files:
            zipf.write(file_path, os.path.basename(file_path))

    print(f"✓ Created ZIP: {zip_path}")
    return zip_path

def process_song_file(input_file: str, output_dir: str, languages: List[str], start_minute: float, transcription_language: str, source_language: str, text_content: str = None):
    """Process a single song file"""
    song_name = os.path.splitext(os.path.basename(input_file))[0]
    
    print(f"\n{'='*60}")
    print(f"Processing: {song_name}")
    print(f"{'='*60}\n")
    
    # Read input file if text_content not provided
    if text_content is None:
        with open(input_file, 'r', encoding='utf-8-sig') as f:
            text = f.read()
    else:
        text = text_content
    
    lines = parse_lines(text)
    print(f"Found {len(lines)} lines\n")

    # Generate all translations
    result = generate_all_translations(text, languages, source_language, transcription_language)

    if not result:
        print(f"✗ Failed to generate translations for {song_name}")
        return

    # Generate LRC file
    lrc_path = os.path.join(output_dir, f"{song_name}.lrc")
    save_lrc_file(lrc_path, lines, start_minute)

    # Generate JSON files
    generated_files = [lrc_path]

    # Extract transcriptions from the result
    transcriptions = result.get('transcriptions', {})
    transcription_ru = transcriptions.get('ru', '')
    transcription_en = transcriptions.get('en', '')
    transcription_latin = transcriptions.get('latin', '')

    # Process translation files (skip 'trans' - it's not in API response anymore)
    for lang in languages:
        if lang == 'trans':
            continue

        if lang not in result:
            print(f"✗ Missing data for language: {lang}")
            continue

        lang_data = result[lang]
        translation = lang_data.get('translation', '')

        # Choose transcription based on language
        if lang == 'ru' or lang == 'ru_literal':
            transcript = transcription_ru
        else:
            transcript = transcription_latin

        translation_lines = create_translation_lines(
            translation,
            transcript,
            start_minute
        )

        type_value = ''
        if lang == 'ru_literal':
            type_value = 'literal'

        json_path = os.path.join(output_dir, f"{song_name}_{lang}.json")
        save_json_file(
            json_path,
            song_name,
            lang,
            LANGUAGE_NAMES.get(lang, lang),
            type_value,
            translation_lines,
            source_language
        )

        generated_files.append(json_path)

    # Create trans file using transcriptions
    if 'trans' in languages:
        # Get target language transcription based on transcription_language
        transcription_target_map = {
            'ru': transcription_ru,
            'en': transcription_en,
            'de': transcription_en,
            'es': transcription_en,
            'fr': transcription_en,
            'it': transcription_en,
            'pt': transcription_en
        }
        transcription_target = transcription_target_map.get(transcription_language, transcription_en)

        transcript_lines = create_translation_lines(
            transcription_latin,
            transcription_target,
            start_minute
        )

        json_path = os.path.join(output_dir, f"{song_name}_trans.json")
        save_json_file(
            json_path,
            song_name,
            'trans',
            LANGUAGE_NAMES.get('trans', 'Transcription'),
            'transcript',
            transcript_lines,
            source_language
        )

        generated_files.append(json_path)

    # Create ZIP archive
    zip_path = create_zip_archive(output_dir, song_name, generated_files)

    # Clean up individual files
    for file_path in generated_files:
        if file_path != zip_path:
            try:
                os.remove(file_path)
            except:
                pass

    print(f"\n✓ Successfully processed: {song_name}")

def main():
    """Main function"""
    # Parse arguments
    languages_str, start_minute, transcription_language = parse_arguments()
    languages = [lang.strip() for lang in languages_str.split(',')]

    print("=" * 60)
    print("DeepSeek Lyrics Generator v3")
    print("=" * 60)
    print(f"\nLanguages: {', '.join([LANGUAGE_NAMES.get(lang, lang) for lang in languages])}")
    print(f"Start minute: {start_minute}")
    print(f"Transcription language: {TRANSCRIPTION_ALPHABET_NAMES.get(transcription_language, transcription_language)}")

    # Directories
    input_dir = r"D:\Ai-Projects\LingoTune\input"
    output_dir = r"D:\Ai-Projects\LingoTune\output"

    if not os.path.exists(input_dir):
        print(f"\n✗ Input directory not found: {input_dir}")
        return

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"✓ Created output directory: {output_dir}")

    # Find all text files
    text_files = []
    for filename in os.listdir(input_dir):
        if filename.endswith('.txt'):
            text_files.append(os.path.join(input_dir, filename))

    if not text_files:
        print(f"\n✗ No .txt files found in input directory")
        return

    print(f"\nFound {len(text_files)} file(s) to process")
    
    # Process each file
    for input_file in text_files:
        # Read file content to detect language
        with open(input_file, 'r', encoding='utf-8-sig') as f:
            text_content = f.read()
        
        # Detect source language
        detected_language = detect_source_language(text_content)
        
        process_song_file(
            input_file,
            output_dir,
            languages,
            start_minute,
            transcription_language,
            detected_language,
            text_content  # Pass text to avoid reading twice
        )

    print("\n" + "=" * 60)
    print("✓ ALL GENERATIONS COMPLETED!")
    print("=" * 60)

if __name__ == "__main__":
    main()
