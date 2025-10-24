import 'user.dart';

class RegistrationFee {
  final int id;
  final int userId;
  final double amount;
  final String? transactionId;
  final String? mpesaReceiptNumber;
  final String phoneNumber;
  final String paymentMethod; // mpesa, cash, bank_transfer, other
  final String status; // pending, completed, failed, reversed
  final DateTime? paidAt;
  final String? notes;
  final int? recordedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final User? user; // Associated user details

  RegistrationFee({
    required this.id,
    required this.userId,
    required this.amount,
    this.transactionId,
    this.mpesaReceiptNumber,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.status,
    this.paidAt,
    this.notes,
    this.recordedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.user,
  });

  factory RegistrationFee.fromJson(Map<String, dynamic> json) {
    return RegistrationFee(
      id: json['id'],
      userId: json['user_id'],
      amount: double.parse(json['amount']?.toString() ?? '300'),
      transactionId: json['transaction_id'],
      mpesaReceiptNumber: json['mpesa_receipt_number'],
      phoneNumber: json['phone_number'] ?? '',
      paymentMethod: json['payment_method'] ?? 'mpesa',
      status: json['status'] ?? 'pending',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      notes: json['notes'],
      recordedBy: json['recorded_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'transaction_id': transactionId,
      'mpesa_receipt_number': mpesaReceiptNumber,
      'phone_number': phoneNumber,
      'payment_method': paymentMethod,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
      'notes': notes,
      'recorded_by': recordedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isReversed => status == 'reversed';
}
