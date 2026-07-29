import 'dart:js' as js;
import 'package:js/js.dart';
import 'package:ocr_mrz/models/scan_result.dart';

@JS('window.firebase')
external dynamic getFirebase();

class FirebaseService {
  dynamic get _auth => getFirebase()['auth']();
  dynamic get _firestore => getFirebase()['firestore']();

  Future<String?> get currentUid async {
    try {
      final user = await _promise(_auth.currentUser);
      return user != null ? user['uid'] as String? : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> initialize() async {
    try {
      await _promise(_auth.signInAnonymously());
    } catch (e) {
      // may already be signed in
    }
  }

  Future<void> saveScanResult(ScanResult result) async {
    try {
      final uid = await currentUid;
      if (uid == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('scans')
          .doc(result.id);

      await _jsPromise(docRef.set(result.toMap()));
    } catch (e) {
      // swallow to avoid blocking UI
    }
  }

  Future<List<ScanResult>> loadScanHistory() async {
    try {
      final uid = await currentUid;
      if (uid == null) return [];

      final snapshot = await _jsPromise(_firestore
          .collection('users')
          .doc(uid)
          .collection('scans')
          .orderBy('scannedAt', descending: true)
          .get());

      final docs = snapshot['docs'] as List;
      return docs.map((doc) {
        final data = doc['data']();
        return ScanResult.fromMap(Map<String, dynamic>.from(data));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<T> _jsPromise<T>(dynamic promise) {
    final completer = js.context.callMethod('Promise').callMethod('resolve', [null]);
    promise.then(js.allowInterop((dynamic result) {
      completer.callMethod('resolve', [result]);
    }), js.allowInterop((dynamic error) {
      completer.callMethod('reject', [error]);
    }));
    return completer.callMethod('toDart');
  }
}
