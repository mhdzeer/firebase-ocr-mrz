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

      final lastNameRaw = line1.substring(5, 44).replaceAll('<', ' ').trim();
      final nameTokens = lastNameRaw.split(' ').where((s) => s.isNotEmpty).toList();

      Map<String, String> names;
      if (nameTokens.length >= 2) {
        names = {'last': nameTokens[0], 'first': nameTokens.sublist(1).join(' ')};
      } else if (nameTokens.length == 1) {
        names = {'last': nameTokens[0], 'first': ''};
      } else {
        names = {'last': '', 'first': ''};
      }

      final docNumber = line2.substring(0, 9).replaceAll('<', '').trim();
      final nationality = line2.substring(11, 14);
      final birthDateRaw = line2.substring(14, 20);
      final sex = line2.substring(21, 22);
      final expiryDateRaw = line2.substring(22, 28);
      final personalNumber = line2.substring(28, 42).replaceAll(RegExp(r'[^A-Z0-9]'), '').trim();

      return {
        'documentType': 'passport',
        'countryCode': countryCode,
        'lastName': names['last'] ?? '',
        'firstName': names['first'] ?? '',
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
      final nationality = first.substring(11, 14);
      final birthDate = first.substring(14, 20);
      final sex = first.substring(21, 22);
      final expiryDate = first.substring(22, 28);

      final lastName = second.substring(0, 29).replaceAll('<', ' ').trim();
      final firstName = third.substring(0, 29).replaceAll('<', ' ').trim();

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

  String _formatDate(String yymmdd) {
    if (yymmdd.length != 6) return yymmdd;
    final year = int.tryParse(yymmdd.substring(0, 2)) ?? 0;
    final month = int.tryParse(yymmdd.substring(2, 4)) ?? 0;
    final day = int.tryParse(yymmdd.substring(4, 6)) ?? 0;
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
}
