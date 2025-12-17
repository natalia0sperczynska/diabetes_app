import 'package:cloud_firestore/cloud_firestore.dart';

class DailyStats {
  final Timestamp date;
  final double averageGlucose;
  final double gmi;
  final double coefficientOfVariation;
  final double standardDeviation;
  final double sensorActivePercent;

  final Map<String, double> ranges;

  DailyStats({
    required this.date,
    required this.averageGlucose,
    required this.standardDeviation,
    required this.gmi,
    required this.coefficientOfVariation,
    required this.sensorActivePercent,
    required this.ranges,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'averageGlucose': averageGlucose,
      'standardDeviation': standardDeviation,
      'gmi': gmi,
      'coefficientOfVariation': coefficientOfVariation,
      'sensorActivePercent': sensorActivePercent,
      'ranges': ranges,
    };
  }

  factory DailyStats.fromMap(Map<String, dynamic> map) {
    return DailyStats(
      date: map['date'] as Timestamp,
      averageGlucose: (map['averageGlucose'] ?? 0).toDouble(),
      standardDeviation: (map['standardDeviation'] ?? 0).toDouble(),
      gmi: (map['gmi'] ?? 0).toDouble(),
      coefficientOfVariation: (map['coefficientOfVariation'] ?? 0).toDouble(),
      sensorActivePercent: (map['sensorActivePercent'] ?? 0).toDouble(),
      ranges: (map['ranges'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ) ??
          {},
    );
  }
}
