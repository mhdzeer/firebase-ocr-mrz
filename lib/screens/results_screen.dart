import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    if (firebase.currentUid == null) {
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
          subtitle: SelectableText(value.toString()),
          leading: const Icon(Icons.info_outline),
        ),
      );
    });

    final validation = widget.scanResult.validation;
    final validationWidgets = <Widget>[];
    if (validation != null && validation['overall'] != null) {
      final overall = validation['overall'] as Map<String, dynamic>;
      final confidence = (overall['confidence'] as double? ?? 0.0);
      final matched = overall['matchedFields'] ?? 0;
      final total = overall['totalFields'] ?? 0;

      validationWidgets.add(
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: confidence > 0.7 ? Colors.green.shade50 : Colors.orange.shade50,
            border: Border.all(color: confidence > 0.7 ? Colors.green : Colors.orange),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(confidence > 0.7 ? Icons.verified : Icons.warning, color: confidence > 0.7 ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Visual Text Match: ${(confidence * 100).toStringAsFixed(0)}% ($matched/$total fields)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );

      validation.forEach((key, value) {
        if (key == 'overall') return;
        final item = value as Map<String, dynamic>;
        final found = item['found'] as bool;
        validationWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                Icon(found ? Icons.check_circle : Icons.cancel, color: found ? Colors.green : Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('${_capitalize(key)} found in visual text')),
              ],
            ),
          ),
        );
      });
    }

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
              Image.network(
                widget.imagePath,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 16),
            if (widget.scanResult.rawOcrText != null && widget.scanResult.rawOcrText!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Visual OCR Text:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SelectableText(widget.scanResult.rawOcrText!, maxLines: 10),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (validationWidgets.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visual Text Validation:', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...validationWidgets,
                  ],
                ),
              ),
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
