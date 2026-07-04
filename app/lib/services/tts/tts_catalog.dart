/// Каталог офлайн-TTS моделей (Piper VITS medium) для sherpa_onnx.
///
/// Источник моделей: https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models
/// Каждая модель = ~63 МБ (full), внутри tar.bz2:
///   <voiceName>/<voice>.onnx        (реальное имя, напр. ru_RU-irina-medium.onnx)
///   <voiceName>/<voice>.onnx.json   (Piper-конфиг)
///   <voiceName>/tokens.txt
///   <voiceName>/espeak-ng-data/     (фонемный словарь espeak-ng)
/// При распаковке [TtsModelManager] переименовывает `<voice>.onnx` /
/// `<voice>.onnx.json` в канонические `model.onnx` / `model.onnx.json`.
///
/// [TtsVoiceInfo.bundled] = true значит модель лежит в `assets/tts/<locale>.tar.bz2`
/// и распаковывается из ассета при первом включении офлайн-режима. Остальные
/// докачиваются по сети из [TtsVoiceInfo.url] через [TtsModelManager].
///
/// Языки без Piper-модели (uk/zh/ar/ja/ko) НЕ входят в каталог — для них
/// [OfflineTtsEngine] автоматически fallback'ает на системный TTS.
class TtsVoiceInfo {
  /// Код языка перевода (как в TranslationService): 'ru', 'en', 'de', ...
  final String languageCode;

  /// Локаль модель-папки: 'ru_RU', 'en_US', ...
  /// Используется как: (1) имя файла ассета `assets/tts/<locale>.tar.bz2`,
  /// (2) имя папки назначения `<docs>/tts/<locale>/`.
  final String localeCode;

  /// Имя voice (Piper): 'vits-piper-ru_RU-irina-medium'.
  /// Соответствует имени подпапки внутри tar.bz2.
  final String voiceName;

  /// Человекочитаемое имя диктора: 'Ирина', 'Amy', ...
  final String speakerName;

  /// Человекочитаемое название языка: 'Русский', 'English', ...
  final String languageLabel;

  /// Полный URL .tar.bz2 на GitHub releases.
  final String url;

  /// Ожидаемый размер архива в байтах (для прогресса и проверки места).
  final int estimatedSizeBytes;

  /// true = модель bundled в APK (assets/tts/<locale>.tar.bz2).
  /// false = нужна докачка.
  final bool bundled;

  const TtsVoiceInfo({
    required this.languageCode,
    required this.localeCode,
    required this.voiceName,
    required this.speakerName,
    required this.languageLabel,
    required this.url,
    required this.estimatedSizeBytes,
    required this.bundled,
  });

  /// Asset-путь бандла в pubspec (только для bundled=true).
  String get bundleAssetPath => 'assets/tts/$localeCode.tar.bz2';

  @override
  String toString() =>
      'TtsVoiceInfo($languageCode, $voiceName, bundled=$bundled)';
}

/// Статический каталог всех доступных офлайн-голосов.
///
/// Используется [TtsModelManager] и [VoicePackagesScreen]. Ключ — languageCode.
class TtsCatalog {
  TtsCatalog._();

  static const String _baseUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models';

  static const Map<String, TtsVoiceInfo> _voices = {
    // === Бандл в APK (распаковка из ассета) ===
    'ru': TtsVoiceInfo(
      languageCode: 'ru',
      localeCode: 'ru_RU',
      voiceName: 'vits-piper-ru_RU-irina-medium',
      speakerName: 'Ирина',
      languageLabel: 'Русский',
      url: '$_baseUrl/vits-piper-ru_RU-irina-medium.tar.bz2',
      estimatedSizeBytes: 67153308, // ~64 MB (реальный размер бандла)
      bundled: true,
    ),
    // === Докачка ===
    'en': TtsVoiceInfo(
      languageCode: 'en',
      localeCode: 'en_US',
      voiceName: 'vits-piper-en_US-amy-medium',
      speakerName: 'Amy',
      languageLabel: 'English',
      url: '$_baseUrl/vits-piper-en_US-amy-medium.tar.bz2',
      estimatedSizeBytes: 63000000,
      bundled: false,
    ),
    'de': TtsVoiceInfo(
      languageCode: 'de',
      localeCode: 'de_DE',
      voiceName: 'vits-piper-de_DE-thorsten-medium',
      speakerName: 'Thorsten',
      languageLabel: 'Deutsch',
      url: '$_baseUrl/vits-piper-de_DE-thorsten-medium.tar.bz2',
      estimatedSizeBytes: 63000000,
      bundled: false,
    ),
    'es': TtsVoiceInfo(
      languageCode: 'es',
      localeCode: 'es_ES',
      voiceName: 'vits-piper-es_ES-davefx-medium',
      speakerName: 'Dave FX',
      languageLabel: 'Español',
      url: '$_baseUrl/vits-piper-es_ES-davefx-medium.tar.bz2',
      estimatedSizeBytes: 63000000,
      bundled: false,
    ),
    'fr': TtsVoiceInfo(
      languageCode: 'fr',
      localeCode: 'fr_FR',
      voiceName: 'vits-piper-fr_FR-siwis-medium',
      speakerName: 'Siwis',
      languageLabel: 'Français',
      url: '$_baseUrl/vits-piper-fr_FR-siwis-medium.tar.bz2',
      estimatedSizeBytes: 63000000,
      bundled: false,
    ),
    'it': TtsVoiceInfo(
      languageCode: 'it',
      localeCode: 'it_IT',
      voiceName: 'vits-piper-it_IT-paola-medium',
      speakerName: 'Paola',
      languageLabel: 'Italiano',
      url: '$_baseUrl/vits-piper-it_IT-paola-medium.tar.bz2',
      estimatedSizeBytes: 63000000,
      bundled: false,
    ),
    'pt': TtsVoiceInfo(
      languageCode: 'pt',
      localeCode: 'pt_BR',
      voiceName: 'vits-piper-pt_BR-faber-medium',
      speakerName: 'Faber',
      languageLabel: 'Português',
      url: '$_baseUrl/vits-piper-pt_BR-faber-medium.tar.bz2',
      estimatedSizeBytes: 63000000,
      bundled: false,
    ),
    'ro': TtsVoiceInfo(
      languageCode: 'ro',
      localeCode: 'ro_RO',
      voiceName: 'vits-piper-ro_RO-mihai-medium',
      speakerName: 'Mihai',
      languageLabel: 'Română',
      url: '$_baseUrl/vits-piper-ro_RO-mihai-medium.tar.bz2',
      estimatedSizeBytes: 63000000,
      bundled: false,
    ),
  };

  /// Все голоса (в стабильном порядке: сначала bundled, потом алфавит).
  static List<TtsVoiceInfo> get all {
    final list = _voices.values.toList();
    list.sort((a, b) {
      if (a.bundled != b.bundled) return a.bundled ? -1 : 1;
      return a.languageCode.compareTo(b.languageCode);
    });
    return list;
  }

  /// Голос по коду языка или null, если язык не поддерживается офлайн.
  static TtsVoiceInfo? forLanguage(String languageCode) =>
      _voices[languageCode.toLowerCase()];

  /// Поддерживается ли язык офлайн-TTS (есть ли модель в каталоге).
  static bool isSupported(String languageCode) =>
      _voices.containsKey(languageCode.toLowerCase());

  /// Языки, для которых модель bundled в APK.
  static Iterable<TtsVoiceInfo> get bundledVoices =>
      _voices.values.where((v) => v.bundled);
}
