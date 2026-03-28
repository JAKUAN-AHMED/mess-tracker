import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/deposit.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import '../models/meal.dart';
import '../models/member.dart';
import '../models/mess.dart';
import '../models/mess_month.dart';
import 'mongo_service.dart';
import 'sqlite_service.dart';

/// Local-first database service.
/// All reads/writes go to SQLite immediately for speed.
/// MongoDB is synced asynchronously in the background.
class DatabaseService {
  final SqliteService _sqlite = SqliteService();
  final MongoService _mongo = MongoService();
  final _uuid = const Uuid();

  // Chat stream notifier (broadcast, triggered on every chat write/delete)
  final _chatNotifier = StreamController<void>.broadcast();

  bool get isMongoConnected => _mongo.isConnected;

  // ─── MongoDB Connection ────────────────────────────────────────────────────

  Future<bool> connectMongo(String uri) async {
    final connected = await _mongo.connect(uri);
    if (connected) {
      await _sqlite.setConfig('mongodb_uri', uri);
    }
    return connected;
  }

  Future<String?> getSavedMongoUri() => _sqlite.getConfig('mongodb_uri');

  Future<bool> reconnectMongo() async {
    final uri = await getSavedMongoUri();
    if (uri == null) return false;
    return connectMongo(uri);
  }

  // ─── Current Mess ID ──────────────────────────────────────────────────────

