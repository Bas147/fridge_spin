import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../ingredient/presentation/providers/ingredient_provider.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';

class RecipeResultScreen extends ConsumerWidget {
  const RecipeResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeState = ref.watch(recipeProvider);
    final currentRecipe = recipeState.currentRecipe;

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Search Results')),
      body: currentRecipe.when(
        loading: () => Center(child: SpinKitCircle(color: AppColors.primary)),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Error finding recipes: $error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
        data: (recipe) {
          // If no recipe is found
          if (recipe == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, color: AppColors.grey, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'No recipes found for these ingredients',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Try adding different ingredients or try again later',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          // Show recipe result
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Recipe Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Recipe Image
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Container(
                            height: 200,
                            child: _buildRecipeImage(recipe.image),
                          ),
                        ),

                        // Recipe Details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Recipe Name
                              Text(
                                recipe.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Recipe Info
                              Row(
                                children: [
                                  _buildInfoItem(
                                    Icons.restaurant,
                                    recipe.cuisine,
                                  ),
                                  _buildInfoItem(
                                    Icons.people,
                                    '${recipe.servings} servings',
                                  ),
                                  _buildInfoItem(
                                    Icons.timer,
                                    '${recipe.cookingTimeMinutes} min',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Main Ingredients
                              const Text(
                                'Main Ingredients:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildIngredientsList(recipe),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        // Try Another Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Keep ingredients from the previous request and find a new recipe
                              final ingredients =
                                  ref
                                      .read(ingredientProvider)
                                      .value
                                      ?.map((i) => i.name)
                                      .toList() ??
                                  [];
                              if (ingredients.isNotEmpty) {
                                ref
                                    .read(recipeProvider.notifier)
                                    .randomizeRecipe(ingredients);
                              }
                            },
                            icon: Icon(
                              Icons.refresh,
                              color: AppColors.secondary,
                            ),
                            label: Text(
                              'Try Another',
                              style: TextStyle(color: AppColors.secondary),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.secondary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // View Recipe Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => RecipeDetailScreen(
                                        recipeId: recipe.id,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.restaurant_menu),
                            label: const Text('View Recipe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.lightGrey,
        child: Center(
          child: Icon(Icons.restaurant, size: 60, color: Colors.grey.shade600),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Center(
            child: SpinKitFadingCircle(color: AppColors.primary, size: 30),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: AppColors.lightGrey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 60, color: Colors.grey.shade600),
                  const SizedBox(height: 8),
                  const Text(
                    "Unable to load image",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIngredientsList(dynamic recipe) {
    final maxIngredientsToShow = 5;

    final visibleIngredients =
        recipe.ingredients.length > maxIngredientsToShow
            ? recipe.ingredients.sublist(0, maxIngredientsToShow)
            : recipe.ingredients;

    final List<Widget> ingredientWidgets =
        visibleIngredients
            .map<Widget>(
              (ingredient) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList();

    if (recipe.ingredients.length > maxIngredientsToShow) {
      final remainingCount = recipe.ingredients.length - maxIngredientsToShow;
      ingredientWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Text(
            'and $remainingCount more items',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return ingredientWidgets;
  }
}
