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

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.surname,
    required this.age,
    required this.gender,
    required this.country,
    this.phoneNumber,
  });

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
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data);
  }
}
