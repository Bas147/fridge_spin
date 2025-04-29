import '../entities/ingredient.dart';
import '../repositories/ingredient_repository.dart';

class AddIngredientUseCase {
  final IngredientRepository repository;

  AddIngredientUseCase(this.repository);

  Future<Ingredient> call(Ingredient ingredient) {
    return repository.addIngredient(ingredient);
  }
}
