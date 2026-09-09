# Форматы данных LingoTune

## Обзор

LingoTune использует несколько форматов файлов для хранения данных:

- **LRC** - текст песни с временными метками
- **JSON** - переводы и транскрипция
- **ZIP** - архив с материалами песни
- **MP3/WAV/M4A/OGG** - аудиофайлы

## LRC формат (Lyrics with timing)

LRC (Lyrics) - формат для хранения текста песен с временными метками синхронизации.

### Структура LRC файла

Каждая строка имеет формат:
```
[MM:SS.ms]Текст строки
```

Где:
- `MM` - минуты (00-59)
- `SS` - секунды (00-59)
- `ms` - миллисекунды (00-999)
- Текст после скобок - текст песни

### Пример LRC файла

```lrc
[30:00.00]Girl, it's been a long time that we've been apart
[30:05.00]Much too long for a man who needs love
[30:10.00]I miss you since I've been away
[30:15.00]Babe, it wasn't easy to leave you alone
[30:20.00]It's getting harder each time that I go
[30:25.00]If I had a choice, I would stay
[30:30.00]There's no one like you
[30:35.00]I can't wait for nights with you
[30:40.00]I imagine things we'd do
[30:45.00]I just want to be loved by you
```

### Парсинг LRC в приложении

```dart
// Формула для преобразования времени:
startTime = (minutes * 60.0) + seconds + (milliseconds / 1000.0)

// Пример:
// [30:00.00] → 30 * 60.0 + 0 + 0 / 1000.0 = 1800.0 секунд
```

### Правила LRC формата

1. Временные метки в квадратных скобках `[]`
2. Формат времени: `MM:SS.00` или `MM:SS.000`
3. Текст начинается сразу после скобки
4. Пустые строки игнорируются
5. Миллисекунды могут быть 2 или 3 цифры
6. Строки должны быть отсортированы по времени

### Создание LRC файла

```bash
# Используя Python скрипт
python scripts/generate_lrc_json.py \
  --input "Текст песни построчно" \
  --start_minute 30 \
  --timing_step 5.0 \
  --output "song.lrc"
```

## JSON формат (Переводы и транскрипция)

JSON файлы используются для хранения переводов и транскрипции песен.

### Структура JSON файла

```json
{
  "title": "Название песни - Исполнитель",
  "artist": "Исполнитель",
  "originalLanguage": "en",
  "translations": [
    {
      "language": "ru",
      "languageName": "Русский",
      "type": "",
      "lines": [
        {
          "startTime": 1800.0,
          "text": "Переведенный текст строки",
          "translatedText": null,
          "transcript": "фонетическая транскрипция",
          "originalStartTime": null
        }
      ]
    }
  ]
}
```

### Поля JSON

| Поле | Тип | Описание |
|------|-----|----------|
| title | String | Название песни |
| artist | String | Исполнитель |
| originalLanguage | String | Код оригинального языка |
| translations | Array | Массив переводов |

### Объект Translation

| Поле | Тип | Описание |
|------|-----|----------|
| language | String | Код языка (ru, en, de) |
| languageName | String | Название языка |
| type | String | Тип перевода (translation/transcript) |
| lines | Array | Массив строк перевода |

### Объект LyricLine

| Поле | Тип | Описание |
|------|-----|----------|
| startTime | Float | Время начала в секундах |
| text | String | Текст строки |
| translatedText | String/null | Перевод (если есть) |
| transcript | String/null | Транскрипция |
| originalStartTime | Float/null | Оригинальное время |

### Пример JSON файла с переводом на русский

