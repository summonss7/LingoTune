import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsApiService {
  static const String _baseUrl = 'https://api.lyrics.ovh/v1';

  Future<String?> fetchLyrics(String artist, String title) async {
    try {
      final encodedArtist = Uri.encodeComponent(artist);
      final encodedTitle = Uri.encodeComponent(title);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/$encodedArtist/$encodedTitle'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['lyrics'] as String?;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch lyrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching lyrics: $e');
    }
  }

  Future<String?> searchAndFetchLyrics(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      
      final response = await http.get(
        Uri.parse('https://api.lyrics.ovh/v1/$encodedQuery'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['lyrics'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
