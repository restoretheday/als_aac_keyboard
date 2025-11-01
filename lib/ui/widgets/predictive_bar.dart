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
    final hasAny = predictions.isNotEmpty;
    final primary = hasAny ? predictions.first : '';
    final others = hasAny ? predictions.skip(1).toList() : const <String>[];

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: hasAny
                ? others
                    .map((w) => ActionChip(
                          label: Text(w),
                          onPressed: () => onAccept(w),
                          backgroundColor: scheme.surfaceVariant,
                        ))
                    .toList()
                : [
                    Text(
                      'Suggestions',
                      style: TextStyle(color: scheme.onSecondaryContainer.withOpacity(0.7)),
                    )
                  ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: hasAny ? () => onAccept(primary) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            minimumSize: const Size(180, 56),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(
            hasAny ? primary : 'Accepter',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
