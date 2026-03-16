import 'package:flutter/material.dart';

class SelectionModeActions extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onDeleteSelected;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onExitSelectionMode;

  const SelectionModeActions({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onDeleteSelected,
    required this.onAddToPlaylist,
    required this.onExitSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Selected: $selectedCount songs',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: 'Select all',
            onPressed: onSelectAll,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear selection',
            onPressed: onClearSelection,
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Add to playlist',
            onPressed: onAddToPlaylist,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete selected',
            color: Colors.red,
            onPressed: onDeleteSelected,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Exit selection mode',
            onPressed: onExitSelectionMode,
          ),
        ],
      ),
    );
  }
}
