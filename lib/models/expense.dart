import 'package:isar/isar.dart';
import 'expense_item.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;
  double amount = 0.0;
  String description = '';
  String date = '';
  String addedBy = '';
  int messMonthId = 0;

  // Items are embedded in the expense document (set separately)
  List<ExpenseItem> items = [];

  Expense({
    double amount = 0.0,
    String description = '',
    String date = '',
    String addedBy = '',
    int messMonthId = 0,
  })  : amount = amount,
        description = description,
        date = date,
        addedBy = addedBy,
        messMonthId = messMonthId;

  Expense copyWith({
    double? amount,
    String? description,
    String? date,
    String? addedBy,
    int? messMonthId,
  }) {
    final e = Expense(
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      addedBy: addedBy ?? this.addedBy,
      messMonthId: messMonthId ?? this.messMonthId,
    );
    e.id = id;
    e.items = items;
    return e;
  }
}
