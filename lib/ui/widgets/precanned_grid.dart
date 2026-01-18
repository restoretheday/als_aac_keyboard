import 'dart:async';
import 'package:flutter/material.dart';

class PrecannedGrid extends StatefulWidget {
  const PrecannedGrid({
    super.key,
    required this.labels,
    required this.onSelect,
  });

  final List<String> labels; // 9 labels
  final void Function(int index) onSelect;

  @override
  State<PrecannedGrid> createState() => _PrecannedGridState();
}

class _PrecannedGridState extends State<PrecannedGrid> {
  int? _pressedIndex;
  Timer? _cooldownTimer;

  void _cooldown(int index, VoidCallback cb) {
    if (_cooldownTimer != null && _cooldownTimer!.isActive) return;
    setState(() => _pressedIndex = index);
    cb();
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _pressedIndex = null);
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use different colors for precanned grid to differentiate from keyboard
    final precannedScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6), // Purple/violet
      brightness: Brightness.light,
    );

    return Container(
      color: precannedScheme.surface,
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = widget.labels.length >= 9
              ? widget.labels.take(9).toList()
              : [...widget.labels, ...List.filled(9 - widget.labels.length, '')];
          
          // Calculate button dimensions for 3x3 grid
          final spacing = 10.0;
          final availableWidth = constraints.maxWidth - (2 * spacing);
          final availableHeight = constraints.maxHeight - (2 * spacing);
          final buttonWidth = availableWidth / 3;
          final buttonHeight = availableHeight / 3;
          
          // Calculate font size to maximize text size within buttons
          final fontSize = (buttonHeight * 0.32).clamp(30.0, 96.0);

          // Helper function to split label into 2 lines
          List<String> _splitLabelIntoTwoLines(String label) {
            if (label.isEmpty) return ['', ''];
            final words = label.split(' ');
            if (words.length <= 1) return [label, ''];
            final mid = (words.length / 2).ceil();
            final firstLine = words.sublist(0, mid).join(' ');
            final secondLine = words.sublist(mid).join(' ');
            return [firstLine, secondLine];
          }

          // Grid fills remaining height with square-ish buttons
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: buttonWidth / buttonHeight,
            ),
            itemCount: 9,
            itemBuilder: (context, i) {
              final label = items[i];
              final isPressed = _pressedIndex == i;
              final lines = _splitLabelIntoTwoLines(label);
              return ElevatedButton(
                onPressed: ((_cooldownTimer?.isActive ?? false) || label.isEmpty)
                    ? null
                    : () => _cooldown(i, () => widget.onSelect(i)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: label.isEmpty 
                      ? precannedScheme.surfaceContainerHighest.withOpacity(0.3)
                      : precannedScheme.secondary,
                  foregroundColor: label.isEmpty 
                      ? precannedScheme.onSurfaceVariant.withOpacity(0.4)
                      : precannedScheme.onSecondary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isPressed 
                          ? precannedScheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (lines[0].isNotEmpty)
                        Text(
                          lines[0],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      if (lines[1].isNotEmpty)
                        Text(
                          lines[1],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

