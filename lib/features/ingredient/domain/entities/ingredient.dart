class Ingredient {
  final String id;
  final String name;
  final String quantity;
  final DateTime? expiryDate;
  final String category;

  Ingredient({
    required this.id,
    required this.name,
    required this.quantity,
    this.expiryDate,
    required this.category,
  });
}
