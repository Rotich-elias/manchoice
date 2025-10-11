import 'package:cloud_firestore/cloud_firestore.dart';

class SparePart {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final int stockQuantity;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  SparePart({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.stockQuantity,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SparePart.fromMap(Map<String, dynamic> map) {
    return SparePart(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      stockQuantity: map['stockQuantity'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  SparePart copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    int? stockQuantity,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SparePart(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
