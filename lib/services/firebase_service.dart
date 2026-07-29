import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ocr_mrz/models/scan_result.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> initialize() async {
    await _auth.signInAnonymously();
  }

  Future<void> saveScanResult(ScanResult result) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .doc(result.id)
        .set(result.toMap());
  }

  Future<List<ScanResult>> loadScanHistory() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('scannedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => ScanResult.fromMap(doc.data())).toList();
  }
}
