# LingoTune - Agent Guidelines

This is a hybrid Flutter/Dart + Python project for language learning through music.

**Current version: 5.8.7** (see `app/pubspec.yaml`, `app/lib/app_info.dart`,
`app/android/app/build.gradle`). Release history: `docs/CHANGELOG.md`
(consolidated) and `CHANGELOG_v*.dart` in the project root (per-release detail,
the release ritual).

## Documentation Map

- `README.md` (root) — project overview, quick start, doc index (Russian)
- `AGENTS.md` (this file) — authoritative dev guide; update every release
- `docs/ARCHITECTURE.md` — system architecture (Russian)
- `docs/CONTENT_PIPELINE.md` — content pipeline: text → DeepSeek → LRC/JSON/ZIP →
  SUNO → import, plus the local TTS translation-audio pipeline (Russian)
- `docs/CHANGELOG.md` — full version history v4.6.15 → current
- `docs/SETUP.md` — Windows environment setup
- `docs/DATA_FORMATS.md` — LRC / JSON / ZIP / audio format specs
- `docs/TROUBLESHOOTING.md` — FAQ + known Android OEM/TTS quirks
- `docs/plans/` — active (not yet implemented) plans
- `docs/archive/` — completed plans and superseded docs; do not update, reference only

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
- `audio_service` (`BackgroundAudioHandler`) for background playback / media notification
- `audio_session` for audio-focus handling and ducking during TTS / phone calls
- Handle content URIs (`content://`) vs file paths differently (see `AudioService.loadAudio`)
- **Highlight position correction** (`AudioPositionCorrector`): only `LyricsService.updatePosition`
  (lyric-line highlighting) uses the corrected position; slider/time indicators use raw
  `_player.position`. Wall-clock interpolation bridges event-delivery gaps; a *constant* lead
  (one-off ~550 ms hiccup pinned at 500–550 ms) is an artifact and heals back to raw after a
  10 s stability window, while a *growing* lead (real VBR drift) keeps the wall-clock trajectory
  (v5.8.4). Injectable clock → unit tests in `test/audio_position_corrector_test.dart`.
- **Timestamp marks time-domain invariant**: the edit-mode tap writes the LIVE
  `player.position` (just_audio computes it from wall-clock, not the ~5 Hz `positionStream`
  cache which goes stale during edit bursts) through the SAME `AudioPositionCorrector`
  instance the highlight uses — marks and line switching must never live in different
  time domains (v5.8.4 fix: highlight switched early after manual re-timestamping).
- **Zombie-state recovery**: after a TTS audio-session handoff (or a phone call), just_audio
  can report `playing == true` while the position never advances — or fail to restart after
  `completed`. `AudioService.ensurePlaybackAdvancing`, `StudyModeService._kickPlaybackAsync`,
  `BackgroundAudioHandler._restartLoopOne` (loop-one restart) and
  `BackgroundAudioHandler._ensureAdvancingAfterResume` (post-call resume; since v5.8.5 — two
  rounds with a 5 s gap, gated on a fresh user pause / new interruption) reactivate the
  session, retry `play()`, verify the position actually advances, and nudge the player with a
  seek to force a re-buffer. Kick loops abort when a call pause is active
  (`BackgroundAudioHandler.isPausedForCall`) instead of fighting the pause (music over the
  ringtone).
- **Stale interruption echo** (v5.8.5): on ROMs where `audio_session` events lag, a delayed
  interruption-`begin` of an ALREADY-ENDED call used to trigger a fresh pause with no matching
  `end` → playback frozen forever. `BackgroundAudioHandler._handleCallPause` now ignores a
  `begin` arriving within 5 s after a resume when `PhoneCallService.current == idle`.
