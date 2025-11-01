import 'dart:async';
import 'package:flutter/material.dart';

class BinaryKeyboard extends StatefulWidget {
  const BinaryKeyboard({
    super.key,
    required this.labels,
    required this.onSelect,
    required this.onBack,
    required this.onRepeatLast,
    required this.lastChar,
  });

  final List<String> labels; // 6 labels with all chars shown
  final void Function(int index) onSelect;
  final VoidCallback onBack;
  final VoidCallback onRepeatLast;
  final String lastChar;

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
    final canRepeat = widget.lastChar.isNotEmpty;

    return Container(
      color: scheme.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (_cooldownTimer?.isActive ?? false) ? null : () {
                    setState(() => _pressedIndex = -1); // -1 for back button
                    widget.onBack();
                    _cooldownTimer?.cancel();
                    _cooldownTimer = Timer(const Duration(milliseconds: 1000), () {
                      if (mounted) setState(() => _pressedIndex = null);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: _pressedIndex == -1 ? scheme.onError : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: ((_cooldownTimer?.isActive ?? false) || !canRepeat) ? null : () {
                    setState(() => _pressedIndex = -2); // -2 for repeat button
                    widget.onRepeatLast();
                    _cooldownTimer?.cancel();
                    _cooldownTimer = Timer(const Duration(milliseconds: 1000), () {
                      if (mounted) setState(() => _pressedIndex = null);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(
                        color: _pressedIndex == -2 ? scheme.onPrimary : Colors.transparent,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Text(
                    canRepeat ? 'Répéter: ${widget.lastChar}' : 'Répéter',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final items = widget.labels.length >= 6
                    ? widget.labels.take(6).toList()
                    : [...widget.labels, ...List.filled(6 - widget.labels.length, '')];
                
                // Calculate font size based on button size (larger when space allows)
                final buttonHeight = (constraints.maxHeight - 12) / 2;
                final buttonWidth = (constraints.maxWidth - 24) / 3;
                final fontSize = (buttonHeight * 0.25).clamp(24.0, 48.0);

                // Grid fills remaining height
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, i) {
                    final label = items[i];
                    final isPressed = _pressedIndex == i;
                    return ElevatedButton(
                      onPressed: ((_cooldownTimer?.isActive ?? false) || label.isEmpty) ? null : () => _cooldown(i, () => widget.onSelect(i)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: label.isEmpty ? scheme.surfaceVariant : scheme.secondary,
                        foregroundColor: label.isEmpty ? scheme.onSurfaceVariant : scheme.onSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: isPressed ? scheme.onSecondary : Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
