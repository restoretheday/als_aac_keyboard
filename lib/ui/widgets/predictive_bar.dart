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

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: hasAny
                ? others
                    .map((w) => ActionChip(
                          label: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              w,
                              style: TextStyle(
                                fontSize: isLandscape ? 18 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onPressed: () => onAccept(w),
                          backgroundColor: scheme.surfaceVariant,
                          padding: EdgeInsets.symmetric(
                            horizontal: isLandscape ? 16 : 12,
                            vertical: isLandscape ? 12 : 10,
                          ),
                        ))
                    .toList()
                : [
                    Text(
                      'Suggestions',
                      style: TextStyle(
                        color: scheme.onSecondaryContainer.withOpacity(0.7),
                        fontSize: isLandscape ? 18 : 16,
                      ),
                    )
                  ],
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: hasAny ? () => onAccept(primary) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            minimumSize: Size(isLandscape ? 200 : 180, isLandscape ? 64 : 60),
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 24 : 20,
              vertical: isLandscape ? 16 : 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            hasAny ? primary : 'Accepter',
            style: TextStyle(
              fontSize: isLandscape ? 22 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
