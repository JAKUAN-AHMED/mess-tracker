class Expense {
  final int? id;
  final double amount;
  final String description;
  final String date;
  final String addedBy;
  final int messMonthId;

  const Expense({
    this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.addedBy,
    required this.messMonthId,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'amount': amount,
        'description': description,
        'date': date,
        'added_by': addedBy,
        'mess_month_id': messMonthId,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as int?,
        amount: (map['amount'] as num).toDouble(),
        description: map['description'] as String,
        date: map['date'] as String,
        addedBy: map['added_by'] as String,
        messMonthId: map['mess_month_id'] as int,
      );

  Expense copyWith({
    int? id,
    double? amount,
    String? description,
    String? date,
    String? addedBy,
    int? messMonthId,
  }) =>
      Expense(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        date: date ?? this.date,
        addedBy: addedBy ?? this.addedBy,
        messMonthId: messMonthId ?? this.messMonthId,
      );
}
