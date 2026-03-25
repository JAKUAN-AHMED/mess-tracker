import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;
import 'group_chat_screen.dart';
import 'private_chat_screen.dart';

class ChatHubScreen extends ConsumerWidget {
  const ChatHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final members = ref.watch(activeMemberListProvider);
    final myName = auth.userName ?? '';

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Gradient AppBar
          SliverAppBar(
            expandedHeight: AppColors.kAppBarHeight,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.blue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.chat_bubble_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'মেস চ্যাট',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'গ্রুপ ও ব্যক্তিগত চ্যাট',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Group Chat tile
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(icon: Icons.groups_rounded, label: 'গ্রুপ চ্যাট'),
                  const SizedBox(height: 10),
                  _GroupChatTile(onTap: () {
                    Navigator.push(
                      context,
                      _slideRoute(GroupChatScreen(myName: myName)),
                    );
                  }),
                  const SizedBox(height: 20),
                  _SectionLabel(icon: Icons.person_rounded, label: 'ব্যক্তিগত চ্যাট'),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // Members list for 1:1 chat
          members.when(
            loading: () =>
                const SliverFillRemaining(child: LoadingWidget()),
            error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('ত্রুটি: $e'))),
            data: (memberList) {
              final others = memberList
                  .where((m) => m.name != myName && m.isActive)
                  .toList();

              if (others.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyWidget(
                    message: 'কোনো সদস্য নেই',
                    icon: Icons.people_outline,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final member = others[i];
                      final chatKey =
                          privateChatKey(myName, member.name);
                      return _PrivateChatTile(
                        memberName: member.name,
                        chatKey: chatKey,
                        myName: myName,
                        onTap: () {
                          Navigator.push(
                            context,
                            _slideRoute(PrivateChatScreen(
                              myName: myName,
                              otherName: member.name,
                            )),
                          );
                        },
                      );
                    },
                    childCount: others.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      );
}

class _GroupChatTile extends ConsumerWidget {
  final VoidCallback onTap;
  const _GroupChatTile({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastMsg = ref.watch(lastGroupMessageProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.groups_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'মেস গ্রুপ চ্যাট',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  lastMsg.when(
                    loading: () => Text(
                      'লোড হচ্ছে...',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (msg) => Text(
                      msg == null
                          ? 'চ্যাট শুরু করুন!'
                          : '${msg.senderName}: ${msg.message}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivateChatTile extends ConsumerWidget {
  final String memberName;
  final String chatKey;
  final String myName;
  final VoidCallback onTap;

  const _PrivateChatTile({
    required this.memberName,
    required this.chatKey,
    required this.myName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastMsg = ref.watch(lastPrivateMessageProvider(chatKey));

    // Pick a consistent color based on name
    final colors = [
      const Color(0xFFEC4899),
      const Color(0xFFF97316),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];
    final color = colors[memberName.codeUnitAt(0) % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  memberName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memberName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  lastMsg.when(
                    loading: () => Text(
                      'লোড হচ্ছে...',
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 12),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (msg) => Text(
                      msg == null
                          ? 'মেসেজ পাঠান'
                          : (msg.senderName == myName
                              ? 'আপনি: ${msg.message}'
                              : msg.message),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            lastMsg.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (msg) {
                if (msg == null) return const SizedBox.shrink();
                final time = DateTime.tryParse(msg.timestamp);
                if (time == null) return const SizedBox.shrink();
                return Text(
                  DateFormat('HH:mm').format(time),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
