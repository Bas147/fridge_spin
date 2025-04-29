import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/ingredient.dart';
import '../models/ingredient_model.dart';

abstract class LocalIngredientDataSource {
  Future<List<IngredientModel>> getIngredients();
  Future<IngredientModel> addIngredient(IngredientModel ingredient);
  Future<IngredientModel> updateIngredient(IngredientModel ingredient);
  Future<void> deleteIngredient(String id);
  Future<void> clearAllIngredients();
}

class LocalIngredientDataSourceImpl implements LocalIngredientDataSource {
  final SharedPreferences sharedPreferences;
  static const String ingredientsKey = 'ingredients_key';

  LocalIngredientDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<IngredientModel>> getIngredients() async {
    try {
      final jsonString = sharedPreferences.getString(ingredientsKey);
      if (jsonString == null) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((e) => IngredientModel.fromJson(e)).toList();
    } catch (e) {
      print('Error getting ingredients from local storage: $e');
      return [];
    }
  }

  @override
  Future<IngredientModel> addIngredient(IngredientModel ingredient) async {
    try {
      final currentIngredients = await getIngredients();
      currentIngredients.add(ingredient);
      await _saveIngredients(currentIngredients);
      return ingredient;
    } catch (e) {
      print('Error adding ingredient to local storage: $e');
      rethrow;
    }
  }

  @override
  Future<IngredientModel> updateIngredient(IngredientModel ingredient) async {
    try {
      final currentIngredients = await getIngredients();
      final index = currentIngredients.indexWhere((i) => i.id == ingredient.id);

      if (index >= 0) {
        currentIngredients[index] = ingredient;
        await _saveIngredients(currentIngredients);
      }

      return ingredient;
    } catch (e) {
      print('Error updating ingredient in local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteIngredient(String id) async {
    try {
      final currentIngredients = await getIngredients();
      currentIngredients.removeWhere((i) => i.id == id);
      await _saveIngredients(currentIngredients);
    } catch (e) {
      print('Error deleting ingredient from local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllIngredients() async {
    try {
      await sharedPreferences.remove(ingredientsKey);
    } catch (e) {
      print('Error clearing ingredients from local storage: $e');
      rethrow;
    }
  }

  // Helper method to save the ingredient list to SharedPreferences
  Future<void> _saveIngredients(List<IngredientModel> ingredients) async {
    final jsonList = ingredients.map((i) => i.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(ingredientsKey, jsonString);
  }
}
