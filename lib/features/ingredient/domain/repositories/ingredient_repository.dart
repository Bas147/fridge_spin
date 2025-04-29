import '../entities/ingredient.dart';

abstract class IngredientRepository {
  Future<List<Ingredient>> getIngredients();
  Future<Ingredient> addIngredient(Ingredient ingredient);
  Future<void> updateIngredient(Ingredient ingredient);
  Future<void> deleteIngredient(String id);
  Future<List<Ingredient>> getNearExpiryIngredients();
  Future<void> clearAllIngredients();
}
