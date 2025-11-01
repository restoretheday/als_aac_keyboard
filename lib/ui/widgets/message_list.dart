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
    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final msg = messages[index];
        return ListTile(
          title: Text(
            msg.text,
            style: const TextStyle(fontSize: 20),
          ),
          subtitle: Text(
            msg.createdAt.toLocal().toString(),
            style: const TextStyle(fontSize: 12),
          ),
          onTap: () {
            // Quick-add the most frequent word-like token (simple: first word)
            final firstWord = msg.text.split(RegExp(r"\s+")).firstWhere(
                  (e) => e.isNotEmpty,
                  orElse: () => '',
                );
            if (firstWord.isNotEmpty) {
              onTapWord(firstWord);
            }
          },
        );
      },
    );
  }
}
