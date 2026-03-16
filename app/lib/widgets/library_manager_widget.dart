import 'package:flutter/material.dart';
import '../models/song.dart';

class LibraryManagerWidget extends StatefulWidget {
  final List<Song> songs;
  final Function(Song) onSongTap;
  final Function(Song) onDeleteSong;

  const LibraryManagerWidget({
    super.key,
    required this.songs,
    required this.onSongTap,
    required this.onDeleteSong,
  });

  @override
  State<LibraryManagerWidget> createState() => _LibraryManagerWidgetState();
}

class _LibraryManagerWidgetState extends State<LibraryManagerWidget> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dateAdded;

  List<Song> get _filteredSongs {
    var filtered = widget.songs;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((song) =>
          song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          song.artist.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    switch (_sortOption) {
      case SortOption.dateAdded:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.titleAsc:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.titleDesc:
        filtered.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case SortOption.artistAsc:
        filtered.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
        break;
      case SortOption.artistDesc:
        filtered.sort((a, b) => b.artist.toLowerCase().compareTo(a.artist.toLowerCase()));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search songs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              const Text('Sort by: '),
              DropdownButton<SortOption>(
                value: _sortOption,
                items: SortOption.values.map((option) {
                  return DropdownMenuItem<SortOption>(
                    value: option,
                    child: Text(option.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortOption = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredSongs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No songs found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = _filteredSongs[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          song.title.isNotEmpty ? song.title[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(song.title),
                      subtitle: Text(song.artist),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline),
                            onPressed: () => widget.onSongTap(song),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => widget.onDeleteSong(song),
                            color: Colors.red,
                          ),
                        ],
                      ),
                      onTap: () => widget.onSongTap(song),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

enum SortOption {
  dateAdded('Date Added'),
  titleAsc('Title (A-Z)'),
  titleDesc('Title (Z-A)'),
  artistAsc('Artist (A-Z)'),
  artistDesc('Artist (Z-A)');

  final String label;
  const SortOption(this.label);
}
