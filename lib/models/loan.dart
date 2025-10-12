import 'customer_api.dart';
import 'payment.dart';
import 'user.dart';

class Loan {
  final int id;
  final int customerId;
  final String loanNumber;
  final double principalAmount;
  final double interestRate;
  final double totalAmount;
  final double amountPaid;
  final double balance;
  final String status; // pending, approved, active, completed, defaulted, cancelled, rejected
  final DateTime? disbursementDate;
  final DateTime? dueDate;
  final int? durationDays;
  final String? purpose;
  final String? notes;
  final int? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final CustomerApi? customer;
  final User? approver;
  final List<Payment>? payments;

  Loan({
    required this.id,
    required this.customerId,
    required this.loanNumber,
    required this.principalAmount,
    required this.interestRate,
    required this.totalAmount,
    required this.amountPaid,
    required this.balance,
    required this.status,
    this.disbursementDate,
    this.dueDate,
    this.durationDays,
    this.purpose,
    this.notes,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.customer,
    this.approver,
    this.payments,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'],
      customerId: json['customer_id'],
      loanNumber: json['loan_number'],
      principalAmount: double.parse(json['principal_amount']?.toString() ?? '0'),
      interestRate: double.parse(json['interest_rate']?.toString() ?? '0'),
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      amountPaid: double.parse(json['amount_paid']?.toString() ?? '0'),
      balance: double.parse(json['balance']?.toString() ?? '0'),
      status: json['status'],
      disbursementDate: json['disbursement_date'] != null
          ? DateTime.parse(json['disbursement_date'])
          : null,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      durationDays: json['duration_days'],
      purpose: json['purpose'],
      notes: json['notes'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      customer: json['customer'] != null ? CustomerApi.fromJson(json['customer']) : null,
      approver: json['approver'] != null ? User.fromJson(json['approver']) : null,
      payments: json['payments'] != null
          ? (json['payments'] as List).map((e) => Payment.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'loan_number': loanNumber,
      'principal_amount': principalAmount,
      'interest_rate': interestRate,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'balance': balance,
      'status': status,
      'disbursement_date': disbursementDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'duration_days': durationDays,
      'purpose': purpose,
      'notes': notes,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Check if loan is overdue
  bool get isOverdue {
    if (dueDate == null || status == 'completed') return false;
    return dueDate!.isBefore(DateTime.now()) && balance > 0;
  }

  // Calculate days overdue
  int get daysOverdue {
    if (!isOverdue || dueDate == null) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }

  // Get payment progress percentage
  double get paymentProgress {
    if (totalAmount == 0) return 0;
    return (amountPaid / totalAmount) * 100;
  }
}
