import 'dart:convert';

class MrzParserService {
  Map<String, dynamic>? parsePassport(List<String> lines) {
    try {
      final line1Raw = lines[0].replaceAll(' ', '');
      final line2Raw = lines[1].replaceAll(' ', '');

      if (line1Raw.length < 41 || line1Raw.length > 47) return null;
      if (line2Raw.length < 41 || line2Raw.length > 47) return null;

      final line1 = line1Raw.padRight(44, '<').substring(0, 44);
      final line2 = line2Raw.padRight(44, '<').substring(0, 44);

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
      final sex = line2.substring(20, 21);
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
      final firstRaw = lines[0].replaceAll(' ', '');
      final secondRaw = lines[1].replaceAll(' ', '');
      final thirdRaw = lines[2].replaceAll(' ', '');

      if (firstRaw.length < 27 || firstRaw.length > 33) return null;
      if (secondRaw.length < 27 || secondRaw.length > 33) return null;
      if (thirdRaw.length < 27 || thirdRaw.length > 33) return null;

      final first = firstRaw.padRight(30, '<').substring(0, 30);
      final second = secondRaw.padRight(30, '<').substring(0, 30);
      final third = thirdRaw.padRight(30, '<').substring(0, 30);

      final docNumber = first.substring(0, 9);
      final nationality = first.substring(10, 13);
      final birthDate = first.substring(13, 19);
      final sex = first.substring(20, 21);
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
