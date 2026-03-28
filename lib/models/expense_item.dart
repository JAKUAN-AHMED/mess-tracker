class ExpenseItem {
  final String itemName;
  final double price;

  const ExpenseItem({
    required this.itemName,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'item_name': itemName,
        'price': price,
      };

  factory ExpenseItem.fromMap(Map<String, dynamic> m) => ExpenseItem(
        itemName: m['item_name'] as String,
        price: (m['price'] as num).toDouble(),
      );
}
