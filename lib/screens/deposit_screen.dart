import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../models/deposit.dart';
import '../providers/deposit_provider.dart';
import '../providers/member_provider.dart';
import '../providers/mess_month_provider.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class DepositScreen extends ConsumerWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMonth = ref.watch(activeMessMonthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('জমা খরচ')),
      body: activeMonth.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (month) {
          if (month == null) {
            return const EmptyWidget(
              message: 'সক্রিয় কোনো মাস নেই',
              icon: Icons.calendar_today,
            );
          }
          return _DepositList(messMonthId: month.id!);
        },
      ),
    );
  }
}

class _DepositList extends ConsumerWidget {
  final int messMonthId;

  const _DepositList({required this.messMonthId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(depositNotifierProvider(messMonthId));
    final members = ref.watch(activeMemberListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('জমা যোগ করুন'),
        onPressed: () =>
            _showDepositDialog(context, ref, members.value ?? []),
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (deposits) {
          if (deposits.isEmpty) {
            return const EmptyWidget(
              message: 'কোনো জমা নেই\nজমা যোগ করুন',
              icon: Icons.account_balance_wallet_outlined,
            );
          }

          final memberMap = {
            for (final m in (members.value ?? [])) m.id: m
          };

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: deposits.length,
            itemBuilder: (ctx, i) {
              final d = deposits[i];
              final member = memberMap[d.memberId];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => ref
                            .read(depositNotifierProvider(messMonthId)
                                .notifier)
                            .deleteDeposit(d.id!),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'মুছুন',
                      ),
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          (member?.name ?? '?')
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(member?.name ?? 'অজানা সদস্য'),
                      subtitle: Text(
                          '${d.date}${d.note.isNotEmpty ? ' • ${d.note}' : ''}'),
                      trailing: AmountText(amount: d.amount),
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

  Future<void> _showDepositDialog(BuildContext context, WidgetRef ref,
      List members) async {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রথমে সদস্য যোগ করুন')),
      );
      return;
    }

    int? selectedMemberId = members.first.id;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('জমা যোগ করুন'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedMemberId,
                    decoration: const InputDecoration(
                      labelText: 'সদস্য *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: members
                        .map((m) => DropdownMenuItem(
                            value: m.id as int,
                            child: Text(m.name as String)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedMemberId = v),
                    validator: (v) =>
                        v == null ? 'সদস্য নির্বাচন করুন' : null,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: amountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'পরিমাণ (টাকা) *',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'পরিমাণ আবশ্যক';
                      if (double.tryParse(v) == null) return 'বৈধ সংখ্যা দিন';
                      return null;
                    },
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'মন্তব্য',
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final notifier = ref
                    .read(depositNotifierProvider(messMonthId).notifier);
                final today =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                await notifier.addDeposit(Deposit(
                  memberId: selectedMemberId!,
                  amount: double.parse(amountCtrl.text),
                  date: today,
                  note: noteCtrl.text.trim(),
                  messMonthId: messMonthId,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('যোগ করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
