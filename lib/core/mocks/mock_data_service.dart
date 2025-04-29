import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../features/recipe/domain/entities/recipe.dart';
import '../../features/recipe/data/datasources/spoonacular_datasource.dart';
import '../../features/recipe/data/models/recipe_model.dart';

/// บริการจำลองข้อมูลสำหรับการพัฒนา
class MockDataService {
  // จำลอง Firestore สำหรับการพัฒนา
  static FirebaseFirestore get mockFirestore => MockFirestore();
}

/// จำลอง Firestore สำหรับการพัฒนา
class MockFirestore implements FirebaseFirestore {
  MockFirestore();

  @override
  MockCollectionReference<Map<String, dynamic>> collection(String path) {
    return MockCollectionReference(path);
  }

  @override
  Settings get settings => Settings();

  @override
  WriteBatch batch() => throw UnimplementedError();

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> collectionGroup(
    String collectionId,
  ) => throw UnimplementedError();

  @override
  Future<void> disableNetwork() => throw UnimplementedError();

  @override
  Future<void> enableNetwork() => throw UnimplementedError();

  @override
  Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler) =>
      throw UnimplementedError();

  @override
  Future<void> terminate() => throw UnimplementedError();

  @override
  Future<void> waitForPendingWrites() => throw UnimplementedError();

  @override
  FirebaseApp get app => throw UnimplementedError();

  @override
  LoadBundleTask loadBundle(Uint8List bundle) => throw UnimplementedError();

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> namedQueryGet(String name) =>
      throw UnimplementedError();

  @override
  Future<void> clearPersistence() => throw UnimplementedError();

  @override
  bool get isWeb => false;

  @override
  Future<void> setIndexConfiguration(String indexConfiguration) =>
      throw UnimplementedError();

  @override
  Future<void> setLoggingEnabled(bool enabled) => throw UnimplementedError();

  @override
  int get persistentStorageSize => 0;

  @override
  Future<void> useEmulator(String host, int port) => throw UnimplementedError();
}

/// จำลอง Collection Reference
class MockCollectionReference<T extends Object?>
    implements CollectionReference<T> {
  final String path;

  MockCollectionReference(this.path);

  @override
  MockDocumentReference<T> doc(String id) {
    return MockDocumentReference('$path/$id');
  }

  @override
  Future<DocumentReference<T>> add(T data) => throw UnimplementedError();

  @override
  Future<QuerySnapshot<T>> get([GetOptions? options]) =>
      throw UnimplementedError();

  @override
  String get id => path.split('/').last;

  @override
  String get path => this.path;

  @override
  Query<T> endAtDocument(DocumentSnapshot<Object?> documentSnapshot) =>
      throw UnimplementedError();

  @override
  Query<T> endAt(List<Object?> values) => throw UnimplementedError();

  @override
  Query<T> endBefore(List<Object?> values) => throw UnimplementedError();

  @override
  Query<T> endBeforeDocument(DocumentSnapshot<Object?> documentSnapshot) =>
      throw UnimplementedError();

  @override
  Future<QuerySnapshot<T>> getDocuments([GetOptions? options]) =>
      throw UnimplementedError();

  @override
  Query<T> limit(int limit) => throw UnimplementedError();

  @override
  Query<T> limitToLast(int limit) => throw UnimplementedError();

  @override
  Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false}) =>
      throw UnimplementedError();

  @override
  Query<T> orderBy(Object field, {bool descending = false}) =>
      throw UnimplementedError();

  @override
  Query<T> startAfter(List<Object?> values) => throw UnimplementedError();

  @override
  Query<T> startAfterDocument(DocumentSnapshot<Object?> documentSnapshot) =>
      throw UnimplementedError();

  @override
  Query<T> startAt(List<Object?> values) => throw UnimplementedError();

  @override
  Query<T> startAtDocument(DocumentSnapshot<Object?> documentSnapshot) =>
      throw UnimplementedError();

  @override
  Query<T> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    List<Object?>? arrayContainsAny,
    List<Object?>? whereIn,
    List<Object?>? whereNotIn,
    bool? isNull,
  }) => throw UnimplementedError();

  @override
  get parameters => throw UnimplementedError();

  @override
  FirebaseFirestore get firestore => throw UnimplementedError();

  @override
  DocumentReference<T> get parent => throw UnimplementedError();

  @override
  Query<T> withConverter<R extends Object?>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) => throw UnimplementedError();
}

