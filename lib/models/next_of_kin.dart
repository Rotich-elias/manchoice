import 'package:cloud_firestore/cloud_firestore.dart';

class NextOfKin {
  final String id;
  final String customerId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String idNumber;
  final String relationship;
  final String idFrontPhotoUrl;
  final String idBackPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  NextOfKin({
    required this.id,
    required this.customerId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.idNumber,
    required this.relationship,
    required this.idFrontPhotoUrl,
    required this.idBackPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'idNumber': idNumber,
      'relationship': relationship,
      'idFrontPhotoUrl': idFrontPhotoUrl,
      'idBackPhotoUrl': idBackPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory NextOfKin.fromMap(Map<String, dynamic> map) {
    return NextOfKin(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      idNumber: map['idNumber'] ?? '',
      relationship: map['relationship'] ?? '',
      idFrontPhotoUrl: map['idFrontPhotoUrl'] ?? '',
      idBackPhotoUrl: map['idBackPhotoUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  NextOfKin copyWith({
    String? id,
    String? customerId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? idNumber,
    String? relationship,
    String? idFrontPhotoUrl,
    String? idBackPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NextOfKin(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idNumber: idNumber ?? this.idNumber,
      relationship: relationship ?? this.relationship,
      idFrontPhotoUrl: idFrontPhotoUrl ?? this.idFrontPhotoUrl,
      idBackPhotoUrl: idBackPhotoUrl ?? this.idBackPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
