import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

class HealthConnectViewModel extends ChangeNotifier {
  final Health _health = Health();

  // Native channel (Android only)
  static const MethodChannel _hcChannel =
  MethodChannel('health_connect_permissions');

  List<HealthDataPoint> _healthDataList = [];
  bool _isAuthorized = false;
  bool _isLoading = false;
  int _steps = 0;

  List<HealthDataPoint> get healthDataList => _healthDataList;
  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;
  int get steps => _steps;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  static const _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_GLUCOSE,
  ];

  static const _permissions = <HealthDataAccess>[
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  HealthConnectViewModel() {
    _logPlatform();
  }

  void _logPlatform() {
    if (!_isAndroid) {
      debugPrint('Health Connect not supported on this platform');
    } else {
      debugPrint('Android detected — using Health Connect');
    }
  }

  /// Calls your Android native code to launch the Health Connect permission UI.
  /// IMPORTANT: This will still fail/close instantly if your Manifest does NOT
  /// declare the rationale activity + alias correctly.
  Future<bool> _requestNativeHealthConnectPermissions() async {
    if (!_isAndroid) return false;

    try {
      final granted = await _hcChannel.invokeMethod<bool>(
        'requestHealthConnectPermissions',
        {
          // Pass full Android permission strings (safe + explicit)
          'permissions': <String>[
            'android.permission.health.READ_STEPS',
            'android.permission.health.READ_HEART_RATE',
            'android.permission.health.READ_BLOOD_GLUCOSE',
          ],
        },
      );

      debugPrint('Native Health Connect permissions granted = ${granted == true}');
      return granted == true;
    } on PlatformException catch (e) {
      debugPrint('Native HC permission request failed: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Native HC permission request failed: $e');
      return false;
    }
  }

  /// Call this from UI (button press or initState) to connect to Health Connect.
  Future<void> authorize() async {
    if (!_isAndroid) return;

    try {
      // 1) Verify Health Connect is available (installed / supported)
      final hcAvailable = await _health.isHealthConnectAvailable();
      debugPrint('Health Connect available = $hcAvailable');

      if (hcAvailable != true) {
        _isAuthorized = false;
        notifyListeners();
        return;
      }

      // 2) Check current permission state via plugin
      final hasPerms = await _health.hasPermissions(
        _types,
        permissions: _permissions,
      );

      debugPrint('Health Connect hasPermissions (plugin) = $hasPerms');

      bool granted = hasPerms == true;

      // 3) If missing, do a REAL native permission request first.
      // This is the key step that makes your app appear inside Health Connect.
      if (!granted) {
        granted = await _requestNativeHealthConnectPermissions();

        // Re-check after native flow
        final afterNative = await _health.hasPermissions(
          _types,
          permissions: _permissions,
        );
        debugPrint('Health Connect hasPermissions AFTER native = $afterNative');
        granted = granted && (afterNative == true);
      }

      // 4) Fallback: if native didn’t grant (or you didn’t implement it),
      // try the plugin requestAuthorization (some setups work fine with only this).
      if (!granted) {
        final pluginGranted = await _health.requestAuthorization(
          _types,
          permissions: _permissions,
        );
        debugPrint('Health Connect requestAuthorization (plugin) = $pluginGranted');
        granted = pluginGranted == true;
      }

      _isAuthorized = granted;

      if (_isAuthorized) {
        await fetchData();
      } else {
        debugPrint('Health Connect permissions not granted.');
      }
    } catch (e, st) {
      debugPrint('Authorization error: $e');
      debugPrintStack(stackTrace: st);
      _isAuthorized = false;
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

    try {
      final healthData = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: _types,
      );

      _healthDataList = _health.removeDuplicates(healthData);

      final stepsCount = await _health.getTotalStepsInInterval(yesterday, now);
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
