import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/get_recipe_details_usecase.dart';
import '../../domain/usecases/randomize_recipe_usecase.dart';

// State class for recipe
class RecipeState {
  final AsyncValue<Recipe?> currentRecipe;
  final AsyncValue<List<Recipe>> favoriteRecipes;

  RecipeState({
    this.currentRecipe = const AsyncValue.data(null),
    this.favoriteRecipes = const AsyncValue.data([]),
  });

  RecipeState copyWith({
    AsyncValue<Recipe?>? currentRecipe,
    AsyncValue<List<Recipe>>? favoriteRecipes,
  }) {
    return RecipeState(
      currentRecipe: currentRecipe ?? this.currentRecipe,
      favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
    );
  }
}

// State notifier for recipes
class RecipeNotifier extends StateNotifier<RecipeState> {
  final RandomizeRecipeUseCase _randomizeRecipeUseCase;
  final GetRecipeDetailsUseCase _getRecipeDetailsUseCase;
  final RecipeRepository _recipeRepository;

  RecipeNotifier({
    required RandomizeRecipeUseCase randomizeRecipeUseCase,
    required GetRecipeDetailsUseCase getRecipeDetailsUseCase,
    required RecipeRepository recipeRepository,
  }) : _randomizeRecipeUseCase = randomizeRecipeUseCase,
       _getRecipeDetailsUseCase = getRecipeDetailsUseCase,
       _recipeRepository = recipeRepository,
       super(RecipeState());

  Future<void> randomizeRecipe(List<String> ingredients) async {
    try {
      state = state.copyWith(currentRecipe: const AsyncValue.loading());

      final recipe = await _randomizeRecipeUseCase(ingredients);

      state = state.copyWith(currentRecipe: AsyncValue.data(recipe));
    } catch (e, stack) {
      state = state.copyWith(currentRecipe: AsyncValue.error(e, stack));
    }
  }

  Future<void> getRecipeDetails(int id) async {
    try {
      state = state.copyWith(currentRecipe: const AsyncValue.loading());

      final recipe = await _getRecipeDetailsUseCase(id);

      state = state.copyWith(currentRecipe: AsyncValue.data(recipe));
    } catch (e, stack) {
      state = state.copyWith(currentRecipe: AsyncValue.error(e, stack));
    }
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    try {
      final updatedRecipe = recipe.copyWith(isFavorite: !recipe.isFavorite);

      // อัปเดตรายการโปรดในฐานข้อมูล
      if (updatedRecipe.isFavorite) {
        // เพิ่มเข้ารายการโปรด
        await _recipeRepository.addFavoriteRecipe(updatedRecipe);
      } else {
        // ลบออกจากรายการโปรด
        await _recipeRepository.removeFavoriteRecipe(updatedRecipe.id);
      }

      // อัปเดตสูตรอาหารปัจจุบัน
      state = state.copyWith(currentRecipe: AsyncValue.data(updatedRecipe));

      // โหลดรายการโปรดใหม่
      await loadFavorites();
    } catch (e, stack) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> loadFavorites() async {
    try {
      state = state.copyWith(favoriteRecipes: const AsyncValue.loading());

      // ดึงรายการโปรดจากฐานข้อมูล
      final favorites = await _recipeRepository.getFavoriteRecipes();

      state = state.copyWith(favoriteRecipes: AsyncValue.data(favorites));
    } catch (e, stack) {
      state = state.copyWith(favoriteRecipes: AsyncValue.error(e, stack));
    }
  }

  // ลบรายการโปรดทั้งหมด
  Future<void> clearAllFavorites() async {
    try {
      state = state.copyWith(favoriteRecipes: const AsyncValue.loading());

      // ดึงรายการโปรดปัจจุบัน
      final currentFavorites = state.favoriteRecipes.asData?.value ?? [];

      // ลบรายการโปรดทีละรายการ
      for (final recipe in currentFavorites) {
        if (recipe.isFavorite) {
          await _recipeRepository.removeFavoriteRecipe(recipe.id);
        }
      }

      // อัปเดตสถานะเป็นรายการว่าง
      state = state.copyWith(favoriteRecipes: const AsyncValue.data([]));
    } catch (e, stack) {
      print('Error clearing favorites: $e');
      state = state.copyWith(favoriteRecipes: AsyncValue.error(e, stack));
    }
  }
}

// Provider for recipe notifier
final recipeProvider = StateNotifierProvider<RecipeNotifier, RecipeState>((
  ref,
) {
  return RecipeNotifier(
    randomizeRecipeUseCase: sl<RandomizeRecipeUseCase>(),
    getRecipeDetailsUseCase: sl<GetRecipeDetailsUseCase>(),
    recipeRepository: sl<RecipeRepository>(),
  );
});
