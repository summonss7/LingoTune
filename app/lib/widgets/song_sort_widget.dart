import 'package:flutter/material.dart';

class SongSortWidget extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortChanged;

  const SongSortWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort songs',
      onSelected: (value) {
        if (value != null) {
          onSortChanged(value);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'default',
          child: ListTile(
            leading: Icon(Icons.list),
            title: Text('Default'),
            subtitle: Text('As added'),
          ),
        ),
        const PopupMenuItem(
          value: 'title',
          child: ListTile(
            leading: Icon(Icons.sort_by_alpha),
            title: Text('Title'),
            subtitle: Text('A-Z'),
          ),
        ),
        const PopupMenuItem(
          value: 'artist',
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Artist'),
            subtitle: Text('A-Z'),
          ),
        ),
        const PopupMenuItem(
          value: 'date',
          child: ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Date Added'),
            subtitle: Text('Newest first'),
          ),
        ),
      ],
      child: Text('Sort: ${_getSortLabel(currentSort)}'),
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'default':
        return 'Default';
      case 'title':
        return 'Title';
      case 'artist':
        return 'Artist';
      case 'date':
        return 'Date';
      default:
        return 'Default';
    }
  }
}
