import 'package:flutter/foundation.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/repositories/ingredient_repository.dart';
import '../datasources/ingredient_firebase_datasource.dart';
import '../datasources/local_ingredient_datasource.dart';
import '../models/ingredient_model.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final IngredientFirebaseDataSource firebaseDataSource;
  final LocalIngredientDataSource localDataSource;

  IngredientRepositoryImpl({
    required this.firebaseDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Ingredient>> getIngredients() async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ข้อมูลจาก local storage
        return await localDataSource.getIngredients();
      }

      // ในโหมด Production ใช้ข้อมูลจาก Firebase
      final ingredients = await firebaseDataSource.getIngredients();
      return ingredients;
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาดกับ Firebase ให้ลองใช้ local storage
      return await localDataSource.getIngredients();
    }
  }

  @override
  Future<Ingredient> addIngredient(Ingredient ingredient) async {
    final ingredientModel = IngredientModel.fromEntity(ingredient);

    // บันทึกลง local storage ทุกครั้ง
    await localDataSource.addIngredient(ingredientModel);

    if (!kDebugMode) {
      // ในโหมด Production บันทึกลง Firebase ด้วย
      return await firebaseDataSource.addIngredient(ingredientModel);
    }

    return ingredient;
  }

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {
    final ingredientModel = IngredientModel.fromEntity(ingredient);

    // อัปเดตใน local storage ทุกครั้ง
    await localDataSource.updateIngredient(ingredientModel);

    if (!kDebugMode) {
      // ในโหมด Production อัปเดตใน Firebase ด้วย
      await firebaseDataSource.updateIngredient(ingredientModel);
    }
  }

  @override
  Future<void> deleteIngredient(String id) async {
    // ลบจาก local storage ทุกครั้ง
    await localDataSource.deleteIngredient(id);

    if (!kDebugMode) {
      // ในโหมด Production ลบจาก Firebase ด้วย
      await firebaseDataSource.deleteIngredient(id);
    }
  }

  @override
  Future<void> clearAllIngredients() async {
    // ลบจาก local storage ทุกครั้ง
    await localDataSource.clearAllIngredients();

    if (!kDebugMode) {
      // ในโหมด Production ลบจาก Firebase ด้วย
      await firebaseDataSource.clearAllIngredients();
    }
  }

  @override
  Future<List<Ingredient>> getNearExpiryIngredients() async {
    if (kDebugMode) {
      // ในโหมดดีบัก ให้กรองข้อมูลจาก getIngredients จาก local storage
      final allIngredients = await localDataSource.getIngredients();
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

      return allIngredients.where((ingredient) {
        if (ingredient.expiryDate == null) return false;
        return ingredient.expiryDate!.isBefore(tomorrow);
      }).toList();
    }

    // ในโหมด Production ใช้ข้อมูลจาก Firebase
    try {
      final nearExpiryIngredients =
          await firebaseDataSource.getNearExpiryIngredients();
      return nearExpiryIngredients;
    } catch (e) {
      // ถ้าเกิดข้อผิดพลาด ให้ใช้ local storage แทน
      print('Error getting near expiry ingredients: $e');
      final allIngredients = await localDataSource.getIngredients();
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

      return allIngredients.where((ingredient) {
        if (ingredient.expiryDate == null) return false;
        return ingredient.expiryDate!.isBefore(tomorrow);
      }).toList();
    }
  }
}
