import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerticalFocusOffsetSlider extends StatefulWidget {
  final double offset;
  final ValueChanged<double>? onChanged;

  const VerticalFocusOffsetSlider({
    super.key,
    required this.offset,
    this.onChanged,
  });

  @override
  State<VerticalFocusOffsetSlider> createState() => _VerticalFocusOffsetSliderState();
}

class _VerticalFocusOffsetSliderState extends State<VerticalFocusOffsetSlider> {
  late double _offset;
  static const double _maxOffset = 1000.0;

  @override
  void initState() {
    super.initState();
    _offset = widget.offset;
  }

  Future<void> _updateOffset(double newValue) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _offset = newValue;
    });
    await prefs.setDouble('autoScrollFocusOffset', _offset);
    widget.onChanged?.call(_offset);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  Icons.arrow_upward,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Slider(
                        value: _offset,
                        min: -_maxOffset,
                        max: _maxOffset,
                        onChanged: _updateOffset,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 32,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_offset >= 0 ? "+" : ""}${_offset.toInt()}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
