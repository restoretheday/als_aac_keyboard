import 'dart:async';
import 'package:flutter/material.dart';

class BinaryKeyboard extends StatefulWidget {
  const BinaryKeyboard({
    super.key,
    required this.labels,
    required this.onSelect,
  });

  final List<String> labels; // 6 labels with all chars shown
  final void Function(int index) onSelect;

  @override
  State<BinaryKeyboard> createState() => _BinaryKeyboardState();
}

class _BinaryKeyboardState extends State<BinaryKeyboard> {
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final items = widget.labels.length >= 6
              ? widget.labels.take(6).toList()
              : [...widget.labels, ...List.filled(6 - widget.labels.length, '')];
          
          // Calculate button dimensions for 3x2 grid
          // Reduce available height by 30% to make buttons smaller and give more space to lower buttons
          final spacing = 10.0;
          final availableWidth = constraints.maxWidth - (2 * spacing);
          final availableHeight = (constraints.maxHeight - spacing) * 0.7; // Reduce by 30%
          final buttonWidth = availableWidth / 3;
          final buttonHeight = availableHeight / 2;
          
          // Calculate font size to maximize text size within buttons
          // Use a larger multiplier to make text as big as possible for 2-line display
          final fontSize = (buttonHeight * 0.32).clamp(30.0, 96.0);

          String _formatLabel(String label) {
            final buffer = StringBuffer();
            for (final rune in label.runes) {
              final ch = String.fromCharCode(rune);
              final lower = ch.toLowerCase();
              final isAsciiLetter = lower.compareTo('a') >= 0 && lower.compareTo('z') <= 0;
              final isAccent = lower == 'é' || lower == 'è' || lower == 'à';
              if (isAsciiLetter && !isAccent) {
                buffer.write(lower.toUpperCase());
              } else {
                buffer.write(ch);
              }
            }
            return buffer.toString();
          }

          // Helper function to split label into 2 lines
          List<String> _splitLabelIntoTwoLines(String label) {
            if (label.isEmpty) return ['', ''];
            final chars = label.split(' ').join('').split('');
            if (chars.length <= 1) return [label, ''];
            final mid = (chars.length / 2).ceil();
            final firstLine = chars.sublist(0, mid).join(' ');
            final secondLine = chars.sublist(mid).join(' ');
            return [firstLine, secondLine];
          }

          // Grid aligned to bottom with padding
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: SizedBox(
                height: availableHeight + spacing,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: buttonWidth / buttonHeight,
                  ),
                  itemCount: 6,
            itemBuilder: (context, i) {
              final label = items[i];
              final displayLabel = _formatLabel(label);
              final isPressed = _pressedIndex == i;
              final lines = _splitLabelIntoTwoLines(displayLabel);
              return ElevatedButton(
                onPressed: ((_cooldownTimer?.isActive ?? false) || label.isEmpty)
                    ? null
                    : () => _cooldown(i, () => widget.onSelect(i)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: label.isEmpty 
                      ? scheme.surfaceContainerHighest.withOpacity(0.3)
                      : scheme.secondary,
                  foregroundColor: label.isEmpty 
                      ? scheme.onSurfaceVariant.withOpacity(0.4)
                      : scheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isPressed 
                          ? scheme.primary.withOpacity(0.5)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
