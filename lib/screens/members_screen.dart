import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: AppColors.kAppBarHeight,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.gradientPurplePink),
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
                          child: const Icon(Icons.people_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'সদস্য তালিকা',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'মেসের সকল সদস্য',
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

          state.when(
            loading: () =>
                const SliverFillRemaining(child: LoadingWidget()),
            error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('ত্রুটি: $e'))),
            data: (members) {
              if (members.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyWidget(
                    message: 'কোনো সদস্য নেই\nনিচের বোতামে চাপুন',
                    icon: Icons.people_outline,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) =>
                        _MemberCard(member: members[i], ref: ref),
                    childCount: members.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientPurplePink,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showMemberSheet(context, ref, null),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.person_add_rounded, color: Colors.white),
          label: const Text(
            'নতুন সদস্য',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Member member;
  final WidgetRef ref;

  const _MemberCard({required this.member, required this.ref});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      AppColors.gradientPurplePink,
      AppColors.gradientTealBlue,
      AppColors.gradientOrangeYellow,
      AppColors.gradientGreenTeal,
    ];
    final gradient = gradients[member.name.codeUnitAt(0) % gradients.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              onPressed: (_) => _showMemberSheet(context, ref, member),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'সম্পাদনা',
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
            SlidableAction(
              onPressed: (_) => _confirmDeactivate(context, ref, member),
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              icon: Icons.person_off_rounded,
              label: 'নিষ্ক্রিয়',
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: member.isActive ? gradient : null,
                    color: member.isActive ? null : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      member.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color:
                            member.isActive ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color:
                              member.isActive ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      if (member.phone?.isNotEmpty == true) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.phone_rounded,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              member.phone!,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ],
                      if (member.email?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.email_rounded,
                                size: 12, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                member.email!,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: member.isActive
                        ? AppColors.green.withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    member.isActive
                        ? Icons.check_rounded
                        : Icons.close_rounded,
                    color: member.isActive ? AppColors.green : Colors.grey,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showMemberSheet(
    BuildContext context, WidgetRef ref, Member? existing) async {
  final nameCtrl = TextEditingController(text: existing?.name);
  final phoneCtrl = TextEditingController(text: existing?.phone);
  final emailCtrl = TextEditingController(text: existing?.email);
  final formKey = GlobalKey<FormState>();

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final bottomPad = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: const BoxDecoration(
            color: AppColors.kSheetBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPurplePink,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        existing == null ? 'নতুন সদস্য যোগ' : 'সদস্য সম্পাদনা',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _sheetField(
                            ctrl: nameCtrl,
                            label: 'নাম *',
                            icon: Icons.person_rounded,
                            gradient: AppColors.gradientPurplePink,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'নাম আবশ্যক'
                                : null),
                        const SizedBox(height: 14),
                        _sheetField(
                          ctrl: phoneCtrl,
                          label: 'ফোন নম্বর',
                          icon: Icons.phone_rounded,
                          gradient: AppColors.gradientTealBlue,
                          keyboard: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        _sheetField(
                          ctrl: emailCtrl,
                          label: 'ইমেইল',
                          icon: Icons.email_rounded,
                          gradient: AppColors.gradientOrangeYellow,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientPurplePink,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                final notifier =
                                    ref.read(memberNotifierProvider.notifier);
                                final today = DateFormat('yyyy-MM-dd')
                                    .format(DateTime.now());
                                if (existing == null) {
                                  await notifier.addMember(Member(
                                    name: nameCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                    joinDate: today,
                                  ));
                                } else {
                                  await notifier.updateMember(
                                      existing.copyWith(
                                    name: nameCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                  ));
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Text(
                                existing == null ? 'যোগ করুন' : 'আপডেট করুন',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
  nameCtrl.dispose();
  phoneCtrl.dispose();
  emailCtrl.dispose();
}

Widget _sheetField({
  required TextEditingController ctrl,
  required String label,
  required IconData icon,
  required LinearGradient gradient,
  TextInputType keyboard = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    ),
  );
}

Future<void> _confirmDeactivate(
    BuildContext context, WidgetRef ref, Member m) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.person_off_rounded,
                  color: AppColors.red, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              'সদস্য নিষ্ক্রিয় করুন?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '"${m.name}" কে নিষ্ক্রিয় করতে চান?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('না'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('হ্যাঁ',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (confirmed == true) {
    await ref.read(memberNotifierProvider.notifier).deactivateMember(m.id);
  }
}
