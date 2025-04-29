import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../config/firebase_options.dart';

class FirebaseService {
  static FirebaseFirestore? _firestoreInstance;

  static Future<void> initialize() async {
    // เชื่อมต่อกับ Firebase จริง
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firestoreInstance = FirebaseFirestore.instance;
  }

  static FirebaseFirestore get firestore {
    if (_firestoreInstance == null) {
      throw StateError(
        'Firebase has not been initialized. '
        'Call FirebaseService.initialize() first.',
      );
    }

    return _firestoreInstance!;
  }
}
