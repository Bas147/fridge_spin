import 'package:dio/dio.dart';
import 'dart:math';
import '../models/recipe_model.dart';

abstract class SpoonacularDataSource {
  Future<RecipeModel> getRandomRecipeByIngredients(List<String> ingredients);
  Future<RecipeModel> getRecipeById(int id);
}

class SpoonacularDataSourceImpl implements SpoonacularDataSource {
  final Dio dio;
  final String apiKey;
  final String baseUrl = 'https://api.spoonacular.com';

  SpoonacularDataSourceImpl({required this.dio, required this.apiKey});

  /// Check if ingredients are in English or convert to English
  List<String> _translateIngredientsToEnglish(List<String> ingredients) {
    final List<String> englishIngredients = [];

    // Process each ingredient
    for (String ingredient in ingredients) {
      String english = ingredient.trim().toLowerCase();

      // Check if ingredient is already in English
      bool isAlreadyEnglish = english
          .split('')
          .every(
            (char) => char.codeUnitAt(0) < 128 || char == ' ' || char == ',',
          );

      if (isAlreadyEnglish) {
        englishIngredients.add(english);
      } else {
        // If not English, use a generic fallback or skip
        // This assumes users will input ingredients in English
        englishIngredients.add('ingredient');
      }
    }

    return englishIngredients;
  }

  @override
  Future<RecipeModel> getRandomRecipeByIngredients(
    List<String> ingredients,
  ) async {
    try {
      // Convert ingredient names to English
      final englishIngredients = _translateIngredientsToEnglish(ingredients);
      print('Translated ingredients to English: $englishIngredients');

      // Get a list of recipes based on ingredients
      final response = await dio.get(
        '$baseUrl/recipes/findByIngredients',
        queryParameters: {
          'ingredients': englishIngredients.join(','),
          'number': 10, // Get multiple recipes to randomize from
          'ranking':
              2, // 1=maximize used ingredients, 2=minimize missing ingredients
          'ignorePantry': false, // Include basic ingredients
          'apiKey': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> recipes = response.data;

        if (recipes.isEmpty) {
          throw Exception('No recipes found for these ingredients');
        }

        // Filter recipes that use actual ingredients
        final filteredRecipes =
            recipes.where((recipe) {
              // Check if this recipe uses at least one of our ingredients
              final usedIngredients =
                  recipe['usedIngredients'] as List<dynamic>;
              return usedIngredients.isNotEmpty;
            }).toList();

        if (filteredRecipes.isEmpty) {
          throw Exception('No recipes found that use your ingredients');
        }

        // Sort by recipes that use the most ingredients we have
        filteredRecipes.sort((a, b) {
          final aUsed = (a['usedIngredients'] as List).length;
          final bUsed = (b['usedIngredients'] as List).length;
          return bUsed.compareTo(aUsed); // Sort from most to least
        });

        // Randomly select from top 3 recipes
        final topRecipes = filteredRecipes.take(3).toList();
        final random = Random();
        final selectedRecipe = topRecipes[random.nextInt(topRecipes.length)];
        final recipeId = selectedRecipe['id'];

        // Get full recipe information
        return await getRecipeById(recipeId);
      } else {
        throw Exception('Failed to fetch recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  @override
  Future<RecipeModel> getRecipeById(int id) async {
    try {
      final response = await dio.get(
        '$baseUrl/recipes/$id/information',
        queryParameters: {'includeNutrition': false, 'apiKey': apiKey},
      );

      if (response.statusCode == 200) {
        return RecipeModel.fromSpoonacular(response.data);
      } else {
        throw Exception(
          'Failed to fetch recipe details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching recipe details: $e');
    }
  }
}
