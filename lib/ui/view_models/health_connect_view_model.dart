import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

enum HealthConnectSource {
  all,
  googleFit,
  miFitness,
}

// Known Android package names for Health Connect data origins.
const String _kGoogleFitPackage = 'com.google.android.apps.fitness';
const String _kMiFitnessPackage = 'com.xiaomi.wearable';

class HourlySteps {
  final DateTime hourStart; // truncated to the hour
  final int steps;

  const HourlySteps({required this.hourStart, required this.steps});
}

class HealthConnectViewModel extends ChangeNotifier {
  final Health _health = Health();
  final HealthConnectSource source;

  static const MethodChannel _hcChannel =
  MethodChannel('health_connect_permissions');

  // Plugin requires: permissions list length == types length.
  List<HealthDataAccess> _readPermsFor(List<HealthDataType> types) =>
      List<HealthDataAccess>.filled(types.length, HealthDataAccess.READ);

  /// Base scope (safe / non-sensitive): steps only.
  static const List<HealthDataType> _baseTypes = <HealthDataType>[
    HealthDataType.STEPS,
  ];

  /// Extra types for Mi Fitness dashboard.
  /// NOTE: EXERCISE_TIME removed because on some devices/emulators
  /// Health Connect doesn't expose it and the plugin throws:
  /// "Datatype EXERCISE_TIME not found in HC"
  static const List<HealthDataType> _extraTypes = <HealthDataType>[
    HealthDataType.ACTIVE_ENERGY_BURNED,

    // Sleep
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,

    // Vitals
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
  ];

  bool _isAuthorized = false;
  bool _isLoading = false;

  int _steps = 0;
  List<HealthDataPoint> _healthDataList = <HealthDataPoint>[];

  List<HourlySteps> _hourlySteps = const <HourlySteps>[];
  int _peakHourlySteps = 0;
  DateTime? _peakHourStart;
  int _activeHours = 0;
  double _avgStepsPerHour = 0;

  // Mi dashboard
  int _caloriesKcal = 0;
  int _movingMinutes = 0;
  Duration _sleepDuration = Duration.zero;
  double? _latestHeartRateBpm;
  double? _latestBloodOxygenPercent;
  bool _hasAdditionalPermissions = false;

  bool get isAuthorized => _isAuthorized;
  bool get isLoading => _isLoading;

  int get steps => _steps;
  List<HealthDataPoint> get healthDataList => _healthDataList;

  List<HourlySteps> get hourlySteps => _hourlySteps;
  int get peakHourlySteps => _peakHourlySteps;
  DateTime? get peakHourStart => _peakHourStart;
  int get activeHours => _activeHours;
  double get avgStepsPerHour => _avgStepsPerHour;

  int get caloriesKcal => _caloriesKcal;
  int get movingMinutes => _movingMinutes;
  Duration get sleepDuration => _sleepDuration;
  double? get latestHeartRateBpm => _latestHeartRateBpm;
  double? get latestBloodOxygenPercent => _latestBloodOxygenPercent;
  bool get hasAdditionalPermissions => _hasAdditionalPermissions;

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;
  bool get _isMiFitness => source == HealthConnectSource.miFitness;
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

  HealthConnectViewModel({this.source = HealthConnectSource.all});

  Future<void> authorize() async => initHealthConnect();

  Future<void> fetchData() async {
    await fetchStepsLast24h();
    await _refreshAdditionalPermissionState();
    if (_isMiFitness && _hasAdditionalPermissions) {
      await fetchMiDashboardExtrasLast24h();
    }
  }

  Future<void> _refreshAdditionalPermissionState() async {
    if (!_isAndroid || !_isMiFitness) {
      _hasAdditionalPermissions = false;
      return;
    }

    final ok = (await _health.hasPermissions(
      _extraTypes,
      permissions: _readPermsFor(_extraTypes),
    )) ==
        true;

    _hasAdditionalPermissions = ok;
  }

