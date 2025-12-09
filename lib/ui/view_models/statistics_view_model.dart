import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsViewModel extends ChangeNotifier {
  List<FlSpot> _glucoseSpots = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _selectedDate;

  List<FlSpot> get glucoseSpots => _glucoseSpots;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userEmail = 'anniefocused@gmail.com';

  StatisticsViewModel() : _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day) {
    fetchGlucoseData();
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    fetchGlucoseData();
  }
  
  void previousDay() {
    updateSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  void nextDay() {
    updateSelectedDate(_selectedDate.add(const Duration(days: 1)));
  }

  bool get canGoNext {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !_selectedDate.isAtSameMomentAs(today);
  }

  Future<void> fetchGlucoseData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final startOfDay = _selectedDate;
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('Glucose_measurements')
          .doc(_userEmail)
          .collection('history')
          .where('Timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
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
          } else if (data['Timestamp'] is String) {
             timestamp = DateTime.tryParse(data['Timestamp']) ?? DateTime.now();
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
      _errorMessage = 'Failed to load data: $e';
      print("Error fetching glucose data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
