# KNOWLEDGE.md — база знаний LingoTune

Вынесено из AGENTS.md (карточка scheduler-064, 31.10.2026), чтобы не раздувать контекст каждого хода сессий. Читай разделы по необходимости.

## Project Structure

- **app/**: Flutter mobile application (Dart 3.0+)
- **scripts/**: Python utilities for lyrics processing and generation
- **input/**: Source files for song processing
- **output/**: Generated lyrics and translations

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

## Theming (theme «Аметист» + seed themes)

- All `ThemeData` is built in exactly ONE place — `main.dart`
  (`_buildTextTheme` / `_seededTheme` / `AmethystPalette.buildTheme`).
  Never construct `ThemeData` in screens.
- **«Аметист»** (`'amethyst'`, key of `themeColor` prefs; default since v5.8.9):
  full-screen vertical gradient behind all screens (via `MaterialApp.builder`
  → `DecoratedBox`), transparent Scaffolds/AppBars, darker gradient cards.
  Light mode = vivid purple `#5E3FE6→#4125C2`, dark = purple-black
  `#1A1428→#0F0B19`; both are dark-brightness schemes (light text).
  Core: `app/lib/theme/app_gradients.dart` — `ThemeExtension<AppGradients>`
  (backdrop / card / transcriptAccent / activeLineHighlight — the active lyric
  line's highlight: dark glass `0x4D000000` on light flood, where
  `primaryContainer` blends into the gradient; `0xFF522DDB` on dark),
  `AmethystPalette` (hex tables + `buildTheme`), context helpers.
- **Skin gate**: `context.isAmethystSkin` is true iff the theme carries the
  `AppGradients` extension — use it (or `context.appBarColor(fallback)` /
  `amethystCardDecoration(context, {radius})`) for any screen-level styling
  that must differ on «Аметист»; all other themes must keep their old look.
- `themeColor` is persisted TWICE (ThemeProvider + SettingsProvider) — always
  write both (see `ColorThemeTile.onChanged`). Default when the key is absent:
  `'amethyst'` (chosen colors are never overridden).
- Semantic status colors (green/red/orange SnackBars, delete buttons, orange
  edit-mode) are intentional — do NOT rebrand them.

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
  `begin` arriving within 5 s after a resume when `PhoneCallService.current == idle`
  (v5.8.11: OR the cached `AudioModeService.lastKnownLineIdle == true`, warmed on every
  resume / watchdog check / play-pre-flight).
  Since v5.8.8 a begin whose `end` never arrives at all (message-notification beep, echo older
  than the window) is cleared by `BackgroundAudioHandler.clearStaleCallPause()` (async since
  v5.8.11): after a **20 s** stale threshold (was 30 s — MUST stay below the ~24 s watchdog
  self-heal, otherwise the flag survives and the NEXT song plays voiceless), confirmed by
  `_confirmedNoCall()` — a LISTENING phone detector reporting `idle` OR the audio line in
  MODE_NORMAL (`AudioManager.getMode()` via `AudioModeService` — permission-free, sees VoIP
  calls too) — it runs the regular `_handleCallResume` (→ `onPlaybackResumed` →
  `resumeSession`). `_selfHealStuckCompletion` additionally calls
  `forceClearCallPauseIfNoCall()` (no age threshold) when the age-gated clear refused.
  Since v5.8.11 `play()` opens with a pre-flight: a stuck `_pausedForCall` is cleared via
  `_clearCallPauseFlags()` (flags only, NO `onPlaybackResumed` — the single `resumeSession`
  comes from the regular `onUserPlay` handoff; a double resume could start two study
  runners) whenever no call is confirmed — the «app idled in memory, user presses play,
  everything glitched» scenario.
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
- **A–B section repeat** (v5.12.0, `AbRepeatController` + `AbRepeatSliderTrackShape`):
  tap the «A–B» player-bar button to mark start A, second tap marks end B —
  the segment loops; third tap / long-press clears. `AudioService` owns the
  controller and enforces the loop on a FINE position stream
  (`createPositionStream` maxPeriod 80 ms) with a raw `_player.seek(A)` —
  works in background, survives no-handler mode. A 400 ms guard after any
  EXPLICIT seek (slider scrub, replay/forward-10) keeps the loop from
  fighting the user's drag. Cleared on `loadAudio` (song change) and on
  study-mode start (segments and the loop would fight over seeks); the
  button is disabled while a study session is active. Marks use the LIVE
  `player.position` (same time-domain rule as timestamp marks). Pure logic
  is unit-tested in `test/ab_repeat_controller_test.dart`.
- **Track completion**: `AudioService.onSongComplete` (fired on `processingState == completed`)
  is guarded while study mode is active — advancement then depends on study's own completion
  detector. A completion watchdog in `PlayerScreen` (`_armCompletionWatchdog`) breaks the
  deadlock when study fails to advance after a call: if the song hasn't changed within ~4 s,
  it forces `_playNextSong()`. While a call/interruption pause is active
  (`isPausedForCall` / `_studyPausedForCall`) OR the study session is user-paused
  (`StudyModeService.isUserPaused`) the watchdog re-arms instead of firing —
  `!player.playing` is legitimate during a pause, not a deadlock (v5.8.5 calls, v5.8.6 user
  pause). Since v5.8.8 that re-arm loop is BOUNDED and self-healing: after 5 dirty re-arms
  (~20 s) in the call branch — or 8 (~32 s) in the user-pause branch, and only when the song
  is already `completed` (a pause on a finished song is a race artifact, not intent) — with
  «no call» confirmed (`_canSelfHealCompletion`, async since v5.8.11: phone detector
  listening+idle OR audio line MODE_NORMAL via `AudioModeService` — self-healing no longer
  dies forever when READ_PHONE_STATE is missing or the detector was frozen by the ROM),
  `_selfHealStuckCompletion` clears the stuck flags (`clearStaleCallPause`, then
  `forceClearCallPauseIfNoCall()` if the age gate refused, `_studyPausedForCall`) and forces
  the next song. Since v5.8.11 the final watchdog branch (playing, not completed) also
  re-arms with a POSITION-stall check (`_watchdogLastPosMs`): two consecutive 4 s ticks with
  a frozen position → force `_playNextSong()` (previously a silent no-op without re-arm
  killed the watchdog on a playing zombie). Since v5.8.12 LoopMode.one HAS its own completion
  watchdog branch too (the early return in `AudioService._onSongCompleted` is GONE —
  `onSongComplete` always fires): the screen arms the watchdog and, when the handler's
  `_restartLoopOne` hasn't revived the track (completed && playing = the just_audio no-op trap,
  or a frozen position), forces a full `_playSong(_currentSong)` reload (≤5 force-reloads per
  completion episode; user pause at a completed song is respected and stands down). While a
  study session is active the handler SKIPS its raw loop-one restart
  (`BackgroundAudioHandler.isStudySessionActive` callback, v5.8.12) — study's
  `onStudyCompleted` → `_playSong` owns the transition without the two fighting over the
  player; `_restartLoopOne` also aborts while `_pausedForCall`. `BackgroundAudioHandler.
  onLoopOneRestartFailed` (v5.8.11) lets PlayerScreen force the full reload when
  `_restartLoopOne` exhausts its retries (v5.8.12: postponed by 1.5 s and retried when
  `_isSongLoading`). `play()` / `playFromStudy()` seek to start first when the player sits at
  `completed` (`_seekToStartIfCompleted`) — a bare `play()` there is a silent no-op. This covers
  the v5.8.7 field bug where a rejected
  call or a notification beep left the session paused while the player kept playing, and each
  song then needed manual pause+play to advance. The late-play race that created that state
  is also plugged at the source: `StudyModeService._pauseSessionInner` re-checks
  `player.playing` at ~1 s and ~3 s after the pause (generation-guarded) and raw-re-pauses
  if an in-flight kick `play()` won.
- **Idle revalidation** (v5.8.11): when the app resumes after >5 min in background
  (`PlayerScreen._revalidateAfterIdle`, hooked in `didChangeAppLifecycleState`),
  stale connections are rebuilt BEFORE the user presses play:
  `TtsCoordinator.revalidateAfterIdle()` (health-probe `setLanguage` with a 4 s timeout;
  on hang/failure → `SystemTtsEngine.reset()` recreates the `FlutterTts` instance — the
  lazy idempotent `initialize` never healed a dead binding), `PhoneCallService.start()`
  re-called if its subscription died, an aged stuck call-pause cleared, and the
  `AudioModeService` cache invalidated and re-warmed. `_ensureTtsReady` distinguishes
  «service unresponsive» (timeout → engine reset → re-check) from «language genuinely
  unavailable» and no longer latches segments-only for the whole session on a transient
  post-idle failure.
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
  Since v5.8.8 `SystemTtsEngine.speak()` also time-boxes (3 s) every speech-param platform call
  (`setLanguage/setSpeechRate/setPitch/setVolume`, via `_safeParam`) and the `speak()` platform
  call itself: after a call/notification the system TTS service rebinds, an un-timed call could
  hang forever and burn the study watchdog TWICE from one incident → speech disabled for the
  rest of the song. A timed-out param is skipped; a timed-out speak resolves as failure
  (one fail-strike max per incident).
  **Failure channel (v5.8.11)**: the `TtsEngine.speak` contract CHANGED — genuine engine
  failures (platform call hung, `result==0`, engine error handler) now complete the future
  with an ERROR; `StudyModeService._speak` counts them into `_ttsFailStreak` exactly like
  its own watchdog timeout (previously every failure resolved "successfully", the streak
  never grew and a post-beep/post-idle TTS rebinding meant silent segments until song end).
  Own `stop()` interruptions still resolve normally (no false strikes; `CarAlertService`
  already try-catches). `SystemTtsEngine` cancels the abandoned utterance (`_tts.stop()`)
  and eats its late completion (`_dropNextCompletion`) so it can neither speak over the
  next line nor complete the NEXT completer early. `setLanguage` no longer latches
  `available=false` on a transient platform exception (only on an honest "no voices").
  `stop()` resets `_ttsFailStreak` so a streak of 1 doesn't instantly latch silence on the
  next song.
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
- **`TtsEngine.reset()`** (v5.8.11): full rebinding — `SystemTtsEngine` recreates the
  `FlutterTts` instance (the lazy idempotent `initialize` never healed a connection Android
  dropped while the app idled in memory), re-applies handlers/engine/language; default no-op
  for engines without a stateful binding. Called by `TtsCoordinator.revalidateAfterIdle()`
  (health-probe `setLanguage` with a 4 s timeout; hang/failure → reset) which is invoked by
  `PlayerScreen._revalidateAfterIdle()` on app resume after >5 min in background, and by
  `_ensureTtsReady` when the language check fails/times out (retry once after reset before
  ever latching segments-only).
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
- **Audio-mode fallback** (v5.8.11): `AudioModeService` (Dart) + `AudioModePlugin` (Kotlin
  MethodChannel `lingotune/audio_mode`) query `AudioManager.getMode()` on demand —
  permission-free, real-time, sees VoIP calls `TelephonyManager` misses. Every "no call"
  decision that used to hard-require the detector (`clearStaleCallPause`,
  `_canSelfHealCompletion`, the stale-echo debounce, the `play()` pre-flight) now accepts
  detector-idle OR MODE_NORMAL; "unknown" (channel unavailable) is treated conservatively
  as "call possible". This keeps stuck-beep self-healing alive when the permission is
  missing/revoked or the detector silently died while the ROM froze the app.
- **VoIP line watcher** (v5.12.3, lingotune-013): while audio is (or was recently)
  audible, `BackgroundAudioHandler` polls a FRESH audio mode every second — messenger
  calls (Viber etc.) set in_call/in_communication while staying invisible to
  `TelephonyManager`, and ROM ducking delivers no interruption event (the song kept
  playing quietly through the whole conversation). Pause/resume go through the SAME
  `_handleCallPause`/`_handleCallResume` machinery; `_confirmedNoCall()` now requires
  detector-idle AND fresh MODE_NORMAL (detector alone would let the sweep resume music
  mid-VoIP-call after 20 s). See the "Interruption policy" section below for details.

---

## Interruption policy: звонок vs beep сообщения (v5.12.2, lingotune-011)

Симптомы «на замкнутом телефоне в наушниках: после SMS перестаёт говорить перевод;
звонок + SMS — песня застревает, через минуту играет новую» — это два независимых
глюка в `BackgroundAudioHandler` + `StudyModeService`. Политика v5.12.2:

**Пауза по прерыванию** (`_handleCallPause(fromPhoneDetector:)`) помнит источник:

- `fromPhoneDetector: true` — нативный детектор звонка (реальный звонок) → порог
  залипания 20 с;
- `false` — interruption-событие `audio_session` (beep SMS/уведомления) → 12 с
  (`_staleBeepPauseTimeout`);
- **echo-suspect** — begin пришёл в окне 5 с после недавнего resume И слушатель
  слышит звук (`_player.playing || wasPlayingRecently`): раньше такое эхо просто
  игнорировалось, и парный end оставался no-op'ом → плеер, паузнутый самим
  just_audio, никто не возобновлял. Теперь beep в окне эха принимается, но с
  порогом самолечения 6 с (`_staleEchoSuspectTimeout`). В тишине эхо по-прежнему
  игнорируется. Пороги — `stalePauseThresholdFor()` (`@visibleForTesting`,
  тестируется в `app/test/interruption_policy_test.dart`).

**Sweep-самолечение середины песни** (`_startCallPauseSweep`): тик каждые 2 с, пока
висит `_pausedForCall`; пауза старше порога + линия подтверждённо свободна
(`_confirmedNoCall`: детектор idle И свежий MODE_NORMAL — v5.12.3, раньше было
«ИЛИ»; детектор не видит VoIP и честно отвечает idle весь мессенджерский разговор)
→ штатный `_handleCallResume` (песня продолжается С ТОЙ ЖЕ строки, с переводом).
До v5.12.2 залипший begin без end лечился только completion-watchdog'ом
(вооружается при завершении песни — отсюда «застряла, через ~минуту играет новую»)
и `_revalidateAfterIdle` (только при возврате из фона — на замкнутом телефоне
не случается). Ответ канала режима «неизвестно» (null) сохраняет прежнюю семантику
— решает детектор.

**Наблюдатель VoIP-линии** (v5.12.3, lingotune-013): мессенджерский звонок (Viber и
др.) невидим для TelephonyManager, а ROM-дакинг не присылает interruption-событие —
музыка «лёгким фоном» играла весь разговор. Пока звук звучал (или звучал за
последние ~2 мин — `wasPlayingRecently`), таймер раз в секунду опрашивает СВЕЖИЙ
`AudioModeService.isLineIdle()` (кэш инвалидируется): линия занята
(in_call/in_communication/ringtone) → `_handleCallPause(fromPhoneDetector: true)`
тем же единым путём (study-хендофф, дедупликация, sweep; порог 20 с); уже висящую
паузу наблюдатель «усыновляет» (`_voipPauseActive`); линия освободилась →
`resumeAfterCall()` — но только «свою»/усыновлённую паузу: beep-пауза (сообщение
линию НЕ занимает, режим остаётся normal) по-прежнему живёт по своим порогам
audio_session-end + sweep — политика lingotune-011 не тронута. Канал режима
недоступен (не Android / плагин умер) → после 3 отказов наблюдатель отключается,
поведение полностью откатывается к прежнему. Решение — чистая функция
`voipLineWatchDecision()` (`@visibleForTesting`, тестируется в
`app/test/interruption_policy_test.dart`).

**interruption-end во время звонка**: beep, пришедший ВО ВРЕМЯ разговора, присылает
свой end, пока линия занята. `_handleCallResume(fromPhoneDetector: false)` теперь
сначала ждёт `_confirmedNoCall()` и при занятой линии игнорирует end («возобновит
настоящий отбой»). Иначе музыка включалась бы посреди разговора, а настоящий отбой
потом был бы no-op.

**Грейс-окно TTS-watchdog** (`StudyModeService.ttsWatchdogSeconds`): первый speak
после resume/старта сессии (`_resumedAt`, окно 20 с) легитимно медленный — drain
движка (engine.stop), синтез офлайн-модели, реактивация аудиосессии на замкнутом
телефоне. Запас watchdog'а для него +8 с (кап 16) вместо +3 (кап 12); два «ложных
зависания» подряд раньше защёлкивали cooldown-глушение перевода на 20–120 с.
Поддержка: drain-таймауты движков укорочены (`OfflineTtsEngine.stop` 750 мс,
`SystemTtsEngine.stop` 1 с) — они сидят внутри окна watchdog'а следующего speak.

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

## Auto-update (`UpdateService` + `UpdateFlow`, v5.9.0; канал Aila — v5.11.0)

- Source of truth for version (v5.11.0, card lingotune-006, canon
  `D:\Scheduler\UPDATES-SYSTEM.md`): the **Aila update center** — manifest v2
  at `UpdateService.ailaManifestUrl`
  (`https://aila.skillcoin.pp.ua/updates/lingotune/manifest.json`, format:
  `project/versionName/versionCode/notes/assets[{name,url,size,sha256,kind}]`).
  **GitHub Releases** (`UpdateService.githubReleasesUrl`) is the automatic
  BACKUP, consulted only when the previous source failed to answer (network /
  non-200 / bad JSON / unusable format). A source that ANSWERS is
  authoritative — its "no update" verdict never falls through to the backup.
  Check chain: custom URL (if set) → Aila → GitHub; a v2 manifest without an
  APK asset (web-release) is unusable for this client → treated as unanswered.
- Version comparison: v2 manifests compare **`versionCode`** (Android rule;
  equal versionName with a higher code IS an update), GitHub tags compare
  semver strings (`compareVersions`, tolerates a leading `v` and prerelease
  suffixes; missing parts = 0). Local version = `AppInfo.version` /
  `AppInfo.versionCode`. `checkForUpdate()` returns a tri-state
  `UpdateCheckResult` (`updateAvailable` / `upToDate` / `sourceUnavailable`).
  Unit tests: `test/update_service_test.dart`.
- Manual check: Settings → «Check for updates» (`UpdateFlow.manualCheck`) —
  update dialog / green «✓ You have the latest version» (`noUpdatesAvailable`)
  / red «failed to check» when ALL sources are unreachable. Auto-check:
  `MainScreen.initState` post-frame + 5 s delay → `UpdateFlow.maybeAutoCheck`
  (throttled to once per HOUR via `lastUpdateCheckMs`, v5.12.1 — was 24 h;
  the mark is set only when a source ANSWERED, so a failed check retries on
  the next launch), silent on everything except an available update.
  Field-verified end-to-end on an emulator (v5.12.1, card lingotune-008):
  auto banner on launch → download (sha256 ok) → system installer →
  the app updated itself 5.12.0/244 → 5.12.1/245. Known limitation: a
  custom `http://` source cannot work in release builds (cleartext blocked
  by the platform since targetSdk 28; the app only allows https) — separate
  card filed.
- Download: streamed `http` into `<externalStorageDir>/updates/
  LingoTune-v<version>.apk` (app-specific dir, no storage permission), progress
  dialog with cancel (`UpdateService.cancelDownload`); the dialog closes only
  from the download completion path (single-pop, no races). **sha256
  verification** (v5.11.0): when the manifest carries `assets[].sha256`, the
  downloaded file is hashed (`crypto`) after the stream ends; a mismatch
  deletes the file and fails the download (integrity rule of the center).
  Sources without a hash (old GitHub/simple manifests) skip the check.
- Install: `OpenFilex.open(path)` (`open_filex`) fires the system installer;
  requires the `REQUEST_INSTALL_PACKAGES` permission (declared) + the user's
  one-time "unknown sources" grant for LingoTune. `url_launcher` is the
  fallback "open release page" action (https VIEW `<queries>` entry declared).
- Custom **update source** (v5.10.0, wish option «б»; https-only since
  lingotune-009): `UpdateService.getCustomManifestUrl()/setCustomManifestUrl()`
  (same `updateManifestUrl` prefs key; `null`/blank = default Aila→GitHub
  chain). The custom URL is checked FIRST and its verdict is final; if it
  fails to answer, the default chain runs. **Only https is accepted** (variant
  Б, agreed in «Хаб ИИ» 31.10.2026): release Android (targetSdk 35) blocks
  cleartext, so an http source always failed with «не удалось проверить».
  `UpdateService.validateCustomManifestUrl()` → `UpdateSourceValidation`
  (ok/httpBlocked/invalid); the dialog snackbar explains the http rejection
  (`updateSourceHttpBlocked` l10n). http stays allowed in debug builds only
  (`app/android/app/src/debug/AndroidManifest.xml` sets
  `usesCleartextTraffic="true"` for LAN tests; release manifest is clean).
  Unit tests cover the round-trip, reset, https/http/debug postures and the
  Android manifest contents.
- **Release publishing** (v5.11.0): `publish_release.ps1` (project root)
  publishes a release to BOTH channels in one command — the Aila center via
  `node D:\Scheduler\tools\publish-update.cjs lingotune --notes-file
  CHANGELOG.md` (manifest v2 + sha256 + history + «Хаб ИИ» notification) and
  GitHub Releases via REST API (tag `v<version>` + APK asset; PAT from
  `GITHUB_TOKEN` or untracked `.github_release_token`; no token → channel
  skipped with a warning, Aila is the source of truth). `-Version`/`-Code`
  default from `pubspec.yaml`/`build.gradle`, `-DryRun`, `-SkipAila`,
  `-SkipGitHub`; exit 0 = primary channel published.
- Playlist **rename** (v5.9.0): `PlaylistService.renamePlaylist` (guards
  system playlists; `all_songs`/`favorites`/`lang_*` are NOT renamable) — UI in
  `PlaylistScreen` card ⋮ menu and `PlaylistSongsScreen` sort menu; duplicate
  names rejected with a SnackBar.
- No-lyrics **equalizer** (v5.9.0): `widgets/audio_equalizer_widget.dart`
  replaces the bare screen in `PlayerScreen` when `lyricLines` is empty.
  Since v5.10.0 it dances to the REAL audio (see «Audio visualizer» below)
  and a header button toggles lyrics ↔ equalizer on ANY song (persisted
  `playerShowEqualizer`; hidden in edit-timestamps mode).

## Audio visualizer (`AudioVisualizerService` + `AudioVisualizerPlugin`, v5.10.0)

- Native Kotlin plugin (`AudioVisualizerPlugin.kt`, registered in
  `MainActivity`): `android.media.audiofx.Visualizer` attached to the global
  output mix (session 0) streams the REAL FFT of whatever is playing (~20
  fps) → 32 log-spaced frequency bands (bytes 0..255) over EventChannel
  `lingotune/audio_visualizer/events`. No file decoding, no audio-path
  changes. Needs RECORD_AUDIO (requested at runtime by the Dart side — same
  permission as car detection). If the ROM refuses to create the Visualizer
  (common on de-Googled ROMs) the widget silently falls back to the old
  sine-wave pseudo-animation.
- Dart wrapper `services/audio_visualizer_service.dart` (singleton): `start()`
  requests the permission, invokes native `start`, broadcasts frames on
  `barStream`; `stop()` releases the native Visualizer (battery) — the
  equalizer widget stops it in `dispose()`.
- `utils/audio_band_processor.dart` (pure Dart, unit-tested in
  `test/audio_band_processor_test.dart`): instant attack + exponential
  release (~160 ms), adaptive gain vs a ~3 s running peak (≤3×), beat
  detection (bass energy vs ~2 s moving average, 220 ms refractory), falling
  peak caps. The painter adds a beat-synced glow pulse and slightly taller
  bars on each beat.

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
  - **Audio**: `AudioService`, `BackgroundAudioHandler`, `AudioPositionCorrector`, `AbRepeatController` (A–B section repeat, v5.12.0)
  - **Data**: `DatabaseService` (sqflite singleton), `LyricsService`, `TranslationService`, `PlaylistService`, `SongImportService`, `FolderImportService`, `FolderConfigService`, `ExportImportService`, `CoverArtService`
  - **AI / API**: `DeepSeekApiService`, `TranslationApiService`, `LyricsApiService`, `LyricsGeneratorService`
  - **Study mode**: `StudyModeService` (line-by-line translation playback coordinator)
  - **TTS**: `TtsCoordinator` (singleton, polymorphic engine) → `services/tts/` (`TtsEngine`, `SystemTtsEngine`, `OfflineTtsEngine`, `OfflineTtsIsolate`, `TtsModelManager`, `TtsCatalog`)
  - **Car detection**: `CarDetectionService` (on-device FFT), `CarAlertService`, `CalibrationProfile`
  - **Phone calls**: `PhoneCallService` (native TelephonyManager EventChannel wrapper),
    `AudioModeService` (permission-free AudioManager.getMode() query — "no call" fallback)
  - **Settings**: `SettingsProvider`, `ThemeProvider`, `SettingsHelper`, `SettingsDialogs`, `SettingsExportService`
  - **Updates**: `UpdateService` (manifest check + APK download + custom source URL), `UpdateFlow` (dialogs/install orchestration, v5.9.0)
  - **Visualizer**: `AudioVisualizerService` (native FFT → equalizer bars, v5.10.0)
- **screens/**: UI screens (SongLibraryScreen, PlayerScreen, PlaylistScreen, PlaylistSongsScreen, SettingsScreen, LyricGeneratorDialog, TextLoaderDialog, TranslationEditorScreen, VoicePackagesScreen, CarCalibrationScreen)
- **screens/helpers/**: Helper classes for complex screens (SongImportHelper, PlayerImportHelper, PlayerPlaylistHelper, PlayerTranslationHelper, SongTranslationLoader, CoverArtHelper, PlaylistImportHelper)
- **widgets/**: Reusable components (SongListTile, EmptyLibraryWidget, MiniPlayerWidget, LyricLineWidget, AudioEqualizerWidget, GenerationOptionsWidget, GenerationProgressWidget, LibraryManagerWidget, BatchSelectionWidget, LoadingWidget, LyricsSearchDialog, SongSortWidget, SelectionModeActions, AbRepeatSliderTrackShape (A–B highlight on the position slider, v5.12.0) + `widgets/settings/` (ApiSettingsTile, TextSettingsSection, DefaultAutoScrollFocusOffsetControl)
- **theme/**: Amethyst gradient skin — `AppGradients` ThemeExtension, `AmethystPalette`, context helpers (`isAmethystSkin`, `appBarColor`, `amethystCardDecoration`)
- **utils/**: Utility functions (SnackBarHelper, LrcFormatter, LanguageHelpers, TtsEngineHelper, Fft, LyricColors — palette + presets for custom lyric-line text colors, see `SettingsProvider.useCustomLyricColors` / `originalTextColor` / `translationTextColor`; since v5.8.10 also the ACTIVE line's highlight color `SettingsProvider.activeLineColor` — applied WITHOUT the `useCustomLyricColors` toggle, overriding the theme default incl. Amethyst's `activeLineHighlight`; since v5.10.0 `AudioBandProcessor` — spectrum frames → equalizer bars: attack/release, adaptive gain, beat detection, peak caps, unit-tested)
- **constants/**: Constants and configuration (DeepSeekPrompts, GenerationConstants)
- **l10n/**: Localization — 11 locales (en, ru, de, es, fr, it, pt, ro, uk, zh, ar), 724 keys each; ARB sources + generated `app_localizations*.dart`
