import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About LingoTune'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.music_note,
              size: 80,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 32),
            const Text(
              'LingoTune',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'v3.40.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Learn languages through music with synchronized lyrics',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Features include audio playback, synchronized lyrics, translations,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.music_note, size: 24),
                      SizedBox(width: 12),
                      Text('🎵 Play your favorite songs'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.headset, size: 24),
                      SizedBox(width: 12),
                      Text('📝 Synchronized lyrics'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.translate, size: 24),
                      SizedBox(width: 12),
                      Text('🌍 Multiple translations'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.format_size, size: 24),
                      SizedBox(width: 12),
                      Text('⏱️ Accurate timing'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.format_color_fill, size: 24),
                      SizedBox(width: 12),
                      Text('🎯 Highlight next lines'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Text(
              'New in v1.1.0:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '✅ Dark mode & theme',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '✅ Font size control',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '✅ Import/Export settings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '✅ Translation editor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '✅ Lyrics search (Lyrics.ovh API)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '✅ AI translation (MyMemory API)',
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 48),
            const Divider(),
            Text(
              'Supported languages:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  Text('English •'),
                  SizedBox(width: 8),
                  Text('Russian •'),
                  SizedBox(width: 8),
                  Text('Romanian •'),
                  const SizedBox(width: 8),
                  Text('French •'),
                  const SizedBox(width: 8),
                  Text('German •'),
                  const SizedBox(width: 8),
                  Text('Spanish •'),
                  const SizedBox(width: 8),
                  Text('Italian •'),
                  const SizedBox(width: 8),
                  Text('Portuguese •'),
                  const SizedBox(width: 8),
                  Text('Chinese •'),
                  const SizedBox(width: 8),
                  Text('Japanese •'),
                  const SizedBox(width: 8),
                  Text('Korean •'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Text(
              'Supported file formats:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  Text('MP3 •'),
                  SizedBox(width: 8),
                  Text('WAV •'),
                  SizedBox(width: 8),
                  Text('M4A •'),
                  SizedBox(width: 8),
                  Text('OGG •'),
                  SizedBox(width: 8),
                  Text('FLAC •'),
                  SizedBox(width: 8),
                  Text('LRC'),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Divider(),
            Text(
              'Credits:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Developed with ❤️ for language learners',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 Z.AI GLM & Цимбалов Артем',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