- **Loop mode** — `AudioService` is the single source of truth (persisted, pushed to
  `BackgroundAudioHandler`, mirrored in `PlayerScreen` via a listener so lock-screen changes
  are reflected). Button cycle: `off → all → one → allPlaylists → off`. The `favorites` enum
  value is retained only for prefs backward-compat — it is NOT part of the cycle; favorites
  are played by opening the favorites playlist (behaves as `LoopMode.all`). The heart button
  only adds/removes the song from favorites and never changes the playback mode.
  `allPlaylists` + shuffle builds a GLOBAL shuffled queue over the whole library
  (`PlayerScreen._playNextFromShuffledLibrary`): union of all playlists' songs, deduped by
  song id (a song lives both in its folder and in `all_songs`/`favorites`), current song
  not repeated immediately, reshuffled each cycle; the queue itself becomes
  `_activePlaybackList` so indices/prev/notification stay consistent. Without shuffle,
  `allPlaylists` remains sequential (folder by folder, `_playNextFromAllPlaylists`).
- **Track completion**: `AudioService.onSongComplete` (fired on `processingState == completed`)
  is guarded while study mode is active — advancement then depends on study's own completion
  detector. A completion watchdog in `PlayerScreen` (`_armCompletionWatchdog`) breaks the
  deadlock when study fails to advance after a call: if the song hasn't changed within ~4 s,
  it forces `_playNextSong()`. While a call/interruption pause is active
  (`isPausedForCall` / `_studyPausedForCall`) OR the study session is user-paused
  (`StudyModeService.isUserPaused`) the watchdog re-arms instead of firing —
  `!player.playing` is legitimate during a pause, not a deadlock (v5.8.5 calls, v5.8.6 user
  pause).
- **Phone calls**: `becomingNoisy` (headphone unplug) is ignored while a call pause is active
  (`_pausedForCall`) — some ROMs fire it on the in-call audio-route change, and it would
  otherwise set `_userPausedDuringCall` and block the legitimate post-call auto-resume.
- **Headphone unplug** (v5.8.1): `audio_session` registers its `ACTION_AUDIO_BECOMING_NOISY`
  receiver only while it holds audio focus, which this app drops constantly (TTS handoff,
  zombie recovery) — so unplug events got lost and playback continued on the speaker.
  The native `BecomingNoisyPlugin` (Kotlin, EventChannel `lingotune/becoming_noisy`, wrapped
  by `BecomingNoisyService`) keeps its own receiver regardless of focus; `BackgroundAudioHandler
  ._handleBecomingNoisy` gates on audibility, defers to the study-aware `onBecomingNoisy`
  callback (PlayerScreen pauses the study session like the FAB does), and the old
  audio_session subscription stays as a fallback.

---

## Study Mode (`StudyModeService`)

- Speaks the translation (TTS) and plays the corresponding song segment per lyric line,
  in the order defined by `StudyModeOrder` (`translationFirst` / `originalFirst` / `overlay`).
- **Pause routing** (v5.8.6): the player-screen FAB is a PURE transport button — it always
  calls `AudioService.pause()/play()` (one shared path for FAB, mini-player, lock-screen,
  notification, media buttons). `BackgroundAudioHandler.pause()/play()` hand off to the
  `onUserPause`/`onUserPlay` callbacks (wired by `PlayerScreen` to
  `StudyModeService.pauseSession()/resumeSession()`) whenever a study session is active —
  a pause that skips `pauseSession()` leaves the session "active, not paused" and gets
  overridden by the kick loop / watchdogs within seconds. Study's OWN pauses/plays (TTS
  phases, kick loop, `pauseSession` tail, `stop`) go through the service variants
  `BackgroundAudioHandler.pauseFromStudy()/playFromStudy()`
  (`AudioService.systemPause()/systemPlay()`) so internal bookkeeping is never mistaken
  for user intent. The kick loop re-checks `_isUserPaused` immediately before `play()`,
  `pauseSession` drains the kick with a 3 s timeout and re-pauses 250 ms later if an
  in-flight `play()` still won. The segment watchdog distinguishes an external pause
  (player not playing, no kick, no call → `pauseSession()`) from a just_audio zombie
  (playing=true, position frozen → force-advance). The top study button is a pure
  on/off toggle in ANY session state (including user-paused); turning the mode OFF
  does NOT touch transport — if something was audible (TTS/segment/recently
  playing) the song keeps playing from the current position via
  `ensurePlaybackAdvancing()` (v5.8.7).
