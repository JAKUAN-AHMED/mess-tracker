import 'expense_item.dart';

class Expense {
  final String id;
  final String messId;
  final String messMonthId;
  final double amount;
  final String description;
  final String date;
  final String addedBy;
  final List<ExpenseItem> items;

  const Expense({
    required this.id,
    required this.messId,
    required this.messMonthId,
    required this.amount,
    required this.description,
    required this.date,
    required this.addedBy,
    this.items = const [],
  });

  Expense copyWith({
    double? amount,
    String? description,
    String? date,
    String? addedBy,
    String? messMonthId,
    List<ExpenseItem>? items,
  }) =>
      Expense(
        id: id,
        messId: messId,
        messMonthId: messMonthId ?? this.messMonthId,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        date: date ?? this.date,
        addedBy: addedBy ?? this.addedBy,
        items: items ?? this.items,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'mess_id': messId,
        'mess_month_id': messMonthId,
        'amount': amount,
        'description': description,
        'date': date,
        'added_by': addedBy,
        'items': items.map((i) => i.toMap()).toList(),
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['_id'] as String,
        messId: m['mess_id'] as String,
        messMonthId: m['mess_month_id'] as String,
        amount: (m['amount'] as num).toDouble(),
        description: m['description'] as String,
        date: m['date'] as String,
        addedBy: m['added_by'] as String,
        items: (m['items'] as List<dynamic>? ?? [])
            .map((i) => ExpenseItem.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList(),
      );
}
