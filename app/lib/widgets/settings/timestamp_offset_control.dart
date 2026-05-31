import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/settings_provider.dart';

class TimestampOffsetControl extends StatefulWidget {
  final double offset;

  const TimestampOffsetControl({super.key, required this.offset});

  @override
  State<TimestampOffsetControl> createState() => _TimestampOffsetControlState();
}

class _TimestampOffsetControlState extends State<TimestampOffsetControl> {
  late double _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _offset > 0
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _offset -= 1;
                  });
                  await prefs.setDouble('defaultTimestampOffset', _offset * 60.0);
                  settingsProvider.setDefaultTimestampOffset(_offset * 60.0);
                }
              : null,
        ),
        Text(
          '${_offset.toInt()}',
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _offset < 180
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _offset += 1;
                  });
                  await prefs.setDouble('defaultTimestampOffset', _offset * 60.0);
                  settingsProvider.setDefaultTimestampOffset(_offset * 60.0);
                }
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          'min',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}