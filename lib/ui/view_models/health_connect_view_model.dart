import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthConnectViewModel extends ChangeNotifier {
  final Health _health = Health();

  List<HealthDataPoint> _healthDataList = [];
  bool _isAuthorized = false;
  bool _isLoading = false;
  int _steps = 0;

  List<HealthDataPoint> get healthDataList => _healthDataList;
  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  int get steps => _steps;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static const bool _devMode = true;

  HealthConnectViewModel() {
    _logPlatform();
  }

  void _logPlatform() {
    if (!_isAndroid) {
      debugPrint('Health Connect not supported on this platform');
    } else if (_devMode) {
      debugPrint('DEV MODE: Android emulator – skipping HC permissions');
    } else {
      debugPrint('Android detected — Health Connect (production mode)');
    }
  }

  /// DEV MODE authorization - no permission UI
  Future<void> authorize() async {
    if (!_isAndroid) return;

    if (_devMode) {
      // Emulator workaround: assume authorized
      _isAuthorized = true;
      debugPrint('DEV MODE: Authorization bypassed');
      await fetchData();
      notifyListeners();
      return;
    }

    const types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
    ];

    const permissions = <HealthDataAccess>[
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      final granted = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      debugPrint('Health Connect hasPermissions = $granted');

      _isAuthorized = granted == true;

      if (_isAuthorized) {
        await fetchData();
      } else {
        debugPrint('Health Connect permissions not granted');
      }
    } catch (e, st) {
      debugPrint('Authorization error: $e');
      debugPrintStack(stackTrace: st);
    }

    notifyListeners();
  }

  /// Fetch health data (last 24h)
  Future<void> fetchData() async {
    if (!_isAndroid || !_isAuthorized) return;

    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    const types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
    ];

    try {
      final healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: types,
      );

      _healthDataList = _health.removeDuplicates(healthData);

      final stepsCount =
      await _health.getTotalStepsInInterval(yesterday, now);

      _steps = stepsCount ?? 0;

      debugPrint('Health data points: ${_healthDataList.length}');
      debugPrint('Steps (last 24h): $_steps');
    } catch (e, st) {
      debugPrint('Fetch error: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
