import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../providers/mess_month_provider.dart';
import '../providers/report_provider.dart';
import '../providers/db_provider.dart';
import '../models/mess_month.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final activeMonth = ref.watch(activeMessMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('মেস হিসাব'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'নতুন মাস শুরু করুন',
            onPressed: () => _showNewMonthDialog(context),
          ),
        ],
      ),
      body: activeMonth.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (month) {
          if (month == null) {
            return _noActiveMonth(context);
          }
          return _dashboardContent(context, month);
        },
      ),
    );
  }

  Widget _noActiveMonth(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 72, color: Colors.grey),
          const Gap(16),
          Text('কোনো সক্রিয় মাস নেই',
              style: Theme.of(context).textTheme.titleMedium),
          const Gap(12),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('নতুন মাস শুরু করুন'),
            onPressed: () => _showNewMonthDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _dashboardContent(BuildContext context, MessMonth month) {
    final report = ref.watch(monthlyReportProvider(month.id!));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeMessMonthProvider);
        ref.invalidate(monthlyReportProvider(month.id!));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Month banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'সক্রিয় মাস',
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          const Gap(16),
          report.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => Text('ত্রুটি: $e'),
            data: (r) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'মোট খরচ',
                        value: '${r.totalExpenses.toStringAsFixed(0)} ৳',
                        icon: Icons.shopping_cart_outlined,
                        iconColor: Colors.orange,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: SummaryCard(
                        label: 'মিল রেট',
                        value: '${r.mealRate.toStringAsFixed(2)} ৳',
                        icon: Icons.restaurant,
                        iconColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'মোট মিল',
                        value: r.totalMealUnits.toStringAsFixed(1),
                        icon: Icons.fastfood_outlined,
                        iconColor: Colors.blue,
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: SummaryCard(
                        label: 'সদস্য সংখ্যা',
                        value: '${r.summaries.length}',
                        icon: Icons.people_outline,
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                const SectionHeader(title: 'সদস্য সারসংক্ষেপ'),
                const Gap(8),
                ...r.summaries.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            s.member.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(s.member.name),
                        subtitle: Text(
                            'মিল: ${s.totalMealUnits.toStringAsFixed(1)} | জমা: ${s.totalDeposit.toStringAsFixed(0)} ৳'),
                        trailing: AmountText(
                          amount: s.balance,
                          showSign: true,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const Gap(80),
        ],
      ),
    );
  }

  Future<void> _showNewMonthDialog(BuildContext context) async {
    final now = DateTime.now();
    int selectedYear = now.year;
    int selectedMonth = now.month;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('নতুন মাস শুরু করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: const InputDecoration(labelText: 'বছর'),
                items: List.generate(5, (i) => now.year - 2 + i)
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (v) => setState(() => selectedYear = v!),
              ),
              const Gap(8),
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: const InputDecoration(labelText: 'মাস'),
                items: List.generate(12, (i) => i + 1)
                    .map((m) => DropdownMenuItem(
                        value: m, child: Text(DateFormat.MMMM().format(DateTime(0, m)))))
                    .toList(),
                onChanged: (v) => setState(() => selectedMonth = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(dbHelperProvider);
                final startDate = DateFormat('yyyy-MM-dd')
                    .format(DateTime(selectedYear, selectedMonth, 1));

                // Close current active month
                final active = await db.getActiveMessMonth();
                if (active != null) {
                  await db.closeMessMonth(
                      active.id!,
                      DateFormat('yyyy-MM-dd').format(DateTime.now()));
                }

                await db.insertMessMonth(MessMonth(
                  year: selectedYear,
                  month: selectedMonth,
                  startDate: startDate,
                ));
                ref.invalidate(activeMessMonthProvider);
                ref.invalidate(messMonthListProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('শুরু করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
