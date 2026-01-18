import 'package:flutter/material.dart';

class PredictiveBar extends StatelessWidget {
  const PredictiveBar({
    super.key,
    required this.predictions,
    required this.onAccept,
  });

  final List<String> predictions;
  final void Function(String word) onAccept;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final hasAny = predictions.isNotEmpty;
    final primary = hasAny ? predictions.first : '';
    final others = hasAny ? predictions.skip(1).toList() : const <String>[];

    final chipTextSize = isLandscape ? 22.0 : 20.0;
    final chipPaddingH = isLandscape ? 18.0 : 16.0;
    final chipPaddingV = isLandscape ? 16.0 : 14.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            children: hasAny
                ? others
                    .map((w) => ActionChip(
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              w,
                              style: TextStyle(
                                fontSize: chipTextSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          onPressed: () => onAccept(w),
                          backgroundColor: scheme.surfaceContainerHighest,
                          padding: EdgeInsets.symmetric(
                            horizontal: chipPaddingH,
                            vertical: chipPaddingV,
                          ),
                        ))
                    .toList()
                : [
                    Text(
                      'Suggestions',
                      style: TextStyle(
                        color: scheme.onSecondaryContainer.withOpacity(0.7),
                        fontSize: chipTextSize,
                      ),
                    )
                  ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: hasAny ? () => onAccept(primary) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            minimumSize: Size(isLandscape ? 240 : 220, isLandscape ? 120 : 100),
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 28 : 24,
              vertical: isLandscape ? 26 : 22,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            hasAny ? primary : 'Accepter',
            style: TextStyle(
              fontSize: isLandscape ? 28 : 26,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
        ),
      ],
    );
  }
}
