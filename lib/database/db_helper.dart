import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/member.dart';
import '../models/expense.dart';
import '../models/expense_item.dart';
import '../models/deposit.dart';
import '../models/meal.dart';
import '../models/mess_month.dart';
import '../models/chat_message.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mess_hisab.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mess_months (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        start_date TEXT NOT NULL,
        end_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        join_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        added_by TEXT NOT NULL,
        mess_month_id INTEGER NOT NULL,
        FOREIGN KEY (mess_month_id) REFERENCES mess_months(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expense_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE deposits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        mess_month_id INTEGER NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members(id),
        FOREIGN KEY (mess_month_id) REFERENCES mess_months(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        breakfast INTEGER NOT NULL DEFAULT 0,
        lunch INTEGER NOT NULL DEFAULT 1,
        dinner INTEGER NOT NULL DEFAULT 1,
        UNIQUE(member_id, date),
        FOREIGN KEY (member_id) REFERENCES members(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_config (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_name TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        chat_type TEXT NOT NULL DEFAULT 'group',
        receiver_name TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE members ADD COLUMN email TEXT');
      } catch (_) {}
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expense_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          expense_id INTEGER NOT NULL,
          item_name TEXT NOT NULL,
          price REAL NOT NULL,
          FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS app_config (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chat_messages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sender_name TEXT NOT NULL,
          message TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          chat_type TEXT NOT NULL DEFAULT 'group',
          receiver_name TEXT NOT NULL DEFAULT ''
        )
      ''');
    }
  }

  // ─── App Config ──────────────────────────────────────────────────────────────

  Future<void> setConfig(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getConfig(String key) async {
    final db = await database;
    final rows = await db.query('app_config', where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<bool> isSetupDone() async {
    final code = await getConfig('mess_code');
    return code != null && code.isNotEmpty;
  }

  // ─── MessMonth ───────────────────────────────────────────────────────────────

  Future<int> insertMessMonth(MessMonth m) async {
    final db = await database;
    return db.insert('mess_months', m.toMap());
  }

  Future<List<MessMonth>> getMessMonths() async {
    final db = await database;
    final rows = await db.query('mess_months', orderBy: 'year DESC, month DESC');
    return rows.map(MessMonth.fromMap).toList();
  }

  Future<MessMonth?> getActiveMessMonth() async {
    final db = await database;
    final rows = await db.query(
      'mess_months',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    return rows.isEmpty ? null : MessMonth.fromMap(rows.first);
  }

  Future<void> closeMessMonth(int id, String endDate) async {
    final db = await database;
    await db.update(
      'mess_months',
      {'is_active': 0, 'end_date': endDate},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Members ─────────────────────────────────────────────────────────────────

  Future<int> insertMember(Member m) async {
    final db = await database;
    return db.insert('members', m.toMap());
  }

  Future<List<Member>> getMembers({bool activeOnly = false}) async {
    final db = await database;
    final rows = await db.query(
      'members',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'name ASC',
    );
    return rows.map(Member.fromMap).toList();
  }

  Future<void> updateMember(Member m) async {
    final db = await database;
    await db.update('members', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
  }

  Future<void> deleteMember(int id) async {
    final db = await database;
    await db.update(
      'members',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Expenses ────────────────────────────────────────────────────────────────

  Future<int> insertExpense(Expense e) async {
    final db = await database;
    return db.insert('expenses', e.toMap());
  }

  Future<int> insertExpenseWithItems(Expense e, List<ExpenseItem> items) async {
    final db = await database;
    int expenseId = 0;
    await db.transaction((txn) async {
      expenseId = await txn.insert('expenses', e.toMap());
      for (final item in items) {
        await txn.insert('expense_items', {
          'expense_id': expenseId,
          'item_name': item.itemName,
          'price': item.price,
        });
      }
    });
    return expenseId;
  }

  Future<List<Expense>> getExpenses(int messMonthId) async {
    final db = await database;
    final rows = await db.query(
      'expenses',
      where: 'mess_month_id = ?',
      whereArgs: [messMonthId],
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<ExpenseItem>> getExpenseItems(int expenseId) async {
    final db = await database;
    final rows = await db.query(
      'expense_items',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    return rows.map(ExpenseItem.fromMap).toList();
  }

  Future<double> getTotalExpenses(int messMonthId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE mess_month_id = ?',
      [messMonthId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> updateExpense(Expense e) async {
    final db = await database;
    await db.update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> updateExpenseWithItems(
      Expense e, List<ExpenseItem> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('expenses', e.toMap(),
          where: 'id = ?', whereArgs: [e.id]);
      await txn.delete('expense_items',
          where: 'expense_id = ?', whereArgs: [e.id]);
      for (final item in items) {
        await txn.insert('expense_items', {
          'expense_id': e.id,
          'item_name': item.itemName,
          'price': item.price,
        });
      }
    });
  }

  Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expense_items', where: 'expense_id = ?', whereArgs: [id]);
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Deposits ────────────────────────────────────────────────────────────────

  Future<int> insertDeposit(Deposit d) async {
    final db = await database;
    return db.insert('deposits', d.toMap());
  }

  Future<List<Deposit>> getDeposits(int messMonthId) async {
    final db = await database;
    final rows = await db.query(
      'deposits',
      where: 'mess_month_id = ?',
      whereArgs: [messMonthId],
      orderBy: 'date DESC',
    );
    return rows.map(Deposit.fromMap).toList();
  }

  Future<Map<int, double>> getMemberDepositTotals(int messMonthId) async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT member_id, SUM(amount) as total FROM deposits WHERE mess_month_id = ? GROUP BY member_id',
      [messMonthId],
    );
    return {
      for (final r in rows)
        r['member_id'] as int: (r['total'] as num).toDouble()
    };
  }

  Future<void> deleteDeposit(int id) async {
    final db = await database;
    await db.delete('deposits', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Meals ───────────────────────────────────────────────────────────────────

  Future<void> upsertMeal(Meal meal) async {
    final db = await database;
    await db.insert(
      'meals',
      meal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Meal>> getMealsForDate(String date) async {
    final db = await database;
    final rows = await db.query(
      'meals',
      where: 'date = ?',
      whereArgs: [date],
    );
    return rows.map(Meal.fromMap).toList();
  }

  Future<List<Meal>> getMealsForMonth(int messMonthId) async {
    final db = await database;
    final month = await getMessMonthById(messMonthId);
    if (month == null) return [];
    final prefix =
        '${month.year}-${month.month.toString().padLeft(2, '0')}';
    final rows = await db.query(
      'meals',
      where: "date LIKE ?",
      whereArgs: ['$prefix%'],
    );
    return rows.map(Meal.fromMap).toList();
  }

  Future<Map<int, double>> getMemberMealUnits(int messMonthId) async {
    final meals = await getMealsForMonth(messMonthId);
    final Map<int, double> totals = {};
    for (final meal in meals) {
      totals[meal.memberId] = (totals[meal.memberId] ?? 0) + meal.totalUnits;
    }
    return totals;
  }

  Future<MessMonth?> getMessMonthById(int id) async {
    final db = await database;
    final rows =
        await db.query('mess_months', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : MessMonth.fromMap(rows.first);
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────────

  Future<int> insertChatMessage(ChatMessage msg) async {
    final db = await database;
    return db.insert('chat_messages', msg.toMap());
  }

  Future<List<ChatMessage>> getGroupMessages({int limit = 100}) async {
    final db = await database;
    final rows = await db.query(
      'chat_messages',
      where: "chat_type = 'group'",
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(ChatMessage.fromMap).toList().reversed.toList();
  }

  Future<List<ChatMessage>> getPrivateMessages(
      String user1, String user2, {int limit = 100}) async {
    final db = await database;
    final rows = await db.query(
      'chat_messages',
      where: "chat_type = 'private' AND ((sender_name = ? AND receiver_name = ?) OR (sender_name = ? AND receiver_name = ?))",
      whereArgs: [user1, user2, user2, user1],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(ChatMessage.fromMap).toList().reversed.toList();
  }

  Future<ChatMessage?> getLastPrivateMessage(String user1, String user2) async {
    final db = await database;
    final rows = await db.query(
      'chat_messages',
      where: "chat_type = 'private' AND ((sender_name = ? AND receiver_name = ?) OR (sender_name = ? AND receiver_name = ?))",
      whereArgs: [user1, user2, user2, user1],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : ChatMessage.fromMap(rows.first);
  }

  Future<ChatMessage?> getLastGroupMessage() async {
    final db = await database;
    final rows = await db.query(
      'chat_messages',
      where: "chat_type = 'group'",
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : ChatMessage.fromMap(rows.first);
  }

  Future<void> deleteChatMessage(int id) async {
    final db = await database;
    await db.delete('chat_messages', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Close ───────────────────────────────────────────────────────────────────

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
