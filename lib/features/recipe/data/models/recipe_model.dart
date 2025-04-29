import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  RecipeModel({
    required int id,
    required String name,
    required String image,
    required List<String> ingredients,
    required List<String> instructions,
    required String cuisine,
    required int servings,
    required int cookingTimeMinutes,
    bool isFavorite = false,
  }) : super(
         id: id,
         name: name,
         image: image,
         ingredients: ingredients,
         instructions: instructions,
         cuisine: cuisine,
         servings: servings,
         cookingTimeMinutes: cookingTimeMinutes,
         isFavorite: isFavorite,
       );

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      image: recipe.image,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      cuisine: recipe.cuisine,
      servings: recipe.servings,
      cookingTimeMinutes: recipe.cookingTimeMinutes,
      isFavorite: recipe.isFavorite,
    );
  }

  /// Return the original English text instead of translating to Thai
  static String _translateCommonTermsToThai(String englishText) {
    // Return the original text without translation
    return englishText;
  }

  factory RecipeModel.fromSpoonacular(Map<String, dynamic> json) {
    // Handle recipe from Spoonacular API format
    List<String> ingredients = [];
    List<String> instructions = [];

    // Extract ingredients from Spoonacular format
    if (json['extendedIngredients'] != null) {
      ingredients =
          (json['extendedIngredients'] as List).map((ingredient) {
            String ingredientStr =
                '${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}';
            return ingredientStr;
          }).toList();
    }

    // Extract instructions from Spoonacular format
    if (json['analyzedInstructions'] != null &&
        (json['analyzedInstructions'] as List).isNotEmpty) {
      final steps = json['analyzedInstructions'][0]['steps'] as List;
      instructions =
          steps.map((step) {
            final stepText = step['step'] as String;
            return stepText;
          }).toList();
    }

    // Use original English title
    String title = json['title'] as String;

    return RecipeModel(
      id: json['id'] as int,
      name: title,
      image: json['image'] ?? '',
      ingredients: ingredients,
      instructions: instructions,
      cuisine:
          (json['cuisines'] as List?)?.isNotEmpty == true
              ? (json['cuisines'] as List).first as String
              : 'Unknown',
      servings: json['servings'] as int? ?? 2,
      cookingTimeMinutes: json['readyInMinutes'] as int? ?? 30,
      isFavorite: false,
    );
  }

  static String _translateCuisine(String cuisine) {
    // Return the original cuisine name without translation
    return cuisine;
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
      ingredients: List<String>.from(json['ingredients']),
      instructions: List<String>.from(json['instructions']),
      cuisine: json['cuisine'] as String,
      servings: json['servings'] as int,
      cookingTimeMinutes: json['cookingTimeMinutes'] as int,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'ingredients': ingredients,
      'instructions': instructions,
      'cuisine': cuisine,
      'servings': servings,
      'cookingTimeMinutes': cookingTimeMinutes,
      'isFavorite': isFavorite,
    };
  }
}
