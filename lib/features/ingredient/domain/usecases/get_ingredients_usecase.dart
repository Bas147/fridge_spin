import '../entities/ingredient.dart';
import '../repositories/ingredient_repository.dart';

class GetIngredientsUseCase {
  final IngredientRepository repository;

  GetIngredientsUseCase(this.repository);

  Future<List<Ingredient>> call() {
    return repository.getIngredients();
  }
}
