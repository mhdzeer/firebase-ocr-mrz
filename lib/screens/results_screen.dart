import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ocr_mrz/models/scan_result.dart';
import 'package:ocr_mrz/services/firebase_service.dart';

class ResultsScreen extends StatefulWidget {
  final ScanResult scanResult;
  final String imagePath;

  const ResultsScreen({super.key, required this.scanResult, required this.imagePath});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _saving = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _saveToFirestore();
  }

  Future<void> _saveToFirestore() async {
    final firebase = FirebaseService();
    if (firebase.currentUser == null) {
      try {
        await firebase.initialize();
      } catch (e) {
        setState(() => _status = 'Auth failed: $e');
        return;
      }
    }
    setState(() => _saving = true);
    try {
      await firebase.saveScanResult(widget.scanResult);
      setState(() => _status = 'Saved to Firestore');
    } catch (e) {
      setState(() => _status = 'Save failed: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.scanResult.data;
    final fields = <Widget>[];

    data.forEach((key, value) {
      fields.add(
        ListTile(
          title: Text(_capitalize(key)),
          subtitle: Text(value.toString()),
          leading: const Icon(Icons.info_outline),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.scanResult.type == 'passport' ? 'Passport Result' : 'CPR / ID Result'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_saving) const Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _status ?? (widget.scanResult.type == 'passport' ? 'Passport detected' : 'CPR ID detected'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (widget.imagePath.isNotEmpty)
              Image.file(
                File(widget.imagePath),
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            ...fields,
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
