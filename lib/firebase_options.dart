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
    apiKey: 'YOUR-WEB-API-KEY',
    appId: 'YOUR-WEB-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'OCR-MRZ',
    authDomain: 'OCR-MRZ.firebaseapp.com',
    storageBucket: 'OCR-MRZ.appspot.com',
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
