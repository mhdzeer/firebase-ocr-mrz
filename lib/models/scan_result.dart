class ScanResult {
  final String id;
  final String type; // 'passport' or 'cpr'
  final Map<String, dynamic> data;
  final DateTime scannedAt;
  final String? imagePath;

  ScanResult({
    required this.id,
    required this.type,
    required this.data,
    required this.scannedAt,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'scannedAt': scannedAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      scannedAt: DateTime.parse(map['scannedAt'] ?? DateTime.now().toIso8601String()),
      imagePath: map['imagePath'],
    );
  }
}
