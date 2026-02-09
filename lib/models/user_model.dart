import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String surname;
  final int age;
  final String gender;
  final String country;
  final String? phoneNumber;
  final bool isDoctor;
  final List<String> patientIds;
  final String? glucoseSourceEmail;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.age,
    required this.gender,
    required this.country,
    this.phoneNumber,
    this.isDoctor = false,
    this.patientIds = const [],
    this.glucoseSourceEmail,
  });

  /// The email key used to look up glucose data in Glucose_measurements.
  /// Falls back to the user's own email when glucoseSourceEmail is not set.
  String get glucoseEmail => glucoseSourceEmail ?? email;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'surname': surname,
      'age': age,
      'gender': gender,
      'country': country,
      'phoneNumber': phoneNumber,
      'isDoctor': isDoctor,
      'patientIds': patientIds,
      'glucoseSourceEmail': glucoseSourceEmail,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      country: map['country'] ?? '',
      phoneNumber: map['phoneNumber'],
      isDoctor: map['isDoctor'] ?? false,
      patientIds: List<String>.from(map['patientIds'] ?? []),
      glucoseSourceEmail: map['glucoseSourceEmail'],
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return UserModel.fromMap(data);
  }
}
