import '../repositories/ingredient_repository.dart';

class ClearIngredientsUseCase {
  final IngredientRepository repository;

  ClearIngredientsUseCase(this.repository);

  Future<void> call() async {
    return await repository.clearAllIngredients();
  }
}
