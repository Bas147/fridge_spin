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
    // คำแปลจากไทยเป็นอังกฤษ
    final Map<String, String> thaiToEnglish = {
      'เนื้อ': 'beef',
      'เนื้อวัว': 'beef',
      'หมู': 'pork',
      'เนื้อหมู': 'pork',
      'ไก่': 'chicken',
      'เนื้อไก่': 'chicken',
      'ปลา': 'fish',
      'กุ้ง': 'shrimp',
      'ปู': 'crab',
      'หอย': 'shellfish',
      'ไข่': 'egg',
      'ข้าว': 'rice',
      'มะเขือเทศ': 'tomato',
      'แครอท': 'carrot',
      'หอมใหญ่': 'onion',
      'กระเทียม': 'garlic',
      'พริก': 'chili',
      'มันฝรั่ง': 'potato',
      'แตงกวา': 'cucumber',
      'ผักกาดขาว': 'cabbage',
      'ผักคะน้า': 'kale',
      'ผักบุ้ง': 'morning glory',
      'น้ำตาล': 'sugar',
      'เกลือ': 'salt',
      'พริกไทย': 'pepper',
      'ซอสถั่วเหลือง': 'soy sauce',
      'น้ำมัน': 'oil',
      'น้ำปลา': 'fish sauce',
      'นม': 'milk',
      'เนย': 'butter',
      'ชีส': 'cheese',
      'เส้นสปาเกตตี้': 'spaghetti',
      'บะหมี่': 'noodle',
    };

    final List<String> englishIngredients = [];

    // Process each ingredient
    for (String ingredient in ingredients) {
      String english = ingredient.trim().toLowerCase();

      // ตรวจสอบว่าเป็นภาษาไทยหรือไม่
      bool isThai = english
          .split('')
          .any(
            (char) =>
                char.codeUnitAt(0) > 0x0E00 && char.codeUnitAt(0) < 0x0E7F,
          );

      if (isThai) {
        // หาคำแปลจากพจนานุกรม
        bool found = false;
        for (var thaiWord in thaiToEnglish.keys) {
          if (english.contains(thaiWord.toLowerCase())) {
            englishIngredients.add(thaiToEnglish[thaiWord]!);
            found = true;
            print('แปลวัตถุดิบ: $english -> ${thaiToEnglish[thaiWord]}');
            break;
          }
        }

        // ถ้าไม่พบในพจนานุกรม ใช้คำทั่วไป
        if (!found) {
          englishIngredients.add('ingredient');
          print('ไม่พบคำแปลสำหรับ: $english, ใช้ "ingredient" แทน');
        }
      } else {
        // ถ้าเป็นภาษาอังกฤษอยู่แล้ว
        englishIngredients.add(english);
      }
    }

    print('รายการวัตถุดิบที่แปลแล้ว: $englishIngredients');
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

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null || !(response.data is List)) {
          throw Exception('Invalid response format from API');
        }

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
    } on DioException catch (e) {
      print('DioException occurred: ${e.message}');
      print('DioException type: ${e.type}');
      print('DioException response: ${e.response}');
      throw Exception('Error fetching recipes: ${e.message}');
    } catch (e) {
      print('General error occurred: $e');
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

      print('Recipe details response status: ${response.statusCode}');
      print('Recipe details response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null || !(response.data is Map)) {
          throw Exception('Invalid recipe details format from API');
        }
        return RecipeModel.fromSpoonacular(response.data);
      } else {
        throw Exception(
          'Failed to fetch recipe details: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioException occurred: ${e.message}');
      print('DioException type: ${e.type}');
      print('DioException response: ${e.response}');
      throw Exception('Error fetching recipe details: ${e.message}');
    } catch (e) {
      print('General error occurred: $e');
      throw Exception('Error fetching recipe details: $e');
    }
  }
}
