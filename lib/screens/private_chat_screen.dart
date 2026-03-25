import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class PrivateChatScreen extends ConsumerStatefulWidget {
  final String myName;
  final String otherName;

  const PrivateChatScreen({
    super.key,
    required this.myName,
    required this.otherName,
  });

  @override
  ConsumerState<PrivateChatScreen> createState() =>
      _PrivateChatScreenState();
}

class _PrivateChatScreenState extends ConsumerState<PrivateChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  late String _chatKey;

  // Consistent color for the other person
  Color get _otherColor {
    final colors = [
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];
    return colors[widget.otherName.codeUnitAt(0) % colors.length];
  }

  @override
  void initState() {
    super.initState();
    _chatKey = privateChatKey(widget.myName, widget.otherName);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(privateChatProvider(_chatKey));
    chatState.whenData((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
      appBar: AppBar(
        backgroundColor: _otherColor,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_otherColor, _otherColor.withValues(alpha: 0.7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.otherName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.otherName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const Text(
                  'ব্যক্তিগত চ্যাট',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('ত্রুটি: $e')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.otherName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 60,
                            color: _otherColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.otherName} কে মেসেজ করুন',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    final isMe = msg.senderName == widget.myName;
                    return _PrivateBubble(
                      message: msg,
                      isMe: isMe,
                      otherColor: _otherColor,
                      onLongPress: isMe ? () => _delete(msg) : null,
                    );
                  },
                );
              },
            ),
          ),

          _PrivateInputBar(
            ctrl: _msgCtrl,
            sending: _sending,
            accentColor: _otherColor,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    await ref
        .read(privateChatProvider(_chatKey).notifier)
        .send(widget.myName, text);
    setState(() => _sending = false);
  }

  Future<void> _delete(ChatMessage msg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('মেসেজ মুছুন?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('না')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('মুছুন',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(privateChatProvider(_chatKey).notifier)
          .delete(msg.id);
    }
  }
}

class _PrivateBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final Color otherColor;
  final VoidCallback? onLongPress;

  const _PrivateBubble({
    required this.message,
    required this.isMe,
    required this.otherColor,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateTime.tryParse(message.timestamp);
    final timeStr =
        time != null ? DateFormat('HH:mm').format(time) : '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: 6,
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Align(
          alignment:
              isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isMe
                  ? LinearGradient(
                      colors: [otherColor, otherColor.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMe ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isMe
                    ? const Radius.circular(18)
                    : const Radius.circular(4),
                bottomRight: isMe
                    ? const Radius.circular(4)
                    : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (isMe ? otherColor : Colors.black).withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.grey.shade400,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivateInputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final Color accentColor;
  final VoidCallback onSend;

  const _PrivateInputBar({
    required this.ctrl,
    required this.sending,
    required this.accentColor,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: ctrl,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'মেসেজ লিখুন...',
                  hintStyle:
                      TextStyle(color: Color(0xFFADB5BD), fontSize: 14),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          sending
              ? SizedBox(
                  width: 46,
                  height: 46,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: accentColor),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: onSend,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
        ],
      ),
    );
  }
}
