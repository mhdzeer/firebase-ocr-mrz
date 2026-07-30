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
        .map((line) => line.trim().toUpperCase())
        .where((line) => line.isNotEmpty)
        .toList();

    final cleanedLines = lines.map((line) => line.replaceAll(' ', '')).toList();

    final passportCandidates = <String>[];
    final idCandidates = <String>[];
    final otherCandidates = <String>[];

    for (final line in cleanedLines) {
      final alnumRatio = _alnumRatio(line);
      if (alnumRatio < 0.6) continue;

      if (line.startsWith('P<') && line.length >= 41 && line.length <= 47) {
        passportCandidates.add(line);
      } else if ((line.startsWith('ID') || line.startsWith('I<')) && line.length >= 25 && line.length <= 35) {
        idCandidates.add(line);
      } else if (line.length >= 41 && line.length <= 47) {
        otherCandidates.add(line);
      } else if (line.length >= 25 && line.length <= 35) {
        otherCandidates.add(line);
      }
    }

    final result = <String>[];
    for (final line in passportCandidates) {
      if (!result.contains(line)) result.add(line);
    }
    for (final line in idCandidates) {
      if (!result.contains(line)) result.add(line);
    }
    for (final line in otherCandidates) {
      if (!result.contains(line)) result.add(line);
    }

    return result;
  }

  double _alnumRatio(String s) {
    if (s.isEmpty) return 0;
    final alnum = s.runes.where((r) => (r >= 48 && r <= 57) || (r >= 65 && r <= 90)).length;
    return alnum / s.length;
  }
}
