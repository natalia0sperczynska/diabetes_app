import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dexcom_credentials_service.dart';

class DexcomService {
  static const String _functionUrlGetLast =
      'https://us-central1-diabetes-app-81f7d.cloudfunctions.net/get_last_glucose_measurement';

  static Future<Map<String, dynamic>> getCurrentGlucoseWithCredentials() async {
    final credentials = await DexcomCredentialsService.getCredentials();

    if (credentials == null) {
      return {
        'success': false,
        'error': 'No Dexcom credentials saved. Configure them in settings.',
      };
    }

    return getCurrentGlucose(
      username: credentials.username,
      password: credentials.password,
      region: credentials.region,
    );
  }

  static Future<bool> hasCredentials() async {
    return await DexcomCredentialsService.hasCredentials();
  }

  static Future<Map<String, dynamic>> getCurrentGlucose({
    required String username,
    required String password,
    String region = 'ous',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrlGetLast),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'region': region,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'value': data['value'],
          'trend': data['trend'],
          'time': data['time'],
          'source': data['source'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error - check internet connection',
      };
    }
  }
}
