class Deposit {
  final int? id;
  final int memberId;
  final double amount;
  final String date;
  final String note;
  final int messMonthId;

  const Deposit({
    this.id,
    required this.memberId,
    required this.amount,
    required this.date,
    this.note = '',
    required this.messMonthId,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'member_id': memberId,
        'amount': amount,
        'date': date,
        'note': note,
        'mess_month_id': messMonthId,
      };

  factory Deposit.fromMap(Map<String, dynamic> map) => Deposit(
        id: map['id'] as int?,
        memberId: map['member_id'] as int,
        amount: (map['amount'] as num).toDouble(),
        date: map['date'] as String,
        note: map['note'] as String? ?? '',
        messMonthId: map['mess_month_id'] as int,
      );

  Deposit copyWith({
    int? id,
    int? memberId,
    double? amount,
    String? date,
    String? note,
    int? messMonthId,
  }) =>
      Deposit(
        id: id ?? this.id,
        memberId: memberId ?? this.memberId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        note: note ?? this.note,
        messMonthId: messMonthId ?? this.messMonthId,
      );
}
