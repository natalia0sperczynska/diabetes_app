import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

enum HealthConnectSource {
  all,
  googleFit,
  miFitness,
}

// Origins
const String _kGoogleFitPackage = 'com.google.android.apps.fitness';

// Xiaomi/Mi ecosystem can have multiple origins depending on region/app version.
const List<String> _kMiFitnessPackages = <String>[
  'com.xiaomi.wearable',     // Mi Fitness (common)
  'com.xiaomi.hm.health',    // legacy Mi Fit / Zepp Life (sometimes)
  'com.mi.health',           // Xiaomi Health (sometimes)
];

class HourlySteps {
  final DateTime hourStart; // truncated to the hour
  final int steps;
  const HourlySteps({required this.hourStart, required this.steps});
}

class HrSample {
  final DateTime time;
  final double bpm;
  const HrSample({required this.time, required this.bpm});
}

class HealthConnectViewModel extends ChangeNotifier {
  final Health _health = Health();
  final HealthConnectSource source;

  static const MethodChannel _hcChannel =
  MethodChannel('health_connect_permissions');

  List<HealthDataAccess> _readPermsFor(List<HealthDataType> types) =>
      List<HealthDataAccess>.filled(types.length, HealthDataAccess.READ);

  // Base scope (safe / non-sensitive): steps only.
  static const List<HealthDataType> _baseTypes = <HealthDataType>[
    HealthDataType.STEPS,
  ];

  // Extra types for Mi Fitness dashboard.
  // EXERCISE_TIME removed due to “Datatype … not found in HC” on some builds.
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
  double? _latestHeartRateBpm; // latest from plugin points (may be null)
  double? _latestBloodOxygenPercent;
  bool _hasAdditionalPermissions = false;

  // NEW: HR series for chart (from native Health Connect read HeartRateRecord)
  List<HrSample> _hrSeries = const <HrSample>[];
  List<HrSample> get hrSeries => _hrSeries;

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

