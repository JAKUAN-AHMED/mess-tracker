import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/mess_month_provider.dart';
import '../providers/report_provider.dart';
import '../services/report_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(messMonthListProvider);

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
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
    _selectedMonthId = widget.months.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final month =
        widget.months.firstWhere((m) => m.id == _selectedMonthId);
    final report = ref.watch(monthlyReportProvider(_selectedMonthId));

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
      body: CustomScrollView(
      slivers: [
        // AppBar
        SliverAppBar(
          expandedHeight: AppColors.kAppBarHeight,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.blue,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.gradientTealBlue),
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
                        child: const Icon(Icons.bar_chart_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'মাসিক রিপোর্ট',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'বিস্তারিত হিসাব-নিকাশ',
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

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppColors.kCardRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedMonthId,
                decoration: InputDecoration(
                  labelText: 'মাস নির্বাচন করুন',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(10),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientTealBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 18),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: widget.months
                    .map((m) => DropdownMenuItem(
                        value: m.id as int,
                        child: Text(m.label as String)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedMonthId = v!),
              ),
            ),
          ),
        ),

        report.when(
          loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('ত্রুটি: $e'))),
          data: (r) => SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _ReportStatCard(
                        label: 'মোট খরচ',
                        value: '${r.totalExpenses.toStringAsFixed(0)} ৳',
                        icon: Icons.shopping_basket_rounded,
                        gradient: AppColors.gradientOrangeYellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportStatCard(
                        label: 'মিল রেট',
                        value: '${r.mealRate.toStringAsFixed(2)} ৳',
                        icon: Icons.restaurant_rounded,
                        gradient: AppColors.gradientTealBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Member table
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientTealBlue,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text('সদস্য',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                            Expanded(
                                child: Text('মিল',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                            Expanded(
                                child: Text('জমা',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                            Expanded(
                                child: Text('খরচ',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                            Expanded(
                                child: Text('ব্যালেন্স',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                          ],
                        ),
                      ),

                      // Rows
                      ...r.summaries.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        final isPositive = s.balance >= 0;
                        return Container(
                          color: i.isOdd
                              ? Colors.grey.shade50
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: isPositive
                                            ? AppColors.gradientGreenTeal
                                            : AppColors.gradientPinkOrange,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          s.member.name
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        s.member.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  s.totalMealUnits.toStringAsFixed(1),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  s.totalDeposit.toStringAsFixed(0),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  s.mealCost.toStringAsFixed(0),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isPositive
                                        ? AppColors.green
                                            .withValues(alpha: 0.12)
                                        : AppColors.red.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${isPositive ? '+' : ''}${s.balance.toStringAsFixed(0)}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isPositive
                                          ? AppColors.green
                                          : AppColors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Bottom border radius
                      const SizedBox(height: 4),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Export buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPinkOrange,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final file = await ReportService.generatePdf(
                                r, month);
                            await Printing.sharePdf(
                                bytes: await file.readAsBytes(),
                                filename:
                                    file.path.split('/').last);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded),
                          label: const Text('PDF',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientGreenTeal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final file =
                                await ReportService.generateExcel(
                                    r, month);
                            await Share.shareXFiles(
                                [XFile(file.path)]);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          icon: const Icon(Icons.table_chart_rounded),
                          label: const Text('Excel',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ],
    ));
  }
}

class _ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _ReportStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppColors.kCardRadius),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
