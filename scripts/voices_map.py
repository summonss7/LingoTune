"""Mapping of LingoTune language codes to edge-tts voice names.

Covers all language codes from `app/lib/constants/generation_constants.dart`
(GenerationConstants.supportedLanguages).

Default voice per language is exposed via `get_voice_for_language()`.
A list of alternatives (female/male pairs) is provided for future picker UI
or `--voice` overrides.
"""

# Default voice per LingoTune language code
LANG_TO_VOICE = {
    'ro': 'ro-RO-AndreiNeural',
    'ru': 'ru-RU-DmitryNeural',
    'ru_literal': 'ru-RU-SvetlanaNeural',
    'en': 'en-US-GuyNeural',
    'de': 'de-DE-ConradNeural',
    'es': 'es-ES-AlvaroNeural',
    'fr': 'fr-FR-HenriNeural',
    'it': 'it-IT-DiegoNeural',
    'pt': 'pt-BR-AntonioNeural',
    'zh': 'zh-CN-XiaoxiaoNeural',
    'ar': 'ar-EG-SalmaNeural',
    'uk': 'uk-UA-PolinaNeural',
    # `trans` is a phonetic transcription written with Russian letters,
    # so it is spoken with a Russian voice.
    'trans': 'ru-RU-SvetlanaNeural',
}

# Female voice per language code (used by --variant v2 "echo" preset).
# Falls back to the default voice if a language has no dedicated female mapping.
LANG_TO_FEMALE_VOICE = {
    'ro': 'ro-RO-AlinaNeural',
    'ru': 'ru-RU-SvetlanaNeural',
    'ru_literal': 'ru-RU-SvetlanaNeural',
    'en': 'en-US-AriaNeural',
    'de': 'de-DE-KatjaNeural',
    'es': 'es-ES-ElviraNeural',
    'fr': 'fr-FR-DeniseNeural',
    'it': 'it-IT-ElsaNeural',
    'pt': 'pt-BR-FranciscaNeural',
    'zh': 'zh-CN-XiaoxiaoNeural',
    'ar': 'ar-EG-SalmaNeural',
    'uk': 'uk-UA-PolinaNeural',
    'trans': 'ru-RU-SvetlanaNeural',
}

# Alternative voices (useful for `--voice` overrides or future UI)
LANG_VOICE_ALTERNATIVES = {
    'ro': ['ro-RO-AlinaNeural', 'ro-RO-AndreiNeural'],
    'ru': ['ru-RU-SvetlanaNeural', 'ru-RU-DmitryNeural'],
    'ru_literal': ['ru-RU-SvetlanaNeural', 'ru-RU-DmitryNeural'],
    'en': ['en-US-JennyNeural', 'en-US-GuyNeural', 'en-GB-SoniaNeural'],
    'de': ['de-DE-KatjaNeural', 'de-DE-ConradNeural'],
    'es': ['es-ES-ElviraNeural', 'es-ES-AlvaroNeural', 'es-MX-DaliaNeural'],
    'fr': ['fr-FR-DeniseNeural', 'fr-FR-HenriNeural', 'fr-CA-AntoineNeural'],
    'it': ['it-IT-ElsaNeural', 'it-IT-DiegoNeural'],
    'pt': ['pt-BR-FranciscaNeural', 'pt-BR-AntonioNeural', 'pt-PT-RaquelNeural'],
    'zh': ['zh-CN-XiaoxiaoNeural', 'zh-CN-YunyangNeural', 'zh-TW-HsiaoChenNeural'],
    'ar': ['ar-EG-SalmaNeural', 'ar-SA-HamedNeural', 'ar-AE-FatimaNeural'],
    'uk': ['uk-UA-PolinaNeural', 'uk-UA-OstapNeural'],
    'trans': ['ru-RU-SvetlanaNeural', 'ru-RU-DmitryNeural'],
}


def get_voice_for_language(language: str) -> str:
    """Return the default edge-tts voice name for the given language code.

    Returns an empty string if the language is unknown.
    """
    return LANG_TO_VOICE.get(language, '')


def get_female_voice_for_language(language: str) -> str:
    """Return a female edge-tts voice for the language.

    Falls back to the default voice if no female mapping exists.
    """
    return LANG_TO_FEMALE_VOICE.get(language) or LANG_TO_VOICE.get(language, '')


def list_languages() -> list:
    """Return the list of supported language codes (sorted)."""
    return sorted(LANG_TO_VOICE.keys())
