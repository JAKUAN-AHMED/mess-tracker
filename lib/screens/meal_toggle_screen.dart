import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../models/meal.dart';
import '../providers/member_provider.dart';
import '../providers/meal_provider.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class MealToggleScreen extends ConsumerStatefulWidget {
  const MealToggleScreen({super.key});

  @override
  ConsumerState<MealToggleScreen> createState() => _MealToggleScreenState();
}

class _MealToggleScreenState extends ConsumerState<MealToggleScreen> {
  DateTime _selectedDate = DateTime.now();

  String get _dateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);
  String get _displayDate => DateFormat('dd MMMM, yyyy').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('মিল চালু/বন্ধ')),
      body: Column(
        children: [
          _datePicker(),
          Expanded(child: _mealGrid()),
        ],
      ),
    );
  }

  Widget _datePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(
                () => _selectedDate = _selectedDate.subtract(const Duration(days: 1))),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _pickDate,
              child: Column(
                children: [
                  Text(
                    _displayDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('EEEE').format(_selectedDate),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedDate.isBefore(DateTime.now())
                ? () => setState(() =>
                    _selectedDate = _selectedDate.add(const Duration(days: 1)))
                : null,
          ),
        ],
      ),
    );
  }

  Widget _mealGrid() {
    final members = ref.watch(activeMemberListProvider);
    final meals = ref.watch(mealNotifierProvider(_dateKey));

    return members.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('ত্রুটি: $e')),
      data: (memberList) {
        if (memberList.isEmpty) {
          return const EmptyWidget(
            message: 'কোনো সক্রিয় সদস্য নেই',
            icon: Icons.people_outline,
          );
        }

        final mealData = meals.when(
          loading: () => <Meal>[],
          error: (_, __) => <Meal>[],
          data: (m) => m,
        );

        // Build a map of memberId -> Meal
        final mealMap = {for (final m in mealData) m.memberId: m};

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: memberList.length,
          itemBuilder: (context, i) {
            final member = memberList[i];
            final meal = mealMap[member.id] ??
                Meal(
                  memberId: member.id!,
                  date: _dateKey,
                  breakfast: false,
                  lunch: true,
                  dinner: true,
                );

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            member.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Text(member.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          '${meal.totalUnits.toStringAsFixed(1)} মিল',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _mealToggle(
                          label: 'সকাল',
                          active: meal.breakfast,
                          icon: Icons.wb_sunny_outlined,
                          color: Colors.orange,
                          onTap: () => _toggleMeal(
                            ref,
                            meal.copyWith(breakfast: !meal.breakfast),
                          ),
                        ),
                        _mealToggle(
                          label: 'দুপুর',
                          active: meal.lunch,
                          icon: Icons.wb_sunny,
                          color: Colors.amber,
                          onTap: () => _toggleMeal(
                            ref,
                            meal.copyWith(lunch: !meal.lunch),
                          ),
                        ),
                        _mealToggle(
                          label: 'রাত',
                          active: meal.dinner,
                          icon: Icons.nightlight_round,
                          color: Colors.indigo,
                          onTap: () => _toggleMeal(
                            ref,
                            meal.copyWith(dinner: !meal.dinner),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _mealToggle({
    required String label,
    required bool active,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? color : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? color : Colors.grey, size: 20),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? color : Colors.grey,
                fontWeight:
                    active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMeal(WidgetRef ref, Meal meal) async {
    await ref
        .read(mealNotifierProvider(_dateKey).notifier)
        .upsertMeal(meal);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
