import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/usecases/add_ingredient_usecase.dart';
import '../../domain/usecases/clear_ingredients_usecase.dart';
import '../../domain/usecases/delete_ingredient_usecase.dart';
import '../../domain/usecases/get_ingredients_usecase.dart';
import '../../domain/usecases/update_ingredient_usecase.dart';

// State notifier for ingredients
class IngredientNotifier extends StateNotifier<AsyncValue<List<Ingredient>>> {
  final GetIngredientsUseCase _getIngredientsUseCase;
  final AddIngredientUseCase _addIngredientUseCase;
  final UpdateIngredientUseCase _updateIngredientUseCase;
  final DeleteIngredientUseCase _deleteIngredientUseCase;
  final ClearIngredientsUseCase _clearIngredientsUseCase;

  IngredientNotifier({
    required GetIngredientsUseCase getIngredientsUseCase,
    required AddIngredientUseCase addIngredientUseCase,
    required UpdateIngredientUseCase updateIngredientUseCase,
    required DeleteIngredientUseCase deleteIngredientUseCase,
    required ClearIngredientsUseCase clearIngredientsUseCase,
  }) : _getIngredientsUseCase = getIngredientsUseCase,
       _addIngredientUseCase = addIngredientUseCase,
       _updateIngredientUseCase = updateIngredientUseCase,
       _deleteIngredientUseCase = deleteIngredientUseCase,
       _clearIngredientsUseCase = clearIngredientsUseCase,
       super(const AsyncValue.loading()) {
    loadIngredients();
  }

  Future<void> loadIngredients() async {
    try {
      state = const AsyncValue.loading();
      final ingredients = await _getIngredientsUseCase();
      state = AsyncValue.data(ingredients);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    try {
      // ป้องกันการเพิ่มวัตถุดิบในขณะที่ state กำลัง loading
      if (state is AsyncLoading) {
        print('ไม่สามารถเพิ่มวัตถุดิบขณะกำลังโหลดข้อมูล');
        return;
      }

      // ตรวจสอบว่ามีวัตถุดิบชื่อเดียวกันอยู่แล้วหรือไม่
      bool isDuplicate = false;

      // ตรวจสอบเฉพาะเมื่อมีรายการวัตถุดิบอยู่แล้ว
      state.whenData((ingredients) {
        final normalizedName = ingredient.name.trim().toLowerCase();
        print('กำลังตรวจสอบวัตถุดิบ: $normalizedName');
        print(
          'รายการวัตถุดิบปัจจุบัน: ${ingredients.map((e) => e.name.trim().toLowerCase())}',
        );

        // ตรวจสอบแบบละเอียดกว่าเดิม
        isDuplicate = ingredients.any((existing) {
          final existingName = existing.name.trim().toLowerCase();

          // เช็คแบบตรงๆ ก่อน
          if (existingName == normalizedName) return true;

          // เช็คแบบพิเศษสำหรับวัตถุดิบที่มักเขียนหลายแบบ
          if ((normalizedName == 'เนื้อวัว' || normalizedName == 'เนื้อ') &&
              (existingName == 'เนื้อวัว' || existingName == 'เนื้อ')) {
            return true;
          }

          if ((normalizedName == 'หมู' || normalizedName == 'เนื้อหมู') &&
              (existingName == 'หมู' || existingName == 'เนื้อหมู')) {
            return true;
          }

          if ((normalizedName == 'ไก่' || normalizedName == 'เนื้อไก่') &&
              (existingName == 'ไก่' || existingName == 'เนื้อไก่')) {
            return true;
          }

          return false;
        });
      });

      // ถ้าซ้ำให้ออกจากฟังก์ชันเลย ไม่ต้องเพิ่ม
      if (isDuplicate) {
        print('วัตถุดิบซ้ำ: ${ingredient.name}');
        return;
      }

      // ถ้าไม่ซ้ำให้เพิ่มตามปกติ
      print('กำลังเพิ่มวัตถุดิบใหม่: ${ingredient.name}');
      final newIngredient = await _addIngredientUseCase(ingredient);

      // บันทึกค่าปัจจุบันของ state ก่อนอัพเดท
      List<Ingredient> currentIngredients = [];
      state.whenData((ingredients) {
        currentIngredients = List.from(ingredients);
      });

      // สร้างรายการใหม่และเซ็ต state ใหม่ (ไม่ใช้ whenData เพื่อหลีกเลี่ยงปัญหา)
      final updatedList = [...currentIngredients, newIngredient];
      print('รายการวัตถุดิบหลังเพิ่ม: ${updatedList.map((e) => e.name)}');
      state = AsyncValue.data(updatedList);
    } catch (e, stack) {
      print('เกิดข้อผิดพลาดในการเพิ่มวัตถุดิบ: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    try {
      await _updateIngredientUseCase(ingredient);

      state.whenData((ingredients) {
        final updatedIngredients =
            ingredients.map((i) {
              return i.id == ingredient.id ? ingredient : i;
            }).toList();

        state = AsyncValue.data(updatedIngredients);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteIngredient(String id) async {
    try {
      await _deleteIngredientUseCase(id);

      state.whenData((ingredients) {
        final updatedIngredients =
            ingredients.where((i) => i.id != id).toList();
        state = AsyncValue.data(updatedIngredients);
      });
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearAllIngredients() async {
    try {
      state = const AsyncValue.loading();
      await _clearIngredientsUseCase();

      // เพิ่มการรอเล็กน้อยเพื่อให้แน่ใจว่าข้อมูลถูกล้างเรียบร้อย
      await Future.delayed(const Duration(milliseconds: 500));

      // ดึงข้อมูลวัตถุดิบใหม่เพื่อตรวจสอบการล้างข้อมูล
      final ingredients = await _getIngredientsUseCase();

      // ตรวจสอบว่ายังมีข้อมูลเหลืออยู่หรือไม่
      if (ingredients.isNotEmpty) {
        print(
          'ยังมีวัตถุดิบคงเหลือหลังการล้างข้อมูล: ${ingredients.length} รายการ',
        );
        // พยายามล้างอีกครั้ง
        await _clearIngredientsUseCase();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // ตั้งค่าให้เป็นรายการว่าง
      state = const AsyncValue.data([]);

      print('ล้างข้อมูลวัตถุดิบสำเร็จแล้ว');
    } catch (e, stack) {
      print('เกิดข้อผิดพลาดในการล้างข้อมูลวัตถุดิบ: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider for ingredient notifier
final ingredientProvider =
    StateNotifierProvider<IngredientNotifier, AsyncValue<List<Ingredient>>>((
      ref,
    ) {
      return IngredientNotifier(
        getIngredientsUseCase: sl<GetIngredientsUseCase>(),
        addIngredientUseCase: sl<AddIngredientUseCase>(),
        updateIngredientUseCase: sl<UpdateIngredientUseCase>(),
        deleteIngredientUseCase: sl<DeleteIngredientUseCase>(),
        clearIngredientsUseCase: sl<ClearIngredientsUseCase>(),
      );
    });
