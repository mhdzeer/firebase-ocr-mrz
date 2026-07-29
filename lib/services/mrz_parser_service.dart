import 'dart:convert';

class MrzParserService {
  Map<String, dynamic>? parsePassport(List<String> lines) {
    try {
      final line1 = lines[0].replaceAll(' ', '');
      final line2 = lines[1].replaceAll(' ', '');

      if (line1.length != 44 || line2.length != 44) return null;

      final docType = line1.substring(0, 2);
      final countryCode = line1.substring(2, 5);
      final lastNameRaw = line1.substring(5, 44);
      final lastName = lastNameRaw.replaceAll('<', ' ').trim();

      final nameParts = lastName.split(' ').where((s) => s.isNotEmpty).toList();
      final parsedLastName = nameParts.isNotEmpty ? nameParts.removeAt(0) : '';
      final parsedFirstName = nameParts.join(' ');

      final docNumber = line2.substring(0, 9);
      final nationality = line2.substring(10, 13);
      final birthDateRaw = line2.substring(13, 19);
      final sex = line2.substring(20, 1);
      final expiryDateRaw = line2.substring(21, 27);

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
        'optionalData': line2.length > 28 ? line2.substring(28) : '',
      };
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? parseCpr(List<String> lines) {
    try {
      final first = lines[0].replaceAll(' ', '');
      final second = lines[1].replaceAll(' ', '');
      final third = lines[2].replaceAll(' ', '');

      if (first.length != 30 || second.length != 30 || third.length != 30) return null;

      final docNumber = first.substring(0, 9);
      final nationality = first.substring(10, 13);
      final birthDate = first.substring(13, 19);
      final sex = first.substring(20, 1);
      final expiryDate = first.substring(21, 27);

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

  String _formatDate(String yymmdd) {
    if (yymmdd.length != 6) return yymmdd;
    final year = int.tryParse(yymmdd.substring(0, 2)) ?? 0;
    final month = int.tryParse(yymmdd.substring(2, 4)) ?? 0;
    final day = int.tryParse(yymmdd.substring(4, 6)) ?? 0;
    final fullYear = year > 50 ? 1900 + year : 2000 + year;
    return '${fullYear.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic>? parse(List<String> lines) {
    if (lines.length >= 2 && lines[0].replaceAll(' ', '').length == 44) {
      return parsePassport(lines);
    }
    if (lines.length >= 3 && lines[0].replaceAll(' ', '').length == 30) {
      return parseCpr(lines);
    }
    return null;
  }
}
