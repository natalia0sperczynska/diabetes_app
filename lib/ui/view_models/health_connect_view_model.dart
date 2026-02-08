import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

/// Which data source (origin app) we want to display from Health Connect.
///
/// This does **not** change requested permissions — we still only ask for the
/// same Health Connect READ_* permissions, and then filter the returned points
/// by their data origin (package name / source).
enum HealthConnectSource {
  /// Do not filter by origin app.
  all,

  /// Filter to data written by Google Fit.
  googleFit,

  /// Filter to data written by Mi Fitness (Xiaomi Wear).
  miFitness,
}

// Known Android package names for Health Connect data origins.
// Google Fit (Play Store): com.google.android.apps.fitness
// Mi Fitness (Play Store): com.xiaomi.wearable
const String _kGoogleFitPackage = 'com.google.android.apps.fitness';
const String _kMiFitnessPackage = 'com.xiaomi.wearable';

/// Simple, UI-ready bucket of steps for a single hour.
class HourlySteps {
  final DateTime hourStart; // truncated to the hour
  final int steps;

  const HourlySteps({required this.hourStart, required this.steps});
}

class HealthConnectViewModel extends ChangeNotifier {
  final Health _health = Health();

  /// Selected origin filter.
  final HealthConnectSource source;

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

  /// Backwards-compatible constructor.
  ///
  /// Existing code can keep calling `HealthConnectViewModel()`.
  HealthConnectViewModel({this.source = HealthConnectSource.all}) {
    if (_isAndroid) {
      debugPrint('Android detected — using Health Connect');
    } else {
      debugPrint('Not Android — Health Connect not used');
    }
  }

  /// Human label for the current origin filter.
  String get sourceLabel {
    switch (source) {
      case HealthConnectSource.googleFit:
        return 'Google Fit';
      case HealthConnectSource.miFitness:
        return 'Mi Fitness';
      case HealthConnectSource.all:
        return 'All sources';
    }
  }

  /// Whether we are filtering to a specific origin app.
  bool get isSourceFiltered => source != HealthConnectSource.all;

  String? get _sourcePackage {
    switch (source) {
      case HealthConnectSource.googleFit:
        return _kGoogleFitPackage;
      case HealthConnectSource.miFitness:
        return _kMiFitnessPackage;
      case HealthConnectSource.all:
        return null;
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
      bool hasPerms =
          (await _health.hasPermissions(_types, permissions: _permissions)) ==
              true;
      debugPrint('Health Connect hasPermissions (plugin) = $hasPerms');

      // 2) If missing -> native flow first
      if (!hasPerms) {
        await _requestNativeHealthConnectPermissions();

        hasPerms =
            (await _health.hasPermissions(_types, permissions: _permissions)) ==
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

      // De-duplicate (plugin may return duplicates on some devices/sources).
      final unique = _dedupe(points);

      // Filter by data origin (Google Fit / Mi Fitness) if requested.
      final filtered = _filterBySource(unique);
      _healthDataList = filtered;

      // Total steps:
      // - For "All sources" we keep the existing plugin method (best behaviour).
      // - For a filtered source we sum points because the plugin total cannot be filtered.
      if (!isSourceFiltered) {
        final total = await _health.getTotalStepsInInterval(start, now);
        _steps = total ?? 0;
      } else {
        _steps = _sumStepsFromPoints(filtered);
      }

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

  List<HealthDataPoint> _dedupe(List<HealthDataPoint> points) {
    final seen = <String>{};
    final out = <HealthDataPoint>[];

    for (final p in points) {
      // Key based on timestamps, type, numeric value, and source.
      final sourceId = _getSourceId(p) ?? '';
      final val = p.type == HealthDataType.STEPS
          ? _asIntSteps(p.value)
          : p.value.toString();
      final key =
          '${p.type}|${p.dateFrom.millisecondsSinceEpoch}|${p.dateTo.millisecondsSinceEpoch}|$val|$sourceId';
      if (seen.add(key)) out.add(p);
    }

    return out;
  }

  List<HealthDataPoint> _filterBySource(List<HealthDataPoint> points) {
    final pkg = _sourcePackage;
    if (pkg == null) return points;

    return points.where((p) => _matchesSource(p, pkg)).toList(growable: false);
  }

  bool _matchesSource(HealthDataPoint p, String pkg) {
    final id = (_getSourceId(p) ?? '').toLowerCase();
    final target = pkg.toLowerCase();

    // Common: exact match with package name.
    if (id == target) return true;

    // Some implementations append extra information after ':'
    // e.g. "com.google.android.apps.fitness:..."
    if (id.startsWith('$target:')) return true;

    // Some devices may include a longer prefix; keep it tolerant.
    if (id.startsWith(target)) return true;

    final name = (_getSourceName(p) ?? '').toLowerCase();
    if (target == _kGoogleFitPackage) {
      return name.contains('google') && name.contains('fit');
    }
    if (target == _kMiFitnessPackage) {
      // Mi Fitness is sometimes shown as Xiaomi Wear / Mi Fitness.
      return (name.contains('mi') && name.contains('fitness')) ||
          name.contains('xiaomi') ||
          name.contains('wear');
    }
    return false;
  }

  String? _getSourceId(HealthDataPoint p) {
    // `health` plugin fields differ across versions; use dynamic access safely.
    try {
      final v = (p as dynamic).sourceId;
      if (v is String) return v;
      return v?.toString();
    } catch (_) {
      return null;
    }
  }

  String? _getSourceName(HealthDataPoint p) {
    try {
      final v = (p as dynamic).sourceName;
      if (v is String) return v;
      return v?.toString();
    } catch (_) {
      return null;
    }
  }

  int _sumStepsFromPoints(List<HealthDataPoint> points) {
    int sum = 0;
    for (final p in points) {
      if (p.type != HealthDataType.STEPS) continue;
      sum += _asIntSteps(p.value);
    }
    return sum;
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

    final list = buckets.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

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
