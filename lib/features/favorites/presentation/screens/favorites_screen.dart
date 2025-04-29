import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../recipe/domain/entities/recipe.dart';
import '../../../recipe/presentation/providers/recipe_provider.dart';
import '../../../recipe/presentation/screens/recipe_detail_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  // สถานะของโหมดการเลือกหลายรายการ
  bool _isSelectionMode = false;
  // รายการ ID ของสูตรอาหารที่ถูกเลือก
  final Set<int> _selectedRecipeIds = {};

  @override
  Widget build(BuildContext context) {
    final recipeState = ref.watch(recipeProvider);
    final favoritesState = recipeState.favoriteRecipes;

    // Load favorites if not already loaded
    if (favoritesState.asData?.value.isEmpty ?? true) {
      Future.microtask(() {
        ref.read(recipeProvider.notifier).loadFavorites();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการโปรด'),
        actions: [
          if (favoritesState.hasValue && favoritesState.value!.isNotEmpty)
            IconButton(
              icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
              tooltip: _isSelectionMode ? 'ยกเลิกการเลือก' : 'เลือกหลายรายการ',
              onPressed: () {
                setState(() {
                  // สลับโหมดการเลือก
                  _isSelectionMode = !_isSelectionMode;
                  // ล้างรายการที่เลือกเมื่อออกจากโหมดเลือก
                  if (!_isSelectionMode) {
                    _selectedRecipeIds.clear();
                  }
                });
              },
            ),
        ],
      ),
      body: favoritesState.when(
        loading: () => Center(child: SpinKitCircle(color: AppColors.primary)),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'เกิดข้อผิดพลาดในการโหลดรายการโปรด: $error',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => ref.read(recipeProvider.notifier).loadFavorites(),
                    child: const Text('ลองอีกครั้ง'),
                  ),
                ],
              ),
            ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, color: AppColors.grey, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'ยังไม่มีสูตรอาหารโปรด',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'สูตรอาหารที่คุณบันทึกไว้จะปรากฏที่นี่',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  _isSelectionMode && _selectedRecipeIds.isNotEmpty ? 80 : 16,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final recipe = favorites[index];
                  return _isSelectionMode
                      ? _buildSelectableRecipeCard(context, recipe, ref)
                      : _buildDismissibleRecipeCard(context, recipe, ref);
                },
              ),

              // แสดงปุ่มลบด้านล่างเมื่อมีการเลือกรายการ
              if (_isSelectionMode && _selectedRecipeIds.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton.icon(
                    onPressed:
                        () => _showDeleteSelectedConfirmation(
                          context,
                          ref,
                          favorites,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.delete),
                    label: Text(
                      'ลบรายการที่เลือก (${_selectedRecipeIds.length})',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectableRecipeCard(
    BuildContext context,
    Recipe recipe,
    WidgetRef ref,
  ) {
    final isSelected = _selectedRecipeIds.contains(recipe.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          setState(() {
            // สลับการเลือก/ยกเลิกการเลือกรายการ
            if (isSelected) {
              _selectedRecipeIds.remove(recipe.id);
            } else {
              _selectedRecipeIds.add(recipe.id);
            }
          });
        },
        child: Stack(
          children: [
            _buildRecipeCardContent(recipe),
            // แสดง checkbox ในโหมดเลือก
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedRecipeIds.add(recipe.id);
                      } else {
                        _selectedRecipeIds.remove(recipe.id);
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleRecipeCard(
    BuildContext context,
    Recipe recipe,
    WidgetRef ref,
  ) {
    return Dismissible(
      key: Key('favorite_${recipe.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // เรียกใช้ toggleFavorite เพื่อยกเลิกการบันทึกสูตรอาหารเป็นรายการโปรด
        ref.read(recipeProvider.notifier).toggleFavorite(recipe);

        // แสดงแจ้งเตือนว่าได้ลบรายการแล้ว
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบ "${recipe.name}" ออกจากรายการโปรดแล้ว'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      confirmDismiss: (direction) async {
        // แสดงกล่องยืนยันก่อนลบ
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('ยืนยันการลบ'),
              content: Text(
                'คุณต้องการลบ "${recipe.name}" ออกจากรายการโปรดหรือไม่?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('ยกเลิก'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('ลบ'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
              ),
            );
          },
          child: _buildRecipeCardContent(recipe),
        ),
      ),
    );
  }

  Widget _buildRecipeCardContent(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: const Icon(Icons.restaurant, size: 48),
                ),
          ),
        ),

        // Recipe Info
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!_isSelectionMode)
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      tooltip: 'นำออกจากรายการโปรด',
                      onPressed: () {
                        _showRemoveConfirmation(context, recipe, ref);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 16, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    recipe.cuisine,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: AppColors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${recipe.cookingTimeMinutes} นาที',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // แสดงกล่องยืนยันการลบออกจากรายการโปรด
  Future<void> _showRemoveConfirmation(
    BuildContext context,
    Recipe recipe,
    WidgetRef ref,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ยืนยันการลบ'),
            content: Text(
              'คุณต้องการลบ "${recipe.name}" ออกจากรายการโปรดหรือไม่?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(recipeProvider.notifier).toggleFavorite(recipe);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ลบ "${recipe.name}" ออกจากรายการโปรดแล้ว'),
                    ),
                  );
                },
                child: const Text('ลบ'),
              ),
            ],
          ),
    );
  }

  // แสดงกล่องยืนยันการลบรายการที่เลือก
  Future<void> _showDeleteSelectedConfirmation(
    BuildContext context,
    WidgetRef ref,
    List<Recipe> favorites,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ยืนยันการลบ'),
            content: Text(
              'คุณต้องการลบรายการที่เลือกจำนวน ${_selectedRecipeIds.length} รายการหรือไม่?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteSelectedRecipes(favorites, ref);
                },
                child: const Text('ลบ'),
              ),
            ],
          ),
    );
  }

  // ลบรายการที่เลือกทั้งหมด
  void _deleteSelectedRecipes(List<Recipe> favorites, WidgetRef ref) {
    // หารายการสูตรอาหารที่ต้องการลบ
    final recipesToDelete =
        favorites
            .where((recipe) => _selectedRecipeIds.contains(recipe.id))
            .toList();

    // ลบทีละรายการ
    for (final recipe in recipesToDelete) {
      ref.read(recipeProvider.notifier).toggleFavorite(recipe);
    }

    // แสดงข้อความแจ้งเตือน
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ลบ ${recipesToDelete.length} รายการเรียบร้อยแล้ว'),
      ),
    );

    // ออกจากโหมดเลือก
    setState(() {
      _isSelectionMode = false;
      _selectedRecipeIds.clear();
    });
  }
}
