import 'dart:convert';
import 'package:mrz_parser/mrz_parser.dart';

class MrzParserService {
  Map<String, dynamic>? parsePassport(List<String> lines) {
    try {
      final mrz = MrzParser([lines[0], lines[1]]);
      final doc = mrz.getMrzInfo();
      final birth = doc.birthDate;
      final expiry = doc.expiryDate;
      return {
        'documentType': 'passport',
        'countryCode': doc.countryCode,
        'lastName': doc.surname,
        'firstName': doc.givenNames,
        'documentNumber': doc.documentNumber,
        'nationality': doc.nationality,
        'birthDate': birth != null ? _formatDateMrz(birth) : '',
        'sex': doc.gender?.toString().toLowerCase() ?? '',
        'expirationDate': expiry != null ? _formatDateMrz(expiry) : '',
        'optionalData': doc.optionalData,
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

  String _formatDateMrz(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
