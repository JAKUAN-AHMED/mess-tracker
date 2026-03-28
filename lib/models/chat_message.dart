class ChatMessage {
  final String id;
  final String messId;
  final String senderName;
  final String message;
  final String timestamp;
  final String chatType; // 'group' or 'private'
  final String? receiverName;

  const ChatMessage({
    required this.id,
    required this.messId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.chatType = 'group',
    this.receiverName,
  });

  Map<String, dynamic> toMap() => {
        '_id': id,
        'mess_id': messId,
        'sender_name': senderName,
        'message': message,
        'timestamp': timestamp,
        'chat_type': chatType,
        'receiver_name': receiverName,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        id: m['_id'] as String,
        messId: m['mess_id'] as String,
        senderName: m['sender_name'] as String,
        message: m['message'] as String,
        timestamp: m['timestamp'] as String,
        chatType: (m['chat_type'] as String?) ?? 'group',
        receiverName: m['receiver_name'] as String?,
      );
}
