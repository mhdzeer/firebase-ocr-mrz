import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr_mrz/services/ocr_service.dart';
import 'package:ocr_mrz/services/mrz_parser_service.dart';
import 'package:ocr_mrz/models/scan_result.dart';
import 'package:ocr_mrz/screens/results_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isProcessing = false;
  String? _errorText;
  String? _previewPath;

  Future<void> _pickAndProcess() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _errorText = null;
    });

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        setState(() => _isProcessing = false);
        return;
      }
      setState(() => _previewPath = picked.path);
      final result = await _processImage(picked.path);
      if (!mounted) return;
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              scanResult: result,
              imagePath: picked.path,
            ),
          ),
        );
      } else {
        setState(() => _errorText = 'No valid MRZ detected. Try again.');
      }
    } catch (e) {
      setState(() => _errorText = 'Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<ScanResult?> _processImage(String imagePath) async {
    final ocr = OcrService();
    final mrzParser = MrzParserService();

    final rawText = await ocr.recognizeText(imagePath);
    final mrzLines = await ocr.extractMrzLines(rawText);

    if (mrzLines.isEmpty) return null;

    final parsed = mrzParser.parse(mrzLines);
    if (parsed == null) return null;

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: parsed['documentType'],
      data: parsed,
      scannedAt: DateTime.now(),
      imagePath: imagePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document (Upload Image)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_previewPath != null)
                kIsWeb
                    ? Image.network(_previewPath!, height: 200, fit: BoxFit.cover)
                    : Image.file(File(_previewPath!), height: 200, fit: BoxFit.cover),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _pickAndProcess,
                icon: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.upload_file),
                label: Text(_isProcessing ? 'Scanning...' : 'Select Image'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              ),
              const SizedBox(height: 16),
              if (_errorText != null)
                Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
