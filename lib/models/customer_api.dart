import 'loan.dart';
import 'payment.dart';

class CustomerApi {
  final int id;
  final String name;
  final String? email;
  final String phone;
  final String? idNumber;
  final String? address;
  final String? businessName;
  final String status; // active, inactive, blacklisted
  final double creditLimit;
  final double totalBorrowed;
  final double totalPaid;
  final int loanCount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<Loan>? loans;
  final List<Payment>? payments;

  CustomerApi({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.idNumber,
    this.address,
    this.businessName,
    this.status = 'active',
    this.creditLimit = 0.0,
    this.totalBorrowed = 0.0,
    this.totalPaid = 0.0,
    this.loanCount = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.loans,
    this.payments,
  });

  factory CustomerApi.fromJson(Map<String, dynamic> json) {
    return CustomerApi(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      idNumber: json['id_number'],
      address: json['address'],
      businessName: json['business_name'],
      status: json['status'] ?? 'active',
      creditLimit: double.parse(json['credit_limit']?.toString() ?? '0'),
      totalBorrowed: double.parse(json['total_borrowed']?.toString() ?? '0'),
      totalPaid: double.parse(json['total_paid']?.toString() ?? '0'),
      loanCount: json['loan_count'] ?? 0,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      loans: json['loans'] != null
          ? (json['loans'] as List).map((e) => Loan.fromJson(e)).toList()
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List).map((e) => Payment.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'id_number': idNumber,
      'address': address,
      'business_name': businessName,
      'status': status,
      'credit_limit': creditLimit,
      'total_borrowed': totalBorrowed,
      'total_paid': totalPaid,
      'loan_count': loanCount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // Get outstanding balance
  double get outstandingBalance => totalBorrowed - totalPaid;

  // Check if customer can borrow more
  bool canBorrow(double amount) {
    return outstandingBalance + amount <= creditLimit;
  }
}
