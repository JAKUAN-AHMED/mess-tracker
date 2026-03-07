import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import 'db_provider.dart';
import 'mess_month_provider.dart';

final expenseListProvider =
    FutureProvider.family<List<Expense>, int>((ref, messMonthId) async {
  final db = ref.watch(dbHelperProvider);
  return db.getExpenses(messMonthId);
});

final totalExpensesProvider =
    FutureProvider.family<double, int>((ref, messMonthId) async {
  final db = ref.watch(dbHelperProvider);
  return db.getTotalExpenses(messMonthId);
});

class ExpenseNotifier extends FamilyNotifier<AsyncValue<List<Expense>>, int> {
  @override
  AsyncValue<List<Expense>> build(int arg) {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      final expenses = await db.getExpenses(arg);
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addExpense(Expense expense) async {
    final db = ref.read(dbHelperProvider);
    await db.insertExpense(expense);
    await _load();
  }

  Future<void> updateExpense(Expense expense) async {
    final db = ref.read(dbHelperProvider);
    await db.updateExpense(expense);
    await _load();
  }

  Future<void> deleteExpense(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteExpense(id);
    await _load();
  }

  Future<void> refresh() => _load();
}

final expenseNotifierProvider =
    NotifierProviderFamily<ExpenseNotifier, AsyncValue<List<Expense>>, int>(
        ExpenseNotifier.new);
