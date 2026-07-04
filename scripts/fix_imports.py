import os
import re
from pathlib import Path

def fix_imports(file_path):
    # Читаем файл
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Заменяем все относительные импорты на абсолютные
    content = re.sub(r"import '\.\./l10n/app_localizations\.dart'", "import 'package:lingotune/l10n/app_localizations.dart'", content)
    
    # Записываем измененный файл
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Исправлено {file_path}")
    return file_path

# Project root (this file is in <root>/scripts/)
dart_dir = str(Path(__file__).resolve().parent.parent / "app" / "lib")

# Обрабатываем все .dart файлы
for root, dirs, files in os.walk(dart_dir):
    for filename in files:
        if filename.endswith('.dart'):
            file_path = os.path.join(root, filename)
            fix_imports(file_path)

print("Готово!")
