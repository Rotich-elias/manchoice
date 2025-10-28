import 'loan.dart';
import 'user.dart';

class Deposit {
  final int id;
  final int loanId;
  final int customerId;
  final double amount;
  final String? transactionId;
  final String? mpesaReceiptNumber;
  final String phoneNumber;
  final String paymentMethod; // mpesa, cash, bank_transfer, other
  final String status; // pending, completed, failed, reversed, rejected
  final DateTime? paidAt;
  final String? notes;
  final int? recordedBy;
  final String? rejectionReason;
  final DateTime? rejectedAt;
  final int? rejectedBy;
  final int rejectionCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final Loan? loan;
  final User? recorder;
  final User? rejector;

  Deposit({
    required this.id,
    required this.loanId,
    required this.customerId,
    required this.amount,
    this.transactionId,
    this.mpesaReceiptNumber,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.status,
    this.paidAt,
    this.notes,
    this.recordedBy,
    this.rejectionReason,
    this.rejectedAt,
    this.rejectedBy,
    this.rejectionCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.loan,
    this.recorder,
    this.rejector,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      id: json['id'],
      loanId: json['loan_id'],
      customerId: json['customer_id'],
      amount: double.parse(json['amount']?.toString() ?? '0'),
      transactionId: json['transaction_id'],
      mpesaReceiptNumber: json['mpesa_receipt_number'],
      phoneNumber: json['phone_number'] ?? '',
      paymentMethod: json['payment_method'] ?? 'mpesa',
      status: json['status'] ?? 'pending',
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      notes: json['notes'],
      recordedBy: json['recorded_by'],
      rejectionReason: json['rejection_reason'],
      rejectedAt: json['rejected_at'] != null ? DateTime.parse(json['rejected_at']) : null,
      rejectedBy: json['rejected_by'],
      rejectionCount: json['rejection_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      loan: json['loan'] != null ? Loan.fromJson(json['loan']) : null,
      recorder: json['recorder'] != null ? User.fromJson(json['recorder']) : null,
      rejector: json['rejector'] != null ? User.fromJson(json['rejector']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loan_id': loanId,
      'customer_id': customerId,
      'amount': amount,
      'transaction_id': transactionId,
      'mpesa_receipt_number': mpesaReceiptNumber,
      'phone_number': phoneNumber,
      'payment_method': paymentMethod,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
      'notes': notes,
      'recorded_by': recordedBy,
      'rejection_reason': rejectionReason,
      'rejected_at': rejectedAt?.toIso8601String(),
      'rejected_by': rejectedBy,
      'rejection_count': rejectionCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isReversed => status == 'reversed';
  bool get isRejected => status == 'rejected';

  // Check if rejection limit is reached (3 rejections)
  bool get hasReachedRejectionLimit => rejectionCount >= 3;

  // Check if this deposit can be retried
  bool get canRetry => (isRejected || isFailed) && !hasReachedRejectionLimit;
}
