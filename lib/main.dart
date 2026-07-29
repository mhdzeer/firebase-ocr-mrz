import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ocr_mrz/screens/scan_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Sign in anonymously for Firestore access
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      // Auth may not be configured yet
    }
    
  } catch (e) {
    // Firebase may not be configured yet
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MRZ OCR Reader',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const ScanScreen(),
    );
  }
}
