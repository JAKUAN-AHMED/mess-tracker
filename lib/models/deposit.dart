import 'package:isar/isar.dart';

part 'deposit.g.dart';

@collection
class Deposit {
  Id id = Isar.autoIncrement;
  int memberId = 0;
  double amount = 0.0;
  String date = '';
  String note = '';
  int messMonthId = 0;

  Deposit({
    int memberId = 0,
    double amount = 0.0,
    String date = '',
    String note = '',
    int messMonthId = 0,
  })  : memberId = memberId,
        amount = amount,
        date = date,
        note = note,
        messMonthId = messMonthId;

  Deposit copyWith({
    int? memberId,
    double? amount,
    String? date,
    String? note,
    int? messMonthId,
  }) {
    final d = Deposit(
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      messMonthId: messMonthId ?? this.messMonthId,
    );
    d.id = id;
    return d;
  }
}
