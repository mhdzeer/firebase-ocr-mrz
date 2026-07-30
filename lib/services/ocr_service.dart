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

    final cleanedLines = lines.map((line) => line.replaceAll(' ', '')).toList();

    final candidateLines = <String>[];
    for (final line in cleanedLines) {
      final alnumRatio = _alnumRatio(line);
      if (alnumRatio < 0.7) continue;
      final upper = line.toUpperCase();
      if (upper.startsWith('P<') && line.length >= 41 && line.length <= 47) {
        candidateLines.insert(0, line);
      } else if (line.length >= 41 && line.length <= 47) {
        candidateLines.add(line);
      } else if (line.length >= 27 && line.length <= 33) {
        candidateLines.add(line);
      }
    }

    final deduped = <String>[];
    for (final line in candidateLines) {
      if (!deduped.contains(line)) deduped.add(line);
    }
    return deduped;
  }

  double _alnumRatio(String s) {
    if (s.isEmpty) return 0;
    final alnum = s.runes.where((r) => (r >= 48 && r <= 57) || (r >= 65 && r <= 90)).length;
    return alnum / s.length;
  }
}
