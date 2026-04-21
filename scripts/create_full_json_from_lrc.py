"""
Создание полного JSON файла из LRC файла
"""

import re
from pathlib import Path

def parse_lrc_file(lrc_path):
    """
    Парсинг LRC файла и извлечение строк с временными метками
    """
    with open(lrc_path, 'r', encoding='utf-8') as f:
        content = f.read()

    lines_data = []
    for line in content.split('\n'):
        match = re.search(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]\s*(.*)', line)
        if match:
            minutes = int(match.group(1))
            seconds = int(match.group(2))
            fraction = match.group(3)
            milliseconds = int(fraction) * 10 if len(fraction) == 2 else int(fraction)
            total_seconds = minutes * 60 + seconds + milliseconds / 1000.0
            text = match.group(4).strip()

            lines_data.append({
                'time': total_seconds,
                'text': text
            })

    return lines_data

def create_json_file(lrc_path, json_path, title, artist):
    """
    Создание JSON файла в правильном формате
    """
    lines_data = parse_lrc_file(lrc_path)

    data = {
        'title': title,
        'artist': artist,
        'originalLanguage': 'Romanian',
        'translations': [
            {
                'language': 'ru',
                'languageName': 'Russian',
                'lines': [
                    {
                        'startTime': line['time'],
                        'text': ''  # Пустой перевод для редактирования
                    }
                    for line in lines_data
                ]
            }
        ]
    }

    with open(json_path, 'w', encoding='utf-8') as f:
        import json
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"JSON создан: {json_path}")
    print(f"Всего строк: {len(lines_data)}")


if __name__ == '__main__':
    lrc_path = Path('../temp/test_song/Alexia_x_Spike_-_Infinituri_auto_sync.lrc')
    json_path = Path('../output/Alexia - Infinituri Ft Spike.json')

    if not lrc_path.exists():
        print(f"LRC файл не найден: {lrc_path}")
        exit(1)

    create_json_file(lrc_path, json_path, 'Alexia - Infinituri Ft Spike', 'Alexia x Spike')
