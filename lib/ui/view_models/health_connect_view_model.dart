import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthConnectViewModel extends ChangeNotifier {
  List<HealthDataPoint> _healthDataList = [];
  bool _isAuthorized = false;
  bool _isLoading = false;
  int _steps = 0;

  List<HealthDataPoint> get healthDataList => _healthDataList;
  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  int get steps => _steps;

  // Configure Health to use Health Connect on Android
  final Health _health = Health();

  HealthConnectViewModel() {
     _health.configure();
  }

  Future<void> authorize() async {
    // Define the types to get
    var types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
    ];
    
    try {
      // Check if we have permissions
      // bool hasPermissions = await _health.hasPermissions(types) ?? false;
      
      // Request authorization
      bool requested = await _health.requestAuthorization(types);
      
      if (requested) {
        _isAuthorized = true;
        fetchData();
      } else {
        _isAuthorized = false;
        if (kDebugMode) {
           print("Authorization denied");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Exception during authorization: $e");
      }
    }
    notifyListeners();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    var types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
    ];

    try {
      // Fetch data
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: types,
      );
      
      // Remove duplicates
      _healthDataList = _health.removeDuplicates(healthData);

      // Calculate total steps
      _steps = 0;
      
      // Use getTotalStepsInInterval
      int? stepsCount = await _health.getTotalStepsInInterval(yesterday, now);
      if (stepsCount != null) {
        _steps = stepsCount;
      }

    } catch (e) {
      if (kDebugMode) {
        print("Error fetching health data: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
