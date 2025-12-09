import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsViewModel extends ChangeNotifier {
  List<FlSpot> _glucoseSpots = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<FlSpot> get glucoseSpots => _glucoseSpots;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Using the same email as seen in HomeContent
  final String _userEmail = 'anniefocused@gmail.com'; 

  StatisticsViewModel() {
    fetchGlucoseData();
  }

  Future<void> fetchGlucoseData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('Glucose_measurements')
          .doc(_userEmail)
          .collection('history')
          .orderBy('Timestamp', descending: true)
          .limit(288) // approx 24 hours of data (12 readings per hour * 24)
          .get();

      final List<FlSpot> spots = [];
      
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('Glucose') && data.containsKey('Timestamp')) {
          final double glucose = (data['Glucose'] as num).toDouble();
          
          // Timestamp parsing
          DateTime timestamp;
          if (data['Timestamp'] is Timestamp) {
            timestamp = (data['Timestamp'] as Timestamp).toDate();
          } else if (data['Timestamp'] is String) {
             timestamp = DateTime.tryParse(data['Timestamp']) ?? now;
          } else {
            continue;
          }

          // Filter for only today's data to avoid mixing yesterday's late hours with today's early hours
          // on a fixed 0-24h chart axis.
          if (timestamp.isBefore(startOfDay)) {
            continue;
          }

          // Calculate X value (hours from start of day, or just hours 0-24)
          // The Chart widget in Chart.dart has minX: 0, maxX: 24.
          final double xValue = timestamp.hour + (timestamp.minute / 60.0);
          
          spots.add(FlSpot(xValue, glucose));
        }
      }
      
      // Sort spots by X value for the chart to render correctly
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
