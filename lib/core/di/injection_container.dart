import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/ingredient/data/datasources/ingredient_firebase_datasource.dart';
import '../../features/ingredient/data/datasources/local_ingredient_datasource.dart';
import '../../features/ingredient/data/repositories/ingredient_repository_impl.dart';
import '../../features/ingredient/domain/repositories/ingredient_repository.dart';
import '../../features/ingredient/domain/usecases/add_ingredient_usecase.dart';
import '../../features/ingredient/domain/usecases/clear_ingredients_usecase.dart';
import '../../features/ingredient/domain/usecases/delete_ingredient_usecase.dart';
import '../../features/ingredient/domain/usecases/get_ingredients_usecase.dart';
import '../../features/ingredient/domain/usecases/update_ingredient_usecase.dart';
import '../../features/recipe/data/datasources/recipe_firebase_datasource.dart';
import '../../features/recipe/data/datasources/spoonacular_datasource.dart';
import '../../features/recipe/data/repositories/recipe_repository_impl.dart';
import '../../features/recipe/domain/repositories/recipe_repository.dart';
import '../../features/recipe/domain/usecases/get_recipe_details_usecase.dart';
import '../../features/recipe/domain/usecases/randomize_recipe_usecase.dart';
import '../services/api_service.dart';
import '../services/firebase_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External libraries
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Core services
  sl.registerLazySingleton(() => FirebaseService.firestore);
  sl.registerLazySingleton(() => ApiService.dio);

  // Data sources
  sl.registerLazySingleton<IngredientFirebaseDataSource>(
    () => IngredientFirebaseDataSourceImpl(
      firestore: FirebaseService.firestore,
      userUid: 'default_user', // ควรแทนที่ด้วย ID ผู้ใช้จริงในโปรดักชัน
    ),
  );

  // Local data source
  sl.registerLazySingleton<LocalIngredientDataSource>(
    () => LocalIngredientDataSourceImpl(sharedPreferences: sl()),
  );

  // SpoonacularDataSource - ใช้ implementation จริงเสมอ
  sl.registerLazySingleton<SpoonacularDataSource>(
    () => SpoonacularDataSourceImpl(dio: sl(), apiKey: ApiService.apiKey),
  );

  sl.registerLazySingleton<RecipeFirebaseDataSource>(
    () => RecipeFirebaseDataSourceImpl(
      firestore: FirebaseService.firestore,
      userUid: 'default_user', // ควรแทนที่ด้วย ID ผู้ใช้จริงในโปรดักชัน
    ),
  );

  // Repositories
  sl.registerLazySingleton<IngredientRepository>(
    () => IngredientRepositoryImpl(
      firebaseDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(
      spoonacularDataSource: sl(),
      firebaseDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetIngredientsUseCase(sl()));
  sl.registerLazySingleton(() => AddIngredientUseCase(sl()));
  sl.registerLazySingleton(() => UpdateIngredientUseCase(sl()));
  sl.registerLazySingleton(() => DeleteIngredientUseCase(sl()));
  sl.registerLazySingleton(() => ClearIngredientsUseCase(sl()));
  sl.registerLazySingleton(() => RandomizeRecipeUseCase(sl()));
  sl.registerLazySingleton(() => GetRecipeDetailsUseCase(sl()));
}
