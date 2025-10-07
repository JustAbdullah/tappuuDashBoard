import 'message.dart';

class Conversation {
  final int partnerId;
  final String partnerEmail;
  final int unreadCount;
  final DateTime lastMessageAt;
  final Message lastMessage;

  Conversation({
    required this.partnerId,
    required this.partnerEmail,
    required this.unreadCount,
    required this.lastMessageAt,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      partnerId: json['partner']['id'] as int,
      partnerEmail: json['partner']['email'] as String,
      unreadCount: json['unread_count'] as int,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      lastMessage: Message.fromJson(json['last_message'] as Map<String, dynamic>),
    );
  }
}
