import 'dart:js' as js;
import 'package:js/js.dart';

@JS('Tesseract')
class Tesseract {
  external static Future<String> recognize(String imagePathOrBase64);
}

class OcrService {
  Future<String> recognizeText(String imagePathOrBase64) async {
    try {
      final result = await Tesseract.recognize(imagePathOrBase64);
      return result as String;
    } catch (e) {
      return '';
    }
  }

  Future<List<String>> extractMrzLines(String rawText) async {
    if (rawText.isEmpty) return [];
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
}
