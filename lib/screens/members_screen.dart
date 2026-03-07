import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(memberNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('সদস্য তালিকা')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: const Text('নতুন সদস্য'),
        onPressed: () => _showMemberDialog(context, ref, null),
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (members) {
          if (members.isEmpty) {
            return const EmptyWidget(
              message: 'কোনো সদস্য নেই\nনতুন সদস্য যোগ করুন',
              icon: Icons.people_outline,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: members.length,
            itemBuilder: (context, i) {
              final m = members[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _showMemberDialog(context, ref, m),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'সম্পাদনা',
                      ),
                      SlidableAction(
                        onPressed: (_) =>
                            _confirmDeactivate(context, ref, m),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.person_off,
                        label: 'নিষ্ক্রিয়',
                      ),
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: m.isActive
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.grey.shade200,
                        child: Text(
                          m.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: m.isActive
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(m.name,
                          style: TextStyle(
                              color: m.isActive ? null : Colors.grey)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (m.phone != null && m.phone!.isNotEmpty)
                            Text(m.phone!),
                          Text(
                            'যোগদান: ${m.joinDate}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: m.isActive
                          ? const Icon(Icons.check_circle,
                              color: Colors.green, size: 18)
                          : const Icon(Icons.cancel,
                              color: Colors.grey, size: 18),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showMemberDialog(
      BuildContext context, WidgetRef ref, Member? existing) async {
    final nameCtrl = TextEditingController(text: existing?.name);
    final phoneCtrl = TextEditingController(text: existing?.phone);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'নতুন সদস্য যোগ করুন' : 'সদস্য সম্পাদনা'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'নাম *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'নাম আবশ্যক' : null,
              ),
              const Gap(12),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'ফোন নম্বর',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final notifier = ref.read(memberNotifierProvider.notifier);
              final today =
                  DateFormat('yyyy-MM-dd').format(DateTime.now());

              if (existing == null) {
                await notifier.addMember(Member(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  joinDate: today,
                ));
              } else {
                await notifier.updateMember(existing.copyWith(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                ));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'যোগ করুন' : 'আপডেট করুন'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeactivate(
      BuildContext context, WidgetRef ref, Member m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('সদস্য নিষ্ক্রিয় করুন'),
        content: Text('আপনি কি "${m.name}" কে নিষ্ক্রিয় করতে চান?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('না')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('হ্যাঁ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(memberNotifierProvider.notifier)
          .deactivateMember(m.id!);
    }
  }
}
