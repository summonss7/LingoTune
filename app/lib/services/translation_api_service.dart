import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationApiService {
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  Future<String?> translateText(String text, String fromLang, String toLang) async {
    if (text.trim().isEmpty) return null;

    try {
      final url = '$_baseUrl?q=${Uri.encodeComponent(text)}&langpair=$fromLang|$toLang';
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        if (data['responseStatus'] == 200 && data['responseData'] != null) {
          final responseData = data['responseData'] as Map<String, dynamic>;
          return responseData['translatedText'] as String?;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error translating text: $e');
    }
  }

  Future<List<String>> translateBatch(List<String> texts, String fromLang, String toLang) async {
    final translations = <String>[];

    for (var text in texts) {
      try {
        final translated = await translateText(text, fromLang, toLang);
        translations.add(translated ?? text);
      } catch (e) {
        translations.add(text);
      }
    }

    return translations;
  }
}
