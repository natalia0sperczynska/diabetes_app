import 'package:diabetes_app/services/menstruation_cycle_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum CyclePhase {
  menstruation, // 1-7
  follicular, // 8-13
  ovulation, // 14-16
  luteal, // 17-28 ogolnie one sie nakldaja ale tak jest prosceij
  unknown
}

class CycleViewModel extends ChangeNotifier {
  final MenstrualServiceFirebase _cycleService = MenstrualServiceFirebase();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  List<DateTime> _periodDates = [];
  DateTime? _lastPeriodDate;

  final int _averageCycleLength = 28;

  bool get isLoading => _isLoading;

  List<DateTime> get periodDates => _periodDates;

  int get currentDayOfCycle {
    if (_lastPeriodDate == null) return 0;
    final difference = DateTime.now().difference(_lastPeriodDate!).inDays;
    return difference + 1;
  }

  CyclePhase get currentPhase {
    final day = currentDayOfCycle;
    if (day == 0) return CyclePhase.unknown;
    if (day <= 5) return CyclePhase.menstruation;
    if (day <= 13) return CyclePhase.follicular;
    if (day <= 16) return CyclePhase.ovulation;
    if (day <= _averageCycleLength) return CyclePhase.luteal;
    return CyclePhase.luteal;
  }

  String get phaseName {
    switch (currentPhase) {
      case CyclePhase.menstruation:
        return "Menstruation";
      case CyclePhase.follicular:
        return "Follicular";
      case CyclePhase.ovulation:
        return "Ovulation";
      case CyclePhase.luteal:
        return "Luteal Phase";
      case CyclePhase.unknown:
        return "No Data";
    }
  }

  bool get isHighInsulinResistance {
    return currentPhase == CyclePhase.luteal;
  }

  bool get isSensitivityToInsulin {
    return currentPhase == CyclePhase.follicular;
  }

  Future<void> fetchCycleData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;

    try {
      final dates = await _cycleService.fetchCycleData(user.uid);

      _periodDates = dates;

      if (_periodDates.isNotEmpty) {
        _lastPeriodDate = _periodDates.first;
      }
    } catch (e) {
      print("ViewModel Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logPeriodStart(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final normalizedDate = DateTime(date.year, date.month, date.day, 12);

    if (_periodDates.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day)) {
      return;
    }

    try {
      await _cycleService.logPeriodStart(user.uid, normalizedDate);

      _periodDates.insert(0, normalizedDate);
      _periodDates.sort((a, b) => b.compareTo(a));
      _lastPeriodDate = _periodDates.first;

      notifyListeners();
    } catch (e) {
      print("ViewModel Error: $e");
    }
  }

  Future<void> removeEntry(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _cycleService.removeEntry(user.uid, date);

      _periodDates.removeWhere((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);

      if (_periodDates.isNotEmpty) {
        _lastPeriodDate = _periodDates.first;
      } else {
        _lastPeriodDate = null;
      }

      notifyListeners();
    } catch (e) {
      print("ViewModel Error removing entry: $e");
    }
  }
}
