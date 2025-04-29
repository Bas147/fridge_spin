import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetRecipeDetailsUseCase {
  final RecipeRepository repository;

  GetRecipeDetailsUseCase(this.repository);

  Future<Recipe> call(int id) {
    return repository.getRecipeById(id);
  }
}