```json
{
  "title": "Scorpions - No One Like You",
  "artist": "Scorpions",
  "originalLanguage": "en",
  "translations": [
    {
      "language": "ru",
      "languageName": "Русский",
      "type": "",
      "lines": [
        {
          "startTime": 1800.0,
          "text": "Девушка, прошло много времени, так как мы разошлись",
          "translatedText": null,
          "transcript": "ɡɜːl, ɪts bɪn ə lɒŋ taɪm ðæt wiːv bɪn əˈpɑːt",
          "originalStartTime": null
        },
        {
          "startTime": 1805.0,
          "text": "Слишком долго для мужчины, которому нужна любовь",
          "translatedText": null,
          "transcript": "mʌʃ tuː lɒŋ fɔːr ə mæn huː niːdz lʌv",
          "originalStartTime": null
        },
        {
          "startTime": 1810.0,
          "text": "Я скучаю по тебе с тех пор, как я ушел",
          "translatedText": null,
          "transcript": "aɪ mɪs juː sɪns aɪv bɪn əˈweɪ",
          "originalStartTime": null
        }
      ]
    }
  ]
}
```

### Пример JSON файла с транскрипцией

```json
{
  "title": "Scorpions - No One Like You",
  "artist": "Scorpions",
  "originalLanguage": "en",
  "translations": [
    {
      "language": "trans",
      "languageName": "Транскрипция",
      "type": "transcript",
      "lines": [
        {
          "startTime": 1800.0,
          "text": "ɡɜːl, ɪts bɪn ə lɒŋ taɪm ðæt wiːv bɪn əˈpɑːt",
          "translatedText": null,
          "transcript": "Девушка, прошло много времени, так как мы разошлись",
          "originalStartTime": null
        },
        {
          "startTime": 1805.0,
          "text": "mʌʃ tuː lɒŋ fɔːr ə mæn huː niːdz lʌv",
          "translatedText": null,
          "transcript": "Слишком долго для мужчины, которому нужна любовь",
          "originalStartTime": null
        }
      ]
    }
  ]
}
```

### Множественные переводы в одном файле

```json
{
  "title": "Песня",
  "artist": "Исполнитель",
  "originalLanguage": "en",
  "translations": [
    {
      "language": "ru",
      "languageName": "Русский",
      "type": "",
      "lines": [...]
    },
    {
      "language": "de",
      "languageName": "Deutsch",
      "type": "",
      "lines": [...]
    },
    {
      "language": "trans",
      "languageName": "Транскрипция",
      "type": "transcript",
      "lines": [...]
    }
  ]
}
```

## ZIP архив (Пакет материалов песни)

ZIP архив содержит все файлы для одной песни:

### Структура ZIP архива

```
Песня - Исполнитель.zip
├── Песня - Исполнитель.lrc           # LRC файл с текстом
├── Песня - Исполнитель_ru.json       # Перевод на русский
├── Песня - Исполнитель_de.json       # Перевод на немецкий
├── Песня - Исполнитель_trans.json    # Транскрипция
└── (опционально) audio.mp3          # Аудиофайл
```

### Пример содержимого архива

```zip
Scorpions - No One Like You.zip
├── Scorpions - No One Like You.lrc
├── Scorpions - No One Like You_ru.json
├── Scorpions - No One Like You_de.json
├── Scorpions - No One Like You_trans.json
└── Scorpions - No One Like You.mp3
```

### Создание ZIP архива

```bash
# Используя Python скрипт
python scripts/deepseek_generator_v3.py \
  --text "Текст песни" \
  --languages ru,en,de,trans \
  --output "Scorpions - No One Like You.zip"
```

## Аудио форматы

### Поддерживаемые форматы

| Формат | Расширение | Описание |
|--------|------------|----------|
| MP3 | .mp3 | Наиболее распространенный формат |
| WAV | .wav | Несжатый формат, высокое качество |
| M4A | .m4a | Формат Apple, сжатый AAC |
| OGG | .ogg | Открытый формат сжатия |

### Рекомендации для аудио

- **Битрейт:** 128-320 kbps
- **Частота дискретизации:** 44.1 kHz
- **Каналы:** Стерео
- **Размер файла:** 3-10 MB для одной песни

