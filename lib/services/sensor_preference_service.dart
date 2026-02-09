import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the available CGM sensor types
enum SensorType {
  none,
  dexcom,
  libre,
}

/// Service to manage user's preferred CGM sensor type
class SensorPreferenceService {
  static const String _sensorTypeKey = 'selected_sensor_type';

  /// Get the currently selected sensor type
  static Future<SensorType> getSensorType() async {
    final prefs = await SharedPreferences.getInstance();
    final sensorString = prefs.getString(_sensorTypeKey);
    
    switch (sensorString) {
      case 'dexcom':
        return SensorType.dexcom;
      case 'libre':
        return SensorType.libre;
      default:
        return SensorType.none;
    }
  }

  /// Save the selected sensor type
  static Future<void> setSensorType(SensorType type) async {
    final prefs = await SharedPreferences.getInstance();
    
    String value;
    switch (type) {
      case SensorType.dexcom:
        value = 'dexcom';
        break;
      case SensorType.libre:
        value = 'libre';
        break;
      case SensorType.none:
        value = 'none';
        break;
    }
    
    await prefs.setString(_sensorTypeKey, value);
  }

  /// Check if user has selected a sensor type
  static Future<bool> hasSensorSelected() async {
    final type = await getSensorType();
    return type != SensorType.none;
  }

  /// Clear sensor preference
  static Future<void> clearSensorType() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sensorTypeKey);
  }

  /// Get display name for sensor type
  static String getDisplayName(SensorType type) {
    switch (type) {
      case SensorType.dexcom:
        return 'Dexcom';
      case SensorType.libre:
        return 'FreeStyle Libre';
      case SensorType.none:
        return 'None';
    }
  }

  /// Get description for sensor type
  static String getDescription(SensorType type) {
    switch (type) {
      case SensorType.dexcom:
        return 'Connect with Dexcom Share';
      case SensorType.libre:
        return 'Connect with LibreLinkUp';
      case SensorType.none:
        return 'No CGM sensor connected';
    }
  }
}
