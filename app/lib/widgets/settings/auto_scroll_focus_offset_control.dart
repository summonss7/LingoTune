import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoScrollFocusOffsetControl extends StatefulWidget {
  final double offset;

  const AutoScrollFocusOffsetControl({super.key, required this.offset});

  @override
  State<AutoScrollFocusOffsetControl> createState() => _AutoScrollFocusOffsetControlState();
}

class _AutoScrollFocusOffsetControlState extends State<AutoScrollFocusOffsetControl> {
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
          icon: const Icon(Icons.arrow_downward),
          onPressed: _offset > -200
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _offset -= 10;
                  });
                  await prefs.setDouble('autoScrollFocusOffset', _offset);
                }
              : null,
          tooltip: 'Move focus up',
          iconSize: 20,
        ),
        Container(
          width: 50,
          alignment: Alignment.center,
          child: Text(
            '${_offset >= 0 ? "+" : ""}${_offset.toInt()}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_upward),
          onPressed: _offset < 200
              ? () async {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _offset += 10;
                  });
                  await prefs.setDouble('autoScrollFocusOffset', _offset);
                }
              : null,
          tooltip: 'Move focus down',
          iconSize: 20,
        ),
      ],
    );
  }
}
