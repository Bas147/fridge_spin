import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_firebase_datasource.dart';
import '../datasources/spoonacular_datasource.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final SpoonacularDataSource spoonacularDataSource;
  final RecipeFirebaseDataSource firebaseDataSource;

  RecipeRepositoryImpl({
    required this.spoonacularDataSource,
    required this.firebaseDataSource,
  });

  @override
  Future<Recipe> getRandomRecipeByIngredients(List<String> ingredients) async {
    final recipe = await spoonacularDataSource.getRandomRecipeByIngredients(
      ingredients,
    );

    // Check if this recipe is in favorites
    try {
      final favorites = await firebaseDataSource.getFavoriteRecipes();
      final isFavorite = favorites.any((fav) => fav.id == recipe.id);

      if (isFavorite) {
        return RecipeModel(
          id: recipe.id,
          name: recipe.name,
          image: recipe.image,
          ingredients: recipe.ingredients,
          instructions: recipe.instructions,
          cuisine: recipe.cuisine,
          servings: recipe.servings,
          cookingTimeMinutes: recipe.cookingTimeMinutes,
          isFavorite: true,
        );
      }
    } catch (_) {
      // If favorites can't be fetched, continue with recipe as non-favorite
    }

    return recipe;
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    final recipe = await spoonacularDataSource.getRecipeById(id);

    // Check if this recipe is in favorites
    try {
      final favorites = await firebaseDataSource.getFavoriteRecipes();
      final isFavorite = favorites.any((fav) => fav.id == recipe.id);

      if (isFavorite) {
        return RecipeModel(
          id: recipe.id,
          name: recipe.name,
          image: recipe.image,
          ingredients: recipe.ingredients,
          instructions: recipe.instructions,
          cuisine: recipe.cuisine,
          servings: recipe.servings,
          cookingTimeMinutes: recipe.cookingTimeMinutes,
          isFavorite: true,
        );
      }
    } catch (_) {
      // If favorites can't be fetched, continue with recipe as non-favorite
    }

    return recipe;
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    final recipes = await firebaseDataSource.getFavoriteRecipes();
    return recipes;
  }

  @override
  Future<void> addFavoriteRecipe(Recipe recipe) async {
    final recipeModel = RecipeModel.fromEntity(recipe);
    await firebaseDataSource.addFavoriteRecipe(recipeModel);
  }

  @override
  Future<void> removeFavoriteRecipe(int id) async {
    await firebaseDataSource.removeFavoriteRecipe(id);
  }
}
