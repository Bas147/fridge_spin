import '../entities/ingredient.dart';
import '../repositories/ingredient_repository.dart';

class UpdateIngredientUseCase {
  final IngredientRepository repository;

  UpdateIngredientUseCase(this.repository);

  Future<void> call(Ingredient ingredient) {
    return repository.updateIngredient(ingredient);
  }
}
