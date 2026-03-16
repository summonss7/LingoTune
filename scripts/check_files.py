import json
import os
import re

def check_lrc_file(lrc_path):
    """Check LRC file format"""
    print(f'🔍 Проверка LRC файла: {lrc_path}')

    if not os.path.exists(lrc_path):
        print('   ❌ Файл не найден!')
        return False

    with open(lrc_path, 'r', encoding='utf-8') as f:
        content = f.read()
        lines = content.strip().split('\n')

    print(f'   📊 Всего строк: {len(lines)}')

    # Check format
    lrc_pattern = re.compile(r'\[(\d{2}):(\d{2})\.(\d{2})\](.*)')
    valid_lines = 0
    issues = []

    for i, line in enumerate(lines[:10]):  # Check first 10 lines
        match = lrc_pattern.match(line)
        if match:
            valid_lines += 1
        else:
            issues.append(f'Строка {i+1}: неверный формат')

    if valid_lines > 0:
        print(f'   ✅ Формат LRC правильный')
        print(f'   📝 Первая строка: {lines[0][:50]}...')
        return True
    else:
        print(f'   ❌ Формат LRC неверный!')
        for issue in issues:
            print(f'      {issue}')
        return False

def check_json_file(json_path):
    """Check JSON file format"""
    print(f'🔍 Проверка JSON файла: {json_path}')

    if not os.path.exists(json_path):
        print('   ❌ Файл не найден!')
        return False

    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        print(f'   ✅ Файл JSON валиден')

        # Check structure
        if 'translations' not in data:
            print('   ❌ Отсутствует поле "translations"!')
            return False

        translations = data['translations']
        if not isinstance(translations, list) or len(translations) == 0:
            print('   ❌ Поле "translations" должно быть непустым массивом!')
            return False

        print(f'   📊 Количество переводов: {len(translations)}')

        first_translation = translations[0]
        required_fields = ['language', 'languageName', 'lines']
        for field in required_fields:
            if field not in first_translation:
                print(f'   ❌ Отсутствует поле: {field}')
                return False

        print(f'   🌍 Язык: {first_translation["languageName"]} ({first_translation["language"]})')
        print(f'   📝 Количество строк: {len(first_translation["lines"])}')

        # Check first few lines
        lines = first_translation['lines']
        if len(lines) > 0:
            print(f'   📄 Первая строка:')
            print(f'      startTime: {lines[0].get("startTime")} сек')
            print(f'      text: {lines[0].get("text", "")[:50]}...')

        return True

    except json.JSONDecodeError as e:
        print(f'   ❌ Ошибка JSON: {e}')
        return False
    except Exception as e:
        print(f'   ❌ Ошибка: {e}')
        return False

def check_mp3_file(mp3_path):
    """Check MP3 file exists"""
    print(f'🔍 Проверка MP3 файла: {mp3_path}')

    if not os.path.exists(mp3_path):
        print('   ❌ Файл не найден!')
        return False

    size_mb = os.path.getsize(mp3_path) / (1024 * 1024)
    print(f'   ✅ Файл существует')
    print(f'   📊 Размер: {size_mb:.2f} MB')

    return True

def main():
    print('=' * 60)
    print('🔍 Проверка файлов песни')
    print('=' * 60)

    output_dir = 'output'
    files = os.listdir(output_dir)

    mp3_files = [f for f in files if f.endswith('.mp3')]
    lrc_files = [f for f in files if f.endswith('.lrc')]
    json_files = [f for f in files if f.endswith('.json')]

    if not mp3_files:
        print('❌ MP3 файл не найден!')
        return

    base_name = mp3_files[0].replace('.mp3', '')
    print(f'📁 Песня: {base_name}')
    print()

    mp3_path = os.path.join(output_dir, mp3_files[0])
    lrc_path = os.path.join(output_dir, f'{base_name}.lrc')
    json_path = os.path.join(output_dir, f'{base_name}.json')

    results = {
        'mp3': check_mp3_file(mp3_path),
        'lrc': check_lrc_file(lrc_path),
        'json': check_json_file(json_path)
    }

    print()
    print('=' * 60)
    print('📋 Итоговая проверка')
    print('=' * 60)

    for file_type, result in results.items():
        status = '✅' if result else '❌'
        print(f'{status} {file_type.upper()} файл: {"OK" if result else "ОШИБКА"}')

    print()

    if all(results.values()):
        print('🎉 Все файлы готовы к импорту!')
        print()
        print('📱 Шаги для импорта:')
        print('1. Скомпилируйте приложение: cd app && flutter build apk --release')
        print('2. Установите APK на устройство')
        print('3. Перенесите файлы из output/ на устройство')
        print('4. Импортируйте MP3 файл через приложение')
        print('5. Готово! Переводы загрузятся автоматически')
    else:
        print('❌ Найдены ошибки! Проверьте файлы и запустите process_song.py снова')

    print()
    print('=' * 60)

if __name__ == '__main__':
    main()
