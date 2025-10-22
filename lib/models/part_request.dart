class PartRequest {
  final int id;
  final int customerId;
  final int userId;
  final String partName;
  final String? description;
  final String? motorcycleModel;
  final String? year;
  final int quantity;
  final double? budget;
  final String urgency; // low, medium, high
  final String status; // pending, in_progress, available, fulfilled, cancelled
  final String? adminNotes;
  final String? imagePath;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PartRequest({
    required this.id,
    required this.customerId,
    required this.userId,
    required this.partName,
    this.description,
    this.motorcycleModel,
    this.year,
    required this.quantity,
    this.budget,
    required this.urgency,
    required this.status,
    this.adminNotes,
    this.imagePath,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartRequest.fromJson(Map<String, dynamic> json) {
    return PartRequest(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      partName: json['part_name'],
      description: json['description'],
      motorcycleModel: json['motorcycle_model'],
      year: json['year'],
      quantity: json['quantity'] is int ? json['quantity'] : int.parse(json['quantity'].toString()),
      budget: json['budget'] != null ? double.parse(json['budget'].toString()) : null,
      urgency: json['urgency'],
      status: json['status'],
      adminNotes: json['admin_notes'],
      imagePath: json['image_path'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'user_id': userId,
      'part_name': partName,
      'description': description,
      'motorcycle_model': motorcycleModel,
      'year': year,
      'quantity': quantity,
      'budget': budget,
      'urgency': urgency,
      'status': status,
      'admin_notes': adminNotes,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Status helper methods
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isAvailable => status == 'available';
  bool get isFulfilled => status == 'fulfilled';
  bool get isCancelled => status == 'cancelled';

  // Urgency helper methods
  bool get isLowUrgency => urgency == 'low';
  bool get isMediumUrgency => urgency == 'medium';
  bool get isHighUrgency => urgency == 'high';

  // Get status display text
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'available':
        return 'Available';
      case 'fulfilled':
        return 'Fulfilled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Get urgency display text
  String get urgencyText {
    switch (urgency) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      default:
        return urgency;
    }
  }
}
