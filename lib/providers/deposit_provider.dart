import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deposit.dart';
import 'db_provider.dart';

final depositListProvider =
    FutureProvider.family<List<Deposit>, int>((ref, messMonthId) async {
  final db = ref.watch(dbHelperProvider);
  return db.getDeposits(messMonthId);
});

final memberDepositTotalsProvider =
    FutureProvider.family<Map<int, double>, int>((ref, messMonthId) async {
  final db = ref.watch(dbHelperProvider);
  return db.getMemberDepositTotals(messMonthId);
});

class DepositNotifier extends FamilyNotifier<AsyncValue<List<Deposit>>, int> {
  @override
  AsyncValue<List<Deposit>> build(int arg) {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      final deposits = await db.getDeposits(arg);
      state = AsyncValue.data(deposits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addDeposit(Deposit deposit) async {
    final db = ref.read(dbHelperProvider);
    await db.insertDeposit(deposit);
    await _load();
  }

  Future<void> deleteDeposit(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteDeposit(id);
    await _load();
  }

  Future<void> refresh() => _load();
}

final depositNotifierProvider =
    NotifierProviderFamily<DepositNotifier, AsyncValue<List<Deposit>>, int>(
        DepositNotifier.new);
