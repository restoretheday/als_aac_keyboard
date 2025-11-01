class Message {
  Message({required this.text, required this.createdAt});

  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
