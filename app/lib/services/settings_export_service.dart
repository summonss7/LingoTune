import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SettingsExportService {
  static Future<String> exportSettings(Map<String, dynamic> settings) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, 'lingotune_settings.json'));
    
    await file.writeAsString(json.encode(settings));
    
    return file.path;
  }

  static Future<Map<String, dynamic>> importSettings(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw Exception('Settings file not found');
    }
    
    final content = await file.readAsString();
    return json.decode(content) as Map<String, dynamic>;
  }

  static Future<String> exportSongData(Map<String, dynamic> songData) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, 'lingotune_songs_backup.json'));
    
    await file.writeAsString(json.encode(songData));
    
    return file.path;
  }

  static Future<Map<String, dynamic>> importSongData(String filePath) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw Exception('Song backup file not found');
    }
    
    final content = await file.readAsString();
    return json.decode(content) as Map<String, dynamic>;
  }
}
