# Руководство по API LingoTune

## Обзор

LingoTune использует несколько API для генерации переводов, поиска текстов песен и других функций.

## DeepSeek API

DeepSeek API используется для генерации переводов и транскрипции песен.

### Получение API ключа

1. Перейдите на https://platform.deepseek.com/
2. Зарегистрируйтесь или войдите в аккаунт
3. Создайте новый API ключ
4. Сохраните ключ в безопасном месте

### Конфигурация API ключа

Создайте файл `.env` в корневой директории проекта:

```env
DEEPSEEK_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### API Эндпоинт

```
POST https://api.deepseek.com/v1/chat/completions
```

### Модель

```
deepseek-reasoner
```

### Структура запроса

```json
{
  "model": "deepseek-reasoner",
  "messages": [
    {
      "role": "system",
      "content": "Вы профессиональный переводчик и эксперт по транскрипции..."
    },
    {
      "role": "user",
      "content": "Переведите следующий текст..."
    }
  ],
  "temperature": 0.7,
  "max_tokens": 4096,
  "stream": false
}
```

### Использование в Python

```python
import requests
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("DEEPSEEK_API_KEY")
BASE_URL = "https://api.deepseek.com/v1"
MODEL = "deepseek-reasoner"

def generate_translation(text, languages):
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    prompt = f"""Generate translations for the following song text:
    
    Text: {text}
    Languages: {', '.join(languages)}
    
    Provide translations in JSON format."""
    
    payload = {
        "model": MODEL,
        "messages": [
            {
                "role": "system",
                "content": "You are a professional translator and transcription expert."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        "temperature": 0.7,
        "max_tokens": 4096
    }
    
    response = requests.post(
        f"{BASE_URL}/chat/completions",
        headers=headers,
        json=payload
    )
    
    return response.json()
```

### Использование во Flutter

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeepSeekApiService {
  static const String _baseUrl = 'https://api.deepseek.com/v1';
  static const String _model = 'deepseek-reasoner';
  
  Future<Map<String, dynamic>> generateTranslation({
    required String text,
    required List<String> languages,
    required String sourceLanguage,
    required String transcriptionLanguage,
  }) async {
    await dotenv.load(fileName: '.env');
    final apiKey = dotenv.env['DEEPSEEK_API_KEY'];
    
    final prompt = DeepSeekPrompts.getPromptForPreset(
      'balanced',
      text,
      languages,
      sourceLanguage,
      transcriptionLanguage,
    );
    
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional translator and transcription expert.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'temperature': 0.7,
        'max_tokens': 4096,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate translation: ${response.body}');
    }
  }
}
```

### Промты для DeepSeek

Промты для разных режимов перевода находятся в `app/lib/constants/deepseek_prompts.dart`:

```dart
class DeepSeekPrompts {
  static String getPromptForPreset(
    String preset,
    String text,
    List<String> languages,
    String sourceLanguage,
    String transcriptionLanguage,
  ) {
    switch (preset) {
      case 'poetic':
        return _getPoeticPrompt(text, languages, sourceLanguage, transcriptionLanguage);
      case 'literal':
        return _getLiteralPrompt(text, languages, sourceLanguage, transcriptionLanguage);
      case 'balanced':
      default:
        return _getBalancedPrompt(text, languages, sourceLanguage, transcriptionLanguage);
    }
  }
  
  static String _getBalancedPrompt(...) {
    // Промт для сбалансированного перевода
  }
  
  static String _getPoeticPrompt(...) {
    // Промт для художественного перевода
  }
  
  static String _getLiteralPrompt(...) {
    // Промт для дословного перевода
  }
}
```

### Режимы перевода

#### Художественный перевод (Poetic)
- Создает стихотворный перевод
- Сохраняет ритм и рифму оригинала
- Подходит для пения

#### Дословный перевод (Literal)
- Слово в слово
- Сохраняет структуру предложений
- Полезен для обучения грамматике

#### Сбалансированный перевод (Balanced)
- Естественный перевод
- Сочетает точность и читаемость
- По умолчанию для большинства случаев

### Ограничения API

- **Максимум токенов:** 4096 на запрос
- **Максимум запросов:** 60 запросов в минуту
- **Размер текста:** ~2000-3000 слов за запрос

### Обработка ошибок

```python
try:
    result = generate_translation(text, languages)
    return result
except requests.exceptions.RequestException as e:
    print(f"Network error: {e}")
    return None
except Exception as e:
    print(f"API error: {e}")
    return None
```

### Логирование API запросов

```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def generate_translation(text, languages):
    logger.info(f"Generating translation for text length: {len(text)}")
    logger.info(f"Languages: {languages}")
    
    # ... API запрос ...
    
    logger.info(f"Translation generated successfully")
    return result
```

## Поиск текстов песен (Lyrics API)

LingoTune может искать тексты песен онлайн из нескольких источников.

### Используемые источники

- **lyrics.wikia.com** - большая база текстов песен
- **genius.com** - тексты и аннотации
- **azlyrics.com** - простой интерфейс

### Использование в приложении

```dart
class LyricsApiService {
  Future<String?> searchLyrics(String artist, String title) async {
    // Поиск на lyrics.wikia.com
    final result1 = await _searchLyricsWikia(artist, title);
    if (result1 != null) return result1;
    
    // Поиск на genius.com
    final result2 = await _searchGenius(artist, title);
    if (result2 != null) return result2;
    
    // Поиск на azlyrics.com
    final result3 = await _searchAzLyrics(artist, title);
    return result3;
  }
  
  Future<String?> _searchLyricsWikia(String artist, String title) async {
    // Реализация поиска
  }
  
  Future<String?> _searchGenius(String artist, String title) async {
    // Реализация поиска
  }
  
  Future<String?> _searchAzLyrics(String artist, String title) async {
    // Реализация поиска
  }
}
```

### Форматирование найденного текста

```dart
String formatLyrics(String rawLyrics) {
  // Удаление HTML тегов
  var lyrics = rawLyrics.replaceAll(RegExp(r'<[^>]*>'), '');
  
  // Удаление лишних пробелов
  lyrics = lyrics.replaceAll(RegExp(r'\s+'), ' ');
  
  // Разбивка на строки
  final lines = lyrics.split('\n');
  
  // Удаление пустых строк
  lines.removeWhere((line) => line.trim().isEmpty);
  
  return lines.join('\n');
}
```

## Генерация аудио перевода (локальная, TTS)

Для задачи «та же песня, переведённая на другой язык» LingoTune использует
**локальный TTS-пайплайн** вместо внешних музыкальных AI.

> ⚠️ **Почему не Suno / аналоги?** Suno, Udio и подобные сервисы генерируют
> **новую** музыку из текстового промта — они НЕ сохраняют мелодию и ритм
> исходной песни. Для цели обучения (караоке/произношение) важно точное
> совпадение таймингов с оригиналом, что недоступно через генеративные модели.

### Принцип работы

Скрипт `scripts/generate_translation_audio.py` берёт готовые артефакты
пайплайна (`.mp3` + `.lrc` + `.json` с переводами) и для каждой строки:

1. Находит перевод по `startTime` (с толерантностью до 0.5 с)
2. Озвучивает его через **edge-tts** (бесплатно, без API-ключа, поддержка
   всех 14 языков из `GenerationConstants.supportedLanguages`)
3. Подгоняет длительность клипа под слот строки:
   - `--align stretch` (по умолчанию): pitch-preserving ускорение через
     `ffmpeg atempo` (до `--max-speed`) или добивка тишиной
   - `--align words`: слова остаются на естественной скорости, а паузы
     между ними растягиваются на весь слот (`scripts/word_align.py`)
4. Накладывает на тихую канву, затем микширует с базовым аудио

### Использование

```bash
# Установить зависимости (первый раз)
pip install -r scripts/requirements.txt

# Сгенерировать русскую «караоке-версию» песни
python scripts/generate_translation_audio.py \
    --audio "media/Songs/Romanian/Song.mp3" \
    --lrc "path/to/Song.lrc" \
    --translations "path/to/Song_ru.json" \
    --language ru \
    --mode mixed \
    --test 3
```

### Режимы микширования (`--mode`)

| Режим | Базовое аудио | TTS-перевод | Назначение |
|---|---|---|---|
| `mixed` (по умолч.) | оригинал, −12 dB | полный | Универсальный режим обучения |
| `tts_only` | — | полный | Чистая практика произношения |
| `ducked` | оригинал, полный | −6 dB | Прослушивание с подсказкой |
| `karaoke` | инструментал (без вокала) | полный | Настоящее караоке: вокал заменён переводом |

> Режим `karaoke` использует **Demucs** (`scripts/demucs_service.py`) для
> удаления вокала из оригинала. Stems кэшируются в `<родитель аудио>/.stems/`,
> повторный запуск той же песни мгновенный. Требует `torch` + `demucs` +
> `soundfile` (см. `requirements.txt`, optional-секция).

### Пресеты генерации (`--variant`)

Три готовых типа генерации, выбираемые одним флагом. **`v2` — рекомендуемый
основной режим** для перевода песен.

| Пресет | Голос | Размещение TTS | Поведение |
|---|---|---|---|
| `v1` | авто по языку | `inline`, **pad=True** — перевод озвучивается с начала строки и **заполняет весь слот** (с паддингом тишиной) | Перевод «ведёт» строку на всю её длину |
| `v2` ⭐ **рекомендуется** | **женский** | `inline`, **compact** — перевод звучит **точно в момент метки строки**, **быстро** (edge-tts `rate=+50%`) и компактно (без паддинга). Громкость: оригинал 0 dB, перевод +3 dB | Женский голос быстро проговаривает перевод ровно в timestamp каждой строки поверх оригинала полной громкости |
| `v3` ⚠ **экспериментальный** | **женский** | `inline`, **compact** + **замедленный оригинал** + **лид**. rate `+40%`, перевод **на 1с раньше** метки (`--lead-ms -1000`), оригинал **замедлен ×1.10** (pitch сохранён, длительность +10%) и **−1 dB**, перевод +4 dB | **Не рекомендуется:** замедление меняет характер песни и воспринимается неестественно. Эффект «предвосхищения» (сначала русский перевод, затем замедленная английская строка). Оставлен как эксперимент; используйте v2 |

```bash
# v2 — РЕКОМЕНДУЕМЫЙ: быстрый женский перевод ровно в метку каждой строки
python scripts/generate_translation_audio.py ... --language ru --variant v2

# v1 — перевод заполняет весь слот строки (с паддингом)
python scripts/generate_translation_audio.py ... --language ru --variant v1

# v3 — экспериментальный (замедляет песню; не рекомендуется)
python scripts/generate_translation_audio.py ... --language ru --variant v3

# v2 + karaoke — женский перевод поверх инструментала (без вокала)
python scripts/generate_translation_audio.py ... --language ru --variant v2 --mode karaoke

# Свой темп / громкости
python scripts/generate_translation_audio.py ... --language ru --variant v2 --rate "+70%" --orig-gain -3 --tts-gain 4
```

Пресет лишь выставляет значения по умолчанию; любой параметр можно
переопределить явно: `--voice`, `--placement {inline,gap}`, `--mode`,
`--align`, `--rate`, `--max-speed`, `--gap-speed`, `--slow-factor`,
`--lead-ms`, `--orig-gain`, `--tts-gain`.

> Дополнительно доступно `--placement gap` — «эхо» с end-anchoring:
> перевод заканчивается прямо перед следующей меткой строки (в хвосте слота).

### Выравнивание TTS (`--align`) — только для `v1` (inline + pad)

| Значение | Поведение |
|---|---|
| `stretch` (по умолч.) | Клип равномерно ускоряется/замедляется (pitch сохранён) |
| `words` | Слова звучат естественно, паузы между ними растягиваются на слот |

### Пакетная обработка

`scripts/batch_generate.py` обходит всю библиотеку (`media/Songs/<Lang>/`),
сопоставляет `.zip` с переводами и `.mp3` (включая диакритико-нечувствительный
матч), и генерирует аудио для выбранных языков.

```bash
# Только посмотреть, что найдётся (без генерации)
python scripts/batch_generate.py --library media/Songs --dry-run

# Сгенерировать русские караоке-версии для всех песей с аудио
python scripts/batch_generate.py --library media/Songs \
    --languages ru --mode karaoke --device cpu
```

### Маппинг голосов

Соответствие кодов языков (из `generation_constants.dart`) и голосов edge-tts
определено в `scripts/voices_map.py`. Особые случаи:
- `trans` (фонетическая транскрипция русскими буквами) → русский голос
- `ru_literal` (дословный перевод) → русский голос

### Требования

- Python 3.8+, пакеты `edge-tts`, `pydub`
- Системный **ffmpeg** в PATH (для чтения/записи MP3 и pitch-preserving tempo)
- Без API-ключей — полностью офлайн после установки моделей edge-tts

См. подробный план: [`docs/PLAN_v4.6.19_translation_audio.md`](PLAN_v4.6.19_translation_audio.md)

## Локализация API

### Поддерживаемые языки

Языки для переводов определяются в `app/lib/constants/generation_constants.dart`:

```dart
class GenerationConstants {
  static const Map<String, String> supportedLanguages = {
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
    'ja': '日本語',
    'ko': '한국어',
    'trans': 'Транскрипция',
  };
}
```

## Управление API ключами

### Хранение ключей

API ключи хранятся в файле `.env`:

```env
DEEPSEEK_API_KEY=your_deepseek_api_key
```

> Примечание: для генерации аудио перевода (TTS) API-ключ **не требуется** —
> `edge-tts` работает бесплатно. См. раздел «Генерация аудио перевода» выше.

### Безопасность

- Никогда не коммитить `.env` файл в Git
- Добавить `.env` в `.gitignore`
- Не делиться API ключами публично

### Обновление ключей

```bash
# Редактирование .env файла
notepad .env

# Или через командную строку
set DEEPSEEK_API_KEY=новый_ключ_здесь
```

## Мониторинг использования API

### Логирование запросов

```python
import logging
from datetime import datetime

class ApiLogger:
    def __init__(self):
        self.logger = logging.getLogger('api')
        self.logger.setLevel(logging.INFO)
        
    def log_request(self, api_name, request_data):
        timestamp = datetime.now().isoformat()
        self.logger.info(f"[{timestamp}] {api_name} Request: {request_data}")
        
    def log_response(self, api_name, response_data):
        timestamp = datetime.now().isoformat()
        self.logger.info(f"[{timestamp}] {api_name} Response: {response_data}")
        
    def log_error(self, api_name, error):
        timestamp = datetime.now().isoformat()
        self.logger.error(f"[{timestamp}] {api_name} Error: {error}")
```

## Оптимизация API запросов

### Кэширование

```dart
class TranslationCache {
  final Map<String, Translation> _cache = {};
  
  Translation? get(String key) {
    return _cache[key];
  }
  
  void set(String key, Translation translation) {
    _cache[key] = translation;
  }
  
  void clear() {
    _cache.clear();
  }
}
```

### Batch запросы

```python
def batch_generate_translations(texts, languages):
    """
    Генерирует переводы для нескольких текстов
    
    Args:
        texts: Список текстов
        languages: Список языков
    
    Returns:
        Список переводов
    """
    results = []
    
    for text in texts:
        result = generate_translation(text, languages)
        results.append(result)
        
    return results
```

## Тестирование API

### Unit тесты для Python

```python
import unittest
from unittest.mock import patch
import requests

class TestDeepSeekAPI(unittest.TestCase):
    
    @patch('requests.post')
    def test_generate_translation_success(self, mock_post):
        mock_response = mock.Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            'choices': [{'message': {'content': 'Translation'}}]
        }
        mock_post.return_value = mock_response
        
        result = generate_translation('test text', ['ru'])
        
        self.assertIsNotNone(result)
        mock_post.assert_called_once()
```

### Widget тесты для Flutter

```dart
testWidgets('DeepSeekApiService generates translation', (WidgetTester tester) async {
  final service = DeepSeekApiService();
  
  when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
      .thenAnswer((_) async => Response('{"choices": []}', 200));
  
  final result = await service.generateTranslation(
    text: 'test',
    languages: ['ru'],
    sourceLanguage: 'en',
    transcriptionLanguage: 'ru',
  );
  
  expect(result, isNotNull);
});
```

## Решение проблем

### API ключ не работает

**Решение:**
1. Проверьте, что ключ правильный
2. Проверьте баланс на DeepSeek
3. Создайте новый ключ
4. Убедитесь, что файл `.env` существует

### Превышен лимит запросов

**Решение:**
1. Подождите 1 минуту
2. Уменьшите количество запросов
3. Используйте кэширование
4. Оптимизируйте промты

### Неверный ответ от API

**Решение:**
1. Проверьте формат запроса
2. Проверьте промты
3. Проверьте модель API
4. Свяжитесь с поддержкой DeepSeek

### Текст слишком длинный

**Решение:**
1. Разбейте текст на части
2. Используйте меньшее количество языков
3. Сократите промт
4. Увеличьте max_tokens

---

Дополнительная информация:
- [Архитектура](ARCHITECTURE.md)
- [Форматы данных](DATA_FORMATS.md)
- [Создание уроков](LESSON_CREATION.md)
