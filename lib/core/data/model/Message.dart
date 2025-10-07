class Message {
  final int id;
  final int senderId;
  final int recipientId;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      recipientId: json['recipient_id'] as int,
      body: json['body'] as String,
      isRead: (json['is_read'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
