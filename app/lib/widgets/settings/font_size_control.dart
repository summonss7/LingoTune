import 'package:flutter/material.dart';

class FontSizeControl extends StatelessWidget {
  final double fontSize;
  final double minSize;
  final double maxSize;
  final ValueChanged<double> onChanged;

  const FontSizeControl({
    super.key,
    required this.fontSize,
    this.minSize = 10,
    this.maxSize = 32,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: fontSize > minSize
              ? () => onChanged(fontSize - 1)
              : null,
        ),
        Text(
          '${fontSize.toInt()} px',
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: fontSize < maxSize
              ? () => onChanged(fontSize + 1)
              : null,
        ),
      ],
    );
  }
}