## Коды языков

### Поддерживаемые языки

| Код | Название | Название в приложении |
|-----|----------|----------------------|
| en | English | English |
| ru | Russian | Русский |
| ro | Romanian | Română |
| de | German | Deutsch |
| fr | French | Français |
| es | Spanish | Español |
| it | Italian | Italiano |
| pt | Portuguese | Português |
| zh | Chinese | 中文 |
| ar | Arabic | العربية |
| uk | Ukrainian | Українська |
| ja | Japanese | 日本語 |
| ko | Korean | 한국어 |
| ru_literal | Russian Literal | Русский (Дословный) |
| trans | Transcription | Транскрипция |

## Именование файлов

### Правила именования

1. Используйте формат: `Название - Исполнитель.расширение`
2. Используйте латинские буквы для совместимости
3. Замените спецсимволы на подчеркивания
4. Код языка добавляется перед расширением

### Примеры

```
✅ Scorpions - No One Like You.lrc
✅ Scorpions - No One Like You_ru.json
✅ Scorpions - No One Like You.zip

❌ Scorpions: No One Like You.lrc
❌ Scorpions/No One Like You.lrc
❌ Скорпионы - Никто как ты.lrc
```

## Временные метки

### Формат времени

Время хранится в секундах с точностью до миллисекунд:

```
1800.0 = 30 минут
1810.5 = 30 минут 10.5 секунд
```

### Начальное время

По умолчанию для уроков используется начальное время 30 минут (1800.0 секунд):

```lrc
[30:00.00]Первая строка песни
[30:05.00]Вторая строка песни
```

Это необходимо для SUNO - AI генератор музыки начинает создавать музыку с определенной позиции.

## Транскрипция

### IPA формат

Транскрипция использует международный фонетический алфавит (IPA):

```
English: /həˈləʊ/
Russian: /ˈprʲivɛt/
German: /ˈhaloː/
```

### Кириллическая транскрипция

Для русского языка используется кириллическая транскрипция:

```
Hello → Хелло
Goodbye → Гудбай
Thank you → Сэнк ю
```

## Валидация файлов

### Проверка LRC файла

```bash
# Используйте Python скрипт для проверки
python scripts/check_files.py --input song.lrc
```

### Проверка JSON файла

```bash
# Проверка валидности JSON
python -m json.tool song_ru.json

# Проверка структуры
python scripts/check_files.py --input song_ru.json
```

## Конвертация форматов

### Текст → LRC

```bash
python scripts/generate_lrc_json.py \
  --input "Текст песни построчно" \
  --start_minute 30 \
  --output song.lrc
```

### LRC → JSON

```bash
python scripts/generate_lrc_json.py \
  --lrc song.lrc \
  --languages ru,en,trans \
  --output song_ru.json
```

### Excel → JSON

```bash
python scripts/process_excel_songs.py \
  --excel songs.xlsx \
  --output output/
```

## Размеры файлов

### Типичные размеры

| Тип файла | Средний размер |
|-----------|----------------|
| LRC файл | 2-5 KB |
| JSON файл (1 язык) | 5-10 KB |
| ZIP архив (все файлы) | 10-50 KB |
| MP3 файл (128 kbps) | 3-5 MB |
| MP3 файл (320 kbps) | 8-10 MB |

## Кодировка

### LRC файлы

- Кодировка: UTF-8
- Поддерживаются Unicode символы

### JSON файлы

- Кодировка: UTF-8
- Поддерживаются эмодзи и спецсимволы

## Шифрование и безопасность

- API ключи хранятся в `.env` файле
- JSON файлы не содержат личных данных
- Аудиофайлы не шифруются

---

Дополнительная информация:
- [Архитектура](ARCHITECTURE.md)
- [Пайплайн контента](CONTENT_PIPELINE.md)
- [AGENTS.md](../AGENTS.md) — конвенции разработки
