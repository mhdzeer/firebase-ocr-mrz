import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  String? _rawOcrText;
  int? _rawOcrLength;
  List<String> _mrzLines = const [];
  String? _parseResult;

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

      final bytes = await picked.readAsBytes();
      final base64 = base64Encode(bytes);
      final mimeType = _mimeType(picked.name);
      final dataUrl = 'data:$mimeType;base64,$base64';

      setState(() => _previewPath = dataUrl);
      final result = await _processImage(dataUrl);
      if (!mounted) return;
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              scanResult: result,
              imagePath: dataUrl,
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

  String _mimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (ext == 'png') return 'image/png';
    if (ext == 'jpg' || ext == 'jpeg') return 'image/jpeg';
    if (ext == 'gif') return 'image/gif';
    return 'image/jpeg';
  }

  Future<ScanResult?> _processImage(String imagePath) async {
    final ocr = OcrService();
    final mrzParser = MrzParserService();

    final rawText = await ocr.recognizeText(imagePath);
    final trimmed = rawText.trim();
    setState(() {
      _rawOcrText = trimmed.isEmpty ? '(empty)' : trimmed;
      _rawOcrLength = rawText.length;
    });

    final mrzLines = await ocr.extractMrzLines(rawText);
    setState(() => _mrzLines = mrzLines);

    if (mrzLines.isEmpty) {
      setState(() => _parseResult = 'no mrz lines');
      return null;
    }

    final parsed = mrzParser.parse(mrzLines);
    setState(() => _parseResult = parsed == null ? 'parse failed' : 'parsed');

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
              const SizedBox(height: 12),
              if (_rawOcrText != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Raw OCR (${_rawOcrLength ?? 0} chars):', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_rawOcrText!, maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('MRZ lines: ${_mrzLines.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    ..._mrzLines.map((l) => Text('• $l')),
                    const SizedBox(height: 8),
                    Text('Parse: ${_parseResult ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
