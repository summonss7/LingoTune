import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultAutoScrollFocusOffsetControl extends StatefulWidget {
  final double offset;

  const DefaultAutoScrollFocusOffsetControl({super.key, required this.offset});

  @override
  State<DefaultAutoScrollFocusOffsetControl> createState() => _DefaultAutoScrollFocusOffsetControlState();
}

class _DefaultAutoScrollFocusOffsetControlState extends State<DefaultAutoScrollFocusOffsetControl> {
  late double _offset;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
    _controller = TextEditingController(text: _offset.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _updateOffset(double newValue) async {
    final prefs = await SharedPreferences.getInstance();
    final clampedValue = newValue.clamp(-1000.0, 1000.0);
    setState(() {
      _offset = clampedValue;
      _controller.text = clampedValue.toStringAsFixed(0);
    });
    await prefs.setDouble('defaultAutoScrollFocusOffset', _offset);
  }

  void _onTextFieldChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null) return;
    _updateOffset(parsed!);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 20),
          onPressed: _offset > -1000
              ? () => _updateOffset(_offset - 10)
              : null,
          tooltip: '-10',
        ),
        Container(
          width: 60,
          child: TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            onChanged: _onTextFieldChanged,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 20),
          onPressed: _offset < 1000
              ? () => _updateOffset(_offset + 10)
              : null,
          tooltip: '+10',
        ),
      ],
    );
  }
}