/// จำลอง Document Reference
class MockDocumentReference<T> implements DocumentReference<T> {
  final String path;

  MockDocumentReference(this.path);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    // จำลองการบันทึกข้อมูล
    return Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> update(Map<String, dynamic> data) async {
    // จำลองการอัปเดตข้อมูล
    return Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> delete() async {
    // จำลองการลบข้อมูล
    return Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<DocumentSnapshot<T>> get([GetOptions? options]) async {
    // จำลองการดึงข้อมูล
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => MockDocumentSnapshot(path) as DocumentSnapshot<T>,
    );
  }

  @override
  String get id => path.split('/').last;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      throw UnimplementedError();

  @override
  String get path => this.path;

  @override
  FirebaseFirestore get firestore => throw UnimplementedError();

  @override
  Stream<DocumentSnapshot<T>> snapshots({
    bool includeMetadataChanges = false,
  }) => throw UnimplementedError();

  @override
  DocumentReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) => throw UnimplementedError();

  @override
  CollectionReference<T> get parent => throw UnimplementedError();
}

/// จำลอง Document Snapshot
class MockDocumentSnapshot implements DocumentSnapshot {
  final String path;

  MockDocumentSnapshot(this.path);

  @override
  Map<String, dynamic>? data() {
    // จำลองข้อมูลตาม path
    if (path.contains('ingredients')) {
      return {
        'id': 'mock_ingredient_1',
        'name': 'Tomato',
        'quantity': '500 g',
        'category': 'Vegetable',
      };
    }
    return null;
  }

  @override
  bool exists = true;

  @override
  String get id => path.split('/').last;

  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference get reference => throw UnimplementedError();

  @override
  String get path => this.path;

  @override
  get(Object field) => throw UnimplementedError();
}

/// จำลอง Spoonacular Data Source
class MockSpoonacularDataSourceImpl implements SpoonacularDataSource {
  @override
  Future<RecipeModel> getRandomRecipeByIngredients(
    List<String> ingredients,
  ) async {
    // Mock retrieving random recipe
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => RecipeModel(
        id: 1,
        name: 'Spaghetti with Tomato Sauce',
        image: 'https://spoonacular.com/recipeImages/1-556x370.jpg',
        ingredients: [
          '200 g spaghetti',
          '3 tomatoes',
          '2 cloves garlic',
          '1 tbsp olive oil',
          'salt and pepper to taste',
        ],
        instructions: [
          'Boil water with a pinch of salt',
          'Add spaghetti and cook for 8-10 minutes',
          'In another pan, add olive oil and chopped garlic, sauté until fragrant',
          'Add tomatoes and cook until soft, season with salt and pepper',
          'Mix the sauce with cooked spaghetti, serve hot',
        ],
        cuisine: 'Italian',
        servings: 2,
        cookingTimeMinutes: 20,
      ),
    );
  }

  @override
  Future<RecipeModel> getRecipeById(int id) async {
    // Mock retrieving recipe by ID
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => RecipeModel(
        id: id,
        name: 'Spaghetti with Tomato Sauce',
        image: 'https://spoonacular.com/recipeImages/1-556x370.jpg',
        ingredients: [
          '200 g spaghetti',
          '3 tomatoes',
          '2 cloves garlic',
          '1 tbsp olive oil',
          'salt and pepper to taste',
        ],
        instructions: [
          'Boil water with a pinch of salt',
          'Add spaghetti and cook for 8-10 minutes',
          'In another pan, add olive oil and chopped garlic, sauté until fragrant',
          'Add tomatoes and cook until soft, season with salt and pepper',
          'Mix the sauce with cooked spaghetti, serve hot',
        ],
        cuisine: 'Italian',
        servings: 2,
        cookingTimeMinutes: 20,
      ),
    );
  }
}
