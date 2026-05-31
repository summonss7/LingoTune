#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Arabic Songs Generator for SUNO
Generates educational Arabic songs and SUNO prompts using DeepSeek API
"""

import requests
import json
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

# Configuration
API_KEY = os.getenv("DEEPSEEK_API_KEY")
if not API_KEY:
    raise ValueError("DEEPSEEK_API_KEY not found in environment variables")
BASE_URL = "https://api.deepseek.com/v1"
MODEL = "deepseek-reasoner"

# Directory paths
PROMPTS_DIR = r"D:\Ai-Projects\LingoTune\prompts\arabic"
LYRICS_DIR = r"D:\Ai-Projects\LingoTune\lyrics\arabic"

# Ensure directories exist
os.makedirs(PROMPTS_DIR, exist_ok=True)
os.makedirs(LYRICS_DIR, exist_ok=True)

# Song configurations
SONGS_CONFIG = [
    {
        "id": "01",
        "name": "Alphabet Song",
        "arabic_name": "أغنية الحروف الأبجدية",
        "theme": "Arabic alphabet with word examples",
        "instruments": "acoustic guitar, drums, duduk, violin",
        "tempo_bpm": 70,
        "description": "Teaching all 28 letters of the Arabic alphabet with one word example for each letter"
    },
    {
        "id": "02",
        "name": "Numbers Song",
        "arabic_name": "أغنية الأرقام",
        "theme": "Numbers 1-10, 11-20, 30, 40, 100, 1000 in context",
        "instruments": "electric guitar, drums, flute, cello",
        "tempo_bpm": 75,
        "description": "Teaching essential numbers with examples of usage"
    },
    {
        "id": "03",
        "name": "Greetings Song",
        "arabic_name": "أغنية التحيات",
        "theme": "Common greetings and salutations",
        "instruments": "acoustic guitar, drums, violin, organ",
        "tempo_bpm": 72,
        "description": "Teaching essential greetings for meeting people"
    },
    {
        "id": "04",
        "name": "Politeness Phrases Song",
        "arabic_name": "أغنية عبارات اللطف",
        "theme": "Polite expressions and courtesy",
        "instruments": "electric guitar, drums, duduk, cello",
        "tempo_bpm": 68,
        "description": "Teaching polite phrases for everyday communication"
    }
]

def generate_suno_prompt(song_config):
    """Generate detailed SUNO prompt for the song"""

    prompt = f'''[Genre: Egyptian Folk Rock]

[Musical Style]
- Tempo: {song_config['tempo_bpm']} BPM (slow to moderate for clear pronunciation)
- Instruments: {song_config['instruments']}
- Mood: Educational but musical, memorable and engaging
- Structure: Verse-chorus format with repetition for learning
- Instrumental sections: Can be faster/more energetic
- Overall style: Rock fusion with Middle Eastern elements

[Vocal Requirements]
- Language: Egyptian Arabic (Masry dialect) - IMPORTANT
- Pronunciation: VERY CLEAR and distinct - do NOT break words into syllables
- Tempo: Slow to moderate vocals, allow for clear enunciation of each word
- Style: Melodic, natural, not robotic
- Emphasis: Each word must be distinctly audible
- Delivery: Smooth flow between words, no choppy or broken syllables

[Theme]
{song_config['description']}

[Length]
3-4 minutes

[Structure]
- Intro: Short instrumental (10-15 seconds)
- Verse 1: Present 4-6 phrases/concepts
- Chorus: Reinforce learning with repetition
- Verse 2: Present 4-6 new phrases/concepts
- Chorus: Same as before
- Bridge: Review key concepts
- Final Chorus: Reinforce all learning
- Outro: Soft instrumental fade

[SPECIAL INSTRUCTIONS FOR SUNO]
1. Use ONLY Egyptian Arabic dialect (Masry), not MSA (Modern Standard Arabic)
2. Pronunciation must be crystal clear - imagine teaching a beginner
3. Do NOT break words into syllables - sing complete words smoothly
4. Use natural Egyptian pronunciation patterns
5. Each phrase should be easy to hear and understand
6. Vocals should be prominent in the mix
7. Background music should not overpower the vocals

[LYRICS - Egyptian Arabic]
(WAIT FOR LYRICS TO BE GENERATED)'''

    return prompt

def get_song_generation_prompt(song_config):
    """Generate prompt for DeepSeek to create Arabic lyrics"""

    prompt = f'''You are an expert Arabic language teacher and songwriter specializing in Egyptian Arabic (Masry dialect). Create an educational song for beginners learning Arabic.

SONG INFORMATION:
- Song Title: {song_config['name']}
- Theme: {song_config['theme']}
- Description: {song_config['description']}
- Target Level: Complete beginners (A0-A1)
- Dialect: Egyptian Arabic (Masry) - CRITICAL - do NOT use MSA

REQUIREMENTS:
1. Language: Egyptian Arabic ONLY - use colloquial Egyptian expressions
2. Structure: Verse-chorus format with repetition
3. Length: 12-16 lines total (suitable for 3-4 minute song)
4. Difficulty: Very simple, clear, easy to pronounce
5. Format: Line-by-line, not paragraphs

LYRICS FORMAT:
Provide the Arabic lyrics in this exact format:

[ARABIC LYRICS]
Line 1 in Egyptian Arabic
Line 2 in Egyptian Arabic
Line 3 in Egyptian Arabic
...

[TRANSLATION TO RUSSIAN]
Russian translation of line 1
Russian translation of line 2
Russian translation of line 3
...

[PRONUNCIATION GUIDE - IPA]
IPA transcription of line 1
IPA transcription of line 2
IPA transcription of line 3
...

IMPORTANT RULES:
- Use ONLY Egyptian Arabic colloquial expressions (masry)
- DO NOT use MSA (Modern Standard Arabic)
- Keep phrases short and simple (3-5 words per line)
- Include repetition for memorization
- Make it melodic and natural, not robotic
- Each line should be complete and meaningful
- Use common, everyday expressions
- Include some simple rhyming where possible

Theme details: {song_config['description']}

Generate the complete song now.'''

    return prompt

def call_deepseek_api(prompt):
    """Call DeepSeek API to generate lyrics"""

    print(f"\n{'='*60}")
    print("Calling DeepSeek API...")
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
                "temperature": 0.8,
                "max_tokens": 4000
            },
            timeout=300
        )

        if response.status_code == 200:
            data = response.json()
            choices = data.get('choices', [])
            if choices:
                content = choices[0]['message']['content']
                print(f"✓ Successfully generated lyrics")
                return content
            else:
                print(f"✗ No choices in response")
                return None
        else:
            print(f"✗ API Error: {response.status_code}")
            print(f"Response: {response.text}")
            return None

    except Exception as e:
        print(f"✗ Error calling DeepSeek API: {e}")
        return None

def parse_lyrics_response(response_text):
    """Parse the DeepSeek response to extract Arabic lyrics, Russian translation, and IPA"""

    arabic_lines = []
    russian_lines = []
    ipa_lines = []

    current_section = None

    for line in response_text.split('\n'):
        line = line.strip()

        if line.startswith('[ARABIC LYRICS]'):
            current_section = 'arabic'
            continue
        elif line.startswith('[TRANSLATION TO RUSSIAN]') or line.startswith('[RUSSIAN TRANSLATION]'):
            current_section = 'russian'
            continue
        elif line.startswith('[PRONUNCIATION GUIDE - IPA]') or line.startswith('[IPA]'):
            current_section = 'ipa'
            continue
        elif line.startswith('[') and line.endswith(']'):
            continue

        if line and current_section:
            if current_section == 'arabic':
                arabic_lines.append(line)
            elif current_section == 'russian':
                russian_lines.append(line)
            elif current_section == 'ipa':
                ipa_lines.append(line)

    return arabic_lines, russian_lines, ipa_lines

def save_lyrics_files(song_config, arabic_lines, russian_lines, ipa_lines):
    """Save lyrics files in the lyrics directory"""

    song_id = song_config['id']
    base_filename = f"{song_id}-{song_config['name'].replace(' ', '-')}"

    # Save Arabic lyrics
    arabic_file = os.path.join(LYRICS_DIR, f"{base_filename}-arabic.txt")
    with open(arabic_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(arabic_lines))
    print(f"✓ Saved Arabic: {arabic_file}")

    # Save Russian translation
    russian_file = os.path.join(LYRICS_DIR, f"{base_filename}-russian.txt")
    with open(russian_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(russian_lines))
    print(f"✓ Saved Russian: {russian_file}")

    # Save IPA transcription
    ipa_file = os.path.join(LYRICS_DIR, f"{base_filename}-ipa.txt")
    with open(ipa_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(ipa_lines))
    print(f"✓ Saved IPA: {ipa_file}")

    return {
        'arabic': arabic_file,
        'russian': russian_file,
        'ipa': ipa_file
    }

def save_suno_prompt_file(song_config, arabic_lines):
    """Save complete SUNO prompt file"""

    song_id = song_config['id']
    suno_prompt = generate_suno_prompt(song_config)

    # Add Arabic lyrics to the prompt
    lyrics_text = '\n'.join(arabic_lines)
    suno_prompt = suno_prompt.replace('(WAIT FOR LYRICS TO BE GENERATED)', lyrics_text)

    prompt_file = os.path.join(PROMPTS_DIR, f"{song_id}-{song_config['name'].replace(' ', '-')}-suno-prompt.txt")
    with open(prompt_file, 'w', encoding='utf-8') as f:
        f.write(suno_prompt)
    print(f"✓ Saved SUNO prompt: {prompt_file}")

    return prompt_file

def generate_song(song_config):
    """Generate complete song (lyrics + SUNO prompt)"""

    print(f"\n{'='*70}")
    print(f"Generating: {song_config['id']}. {song_config['name']}")
    print(f"{'='*70}\n")

    # Generate lyrics using DeepSeek
    generation_prompt = get_song_generation_prompt(song_config)
    response = call_deepseek_api(generation_prompt)

    if not response:
        print(f"✗ Failed to generate lyrics for {song_config['name']}")
        return None

    # Parse response
    arabic_lines, russian_lines, ipa_lines = parse_lyrics_response(response)

    if not arabic_lines:
        print(f"✗ Failed to parse Arabic lyrics for {song_config['name']}")
        return None

    print(f"  Generated {len(arabic_lines)} lines of Arabic lyrics\n")

    # Save lyrics files
    lyrics_files = save_lyrics_files(song_config, arabic_lines, russian_lines, ipa_lines)

    # Save SUNO prompt
    prompt_file = save_suno_prompt_file(song_config, arabic_lines)

    return {
        'config': song_config,
        'arabic_lines': arabic_lines,
        'russian_lines': russian_lines,
        'ipa_lines': ipa_lines,
        'files': lyrics_files,
        'suno_prompt': prompt_file
    }

def main():
    """Main function to generate all songs"""

    print("=" * 70)
    print("Arabic Songs Generator for SUNO")
    print("=" * 70)
    print(f"\nModel: {MODEL}")
    print(f"Songs to generate: {len(SONGS_CONFIG)}")
    print(f"Output directory: {LYRICS_DIR}")
    print(f"Prompts directory: {PROMPTS_DIR}\n")

    # Generate all songs
    results = []
    for song_config in SONGS_CONFIG:
        result = generate_song(song_config)
        if result:
            results.append(result)

    print("\n" + "=" * 70)
    print(f"✓ COMPLETED: Generated {len(results)}/{len(SONGS_CONFIG)} songs")
    print("=" * 70)

    # Print summary
    print("\n📋 Generated Songs:")
    for result in results:
        print(f"  ✓ {result['config']['id']}. {result['config']['name']}")

    print(f"\n📁 Files saved in:")
    print(f"  - Lyrics: {LYRICS_DIR}")
    print(f"  - SUNO prompts: {PROMPTS_DIR}")
    print(f"\n🎯 Next step: Use SUNO prompts to generate music")
    print(f"   Then run arabic_lrc_generator.py to create LRC, JSON, ZIP files\n")

if __name__ == "__main__":
    main()
