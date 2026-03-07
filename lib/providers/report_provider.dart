import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';
import 'db_provider.dart';
import 'mess_month_provider.dart';

class MemberSummary {
  final Member member;
  final double totalDeposit;
  final double totalMealUnits;
  final double mealCost;
  final double balance;

  const MemberSummary({
    required this.member,
    required this.totalDeposit,
    required this.totalMealUnits,
    required this.mealCost,
    required this.balance,
  });
}

class MonthlyReport {
  final double totalExpenses;
  final double totalMealUnits;
  final double mealRate;
  final List<MemberSummary> summaries;

  const MonthlyReport({
    required this.totalExpenses,
    required this.totalMealUnits,
    required this.mealRate,
    required this.summaries,
  });
}

final monthlyReportProvider =
    FutureProvider.family<MonthlyReport, int>((ref, messMonthId) async {
  final db = ref.watch(dbHelperProvider);

  final totalExpenses = await db.getTotalExpenses(messMonthId);
  final mealUnits = await db.getMemberMealUnits(messMonthId);
  final depositTotals = await db.getMemberDepositTotals(messMonthId);
  final members = await db.getMembers(activeOnly: false);

  final totalMealUnits =
      mealUnits.values.fold<double>(0.0, (a, b) => a + b);
  final mealRate =
      totalMealUnits > 0 ? totalExpenses / totalMealUnits : 0.0;

  final summaries = members
      .where((m) => m.isActive || mealUnits.containsKey(m.id))
      .map((m) {
    final units = mealUnits[m.id] ?? 0.0;
    final deposit = depositTotals[m.id] ?? 0.0;
    final cost = units * mealRate;
    return MemberSummary(
      member: m,
      totalDeposit: deposit,
      totalMealUnits: units,
      mealCost: cost,
      balance: deposit - cost,
    );
  }).toList();

  return MonthlyReport(
    totalExpenses: totalExpenses,
    totalMealUnits: totalMealUnits,
    mealRate: mealRate,
    summaries: summaries,
  );
});