- Overlay mode runs continuously: TTS is triggered over the ducked song at line boundaries
  according to `OverlayTiming` (`start` / `end` / `both`). `ttsOffset` (−5..+5 s, plus =
  later, minus = earlier) shifts the boundary detection in the 150 ms position poll;
  segment modes are sequential by construction and ignore it.
- Per-song override: order, speech rate, speech volume, overlay timing, duck volume and
  TTS offset can be overridden per song (`song_{id}_*` SharedPreferences keys).
- Race-condition hardening via `_sessionToken` and `_speakToken` — invalidates stale
  fire-and-forget callbacks when the song changes or the session stops, preventing
  zombie-kick loops and overlapping audio.
- The `_speak` watchdog disables TTS only after 2 consecutive hangs (`_ttsFailStreak`);
  `resumeSession()` re-enables speech (`_speakDisabled=false`, `_ttsFailStreak=0` unconditionally)
  so a hang during a phone call no longer silences the rest of the current song (v5.8.1).
  Since v5.8.5 the disable is **self-healing**: it arms a cooldown (20 s, doubling up to 120 s
  on repeated failures; any successful speak resets it) and after the cooldown `_speak()` probes
  once, so speech returns within the SAME song after a transient interruption (notification
  beep). No probes when the language is genuinely unavailable — segments-only stays permanent.
  Engine `stop()` paths are time-boxed (2 s) so a wedged stop can't hang
  `TtsCoordinator._interruptCurrent` and cascade every following speak into a timeout.
- `pauseSession`/`resumeSession` re-entrancy (v5.8.5): `resumeSession` awaits the in-flight
  pause tail (`_pauseSessionFuture`, 3 s timeout) before starting the runner; a wedged tail is
  stopped by the `_pauseGen` generation token before its player re-pause. A short interruption
  (notification beep ~1–2 s) can no longer have its stale pause tail cancel the just-resumed
  runner. `stop()` bumps the same token.
- Watchdog timers protect against zombie just_audio state: `_segmentWatchdog` forces a line
  advance when the segment completer would otherwise hang forever.
- Persisted flag `studyModeEnabled` auto-restarts study mode on the next song / app restart.

---

## Text-to-Speech (`TtsCoordinator` + `services/tts/`)

- `TtsCoordinator` is a **singleton** (`TtsCoordinator.instance`) holding a polymorphic
  `TtsEngine` selected by the `ttsSource` setting: `SystemTtsEngine` (flutter_tts) or
  `OfflineTtsEngine` (sherpa_onnx VITS, ~63 MB model).
- Priority queue: study-mode translation (`TtsPriority.study`) always dominates car-alert
  voice (`TtsPriority.alert`); an alert fired during a translation is suppressed.
- `_sourceLock` serializes `setTtsSource` / `setLanguage` to avoid the cold-start race where
  two concurrent calls created two engines (and two 63 MB models).
- `OfflineTtsEngine` runs synthesis in a separate isolate (`OfflineTtsIsolate`) to keep the UI
  thread responsive; voice models are downloaded on-demand (`TtsModelManager`).
- `dispose()` releases the active engine and its native resources — called in
  `MainScreen.dispose()` to prevent a ~63 MB leak on hot-restart during development.

---

## Phone-call Detection (`PhoneCallService`)

- Dart wrapper over the native EventChannel `lingotune/phone_state` (Kotlin
  `PhoneCallPlugin` → `TelephonyManager`).
- Rationale: on some ROMs (ColorOS/Realme UI, MIUI/HyperOS, EMUI) system media-ducking
  during a call ignores `audio_session`'s `willPauseWhenDucked`, so the song keeps playing
  silently through the call. A direct `TelephonyManager` listener fires reliably first.
- Emits `CallState.ringing` / `offhook` / `idle`. On non-Android platforms `start()` returns
  `false` and callers fall back to the `audio_session` interruption scheme.
