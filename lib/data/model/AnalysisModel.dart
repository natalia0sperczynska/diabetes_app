import 'dart:math';

import 'DailyStats.dart';

class AnalysisStats {
  final double averageGlucose;
  final double gmi;
  final double coefficientOfVariation;
  final double standardDeviation;
  final double sensorActivePercent;

  final Map<String, double> ranges;

  const AnalysisStats(
      {required this.averageGlucose,
      required this.standardDeviation,
      required this.gmi,
      required this.coefficientOfVariation,
      required this.sensorActivePercent,
      required this.ranges});

  factory AnalysisStats.empty() {
    return const AnalysisStats(
        averageGlucose: 0,
        standardDeviation: 0,
        gmi: 0,
        coefficientOfVariation: 0,
        sensorActivePercent: 0,
        ranges: {
          'veryHigh': 0.0,
          'high': 0.0,
          'inTarget': 0.0,
          'low': 0.0,
          'veryLow': 0.0,
        });
  }

  factory AnalysisStats.fromReadings(List<double> readings, int totalDays) {
    if (readings.isEmpty) return AnalysisStats.empty();
    double averageGlucose = calculateAverageGlucose(readings);
    double standardDeviation =
        calculateStandardDeviation(readings, averageGlucose);

    return AnalysisStats(
      averageGlucose: averageGlucose,
      standardDeviation: standardDeviation,
      gmi: calculateGMI(averageGlucose),
      coefficientOfVariation:
          calculateCoefficientOfVariation(averageGlucose, standardDeviation),
      sensorActivePercent: calculateSensorActivePercent(readings, totalDays),
      ranges: calculateRanges(readings),
    );
  }
  factory AnalysisStats.fromDailyStatsList(List<DailyStats> days) {
    if (days.isEmpty) return AnalysisStats.empty();

    double sumGlucose = 0;
    double sumGmi = 0;
    double sumCV = 0;
    double sumSD = 0;
    double sumSensorActive = 0;
    double sumVeryHigh = 0;
    double sumHigh = 0;
    double sumInTarget = 0;
    double sumLow = 0;
    double sumVeryLow = 0;

    for (var day in days) {
      sumGlucose += day.averageGlucose;
      sumGmi += day.gmi;
      sumCV += day.coefficientOfVariation;
      sumSD += day.standardDeviation;
      sumSensorActive += day.sensorActivePercent;

      sumVeryHigh += day.ranges['veryHigh'] ?? 0;
      sumHigh += day.ranges['high'] ?? 0;
      sumInTarget += day.ranges['inTarget'] ?? 0;
      sumLow += day.ranges['low'] ?? 0;
      sumVeryLow += day.ranges['veryLow'] ?? 0;
    }

    int count = days.length;

    double avg(double sum) => double.parse((sum / count).toStringAsFixed(1));

    return AnalysisStats(
      averageGlucose: double.parse((sumGlucose / count).toStringAsFixed(0)), // glukoza do całości
      standardDeviation: avg(sumSD),
      gmi: avg(sumGmi),
      coefficientOfVariation: avg(sumCV),
      sensorActivePercent: avg(sumSensorActive),
      ranges: {
        'veryHigh': avg(sumVeryHigh),
        'high': avg(sumHigh),
        'inTarget': avg(sumInTarget),
        'low': avg(sumLow),
        'veryLow': avg(sumVeryLow),
      },
    );
  }

  //average
  static double calculateAverageGlucose(List<double> readings) {
    if (readings.isEmpty) return 0.0;
    double sum = readings.reduce((a, b) => a + b);
    return sum / readings.length;
  }

  //standard deviation formula , sqrt(sum(average - value)^2 / N)
  static double calculateStandardDeviation(
      List<double> readings, double average) {
    if (readings.isEmpty) return 0.0;
    double sumOfSqrDiff = 0;
    for (var reading in readings) {
      sumOfSqrDiff += pow(reading - average, 2);
    }
    double variance = sumOfSqrDiff / readings.length;
    return sqrt(variance);
  }

  //GMI (%) = 3.31 + 0.02392 × [mean glucose in mg/dL]
  static double calculateGMI(double averageGlucose) {
    if (averageGlucose <= 0) return 0.0;
    double calculated = 3.31 + (0.02392 * averageGlucose);
    return double.parse(calculated.toStringAsFixed(2));
  }

  //(Standard Deviation / Mean Glucose) * 100
  static double calculateCoefficientOfVariation(
      double averageGlucose, double standardDeviation) {
    if (averageGlucose <= 0) return 0.0;
    double calculated = (standardDeviation / averageGlucose) * 100;
    return double.parse(calculated.toStringAsFixed(2));
  }

  //(Total Readings / Expected Readings) * 100
  static double calculateSensorActivePercent(
      List<double> readings, int totalDays) {
    if (readings.isEmpty) return 0.0;
    int expectedReadings = totalDays * 288;
    double sensorActive = (readings.length / expectedReadings) * 100;
    if (sensorActive > 100) sensorActive = 100;
    return sensorActive;
  }

  static Map<String, double> calculateRanges(List<double> readings) {
    if (readings.isEmpty) {
      return {
        'veryHigh': 0.0,
        'high': 0.0,
        'inTarget': 0.0,
        'low': 0.0,
        'veryLow': 0.0
      };
    }
    int countVeryHigh = 0;
    int countHigh = 0;
    int countInTarget = 0;
    int countLow = 0;
    int countVeryLow = 0;

    for (var r in readings) {
      if (r > 250) {
        countVeryHigh++;
      } else if (r > 180) {
        countHigh++;
      } else if (r >= 70) {
        countInTarget++;
      } else if (r >= 54) {
        countLow++;
      } else {
        countVeryLow++;
      }
    }

    double total = readings.length.toDouble();

    double calcPercent(int count) {
      return double.parse(((count / total) * 100).toStringAsFixed(1));
    }

    return {
      'veryHigh': calcPercent(countVeryHigh),
      'high': calcPercent(countHigh),
      'inTarget': calcPercent(countInTarget),
      'low': calcPercent(countLow),
      'veryLow': calcPercent(countVeryLow),
    };
  }
}
