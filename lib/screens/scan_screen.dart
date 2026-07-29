import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
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
  CameraController? _cameraController;
  bool _isProcessing = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorText = 'No cameras available');
        return;
      }
      final rear = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(rear, ResolutionPreset.high);
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _errorText = 'Camera error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndProcess() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorText = null;
    });

    try {
      final file = await _cameraController!.takePicture();
      final result = await _processImage(File(file.path));
      if (!mounted) return;
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              scanResult: result,
              imagePath: file.path,
            ),
          ),
        );
      } else {
        setState(() => _errorText = 'No valid MRZ detected. Please rescan.');
      }
    } catch (e) {
      setState(() => _errorText = 'Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

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
      final result = await _processImage(File(picked.path));
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

  Future<ScanResult?> _processImage(File imageFile) async {
    final ocr = OcrService();
    final mrzParser = MrzParserService();

    final rawText = await ocr.recognizeText(imageFile);
    final mrzLines = await ocr.extractMrzLines(rawText);

    if (mrzLines.isEmpty) return null;

    final parsed = mrzParser.parse(mrzLines);
    if (parsed == null) return null;

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: parsed['documentType'],
      data: parsed,
      scannedAt: DateTime.now(),
      imagePath: imageFile.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? Center(
              child: _errorText != null
                  ? Text(_errorText!)
                  : const CircularProgressIndicator(),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _captureAndProcess,
                        icon: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.camera_alt),
                        label: Text(_isProcessing ? 'Scanning...' : 'Scan'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _pickAndProcess,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (_errorText != null)
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.red,
                      child: Text(_errorText!, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
    );
  }
}
