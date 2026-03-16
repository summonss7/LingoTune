import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScrollOffsetControl extends StatefulWidget {
  final double offset;

  const ScrollOffsetControl({super.key, required this.offset});

  @override
  State<ScrollOffsetControl> createState() => _ScrollOffsetControlState();
}

class _ScrollOffsetControlState extends State<ScrollOffsetControl> {
  late double _offset;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _offset > 0
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _offset -= 10;
                  });
                  await prefs.setDouble('scrollOffset', _offset);
                }
              : null,
        ),
        Text(
          '${_offset.toInt()}',
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _offset < 300
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _offset += 10;
                  });
                  await prefs.setDouble('scrollOffset', _offset);
                }
              : null,
        ),
      ],
    );
  }
}
