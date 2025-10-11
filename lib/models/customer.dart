import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String idNumber;
  final String workingStation;
  final String passportPhotoUrl;
  final String idFrontPhotoUrl;
  final String idBackPhotoUrl;
  final String signatureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.idNumber,
    required this.workingStation,
    required this.passportPhotoUrl,
    required this.idFrontPhotoUrl,
    required this.idBackPhotoUrl,
    required this.signatureUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'idNumber': idNumber,
      'workingStation': workingStation,
      'passportPhotoUrl': passportPhotoUrl,
      'idFrontPhotoUrl': idFrontPhotoUrl,
      'idBackPhotoUrl': idBackPhotoUrl,
      'signatureUrl': signatureUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      idNumber: map['idNumber'] ?? '',
      workingStation: map['workingStation'] ?? '',
      passportPhotoUrl: map['passportPhotoUrl'] ?? '',
      idFrontPhotoUrl: map['idFrontPhotoUrl'] ?? '',
      idBackPhotoUrl: map['idBackPhotoUrl'] ?? '',
      signatureUrl: map['signatureUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isApproved: map['isApproved'] ?? false,
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? idNumber,
    String? workingStation,
    String? passportPhotoUrl,
    String? idFrontPhotoUrl,
    String? idBackPhotoUrl,
    String? signatureUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idNumber: idNumber ?? this.idNumber,
      workingStation: workingStation ?? this.workingStation,
      passportPhotoUrl: passportPhotoUrl ?? this.passportPhotoUrl,
      idFrontPhotoUrl: idFrontPhotoUrl ?? this.idFrontPhotoUrl,
      idBackPhotoUrl: idBackPhotoUrl ?? this.idBackPhotoUrl,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }
}
