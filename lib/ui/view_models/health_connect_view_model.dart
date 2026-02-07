import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

/// Simple, UI-ready bucket of steps for a single hour.
class HourlySteps {
  final DateTime hourStart; // truncated to the hour
  final int steps;

  const HourlySteps({required this.hourStart, required this.steps});
}

class HealthConnectViewModel extends ChangeNotifier {
  final Health _health = Health();

  // Android native channel for Health Connect permissions
  static const MethodChannel _hcChannel =
  MethodChannel('health_connect_permissions');

  static const List<HealthDataType> _types = <HealthDataType>[
    HealthDataType.STEPS,
  ];

  static const List<HealthDataAccess> _permissions = <HealthDataAccess>[
    HealthDataAccess.READ,
  ];

  bool _isAuthorized = false;
  bool _isLoading = false;

  int _steps = 0;

  // Raw points (still available for debugging / drill-down).
  List<HealthDataPoint> _healthDataList = <HealthDataPoint>[];

  // Aggregated stats for the last 24 hours.
  List<HourlySteps> _hourlySteps = const <HourlySteps>[];
  int _peakHourlySteps = 0;
  DateTime? _peakHourStart;
  int _activeHours = 0;
  double _avgStepsPerHour = 0;

  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;

  /// Total steps in the last 24 hours.
  int get steps => _steps;

  /// Raw Health Connect points (useful for debugging).
  List<HealthDataPoint> get healthDataList => _healthDataList;

  /// Hourly steps buckets for the last 24 hours (oldest -> newest).
  List<HourlySteps> get hourlySteps => _hourlySteps;

  int get peakHourlySteps => _peakHourlySteps;
  DateTime? get peakHourStart => _peakHourStart;
  int get activeHours => _activeHours;

  /// Average steps per hour across the last 24 hours.
  double get avgStepsPerHour => _avgStepsPerHour;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  HealthConnectViewModel() {
    if (_isAndroid) {
      debugPrint('Android detected — using Health Connect');
    } else {
      debugPrint('Not Android — Health Connect not used');
    }
  }

  /// health_screen.dart calls viewModel.authorize()
  Future<void> authorize() async {
    await initHealthConnect();
  }

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
      final points = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: _types,
      );

      _healthDataList = points;

      final total = await _health.getTotalStepsInInterval(start, now);
      _steps = total ?? 0;

      _computeHourlyBuckets(start: start, end: now);

      debugPrint('Health data points: ${_healthDataList.length}');
      debugPrint('Steps (last 24h): $_steps');
    } catch (e, st) {
      debugPrint('fetchStepsLast24h error: $e');
      debugPrintStack(stackTrace: st);
      _healthDataList = <HealthDataPoint>[];
      _steps = 0;
      _hourlySteps = const <HourlySteps>[];
      _peakHourlySteps = 0;
      _peakHourStart = null;
      _activeHours = 0;
      _avgStepsPerHour = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _computeHourlyBuckets({required DateTime start, required DateTime end}) {
    // Create 24 hourly buckets (oldest -> newest), aligned to the hour.
    final startHour = DateTime(start.year, start.month, start.day, start.hour);
    final buckets = <DateTime, int>{};

    for (int i = 0; i < 24; i++) {
      final h = startHour.add(Duration(hours: i));
      buckets[h] = 0;
    }

    // Add points into buckets by their dateFrom hour.
    for (final p in _healthDataList) {
      if (p.type != HealthDataType.STEPS) continue;

      final h = DateTime(
        p.dateFrom.year,
        p.dateFrom.month,
        p.dateFrom.day,
        p.dateFrom.hour,
      );

      if (!buckets.containsKey(h)) continue;

      buckets[h] = (buckets[h] ?? 0) + _asIntSteps(p.value);
    }

    final list = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    _hourlySteps = list
        .map((e) => HourlySteps(hourStart: e.key, steps: e.value))
        .toList(growable: false);

    _peakHourlySteps = 0;
    _peakHourStart = null;
    _activeHours = 0;

    int sum = 0;
    for (final h in _hourlySteps) {
      sum += h.steps;
      if (h.steps > 0) _activeHours += 1;
      if (h.steps > _peakHourlySteps) {
        _peakHourlySteps = h.steps;
        _peakHourStart = h.hourStart;
      }
    }

    _avgStepsPerHour = _hourlySteps.isEmpty ? 0 : (sum / _hourlySteps.length);
  }

  int _asIntSteps(HealthValue value) {
    if (value is NumericHealthValue) {
      return value.numericValue.round();
    }
    // Fallback (rare for steps)
    final raw = value.toString();
    final match = RegExp(r'(-?\d+(\.\d+)?)').firstMatch(raw);
    if (match == null) return 0;
    return double.tryParse(match.group(1)!)?.round() ?? 0;
  }

  void reset() {
    _isAuthorized = false;
    _isLoading = false;
    _steps = 0;
    _healthDataList = <HealthDataPoint>[];
    _hourlySteps = const <HourlySteps>[];
    _peakHourlySteps = 0;
    _peakHourStart = null;
    _activeHours = 0;
    _avgStepsPerHour = 0;
    notifyListeners();
  }
}
