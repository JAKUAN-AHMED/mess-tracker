import 'package:isar/isar.dart';

part 'expense_item.g.dart';

@embedded
class ExpenseItem {
  String itemName = '';
  double price = 0.0;

  // Legacy field - not stored in Isar (parent expense owns the relationship)
  @ignore
  int expenseId = 0;

  ExpenseItem({
    int expenseId = 0,
    String itemName = '',
    double price = 0.0,
  })  : itemName = itemName,
        price = price,
        expenseId = expenseId;
}
