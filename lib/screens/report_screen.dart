import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/mess_month_provider.dart';
import '../providers/report_provider.dart';
import '../services/report_service.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(messMonthListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('মাসিক রিপোর্ট')),
      body: months.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (monthList) {
          if (monthList.isEmpty) {
            return const EmptyWidget(
              message: 'কোনো মাসের তথ্য নেই',
              icon: Icons.bar_chart,
            );
          }
          return _MonthSelector(months: monthList);
        },
      ),
    );
  }
}

class _MonthSelector extends ConsumerStatefulWidget {
  final List months;

  const _MonthSelector({required this.months});

  @override
  ConsumerState<_MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends ConsumerState<_MonthSelector> {
  late int _selectedMonthId;

  @override
  void initState() {
    super.initState();
    _selectedMonthId = widget.months.first.id!;
  }

  @override
  Widget build(BuildContext context) {
    final month = widget.months.firstWhere((m) => m.id == _selectedMonthId);
    final report = ref.watch(monthlyReportProvider(_selectedMonthId));

    return Column(
      children: [
        // Month selector
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: DropdownButtonFormField<int>(
            value: _selectedMonthId,
            decoration: const InputDecoration(
              labelText: 'মাস নির্বাচন করুন',
              border: OutlineInputBorder(),
              filled: true,
            ),
            items: widget.months
                .map((m) => DropdownMenuItem(
                    value: m.id as int, child: Text(m.label as String)))
                .toList(),
            onChanged: (v) => setState(() => _selectedMonthId = v!),
          ),
        ),
        Expanded(
          child: report.when(
            loading: () => const LoadingWidget(),
            error: (e, _) => Center(child: Text('ত্রুটি: $e')),
            data: (r) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'মোট খরচ',
                        value: '${r.totalExpenses.toStringAsFixed(0)} ৳',
                        icon: Icons.shopping_cart,
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
                const Gap(16),
                const SectionHeader(title: 'সদস্য হিসাব'),
                const Gap(8),
                // Table header
                _tableHeader(context),
                const Divider(height: 1),
                ...r.summaries.map((s) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(s.member.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ),
                              Expanded(
                                child: Text(
                                  s.totalMealUnits.toStringAsFixed(1),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  s.totalDeposit.toStringAsFixed(0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  s.mealCost.toStringAsFixed(0),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  (s.balance >= 0 ? '+' : '') +
                                      s.balance.toStringAsFixed(0),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: s.balance >= 0
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    )),
                const Gap(20),
                // Export buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('PDF'),
                        onPressed: () async {
                          final file =
                              await ReportService.generatePdf(r, month);
                          await Printing.sharePdf(
                              bytes: await file.readAsBytes(),
                              filename: file.path.split('/').last);
                        },
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.table_chart),
                        label: const Text('Excel'),
                        onPressed: () async {
                          final file =
                              await ReportService.generateExcel(r, month);
                          await Share.shareXFiles([XFile(file.path)]);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('সদস্য',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold))),
          Expanded(
              child: Text('মিল',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold))),
          Expanded(
              child: Text('জমা',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold))),
          Expanded(
              child: Text('খরচ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold))),
          Expanded(
              child: Text('ব্যালেন্স',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
