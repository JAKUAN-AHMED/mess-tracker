import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mess_hisab_tracker/database/db_helper.dart';
import 'package:mess_hisab_tracker/models/member.dart';
import 'package:mess_hisab_tracker/models/mess_month.dart';
import 'package:mess_hisab_tracker/models/expense.dart';
import 'package:mess_hisab_tracker/models/deposit.dart';
import 'package:mess_hisab_tracker/models/meal.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final db = DBHelper();

  group('Member CRUD', () {
    test('insert and retrieve member', () async {
      final id = await db.insertMember(const Member(
        name: 'টেস্ট ইউজার',
        phone: '01700000000',
        joinDate: '2025-03-01',
      ));
      expect(id, greaterThan(0));

      final members = await db.getMembers();
      expect(members.any((m) => m.name == 'টেস্ট ইউজার'), isTrue);
    });

    test('update member', () async {
      final members = await db.getMembers();
      final m = members.firstWhere((m) => m.name == 'টেস্ট ইউজার');
      await db.updateMember(m.copyWith(name: 'আপডেটেড ইউজার'));
      final updated = await db.getMembers();
      expect(updated.any((m) => m.name == 'আপডেটেড ইউজার'), isTrue);
    });

    test('deactivate member', () async {
      final members = await db.getMembers();
      final m = members.firstWhere((m) => m.name == 'আপডেটেড ইউজার');
      await db.deleteMember(m.id!);
      final active = await db.getMembers(activeOnly: true);
      expect(active.any((x) => x.id == m.id), isFalse);
    });
  });

  group('MessMonth CRUD', () {
    late int monthId;

    test('insert mess month', () async {
      monthId = await db.insertMessMonth(const MessMonth(
        year: 2025,
        month: 3,
        startDate: '2025-03-01',
      ));
      expect(monthId, greaterThan(0));
    });

    test('get active mess month', () async {
      final active = await db.getActiveMessMonth();
      expect(active, isNotNull);
      expect(active!.year, 2025);
    });
  });

  group('Expense CRUD', () {
    late int monthId;

    setUpAll(() async {
      final month = await db.getActiveMessMonth();
      monthId = month!.id!;
    });

    test('insert expense', () async {
      final id = await db.insertExpense(Expense(
        amount: 500.0,
        description: 'বাজার',
        date: '2025-03-05',
        addedBy: 'করিম',
        messMonthId: monthId,
      ));
      expect(id, greaterThan(0));
    });

    test('get total expenses', () async {
      final total = await db.getTotalExpenses(monthId);
      expect(total, greaterThanOrEqualTo(500.0));
    });

    test('delete expense', () async {
      final expenses = await db.getExpenses(monthId);
      expect(expenses, isNotEmpty);
      await db.deleteExpense(expenses.first.id!);
      final after = await db.getExpenses(monthId);
      expect(after.length, expenses.length - 1);
    });
  });

  group('Meal upsert', () {
    late int memberId;

    setUpAll(() async {
      final id = await db.insertMember(const Member(
        name: 'মিল টেস্ট',
        joinDate: '2025-03-01',
      ));
      memberId = id;
    });

    test('insert meal', () async {
      await db.upsertMeal(Meal(
        memberId: memberId,
        date: '2025-03-05',
        breakfast: true,
        lunch: true,
        dinner: false,
      ));
      final meals = await db.getMealsForDate('2025-03-05');
      expect(meals.any((m) => m.memberId == memberId), isTrue);
    });

    test('update meal (upsert)', () async {
      await db.upsertMeal(Meal(
        memberId: memberId,
        date: '2025-03-05',
        breakfast: false,
        lunch: true,
        dinner: true,
      ));
      final meals = await db.getMealsForDate('2025-03-05');
      final m = meals.firstWhere((m) => m.memberId == memberId);
      expect(m.breakfast, isFalse);
      expect(m.dinner, isTrue);
    });
  });

  group('Deposit CRUD', () {
    late int monthId;
    late int memberId;

    setUpAll(() async {
      final month = await db.getActiveMessMonth();
      monthId = month!.id!;
      final members = await db.getMembers();
      memberId = members.first.id!;
    });

    test('insert deposit', () async {
      final id = await db.insertDeposit(Deposit(
        memberId: memberId,
        amount: 1000.0,
        date: '2025-03-05',
        note: 'প্রথম জমা',
        messMonthId: monthId,
      ));
      expect(id, greaterThan(0));
    });

    test('get member deposit totals', () async {
      final totals = await db.getMemberDepositTotals(monthId);
      expect(totals[memberId], greaterThanOrEqualTo(1000.0));
    });
  });
}
