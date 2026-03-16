import 'generation_constants.dart';

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

  static String _getBalancedPrompt(
    String text,
    List<String> languages,
    String sourceLanguage,
    String transcriptionLanguage,
  ) {
    final sourceLanguageName = GenerationConstants.sourceLanguageNames[sourceLanguage] ?? sourceLanguage;

    final langDescriptions = <String>[];
    for (final lang in languages) {
      if (lang == 'trans') {
        langDescriptions.add('- trans: phonetic transcription in standard notation');
      } else if (lang == 'ru_literal') {
        langDescriptions.add('- ru_literal: literal word-for-word translation to Russian');
      } else if (GenerationConstants.supportedLanguages.containsKey(lang)) {
        langDescriptions.add('- $lang: poetic translation to ${GenerationConstants.supportedLanguages[lang]}');
      }
    }

    final languagesStr = langDescriptions.join('\n');

    final transAlphaName = transcriptionLanguage == 'ru' ? 'Russian Cyrillic letters' :
                          transcriptionLanguage == 'en' ? 'English letters' :
                          transcriptionLanguage == 'de' ? 'German letters' :
                          '$transcriptionLanguage letters';

    return '''You are a professional translator and transcription expert specializing in song lyrics. Generate the following for the provided song text:

REQUEST:
Generate for these language variants:
$languagesStr

ALWAYS generate these transcriptions of SOURCE TEXT (NOT of translations):
1. Transcription of SOURCE TEXT using Russian Cyrillic letters (for ALL languages)
2. Transcription of SOURCE TEXT using Latin letters in standard IPA-like notation (for ALL languages)
3. Transcription of SOURCE TEXT using $transAlphaName (ONLY for "trans" file in transcript field)

RULES FOR TRANSLATIONS:
- Provide natural, poetic translation suitable for singing
- Preserve emotional tone and rhythm
- Maintain the flow and style of original lyrics
- Use expressive, musical language
- Make it fit the rhythm if possible

RULES FOR TRANSCRIPTIONS:
- CRITICAL: Transcribe ONLY the SOURCE TEXT provided below, NOT any translations
- Russian Cyrillic: Use standard Russian phonetic conventions, represent SOURCE TEXT sounds accurately
- Latin (standard): Use standard IPA-like notation with Latin letters for SOURCE TEXT
- $transAlphaName: Use $transAlphaName to represent SOURCE TEXT pronunciation
- CRITICAL: ALL transcriptions MUST preserve the exact same line structure as the SOURCE TEXT
- Each line of SOURCE TEXT must have a corresponding line in all transcriptions
- Use \\n characters to separate lines in JSON strings
- Do NOT merge multiple lines into single lines

EXAMPLE:
If SOURCE TEXT is:
"Te iubesc
Iubirea mea"

Then transcriptions should be:
"ru": "Те юбеск
Иубиря мея"
"en": "Te yoobesk
Eoobirea meya"
"latin": "te juˈbesk
juˈbiʁe meja"

Do NOT transcribe the generated translations like "Я тебя люблю" - only transcribe the original Romanian text!

CRITICAL JSON FORMAT RULES:
- Return ONLY valid JSON, no markdown, no code blocks, no explanations
- Ensure all strings are properly escaped: quotes ("), backslashes (\\), newlines (\\n), tabs (\\t)
- Do NOT use unescaped special characters in JSON strings
- All keys and string values MUST be enclosed in double quotes
- The JSON must be complete and parseable
- Do NOT truncate or cut off the response
- CRITICAL: All transcriptions MUST use \\n to separate lines matching SOURCE TEXT structure

OPTIMIZATION: Generate transcriptions ONLY ONCE for the SOURCE TEXT, not per language

Return ONLY valid JSON in this exact format:
{
  "transcriptions": {
    "ru": "...",
    "en": "...",
    "latin": "..."
  },
  "de": {"translation": "..."},
  "en": {"translation": "..."},
  "ru": {"translation": "..."},
  "ru_literal": {"translation": "..."}
}

NOTE:
- "transcriptions" contains ONLY THREE transcriptions of the SOURCE TEXT
- Each language only has "translation", no transcriptions inside
- Transcriptions MUST use \\n line breaks to match each line of SOURCE TEXT

IMPORTANT REMINDER:
- The SOURCE TEXT below is the ONLY text to transcribe
- Do NOT transcribe any generated translations
- Only transcribe the original lyrics provided in SOURCE TEXT

SOURCE TEXT [$sourceLanguageName]:
$text

Return ONLY the valid JSON, nothing else.''';
  }

  static String _getPoeticPrompt(
    String text,
    List<String> languages,
    String sourceLanguage,
    String transcriptionLanguage,
  ) {
    final sourceLanguageName = GenerationConstants.sourceLanguageNames[sourceLanguage] ?? sourceLanguage;

    final langDescriptions = <String>[];
    for (final lang in languages) {
      if (lang == 'trans') {
        langDescriptions.add('- trans: phonetic transcription in standard notation');
      } else if (lang == 'ru_literal') {
        langDescriptions.add('- ru_literal: literal word-for-word translation to Russian');
      } else if (GenerationConstants.supportedLanguages.containsKey(lang)) {
        langDescriptions.add('- $lang: poetic translation to ${GenerationConstants.supportedLanguages[lang]}');
      }
    }

    final languagesStr = langDescriptions.join('\n');

    final transAlphaName = transcriptionLanguage == 'ru' ? 'Russian Cyrillic letters' :
                          transcriptionLanguage == 'en' ? 'English letters' :
                          transcriptionLanguage == 'de' ? 'German letters' :
                          '$transcriptionLanguage letters';

    return '''You are an artistic translator and poet specializing in song lyrics. Create beautiful, singable translations that capture the soul of the original song.

REQUEST:
Generate for these language variants:
$languagesStr

ALWAYS generate these transcriptions of SOURCE TEXT (NOT of translations):
1. Transcription of SOURCE TEXT using Russian Cyrillic letters (for ALL languages)
2. Transcription of SOURCE TEXT using Latin letters in standard IPA-like notation (for ALL languages)
3. Transcription of SOURCE TEXT using $transAlphaName (ONLY for "trans" file in transcript field)

POETIC TRANSLATION PRINCIPLES:
- Focus on EMOTION, IMAGERY, and RHYTHM over literal accuracy
- Create translations that FLOW MUSICALY and are easy to sing
- Preserve the MOOD, ATMOSPHERE, and ARTISTIC INTENT of the original
- Use expressive, evocative language that resonates emotionally
- Adapt idioms and metaphors to preserve their IMPACT, not their literal meaning
- Prioritize how the lyrics FEEL over what they literally mean
- Match the rhythm and syllable count as closely as possible for singability
- If a phrase sounds awkward in the target language, make it BEAUTIFUL instead of literal

RULES FOR TRANSCRIPTIONS:
- CRITICAL: Transcribe ONLY the SOURCE TEXT provided below, NOT any translations
- Russian Cyrillic: Use standard Russian phonetic conventions, represent SOURCE TEXT sounds accurately
- Latin (standard): Use standard IPA-like notation with Latin letters for SOURCE TEXT
- $transAlphaName: Use $transAlphaName to represent SOURCE TEXT pronunciation
- CRITICAL: ALL transcriptions MUST preserve the exact same line structure as the SOURCE TEXT
- Each line of SOURCE TEXT must have a corresponding line in all transcriptions
- Use \\n characters to separate lines in JSON strings
- Do NOT merge multiple lines into single lines

EXAMPLE:
If SOURCE TEXT is:
"Te iubesc
Iubirea mea"

Then transcriptions should be:
"ru": "Те юбеск
Иубиря мея"
"en": "Te yoobesk
Eoobirea meya"
"latin": "te juˈbesk
juˈbiʁe meja"

Do NOT transcribe the generated translations like "Я тебя люблю" - only transcribe the original Romanian text!

CRITICAL JSON FORMAT RULES:
- Return ONLY valid JSON, no markdown, no code blocks, no explanations
- Ensure all strings are properly escaped: quotes ("), backslashes (\\), newlines (\\n), tabs (\\t)
- Do NOT use unescaped special characters in JSON strings
- All keys and string values MUST be enclosed in double quotes
- The JSON must be complete and parseable
- Do NOT truncate or cut off the response
- CRITICAL: All transcriptions MUST use \\n to separate lines matching SOURCE TEXT structure

OPTIMIZATION: Generate transcriptions ONLY ONCE for the SOURCE TEXT, not per language

Return ONLY valid JSON in this exact format:
{
  "transcriptions": {
    "ru": "...",
    "en": "...",
    "latin": "..."
  },
  "de": {"translation": "..."},
  "en": {"translation": "..."},
  "ru": {"translation": "..."},
  "ru_literal": {"translation": "..."}
}

NOTE:
- "transcriptions" contains ONLY THREE transcriptions of the SOURCE TEXT
- Each language only has "translation", no transcriptions inside
- Transcriptions MUST use \\n line breaks to match each line of SOURCE TEXT

IMPORTANT REMINDER:
- The SOURCE TEXT below is the ONLY text to transcribe
- Do NOT transcribe any generated translations
- Only transcribe the original lyrics provided in SOURCE TEXT

SOURCE TEXT [$sourceLanguageName]:
$text

Return ONLY the valid JSON, nothing else.''';
  }

  static String _getLiteralPrompt(
    String text,
    List<String> languages,
    String sourceLanguage,
    String transcriptionLanguage,
  ) {
    final sourceLanguageName = GenerationConstants.sourceLanguageNames[sourceLanguage] ?? sourceLanguage;

    final langDescriptions = <String>[];
    for (final lang in languages) {
      if (lang == 'trans') {
        langDescriptions.add('- trans: phonetic transcription in standard notation');
      } else if (lang == 'ru_literal') {
        langDescriptions.add('- ru_literal: literal word-for-word translation to Russian');
      } else if (GenerationConstants.supportedLanguages.containsKey(lang)) {
        langDescriptions.add('- $lang: literal translation to ${GenerationConstants.supportedLanguages[lang]}');
      }
    }

    final languagesStr = langDescriptions.join('\n');

    final transAlphaName = transcriptionLanguage == 'ru' ? 'Russian Cyrillic letters' :
                          transcriptionLanguage == 'en' ? 'English letters' :
                          transcriptionLanguage == 'de' ? 'German letters' :
                          '$transcriptionLanguage letters';

    return '''You are a literal translator specializing in song lyrics. Create word-for-word translations that maintain exact meaning and structure.

REQUEST:
Generate for these language variants:
$languagesStr

ALWAYS generate these transcriptions of SOURCE TEXT (NOT of translations):
1. Transcription of SOURCE TEXT using Russian Cyrillic letters (for ALL languages)
2. Transcription of SOURCE TEXT using Latin letters in standard IPA-like notation (for ALL languages)
3. Transcription of SOURCE TEXT using $transAlphaName (ONLY for "trans" file in transcript field)

LITERAL TRANSLATION PRINCIPLES:
- Maintain EXACT WORD-ORDER from source text wherever possible
- Translate WORD-FOR-WORD while ensuring grammatical correctness
- Preserve the ORIGINAL MEANING without adaptation or interpretation
- Do NOT localize idioms - translate them literally with the original structure
- Keep the LITERAL SENSE of each word, even if it sounds awkward
- MINIMIZE stylistic changes - the goal is accuracy, not beauty
- Preserve grammatical forms and structures from the original
- Do NOT add or remove information not present in the source

RULES FOR TRANSCRIPTIONS:
- CRITICAL: Transcribe ONLY the SOURCE TEXT provided below, NOT any translations
- Russian Cyrillic: Use standard Russian phonetic conventions, represent SOURCE TEXT sounds accurately
- Latin (standard): Use standard IPA-like notation with Latin letters for SOURCE TEXT
- $transAlphaName: Use $transAlphaName to represent SOURCE TEXT pronunciation
- CRITICAL: ALL transcriptions MUST preserve the exact same line structure as the SOURCE TEXT
- Each line of SOURCE TEXT must have a corresponding line in all transcriptions
- Use \\n characters to separate lines in JSON strings
- Do NOT merge multiple lines into single lines

EXAMPLE:
If SOURCE TEXT is:
"Te iubesc
Iubirea mea"

Then transcriptions should be:
"ru": "Те юбеск
Иубиря мея"
"en": "Te yoobesk
Eoobirea meya"
"latin": "te juˈbesk
juˈbiʁe meja"

Do NOT transcribe the generated translations like "Я тебя люблю" - only transcribe the original Romanian text!

CRITICAL JSON FORMAT RULES:
- Return ONLY valid JSON, no markdown, no code blocks, no explanations
- Ensure all strings are properly escaped: quotes ("), backslashes (\\), newlines (\\n), tabs (\\t)
- Do NOT use unescaped special characters in JSON strings
- All keys and string values MUST be enclosed in double quotes
- The JSON must be complete and parseable
- Do NOT truncate or cut off the response
- CRITICAL: All transcriptions MUST use \\n to separate lines matching SOURCE TEXT structure

OPTIMIZATION: Generate transcriptions ONLY ONCE for the SOURCE TEXT, not per language

Return ONLY valid JSON in this exact format:
{
  "transcriptions": {
    "ru": "...",
    "en": "...",
    "latin": "..."
  },
  "de": {"translation": "..."},
  "en": {"translation": "..."},
  "ru": {"translation": "..."},
  "ru_literal": {"translation": "..."}
}

NOTE:
- "transcriptions" contains ONLY THREE transcriptions of the SOURCE TEXT
- Each language only has "translation", no transcriptions inside
- Transcriptions MUST use \\n line breaks to match each line of SOURCE TEXT

IMPORTANT REMINDER:
- The SOURCE TEXT below is the ONLY text to transcribe
- Do NOT transcribe any generated translations
- Only transcribe the original lyrics provided in SOURCE TEXT

SOURCE TEXT [$sourceLanguageName]:
$text

Return ONLY the valid JSON, nothing else.''';
  }
}
