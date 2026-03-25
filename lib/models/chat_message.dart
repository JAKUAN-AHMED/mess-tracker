import 'package:isar/isar.dart';

part 'chat_message.g.dart';

@collection
class ChatMessage {
  Id id = Isar.autoIncrement;
  String senderName = '';
  String message = '';

  @Index()
  String timestamp = '';

  @Index()
  String chatType = 'group'; // 'group' or 'private'

  String? receiverName; // only for private

  ChatMessage({
    String senderName = '',
    String message = '',
    String timestamp = '',
    String chatType = 'group',
    String? receiverName,
  })  : senderName = senderName,
        message = message,
        timestamp = timestamp,
        chatType = chatType,
        receiverName = receiverName;
}
