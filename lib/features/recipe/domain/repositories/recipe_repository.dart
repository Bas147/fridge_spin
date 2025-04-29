import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<Recipe> getRandomRecipeByIngredients(List<String> ingredients);
  Future<Recipe> getRecipeById(int id);
  Future<List<Recipe>> getFavoriteRecipes();
  Future<void> addFavoriteRecipe(Recipe recipe);
  Future<void> removeFavoriteRecipe(int id);
}