  String? get _sourcePackageSingle {
    switch (source) {
      case HealthConnectSource.googleFit:
        return _kGoogleFitPackage;
      case HealthConnectSource.miFitness:
      // NOTE: We filter Mi by multiple packages; this is used only by simple callers.
        return _kMiFitnessPackages.first;
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
      await fetchMiHeartRateSeriesLast24h(); // NEW
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
        await fetchMiHeartRateSeriesLast24h(); // NEW
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

  /// Native request for minimal permission (READ_STEPS) via Kotlin handler.
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
          await fetchMiHeartRateSeriesLast24h(); // NEW
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

      // Moving minutes from step points (already filtered by source)
      _movingMinutes = _movingMinutesFromSteps(_healthDataList);

      // Sleep: main sleep (longest merged interval)
      _sleepDuration = _bestSleepSessionDuration(filtered);

      // Latest HR from plugin points (often null with Mi Fitness)
      _latestHeartRateBpm = _latestValueByDateFrom(filtered, HealthDataType.HEART_RATE);

      _latestBloodOxygenPercent =
          _normalizeSpo2(_latestValueByDateFrom(filtered, HealthDataType.BLOOD_OXYGEN));

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

  /// NEW: Fetch HR series (HeartRateRecord samples) via native HC read.
  /// This is what you need for the chart like Mi Fitness.
  Future<void> fetchMiHeartRateSeriesLast24h() async {
    if (!_isAndroid || !_isMiFitness || !_hasAdditionalPermissions) {
      _hrSeries = const <HrSample>[];
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 24));

    try {
      final raw = await _hcChannel.invokeMethod<List<dynamic>>(
        'readHeartRateSeries',
        <String, dynamic>{
          'startMillis': start.millisecondsSinceEpoch,
          'endMillis': now.millisecondsSinceEpoch,
          'allowedPackages': _kMiFitnessPackages,
        },
      );

      final samples = <HrSample>[];

      if (raw != null) {
        for (final item in raw) {
          if (item is Map) {
            final t = item['t'];
            final bpm = item['bpm'];
            if (t is int && (bpm is num)) {
              samples.add(
                HrSample(
                  time: DateTime.fromMillisecondsSinceEpoch(t),
                  bpm: bpm.toDouble(),
                ),
              );
            }
          }
        }
      }

      samples.sort((a, b) => a.time.compareTo(b.time));
      _hrSeries = samples;

      // Optional: if plugin HR is null, set latest from series
      if (_latestHeartRateBpm == null && _hrSeries.isNotEmpty) {
        _latestHeartRateBpm = _hrSeries.last.bpm;
      }

      notifyListeners();
    } on PlatformException catch (e, st) {
      debugPrint('fetchMiHeartRateSeriesLast24h PlatformException: $e');
      debugPrintStack(stackTrace: st);
      _hrSeries = const <HrSample>[];
      notifyListeners();
    } catch (e, st) {
      debugPrint('fetchMiHeartRateSeriesLast24h error: $e');
      debugPrintStack(stackTrace: st);
      _hrSeries = const <HrSample>[];
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

  int _movingMinutesFromSteps(List<HealthDataPoint> stepPoints) {
    final activeMinutes = <DateTime>{};

    for (final p in stepPoints) {
      if (p.type != HealthDataType.STEPS) continue;
      final s = _asIntSteps(p.value);
      if (s <= 0) continue;

      DateTime t = p.dateFrom;
      while (t.isBefore(p.dateTo)) {
        activeMinutes.add(DateTime(t.year, t.month, t.day, t.hour, t.minute));
        if (activeMinutes.length >= 24 * 60) break;
        t = t.add(const Duration(minutes: 1));
      }
      if (activeMinutes.length >= 24 * 60) break;
    }

    return activeMinutes.length;
  }

  Duration _bestSleepSessionDuration(List<HealthDataPoint> points) {
    final sessions =
    points.where((p) => p.type == HealthDataType.SLEEP_SESSION).toList();

    final intervals = <_Interval>[];

    if (sessions.isNotEmpty) {
      for (final p in sessions) {
        intervals.add(_Interval(p.dateFrom, p.dateTo));
      }
    } else {
      const stageTypes = <HealthDataType>{
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
      };
      for (final p in points) {
        if (!stageTypes.contains(p.type)) continue;
        intervals.add(_Interval(p.dateFrom, p.dateTo));
      }
    }

    if (intervals.isEmpty) return Duration.zero;

    intervals.sort((a, b) => a.start.compareTo(b.start));

    final merged = <_Interval>[];
    var cur = intervals.first;

    for (int i = 1; i < intervals.length; i++) {
      final it = intervals[i];
      if (!it.start.isAfter(cur.end)) {
        final newEnd = it.end.isAfter(cur.end) ? it.end : cur.end;
        cur = _Interval(cur.start, newEnd);
      } else {
        merged.add(cur);
        cur = it;
      }
    }
    merged.add(cur);

    Duration best = Duration.zero;
    for (final m in merged) {
      final d = m.end.difference(m.start);
      if (d > best) best = d;
    }

    if (best > const Duration(hours: 24)) return const Duration(hours: 24);
    return best;
  }

  double? _latestValueByDateFrom(List<HealthDataPoint> points, HealthDataType type) {
    HealthDataPoint? latest;
    for (final p in points) {
      if (p.type != type) continue;
      if (latest == null || p.dateFrom.isAfter(latest.dateFrom)) {
        latest = p;
      }
    }
    if (latest == null) return null;
    return _asDouble(latest.value);
  }

  double? _normalizeSpo2(double? v) {
    if (v == null) return null;
    if (v <= 1.2) return v * 100.0;
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
    if (source == HealthConnectSource.all) return points;

    if (source == HealthConnectSource.googleFit) {
      return points.where((p) => _matchesSource(p, _kGoogleFitPackage)).toList(growable: false);
    }

    // Mi Fitness: accept multiple known Xiaomi origins
    return points.where((p) {
      for (final pkg in _kMiFitnessPackages) {
        if (_matchesSource(p, pkg)) return true;
      }
      // fallback heuristic by name (still Xiaomi)
      final name = (_getSourceName(p) ?? '').toLowerCase();
      if (name.contains('mi') && name.contains('fitness')) return true;
      if (name.contains('xiaomi')) return true;
      if (name.contains('wear')) return true;
      if (name.contains('zepp')) return true;
      return false;
    }).toList(growable: false);
  }

  bool _matchesSource(HealthDataPoint p, String pkg) {
    final id = (_getSourceId(p) ?? '').toLowerCase();
    final target = pkg.toLowerCase();

    if (id == target) return true;
    if (id.startsWith('$target:')) return true;
    if (id.startsWith(target)) return true;

    final name = (_getSourceName(p) ?? '').toLowerCase();
    if (target == _kGoogleFitPackage) {
      return name.contains('google') && name.contains('fit');
    }
    // Xiaomi handled outside (multiple pkgs), but keep basic heuristics
    if (name.contains('mi') && name.contains('fitness')) return true;
    if (name.contains('xiaomi')) return true;
    if (name.contains('wear')) return true;

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

    _hrSeries = const <HrSample>[]; // NEW

    notifyListeners();
  }
}

class _Interval {
  final DateTime start;
  final DateTime end;
  _Interval(this.start, this.end);
}
