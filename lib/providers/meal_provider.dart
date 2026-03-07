import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import 'db_provider.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final mealsForDateProvider =
    FutureProvider.family<List<Meal>, String>((ref, date) async {
  final db = ref.watch(dbHelperProvider);
  return db.getMealsForDate(date);
});

final memberMealUnitsProvider =
    FutureProvider.family<Map<int, double>, int>((ref, messMonthId) async {
  final db = ref.watch(dbHelperProvider);
  return db.getMemberMealUnits(messMonthId);
});

class MealNotifier extends FamilyNotifier<AsyncValue<List<Meal>>, String> {
  @override
  AsyncValue<List<Meal>> build(String arg) {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      final meals = await db.getMealsForDate(arg);
      state = AsyncValue.data(meals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> upsertMeal(Meal meal) async {
    final db = ref.read(dbHelperProvider);
    await db.upsertMeal(meal);
    await _load();
  }

  Future<void> refresh() => _load();
}

final mealNotifierProvider =
    NotifierProviderFamily<MealNotifier, AsyncValue<List<Meal>>, String>(
        MealNotifier.new);
