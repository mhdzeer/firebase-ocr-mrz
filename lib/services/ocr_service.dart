import 'dart:js' as js;
import 'package:js/js.dart';

@JS('Tesseract')
class Tesseract {
  external static Future<String> recognize(String imagePathOrBase64);
}

class OcrService {
  Future<String> recognizeText(dynamic imageInput) async {
    try {
      final result = await Tesseract.recognize(imageInput as String);
      return result as String;
    } catch (e) {
      return '';
    }
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
}
