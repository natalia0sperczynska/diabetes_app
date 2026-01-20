import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/AnalysisModel.dart';
import '../../data/model/DailyStats.dart';
import '../../services/firebase_service.dart';
import 'package:firebase_ai/firebase_ai.dart';

//do przechowania i pobrania danych
class AnalysisViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final String _currentTitle = "Analysis";
  String _aiAnalysisResult = "";
  late String bestDay = bestDayText;
  bool _isAiLoading = false;
  List<DailyStats> _cachedDailyData = [];
  bool _isLoading = false;
  final int _daysToAnalyze = 14;
  List<AgpChartData> _agpData = [];


  AnalysisStats _stats = AnalysisStats.empty();

  bool get isLoading => _isLoading;

  int get daysToAnalyze => _daysToAnalyze;

  AnalysisStats get stats => _stats;

  String get currentTitle => _currentTitle;

  String get aiAnalysisResult => _aiAnalysisResult;

  List<AgpChartData> get agpData => _agpData;

  bool get isAiLoading => _isAiLoading;

  List<DailyStats> get cachedDailyData => _cachedDailyData;


  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    if (_cachedDailyData.isNotEmpty) {
      _calculateAgpData(_cachedDailyData);
      _stats = AnalysisStats.fromDailyStatsList(_cachedDailyData);
      notifyListeners();
      _isLoading = false;
      return;
    }
    try {
      List<DailyStats> dailyData =
          await _firebaseService.getAnalysis(_daysToAnalyze);

      if (dailyData.isNotEmpty) {
        _stats = AnalysisStats.fromDailyStatsList(dailyData);
        _cachedDailyData = dailyData;
        _agpData = _calculateAgpData(dailyData);
        _updateCache(dailyData);
        log("Stats from firebase: ${dailyData.length} days ");
      } else {
        _stats = AnalysisStats.empty();
        _cachedDailyData = [];
        log("No data from firebase");
      }
    } catch (e) {
      log("Error fetching glucose data: $e");
      if (_cachedDailyData.isNotEmpty) {
        _stats = AnalysisStats.fromDailyStatsList(_cachedDailyData);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AgpChartData> _calculateAgpData(List<DailyStats> days) {
    List<List<double>> hourlyBuckets = List.generate(24, (_) => []);

    for (var day in days) {
      if (day.samples.isEmpty) continue;

      int totalSamples = day.samples.length;

      for (int i = 0; i < totalSamples; i++) {
        int hour = ((i / totalSamples) * 24).floor();

        if (hour < 24) {
          hourlyBuckets[hour].add(day.samples[i]);
        }
      }
    }

    List<AgpChartData> result = [];
    for (int hour = 0; hour < 24; hour++) {
      var values = hourlyBuckets[hour];

      if (values.isEmpty) {
        result.add(AgpChartData(hour: hour, p5: 0, p25: 0, p50: 0, p75: 0, p95: 0));
        continue;
      }

      values.sort();
      result.add(AgpChartData(
        hour: hour,
        p5: _getPercentile(values, 5),
        p25: _getPercentile(values, 25),
        p50: _getPercentile(values, 50),
        p75: _getPercentile(values, 75),
        p95: _getPercentile(values, 95),
      ));
    }
    return result;
  }

  double _getPercentile(List<double> sortedValues, int percentile) {
    if (sortedValues.isEmpty) return 0;
    int index = ((percentile / 100) * (sortedValues.length - 1)).round();
    return sortedValues[index];
  }

  List<int> getHourlyRiskProfile() {
    if (_agpData.isEmpty) return List.filled(24, 0);

    return _agpData.map((data) {
      if (data.p50 == 0) return 0;
      if (data.p50 < 70) return 1;
      if (data.p50 > 180) return 2;
      return 0;
    }).toList();
  }

  DailyStats? get bestDayStat {
    if (_cachedDailyData.isEmpty) return null;

    return _cachedDailyData.reduce((curr, next) {
      final currTarget = curr.ranges['inTarget'] ?? 0;
      final nextTarget = next.ranges['inTarget'] ?? 0;
      return currTarget > nextTarget ? curr : next;
    });
  }

  String get bestDayText {
    final best = bestDayStat;
    if (best == null) return "No data available";
    final date = best.date.toDate();
    final dateStr = DateFormat('MMMM d').format(date);
    final score = best.ranges['inTarget']?.toInt() ?? 0;

    return "Best Day: $dateStr ($score% in range)";
  }

  Future<void> generateAIAnalysis() async {
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
      final trendData = _prepareTrendData();

      final promptText = '''
You are a medical AI assistant in a Cyberpunk-themed diabetes management app. Your role is to support, not replace, healthcare professionals.

ANALYSIS REQUEST:
Analyze the following patient glucose metrics from the last $_daysToAnalyze days.

CONTEXT DATA:
The following is the daily breakdown of the patient's glucose over the last $_daysToAnalyze days:
$trendData

PATIENT AGGREGATED METRICS:
- Average Glucose: ${_stats.averageGlucose.toInt()} mg/dL
- GMI: ${_stats.gmi}%
- Glucose Variability (SD): ${_stats.standardDeviation.toInt()} mg/dL
- Coefficient of Variation (CV): ${_stats.coefficientOfVariation}%
- Time in Range (70-180 mg/dL): ${_stats.ranges['inTarget']?.toInt()}%
- Time Below Range (<70 mg/dL): ${(_stats.ranges['low']! + _stats.ranges['veryLow']!).toInt()}%
- Time Above Range (>180 mg/dL): ${(_stats.ranges['high']! + _stats.ranges['veryHigh']!).toInt()}%

TASK:
Analyze the provided metrics and the DAILY BREAKDOWN above to identify patterns (e.g., "Frequent drops on weekends", "Consistent night lows").

STRICT OUTPUT FORMAT:
1. Provide a comprehensive yet concise analysis in approximately 5 sentences.
2. Sentence 1: Overall assessment of glucose control quality.
3. Sentence 2: Comment on glycemic stability/variability (SD, CV).
4. Sentence 3: Analyze Time in Range achievement.
5. Sentence 4: Identify the most significant safety concern (hypo- or hyperglycemia) and trends, patterns if detected.
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

  String _prepareTrendData() {
    if (_cachedDailyData.isEmpty) return "No daily breakdown available.";

    StringBuffer buffer = StringBuffer();
    buffer.writeln("DAILY BREAKDOWN (Last ${_cachedDailyData.length} days):");

    for (var day in _cachedDailyData) {
      final date = day.date.toDate().toString().split(' ')[0];
      final low = (day.ranges['low']! + day.ranges['veryLow']!).toInt();
      final high = (day.ranges['high']! + day.ranges['veryHigh']!).toInt();

      buffer.writeln(
          "- $date: Avg: ${day.averageGlucose.toInt()}, Lows: $low%, Highs: $high%");
    }
    return buffer.toString();
  }

  void _updateCache(List<DailyStats> newData) {
    const maxCachedDays = 30;
    if (newData.length > maxCachedDays) {
      _cachedDailyData = newData.sublist(0, maxCachedDays);
    } else {
      _cachedDailyData = newData;
    }
  }

}
class AgpChartData {
  final int hour;
  final double p5;
  final double p25;
  final double p50;
  final double p75;
  final double p95;

  AgpChartData({
    required this.hour,
    required this.p5,
    required this.p25,
    required this.p50,
    required this.p75,
    required this.p95
  });
}