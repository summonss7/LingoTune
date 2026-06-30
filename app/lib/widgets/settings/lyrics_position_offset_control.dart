import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';

class LyricsPositionOffsetControl extends StatefulWidget {
  final double offset;

  const LyricsPositionOffsetControl({super.key, required this.offset});

  @override
  State<LyricsPositionOffsetControl> createState() =>
      _LyricsPositionOffsetControlState();
}

class _LyricsPositionOffsetControlState
    extends State<LyricsPositionOffsetControl> {
  late double _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
  }

  @override
  void didUpdateWidget(covariant LyricsPositionOffsetControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.offset - widget.offset).abs() > 0.0001) {
      _offset = widget.offset;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _offset > 0
              ? () async {
                  final newValue = (_offset - 0.05).clamp(0.0, 1.0);
                  setState(() {
                    _offset = newValue;
                  });
                  await settingsProvider.setLyricsPositionOffset(newValue);
                }
              : null,
        ),
        Text(
          '${_offset.toStringAsFixed(2)}s',
          style: const TextStyle(fontSize: 14),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _offset < 1.0
              ? () async {
                  final newValue = (_offset + 0.05).clamp(0.0, 1.0);
                  setState(() {
                    _offset = newValue;
                  });
                  await settingsProvider.setLyricsPositionOffset(newValue);
                }
              : null,
        ),
      ],
    );
  }
}
