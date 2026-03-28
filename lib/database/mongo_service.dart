import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/chat_message.dart';
import '../models/deposit.dart';
import '../models/expense.dart';
import '../models/meal.dart';
import '../models/member.dart';
import '../models/mess.dart';
import '../models/mess_month.dart';

/// MongoDB cloud sync service. All methods are fire-and-forget where possible.
/// If MongoDB is unavailable the app continues in local (SQLite) only mode.
class MongoService {
  Db? _db;
  bool _connected = false;

  bool get isConnected => _connected;

  Future<bool> connect(String uri) async {
    try {
      _db = Db(uri);
      await _db!.open();
      _connected = true;
      debugPrint('[MongoDB] Connected');
      return true;
    } catch (e) {
      debugPrint('[MongoDB] Connection failed: $e');
      _connected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _db?.close();
    } catch (_) {}
    _connected = false;
    _db = null;
  }

  DbCollection? _col(String name) {
    if (!_connected || _db == null) return null;
    return _db!.collection(name);
  }

  // ─── Mess ──────────────────────────────────────────────────────────────────

  Future<void> upsertMess(Mess mess) async {
    try {
      final col = _col('messes');
      if (col == null) return;
      await col.save(_toMongoDoc(mess.toMap()));
    } catch (e) {
      debugPrint('[MongoDB] upsertMess error: $e');
    }
  }

  Future<Mess?> findMessByCode(String code) async {
    try {
      final col = _col('messes');
      if (col == null) return null;
      final doc = await col.findOne(where.eq('code', code));
      if (doc == null) return null;
      return Mess.fromMap(_fromMongoDoc(doc));
    } catch (e) {
      debugPrint('[MongoDB] findMessByCode error: $e');
      return null;
    }
  }

  // ─── Members ───────────────────────────────────────────────────────────────

  Future<void> upsertMember(Member member) async {
    try {
      final col = _col('members');
      if (col == null) return;
      await col.save(_toMongoDoc(member.toMap()));
    } catch (e) {
      debugPrint('[MongoDB] upsertMember error: $e');
    }
  }

  Future<List<Member>> getMembers(String messId) async {
    try {
      final col = _col('members');
      if (col == null) return [];
      final docs = await col.find(where.eq('mess_id', messId)).toList();
      return docs.map((d) => Member.fromMap(_fromMongoDoc(d))).toList();
    } catch (e) {
      debugPrint('[MongoDB] getMembers error: $e');
      return [];
    }
  }

  Future<void> updateMemberActive(String id, bool isActive) async {
    try {
      final col = _col('members');
      if (col == null) return;
      await col.updateOne(
        where.eq('_id', id),
        modify.set('is_active', isActive ? 1 : 0),
      );
    } catch (e) {
      debugPrint('[MongoDB] updateMemberActive error: $e');
    }
  }

  // ─── MessMonths ────────────────────────────────────────────────────────────

  Future<void> upsertMessMonth(MessMonth m) async {
    try {
      final col = _col('mess_months');
      if (col == null) return;
      await col.save(_toMongoDoc(m.toMap()));
    } catch (e) {
      debugPrint('[MongoDB] upsertMessMonth error: $e');
    }
  }

  Future<List<MessMonth>> getMessMonths(String messId) async {
    try {
      final col = _col('mess_months');
      if (col == null) return [];
      final docs =
          await col.find(where.eq('mess_id', messId)).toList();
      return docs.map((d) => MessMonth.fromMap(_fromMongoDoc(d))).toList();
    } catch (e) {
      debugPrint('[MongoDB] getMessMonths error: $e');
      return [];
    }
  }

  Future<void> closeMessMonth(String id, String endDate) async {
    try {
      final col = _col('mess_months');
      if (col == null) return;
      await col.updateOne(
        where.eq('_id', id),
        modify.set('is_active', 0).set('end_date', endDate),
      );
    } catch (e) {
      debugPrint('[MongoDB] closeMessMonth error: $e');
    }
  }

  // ─── Expenses ──────────────────────────────────────────────────────────────

  Future<void> upsertExpense(Expense expense) async {
    try {
      final col = _col('expenses');
      if (col == null) return;
      await col.save(_toMongoDoc(expense.toMap()));
    } catch (e) {
      debugPrint('[MongoDB] upsertExpense error: $e');
    }
  }

