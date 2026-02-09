import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/model/AnalysisModel.dart';
import '../../data/model/DailyStats.dart';
import '../../models/user_model.dart';
import '../../services/firebase_service.dart';
import '../../services/user_service.dart';

/// Represents a patient visible to the doctor.
class PatientInfo {
  final String uid;
  final String email;
  final String displayName;

  const PatientInfo({
    required this.uid,
    required this.email,
    required this.displayName,
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

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime get selectedDate => _selectedDate;

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

    await _loadPatientData(patient.email);
  }

  /// Go back to patient list.
  void clearSelection() {
    _selectedPatient = null;
    _dailyStats = [];
    _analysisStats = AnalysisStats.empty();
    _glucoseSpots = [];
    notifyListeners();
  }

  // ── Date navigation ──
  Future<void> updateSelectedDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
    if (_selectedPatient != null) {
      await _loadDayGlucose(_selectedPatient!.email, _selectedDate);
    }
  }

  void previousDay() =>
      updateSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
  void nextDay() =>
      updateSelectedDate(_selectedDate.add(const Duration(days: 1)));

  bool get canGoNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !_selectedDate.isAtSameMomentAs(today);
  }

  // ── Load patient data ──
  Future<void> _loadPatientData(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebaseService = FirebaseService(userEmail: email);
      _dailyStats = await firebaseService.getAnalysis(14);
      if (_dailyStats.isNotEmpty) {
        _analysisStats = AnalysisStats.fromDailyStatsList(_dailyStats);
      }
      await _loadDayGlucose(email, _selectedDate);
    } catch (e) {
      debugPrint('DoctorViewModel error: $e');
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
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading day glucose: $e');
    }
  }
}
