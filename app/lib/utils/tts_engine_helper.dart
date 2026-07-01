import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// A discovered system TTS engine.
class TtsEngineInfo {
  /// Package name of the engine, e.g. `com.google.android.tts`.
  final String name;

  /// Human-friendly label for display in the UI.
  final String label;

  const TtsEngineInfo({required this.name, required this.label});
}

/// Known engine package names mapped to friendly labels so the user sees
/// "Google TTS" instead of "com.google.android.tts" in the picker.
const _knownEngineLabels = <String, String>{
  'com.google.android.tts': 'Google TTS',
  'com.google.android.tts.u9': 'Google TTS',
  'com.samsung.android.samsungtts': 'Samsung TTS',
  'com.heytap.speech.speechengine': 'Heytap (Realme / Oppo)',
  'com.heytap.speechassist': 'Heytap Speech Assist',
  'com.huawei.systemserver.ttsengine': 'Huawei TTS',
  'com.iflytek.speechcloud': 'iFlytek TTS',
  'com.baidu.duersdk.sdk': 'Baidu TTS',
  'com.xiaomi.mibrain.speech': 'Mi Brain TTS',
  'com.android.tts': 'Android TTS',
  'ru.yandex.speechkit': 'Yandex SpeechKit',
};

/// Computes a human-friendly label for an engine package name. Falls back to
/// the package name itself (with the leading "com." stripped for brevity).
String engineLabel(String name) {
  final known = _knownEngineLabels[name];
  if (known != null) return known;
  var label = name;
  for (final prefix in ['com.', 'org.', 'io.']) {
    if (label.startsWith(prefix)) {
      label = label.substring(prefix.length);
      break;
    }
  }
  return label;
}

/// Enumerates the system TTS engines available to the app.
///
/// Creates a short-lived [FlutterTts] instance and queries `getEngines`. On
/// Android 11+ (API 30+) this requires the `TTS_SERVICE` `<queries>`
/// declaration in `AndroidManifest.xml`; without it the engines are invisible
/// to package-visibility filtering and this returns an empty list.
Future<List<TtsEngineInfo>> enumerateTtsEngines() async {
  final tts = FlutterTts();
  try {
    final result = await tts.getEngines;
    final list = (result as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    return list
        .map((name) => TtsEngineInfo(name: name, label: engineLabel(name)))
        .toList();
  } catch (e) {
    debugPrint('⚠ tts_engine_helper: enumerateTtsEngines error: $e');
    return const [];
  }
}
