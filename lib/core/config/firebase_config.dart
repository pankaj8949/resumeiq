import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:resumeiq/firebase_options.dart';

/// Firebase configuration and initialization
class FirebaseConfig {
  FirebaseConfig._();

  /// Initialize Firebase for Android and Web using the generated firebase_options.dart file
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (kDebugMode) {
        debugPrint('✅ Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⛔ Firebase initialization failed');
        debugPrint('Error: $e');
      }
      rethrow;
    }
  }
}
