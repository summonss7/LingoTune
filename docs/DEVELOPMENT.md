# Руководство по разработке LingoTune

## Обзор

Этот документ описывает конвенции кода, процессы разработки и лучшие практики для проекта LingoTune.

## Конвенции кода Flutter/Dart

### Именование

#### Классы и перечисления
Используйте PascalCase:

```dart
class Song { }
enum LoopMode { off, all, one }
```

#### Переменные, методы и функции
Используйте camelCase:

```dart
final audioService = AudioService();
void loadSongs() { }
String getSongTitle() { }
```

#### Приватные члены
Префикс с подчеркиванием:

```dart
bool _isPlaying = false;
void _initPlayer() { }
```

#### Константы
Используйте lowerCamelCase для локальных констант:

```dart
const TIME_INCREMENT = 5.0;
const START_MINUTE = 30.0;
```

#### Файлы
Используйте snake_case:

```dart
song_library_screen.dart
audio_service.dart
translation_request.dart
```

### Организация импортов

Группируйте импорты в следующем порядке:

```dart
// Core Dart imports
import 'dart:async';
import 'dart:io';

// Flutter SDK imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Package imports
import 'package:just_audio/just_audio.dart';
import 'package:sqflite/sqflite.dart';

// Project imports
import '../models/song.dart';
import '../services/audio_service.dart';
import '../widgets/song_list_tile.dart';
```

### Виджеты

#### Используйте const конструкторы

```dart
class SongListTile extends StatelessWidget {
  const SongListTile({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text('Song Title'),
    );
  }
}
```

#### Всегда используйте super.key

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
}
```

#### Async/await

Используйте try-catch с debugPrint для ошибок:

```dart
Future<void> _loadSongs() async {
  try {
    final songs = await _databaseService.getAllSongs();
    if (mounted) {
      setState(() => _songs = songs);
    }
  } catch (e) {
    debugPrint('Error loading songs: $e');
  }
}
```

#### Проверка mounted

Проверяйте mounted перед асинхронными операциями, которые влияют на UI:

```dart
Future<void> _updateUI() async {
  final result = await _getData();
  if (mounted) {
    setState(() => _data = result);
  }
}
```

### Модели

Используйте неизменяемые классы:

```dart
class Song {
  final String id;
  final String title;
  
  Song({
    required this.id,
    required this.title,
  });
  
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
  
  Song copyWith({
    String? id,
    String? title,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}
```

### Сервисы

Расширяйте ChangeNotifier для управления состоянием:

```dart
class AudioService extends ChangeNotifier {
  bool _isPlaying = false;
  
  bool get isPlaying => _isPlaying;
  
  void play() {
    _isPlaying = true;
    notifyListeners();
  }
  
  void pause() {
    _isPlaying = false;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
```

### Логирование

Используйте debugPrint с префиксами:

```dart
debugPrint('✓ AudioService: Play via BackgroundHandler');
debugPrint('✗ Error loading audio: $e');
debugPrint('⚠ Warning: BackgroundHandler is null');
```

## Конвенции кода Python

### Типизация

Всегда используйте type hints:

```python
from typing import List, Dict, Optional

def parse_line(line: str) -> str:
    return line.strip()

def read_file_content(filepath: str) -> List[str]:
    return []

def process_song(
    text: str,
    languages: List[str],
    output_dir: Optional[str] = None
) -> Dict[str, Any]:
    pass
```

### Docstrings

Используйте docstrings для всех функций и классов:

```python
def is_cyrillic(text: str) -> bool:
    """Check if text contains Cyrillic characters
    
    Args:
        text: The text to check
        
    Returns:
        True if text contains Cyrillic characters, False otherwise
    """
    return any('\u0400' <= c <= '\u04FF' for c in text)
```

### String formatting

Используйте f-strings:

```python
minutes = int(seconds // 60)
secs = int(seconds % 60)
return f'{minutes:02d}:{secs:05.2f}'
```

### File operations

Используйте pathlib.Path:

```python
from pathlib import Path

output_path = Path(output_dir) / f'{base_name}.json'
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
```

### Error handling

Используйте специфичную обработку исключений:

```python
try:
    df = pd.read_excel(excel_path)
except FileNotFoundError:
    print(f'❌ Excel file not found: {excel_path}')
    return False
except Exception as e:
    print(f'❌ Error processing Excel: {e}')
    return False
```

## Тестирование

### Flutter тесты

#### Unit тесты

```dart
void main() {
  group('Song Model Tests', () {
    test('Song should be created correctly', () {
      final song = Song(id: '1', title: 'Test Song');
      expect(song.title, 'Test Song');
    });
    
    test('Song fromJson should parse correctly', () {
      final json = {'id': '1', 'title': 'Test Song'};
      final song = Song.fromJson(json);
      expect(song.id, '1');
      expect(song.title, 'Test Song');
    });
  });
}
```

#### Widget тесты

```dart
testWidgets('SongListTile displays correctly', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SongListTile(
          song: Song(id: '1', title: 'Test Song', artist: 'Test Artist'),
        ),
      ),
    ),
  );
  
  expect(find.text('Test Song'), findsOneWidget);
  expect(find.text('Test Artist'), findsOneWidget);
});
```

### Python тесты

```python
import unittest

class TestTranslation(unittest.TestCase):
    
