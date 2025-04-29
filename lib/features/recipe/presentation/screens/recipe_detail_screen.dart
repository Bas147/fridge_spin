import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final int recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If recipeId is different from current recipe, fetch it
    final currentRecipeState = ref.watch(recipeProvider).currentRecipe;
    final currentRecipe = currentRecipeState.asData?.value;

    if (currentRecipe == null || currentRecipe.id != recipeId) {
      // Load the recipe details
      Future.microtask(() {
        ref.read(recipeProvider.notifier).getRecipeDetails(recipeId);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดสูตรอาหาร'),
        actions: [
          IconButton(
            icon: Icon(
              currentRecipe?.isFavorite == true
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
                  currentRecipe?.isFavorite == true ? Colors.red : Colors.white,
            ),
            onPressed:
                currentRecipe != null
                    ? () => ref
                        .read(recipeProvider.notifier)
                        .toggleFavorite(currentRecipe)
                    : null,
          ),
        ],
      ),
      body: currentRecipeState.when(
        loading: () => Center(child: SpinKitCircle(color: AppColors.primary)),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'เกิดข้อผิดพลาดในการโหลดสูตรอาหาร: $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ย้อนกลับ'),
                  ),
                ],
              ),
            ),
        data: (recipe) {
          if (recipe == null) {
            return const Center(child: Text('ไม่พบสูตรอาหารนี้'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Recipe Image
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: recipe.image,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Center(
                          child: SpinKitFadingCircle(
                            color: AppColors.primary,
                            size: 30,
                          ),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          color: AppColors.lightGrey,
                          child: const Icon(Icons.restaurant, size: 60),
                        ),
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
                      const SizedBox(height: 8),

                      // Recipe Info
                      Row(
                        children: [
                          _buildInfoChip(Icons.restaurant, recipe.cuisine),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.people,
                            '${recipe.servings} servings',
                          ),
                          const SizedBox(width: 12),
                          _buildInfoChip(
                            Icons.timer,
                            '${recipe.cookingTimeMinutes} min',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Ingredients Section
                      const Text(
                        'วัตถุดิบ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      ...recipe.ingredients.map(
                        (ingredient) => _buildIngredientItem(ingredient),
                      ),

                      const SizedBox(height: 24),

                      // Instructions Section
                      const Text(
                        'วิธีทำ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      ...List.generate(
                        recipe.instructions.length,
                        (index) => _buildInstructionItem(
                          index + 1,
                          recipe.instructions[index],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      backgroundColor: AppColors.lightGrey,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textPrimary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  Widget _buildIngredientItem(String ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fiber_manual_record, size: 10, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(ingredient, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(int step, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(instruction, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
