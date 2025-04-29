import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ingredient.dart';
import '../models/ingredient_model.dart';

abstract class IngredientFirebaseDataSource {
  Future<List<IngredientModel>> getIngredients();
  Future<IngredientModel> addIngredient(IngredientModel ingredient);
  Future<IngredientModel> updateIngredient(IngredientModel ingredient);
  Future<void> deleteIngredient(String id);
  Future<List<IngredientModel>> getNearExpiryIngredients();
  Future<void> clearAllIngredients();
}

class IngredientFirebaseDataSourceImpl implements IngredientFirebaseDataSource {
  // เปลี่ยนจาก FirebaseFirestore เป็น dynamic เพื่อรองรับทั้ง Firebase จริงและ mock
  final dynamic firestore;
  final String userUid;
  final List<IngredientModel> _mockIngredients = [];

  IngredientFirebaseDataSourceImpl({
    required this.firestore,
    required this.userUid,
  });

  @override
  Future<List<IngredientModel>> getIngredients() async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data แต่ไม่เพิ่มข้อมูลตัวอย่างโดยอัตโนมัติ
        return Future.delayed(
          const Duration(milliseconds: 500),
          () => _mockIngredients,
        );
      }

      final snapshot =
          await firestore
              .collection(AppConstants.ingredientsCollection)
              .doc(userUid)
              .collection('items')
              .get();

      return snapshot.docs
          .map((doc) => IngredientModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error in getIngredients: $e');
      // ในกรณีที่เกิดข้อผิดพลาด ให้คืนรายการว่าง
      return [];
    }
  }

  @override
  Future<IngredientModel> addIngredient(IngredientModel ingredient) async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data
        await Future.delayed(const Duration(milliseconds: 300));
        _mockIngredients.add(ingredient);
        return ingredient;
      }

      await firestore
          .collection(AppConstants.ingredientsCollection)
          .doc(userUid)
          .collection('items')
          .doc(ingredient.id)
          .set(ingredient.toJson());

      return ingredient;
    } catch (e) {
      print('Error in addIngredient: $e');
      rethrow;
    }
  }

  @override
  Future<IngredientModel> updateIngredient(IngredientModel ingredient) async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data
        await Future.delayed(const Duration(milliseconds: 300));
        final index = _mockIngredients.indexWhere((i) => i.id == ingredient.id);
        if (index >= 0) {
          _mockIngredients[index] = ingredient;
        }
        return ingredient;
      }

      await firestore
          .collection(AppConstants.ingredientsCollection)
          .doc(userUid)
          .collection('items')
          .doc(ingredient.id)
          .update(ingredient.toJson());

      return ingredient;
    } catch (e) {
      print('Error in updateIngredient: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteIngredient(String id) async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data
        await Future.delayed(const Duration(milliseconds: 300));
        _mockIngredients.removeWhere((i) => i.id == id);
        return;
      }

      await firestore
          .collection(AppConstants.ingredientsCollection)
          .doc(userUid)
          .collection('items')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error in deleteIngredient: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllIngredients() async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ลบข้อมูลทั้งหมดจาก mock
        _mockIngredients.clear();
        return;
      }

      // ในโหมด Production ลบข้อมูลทั้งหมดจาก Firebase
      final snapshot =
          await firestore
              .collection(AppConstants.ingredientsCollection)
              .doc(userUid)
              .collection('items')
              .get();

      final batch = firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error in clearAllIngredients: $e');
      rethrow;
    }
  }

  @override
  Future<List<IngredientModel>> getNearExpiryIngredients() async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

        return Future.delayed(
          const Duration(milliseconds: 300),
          () =>
              _mockIngredients.where((ingredient) {
                if (ingredient.expiryDate == null) return false;
                return ingredient.expiryDate!.isAfter(now) &&
                    ingredient.expiryDate!.isBefore(tomorrow);
              }).toList(),
        );
      }

      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

      final snapshot =
          await firestore
              .collection(AppConstants.ingredientsCollection)
              .doc(userUid)
              .collection('items')
              .get();

      final allIngredients =
          snapshot.docs
              .map((doc) => IngredientModel.fromJson(doc.data()))
              .toList();

      return allIngredients.where((ingredient) {
        if (ingredient.expiryDate == null) return false;
        return ingredient.expiryDate!.isAfter(now) &&
            ingredient.expiryDate!.isBefore(tomorrow);
      }).toList();
    } catch (e) {
      print('Error in getNearExpiryIngredients: $e');
      return [];
    }
  }
}
