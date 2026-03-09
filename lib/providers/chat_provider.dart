import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import 'db_provider.dart';

// Group chat - auto-refreshes every 2 seconds
class GroupChatNotifier extends Notifier<AsyncValue<List<ChatMessage>>> {
  Timer? _timer;

  @override
  AsyncValue<List<ChatMessage>> build() {
    _load();
    // Poll every 2s for fast "real-time" feel
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _load());
    ref.onDispose(() => _timer?.cancel());
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    try {
      final db = ref.read(dbHelperProvider);
      final msgs = await db.getGroupMessages();
      state = AsyncValue.data(msgs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> send(String senderName, String message) async {
    final db = ref.read(dbHelperProvider);
    await db.insertChatMessage(ChatMessage(
      senderName: senderName,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      chatType: 'group',
    ));
    await _load();
  }

  Future<void> delete(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteChatMessage(id);
    await _load();
  }
}

final groupChatProvider =
    NotifierProvider<GroupChatNotifier, AsyncValue<List<ChatMessage>>>(
        GroupChatNotifier.new);

// Private chat - parameterized by "user1|user2" sorted key
class PrivateChatNotifier
    extends FamilyNotifier<AsyncValue<List<ChatMessage>>, String> {
  Timer? _timer;

  @override
  AsyncValue<List<ChatMessage>> build(String arg) {
    _load();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _load());
    ref.onDispose(() => _timer?.cancel());
    return const AsyncValue.loading();
  }

  List<String> get _users => arg.split('|');

  Future<void> _load() async {
    try {
      final db = ref.read(dbHelperProvider);
      final msgs = await db.getPrivateMessages(_users[0], _users[1]);
      state = AsyncValue.data(msgs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> send(String senderName, String message) async {
    final receiver = _users.firstWhere((u) => u != senderName,
        orElse: () => _users[1]);
    final db = ref.read(dbHelperProvider);
    await db.insertChatMessage(ChatMessage(
      senderName: senderName,
      message: message,
      timestamp: DateTime.now().toIso8601String(),
      chatType: 'private',
      receiverName: receiver,
    ));
    await _load();
  }

  Future<void> delete(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteChatMessage(id);
    await _load();
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
