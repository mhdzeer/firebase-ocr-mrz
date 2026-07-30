class ScanResult {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime scannedAt;
  final String? imagePath;
  final String? rawOcrText;
  final Map<String, dynamic>? validation;
  final Map<String, dynamic>? visualExtraction;

  ScanResult({
    required this.id,
    required this.type,
    required this.data,
    required this.scannedAt,
    this.imagePath,
    this.rawOcrText,
    this.validation,
    this.visualExtraction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'scannedAt': scannedAt.toIso8601String(),
      'imagePath': imagePath,
      'rawOcrText': rawOcrText,
      'validation': validation,
      'visualExtraction': visualExtraction,
    };
  }

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      scannedAt: DateTime.parse(map['scannedAt'] ?? DateTime.now().toIso8601String()),
      imagePath: map['imagePath'],
      rawOcrText: map['rawOcrText'],
      validation: map['validation'] != null ? Map<String, dynamic>.from(map['validation']) : null,
      visualExtraction: map['visualExtraction'] != null ? Map<String, dynamic>.from(map['visualExtraction']) : null,
    );
  }
}
