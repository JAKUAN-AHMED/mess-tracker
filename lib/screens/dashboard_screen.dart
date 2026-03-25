import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../providers/mess_month_provider.dart';
import '../providers/report_provider.dart';
import '../providers/db_provider.dart';
import '../providers/auth_provider.dart';
import '../models/mess_month.dart';
import '../theme/app_theme.dart';
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
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
      body: activeMonth.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (month) {
          if (month == null) {
            return _noActiveMonth(context);
          }
          return _dashboardContent(context, month, auth);
        },
      ),
    );
  }

  Widget _noActiveMonth(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.gradientBackground),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPurplePink,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  size: 50, color: Colors.white),
            ),
            const Gap(20),
            const Text(
              'কোনো সক্রিয় মাস নেই',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const Gap(8),
            Text(
              'নতুন মাস শুরু করুন',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Gap(24),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradientPurplePink,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showNewMonthDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'নতুন মাস শুরু করুন',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardContent(
      BuildContext context, MessMonth month, AuthState auth) {
    final report = ref.watch(monthlyReportProvider(month.id));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeMessMonthProvider);
        ref.invalidate(monthlyReportProvider(month.id));
      },
      child: CustomScrollView(
        slivers: [
          // Gradient App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientPurplePink,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.restaurant_menu_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auth.messName ?? 'মেস হিসাব',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'স্বাগতম, ${auth.userName ?? "ব্যবহারকারী"}!',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.85),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (auth.status == AuthStatus.manager)
                              GestureDetector(
                                onTap: () => _showNewMonthDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        width: 1),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.add_rounded,
                                          color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'নতুন মাস',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                month.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '● সক্রিয়',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          report.when(
            loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('ত্রুটি: $e'))),
            data: (r) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'মোট খরচ',
                          value: '${r.totalExpenses.toStringAsFixed(0)} ৳',
                          icon: Icons.shopping_basket_rounded,
                          gradient: AppColors.gradientOrangeYellow,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'মিল রেট',
                          value: '${r.mealRate.toStringAsFixed(2)} ৳',
                          icon: Icons.restaurant_rounded,
                          gradient: AppColors.gradientTealBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'মোট মিল',
                          value: r.totalMealUnits.toStringAsFixed(1),
                          icon: Icons.fastfood_rounded,
                          gradient: AppColors.gradientGreenTeal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'সদস্য সংখ্যা',
                          value: '${r.summaries.length} জন',
                          icon: Icons.people_rounded,
                          gradient: AppColors.gradientPurplePink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Members header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.people_rounded,
                            size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'সদস্য হিসাব',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Member cards
                  ...r.summaries.map((s) {
                    final isPositive = s.balance >= 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
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
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: isPositive
                                    ? AppColors.gradientGreenTeal
                                    : AppColors.gradientPinkOrange,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  s.member.name
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
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
                                    s.member.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'মিল: ${s.totalMealUnits.toStringAsFixed(1)}  |  জমা: ${s.totalDeposit.toStringAsFixed(0)} ৳',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: isPositive
                                    ? AppColors.gradientGreenTeal
                                    : AppColors.gradientPinkOrange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${isPositive ? '+' : ''}${s.balance.toStringAsFixed(0)} ৳',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ]),
              ),
            ),
          ),
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
        builder: (ctx, setState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPurplePink,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                const Text(
                  'নতুন মাস শুরু করুন',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  value: selectedYear,
                  decoration: InputDecoration(
                    labelText: 'বছর',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  items: List.generate(5, (i) => now.year - 2 + i)
                      .map((y) =>
                          DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (v) => setState(() => selectedYear = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedMonth,
                  decoration: InputDecoration(
                    labelText: 'মাস',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  items: List.generate(12, (i) => i + 1)
                      .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(
                              DateFormat.MMMM().format(DateTime(0, m)))))
                      .toList(),
                  onChanged: (v) => setState(() => selectedMonth = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('বাতিল'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPurplePink,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final db = ref.read(dbHelperProvider);
                            final startDate = DateFormat('yyyy-MM-dd').format(
                                DateTime(selectedYear, selectedMonth, 1));
                            final active = await db.getActiveMessMonth();
                            if (active != null) {
                              await db.closeMessMonth(
                                  active.id,
                                  DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()));
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('শুরু করুন',
                              style:
                                  TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _StatCard({
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
        borderRadius: BorderRadius.circular(18),
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
