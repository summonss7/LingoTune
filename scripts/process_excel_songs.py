"""
Скрипт для обработки RomanianSongs.xlsx
Автоматизирует процесс подготовки песен для LingoTune

Требования: pip install openpyxl
"""

from pathlib import Path
import sys


def read_excel_songs(excel_path):
    from openpyxl import load_workbook

    """
    Чтение Excel файла с песнями

    Ожидаемые столбцы:
    - A: Song Name
    - B: Artist
    - C: Original Lyrics
    - D: Translation (опционально)
    - E: Language (опционально)
    """
    try:
        wb = load_workbook(excel_path)
        ws = wb.active

        songs = []

        # Пропускаем заголовки (первая строка)
        for row in ws.iter_rows(min_row=2, values_only=True):
            # Проверяем, что строка не пустая
            if not row or all(cell is None for cell in row):
                continue

            song = {
                'name': str(row[0]) if len(row) > 0 and row[0] is not None else '',
                'artist': str(row[1]) if len(row) > 1 and row[1] is not None else '',
                'lyrics': str(row[2]) if len(row) > 2 and row[2] is not None else '',
                'translation': str(row[3]) if len(row) > 3 and row[3] is not None else '',
                'language': str(row[4]) if len(row) > 4 and row[4] is not None else 'Romanian',
            }

            # Подсчет строк текста
            lyrics_text = song['lyrics']
            if lyrics_text:
                lines = [line for line in lyrics_text.split('\n') if line.strip()]
                song['lines'] = len(lines)
            else:
                song['lines'] = 0

            if song['name'] and song['artist']:
                songs.append(song)

        return songs
    except Exception as e:
        print(f"Ошибка чтения Excel: {e}")
        import traceback
        traceback.print_exc()
        return []


def generate_youtube_dl_script(songs, output_path):
    """
    Генерация скрипта для скачивания MP3 с YouTube
    """
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('#!/bin/bash\n')
        f.write('# Скрипт для скачивания MP3 файлов с YouTube\n')
        f.write('# Требуется yt-dlp: pip install yt-dlp\n\n\n')
        f.write('cd input\n\n')

        for i, song in enumerate(songs, 1):
            search_query = f"{song['artist']} - {song['name']}"
            filename = f"{song['name']} - {song['artist']}.mp3"

            f.write(f'# Песня {i}: {search_query}\n')
            f.write(f'yt-dlp -x --audio-format mp3 --audio-quality 0 -o "{filename}" "ytsearch1:{search_query}"\n')
            f.write('\n')

    print(f"Скрипт создан: {output_path}")


def generate_lyrics_file(songs, output_path):
    """
    Генерация текстового файла с текстами всех песен
    """
    with open(output_path, 'w', encoding='utf-8') as f:
        for i, song in enumerate(songs, 1):
            f.write(f"{'=' * 60}\n")
            f.write(f"Песня {i}: {song['name']} - {song['artist']}\n")
            f.write(f"Строк текста: {song['lines']}\n")
            f.write(f"{'=' * 60}\n\n")
            f.write(f"{song['lyrics']}\n\n")

    print(f"Файл текстов создан: {output_path}")


def generate_lrc_template(songs, output_path):
    """
    Генерация шаблона LRC файлов без временных меток
    """
    with open(output_path, 'w', encoding='utf-8') as f:
        for song in songs:
            f.write(f"# {song['name']} - {song['artist']}\n")
            f.write(f"# Используйте LRC Synchronizer для синхронизации\n")
            f.write(f"# После добавления текста нажмите 'Auto Sync Lyrics'\n\n")

            lines = song['lyrics'].split('\n')
            for line in lines:
                if line.strip():
                    f.write(f"[00:00.00]{line.strip()}\n")

            f.write('\n')

    print(f"Шаблон LRC создан: {output_path}")


def check_output_files(output_dir, songs):
    """
    Проверка наличия выходных файлов (MP3, LRC, JSON)
    """
    print("\nПроверка выходных файлов:\n")
    print(f"{'Песня':<50} {'MP3':<10} {'LRC':<10} {'JSON':<10}")
    print("-" * 80)

    complete = []
    missing = []

    for song in songs:
        mp3_name = f"{song['name']} - {song['artist']}.mp3"
        lrc_name = f"{song['name']} - {song['artist']}.lrc"
        json_name = f"{song['name']} - {song['artist']}.json"

        mp3_exists = Path(output_dir / mp3_name).exists()
        lrc_exists = Path(output_dir / lrc_name).exists()
        json_exists = Path(output_dir / json_name).exists()

        status_mp3 = "✅" if mp3_exists else "❌"
        status_lrc = "✅" if lrc_exists else "❌"
        status_json = "✅" if json_exists else "❌"

        song_status = f"{song['name']} - {song['artist']}"
        print(f"{song_status:<50} {status_mp3:<10} {status_lrc:<10} {status_json:<10}")

        if mp3_exists and lrc_exists:
            complete.append(song)
        else:
            missing.append(song)

    print("-" * 80)
    print(f"\nПолностью обработано: {len(complete)}/{len(songs)}")
    print(f"Требует обработки: {len(missing)}/{len(songs)}")

    if missing:
        print("\nПесни, требующие обработки:")
        for song in missing:
            print(f"  - {song['name']} - {song['artist']}")


def main():
    if len(sys.argv) < 2:
        print("Использование: python process_excel_songs.py <путь к RomanianSongs.xlsx>")
        print("Пример: python process_excel_songs.py ../input/RomanianSongs.xlsx")
        sys.exit(1)

    excel_path = Path(sys.argv[1])

    if not excel_path.exists():
        print(f"Файл не найден: {excel_path}")
        sys.exit(1)

    print(f"Чтение Excel файла: {excel_path}")
    songs = read_excel_songs(excel_path)

    if not songs:
        print("Не найдено песен в Excel файле")
        sys.exit(1)

    print(f"\nНайдено песен: {len(songs)}")

    # Папки
    base_dir = Path(__file__).parent.parent
    output_dir = base_dir / "output"
    scripts_dir = base_dir / "scripts"

    # Создание папок
    output_dir.mkdir(exist_ok=True)
    scripts_dir.mkdir(exist_ok=True)

    # Генерация файлов
    script_path = scripts_dir / "download_mp3_from_youtube.sh"
    generate_youtube_dl_script(songs, script_path)

    lyrics_file_path = output_dir / "all_lyrics.txt"
    generate_lyrics_file(songs, lyrics_file_path)

    lrc_template_path = output_dir / "lrc_templates.txt"
    generate_lrc_template(songs, lrc_template_path)

    # Проверка существующих файлов
    check_output_files(output_dir, songs)

    print("\nСгенерированные файлы:")
    print(f"  1. Скрипт скачивания: {script_path}")
    print(f"  2. Тексты всех песен: {lyrics_file_path}")
    print(f"  3. Шаблоны LRC: {lrc_template_path}")
    print("\nИнструкция:")
    print("  1. Запустите скрипт скачивания для получения MP3 файлов")
    print("  2. Используйте LRC Synchronizer для синхронизации каждой песни")
    print("  3. Нажмите 'Auto Sync Lyrics' для автоматического определения временных меток")
    print("  4. Экспортируйте LRC и JSON файлы")
    print("  5. Импортируйте в приложение LingoTune")


if __name__ == "__main__":
    main()
