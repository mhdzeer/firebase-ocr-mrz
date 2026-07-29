import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAW9FAmjDvf3D5JhbOXLY1Bkax96Cbi4JY',
    appId: '1:452665290767:web:937511bc9b015bb0a2337a',
    messagingSenderId: '452665290767',
    projectId: 'ocr-mrz-87733',
    authDomain: 'ocr-mrz-87733.firebaseapp.com',
    storageBucket: 'ocr-mrz-87733.firebasestorage.app',
  );
}
