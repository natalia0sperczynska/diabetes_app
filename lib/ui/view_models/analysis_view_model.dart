import 'dart:developer';

import 'package:flutter/material.dart';

import '../../data/model/AnalysisModel.dart';
//do przechowania i pobrania danych
class AnalysisViewModel extends ChangeNotifier {
  final String _currentTitle = "Analysis";
  bool _isLoading = false;
  int _daysToAnalyze = 14;
  //List<double> glucoseReadings = firebase function

  AnalysisStats _stats = AnalysisStats.empty();
 // AnalysisStats _stats = AnalysisStats.fromReadings(glucoseReadings, 14);
  bool get isLoading => _isLoading;
  int get daysToAnalyze => _daysToAnalyze;
  AnalysisStats get stats => _stats;
  String get currentTitle => _currentTitle;

  Future<void> loadData() async {
  _isLoading =true;
  notifyListeners();
  final startDate = DateTime.now().subtract(Duration(days: _daysToAnalyze));
  try{
    await Future.delayed(const Duration(seconds: 1));

    _stats = const AnalysisStats(
      averageGlucose: 154,
      gmi: 6.9,
      coefficientOfVariation: 32.5,
      standardDeviation: 45,
      sensorActivePercent: 96,

      timeInTarget: 70,
      timeHigh: 20,
      timeVeryHigh: 5,
      timeLow: 4,
      timeVeryLow: 1,
    );
    //funckja z firebase

  }catch(e){
    log("Error fetching glucose data: $e");
  }finally{
    _isLoading = false;
    notifyListeners();
  }
  }


}