#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
from pathlib import Path

# Project root (this file is in <root>/scripts/)
_L10N_DIR = Path(__file__).resolve().parent.parent / "app" / "lib" / "l10n"

# Читаем русский ARB файл как шаблон (он полный, все ключи)
with open(_L10N_DIR / "app_ru.arb", 'r', encoding='utf-8') as f:
    ru_arb = json.load(f)

# Читаем украинский Dart файл и извлекаем переводы
uk_translations = {}
with open(_L10N_DIR / "app_localizations_uk.dart", 'r', encoding='utf-8') as f:
    content = f.read()
    
    # Извлекаем все строки вида: String get keyName => 'Translation';
    import re
    pattern = r"String get (\w+) => '(.*?)';"
    matches = re.findall(pattern, content)
    
    for key, value in matches:
        uk_translations[key] = value

# Создаем украинский ARB файл
uk_arb = {
    "@@locale": "uk"
}

# Копируем все ключи из русского ARB в украинский, заменяя переводы
for key in ru_arb:
    if key == "@@locale":
        continue
    if key in uk_translations:
        uk_arb[key] = uk_translations[key]
    else:
        # Если перевода нет в Dart, используем русский или оставляем пустым
        uk_arb[key] = ru_arb[key]

# Сохраняем украинский ARB файл
with open(_L10N_DIR / "app_uk.arb", 'w', encoding='utf-8') as f:
    json.dump(uk_arb, f, ensure_ascii=False, indent=2)

print("Готово! Создан полный украинский ARB файл")
