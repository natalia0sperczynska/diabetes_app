import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../data/model/AnalysisModel.dart';
import '../data/model/DailyStats.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userEmail = 'anniefocused@gmail.com';

  final String _rawCollection = 'history';
  final String _aggregatesCollection = 'daily_aggregates';

  Future<List<DailyStats>> getAnalysis(int daysCount) async {
    List<DailyStats> results = [];
    try {
      var latestDocQuery = await _firestore
          .collection('Glucose_measurements')
          .doc(_userEmail)
          .collection(_rawCollection)
          .orderBy('Timestamp', descending: true)
          .limit(1)
          .get();

      if (latestDocQuery.docs.isEmpty) {
        log("No measurements for $_userEmail");
        return [];
      }

      DateTime lastRawDate =
          (latestDocQuery.docs.first['Timestamp'] as Timestamp).toDate();
      DateTime anchorDate =
          DateTime(lastRawDate.year, lastRawDate.month, lastRawDate.day);
      log("Last measrement ${DateFormat('yyyy-MM-dd').format(anchorDate)}");

      for (int i = 0; i < daysCount; i++) {
        DateTime targetDate = anchorDate.subtract(Duration(days: i));
        String dateId = DateFormat('yyyy-MM-dd').format(targetDate);
        var aggregateDocRef = _firestore
            .collection('Glucose_measurements')
            .doc(_userEmail)
            .collection(_aggregatesCollection)
            .doc(dateId);

        var docSnap = await aggregateDocRef.get();

        if (docSnap.exists) {
          results.add(DailyStats.fromMap(docSnap.data()!));
        } else {
          DailyStats? newStats =
              await _generateAndSaveDailyStats(targetDate, dateId);
          if (newStats != null) {
            results.add(newStats);
          }
        }
      }
    } catch (e) {
      print("Firebase Error: $e");
    }

    return results;
  }

  Future<DailyStats?> _generateAndSaveDailyStats(
      DateTime date, String dateId) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    var query = await _firestore
        .collection('Glucose_measurements')
        .doc(_userEmail)
        .collection(_rawCollection)
        .where('Timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('Timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('Timestamp', descending: false)
        .get();

    if (query.docs.isEmpty) return null;

    List<double> glucoseReadings = query.docs
        .map((doc) {
          var data = doc.data();
          dynamic val = data['Glucose'];

          if (val is int) return val.toDouble();
          if (val is double) return val;
          return 0.0;
        })
        .where((val) => val > 0)
        .toList();

    if (glucoseReadings.isEmpty) return null;

    AnalysisStats calculated = AnalysisStats.fromReadings(glucoseReadings, 1);

    DailyStats dailyStats = DailyStats(
      date: Timestamp.fromDate(startOfDay),
      averageGlucose: calculated.averageGlucose,
      standardDeviation: calculated.standardDeviation,
      gmi: calculated.gmi,
      coefficientOfVariation: calculated.coefficientOfVariation,
      sensorActivePercent: calculated.sensorActivePercent,
      ranges: calculated.ranges,
    );

    await _firestore
        .collection('Glucose_measurements')
        .doc(_userEmail)
        .collection(_aggregatesCollection)
        .doc(dateId)
        .set(dailyStats.toMap());

    print("New report: $dateId");
    return dailyStats;
  }
}