  /// Called only after explicit user action (Enable in Mi Fitness tab).
  Future<void> requestAdditionalPermissions() async {
    if (!_isAndroid || !_isMiFitness) return;

    _isLoading = true;
    notifyListeners();

    try {
      final granted = await _health.requestAuthorization(
        _extraTypes,
        permissions: _readPermsFor(_extraTypes),
      );

      _hasAdditionalPermissions = granted == true;

      if (_hasAdditionalPermissions && _isAuthorized) {
        await fetchMiDashboardExtrasLast24h();
      }
    } catch (e, st) {
      debugPrint('requestAdditionalPermissions error: $e');
      debugPrintStack(stackTrace: st);
      _hasAdditionalPermissions = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Native request for minimal permission (READ_STEPS) via your Kotlin handler.
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
      return granted == true;
    } on PlatformException catch (e) {
      debugPrint('Native Health Connect permission error: $e');
      return false;
    }
  }

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

      bool hasPerms = (await _health.hasPermissions(
        _baseTypes,
        permissions: _readPermsFor(_baseTypes),
      )) ==
          true;

      debugPrint('Health Connect hasPermissions (base) = $hasPerms');

      if (!hasPerms) {
        await _requestNativeHealthConnectPermissions();

        hasPerms = (await _health.hasPermissions(
          _baseTypes,
          permissions: _readPermsFor(_baseTypes),
        )) ==
            true;

        debugPrint('Health Connect hasPermissions AFTER native = $hasPerms');
      }

      if (!hasPerms) {
        final pluginAuth = await _health.requestAuthorization(
          _baseTypes,
          permissions: _readPermsFor(_baseTypes),
        );

        debugPrint('Health Connect requestAuthorization (base) = $pluginAuth');
        hasPerms = pluginAuth == true;
      }

      _isAuthorized = hasPerms;

      await _refreshAdditionalPermissionState();

      if (_isAuthorized) {
        await fetchStepsLast24h();
        if (_isMiFitness && _hasAdditionalPermissions) {
          await fetchMiDashboardExtrasLast24h();
        }
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
        types: _baseTypes,
      );

      final unique = _dedupe(points);
      final filtered = _filterBySource(unique);
      _healthDataList = filtered;

      if (!isSourceFiltered) {
        final total = await _health.getTotalStepsInInterval(start, now);
        _steps = total ?? 0;
      } else {
        _steps = _sumStepsFromPoints(filtered);
      }

      _computeHourlyBuckets(start: start);
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