    def test_parse_line(self):
        line = "Test line"
        result = parse_line(line)
        self.assertEqual(result, "Test line")
    
    def test_is_cyrillic(self):
        text = "Привет"
        self.assertTrue(is_cyrillic(text))
    
    def test_is_not_cyrillic(self):
        text = "Hello"
        self.assertFalse(is_cyrillic(text))

if __name__ == '__main__':
    unittest.main()
```

## Сборка и релиз

### Подготовка к релизу

1. **Обновите версию**
   
   В `app/lib/app_info.dart`:
   ```dart
   static const String version = '4.3.3';
    static const String versionCode = '145';
   ```
   
   В `app/pubspec.yaml`:
   ```yaml
   version: 4.3.3
   ```

2. **Запустите тесты**
   
   ```bash
   cd app
   flutter test
   ```

3. **Анализ кода**
   
   ```bash
   flutter analyze
   ```

4. **Форматирование кода**
   
   ```bash
   dart format .
   ```

### Сборка APK

```bash
cd app
flutter build apk --release
```

APK будет создан в: `build/app/outputs/flutter-apk/app-release.apk`

### Сборка App Bundle

```bash
flutter build appbundle --release
```

AAB будет создан в: `build/app/outputs/bundle/release/app-release.aab`

### Подпись APK

Создайте файл `android/key.properties`:

```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=D:/path/to/your/upload-keystore.jks
```

## Работа с Git

### Ветвление

```bash
# Создание новой ветки
git checkout -b feature/add-lyrics-search

# Коммит изменений
git add .
git commit -m "Add lyrics search feature"

# Пуш в удаленный репозиторий
git push origin feature/add-lyrics-search
```

### Сообщения коммитов

Используйте конвенцию:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Типы:
- `feat`: Новая функция
- `fix`: Исправление бага
- `docs`: Документация
- `style`: Форматирование кода
- `refactor`: Рефакторинг
- `test`: Тесты
- `chore: Обслуживание

Примеры:

```
feat(audio): add shuffle mode
fix(player): correct timing offset
docs(readme): update installation guide
```

### Pull requests

Перед созданием PR:

1. Обновите ветку
2. Запустите тесты
3. Проверьте код
4. Обновите документацию

Шаблон PR:

```markdown
## Описание
Краткое описание изменений

## Изменения
- Изменение 1
- Изменение 2

## Тестирование
- [x] Unit тесты пройдены
- [x] Widget тесты пройдены
- [x] Ручное тестирование

## Скриншоты
(если применимо)
```

## Производительность

### Оптимизация Flutter

1. **Используйте const виджеты**
   
   ```dart
   const ListTile(title: Text('Title'))
   ```

2. **Lazy loading для больших списков**
   
   ```dart
   ListView.builder(
     itemCount: songs.length,
     itemBuilder: (context, index) {
       return SongListTile(song: songs[index]);
     },
   )
   ```

3. **Кэширование переведенных строк**
   
