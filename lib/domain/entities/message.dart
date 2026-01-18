class Message {
  Message({required this.text, required this.createdAt, String? id})
      : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  final String id;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String?,
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
