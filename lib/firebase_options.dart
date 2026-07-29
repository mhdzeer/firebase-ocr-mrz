import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAW9FAmjDvf3D5JhbOXLY1Bkax96Cbi4JY',
    appId: '1:452665290767:web:937511bc9b015bb0a2337a',
    messagingSenderId: '452665290767',
    projectId: 'ocr-mrz-87733',
    authDomain: 'ocr-mrz-87733.firebaseapp.com',
    storageBucket: 'ocr-mrz-87733.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR-ANDROID-API-KEY',
    appId: '1:XXXXXXXXXX:android:XXXXXXXXXXXXXXXX',
    messagingSenderId: 'XXXXXXXXXX',
    projectId: 'OCR-MRZ',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR-IOS-API-KEY',
    appId: '1:XXXXXXXXXX:ios:XXXXXXXXXXXXXXXX',
    messagingSenderId: 'XXXXXXXXXX',
    projectId: 'OCR-MRZ',
  );
}
