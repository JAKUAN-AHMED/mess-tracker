import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import 'db_provider.dart';

// Group chat - reactive stream (no more polling!)
class GroupChatNotifier extends Notifier<AsyncValue<List<ChatMessage>>> {
  StreamSubscription<List<ChatMessage>>? _sub;

  @override
  AsyncValue<List<ChatMessage>> build() {
    _startListening();
    ref.onDispose(() => _sub?.cancel());
    return const AsyncValue.loading();
  }

  void _startListening() {
    final db = ref.read(dbHelperProvider);
    _sub = db.watchGroupMessages().listen(
      (msgs) => state = AsyncValue.data(msgs),
      onError: (e, st) => state = AsyncValue.error(e, st),
    );
  }

  Future<void> send(String senderName, String message) async {
    final db = ref.read(dbHelperProvider);
    await db.insertChatMessage(ChatMessage(
      senderName: senderName,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      chatType: 'group',
    ));
    // Stream fires automatically - no manual reload needed
  }

  Future<void> delete(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteChatMessage(id);
    // Stream fires automatically
  }
}

final groupChatProvider =
    NotifierProvider<GroupChatNotifier, AsyncValue<List<ChatMessage>>>(
        GroupChatNotifier.new);

// Private chat - reactive stream per conversation
class PrivateChatNotifier
    extends FamilyNotifier<AsyncValue<List<ChatMessage>>, String> {
  StreamSubscription<List<ChatMessage>>? _sub;

  @override
  AsyncValue<List<ChatMessage>> build(String arg) {
    _startListening();
    ref.onDispose(() => _sub?.cancel());
    return const AsyncValue.loading();
  }

  List<String> get _users => arg.split('|');

  void _startListening() {
    final db = ref.read(dbHelperProvider);
    _sub = db.watchPrivateMessages(_users[0], _users[1]).listen(
      (msgs) => state = AsyncValue.data(msgs),
      onError: (e, st) => state = AsyncValue.error(e, st),
    );
  }

  Future<void> send(String senderName, String message) async {
    final receiver =
        _users.firstWhere((u) => u != senderName, orElse: () => _users[1]);
    final db = ref.read(dbHelperProvider);
    await db.insertChatMessage(ChatMessage(
      senderName: senderName,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      chatType: 'private',
      receiverName: receiver,
    ));
    // Stream fires automatically
  }

  Future<void> delete(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteChatMessage(id);
    // Stream fires automatically
  }
}

final privateChatProvider =
    NotifierProviderFamily<PrivateChatNotifier, AsyncValue<List<ChatMessage>>,
        String>(PrivateChatNotifier.new);

// Helper to make the chat key
String privateChatKey(String user1, String user2) {
  final sorted = [user1, user2]..sort();
  return sorted.join('|');
}

// Last message previews for chat list
final lastGroupMessageProvider = FutureProvider<ChatMessage?>((ref) async {
  final db = ref.watch(dbHelperProvider);
  return db.getLastGroupMessage();
});

final lastPrivateMessageProvider =
    FutureProvider.family<ChatMessage?, String>((ref, key) async {
  final db = ref.watch(dbHelperProvider);
  final users = key.split('|');
  return db.getLastPrivateMessage(users[0], users[1]);
});
