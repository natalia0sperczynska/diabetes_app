import 'package:http/http.dart' as http;
import 'dart:convert';

class DexcomService {
  // URL funkcji po deployu (CHYBA JEŻELI DOBRZE ROZUMIEM)
  static const String _functionUrl =
      'https://us-central1-diabetes-app-81f7d.cloudfunctions.net/get_glucose';
  static const String _functionUrl_get_last =
      'https://us-central1-diabetes-app-81f7d.cloudfunctions.net/get_last_glucose_measurement';

  /// W TEORII pobiera odczyt z DEXCOMA
  ///
  /// Przykład:
  ///
  /// final result = await DexcomService.getCurrentGlucose(
  ///   username: 'email Ani',
  ///   password: 'hasło Ani'
  /// );
  ///
  /// if (result['success']) {
  ///   print('Glucose: ${result['value']} mg/dL');
  /// } else {
  ///   print('Error: ${result['error']}');
  /// }
  ///
  static Future<Map<String, dynamic>> getCurrentGlucose({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrl_get_last),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {
            'success': true,
            'value': data['value'],
            'trend': data['trend'],
            'time': data['time'],
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Invalid response format from server',
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error': error['error'] ?? 'Server error: ${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error - check internet connection',
      };
    }
  }
}
