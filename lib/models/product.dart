class Product {
  final int id;
  final String name;
  final String? description;
  final String? category;
  final double price;
  final double? originalPrice;
  final int discountPercentage;
  final String? imageUrl;
  final int stockQuantity;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.price,
    this.originalPrice,
    this.discountPercentage = 0,
    this.imageUrl,
    required this.stockQuantity,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: double.parse(json['price']?.toString() ?? '0'),
      originalPrice: json['original_price'] != null ? double.parse(json['original_price'].toString()) : null,
      discountPercentage: json['discount_percentage'] ?? 0,
      imageUrl: json['image_url'],
      stockQuantity: json['stock_quantity'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'original_price': originalPrice,
      'discount_percentage': discountPercentage,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Check if product is in stock
  bool get isInStock => stockQuantity > 0 && isAvailable;

  // Check if product has discount
  bool get hasDiscount => discountPercentage > 0;
}
