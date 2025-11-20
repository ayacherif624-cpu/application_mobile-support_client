// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
/*
Remplacer les valeurs par celles de ton google-services.json :
current_key → apiKey
mobilesdk_app_id → appId
project_id → projectId
storage_bucket → storageBucket
project_number → messagingSenderId*/

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'AIzaSyBy49aQ9OLvkFYtLXL-wXw7tmZ_breLWdU',
    appId: '1:532385170939:android:4072a86e6244b9c339b75e',
    messagingSenderId: '532385170939',
    projectId: 'bc3-eya',
    storageBucket: 'bc3-eya.firebasestorage.app',
  );
}