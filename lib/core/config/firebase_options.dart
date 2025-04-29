import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // ค่าที่อัปเดตสำหรับโปรเจค fridge-spin-MB
    return const FirebaseOptions(
      apiKey:
          'AIzaSyCuTrih4lKlLK4vZnCCi1jZLl-F6LH4aUk', // อัปเดตจาก google-services.json
      appId:
          '1:905251633010:android:308b6251a0116e6dbb0feb', // อัปเดตจาก google-services.json
      messagingSenderId: '905251633010', // อัปเดตจาก google-services.json
      projectId: 'fridge-spin-mb',
      storageBucket: 'fridge-spin-mb.firebasestorage.app',
      authDomain: 'fridge-spin-mb.firebaseapp.com',
    );
  }
}