   ```dart
   class TranslationCache {
     final Map<String, String> _cache = {};
     
     String get(String key) => _cache[key] ?? '';
     void set(String key, String value) => _cache[key] = value;
   }
   ```

4. **Оптимизация базы данных**
   
   ```dart
   await db.execute('CREATE INDEX idx_title ON songs(title)');
   ```

### Оптимизация Python

1. **Кэширование API запросов**
   
   ```python
   from functools import lru_cache
   
   @lru_cache(maxsize=100)
   def get_translation(text: str, language: str) -> str:
       return api.translate(text, language)
   ```

2. **Batch операции**
   
   ```python
   # Вместо множества запросов
   for song in songs:
       result = api.translate(song.text)
   
   # Используйте batch запрос
   results = api.batch_translate([s.text for s in songs])
   ```

## Безопасность

### Защита API ключей

1. **Никогда не коммитите API ключи**
   
   ```gitignore
   .env
   key.properties
   ```

2. **Используйте переменные окружения**
   
   ```python
   API_KEY = os.getenv("DEEPSEEK_API_KEY")
   ```

3. **Валидация пользовательского ввода**
   
   ```dart
   String validateApiKey(String key) {
     if (key.isEmpty) return 'API key cannot be empty';
     if (key.length < 10) return 'API key is too short';
     return '';
   }
   ```

### Защита файлов

1. **Ограничьте доступ к файлам**
   
   ```dart
   // Проверьте права доступа перед чтением файла
   final hasPermission = await Permission.storage.request();
   if (!hasPermission.isGranted) {
     return;
   }
   ```

2. **Валидация путей**
   
   ```dart
   bool isValidPath(String path) {
     return path.startsWith('/storage/') || 
            path.startsWith('/data/');
   }
   ```

## Локализация

### Добавление нового языка

1. **Создайте файл локализации**
   
   ```dart
   // app/lib/l10n/app_localizations_xx.dart
   class AppLocalizationsXx extends AppLocalizations {
     AppLocalizationsXx(Locale locale) : super(locale);
     
     @override
     String get library => 'Библиотека';
     
     @override
     String get settings => 'Настройки';
   }
   ```

2. **Добавьте в app_localizations.dart**
   
   ```dart
   static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
     AppLocalizations.delegate,
     // ... другие делегаты
     AppLocalizationsXx.delegate,
   ];
   ```

3. **Обновите список поддерживаемых языков**
   
   ```dart
   static const List<Locale> supportedLocales = [
     Locale('en'),
     Locale('ru'),
     Locale('xx'), // Ваш язык
   ];
   ```

## Отладка

### Flutter

1. **Используйте debugPrint**
   
   ```dart
   debugPrint('Loading songs: ${songs.length}');
   ```

2. **Используйте Flutter DevTools**
   
   ```bash
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

3. **Profiler**
   
   - Widget rebuild analyzer
   - Performance overlay
   - Memory view

### Python

1. **Используйте logging**
   
   ```python
   import logging
   
   logging.basicConfig(level=logging.INFO)
   logger = logging.getLogger(__name__)
   
   logger.info('Processing song...')
   logger.error(f'Error: {e}')
   ```

2. **Используйте pdb для отладки**
   
   ```python
   import pdb; pdb.set_trace()
   ```

## Continuous Integration

### GitHub Actions

Пример workflow:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.0.0'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Analyze code
      run: flutter analyze
```

## Ресурсы для разработчиков

### Документация Flutter
- [Flutter documentation](https://docs.flutter.dev/)
- [Dart language tour](https://dart.dev/guides/language/language-tour)

### Библиотеки Flutter
- [pub.dev](https://pub.dev/)

### Python
- [Python documentation](https://docs.python.org/3/)
- [PEP 8 - Style Guide](https://www.python.org/dev/peps/pep-0008/)

---

Дополнительная информация:
- [Архитектура](ARCHITECTURE.md)
- [Настройка окружения](SETUP.md)
- [Форматы данных](DATA_FORMATS.md)
