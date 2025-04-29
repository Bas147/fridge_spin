import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/firebase_service.dart';
import 'features/ingredient/presentation/providers/ingredient_provider.dart';
import 'features/ingredient/presentation/screens/home_screen.dart';

void main() async {
  // Must be called before using other native code
  WidgetsFlutterBinding.ensureInitialized();

  // Display startup messages
  debugPrint('Starting application...');

  // Try to initialize Firebase
  try {
    debugPrint('Initializing Firebase...');
    await FirebaseService.initialize();
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // When running on emulator or test environment
    // Don't crash the app if Firebase has issues
    if (!kDebugMode) {
      // In production mode, may consider stopping the app
      // rethrow;
    }
  }

  // Initialize dependency injection after Firebase
  try {
    debugPrint('Initializing dependencies...');
    await di.init();
    debugPrint('Dependencies initialized successfully');
  } catch (e) {
    debugPrint('Dependency injection error: $e');
    // Use debugPrint instead of print for better debugging
    if (!kDebugMode) {
      // rethrow;
    }
  }

  // Start the app
  runApp(const ProviderScope(child: FridgeSpinApp()));
}

class FridgeSpinApp extends ConsumerStatefulWidget {
  const FridgeSpinApp({super.key});

  @override
  FridgeSpinAppState createState() => FridgeSpinAppState();
}

class FridgeSpinAppState extends ConsumerState<FridgeSpinApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Call async method after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Load existing ingredients from local storage
      final ingredientNotifier = ref.read(ingredientProvider.notifier);
      await ingredientNotifier.loadIngredients();
      debugPrint('Successfully loaded ingredients from local storage');

      // Update initialization status
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('Error loading ingredients: $e');
      // Even with errors, consider initialization complete
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while waiting for initialization
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading application data...'),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'FridgeSpin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Show the main home screen
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
