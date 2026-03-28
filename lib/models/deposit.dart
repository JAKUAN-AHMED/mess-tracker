class Deposit {
  final String id;
  final String messId;
  final String memberId;
  final double amount;
  final String date;
  final String note;
  final String messMonthId;

  const Deposit({
    required this.id,
    required this.messId,
    required this.memberId,
    required this.amount,
    required this.date,
    this.note = '',
    required this.messMonthId,
  });

  Deposit copyWith({
    String? memberId,
    double? amount,
    String? date,
    String? note,
    String? messMonthId,
  }) =>
      Deposit(
        id: id,
        messId: messId,
        memberId: memberId ?? this.memberId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        note: note ?? this.note,
        messMonthId: messMonthId ?? this.messMonthId,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'mess_id': messId,
        'member_id': memberId,
        'amount': amount,
        'date': date,
        'note': note,
        'mess_month_id': messMonthId,
      };

  factory Deposit.fromMap(Map<String, dynamic> m) => Deposit(
        id: m['_id'] as String,
        messId: m['mess_id'] as String,
        memberId: m['member_id'] as String,
        amount: (m['amount'] as num).toDouble(),
        date: m['date'] as String,
        note: (m['note'] as String?) ?? '',
        messMonthId: m['mess_month_id'] as String,
      );
}