  Future<String> _messId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('current_mess_id');
    if (id == null) throw Exception('No mess configured');
    return id;
  }

  // ─── App Config ───────────────────────────────────────────────────────────

  Future<void> setConfig(String key, String value) =>
      _sqlite.setConfig(key, value);

  Future<String?> getConfig(String key) => _sqlite.getConfig(key);

  Future<bool> isSetupDone() async {
    final v = await _sqlite.getConfig('setup_done');
    return v == 'true';
  }

  // ─── Mess ─────────────────────────────────────────────────────────────────

  Future<void> createMess(Mess mess) async {
    await _sqlite.insertMess(mess);
    _syncAsync(() => _mongo.upsertMess(mess));
  }

  Future<Mess?> getLocalMess(String id) => _sqlite.getMessById(id);

  /// Find a mess by code — checks local first, then MongoDB.
  Future<Mess?> findMessByCode(String code) async {
    // Try local
    final local = await _sqlite.getMessByCode(code);
    if (local != null) return local;
    // Try remote
    final remote = await _mongo.findMessByCode(code);
    if (remote != null) {
      // Cache locally
      await _sqlite.insertMess(remote);
    }
    return remote;
  }

  // ─── Members ──────────────────────────────────────────────────────────────

  Future<String> insertMember(Member member) async {
    await _sqlite.insertMember(member);
    _syncAsync(() => _mongo.upsertMember(member));
    return member.id;
  }

  Future<List<Member>> getMembers({bool activeOnly = false}) async {
    final messId = await _messId();
    return _sqlite.getMembers(messId, activeOnly: activeOnly);
  }

  Future<Member?> getMemberById(String id) => _sqlite.getMemberById(id);

  Future<void> updateMember(Member member) async {
    await _sqlite.updateMember(member);
    _syncAsync(() => _mongo.upsertMember(member));
  }

  Future<void> deactivateMember(String id) async {
    await _sqlite.softDeleteMember(id);
    _syncAsync(() => _mongo.updateMemberActive(id, false));
  }

  // ─── MessMonths ───────────────────────────────────────────────────────────

  Future<String> insertMessMonth(MessMonth m) async {
    await _sqlite.insertMessMonth(m);
    _syncAsync(() => _mongo.upsertMessMonth(m));
    return m.id;
  }

  Future<List<MessMonth>> getMessMonths() async {
    final messId = await _messId();
    return _sqlite.getMessMonths(messId);
  }

  Future<MessMonth?> getActiveMessMonth() async {
    final messId = await _messId();
    return _sqlite.getActiveMessMonth(messId);
  }

  Future<MessMonth?> getMessMonthById(String id) =>
      _sqlite.getMessMonthById(id);

  Future<void> closeMessMonth(String id, String endDate) async {
    await _sqlite.closeMessMonth(id, endDate);
    _syncAsync(() => _mongo.closeMessMonth(id, endDate));
  }

  Future<void> updateMessMonth(MessMonth m) async {
    await _sqlite.updateMessMonth(m);
    _syncAsync(() => _mongo.upsertMessMonth(m));
  }

  // ─── Expenses ─────────────────────────────────────────────────────────────

  Future<String> insertExpense(Expense expense) async {
    await _sqlite.insertExpense(expense);
    _syncAsync(() => _mongo.upsertExpense(expense));
    return expense.id;
  }

  Future<String> insertExpenseWithItems(
      Expense expense, List<ExpenseItem> items) async {
    final full = Expense(
      id: expense.id,
      messId: expense.messId,
      messMonthId: expense.messMonthId,
      amount: expense.amount,
      description: expense.description,
      date: expense.date,
      addedBy: expense.addedBy,
      items: items,
    );
    await _sqlite.insertExpense(full);
    _syncAsync(() => _mongo.upsertExpense(full));
    return full.id;
  }

  Future<List<Expense>> getExpenses(String messMonthId) =>
      _sqlite.getExpenses(messMonthId);

  Future<double> getTotalExpenses(String messMonthId) =>
      _sqlite.getTotalExpenses(messMonthId);

  Future<void> updateExpense(Expense expense) async {
    await _sqlite.updateExpense(expense);
    _syncAsync(() => _mongo.upsertExpense(expense));
  }

  Future<void> updateExpenseWithItems(
      Expense expense, List<ExpenseItem> items) async {
    final full = expense.copyWith(items: items);
    await _sqlite.updateExpense(full);
    _syncAsync(() => _mongo.upsertExpense(full));
  }

  Future<void> deleteExpense(String id) async {
    await _sqlite.deleteExpense(id);
    _syncAsync(() => _mongo.deleteExpense(id));
  }

  // ─── Deposits ─────────────────────────────────────────────────────────────

  Future<String> insertDeposit(Deposit deposit) async {
    await _sqlite.insertDeposit(deposit);
    _syncAsync(() => _mongo.upsertDeposit(deposit));
    return deposit.id;
  }

  Future<List<Deposit>> getDeposits(String messMonthId) =>
      _sqlite.getDeposits(messMonthId);

  Future<Map<String, double>> getMemberDepositTotals(String messMonthId) =>
      _sqlite.getMemberDepositTotals(messMonthId);

  Future<void> deleteDeposit(String id) async {
    await _sqlite.deleteDeposit(id);
    _syncAsync(() => _mongo.deleteDeposit(id));
  }

  // ─── Meals ────────────────────────────────────────────────────────────────

  Future<void> upsertMeal(Meal meal) async {
    await _sqlite.upsertMeal(meal);
    _syncAsync(() => _mongo.upsertMeal(meal));
  }

  Future<List<Meal>> getMealsForDate(String date) async {
    final messId = await _messId();
    return _sqlite.getMealsForDate(messId, date);
  }

  Future<List<Meal>> getMealsForMonth(MessMonth messMonth) async {
    final messId = await _messId();
    return _sqlite.getMealsForMonth(messId, messMonth.year, messMonth.month);
  }

  Future<Map<String, double>> getMemberMealUnits(MessMonth messMonth) async {
    final messId = await _messId();
    return _sqlite.getMemberMealUnits(messId, messMonth.year, messMonth.month);
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────

  Future<String> insertChatMessage(ChatMessage msg) async {
    await _sqlite.insertChatMessage(msg);
    _chatNotifier.add(null);
    _syncAsync(() => _mongo.upsertChatMessage(msg));
    return msg.id;
  }

  Future<List<ChatMessage>> getGroupMessages({int limit = 100}) async {
    final messId = await _messId();
    return _sqlite.getGroupMessages(messId, limit: limit);
  }

  Future<List<ChatMessage>> getPrivateMessages(String user1, String user2,
      {int limit = 100}) async {
    final messId = await _messId();
    return _sqlite.getPrivateMessages(messId, user1, user2, limit: limit);
  }

  Future<ChatMessage?> getLastGroupMessage() async {
    final messId = await _messId();
    return _sqlite.getLastGroupMessage(messId);
  }

  Future<ChatMessage?> getLastPrivateMessage(
      String user1, String user2) async {
    final messId = await _messId();
    return _sqlite.getLastPrivateMessage(messId, user1, user2);
  }

  Future<void> deleteChatMessage(String id) async {
    await _sqlite.deleteChatMessage(id);
    _chatNotifier.add(null);
    _syncAsync(() => _mongo.deleteChatMessage(id));
  }

  Stream<List<ChatMessage>> watchGroupMessages() async* {
    yield await getGroupMessages();
    await for (final _ in _chatNotifier.stream) {
      yield await getGroupMessages();
    }
  }

  Stream<List<ChatMessage>> watchPrivateMessages(
      String user1, String user2) async* {
    yield await getPrivateMessages(user1, user2);
    await for (final _ in _chatNotifier.stream) {
      yield await getPrivateMessages(user1, user2);
    }
  }

  // ─── ID Generation ────────────────────────────────────────────────────────

  String generateId() => _uuid.v4();

  // ─── Sync Helpers ─────────────────────────────────────────────────────────

  /// Pull all existing mess data from MongoDB into local SQLite.
  /// Called after a member joins a mess on a new device.
  Future<void> syncFromMongo(String messId) async {
    if (!_mongo.isConnected) return;
    try {
      final data = await _mongo.pullMessData(messId);
      for (final member in data.members) {
        await _sqlite.insertMember(member);
      }
      for (final month in data.messMonths) {
        await _sqlite.insertMessMonth(month);
      }
      debugPrint('[Sync] Pulled ${data.members.length} members, ${data.messMonths.length} months');
    } catch (e) {
      debugPrint('[Sync] syncFromMongo error: $e');
    }
  }

  void _syncAsync(Future<void> Function() task) {
    task().catchError((e) {
      debugPrint('[Sync] Background sync error: $e');
    });
  }

  Future<void> dispose() async {
    await _chatNotifier.close();
    await _mongo.disconnect();
    await _sqlite.close();
  }
}
