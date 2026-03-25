import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import '../models/deposit.dart';
import '../models/meal.dart';
import '../models/mess_month.dart';
import '../models/chat_message.dart';
import '../models/app_config.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  static Isar? _isar;

  static Future<Isar> get _db async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        MemberSchema,
        ExpenseSchema,
        DepositSchema,
        MealSchema,
        MessMonthSchema,
        ChatMessageSchema,
        AppConfigSchema,
      ],
      directory: dir.path,
    );
    return _isar!;
  }

  // ─── App Config ──────────────────────────────────────────────────────────────

  Future<void> setConfig(String key, String value) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final existing = await isar.appConfigs.filter().keyEqualTo(key).findFirst();
      final config = AppConfig(key: key, value: value);
      if (existing != null) config.id = existing.id;
      await isar.appConfigs.put(config);
    });
  }

  Future<String?> getConfig(String key) async {
    final isar = await _db;
    final config = await isar.appConfigs.filter().keyEqualTo(key).findFirst();
    return config?.value;
  }

  Future<bool> isSetupDone() async {
    final code = await getConfig('mess_code');
    return code != null && code.isNotEmpty;
  }

  // ─── MessMonth ───────────────────────────────────────────────────────────────

  Future<int> insertMessMonth(MessMonth m) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.messMonths.put(m));
    return m.id;
  }

  Future<List<MessMonth>> getMessMonths() async {
    final isar = await _db;
    return isar.messMonths.where().sortByYearDesc().thenByMonthDesc().findAll();
  }

  Future<MessMonth?> getActiveMessMonth() async {
    final isar = await _db;
    return isar.messMonths.filter().isActiveEqualTo(true).findFirst();
  }

  Future<MessMonth?> getMessMonthById(int id) async {
    final isar = await _db;
    return isar.messMonths.get(id);
  }

  Future<void> closeMessMonth(int id, String endDate) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final month = await isar.messMonths.get(id);
      if (month != null) {
        month.isActive = false;
        month.endDate = endDate;
        await isar.messMonths.put(month);
      }
    });
  }

  // ─── Members ─────────────────────────────────────────────────────────────────

  Future<int> insertMember(Member m) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.members.put(m));
    return m.id;
  }

  Future<List<Member>> getMembers({bool activeOnly = false}) async {
    final isar = await _db;
    final all = await isar.members.where().sortByName().findAll();
    if (activeOnly) return all.where((m) => m.isActive).toList();
    return all;
  }

  Future<void> updateMember(Member m) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.members.put(m));
  }

  Future<void> deleteMember(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      final member = await isar.members.get(id);
      if (member != null) {
        member.isActive = false;
        await isar.members.put(member);
      }
    });
  }

  // ─── Expenses ────────────────────────────────────────────────────────────────

  Future<int> insertExpense(Expense e) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.expenses.put(e));
    return e.id;
  }

  Future<int> insertExpenseWithItems(Expense e, List<ExpenseItem> items) async {
    final isar = await _db;
    e.items = items;
    await isar.writeTxn(() async => isar.expenses.put(e));
    return e.id;
  }

  Future<List<Expense>> getExpenses(int messMonthId) async {
    final isar = await _db;
    return isar.expenses
        .filter()
        .messMonthIdEqualTo(messMonthId)
        .sortByDateDesc()
        .findAll();
  }

  Future<List<ExpenseItem>> getExpenseItems(int expenseId) async {
    final isar = await _db;
    final expense = await isar.expenses.get(expenseId);
    return expense?.items ?? [];
  }

  Future<double> getTotalExpenses(int messMonthId) async {
    final expenses = await getExpenses(messMonthId);
    return expenses.fold<double>(0, (sum, e) => sum + e.amount);
  }

  Future<void> updateExpense(Expense e) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.expenses.put(e));
  }

  Future<void> updateExpenseWithItems(Expense e, List<ExpenseItem> items) async {
    final isar = await _db;
    e.items = items;
    await isar.writeTxn(() async => isar.expenses.put(e));
  }

  Future<void> deleteExpense(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.expenses.delete(id));
  }

  // ─── Deposits ────────────────────────────────────────────────────────────────

  Future<int> insertDeposit(Deposit d) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.deposits.put(d));
    return d.id;
  }

  Future<List<Deposit>> getDeposits(int messMonthId) async {
    final isar = await _db;
    return isar.deposits
        .filter()
        .messMonthIdEqualTo(messMonthId)
        .sortByDateDesc()
        .findAll();
  }

  Future<Map<int, double>> getMemberDepositTotals(int messMonthId) async {
    final deposits = await getDeposits(messMonthId);
    final Map<int, double> totals = {};
    for (final d in deposits) {
      totals[d.memberId] = (totals[d.memberId] ?? 0) + d.amount;
    }
    return totals;
  }

  Future<void> deleteDeposit(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.deposits.delete(id));
  }

  // ─── Meals ───────────────────────────────────────────────────────────────────

  Future<void> upsertMeal(Meal meal) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      // Find existing meal with same memberId + date
      final existing = await isar.meals
          .filter()
          .memberIdEqualTo(meal.memberId)
          .dateEqualTo(meal.date)
          .findFirst();
      if (existing != null) {
        meal.id = existing.id;
      }
      await isar.meals.put(meal);
    });
  }

  Future<List<Meal>> getMealsForDate(String date) async {
    final isar = await _db;
    return isar.meals.filter().dateEqualTo(date).findAll();
  }

  Future<List<Meal>> getMealsForMonth(int messMonthId) async {
    final month = await getMessMonthById(messMonthId);
    if (month == null) return [];
    final prefix =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final isar = await _db;
    return isar.meals.filter().dateStartsWith(prefix).findAll();
  }

  Future<Map<int, double>> getMemberMealUnits(int messMonthId) async {
    final meals = await getMealsForMonth(messMonthId);
    final Map<int, double> totals = {};
    for (final meal in meals) {
      totals[meal.memberId] =
          (totals[meal.memberId] ?? 0) + meal.totalUnits;
    }
    return totals;
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────────

  Future<int> insertChatMessage(ChatMessage msg) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.chatMessages.put(msg));
    return msg.id;
  }

  Future<List<ChatMessage>> getGroupMessages({int limit = 100}) async {
    final isar = await _db;
    final msgs = await isar.chatMessages
        .filter()
        .chatTypeEqualTo('group')
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
    return msgs.reversed.toList();
  }

  Future<List<ChatMessage>> getPrivateMessages(
      String user1, String user2,
      {int limit = 100}) async {
    final isar = await _db;
    final all = await isar.chatMessages
        .filter()
        .chatTypeEqualTo('private')
        .sortByTimestampDesc()
        .findAll();
    final filtered = all
        .where((m) =>
            (m.senderName == user1 && (m.receiverName ?? '') == user2) ||
            (m.senderName == user2 && (m.receiverName ?? '') == user1))
        .take(limit)
        .toList();
    return filtered.reversed.toList();
  }

  Future<ChatMessage?> getLastGroupMessage() async {
    final isar = await _db;
    final msgs = await isar.chatMessages
        .filter()
        .chatTypeEqualTo('group')
        .sortByTimestampDesc()
        .limit(1)
        .findAll();
    return msgs.isEmpty ? null : msgs.first;
  }

  Future<ChatMessage?> getLastPrivateMessage(
      String user1, String user2) async {
    final all = await getPrivateMessages(user1, user2, limit: 1);
    return all.isEmpty ? null : all.last;
  }

  Future<void> deleteChatMessage(int id) async {
    final isar = await _db;
    await isar.writeTxn(() async => isar.chatMessages.delete(id));
  }

  // ─── Reactive Streams for Chat ────────────────────────────────────────────────

  Stream<List<ChatMessage>> watchGroupMessages() async* {
    final isar = await _db;
    await for (final _ in isar.chatMessages.watchLazy(fireImmediately: true)) {
      final msgs = await isar.chatMessages
          .filter()
          .chatTypeEqualTo('group')
          .sortByTimestampDesc()
          .limit(100)
          .findAll();
      yield msgs.reversed.toList();
    }
  }

  Stream<List<ChatMessage>> watchPrivateMessages(
      String user1, String user2) async* {
    final isar = await _db;
    await for (final _ in isar.chatMessages.watchLazy(fireImmediately: true)) {
      final all = await isar.chatMessages
          .filter()
          .chatTypeEqualTo('private')
          .sortByTimestampDesc()
          .findAll();
      final filtered = all
          .where((m) =>
              (m.senderName == user1 && (m.receiverName ?? '') == user2) ||
              (m.senderName == user2 && (m.receiverName ?? '') == user1))
          .take(100)
          .toList();
      yield filtered.reversed.toList();
    }
  }

  // ─── Database path (for backup) ───────────────────────────────────────────────

  static Future<String> getDatabaseDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
