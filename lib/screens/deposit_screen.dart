import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/deposit.dart';
import '../providers/deposit_provider.dart';
import '../providers/member_provider.dart';
import '../providers/mess_month_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart' hide ErrorWidget;

class DepositScreen extends ConsumerWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMonth = ref.watch(activeMessMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
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
          return _DepositList(messMonthId: month.id);
        },
      ),
    );
  }
}

class _DepositList extends ConsumerWidget {
  final int messMonthId;

  const _DepositList({required this.messMonthId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(depositNotifierProvider(messMonthId));
    final members = ref.watch(activeMemberListProvider);

    return Scaffold(
      backgroundColor: AppColors.kScaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: AppColors.kAppBarHeight,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.green,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppColors.gradientGreenTeal),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 26),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'জমার তালিকা',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'সদস্যদের জমা অর্থ',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          state.when(
            loading: () =>
                const SliverFillRemaining(child: LoadingWidget()),
            error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('ত্রুটি: $e'))),
            data: (deposits) {
              if (deposits.isEmpty) {
                return const SliverFillRemaining(
                  child: EmptyWidget(
                    message: 'কোনো জমা নেই\nনিচের বোতামে চাপুন',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                );
              }
              final memberMap = {
                for (final m in (members.value ?? [])) m.id: m
              };
              return SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final d = deposits[i];
                      final member = memberMap[d.memberId];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (_) => ref
                                    .read(depositNotifierProvider(messMonthId)
                                        .notifier)
                                    .deleteDeposit(d.id),
                                backgroundColor: AppColors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_rounded,
                                label: 'মুছুন',
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.gradientGreenTeal,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (member?.name ?? '?')
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member?.name ?? 'অজানা',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${d.date}${d.note.isNotEmpty ? '  •  ${d.note}' : ''}',
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
                                      gradient: AppColors.gradientGreenTeal,
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${d.amount.toStringAsFixed(0)} ৳',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: deposits.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.gradientGreenTeal,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () =>
              _showDepositSheet(context, ref, members.value ?? []),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'জমা যোগ করুন',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Future<void> _showDepositSheet(
      BuildContext context, WidgetRef ref, List members) async {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রথমে সদস্য যোগ করুন')),
      );
      return;
    }

    int? selectedMemberId = members.first.id;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final bottomPad = MediaQuery.of(ctx).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.only(bottom: bottomPad),
            decoration: const BoxDecoration(
              color: AppColors.kSheetBg,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientGreenTeal,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.account_balance_wallet_rounded,
                            color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'জমা যোগ করুন',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Member dropdown
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.grey.shade100),
                            ),
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedMemberId,
                              decoration: InputDecoration(
                                labelText: 'সদস্য *',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: AppColors.gradientGreenTeal,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.person_rounded,
                                      color: Colors.white, size: 18),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              items: members
                                  .map((m) => DropdownMenuItem(
                                      value: m.id as int,
                                      child: Text(m.name as String)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedMemberId = v),
                              validator: (v) =>
                                  v == null ? 'সদস্য নির্বাচন করুন' : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.grey.shade100),
                            ),
                            child: TextFormField(
                              controller: amountCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) {
                                if (v?.isEmpty == true)
                                  return 'পরিমাণ দিন';
                                if (double.tryParse(v!) == null)
                                  return 'বৈধ সংখ্যা';
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'পরিমাণ (টাকা) *',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient:
                                        AppColors.gradientOrangeYellow,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.payments_rounded,
                                      color: Colors.white,
                                      size: 18),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.grey.shade100),
                            ),
                            child: TextFormField(
                              controller: noteCtrl,
                              decoration: InputDecoration(
                                labelText: 'মন্তব্য',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient:
                                        AppColors.gradientTealBlue,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.note_rounded,
                                      color: Colors.white, size: 18),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientGreenTeal,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!
                                      .validate()) return;
                                  final notifier = ref.read(
                                      depositNotifierProvider(messMonthId)
                                          .notifier);
                                  final today =
                                      DateFormat('yyyy-MM-dd')
                                          .format(DateTime.now());
                                  await notifier.addDeposit(Deposit(
                                    memberId: selectedMemberId!,
                                    amount:
                                        double.parse(amountCtrl.text),
                                    date: today,
                                    note: noteCtrl.text.trim(),
                                    messMonthId: messMonthId,
                                  ));
                                  if (ctx.mounted) Navigator.pop(ctx);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'জমা যোগ করুন',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    amountCtrl.dispose();
    noteCtrl.dispose();
  }
}
