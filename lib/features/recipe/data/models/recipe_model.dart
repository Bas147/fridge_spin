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
    // ตรวจสอบข้อมูลจำเป็นก่อนการสร้างโมเดล
    if (json['id'] == null) {
      throw Exception('Recipe ID is missing in API response');
    }

    // Extract ingredients
    List<String> ingredients = [];
    try {
      if (json['extendedIngredients'] != null) {
        final List<dynamic> extendedIngredients = json['extendedIngredients'];
        ingredients =
            extendedIngredients
                .map(
                  (ingredient) =>
                      '${ingredient['amount'] ?? ''} ${ingredient['unit'] ?? ''} ${ingredient['name'] ?? ''}',
                )
                .toList();
      }
    } catch (e) {
      print('Error parsing ingredients: $e');
      // ในกรณีที่ไม่สามารถแยกวิเคราะห์ส่วนผสมได้ เราจะใช้รายการว่าง
    }

    // Extract instructions
    List<String> instructions = [];
    try {
      if (json['analyzedInstructions'] != null &&
          json['analyzedInstructions'].isNotEmpty &&
          json['analyzedInstructions'][0]['steps'] != null) {
        final List<dynamic> steps = json['analyzedInstructions'][0]['steps'];
        instructions =
            steps
                .map<String>((step) => '${step['number']}. ${step['step']}')
                .toList();
      } else if (json['instructions'] != null &&
          json['instructions'].isNotEmpty) {
        // ถ้าไม่มี analyzedInstructions ให้ใช้ instructions string แทน
        instructions = [json['instructions']];
      }
    } catch (e) {
      print('Error parsing instructions: $e');
      // ในกรณีที่ไม่สามารถแยกวิเคราะห์คำแนะนำได้ เราจะใช้รายการว่าง
    }

    return RecipeModel(
      id: json['id'],
      name: json['title'] ?? 'Unknown Recipe',
      image: json['image'] ?? '',
      ingredients: ingredients,
      instructions: instructions,
      cuisine:
          json['cuisines'] != null && json['cuisines'].isNotEmpty
              ? json['cuisines'][0]
              : 'Mixed',
      servings: json['servings'] ?? 1,
      cookingTimeMinutes: json['readyInMinutes'] ?? 30,
      isFavorite: false,
    );
  }

  static String _translateCuisine(String cuisine) {
    // Return the original cuisine name without translation
    return cuisine;
  }

  @override
  String toString() {
    return 'RecipeModel(id: $id, name: $name, ingredients: $ingredients, instructions: $instructions, cuisine: $cuisine, servings: $servings, cookingTimeMinutes: $cookingTimeMinutes, isFavorite: $isFavorite)';
  }

  Map<String, dynamic> toJson() {
    try {
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
    } catch (e) {
      print('Error serializing recipe: $e');
      // Return minimal valid JSON if there's an error
      return {
        'id': id,
        'name': name,
        'image': '',
        'ingredients': <String>[],
        'instructions': <String>[],
        'cuisine': 'Unknown',
        'servings': 1,
        'cookingTimeMinutes': 30,
        'isFavorite': false,
      };
    }
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    try {
      return RecipeModel(
        id: json['id'],
        name: json['name'],
        image: json['image'] ?? '',
        ingredients: List<String>.from(json['ingredients'] ?? []),
        instructions: List<String>.from(json['instructions'] ?? []),
        cuisine: json['cuisine'] ?? 'Unknown',
        servings: json['servings'] ?? 1,
        cookingTimeMinutes: json['cookingTimeMinutes'] ?? 30,
        isFavorite: json['isFavorite'] ?? false,
      );
    } catch (e) {
      print('Error deserializing recipe: $e');
      // Return minimal valid object if there's an error
      return RecipeModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown Recipe',
        image: '',
        ingredients: <String>[],
        instructions: <String>[],
        cuisine: 'Unknown',
        servings: 1,
        cookingTimeMinutes: 30,
        isFavorite: false,
      );
    }
  }
}
