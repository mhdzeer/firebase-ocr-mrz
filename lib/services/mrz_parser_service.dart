import 'dart:convert';

class MrzParserService {
  Map<String, dynamic>? parsePassport(List<String> lines) {
    try {
      final line1Raw = lines[0].replaceAll(' ', '');
      final line2Raw = lines[1].replaceAll(' ', '');

      final line1 = _normalizeLine(line1Raw, 44);
      final line2 = _normalizeLine(line2Raw, 44);

      final docType = line1.substring(0, 2);
      final countryCode = line1.substring(2, 5);

      final nameRaw = line1.substring(5, 44);
      final nameParts = nameRaw.split('<<').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final parsedLastName = nameParts.isNotEmpty ? _cleanMrzName(nameParts[0]) : '';
      final parsedFirstName = nameParts.length >= 2 ? _cleanMrzName(nameParts.sublist(1).join(' ')) : '';

      final docNumber = line2.substring(0, 9).replaceAll('<', '').trim();
      final nationality = line2.substring(10, 13).replaceAll(RegExp(r'[^A-Z]'), '');
      final birthDateRaw = line2.substring(13, 19);
      final sex = line2.substring(20, 21);
      final expiryDateRaw = line2.substring(21, 27);
      final personalNumber = line2.substring(28, 42).replaceAll(RegExp(r'[^A-Z0-9]'), '').trim();

      return {
        'documentType': 'passport',
        'countryCode': countryCode,
        'lastName': parsedLastName,
        'firstName': parsedFirstName,
        'documentNumber': docNumber,
        'nationality': nationality,
        'birthDate': _formatDate(birthDateRaw),
        'sex': sex == 'M' ? 'male' : sex == 'F' ? 'female' : 'unknown',
        'expirationDate': _formatDate(expiryDateRaw),
        'personalNumber': personalNumber,
      };
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? parseCpr(List<String> lines) {
    try {
      final firstRaw = lines[0].replaceAll(' ', '');
      final secondRaw = lines[1].replaceAll(' ', '');
      final thirdRaw = lines[2].replaceAll(' ', '');

      final first = _normalizeLine(firstRaw, 30);
      final second = _normalizeLine(secondRaw, 30);
      final third = _normalizeLine(thirdRaw, 30);

      final docNumber = first.substring(0, 9).replaceAll('<', '').trim();
      final nationality = first.substring(10, 13).replaceAll(RegExp(r'[^A-Z]'), '');
      final birthDate = first.substring(13, 19);
      final sex = first.substring(20, 21);
      final expiryDate = first.substring(21, 27);

      final lastNameRaw = second.substring(0, 29);
      final lastName = lastNameRaw.split('<<').map((s) => s.trim()).where((s) => s.isNotEmpty).join(' ');
      
      final firstNameRaw = third.substring(0, 29);
      final firstName = firstNameRaw.split('<<').map((s) => s.trim()).where((s) => s.isNotEmpty).join(' ');

      return {
        'documentType': 'cpr',
        'documentNumber': docNumber,
        'nationality': nationality,
        'birthDate': _formatDate(birthDate),
        'sex': sex == 'M' ? 'male' : sex == 'F' ? 'female' : 'unknown',
        'expirationDate': _formatDate(expiryDate),
        'lastName': lastName,
        'firstName': firstName,
      };
    } catch (e) {
      return null;
    }
  }

  String _normalizeLine(String raw, int expectedLength) {
    final cleaned = raw.replaceAll(' ', '');
    if (cleaned.length >= expectedLength) {
      return cleaned.substring(0, expectedLength);
    }
    return cleaned.padRight(expectedLength, '<');
  }

  String _cleanMrzName(String raw) {
    if (raw.isEmpty) return '';
    String cleaned = raw.replaceAll('<', ' ').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    final parts = cleaned.split(' ').where((s) => s.isNotEmpty).toList();
    return parts.map((s) {
      if (s.length <= 3) return s;
      final seen = <String>{};
      final buffer = StringBuffer();
      for (final char in s.split('')) {
        if (!seen.contains(char) || buffer.length == 0) {
          seen.add(char);
          buffer.write(char);
        }
      }
      return buffer.toString();
    }).join(' ');
  }

  String _formatDate(String yymmdd) {
    if (yymmdd.length != 6) return yymmdd;
    final year = int.tryParse(yymmdd.substring(0, 2)) ?? 0;
    final month = int.tryParse(yymmdd.substring(2, 4)) ?? 0;
    final day = int.tryParse(yymmdd.substring(4, 6)) ?? 0;
    if (month < 1 || month > 12 || day < 1 || day > 31) return yymmdd;
    final fullYear = year > 50 ? 1900 + year : 2000 + year;
    return '${fullYear.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? parse(List<String> lines) {
    if (lines.length >= 2) {
      final first = lines[0].replaceAll(' ', '');
      if (first.length >= 41 && first.length <= 47) {
        return parsePassport(lines);
      }
    }
    if (lines.length >= 3) {
      final first = lines[0].replaceAll(' ', '');
      if (first.length >= 27 && first.length <= 33) {
        return parseCpr(lines);
      }
    }
    return null;
  }

  Map<String, dynamic> compareWithVisualText(Map<String, dynamic> mrzData, String fullOcrText) {
    final upperText = fullOcrText.toUpperCase();
    final result = <String, dynamic>{};

    final fieldsToCheck = <String>[];
    if (mrzData['documentType'] == 'passport') {
      fieldsToCheck.addAll([
        'documentNumber', 'nationality', 'birthDate', 'sex', 'expirationDate', 'personalNumber',
        'lastName', 'firstName'
      ]);
    } else {
      fieldsToCheck.addAll([
        'documentNumber', 'nationality', 'birthDate', 'sex', 'expirationDate',
        'lastName', 'firstName'
      ]);
    }

    for (final field in fieldsToCheck) {
      final value = (mrzData[field] ?? '').toString().trim();
      if (value.isEmpty) {
        result[field] = {'found': false, 'confidence': 0.0};
        continue;
      }
      final upperValue = value.toUpperCase();
      final found = upperText.contains(upperValue);
      result[field] = {
        'found': found,
        'confidence': found ? 1.0 : 0.0,
      };
    }

    final matchCount = result.values.where((v) => (v['found'] as bool)).length;
    final totalCount = result.length;
    result['overall'] = {
      'matchedFields': matchCount,
      'totalFields': totalCount,
      'confidence': totalCount > 0 ? matchCount / totalCount : 0.0,
    };

    return result;
  }
}