  Future<void> fetchMiDashboardExtrasLast24h() async {
    if (!_isAuthorized || !_isMiFitness || !_hasAdditionalPermissions) return;

    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 24));

    try {
      final points = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: _extraTypes,
      );

      final unique = _dedupe(points);
      final filtered = _filterBySource(unique);

      _caloriesKcal = _sumCaloriesKcal(filtered);

      // Moving minutes computed from STEPS points (already filtered by source) —
      // avoids EXERCISE_TIME which is not available everywhere.
      _movingMinutes = _movingMinutesFromSteps(_healthDataList);

      _sleepDuration = _sumSleepDuration(filtered);

      _latestHeartRateBpm = _latestValue(filtered, HealthDataType.HEART_RATE);
      _latestBloodOxygenPercent =
          _normalizeSpo2(_latestValue(filtered, HealthDataType.BLOOD_OXYGEN));

      notifyListeners();
    } catch (e, st) {
      debugPrint('fetchMiDashboardExtrasLast24h error: $e');
      debugPrintStack(stackTrace: st);
      _caloriesKcal = 0;
      _movingMinutes = 0;
      _sleepDuration = Duration.zero;
      _latestHeartRateBpm = null;
      _latestBloodOxygenPercent = null;
      notifyListeners();
    }
  }

  int _sumCaloriesKcal(List<HealthDataPoint> points) {
    double sum = 0;
    for (final p in points) {
      if (p.type != HealthDataType.ACTIVE_ENERGY_BURNED) continue;
      sum += _asDouble(p.value);
    }
    return sum.round();
  }

  /// Approximation: count distinct minutes covered by step records.
  /// Bounded to 24h = 1440 minutes.
  int _movingMinutesFromSteps(List<HealthDataPoint> stepPoints) {
    final activeMinutes = <DateTime>{};

    for (final p in stepPoints) {
      if (p.type != HealthDataType.STEPS) continue;

      // If a point has 0 steps, skip it (common for some providers).
      final s = _asIntSteps(p.value);
      if (s <= 0) continue;

      DateTime t = p.dateFrom;

      // Add minute buckets until dateTo (capped by 24h).
      while (t.isBefore(p.dateTo)) {
        activeMinutes.add(DateTime(t.year, t.month, t.day, t.hour, t.minute));
        if (activeMinutes.length >= 24 * 60) break;
        t = t.add(const Duration(minutes: 1));
      }

      if (activeMinutes.length >= 24 * 60) break;
    }

    return activeMinutes.length;
  }

  Duration _sumSleepDuration(List<HealthDataPoint> points) {
    final sessions = points.where((p) => p.type == HealthDataType.SLEEP_SESSION);
    Duration total = Duration.zero;

    if (sessions.isNotEmpty) {
      for (final p in sessions) {
        total += p.dateTo.difference(p.dateFrom);
      }
      return total;
    }

    const stageTypes = <HealthDataType>{
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
    };

    for (final p in points) {
      if (!stageTypes.contains(p.type)) continue;
      total += p.dateTo.difference(p.dateFrom);
    }
    return total;
  }

  double? _latestValue(List<HealthDataPoint> points, HealthDataType type) {
    HealthDataPoint? latest;
    for (final p in points) {
      if (p.type != type) continue;
      if (latest == null || p.dateTo.isAfter(latest.dateTo)) {
        latest = p;
      }
    }
    if (latest == null) return null;
    return _asDouble(latest.value);
  }

  double? _normalizeSpo2(double? v) {
    if (v == null) return null;
    if (v <= 1.2) return v * 100.0; // normalize 0..1 to %
    return v;
  }

  double _asDouble(HealthValue value) {
    if (value is NumericHealthValue) return value.numericValue.toDouble();
    final raw = value.toString();
    final match = RegExp(r'(-?\d+(\.\d+)?)').firstMatch(raw);
    if (match == null) return 0.0;
    return double.tryParse(match.group(1)!) ?? 0.0;
  }

  List<HealthDataPoint> _dedupe(List<HealthDataPoint> points) {
    final seen = <String>{};
    final out = <HealthDataPoint>[];

    for (final p in points) {
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

    if (id == target) return true;
    if (id.startsWith('$target:')) return true;
    if (id.startsWith(target)) return true;

    final name = (_getSourceName(p) ?? '').toLowerCase();
    if (target == _kGoogleFitPackage) return name.contains('google') && name.contains('fit');
    if (target == _kMiFitnessPackage) {
      return (name.contains('mi') && name.contains('fitness')) ||
          name.contains('xiaomi') ||
          name.contains('wear');
    }
    return false;
  }

  String? _getSourceId(HealthDataPoint p) {
    try {
      final v = (p as dynamic).sourceId;
      return v?.toString();
    } catch (_) {
      return null;
    }
  }

  String? _getSourceName(HealthDataPoint p) {
    try {
      final v = (p as dynamic).sourceName;
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

  void _computeHourlyBuckets({required DateTime start}) {
    final startHour = DateTime(start.year, start.month, start.day, start.hour);
    final buckets = <DateTime, int>{};

    for (int i = 0; i < 24; i++) {
      final h = startHour.add(Duration(hours: i));
      buckets[h] = 0;
    }

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
    if (value is NumericHealthValue) return value.numericValue.round();
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

    _caloriesKcal = 0;
    _movingMinutes = 0;
    _sleepDuration = Duration.zero;
    _latestHeartRateBpm = null;
    _latestBloodOxygenPercent = null;
    _hasAdditionalPermissions = false;

    notifyListeners();
  }
}
