import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import '../providers/expense_provider.dart';
import '../providers/mess_month_provider.dart';
import '../providers/db_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMonth = ref.watch(activeMessMonthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: activeMonth.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('ত্রুটি: $e')),
        data: (month) {
          if (month == null) {
            return const EmptyWidget(
              message: 'সক্রিয় কোনো মাস নেই',
              icon: Icons.calendar_today,
            );
          }
          return _ExpenseList(messMonthId: month.id!);
        },
      ),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  final int messMonthId;

  const _ExpenseList({required this.messMonthId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseNotifierProvider(messMonthId));
    final totalAsync = ref.watch(totalExpensesProvider(messMonthId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: CustomScrollView(
        slivers: [
          // Fancy AppBar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradientOrangeYellow,
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.shopping_basket_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'দৈনিক বাজার',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        totalAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (total) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.account_balance_wallet,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'মোট খরচ: ${total.toStringAsFixed(0)} ৳',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // List
          state.when(
            loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('ত্রুটি: $e'))),
            data: (expenses) {
              if (expenses.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyWidget(
                    message: 'কোনো বাজার খরচ নেই\nনিচের বোতাম চাপুন',
                    icon: Icons.shopping_basket_outlined,
                  ),
                );
              }
              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _ExpenseCard(
                      expense: expenses[i],
                      messMonthId: messMonthId,
                      ref: ref,
                    ),
                    childCount: expenses.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientOrangeYellow,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddSheet(context, ref, messMonthId),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
          label: const Text(
            'বাজার যোগ করুন',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;
  final int messMonthId;
  final WidgetRef ref;

  const _ExpenseCard(
      {required this.expense,
      required this.messMonthId,
      required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              onPressed: (_) =>
                  _showEditSheet(context, ref, messMonthId, expense),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'সম্পাদনা',
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
            ),
            SlidableAction(
              onPressed: (_) => ref
                  .read(expenseNotifierProvider(messMonthId).notifier)
                  .deleteExpense(expense.id!),
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'মুছুন',
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16)),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18)),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: AppColors.gradientOrangeYellow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.receipt_long_rounded,
                  color: Colors.white, size: 22),
            ),
            title: Text(
              expense.description,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15),
            ),
            subtitle: Text(
              '${expense.date} • ${expense.addedBy.isNotEmpty ? expense.addedBy : "নাম নেই"}',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.gradientOrangeYellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${expense.amount.toStringAsFixed(0)} ৳',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            children: [
              _ExpenseItemsList(expenseId: expense.id!),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseItemsList extends ConsumerWidget {
  final int expenseId;
  const _ExpenseItemsList({required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(expenseItemsProvider(expenseId));
    return itemsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator(),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              const Divider(),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        '${item.price.toStringAsFixed(0)} ৳',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Show Add Bottom Sheet ────────────────────────────────────────────────────

void _showAddSheet(
    BuildContext context, WidgetRef ref, int messMonthId) {
  _showExpenseSheet(context, ref, messMonthId, null);
}

void _showEditSheet(
    BuildContext context, WidgetRef ref, int messMonthId, Expense existing) {
  _showExpenseSheet(context, ref, messMonthId, existing);
}

void _showExpenseSheet(
    BuildContext context, WidgetRef ref, int messMonthId, Expense? existing) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ExpenseBottomSheet(
      messMonthId: messMonthId,
      existing: existing,
    ),
  );
}

class _ItemEntry {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;

  _ItemEntry()
      : nameCtrl = TextEditingController(),
        priceCtrl = TextEditingController();

  _ItemEntry.withValues(String name, double price)
      : nameCtrl = TextEditingController(text: name),
        priceCtrl = TextEditingController(text: price.toStringAsFixed(0));

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
  }

  double get price => double.tryParse(priceCtrl.text) ?? 0;
  bool get isValid => nameCtrl.text.trim().isNotEmpty && price > 0;
}

class _ExpenseBottomSheet extends ConsumerStatefulWidget {
  final int messMonthId;
  final Expense? existing;

  const _ExpenseBottomSheet({
    required this.messMonthId,
    required this.existing,
  });

  @override
  ConsumerState<_ExpenseBottomSheet> createState() =>
      _ExpenseBottomSheetState();
}

class _ExpenseBottomSheetState extends ConsumerState<_ExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _byCtrl = TextEditingController();
  final List<_ItemEntry> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _byCtrl.text = widget.existing!.addedBy;
      // Load items from DB asynchronously
      _loadExistingItems();
    } else {
      _items.add(_ItemEntry());
    }
  }

  Future<void> _loadExistingItems() async {
    final existingItems =
        await ref.read(dbHelperProvider).getExpenseItems(widget.existing!.id!);
    if (mounted) {
      setState(() {
        _items.clear();
        if (existingItems.isEmpty) {
          _items.add(_ItemEntry.withValues(
              widget.existing!.description, widget.existing!.amount));
        } else {
          for (final item in existingItems) {
            _items.add(_ItemEntry.withValues(item.itemName, item.price));
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _byCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.price);

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F5FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sheet handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.gradientOrangeYellow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_basket_rounded,
                    color: Colors.white, size: 26),
                const SizedBox(width: 12),
                Text(
                  isEdit ? 'বাজার আপডেট' : 'দৈনিক বাজার যোগ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_total.toStringAsFixed(0)} ৳',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Scrollable content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.55,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Who bought
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _byCtrl,
                        decoration: InputDecoration(
                          labelText: 'কে বাজার করেছেন',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientTealBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: Colors.white, size: 18),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Items header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradientOrangeYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'পণ্যের তালিকা',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _items.add(_ItemEntry()));
                          },
                          icon: const Icon(Icons.add_circle_rounded,
                              size: 18),
                          label: const Text('আইটেম যোগ'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Item rows
                    ..._items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            // Item name
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: item.nameCtrl,
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) => v?.trim().isEmpty == true
                                      ? 'নাম দিন'
                                      : null,
                                  decoration: InputDecoration(
                                    hintText: 'পণ্যের নাম',
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade400),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 14),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Price
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: item.priceCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (_) => setState(() {}),
                                  validator: (v) {
                                    if (v?.isEmpty == true) return 'দাম দিন';
                                    if (double.tryParse(v!) == null)
                                      return 'সংখ্যা';
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    hintText: '০ ৳',
                                    hintStyle: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade400),
                                    suffix: const Text('৳',
                                        style: TextStyle(fontSize: 12)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 14),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Remove button
                            if (_items.length > 1)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _items[idx].dispose();
                                    _items.removeAt(idx);
                                  });
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      color: AppColors.red, size: 18),
                                ),
                              )
                            else
                              const SizedBox(width: 36),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Bottom action
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientOrangeYellow,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          widget.existing == null
                              ? 'বাজার সেভ করুন  •  ${_total.toStringAsFixed(0)} ৳'
                              : 'আপডেট করুন  •  ${_total.toStringAsFixed(0)} ৳',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) return;

    final validItems = _items.where((i) => i.isValid).toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কমপক্ষে একটি পণ্য যোগ করুন')),
      );
      return;
    }

    setState(() => _loading = true);

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final total = validItems.fold<double>(0, (s, i) => s + i.price);
    final description = validItems.map((i) => i.nameCtrl.text.trim()).join(', ');

    final notifier =
        ref.read(expenseNotifierProvider(widget.messMonthId).notifier);

    final expenseItems = validItems
        .map((i) => ExpenseItem(
              expenseId: 0,
              itemName: i.nameCtrl.text.trim(),
              price: i.price,
            ))
        .toList();

    if (widget.existing == null) {
      await notifier.addExpenseWithItems(
        Expense(
          amount: total,
          description: description,
          date: today,
          addedBy: _byCtrl.text.trim(),
          messMonthId: widget.messMonthId,
        ),
        expenseItems,
      );
    } else {
      await notifier.updateExpenseWithItems(
        widget.existing!.copyWith(
          amount: total,
          description: description,
          addedBy: _byCtrl.text.trim(),
        ),
        expenseItems,
      );
    }

    setState(() => _loading = false);
    if (mounted) Navigator.pop(context);
  }
}

