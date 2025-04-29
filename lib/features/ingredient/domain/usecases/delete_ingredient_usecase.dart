import '../repositories/ingredient_repository.dart';

class DeleteIngredientUseCase {
  final IngredientRepository repository;

  DeleteIngredientUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteIngredient(id);
  }
}
