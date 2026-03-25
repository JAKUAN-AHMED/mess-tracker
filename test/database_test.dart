// Database integration tests require the Flutter engine and Isar native libraries.
// These tests are designed to run as Flutter integration tests, not unit tests.
// Run with: flutter test integration_test/ (after moving to integration_test folder)

import 'package:flutter_test/flutter_test.dart';
import 'package:mess_hisab_tracker/models/member.dart';
import 'package:mess_hisab_tracker/models/mess_month.dart';
import 'package:mess_hisab_tracker/models/expense.dart';
import 'package:mess_hisab_tracker/models/deposit.dart';
import 'package:mess_hisab_tracker/models/meal.dart';

void main() {
  group('Model construction', () {
    test('Member constructs with required fields', () {
      final member = Member(name: 'টেস্ট ইউজার', joinDate: '2025-03-01');
      expect(member.name, 'টেস্ট ইউজার');
      expect(member.joinDate, '2025-03-01');
      expect(member.isActive, true);
    });

    test('Member copyWith preserves id', () {
      final member = Member(name: 'করিম', joinDate: '2025-03-01')..id = 5;
      final updated = member.copyWith(name: 'আপডেটেড');
      expect(updated.id, 5);
      expect(updated.name, 'আপডেটেড');
    });

    test('MessMonth constructs correctly', () {
      final month = MessMonth(year: 2025, month: 3, startDate: '2025-03-01');
      expect(month.year, 2025);
      expect(month.month, 3);
      expect(month.isActive, true);
      expect(month.label, 'মার্চ 2025');
    });

    test('Expense constructs correctly', () {
      final expense = Expense(
        amount: 500.0,
        description: 'বাজার',
        date: '2025-03-05',
        addedBy: 'করিম',
        messMonthId: 1,
      );
      expect(expense.amount, 500.0);
      expect(expense.description, 'বাজার');
    });

    test('Deposit constructs correctly', () {
      final deposit = Deposit(
        memberId: 1,
        amount: 1000.0,
        date: '2025-03-05',
        note: 'প্রথম জমা',
        messMonthId: 1,
      );
      expect(deposit.amount, 1000.0);
      expect(deposit.note, 'প্রথম জমা');
    });

    test('Meal totalUnits calculation', () {
      final meal = Meal(
        memberId: 1,
        date: '2025-03-05',
        breakfast: true,
        lunch: true,
        dinner: false,
      );
      expect(meal.totalUnits, 1.5);
    });

    test('Meal copyWith preserves id', () {
      final meal = Meal(memberId: 1, date: '2025-03-05')..id = 10;
      final updated = meal.copyWith(breakfast: true);
      expect(updated.id, 10);
      expect(updated.breakfast, true);
    });
  });
}
