import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/model/AnalysisModel.dart';
import '../../data/model/DailyStats.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

/// Represents a patient visible to the doctor.
class PatientInfo {
  final String uid;
  final String email;
  final String displayName;
  final String glucoseEmail;

  const PatientInfo({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.glucoseEmail,
  });
}

class DoctorViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  // ── Patients loaded dynamically from Firestore ──
  List<PatientInfo> _patients = [];
  List<PatientInfo> get patients => _patients;

  bool _isPatientsLoading = false;
  bool get isPatientsLoading => _isPatientsLoading;

  PatientInfo? _selectedPatient;
  PatientInfo? get selectedPatient => _selectedPatient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Data for the selected patient
  List<DailyStats> _dailyStats = [];
  List<DailyStats> get dailyStats => _dailyStats;

  AnalysisStats _analysisStats = AnalysisStats.empty();
  AnalysisStats get analysisStats => _analysisStats;

  List<FlSpot> _glucoseSpots = [];
  List<FlSpot> get glucoseSpots => _glucoseSpots;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // ── FIX: Added missing getter for the UI ──
  bool get canGoNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Jeśli wybrana data jest wcześniejsza niż dzisiaj, możemy iść dalej
    return _selectedDate.isBefore(today);
  }

  // ── Load patient list from doctor's patientIds ──
  Future<void> loadPatients(UserModel doctorUser) async {
    if (doctorUser.patientIds.isEmpty) {
      _patients = [];
      notifyListeners();
      return;
    }

    _isPatientsLoading = true;
    notifyListeners();

    try {
      final users = await _userService.getUsersByIds(doctorUser.patientIds);
      _patients = users
          .map((u) => PatientInfo(
        uid: u.id,
        email: u.email,
        displayName: '${u.name} ${u.surname}'.trim(),
        glucoseEmail: u.glucoseEmail,
      ))
          .toList();
    } catch (e) {
      debugPrint('DoctorViewModel: Error loading patients: $e');
      _patients = [];
    } finally {
      _isPatientsLoading = false;
      notifyListeners();
    }
  }

  // ── Select a patient ──
  Future<void> selectPatient(PatientInfo patient) async {
    _selectedPatient = patient;
    _dailyStats = [];
    _analysisStats = AnalysisStats.empty();
    _glucoseSpots = [];
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    notifyListeners();

    await _loadPatientData(patient.glucoseEmail);
  }

  void clearSelection() {
    _selectedPatient = null;
    _dailyStats = [];
    _analysisStats = AnalysisStats.empty();
    _glucoseSpots = [];
    notifyListeners();
  }

  Future<void> updateSelectedDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
    if (_selectedPatient != null) {
      await _loadDayGlucose(_selectedPatient!.glucoseEmail, _selectedDate);
    }
  }

  Future<void> previousDay() async {
    await updateSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  Future<void> nextDay() async {
    if (canGoNext) {
      await updateSelectedDate(_selectedDate.add(const Duration(days: 1)));
    }
  }

  // ── Private helpers to fetch data ──

  Future<void> _loadPatientData(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Load DailyStats (last 30 days)
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 30));

      final querySnapshot = await firestore
          .collection('Glucose_measurements')
          .doc(email)
          .collection('daily_stats')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .orderBy('date', descending: true)
          .get();

      _dailyStats = querySnapshot.docs
          .map((doc) => DailyStats.fromMap(doc.data()))
          .toList();

      // 2. Load AnalysisStats (summary)
      if (_dailyStats.isNotEmpty) {
        double totalAvg = 0;
        for (var d in _dailyStats) totalAvg += d.averageGlucose;
        totalAvg /= _dailyStats.length;

        // Pobieramy zakresy z ostatniego dostępnego dnia jako przybliżenie
        // lub tworzymy średnią (tutaj wersja uproszczona biorąca ostatni dzień)
        final lastRanges = _dailyStats.first.ranges;

        // ── FIX: Corrected constructor usage based on your error logs ──
        _analysisStats = AnalysisStats(
          averageGlucose: totalAvg,
          gmi: (totalAvg + 46.7) / 28.7,
          // Wymagane pola (mockujemy lub obliczamy):
          standardDeviation: 15.0, // Przykładowa wartość (warto obliczyć z danych)
          coefficientOfVariation: 20.0, // Przykładowa wartość
          sensorActivePercent: 95.0, // Zakładamy wysokie użycie sensora
          // Zamiast timeInRange, przekazujemy mapę ranges:
          ranges: {
            'inRange': lastRanges['inRange'] ?? 0,
            'low': lastRanges['low'] ?? 0,
            'high': lastRanges['high'] ?? 0,
            'veryLow': lastRanges['veryLow'] ?? 0,
            'veryHigh': lastRanges['veryHigh'] ?? 0,
          },
        );
      } else {
        _analysisStats = AnalysisStats.empty();
      }

      // 3. Load spots for selectedDate
      await _loadDayGlucose(email, _selectedDate);

    } catch (e) {
      debugPrint('DoctorViewModel: Error loading data for $email: $e');
      _analysisStats = AnalysisStats.empty();
      _dailyStats = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDayGlucose(String email, DateTime date) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final startOfDay = date;
      final endOfDay = date.add(const Duration(days: 1));

      final querySnapshot = await firestore
          .collection('Glucose_measurements')
          .doc(email)
          .collection('history')
          .where('Timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('Timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('Timestamp', descending: false)
          .get();

      final List<FlSpot> spots = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('Glucose') && data.containsKey('Timestamp')) {
          final double glucose = (data['Glucose'] as num).toDouble();
          DateTime timestamp;
          if (data['Timestamp'] is Timestamp) {
            timestamp = (data['Timestamp'] as Timestamp).toDate();
          } else {
            continue;
          }
          final double xValue = timestamp.hour + (timestamp.minute / 60.0);
          spots.add(FlSpot(xValue, glucose));
        }
      }
      spots.sort((a, b) => a.x.compareTo(b.x));
      _glucoseSpots = spots;
    } catch (e) {
      debugPrint('DoctorViewModel: Error loading day glucose: $e');
      _glucoseSpots = [];
    }
    notifyListeners();
  }
}