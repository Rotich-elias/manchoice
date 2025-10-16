import 'product.dart';

class LoanItem {
  final int id;
  final int loanId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  LoanItem({
    required this.id,
    required this.loanId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  factory LoanItem.fromJson(Map<String, dynamic> json) {
    return LoanItem(
      id: json['id'],
      loanId: json['loan_id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 1,
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (product != null) 'product': product!.toJson(),
    };
  }

  // Create loan item request for API
  Map<String, dynamic> toRequest() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}

// Helper class for creating loan items (before saving to database)
class LoanItemRequest {
  final int productId;
  final int quantity;
  final Product? product; // Optional, for UI display

  LoanItemRequest({
    required this.productId,
    required this.quantity,
    this.product,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }

  // Calculate subtotal
  double get subtotal {
    if (product != null) {
      return product!.price * quantity;
    }
    return 0.0;
  }
}
