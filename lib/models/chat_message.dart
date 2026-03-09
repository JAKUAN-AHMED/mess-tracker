class ChatMessage {
  final int? id;
  final String senderName;
  final String message;
  final String timestamp; // ISO 8601
  final String chatType; // 'group' or 'private'
  final String? receiverName; // only for private

  const ChatMessage({
    this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.chatType = 'group',
    this.receiverName,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'sender_name': senderName,
        'message': message,
        'timestamp': timestamp,
        'chat_type': chatType,
        'receiver_name': receiverName ?? '',
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as int?,
        senderName: map['sender_name'] as String,
        message: map['message'] as String,
        timestamp: map['timestamp'] as String,
        chatType: map['chat_type'] as String,
        receiverName: map['receiver_name'] as String?,
      );
}
