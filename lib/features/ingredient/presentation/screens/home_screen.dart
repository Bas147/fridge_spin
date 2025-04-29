import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../recipe/presentation/providers/recipe_provider.dart';
import '../../../recipe/presentation/screens/recipe_result_screen.dart';
import '../providers/ingredient_provider.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/ingredients_list.dart';
import 'add_ingredient_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredients = ref.watch(ingredientProvider);
    final hasIngredients = ingredients.asData?.value.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FridgeSpin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const DrawerMenu(),
      body: Column(
        children: [
          // Randomize Recipe Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed:
                    hasIngredients
                        ? () => _randomizeRecipe(context, ref)
                        : null,
                icon: const Icon(Icons.shuffle),
                label: const Text('Randomize Recipe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // Guidance message
          if (!hasIngredients)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Add your ingredients to start randomizing recipes',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

          // Ingredients list with add button
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 16,
                    top: 16,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'วัตถุดิบของฉัน',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: AppColors.primary,
                        onPressed: () => _showAddIngredientScreen(context),
                      ),
                    ],
                  ),
                ),
                const Expanded(child: IngredientsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddIngredientScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddIngredientScreen(),
    );
  }

  void _randomizeRecipe(BuildContext context, WidgetRef ref) {
    final ingredients = ref.read(ingredientProvider).asData?.value ?? [];

    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add ingredients before randomizing recipes'),
        ),
      );
      return;
    }

    // Call recipeProvider to randomize recipe
    final ingredientNames = ingredients.map((i) => i.name).toList();
    ref.read(recipeProvider.notifier).randomizeRecipe(ingredientNames);

    // Navigate to results page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecipeResultScreen()),
    );
  }
}
