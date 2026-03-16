import pandas as pd
import json
import os
import glob
from pathlib import Path

def is_cyrillic(text):
    """Check if text contains Cyrillic characters"""
    return any('\u0400' <= c <= '\u04FF' for c in text)

def format_time_code(seconds):
    """Format seconds to LRC time code [MM:SS.ss]"""
    minutes = int(seconds // 60)
    secs = seconds % 60
    return f'{minutes:02d}:{secs:05.2f}'

def process_song(input_dir='input', output_dir='output'):
    """Process song files and create LRC and JSON with auto-generated timestamps"""
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Find MP3 file
    mp3_files = glob.glob(os.path.join(input_dir, '*.mp3'))
    
    if not mp3_files:
        print('❌ No MP3 file found in input directory!')
        return False
    
    mp3_path = mp3_files[0]
    mp3_filename = os.path.basename(mp3_path)
    base_name = os.path.splitext(mp3_filename)[0]
    
    print(f'📁 Found MP3: {mp3_filename}')
    print(f'📝 Base name: {base_name}')
    
    # Read Excel file
    excel_path = os.path.join(input_dir, 'RomanianSongs.xlsx')
    if not os.path.exists(excel_path):
        print(f'❌ Excel file not found: {excel_path}')
        return False
    
    df = pd.read_excel(excel_path)
    print(f'📊 Excel file loaded: {len(df)} rows')
    
    # Parse lyrics: separate original (Romanian) and translations (Russian)
    original_lines = []
    translations = {}
    
    for i in range(len(df)):
        text = df.iloc[i, 0]
        if pd.isna(text):
            continue
        
        text_str = str(text).strip()
        if not text_str:
            continue
        
        # If it's Cyrillic, it's a translation
        if is_cyrillic(text_str):
            # Associate with previous original line
            if len(original_lines) > 0:
                translations[len(original_lines) - 1] = text_str
        else:
            # Original line
            original_lines.append(text_str)
    
    print(f'🎵 Original lines: {len(original_lines)}')
    print(f'🌍 Translations: {len(translations)}')
    
    # Generate LRC file with auto-generated timestamps
    # Each line gets +2 seconds (adjustable)
    TIME_INCREMENT = 2.0
    
    lrc_content = ""
    json_lines = []
    
    for i, original_text in enumerate(original_lines):
        start_time = i * TIME_INCREMENT
        time_code = format_time_code(start_time)
        
        # Add to LRC
        lrc_content += f'[{time_code}]{original_text}\n'
        
        # Add to JSON structure
        translation = translations.get(i, '')
        json_lines.append({
            'startTime': start_time,
            'text': translation
        })
    
    # Create JSON structure in correct format
    json_data = {
        'title': base_name,
        'artist': 'Unknown Artist',
        'originalLanguage': 'ro',
        'translations': [
            {
                'language': 'ru',
                'languageName': 'Russian',
                'lines': json_lines
            }
        ]
    }
    
    # Write LRC file
    lrc_path = os.path.join(output_dir, f'{base_name}.lrc')
    with open(lrc_path, 'w', encoding='utf-8') as f:
        f.write(lrc_content)
    print(f'✅ LRC file created: {lrc_path}')
    
    # Write JSON file
    json_path = os.path.join(output_dir, f'{base_name}.json')
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(json_data, f, ensure_ascii=False, indent=2)
    print(f'✅ JSON file created: {json_path}')
    
    # Copy MP3 to output directory
    output_mp3_path = os.path.join(output_dir, mp3_filename)
    import shutil
    shutil.copy2(mp3_path, output_mp3_path)
    print(f'✅ MP3 file copied: {output_mp3_path}')
    
    print(f'\n📁 All files ready in: {output_dir}/')
    print(f'   - {base_name}.mp3')
    print(f'   - {base_name}.lrc')
    print(f'   - {base_name}.json')
    
    return True

if __name__ == '__main__':
    print('🎵 LingoTune Song Processor')
    print('=' * 50)
    
    success = process_song()
    
    if success:
        print('\n✅ Processing completed successfully!')
    else:
        print('\n❌ Processing failed!')
