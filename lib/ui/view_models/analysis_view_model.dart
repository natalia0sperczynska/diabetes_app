import 'dart:developer';

import 'package:flutter/material.dart';

import '../../data/model/AnalysisModel.dart';
import '../../data/model/DailyStats.dart';
import '../../services/firebase_service.dart';

//do przechowania i pobrania danych
class AnalysisViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final String _currentTitle = "Analysis";

  bool _isLoading = false;
  int _daysToAnalyze = 14;

  AnalysisStats _stats = AnalysisStats.empty();

  bool get isLoading => _isLoading;

  int get daysToAnalyze => _daysToAnalyze;

  AnalysisStats get stats => _stats;

  String get currentTitle => _currentTitle;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<DailyStats> dailyData =
          await _firebaseService.getAnalysis(_daysToAnalyze);

      if (dailyData.isNotEmpty) {
        _stats = AnalysisStats.fromDailyStatsList(dailyData);
        log("Stats from firebase: ${dailyData.length} days ");
      } else {
        _stats = AnalysisStats.empty();
        log("No data from firebase");
      }
      // _stats = const AnalysisStats(
      //   averageGlucose: 154,
      //   gmi: 6.9,
      //   coefficientOfVariation: 32.5,
      //   standardDeviation: 45,
      //   sensorActivePercent: 96,
      //   ranges: {
      //     'veryHigh': 0.0,
      //     'high': 5.0,
      //     'inTarget': 80.0,
      //     'low': 10.0,
      //     'veryLow': 5.0,
      //   },
      // );
      //funckja z firebase
    } catch (e) {
      log("Error fetching glucose data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
