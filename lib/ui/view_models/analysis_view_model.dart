import 'dart:developer';

import 'package:flutter/material.dart';

import '../../data/model/AnalysisModel.dart';
import '../../data/model/DailyStats.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';

//do przechowania i pobrania danych
class AnalysisViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final String _currentTitle = "Analysis";
  String _aiAnalysisResult = "";
  bool _isAiLoading = false;

  bool _isLoading = false;
  int _daysToAnalyze = 14;

  AnalysisStats _stats = AnalysisStats.empty();

  bool get isLoading => _isLoading;

  int get daysToAnalyze => _daysToAnalyze;

  AnalysisStats get stats => _stats;

  String get currentTitle => _currentTitle;

  String get aiAnalysisResult => _aiAnalysisResult;

  bool get isAiLoading => _isAiLoading;

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

  Future<void> generateSmartAnalysis() async {
    if (_stats.averageGlucose == 0) {
      _aiAnalysisResult = "No enough data for analysis";
      notifyListeners();
      return;
    }
    _isAiLoading = true;
    notifyListeners();

    try {
      final model =
          FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

      final promptText = '''
You are a medical AI assistant in a Cyberpunk-themed diabetes management app. Your role is to support, not replace, healthcare professionals.

ANALYSIS REQUEST:
Analyze the following patient glucose metrics from the last $_daysToAnalyze days.

PATIENT METRICS:
- Average Glucose: ${_stats.averageGlucose.toInt()} mg/dL
- GMI: ${_stats.gmi}%
- Glucose Variability (SD): ${_stats.standardDeviation.toInt()} mg/dL
- Coefficient of Variation (CV): ${_stats.coefficientOfVariation}%
- Time in Range (70-180 mg/dL): ${_stats.ranges['inTarget']?.toInt()}%
- Time Below Range (<70 mg/dL): ${(_stats.ranges['low']! + _stats.ranges['veryLow']!).toInt()}%
- Time Above Range (>180 mg/dL): ${(_stats.ranges['high']! + _stats.ranges['veryHigh']!).toInt()}%

STRICT OUTPUT FORMAT:
1. Provide a comprehensive yet concise analysis in approximately 5 sentences.
2. Sentence 1: Overall assessment of glucose control quality.
3. Sentence 2: Comment on glycemic stability/variability (SD, CV).
4. Sentence 3: Analyze Time in Range achievement.
5. Sentence 4: Identify the most significant safety concern (hypo- or hyperglycemia).
6. Sentence 5: Provide ONE specific, actionable tip for improvement.
7. Tone: Professional, clear, with subtle futuristic undertones. Avoid alarmist language.
8. Language: Plain English only, no markdown.

CRITICAL REMINDER: This analysis is for informational support only. It is not medical advice. The user must consult their doctor for treatment changes.
''';

      final response = await model.generateContent([Content.text(promptText)]);

      _aiAnalysisResult = response.text ?? "Analysis failed.";
    } catch (e) {
      _aiAnalysisResult = "Connection error. Neural link offline.";
      print("AI Error: $e");
    } finally {
      _isAiLoading = false;
      notifyListeners();
    }
  }
}
