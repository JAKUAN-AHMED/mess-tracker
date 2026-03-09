import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/meal.dart';
import '../providers/member_provider.dart';
import '../providers/meal_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class MealToggleScreen extends ConsumerStatefulWidget {
  const MealToggleScreen({super.key});

  @override
  ConsumerState<MealToggleScreen> createState() => _MealToggleScreenState();
}

class _MealToggleScreenState extends ConsumerState<MealToggleScreen> {
  DateTime _selectedDate = DateTime.now();

  String get _dateKey =>
      DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.accent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.gradientOrangeYellow),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.restaurant_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'মিল ট্র্যাকার',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Date picker row
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    color: Colors.white, size: 28),
                                onPressed: () => setState(() =>
                                    _selectedDate = _selectedDate
                                        .subtract(const Duration(days: 1))),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickDate,
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat('dd MMMM, yyyy')
                                            .format(_selectedDate),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        DateFormat('EEEE')
                                            .format(_selectedDate),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right,
                                    color: Colors.white, size: 28),
                                onPressed:
                                    _selectedDate.isBefore(DateTime.now())
                                        ? () => setState(() =>
                                            _selectedDate = _selectedDate.add(
                                                const Duration(days: 1)))
                                        : null,
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

          _MealGrid(
              dateKey: _dateKey,
              selectedDate: _selectedDate,
              onToggle: (meal) async {
                await ref
                    .read(mealNotifierProvider(_dateKey).notifier)
                    .upsertMeal(meal);
              }),
        ],
      ),
    );
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

class _MealGrid extends ConsumerWidget {
  final String dateKey;
  final DateTime selectedDate;
  final Future<void> Function(Meal) onToggle;

  const _MealGrid({
    required this.dateKey,
    required this.selectedDate,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(activeMemberListProvider);
    final meals = ref.watch(mealNotifierProvider(dateKey));

    return members.when(
      loading: () =>
          const SliverFillRemaining(child: LoadingWidget()),
      error: (e, _) =>
          SliverFillRemaining(child: Center(child: Text('ত্রুটি: $e'))),
      data: (memberList) {
        if (memberList.isEmpty) {
          return const SliverFillRemaining(
            child: EmptyWidget(
              message: 'কোনো সক্রিয় সদস্য নেই',
              icon: Icons.people_outline,
            ),
          );
        }

        final mealData = meals.when(
          loading: () => <Meal>[],
          error: (_, __) => <Meal>[],
          data: (m) => m,
        );
        final mealMap = {for (final m in mealData) m.memberId: m};

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final member = memberList[i];
                final meal = mealMap[member.id] ??
                    Meal(
                      memberId: member.id!,
                      date: dateKey,
                      breakfast: false,
                      lunch: true,
                      dinner: true,
                    );

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientOrangeYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  member.name
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                member.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${meal.totalUnits.toStringAsFixed(1)} মিল',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MealChip(
                                label: 'সকাল',
                                icon: Icons.wb_twilight_rounded,
                                active: meal.breakfast,
                                activeColor: const Color(0xFFFF6B35),
                                onTap: () => onToggle(
                                    meal.copyWith(
                                        breakfast: !meal.breakfast)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MealChip(
                                label: 'দুপুর',
                                icon: Icons.wb_sunny_rounded,
                                active: meal.lunch,
                                activeColor: const Color(0xFFF59E0B),
                                onTap: () => onToggle(
                                    meal.copyWith(lunch: !meal.lunch)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MealChip(
                                label: 'রাত',
                                icon: Icons.nights_stay_rounded,
                                active: meal.dinner,
                                activeColor: const Color(0xFF6C3CE1),
                                onTap: () => onToggle(
                                    meal.copyWith(dinner: !meal.dinner)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: memberList.length,
            ),
          ),
        );
      },
    );
  }
}

class _MealChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _MealChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding:
            const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              active ? activeColor.withOpacity(0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? activeColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: active ? 22 : 18,
              color: active ? activeColor : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: active ? activeColor : Colors.grey.shade500,
                fontWeight:
                    active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
