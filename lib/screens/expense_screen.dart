import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/mess_month_provider.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMonth = ref.watch(activeMessMonthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('দৈনিক বাজার খরচ')),
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
          return _ExpenseList(messMonthId: month.id!);
        },
      ),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  final int messMonthId;

  const _ExpenseList({required this.messMonthId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseNotifierProvider(messMonthId));
    final totalAsync = ref.watch(totalExpensesProvider(messMonthId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('খরচ যোগ করুন'),
        onPressed: () => _showAddDialog(context, ref),
      ),
      body: Column(
        children: [
          totalAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (total) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.shopping_cart),
                  const Gap(8),
                  const Text('মোট বাজার খরচ:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  AmountText(amount: total),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('ত্রুটি: $e')),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const EmptyWidget(
                    message: 'কোনো খরচ নেই\nখরচ যোগ করুন',
                    icon: Icons.shopping_cart_outlined,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  itemCount: expenses.length,
                  itemBuilder: (ctx, i) {
                    final e = expenses[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Slidable(
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  _showEditDialog(context, ref, e),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'সম্পাদনা',
                            ),
                            SlidableAction(
                              onPressed: (_) =>
                                  ref
                                      .read(expenseNotifierProvider(
                                              messMonthId)
                                          .notifier)
                                      .deleteExpense(e.id!),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'মুছুন',
                            ),
                          ],
                        ),
                        child: Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.receipt_long),
                            ),
                            title: Text(e.description),
                            subtitle: Text('${e.date} • ${e.addedBy}'),
                            trailing: AmountText(amount: e.amount),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) =>
      _showExpenseDialog(context, ref, null);

  Future<void> _showEditDialog(
      BuildContext context, WidgetRef ref, Expense existing) =>
      _showExpenseDialog(context, ref, existing);

  Future<void> _showExpenseDialog(
      BuildContext context, WidgetRef ref, Expense? existing) async {
    final amountCtrl =
        TextEditingController(text: existing?.amount.toString());
    final descCtrl =
        TextEditingController(text: existing?.description);
    final byCtrl = TextEditingController(text: existing?.addedBy);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(existing == null ? 'খরচ যোগ করুন' : 'খরচ সম্পাদনা'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'বিবরণ *',
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'বিবরণ আবশ্যক' : null,
                ),
                const Gap(12),
                TextFormField(
                  controller: byCtrl,
                  decoration: const InputDecoration(
                    labelText: 'কে বাজার করেছেন',
                    prefixIcon: Icon(Icons.person),
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
              final notifier =
                  ref.read(expenseNotifierProvider(messMonthId).notifier);
              final today =
                  DateFormat('yyyy-MM-dd').format(DateTime.now());

              if (existing == null) {
                await notifier.addExpense(Expense(
                  amount: double.parse(amountCtrl.text),
                  description: descCtrl.text.trim(),
                  date: today,
                  addedBy: byCtrl.text.trim(),
                  messMonthId: messMonthId,
                ));
              } else {
                await notifier.updateExpense(existing.copyWith(
                  amount: double.parse(amountCtrl.text),
                  description: descCtrl.text.trim(),
                  addedBy: byCtrl.text.trim(),
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
}
