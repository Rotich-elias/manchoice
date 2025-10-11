class Payment {
  final int id;
  final int loanId;
  final int customerId;
  final String? transactionId;
  final String? mpesaReceiptNumber;
  final double amount;
  final String paymentMethod; // cash, mpesa, bank_transfer, etc
  final String status; // pending, completed, failed, reversed
  final DateTime paymentDate;
  final String? phoneNumber;
  final String? notes;
  final int? recordedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Payment({
    required this.id,
    required this.loanId,
    required this.customerId,
    this.transactionId,
    this.mpesaReceiptNumber,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    this.phoneNumber,
    this.notes,
    this.recordedBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      loanId: json['loan_id'],
      customerId: json['customer_id'],
      transactionId: json['transaction_id'],
      mpesaReceiptNumber: json['mpesa_receipt_number'],
      amount: double.parse(json['amount']?.toString() ?? '0'),
      paymentMethod: json['payment_method'],
      status: json['status'],
      paymentDate: DateTime.parse(json['payment_date']),
      phoneNumber: json['phone_number'],
      notes: json['notes'],
      recordedBy: json['recorded_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'customer_id': customerId,
      'transaction_id': transactionId,
      'mpesa_receipt_number': mpesaReceiptNumber,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'payment_date': paymentDate.toIso8601String(),
      'phone_number': phoneNumber,
      'notes': notes,
      'recorded_by': recordedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
