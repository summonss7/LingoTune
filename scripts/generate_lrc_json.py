import json
import os
from pathlib import Path


def seconds_to_lrc_time(seconds):
    minutes = int(seconds // 60)
    remaining_seconds = seconds % 60
    secs = int(remaining_seconds)
    centis = int((remaining_seconds - secs) * 100)
    return f"{minutes:02d}:{secs:02d}.{centis:02d}"


def process_txt_file(txt_path, output_dir):
    base_name = txt_path.stem
    
    with open(txt_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    lines = [line.strip() for line in lines if line.strip()]
    
    romanian_lines = []
    russian_lines = []
    
    for i, line in enumerate(lines):
        if i % 2 == 0:
            romanian_lines.append(line)
        else:
            russian_lines.append(line)
    
    lrc_lines = []
    json_lines = []
    start_time = 900.0
    interval = 10.0
    
    for i, (ro_text, ru_text) in enumerate(zip(romanian_lines, russian_lines)):
        current_time = start_time + i * interval
        lrc_time = seconds_to_lrc_time(current_time)
        lrc_lines.append(f"[{lrc_time}]{ro_text}")
        json_lines.append({
            "startTime": round(current_time, 2),
            "text": ru_text
        })
    
    lrc_path = output_dir / f"{base_name}.lrc"
    with open(lrc_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lrc_lines))
    
    json_data = {
        "title": base_name,
        "artist": "",
        "originalLanguage": "ro",
        "translations": [
            {
                "language": "ru",
                "languageName": "Russian",
                "lines": json_lines
            }
        ]
    }
    
    json_path = output_dir / f"{base_name}.json"
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(json_data, f, ensure_ascii=False, indent=2)
    
    print(f"✓ {base_name}: {len(lrc_lines)} lines processed")


def main():
    input_dir = Path("D:/Ai-Projects/LingoTune/input/best")
    output_dir = Path("D:/Ai-Projects/LingoTune/output")
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    txt_files = sorted(input_dir.glob("*.txt"))
    
    if not txt_files:
        print("No .txt files found in input directory!")
        return
    
    print(f"Processing {len(txt_files)} files...")
    print(f"Input: {input_dir}")
    print(f"Output: {output_dir}")
    print("-" * 50)
    
    for txt_file in txt_files:
        try:
            process_txt_file(txt_file, output_dir)
        except Exception as e:
            print(f"✗ Error processing {txt_file.name}: {e}")
    
    print("-" * 50)
    print(f"Done! Created {len(txt_files) * 2} files in {output_dir}")


if __name__ == "__main__":
    main()
