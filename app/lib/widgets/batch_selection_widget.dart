import 'package:flutter/material.dart';
import '../models/song.dart';

class BatchSelectionWidget extends StatefulWidget {
  final List<Song> songs;
  final Function(Set<String>) onSelectionChanged;

  const BatchSelectionWidget({
    super.key,
    required this.songs,
    required this.onSelectionChanged,
  });

  @override
  State<BatchSelectionWidget> createState() => _BatchSelectionWidgetState();
}

class _BatchSelectionWidgetState extends State<BatchSelectionWidget> {
  final Set<String> _selectedSongIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _selectAll() {
    setState(() {
      _selectedSongIds.clear();
      _selectedSongIds.addAll(widget.songs.map((s) => s.id));
    });
    widget.onSelectionChanged(_selectedSongIds);
  }

  void _clearSelection() {
    setState(() {
      _selectedSongIds.clear();
    });
    widget.onSelectionChanged(_selectedSongIds);
  }

  void _toggleSelection(String songId) {
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
      } else {
        _selectedSongIds.add(songId);
      }
    });
    widget.onSelectionChanged(_selectedSongIds);
  }

  List<Song> get _filteredSongs {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      return widget.songs;
    }
    return widget.songs.where((song) {
      return song.title.toLowerCase().contains(query) ||
          song.artist.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSongs = _filteredSongs;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск песен...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: filteredSongs.length == _selectedSongIds.length
                    ? _clearSelection
                    : _selectAll,
                icon: Icon(
                  filteredSongs.length == _selectedSongIds.length
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                ),
                label: Text(filteredSongs.length == _selectedSongIds.length
                    ? 'Снять'
                    : 'Выбрать все'),
              ),
            ],
          ),
        ),
        if (_selectedSongIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_selectedSongIds.length} песен',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: filteredSongs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty
                            ? 'Нет песен'
                            : 'Ничего не найдено',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = filteredSongs[index];
                    final isSelected = _selectedSongIds.contains(song.id);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => _toggleSelection(song.id),
                      title: Text(
                        song.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(song.artist),
                      secondary: const Icon(Icons.music_note),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
