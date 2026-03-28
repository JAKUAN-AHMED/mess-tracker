import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat_message.dart';
import '../models/deposit.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import '../models/meal.dart';
import '../models/member.dart';
import '../models/mess.dart';
import '../models/mess_month.dart';

class SqliteService {
  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mess_hisab.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE app_config (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE messes (
        _id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT UNIQUE NOT NULL,
        manager_name TEXT NOT NULL,
        manager_password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE members (
        _id TEXT PRIMARY KEY,
        mess_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        join_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_members_mess ON members(mess_id)');
    await db.execute('''
      CREATE TABLE mess_months (
        _id TEXT PRIMARY KEY,
        mess_id TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        start_date TEXT NOT NULL,
        end_date TEXT
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_mess_months_mess ON mess_months(mess_id)');
    await db.execute('''
      CREATE TABLE expenses (
        _id TEXT PRIMARY KEY,
        mess_id TEXT NOT NULL,
        mess_month_id TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        added_by TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_expenses_month ON expenses(mess_id, mess_month_id)');
    await db.execute('''
      CREATE TABLE expense_items (
        _id TEXT PRIMARY KEY,
        expense_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        price REAL NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_expense_items ON expense_items(expense_id)');
    await db.execute('''
      CREATE TABLE deposits (
        _id TEXT PRIMARY KEY,
        mess_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        mess_month_id TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_deposits_month ON deposits(mess_id, mess_month_id)');
    await db.execute('''
      CREATE TABLE meals (
        _id TEXT PRIMARY KEY,
        mess_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        date TEXT NOT NULL,
        breakfast INTEGER NOT NULL DEFAULT 0,
        lunch INTEGER NOT NULL DEFAULT 1,
        dinner INTEGER NOT NULL DEFAULT 1,
        UNIQUE(mess_id, member_id, date)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_meals_date ON meals(mess_id, date)');
    await db.execute('''
      CREATE TABLE chat_messages (
        _id TEXT PRIMARY KEY,
        mess_id TEXT NOT NULL,
        sender_name TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        chat_type TEXT NOT NULL DEFAULT 'group',
        receiver_name TEXT
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_chat_mess ON chat_messages(mess_id, chat_type, timestamp)');
  }

  // ─── App Config ───────────────────────────────────────────────────────────

  Future<void> setConfig(String key, String value) async {
    final db = await _database;
    await db.insert(
      'app_config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getConfig(String key) async {
    final db = await _database;
    final rows = await db.query(
      'app_config',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  // ─── Mess ─────────────────────────────────────────────────────────────────

  Future<void> insertMess(Mess mess) async {
    final db = await _database;
    await db.insert(
      'messes',
      _toSqliteMap(mess.toMap()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Mess?> getMessById(String id) async {
    final db = await _database;
    final rows = await db.query(
      'messes',
      where: '_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Mess.fromMap(_fromSqliteMap(rows.first));
  }

  Future<Mess?> getMessByCode(String code) async {
    final db = await _database;
    final rows = await db.query(
      'messes',
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Mess.fromMap(_fromSqliteMap(rows.first));
  }

  // ─── Members ──────────────────────────────────────────────────────────────

  Future<void> insertMember(Member member) async {
    final db = await _database;
    await db.insert(
      'members',
      _toSqliteMap(member.toMap()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Member>> getMembers(String messId,
      {bool activeOnly = false}) async {
    final db = await _database;
    final rows = await db.query(
      'members',
      where: activeOnly ? 'mess_id = ? AND is_active = 1' : 'mess_id = ?',
      whereArgs: [messId],
      orderBy: 'name ASC',
    );
    return rows.map((r) => Member.fromMap(_fromSqliteMap(r))).toList();
  }

  Future<Member?> getMemberById(String id) async {
    final db = await _database;
    final rows = await db.query(
      'members',
      where: '_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Member.fromMap(_fromSqliteMap(rows.first));
  }

  Future<void> updateMember(Member member) async {
    final db = await _database;
    final map = _toSqliteMap(member.toMap());
    map.remove('_id');
    await db.update(
      'members',
      map,
      where: '_id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> softDeleteMember(String id) async {
    final db = await _database;
    await db.update(
      'members',
      {'is_active': 0},
      where: '_id = ?',
      whereArgs: [id],
    );
  }

  // ─── MessMonths ───────────────────────────────────────────────────────────

  Future<void> insertMessMonth(MessMonth m) async {
    final db = await _database;
    await db.insert(
      'mess_months',
      _toSqliteMap(m.toMap()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MessMonth>> getMessMonths(String messId) async {
    final db = await _database;
    final rows = await db.query(
      'mess_months',
      where: 'mess_id = ?',
      whereArgs: [messId],
      orderBy: 'year DESC, month DESC',
    );
    return rows.map((r) => MessMonth.fromMap(_fromSqliteMap(r))).toList();
  }

  Future<MessMonth?> getActiveMessMonth(String messId) async {
    final db = await _database;
    final rows = await db.query(
      'mess_months',
      where: 'mess_id = ? AND is_active = 1',
      whereArgs: [messId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MessMonth.fromMap(_fromSqliteMap(rows.first));
  }

  Future<MessMonth?> getMessMonthById(String id) async {
    final db = await _database;
    final rows = await db.query(
      'mess_months',
      where: '_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MessMonth.fromMap(_fromSqliteMap(rows.first));
  }

  Future<void> closeMessMonth(String id, String endDate) async {
    final db = await _database;
    await db.update(
      'mess_months',
      {'is_active': 0, 'end_date': endDate},
      where: '_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMessMonth(MessMonth m) async {
    final db = await _database;
    final map = _toSqliteMap(m.toMap());
    map.remove('_id');
    await db.update(
      'mess_months',
      map,
      where: '_id = ?',
      whereArgs: [m.id],
    );
  }

  // ─── Expenses ─────────────────────────────────────────────────────────────

  Future<void> insertExpense(Expense expense) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.insert(
        'expenses',
        {
          '_id': expense.id,
          'mess_id': expense.messId,
          'mess_month_id': expense.messMonthId,
          'amount': expense.amount,
          'description': expense.description,
          'date': expense.date,
          'added_by': expense.addedBy,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final item in expense.items) {
        await txn.insert(
          'expense_items',
          {
            '_id': '${expense.id}_${item.itemName}',
            'expense_id': expense.id,
            'item_name': item.itemName,
            'price': item.price,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Expense>> getExpenses(String messMonthId) async {
    final db = await _database;
    final rows = await db.query(
      'expenses',
      where: 'mess_month_id = ?',
      whereArgs: [messMonthId],
      orderBy: 'date DESC',
    );
    final expenses = <Expense>[];
    for (final row in rows) {
      final items = await _getExpenseItems(db, row['_id'] as String);
      expenses.add(Expense(
        id: row['_id'] as String,
        messId: row['mess_id'] as String,
        messMonthId: row['mess_month_id'] as String,
        amount: (row['amount'] as num).toDouble(),
        description: row['description'] as String,
        date: row['date'] as String,
        addedBy: row['added_by'] as String,
        items: items,
      ));
    }
    return expenses;
  }

  Future<List<ExpenseItem>> _getExpenseItems(Database db, String expenseId) async {
    final rows = await db.query(
      'expense_items',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    return rows
        .map((r) => ExpenseItem(
              itemName: r['item_name'] as String,
              price: (r['price'] as num).toDouble(),
            ))
        .toList();
  }

  Future<double> getTotalExpenses(String messMonthId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE mess_month_id = ?',
      [messMonthId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> deleteExpense(String id) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete('expense_items',
          where: 'expense_id = ?', whereArgs: [id]);
      await txn.delete('expenses', where: '_id = ?', whereArgs: [id]);
    });
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.update(
        'expenses',
        {
          'amount': expense.amount,
          'description': expense.description,
          'date': expense.date,
          'added_by': expense.addedBy,
          'mess_month_id': expense.messMonthId,
        },
        where: '_id = ?',
        whereArgs: [expense.id],
      );
      await txn.delete('expense_items',
          where: 'expense_id = ?', whereArgs: [expense.id]);
      for (final item in expense.items) {
        await txn.insert(
          'expense_items',
          {
            '_id': '${expense.id}_${item.itemName}',
            'expense_id': expense.id,
            'item_name': item.itemName,
            'price': item.price,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // ─── Deposits ─────────────────────────────────────────────────────────────

  Future<void> insertDeposit(Deposit deposit) async {
    final db = await _database;
    await db.insert(
      'deposits',
      _toSqliteMap(deposit.toMap()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Deposit>> getDeposits(String messMonthId) async {
    final db = await _database;
    final rows = await db.query(
      'deposits',
      where: 'mess_month_id = ?',
      whereArgs: [messMonthId],
      orderBy: 'date DESC',
    );
    return rows.map((r) => Deposit.fromMap(_fromSqliteMap(r))).toList();
  }

  Future<Map<String, double>> getMemberDepositTotals(
      String messMonthId) async {
    final db = await _database;
    final result = await db.rawQuery(
      'SELECT member_id, SUM(amount) as total FROM deposits WHERE mess_month_id = ? GROUP BY member_id',
      [messMonthId],
    );
    return {
      for (final row in result)
        row['member_id'] as String: (row['total'] as num).toDouble()
    };
  }

  Future<void> deleteDeposit(String id) async {
    final db = await _database;
    await db.delete('deposits', where: '_id = ?', whereArgs: [id]);
  }

  // ─── Meals ────────────────────────────────────────────────────────────────

  Future<void> upsertMeal(Meal meal) async {
    final db = await _database;
    await db.insert(
      'meals',
      _toSqliteMap(meal.toMap()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Meal>> getMealsForDate(String messId, String date) async {
    final db = await _database;
    final rows = await db.query(
      'meals',
      where: 'mess_id = ? AND date = ?',
      whereArgs: [messId, date],
    );
    return rows.map((r) => Meal.fromMap(_fromSqliteMap(r))).toList();
  }

  Future<List<Meal>> getMealsForMonth(
      String messId, int year, int month) async {
    final db = await _database;
    final prefix = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    final rows = await db.query(
      'meals',
      where: 'mess_id = ? AND date LIKE ?',
      whereArgs: [messId, '$prefix%'],
    );
    return rows.map((r) => Meal.fromMap(_fromSqliteMap(r))).toList();
  }

  Future<Map<String, double>> getMemberMealUnits(
      String messId, int year, int month) async {
    final meals = await getMealsForMonth(messId, year, month);
    final totals = <String, double>{};
    for (final meal in meals) {
      totals[meal.memberId] =
          (totals[meal.memberId] ?? 0.0) + meal.totalUnits;
    }
    return totals;
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────

  Future<void> insertChatMessage(ChatMessage msg) async {
    final db = await _database;
    await db.insert(
      'chat_messages',
      _toSqliteMap(msg.toMap()),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ChatMessage>> getGroupMessages(String messId,
      {int limit = 100}) async {
    final db = await _database;
    final rows = await db.query(
      'chat_messages',
      where: 'mess_id = ? AND chat_type = ?',
      whereArgs: [messId, 'group'],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return rows.map((r) => ChatMessage.fromMap(_fromSqliteMap(r))).toList();
  }

  Future<List<ChatMessage>> getPrivateMessages(
      String messId, String user1, String user2,
      {int limit = 100}) async {
    final db = await _database;
    final rows = await db.query(
      'chat_messages',
      where:
          "mess_id = ? AND chat_type = 'private' AND ((sender_name = ? AND receiver_name = ?) OR (sender_name = ? AND receiver_name = ?))",
      whereArgs: [messId, user1, user2, user2, user1],
      orderBy: 'timestamp ASC',
      limit: limit,
    );
    return rows.map((r) => ChatMessage.fromMap(_fromSqliteMap(r))).toList();
  }

  Future<ChatMessage?> getLastGroupMessage(String messId) async {
    final db = await _database;
    final rows = await db.query(
      'chat_messages',
      where: "mess_id = ? AND chat_type = 'group'",
      whereArgs: [messId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ChatMessage.fromMap(_fromSqliteMap(rows.first));
  }

  Future<ChatMessage?> getLastPrivateMessage(
      String messId, String user1, String user2) async {
    final db = await _database;
    final rows = await db.query(
      'chat_messages',
      where:
          "mess_id = ? AND chat_type = 'private' AND ((sender_name = ? AND receiver_name = ?) OR (sender_name = ? AND receiver_name = ?))",
      whereArgs: [messId, user1, user2, user2, user1],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ChatMessage.fromMap(_fromSqliteMap(rows.first));
  }

  Future<void> deleteChatMessage(String id) async {
    final db = await _database;
    await db.delete('chat_messages', where: '_id = ?', whereArgs: [id]);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// SQLite stores rows as Map<String, Object?> but Mongo uses '_id'.
  /// No conversion needed; both use '_id' string key.
  Map<String, dynamic> _toSqliteMap(Map<String, dynamic> doc) {
    // Remove null values (sqflite handles them as NULL)
    return Map.fromEntries(
        doc.entries.where((e) => e.value != null || _isNullableColumn(e.key)));
  }

  bool _isNullableColumn(String key) =>
      key == 'phone' ||
      key == 'email' ||
      key == 'end_date' ||
      key == 'receiver_name';

  Map<String, dynamic> _fromSqliteMap(Map<String, Object?> row) {
    return Map<String, dynamic>.from(row);
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
