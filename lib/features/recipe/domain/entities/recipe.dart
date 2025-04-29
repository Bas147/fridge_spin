class Recipe {
  final int id;
  final String name;
  final String image;
  final List<String> ingredients;
  final List<String> instructions;
  final String cuisine;
  final int servings;
  final int cookingTimeMinutes;
  final bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.ingredients,
    required this.instructions,
    required this.cuisine,
    required this.servings,
    required this.cookingTimeMinutes,
    this.isFavorite = false,
  });

  Recipe copyWith({
    int? id,
    String? name,
    String? image,
    List<String>? ingredients,
    List<String>? instructions,
    String? cuisine,
    int? servings,
    int? cookingTimeMinutes,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      cuisine: cuisine ?? this.cuisine,
      servings: servings ?? this.servings,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
