import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ingredient.dart';
import '../providers/ingredient_provider.dart';
import '../screens/add_ingredient_screen.dart';

class IngredientsList extends ConsumerWidget {
  const IngredientsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsState = ref.watch(ingredientProvider);

    return ingredientsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) => Center(
            child: Text(
              'Error loading ingredients: $error',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.error),
            ),
          ),
      data: (ingredients) {
        // กรองรายการวัตถุดิบที่ซ้ำกันออกก่อนแสดงผล
        final uniqueIngredients = _getUniqueIngredients(ingredients);

        // ไม่แสดงหัวข้อแล้ว เพราะ HomeScreen จะแสดงเอง
        return uniqueIngredients.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_basket_outlined,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่มีวัตถุดิบ',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เพิ่มวัตถุดิบจากตู้เย็นของคุณเพื่อเริ่มต้น',
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
            : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: uniqueIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = uniqueIngredients[index];
                return IngredientCard(
                  ingredient: ingredient,
                  onEdit: () => _showEditIngredientScreen(context, ingredient),
                  onDelete: () => _confirmDelete(context, ref, ingredient),
                );
              },
            );
      },
    );
  }

  void _showEditIngredientScreen(BuildContext context, Ingredient ingredient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIngredientScreen(ingredientToEdit: ingredient),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Ingredient ingredient,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ลบวัตถุดิบ'),
            content: Text('คุณต้องการลบ ${ingredient.name} หรือไม่?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  ref
                      .read(ingredientProvider.notifier)
                      .deleteIngredient(ingredient.id);
                  Navigator.pop(context);

                  // แสดงข้อความยืนยันการลบ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ลบ ${ingredient.name} แล้ว'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: Text('ลบ', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }

  // เพิ่มฟังก์ชันใหม่เพื่อกรองรายการวัตถุดิบที่ซ้ำกัน
  List<Ingredient> _getUniqueIngredients(List<Ingredient> ingredients) {
    final uniqueMap = <String, Ingredient>{};

    for (final ingredient in ingredients) {
      final normalizedName = ingredient.name.trim().toLowerCase();

      // ตรวจสอบว่ามีวัตถุดิบนี้ในแม็พแล้วหรือไม่
      bool shouldAdd = true;

      for (final key in uniqueMap.keys) {
        // เช็คแบบตรงๆ
        if (key == normalizedName) {
          shouldAdd = false;
          break;
        }

        // เช็คกรณีพิเศษ
        if ((normalizedName == 'เนื้อวัว' || normalizedName == 'เนื้อ') &&
            (key == 'เนื้อวัว' || key == 'เนื้อ')) {
          shouldAdd = false;
          break;
        }

        if ((normalizedName == 'หมู' || normalizedName == 'เนื้อหมู') &&
            (key == 'หมู' || key == 'เนื้อหมู')) {
          shouldAdd = false;
          break;
        }

        if ((normalizedName == 'ไก่' || normalizedName == 'เนื้อไก่') &&
            (key == 'ไก่' || key == 'เนื้อไก่')) {
          shouldAdd = false;
          break;
        }
      }

      if (shouldAdd) {
        uniqueMap[normalizedName] = ingredient;
      }
    }

    return uniqueMap.values.toList();
  }
}

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Main information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ingredient.quantity,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (ingredient.expiryDate != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color:
                              _isNearExpiry(ingredient.expiryDate!)
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'หมดอายุ: ${_formatDate(ingredient.expiryDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                _isNearExpiry(ingredient.expiryDate!)
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                            fontWeight:
                                _isNearExpiry(ingredient.expiryDate!)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        if (_isNearExpiry(ingredient.expiryDate!)) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ใกล้หมด',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors.primary),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isNearExpiry(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;
    return difference <= 2; // Consider as near expiry if 2 days or less
  }
}
