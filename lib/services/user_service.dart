import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'Users';
  final CollectionReference _usersCollectionInstance =
      FirebaseFirestore.instance.collection('Users');

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection(_usersCollection).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollectionInstance.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot);
      }
      return null;
    });
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection(_usersCollection).doc(userId).update(data);
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection(_usersCollection).doc(userId).delete();
  }

  /// Fetch multiple users by their document IDs (for doctor's patient list).
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    // Firestore 'whereIn' supports max 30 items per query
    final List<UserModel> results = [];
    final chunks = <List<String>>[];
    for (var i = 0; i < userIds.length; i += 30) {
      chunks.add(userIds.sublist(
          i, i + 30 > userIds.length ? userIds.length : i + 30));
    }

    for (final chunk in chunks) {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        results.add(UserModel.fromFirestore(doc));
      }
    }

    return results;
  }
}
