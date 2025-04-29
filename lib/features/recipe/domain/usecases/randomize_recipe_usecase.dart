import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class RandomizeRecipeUseCase {
  final RecipeRepository repository;

  RandomizeRecipeUseCase(this.repository);

  Future<Recipe> call(List<String> ingredients) {
    final ingredientNames =
        ingredients.map((i) {
          // Extract just the name from the ingredients (which might include quantity)
          final parts = i.split(',');
          return parts[0].trim();
        }).toList();

    return repository.getRandomRecipeByIngredients(ingredientNames);
  }
}
