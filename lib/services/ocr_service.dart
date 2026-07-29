import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _recognizer.processImage(inputImage);
    return recognizedText.text;
  }

  Future<List<String>> extractMrzLines(String rawText) async {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final mrzLines = lines.where((line) {
      final cleaned = line.replaceAll(' ', '');
      if (cleaned.length == 44) return true;
      if (cleaned.length == 30) return true;
      return false;
    }).toList();

    return mrzLines;
  }

  void dispose() {
    _recognizer.close();
  }
}
