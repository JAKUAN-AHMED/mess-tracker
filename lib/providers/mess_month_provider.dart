import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mess_month.dart';
import 'db_provider.dart';

final messMonthListProvider =
    FutureProvider<List<MessMonth>>((ref) async {
  final db = ref.watch(dbHelperProvider);
  return db.getMessMonths();
});

final activeMessMonthProvider =
    FutureProvider<MessMonth?>((ref) async {
  final db = ref.watch(dbHelperProvider);
  return db.getActiveMessMonth();
});

final selectedMonthIdProvider = StateProvider<int?>((ref) => null);

final currentMessMonthProvider = FutureProvider<MessMonth?>((ref) async {
  final selectedId = ref.watch(selectedMonthIdProvider);
  if (selectedId != null) {
    final db = ref.watch(dbHelperProvider);
    return db.getMessMonthById(selectedId);
  }
  return ref.watch(activeMessMonthProvider).value;
});
