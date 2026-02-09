import 'package:http/http.dart' as http;
import 'dart:convert';
import 'libre_credentials_service.dart';

class LibreService {
  static const String _baseUrl =
      'https://us-central1-diabetes-app-81f7d.cloudfunctions.net';

  static const String _functionUrlGetGlucose = '$_baseUrl/get_libre_glucose';
  static const String _functionUrlGetHistory = '$_baseUrl/get_libre_glucose_history';
  static const String _functionUrlGetConnections = '$_baseUrl/get_libre_connections';

  /// Get current glucose using saved credentials
  static Future<Map<String, dynamic>> getCurrentGlucoseWithCredentials() async {
    final credentials = await LibreCredentialsService.getCredentials();

    if (credentials == null) {
      return {
        'success': false,
        'error': 'No LibreLinkUp credentials saved. Configure them in settings.',
      };
    }

    return getCurrentGlucose(
      email: credentials.email,
      password: credentials.password,
    );
  }

  static Future<bool> hasCredentials() async {
    return await LibreCredentialsService.hasCredentials();
  }

  /// Get current glucose reading from LibreLinkUp
  static Future<Map<String, dynamic>> getCurrentGlucose({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrlGetGlucose),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'value': data['value'],
          'trend': data['trend'],
          'trendArrow': data['trendArrow'],
          'time': data['time'],
          'isHigh': data['isHigh'],
          'isLow': data['isLow'],
          'patientName': data['patientName'],
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

  /// Get glucose history (graph data) from LibreLinkUp
  static Future<Map<String, dynamic>> getGlucoseHistoryWithCredentials() async {
    final credentials = await LibreCredentialsService.getCredentials();

    if (credentials == null) {
      return {
        'success': false,
        'error': 'No LibreLinkUp credentials saved. Configure them in settings.',
      };
    }

    return getGlucoseHistory(
      email: credentials.email,
      password: credentials.password,
    );
  }

  /// Get glucose history (graph data) from LibreLinkUp
  static Future<Map<String, dynamic>> getGlucoseHistory({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrlGetHistory),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'current': data['current'],
          'history': data['history'],
          'historyCount': data['historyCount'],
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

  /// Get all patient connections from LibreLinkUp
  static Future<Map<String, dynamic>> getConnectionsWithCredentials() async {
    final credentials = await LibreCredentialsService.getCredentials();

    if (credentials == null) {
      return {
        'success': false,
        'error': 'No LibreLinkUp credentials saved. Configure them in settings.',
      };
    }

    return getConnections(
      email: credentials.email,
      password: credentials.password,
    );
  }

  /// Get all patient connections from LibreLinkUp
  static Future<Map<String, dynamic>> getConnections({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_functionUrlGetConnections),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'connections': data['connections'],
          'count': data['count'],
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

  /// Test connection with LibreLinkUp credentials
  static Future<Map<String, dynamic>> testConnection({
    required String email,
    required String password,
  }) async {
    final result = await getCurrentGlucose(email: email, password: password);
    
    if (result['success'] == true) {
      return {
        'success': true,
        'message': 'Connection successful! Found patient: ${result['patientName']}',
        'patientName': result['patientName'],
      };
    } else {
      return {
        'success': false,
        'error': result['error'] ?? 'Failed to connect to LibreLinkUp',
      };
    }
  }
}
