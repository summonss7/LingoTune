/// Информация о приложении LingoTune
/// Централизованный класс для управления данными о приложении

class AppInfo {
  static const String appName = 'LingoTune';
  static const String packageName = 'com.lingotune.app';
  static const String version = '5.11.0';

  static const String versionCode = '243';
  static const String developerName = 'Z.AI GLM & Цимбалов Артем';
  static const String developerEmail = 'support@lingotune.com';
  static const String website = 'https://lingotune.app';
  static const String privacyPolicyUrl = 'https://lingotune.app/privacy';

  static const String appDescription =
      'Learn languages through music with synchronized lyrics. '
      'Study your favorite songs while seeing the original lyrics and translations in real-time. '
      'Perfect for language learners and music lovers!';

  static const String longDescription =
      'LingoTune is an innovative language learning application that helps you master new languages through music. '
      'With synchronized song lyrics displaying original text alongside translations, you can understand the meaning behind the words while enjoying your favorite tracks. '
      'Features include audio playback, automatic line highlighting, translation support, and more. '
      'Start learning languages the fun way today!';

  static const List<String> features = [
    '🎵 Play your favorite songs',
    '📝 View synchronized lyrics in real-time',
    '🌍 Multiple translation languages support',
    '📊 Line-by-line text and translations',
    '⏱️ Accurate timing with LRC files',
    '🎯 Highlight current and next lines',
    '✏️ Edit translations in app',
    '📝 Edit timestamps manually',
    '🌐 Multi-language app interface',
    '🎤 Transcription support',
    '⚡ Batch lyrics generator',
    '🔍 Search lyrics from online databases',
    '🤖 AI-powered translation (DeepSeek)',
    '💾 Export and import settings',
    '📦 Backup your song library',
    '🚗 Car detection via microphone (safety for runners)',
    '🎚️ Per-song study settings (speed, order, speech rate, speech volume)',
    '🎯 Car detector calibration (record your own sound samples)',
    '🗣️ Offline neural TTS (sherpa_onnx VITS, stable on Chinese ROMs)',
    '🔊 TTS speech volume boost up to 3.0x (peak-normalized)',
    '📞 Auto-pause on incoming call (song + study TTS), smart resume after (respects manual pause & idle state)',
    '🔇 Pause on headphone unplug (native detector, immune to audio-focus loss)',
    '🔊 Study TTS survives phone calls (session reactivation + hang watchdog)',
    '🎯 Overlay translation synced with line highlight (no more lost lines)',
    '📐 Highlight timing correction for VBR MP3 (wall-clock interpolation)',
    '❤ Favorites playlist + play-favorites-only loop mode',
    '🎨 Custom line colors (original & translation): presets + per-type palette',
    '🖍️ Custom highlight color for the active (currently playing) line + clearly visible dark-glass default on the Amethyst theme',
    '⏱️ TTS translation timing offset (speak earlier/later than the lyric timestamp)',
    '🔧 Fix: lyric highlight no longer switches early after manual re-timestamping (corrector heals phantom lead, marks share the highlight time base)',
    '🔧 Fix: study-mode voice recovers by itself after a notification sound (cooldown + retry instead of silence till song end)',
    '🔧 Fix: playback reliably resumes after a phone call (stale interruption echo ignored, second resume-kick round, no next-song jump mid-call)',
    '🔀 Play/pause button is now a pure transport control — voice mode is toggled by its own top button (on/off in any state)',
    '🔧 Fix: pause actually pauses in voice mode — lock-screen/notification/mini-player pause no longer gets overridden by auto-recovery (kick loop, watchdogs)',
    '🔊 Turning voice mode OFF no longer pauses the song (overlay keeps playing, transport untouched)',
    '🔀 Shuffle + "all playlists" now draws almost every song from the whole library across all folders (no folder runs, no repeats per cycle)',
    '🔧 Fix: next song now starts by itself after a rejected call or a message notification (stuck-pause self-healing instead of manual pause+play)',
    '🗣️ Fix: voice translation recovers after a call/notification even when the system TTS service hangs (timed-out engine calls)',
    '💜 New "Amethyst" theme: purple gradient design — one full-screen gradient, darker gradient cards, transparent app bars (light = vivid purple, dark = deep purple-black)',
    '🎨 Inactive lyric lines, transcripts and the About screen now follow the theme colors (readable in dark mode and on the gradient)',
    '🔧 Fix: app kept in memory for a long time no longer glitches on next listen (stale TTS connection rebuilt, stuck call-pause cleared before play)',
    '🔧 Fix: stuck notification-beep pause heals even without phone permission (AudioManager audio-mode check) and no longer kills the voice on the next song',
    '🔁 Fix: repeat-one mode reliably restarts the finished song (completion watchdog + full-reload fallback; play button on a finished song replays it instead of silence)',
    '✏️ Rename playlists — from the card menu in the playlist list or inside an open playlist',
    '🎚️ Animated equalizer on the player screen when the song has no lyrics (was an empty screen)',
    '📊 Equalizer dances to the REAL music: native spectrum analysis (rhythm, beat, volume) with glowing beat pulses and falling peak caps',
    '🎚️ Equalizer button on the player header — switch lyrics ↔ visualizer on any song (when you are tired of reading)',
    '⬆️ In-app auto-update: checks the family Aila update center once a day, shows what\'s new, downloads the APK and starts the install',
    '🔗 Custom update source: any manifest URL (JSON with version + APK link) instead of the default channel',
    '🛡️ GitHub Releases stays as an automatic backup channel; downloaded APKs are verified by sha256',
    '✓ Explicit "you have the latest version" confirmation on every update check',
  ];

  static const List<String> supportedLanguages = [
    'English',
    'Russian',
    'Romanian',
    'French',
    'German',
    'Spanish',
    'Italian',
    'Portuguese',
    'Chinese',
    'Arabic',
    'Ukrainian',
    'Japanese',
    'Korean',
  ];

  static const List<String> audioFormats = [
    'MP3',
    'WAV',
    'M4A',
    'OGG',
  ];

  static const List<String> fileFormats = [
    'LRC (Lyrics)',
    'JSON (Translations)',
  ];

  static String getFullName() {
    return '$appName v$version';
  }

  static Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'version': version,
      'versionCode': versionCode,
      'developerName': developerName,
      'developerEmail': developerEmail,
      'website': website,
      'privacyPolicyUrl': privacyPolicyUrl,
      'appDescription': appDescription,
      'longDescription': longDescription,
      'features': features,
      'supportedLanguages': supportedLanguages,
      'audioFormats': audioFormats,
      'fileFormats': fileFormats,
    };
  }
}