- The plugin dispatches the CURRENT call state on subscribe (sticky, v5.8.5) — a screen
  re-subscribing mid-call no longer misses `ringing`/`offhook`; `PhoneCallService.current`
  exposes the last known state (used by the stale-echo debounce in `BackgroundAudioHandler`).
- Requires `READ_PHONE_STATE` permission, requested at runtime via `permission_handler`
  (`Permission.phone`).

---

## Car Detection (`CarDetectionService` + `CarAlertService`)

- On-device FFT analysis of microphone input (`utils/fft.dart`, `record` plugin, PCM 16 kHz)
  to detect approaching vehicles — a safety feature for runners.
- `CarAlertService` triggers a sound (`assets/sounds/car_alert.wav`) and/or a TTS voice alert
  (routed through `TtsCoordinator` with `TtsPriority.alert`, so it never interrupts a study
  translation).
- `CarCalibrationScreen` lets the user record their own sound samples to build a
  `CalibrationProfile` for better detection accuracy on their device/environment.
- Microphone is optional (`<uses-feature android:required="false"/>`); the feature is simply
  unavailable on devices without a mic.

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

- **models/**: Data models (Song, Playlist, Translation, LyricLine, LoopMode, GenerationResult, TranslationRequest)
- **services/**: Business logic
  - **Audio**: `AudioService`, `BackgroundAudioHandler`, `AudioPositionCorrector`
  - **Data**: `DatabaseService` (sqflite singleton), `LyricsService`, `TranslationService`, `PlaylistService`, `SongImportService`, `FolderImportService`, `FolderConfigService`, `ExportImportService`, `CoverArtService`
  - **AI / API**: `DeepSeekApiService`, `TranslationApiService`, `LyricsApiService`, `LyricsGeneratorService`
  - **Study mode**: `StudyModeService` (line-by-line translation playback coordinator)
  - **TTS**: `TtsCoordinator` (singleton, polymorphic engine) → `services/tts/` (`TtsEngine`, `SystemTtsEngine`, `OfflineTtsEngine`, `OfflineTtsIsolate`, `TtsModelManager`, `TtsCatalog`)
  - **Car detection**: `CarDetectionService` (on-device FFT), `CarAlertService`, `CalibrationProfile`
  - **Phone calls**: `PhoneCallService` (native TelephonyManager EventChannel wrapper)
  - **Settings**: `SettingsProvider`, `ThemeProvider`, `SettingsHelper`, `SettingsDialogs`, `SettingsExportService`
- **screens/**: UI screens (SongLibraryScreen, PlayerScreen, PlaylistScreen, PlaylistSongsScreen, SettingsScreen, LyricGeneratorDialog, TextLoaderDialog, TranslationEditorScreen, VoicePackagesScreen, CarCalibrationScreen)
- **screens/helpers/**: Helper classes for complex screens (SongImportHelper, PlayerImportHelper, PlayerPlaylistHelper, PlayerTranslationHelper, SongTranslationLoader, CoverArtHelper, PlaylistImportHelper)
- **widgets/**: Reusable components (SongListTile, EmptyLibraryWidget, MiniPlayerWidget, LyricLineWidget, GenerationOptionsWidget, GenerationProgressWidget, LibraryManagerWidget, BatchSelectionWidget, LoadingWidget, LyricsSearchDialog, SongSortWidget, SelectionModeActions) + `widgets/settings/` (ApiSettingsTile, TextSettingsSection, DefaultAutoScrollFocusOffsetControl)
- **utils/**: Utility functions (SnackBarHelper, LrcFormatter, LanguageHelpers, TtsEngineHelper, Fft, LyricColors — palette + presets for custom lyric-line text colors, see `SettingsProvider.useCustomLyricColors` / `originalTextColor` / `translationTextColor`)
- **constants/**: Constants and configuration (DeepSeekPrompts, GenerationConstants)
- **l10n/**: Localization — 11 locales (en, ru, de, es, fr, it, pt, ro, uk, zh, ar), 667 keys each; ARB sources + generated `app_localizations*.dart`
