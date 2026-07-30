import 'dart:js_util' as js_util;

class OcrService {
  Future<String> recognizeText(String imagePathOrBase64) async {
    try {
      final fn = js_util.getProperty(js_util.globalThis, 'mrzTesseractRecognize');
      if (fn == null) return '';
      final promise = js_util.callMethod(js_util.globalThis, 'mrzTesseractRecognize', [imagePathOrBase64]);
      final future = js_util.promiseToFuture(promise);
      final result = await future.timeout(const Duration(seconds: 300));
      return result?.toString() ?? '';
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
