import 'package:flutter/material.dart';
import '../../domain/entities/message.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.onTapWord,
  });

  final List<Message> messages;
  final void Function(String word) onTapWord;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text('No saved messages yet'));
    }
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final msg = messages[index];
        return ElevatedButton(
          onPressed: () => onTapWord(msg.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              msg.text,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, height: 1.2),
            ),
          ),
        );
      },
    );
  }
}
