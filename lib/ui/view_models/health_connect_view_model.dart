import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

class HealthConnectViewModel extends ChangeNotifier {
  final Health _health = Health();

  // Android native channel for Health Connect permissions
  static const MethodChannel _hcChannel =
  MethodChannel('health_connect_permissions');

  // ✅ STEPS ONLY
  static const List<HealthDataType> _types = <HealthDataType>[
    HealthDataType.STEPS,
  ];

  // ✅ STEPS ONLY
  static const List<HealthDataAccess> _permissions = <HealthDataAccess>[
    HealthDataAccess.READ,
  ];

  bool _isAuthorized = false;
  bool _isLoading = false;
  int _steps = 0;
  List<HealthDataPoint> _healthDataList = <HealthDataPoint>[];

  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  int get steps => _steps;
  List<HealthDataPoint> get healthDataList => _healthDataList;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  HealthConnectViewModel() {
    if (_isAndroid) {
      debugPrint('Android detected — using Health Connect');
    } else {
      debugPrint('Not Android — Health Connect not used');
    }
  }

  /// ✅ This keeps your existing UI working:
  /// health_screen.dart calls viewModel.authorize()
  Future<void> authorize() async {
    await initHealthConnect();
  }

  /// ✅ This keeps your existing UI working:
  /// health_screen.dart calls viewModel.fetchData()
  Future<void> fetchData() async {
    await fetchStepsLast24h();
  }

  /// Native Health Connect permission request (Android permission UI).
  Future<bool> _requestNativeHealthConnectPermissions() async {
    if (!_isAndroid) return false;

    try {
      final granted = await _hcChannel.invokeMethod<bool>(
        'requestHealthConnectPermissions',
        <String, dynamic>{
          // ✅ STEPS ONLY
          'permissions': <String>[
            'android.permission.health.READ_STEPS',
          ],
        },
      );

      final ok = granted == true;
      debugPrint('Native Health Connect permissions granted = $ok');
      return ok;
    } on PlatformException catch (e) {
      debugPrint('Native Health Connect permission error: $e');
      return false;
    }
  }

  /// Initialize Health Connect permissions + optionally fetch data.
  Future<void> initHealthConnect() async {
    if (!_isAndroid) return;

    _isLoading = true;
    notifyListeners();

    try {
      final available = await _health.isHealthConnectAvailable();
      debugPrint('Health Connect available = $available');

      if (available != true) {
        _isAuthorized = false;
        return;
      }

      // 1) Check permissions via plugin
      bool hasPerms = (await _health.hasPermissions(
        _types,
        permissions: _permissions,
      )) ==
          true;
      debugPrint('Health Connect hasPermissions (plugin) = $hasPerms');

      // 2) If missing -> native flow first
      if (!hasPerms) {
        await _requestNativeHealthConnectPermissions();

        hasPerms = (await _health.hasPermissions(
          _types,
          permissions: _permissions,
        )) ==
            true;

        debugPrint('Health Connect hasPermissions AFTER native = $hasPerms');
      }

      // 3) If still missing -> plugin requestAuthorization
      if (!hasPerms) {
        final pluginAuth = await _health.requestAuthorization(
          _types,
          permissions: _permissions,
        );
        debugPrint('Health Connect requestAuthorization (plugin) = $pluginAuth');

        hasPerms = pluginAuth == true;
      }

      _isAuthorized = hasPerms;

      if (_isAuthorized) {
        await fetchStepsLast24h();
      }
    } catch (e, st) {
      debugPrint('initHealthConnect error: $e');
      debugPrintStack(stackTrace: st);
      _isAuthorized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch steps for last 24 hours (Steps-only).
  Future<void> fetchStepsLast24h() async {
    if (!_isAuthorized) return;

    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 24));

    try {
      // ✅ Your health package requires NAMED params (0 positional allowed)
      final points = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: _types,
      );

      _healthDataList = points;

      final total = await _health.getTotalStepsInInterval(start, now);
      _steps = total ?? 0;

      debugPrint('Health data points: ${_healthDataList.length}');
      debugPrint('Steps (last 24h): $_steps');
    } catch (e, st) {
      debugPrint('fetchStepsLast24h error: $e');
      debugPrintStack(stackTrace: st);
      _healthDataList = <HealthDataPoint>[];
      _steps = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isAuthorized = false;
    _isLoading = false;
    _steps = 0;
    _healthDataList = <HealthDataPoint>[];
    notifyListeners();
  }
}
