class AppConstants {
  // App Info
  static const String appName = 'FridgeSpin';

  // API
  static const String spoonacularApiKey = '75fdfd1a86a74dda81f72b3e4f117fb9';
  static const String spoonacularBaseUrl = 'https://api.spoonacular.com';

  // Firestore Collections
  static const String ingredientsCollection = 'ingredients';
  static const String favoritesCollection = 'favorites';

  // Ingredient Categories
  static const List<String> ingredientCategories = [
    'เนื้อสัตว์',
    'ผัก',
    'ผลไม้',
    'นม',
    'แป้ง/ธัญพืช',
    'เครื่องปรุง',
    'อาหารทะเล',
    'เครื่องดื่ม',
    'อื่นๆ',
  ];
}
