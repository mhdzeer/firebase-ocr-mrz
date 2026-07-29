import 'dart:js_util' as js_util;

class OcrService {
  Future<String> recognizeText(String imagePathOrBase64) async {
    try {
      final tesseract = js_util.getProperty(js_util.globalThis, 'Tesseract');
      if (tesseract == null) return '';
      final promise = js_util.callMethod(tesseract, 'recognize', [imagePathOrBase64]);
      final future = js_util.promiseToFuture(promise);
      final result = await future.timeout(const Duration(seconds: 120));
      final data = js_util.getProperty(result, 'data');
      final text = js_util.getProperty(data, 'text');
      return text?.toString() ?? '';
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
      if (cleaned.length >= 41 && cleaned.length <= 47) return true;
      if (cleaned.length >= 27 && cleaned.length <= 33) return true;
      return false;
    }).toList();

    return mrzLines;
  }
}
