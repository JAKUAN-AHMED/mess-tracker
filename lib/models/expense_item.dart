class ExpenseItem {
  final int? id;
  final int expenseId;
  final String itemName;
  final double price;

  const ExpenseItem({
    this.id,
    required this.expenseId,
    required this.itemName,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'expense_id': expenseId,
        'item_name': itemName,
        'price': price,
      };

  factory ExpenseItem.fromMap(Map<String, dynamic> map) => ExpenseItem(
        id: map['id'] as int?,
        expenseId: map['expense_id'] as int,
        itemName: map['item_name'] as String,
        price: (map['price'] as num).toDouble(),
      );
}
