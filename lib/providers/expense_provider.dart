import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import 'db_provider.dart';

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

final expenseItemsProvider =
    FutureProvider.family<List<ExpenseItem>, int>((ref, expenseId) async {
  final db = ref.watch(dbHelperProvider);
  return db.getExpenseItems(expenseId);
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
    ref.invalidate(totalExpensesProvider(arg));
  }

  Future<void> addExpenseWithItems(
      Expense expense, List<ExpenseItem> items) async {
    final db = ref.read(dbHelperProvider);
    await db.insertExpenseWithItems(expense, items);
    await _load();
    ref.invalidate(totalExpensesProvider(arg));
  }

  Future<void> updateExpense(Expense expense) async {
    final db = ref.read(dbHelperProvider);
    await db.updateExpense(expense);
    await _load();
    ref.invalidate(totalExpensesProvider(arg));
  }

  Future<void> updateExpenseWithItems(
      Expense expense, List<ExpenseItem> items) async {
    final db = ref.read(dbHelperProvider);
    await db.updateExpenseWithItems(expense, items);
    await _load();
    ref.invalidate(totalExpensesProvider(arg));
    if (expense.id != null) {
      ref.invalidate(expenseItemsProvider(expense.id!));
    }
  }

  Future<void> deleteExpense(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteExpense(id);
    await _load();
    ref.invalidate(totalExpensesProvider(arg));
  }

  Future<void> refresh() => _load();
}

final expenseNotifierProvider =
    NotifierProviderFamily<ExpenseNotifier, AsyncValue<List<Expense>>, int>(
        ExpenseNotifier.new);