  Future<List<Expense>> getExpenses(String messMonthId) async {
    try {
      final col = _col('expenses');
      if (col == null) return [];
      final docs =
          await col.find(where.eq('mess_month_id', messMonthId)).toList();
      return docs.map((d) => Expense.fromMap(_fromMongoDoc(d))).toList();
    } catch (e) {
      debugPrint('[MongoDB] getExpenses error: $e');
      return [];
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final col = _col('expenses');
      if (col == null) return;
      await col.deleteOne(where.eq('_id', id));
    } catch (e) {
      debugPrint('[MongoDB] deleteExpense error: $e');
    }
  }

  // ─── Deposits ──────────────────────────────────────────────────────────────

  Future<void> upsertDeposit(Deposit deposit) async {
    try {
      final col = _col('deposits');
      if (col == null) return;
      await col.save(_toMongoDoc(deposit.toMap()));
    } catch (e) {
      debugPrint('[MongoDB] upsertDeposit error: $e');
    }
  }

  Future<List<Deposit>> getDeposits(String messMonthId) async {
    try {
      final col = _col('deposits');
      if (col == null) return [];
      final docs =
          await col.find(where.eq('mess_month_id', messMonthId)).toList();
      return docs.map((d) => Deposit.fromMap(_fromMongoDoc(d))).toList();
    } catch (e) {
      debugPrint('[MongoDB] getDeposits error: $e');
      return [];
    }
  }

  Future<void> deleteDeposit(String id) async {
    try {
      final col = _col('deposits');
      if (col == null) return;
      await col.deleteOne(where.eq('_id', id));
    } catch (e) {
      debugPrint('[MongoDB] deleteDeposit error: $e');
    }
  }

  // ─── Meals ─────────────────────────────────────────────────────────────────

  Future<void> upsertMeal(Meal meal) async {
    try {
      final col = _col('meals');
      if (col == null) return;
      await col.save(_toMongoDoc(meal.toMap()));
    } catch (e) {
      debugPrint('[MongoDB] upsertMeal error: $e');
    }
  }

  Future<List<Meal>> getMealsForMonth(
      String messId, int year, int month) async {
    try {
      final col = _col('meals');
      if (col == null) return [];
      final prefix =
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
      final docs = await col
          .find(where.eq('mess_id', messId).match('date', '^$prefix'))
          .toList();
      return docs.map((d) => Meal.fromMap(_fromMongoDoc(d))).toList();
    } catch (e) {
      debugPrint('[MongoDB] getMealsForMonth error: $e');
      return [];
    }
  }

  // ─── Chat ──────────────────────────────────────────────────────────────────

  Future<void> upsertChatMessage(ChatMessage msg) async {
    try {
      final col = _col('chat_messages');
      if (col == null) return;
      await col.save(_toMongoDoc(msg.toMap()));
    } catch (e) {
      debugPrint('[MongoDB] upsertChatMessage error: $e');
    }
  }

  Future<void> deleteChatMessage(String id) async {
    try {
      final col = _col('chat_messages');
      if (col == null) return;
      await col.deleteOne(where.eq('_id', id));
    } catch (e) {
      debugPrint('[MongoDB] deleteChatMessage error: $e');
    }
  }

  /// Pull all data for a mess from MongoDB and return as bulk maps for
  /// seeding the local SQLite cache (used on join/first-launch sync).
  Future<MessSyncData> pullMessData(String messId) async {
    try {
      final members = await getMembers(messId);
      final messMonths =
          (await getMessMonths(messId)).where((m) => m.messId == messId).toList();
      return MessSyncData(members: members, messMonths: messMonths);
    } catch (e) {
      debugPrint('[MongoDB] pullMessData error: $e');
      return const MessSyncData(members: [], messMonths: []);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Convert our map (with '_id' as String) to a mongo-compatible document.
  /// mongo_dart expects documents without ObjectId; string _id works fine.
  Map<String, dynamic> _toMongoDoc(Map<String, dynamic> map) {
    return Map<String, dynamic>.from(map);
  }

  /// Normalize MongoDB document back to our internal format.
  Map<String, dynamic> _fromMongoDoc(Map<String, dynamic> doc) {
    final result = Map<String, dynamic>.from(doc);
    // Convert ObjectId _id to String if needed
    if (result['_id'] is ObjectId) {
      result['_id'] = (result['_id'] as ObjectId).toHexString();
    }
    return result;
  }
}

class MessSyncData {
  final List<Member> members;
  final List<MessMonth> messMonths;

  const MessSyncData({
    required this.members,
    required this.messMonths,
  });
}
