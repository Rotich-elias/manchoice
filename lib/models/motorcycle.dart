import 'package:cloud_firestore/cloud_firestore.dart';

class Motorcycle {
  final String id;
  final String customerId;
  final String plateNumber;
  final String chassisNumber;
  final String model;
  final String type;
  final String engineCC;
  final String color;
  final String motorcyclePhotoUrl;
  final String logbookPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Motorcycle({
    required this.id,
    required this.customerId,
    required this.plateNumber,
    required this.chassisNumber,
    required this.model,
    required this.type,
    required this.engineCC,
    required this.color,
    required this.motorcyclePhotoUrl,
    required this.logbookPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'plateNumber': plateNumber,
      'chassisNumber': chassisNumber,
      'model': model,
      'type': type,
      'engineCC': engineCC,
      'color': color,
      'motorcyclePhotoUrl': motorcyclePhotoUrl,
      'logbookPhotoUrl': logbookPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Motorcycle.fromMap(Map<String, dynamic> map) {
    return Motorcycle(
      id: map['id'] ?? '',
      customerId: map['customerId'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
      chassisNumber: map['chassisNumber'] ?? '',
      model: map['model'] ?? '',
      type: map['type'] ?? '',
      engineCC: map['engineCC'] ?? '',
      color: map['color'] ?? '',
      motorcyclePhotoUrl: map['motorcyclePhotoUrl'] ?? '',
      logbookPhotoUrl: map['logbookPhotoUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Motorcycle copyWith({
    String? id,
    String? customerId,
    String? plateNumber,
    String? chassisNumber,
    String? model,
    String? type,
    String? engineCC,
    String? color,
    String? motorcyclePhotoUrl,
    String? logbookPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Motorcycle(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      plateNumber: plateNumber ?? this.plateNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      model: model ?? this.model,
      type: type ?? this.type,
      engineCC: engineCC ?? this.engineCC,
      color: color ?? this.color,
      motorcyclePhotoUrl: motorcyclePhotoUrl ?? this.motorcyclePhotoUrl,
      logbookPhotoUrl: logbookPhotoUrl ?? this.logbookPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
