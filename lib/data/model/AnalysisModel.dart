import 'dart:math';

class AnalysisStats {
  final double averageGlucose;
  final double gmi;
  final double coefficientOfVariation;
  final double standardDeviation;
  final double sensorActivePercent;

  final double timeVeryHigh;  // > 250 mg/dL
  final double timeHigh;      // 181-250 mg/dL
  final double timeInTarget;  // 70-180 mg/dL (Cel > 70%)
  final double timeLow;       // 54-69 mg/dL
  final double timeVeryLow;   // < 54 mg/dL

  const AnalysisStats({
    required this.averageGlucose,
    required this.gmi,
    required this.coefficientOfVariation,
    required this.standardDeviation,
    required this.sensorActivePercent,
    required this.timeVeryHigh,
    required this.timeHigh,
    required this.timeInTarget,
    required this.timeLow,
    required this.timeVeryLow,
  });

  factory AnalysisStats.empty() {
    return const AnalysisStats(
      averageGlucose: 0,
      gmi: 0,
      coefficientOfVariation: 0,
      standardDeviation: 0,
      sensorActivePercent: 0,
      timeVeryHigh: 0,
      timeHigh: 0,
      timeInTarget: 0,
      timeLow: 0,
      timeVeryLow: 0,
    );
  }

  //GMI (%) = 3.31 + 0.02392 × [mean glucose in mg/dL]
  static double calculateGMI(double averageGlucose) {
    if (averageGlucose <= 0) return 0.0;
    double calculated = 3.31 + (0.02392 * averageGlucose);
    return double.parse(calculated.toStringAsFixed(2));
  }
  //(Standard Deviation / Mean Glucose) * 100
  static double calculateCoefficientOfVariation (double averageGlucose, double standardDeviation){
    if (averageGlucose <= 0) return 0.0;
    double calculated = (standardDeviation / averageGlucose) *100;
    return double.parse(calculated.toStringAsFixed(2));

  }
}