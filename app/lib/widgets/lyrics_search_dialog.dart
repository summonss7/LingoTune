import 'package:flutter/material.dart';
import '../services/lyrics_api_service.dart';

class LyricsSearchDialog extends StatefulWidget {
  final String artist;
  final String title;
  final Function(String) onLyricsFetched;

  const LyricsSearchDialog({
    super.key,
    required this.artist,
    required this.title,
    required this.onLyricsFetched,
  });

  @override
  State<LyricsSearchDialog> createState() => _LyricsSearchDialogState();
}

class _LyricsSearchDialogState extends State<LyricsSearchDialog> {
  final LyricsApiService _apiService = LyricsApiService();
  bool _isLoading = false;
  String? _lyrics;
  String? _error;

  Future<void> _searchLyrics() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _lyrics = null;
    });

    try {
      final lyrics = await _apiService.fetchLyrics(
        widget.artist,
        widget.title,
      );

      if (!mounted) return;
      setState(() {
        _lyrics = lyrics;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchLyrics();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Lyrics'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.artist} - ${widget.title}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Column(
                children: [
                  Text(
                    'Error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _searchLyrics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              )
            else if (_lyrics != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_lyrics!),
                ),
              )
            else
              const Text('No lyrics found'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (_lyrics != null)
          ElevatedButton(
            onPressed: () {
              widget.onLyricsFetched(_lyrics!);
              Navigator.of(context).pop();
            },
            child: const Text('Import'),
          ),
      ],
    );
  }
}
