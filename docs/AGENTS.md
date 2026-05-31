# LingoTune - Agent Guidelines

This is a hybrid Flutter/Dart + Python project for language learning through music.

## Project Structure

- **app/**: Flutter mobile application (Dart 3.0+)
- **scripts/**: Python utilities for lyrics processing and generation
- **input/**: Source files for song processing
- **output/**: Generated lyrics and translations

---

## Build, Lint & Test Commands

### Flutter (Dart)

```bash
# From app/ directory
cd app

# Install dependencies
flutter pub get

# Run all tests
flutter test

# Run a single test file
flutter test test/models_test.dart

# Run a specific test by name
flutter test --plain-name "Song should be created correctly"

# Run tests with coverage
flutter test --coverage

# Analyze code (linting)
flutter analyze

# Format code
dart format .

# Generate app icons
flutter pub run flutter_launcher_icons

# Build APK
flutter build apk --release

# Run app
flutter run
```

### Python

```bash
# From root directory

# Run a Python script
python scripts/process_song.py

# Run with specific arguments
python scripts/create_lyrics_from_files.py

# Python linting (if available)
pip install black ruff mypy
black scripts/
ruff check scripts/
mypy scripts/
```

---

## Code Style Guidelines

### Dart/Flutter

#### Naming Conventions
- **Classes/Enums**: PascalCase (e.g., `Song`, `AudioService`, `LoopMode`)
- **Variables/Methods/Functions**: camelCase (e.g., `audioService`, `loadSongs`, `_loadInitialScreen`)
- **Private members**: Prefix with underscore (e.g., `_isPlaying`, `_initPlayer()`)
- **Constants**: lowerCamelCase (e.g., `TIME_INCREMENT`, `START_MINUTE`)
- **Files**: lowercase_with_underscores (e.g., `song_library_screen.dart`)

#### Imports
- Group imports: core → package → local
```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song.dart';
import '../services/audio_service.dart';
```

#### Widgets
- Use `const` constructors when possible
- Always use `super.key` parameter
```dart
class SongListTile extends StatelessWidget {
  const SongListTile({super.key});
}
```

#### Async/Error Handling
- Use `try-catch` with `debugPrint` for errors
- Check `mounted` before async operations that affect UI
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

#### Models
- Use `fromJson()` and `toJson()` for serialization
- Implement `copyWith()` for immutability
```dart
class Song {
  final String id;
  final String title;
  
  Song({required this.id, required this.title});
  
  factory Song.fromJson(Map<String, dynamic> json) => Song(...);
  Map<String, dynamic> toJson() => {...};
  Song copyWith({String? id, String? title}) => Song(...);
}
```

#### Services
- Extend `ChangeNotifier` for state management
- Use `notifyListeners()` after state changes
- Dispose streams/subscriptions in `dispose()` method

#### Logging
- Use `debugPrint()` for debug output
- Prefix success/warning/error with emojis for clarity
```dart
debugPrint('✓ AudioService: Play via BackgroundHandler');
debugPrint('✗ Error loading audio: $e');
debugPrint('⚠ Warning: BackgroundHandler is null');
```

---

### Python

#### Type Hints
- Always use type hints for function parameters and return values
```python
from typing import List, Dict, Optional

def parse_line(line: str) -> str:
    return line.strip()

def read_file_content(filepath: str) -> List[str]:
    return []
```

#### Docstrings
- Use docstrings for all functions and classes
```python
def is_cyrillic(text: str) -> bool:
    """Check if text contains Cyrillic characters"""
    return any('\u0400' <= c <= '\u04FF' for c in text)
```

#### String Formatting
- Use f-strings for string interpolation
```python
minutes = int(seconds // 60)
return f'{minutes:02d}:{secs:05.2f}'
```

#### File Operations
- Use `pathlib.Path` for path manipulation
- Always specify `encoding='utf-8'` for text files
```python
from pathlib import Path

output_path = Path(output_dir) / f'{base_name}.json'
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
```

#### Error Handling
- Use specific exception handling
- Provide helpful error messages
```python
try:
    df = pd.read_excel(excel_path)
except FileNotFoundError:
    print(f'❌ Excel file not found: {excel_path}')
    return False
```

---

## Testing

### Flutter Tests
- Use `group()` for organizing related tests
- Follow naming: `<ClassName> should <action>`
```dart
void main() {
  group('Song Model Tests', () {
    test('Song should be created correctly', () {
      final song = Song(id: '1', title: 'Test Song');
      expect(song.title, 'Test Song');
    });
  });
}
```

---

## Localization

- App uses `flutter_localizations` with `AppLocalizations`
- Localization files in `app/lib/l10n/`
- Always get localized strings via `AppLocalizations.of(context)`

---

## State Management

- Use `Provider` package for state management
- Services extending `ChangeNotifier` should use `ChangeNotifierProvider`
- Consumers use `Consumer<N>` or `Provider.of<N>(context)`

---

## Database

- Uses `sqflite` for SQLite database
- `DatabaseService` handles all database operations
- Always use transactions for multiple writes

---

## Audio

- Uses `just_audio` for playback
- `audio_service` for background playback
- Handle content URIs (`content://`) vs file paths differently

---

## Key Patterns

### Async Initialization
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}
```

### PostFrameCallback
Use `WidgetsBinding.instance.addPostFrameCallback()` for operations after first build

### Null Safety
- Use `String?` for nullable types
- Use `!` only when you're certain value is non-null
- Use `??` for null coalescing

---

## Dependencies Management

Run `flutter pub get` after modifying `app/pubspec.yaml`

---

## File Organization

- **models/**: Data models (Song, Playlist, Translation, LyricLine)
- **services/**: Business logic (AudioService, DatabaseService, TranslationService)
- **screens/**: UI screens (SongLibraryScreen, PlayerScreen, SettingsScreen)
- **widgets/**: Reusable components (SongListTile, EmptyLibraryWidget)
- **utils/**: Utility functions (SnackBarHelper, LrcFormatter)
- **constants/**: Constants and configuration (DeepSeekPrompts, GenerationConstants)
- **screens/helpers/**: Helper classes for complex screens (SongImportHelper, PlayerPlaylistHelper)
