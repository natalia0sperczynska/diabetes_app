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

  HealthConnectViewModel() {
    _safeConfigure();
  }

  void _safeConfigure() {
    if (!_isAndroid) {
      if (kDebugMode) {
        print('Health Connect not supported on this platform');
      }
      return;
    }

    _health.configure();
  }

  Future<void> authorize() async {
    if (!_isAndroid) return;

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_GLUCOSE,
    ];

    try {
      final requested = await _health.requestAuthorization(types);

      _isAuthorized = requested;
      if (requested) {
        await fetchData();
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('Authorization error: $e');
        print(st);
      }
    }

    notifyListeners();
  }

  Future<void> fetchData() async {
    if (!_isAndroid || !_isAuthorized) return;

    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final types = [
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
    } catch (e, st) {
      if (kDebugMode) {
        print('Fetch error: $e');
        print(st);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
