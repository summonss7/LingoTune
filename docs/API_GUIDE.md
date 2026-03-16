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

## API для генерации музыки (SUNO)

SUNO API используется для генерации музыки на основе текста песен.

### Создание промта для SUNO

```python
def create_suno_prompt(text, style):
    """
    Создает промт для генерации музыки в SUNO
    
    Args:
        text: Текст песни
        style: Стиль музыки (например, "rock with duduk, violin, cello, flute, organ")
    
    Returns:
        Промт для SUNO
    """
    prompt = f"""
    Song text:
    {text}
    
    Style:
    {style}
    
    Requirements:
    - Medium tempo
    - Melodic interludes
    - Arabic pronunciation should be clear, not syllable-based
    - Rock genre with ethnic instruments
    """
    
    return prompt
```

### Пример промта для арабской рок песни

```
Text:
Арабский текст песни здесь...

Style:
Rock with duduk, violin, cello, flute, organ, melodic interludes, medium tempo, clear pronunciation, Arabic dialect of Egypt
```

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
SUNO_API_KEY=your_suno_api_key
```

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
