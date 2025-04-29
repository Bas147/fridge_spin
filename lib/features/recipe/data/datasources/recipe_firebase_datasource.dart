import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/recipe.dart';
import '../models/recipe_model.dart';

abstract class RecipeFirebaseDataSource {
  Future<List<Recipe>> getFavoriteRecipes();
  Future<void> addFavoriteRecipe(RecipeModel recipe);
  Future<void> removeFavoriteRecipe(int recipeId);
}

class RecipeFirebaseDataSourceImpl implements RecipeFirebaseDataSource {
  // เปลี่ยนจาก FirebaseFirestore เป็น dynamic เพื่อรองรับทั้ง Firebase จริงและ mock
  final dynamic firestore;
  final String userUid;
  // ให้เป็นตัวแปรแบบ static เพื่อให้เก็บค่าระหว่างการเรียกเมธอด
  static final List<RecipeModel> _mockFavorites = [];
  // ตัวแปรควบคุมว่าเพิ่มข้อมูลตัวอย่างแล้วหรือยัง
  static bool _hasAddedSampleData = false;

  RecipeFirebaseDataSourceImpl({
    required this.firestore,
    required this.userUid,
  });

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data และเพิ่มข้อมูลตัวอย่างเฉพาะครั้งแรกที่แอปเริ่มทำงาน
        if (!_hasAddedSampleData && _mockFavorites.isEmpty) {
          // เพิ่มข้อมูลตัวอย่าง
          _mockFavorites.add(
            RecipeModel(
              id: 1,
              name: 'สปาเกตตีซอสมะเขือเทศ',
              image: 'https://spoonacular.com/recipeImages/1-556x370.jpg',
              ingredients: ['มะเขือเทศ', 'เส้นสปาเกตตี', 'น้ำมันมะกอก'],
              instructions: ['ต้มน้ำ', 'ใส่เส้น', 'ผัดซอส'],
              cuisine: 'อิตาเลียน',
              servings: 2,
              cookingTimeMinutes: 20,
              isFavorite: true,
            ),
          );
          _hasAddedSampleData = true;
          print('เพิ่มข้อมูลสูตรอาหารตัวอย่างแล้ว');
        }

        print('จำนวนรายการโปรดที่พบ: ${_mockFavorites.length}');
        return List<Recipe>.from(_mockFavorites);
      }

      final snapshot =
          await firestore
              .collection(AppConstants.favoritesCollection)
              .doc(userUid)
              .collection('recipes')
              .get();

      return snapshot.docs
          .map((doc) => RecipeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error in getFavoriteRecipes: $e');
      return [];
    }
  }

  @override
  Future<void> addFavoriteRecipe(RecipeModel recipe) async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data
        if (!_mockFavorites.any((r) => r.id == recipe.id)) {
          _mockFavorites.add(recipe);
          print('เพิ่มสูตร ${recipe.name} เข้ารายการโปรดแล้ว');
        }
        return;
      }

      await firestore
          .collection(AppConstants.favoritesCollection)
          .doc(userUid)
          .collection('recipes')
          .doc(recipe.id.toString())
          .set(recipe.toJson());
    } catch (e) {
      print('Error in addFavoriteRecipe: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFavoriteRecipe(int recipeId) async {
    try {
      if (kDebugMode) {
        // ในโหมด Debug ใช้ mock data
        final length = _mockFavorites.length;
        _mockFavorites.removeWhere((r) => r.id == recipeId);
        print('ลบสูตรอาหาร ID $recipeId จากรายการโปรดแล้ว');
        print('จำนวนรายการโปรดที่เหลือ: ${_mockFavorites.length}');

        // ตรวจสอบว่าการลบสำเร็จหรือไม่
        if (length == _mockFavorites.length) {
          print('ไม่พบสูตรอาหาร ID $recipeId ในรายการโปรด');
        }
        return;
      }

      await firestore
          .collection(AppConstants.favoritesCollection)
          .doc(userUid)
          .collection('recipes')
          .doc(recipeId.toString())
          .delete();
    } catch (e) {
      print('Error in removeFavoriteRecipe: $e');
      rethrow;
    }
  }
}
