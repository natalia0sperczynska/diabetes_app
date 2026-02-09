import 'package:cloud_firestore/cloud_firestore.dart';

class MenstrualServiceFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getCycleCollection(String uid) {
    return _firestore.collection('Users').doc(uid).collection('cycle_logs');
  }

  Future<List<DateTime>> fetchCycleData(String uid) async {
    try {
      final snapshot = await _getCycleCollection(uid)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return (doc['date'] as Timestamp).toDate();
      }).toList();
    } catch (e) {
      print("Service Error: Error fetching cycle data: $e");
      throw e;
    }
  }

  Future<void> logPeriodStart(String uid, DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day, 12);

      await _getCycleCollection(uid).add({
        'date': Timestamp.fromDate(normalizedDate),
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Service Error: Error logging period: $e");
      throw e;
    }
  }

  Future<void> removeEntry(String uid, DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day, 12);
      final targetTimestamp = Timestamp.fromDate(normalizedDate);

      final snapshot = await _getCycleCollection(uid)
          .where('date', isEqualTo: targetTimestamp)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Service Error: Error deleting entry: $e");
      throw e;
    }
  }
}
