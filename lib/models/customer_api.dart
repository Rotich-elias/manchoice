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
  // Motorcycle Details
  final String? motorcycleNumberPlate;
  final String? motorcycleChassisNumber;
  final String? motorcycleModel;
  final String? motorcycleType;
  final String? motorcycleEngineCC;
  final String? motorcycleColour;
  // Next of Kin Details
  final String? nextOfKinName;
  final String? nextOfKinPhone;
  final String? nextOfKinRelationship;
  // Guarantor Details
  final String? guarantorName;
  final String? guarantorPhone;
  final String? guarantorRelationship;
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
    this.motorcycleNumberPlate,
    this.motorcycleChassisNumber,
    this.motorcycleModel,
    this.motorcycleType,
    this.motorcycleEngineCC,
    this.motorcycleColour,
    this.nextOfKinName,
    this.nextOfKinPhone,
    this.nextOfKinRelationship,
    this.guarantorName,
    this.guarantorPhone,
    this.guarantorRelationship,
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
      motorcycleNumberPlate: json['motorcycle_number_plate'],
      motorcycleChassisNumber: json['motorcycle_chassis_number'],
      motorcycleModel: json['motorcycle_model'],
      motorcycleType: json['motorcycle_type'],
      motorcycleEngineCC: json['motorcycle_engine_cc'],
      motorcycleColour: json['motorcycle_colour'],
      nextOfKinName: json['next_of_kin_name'],
      nextOfKinPhone: json['next_of_kin_phone'],
      nextOfKinRelationship: json['next_of_kin_relationship'],
      guarantorName: json['guarantor_name'],
      guarantorPhone: json['guarantor_phone'],
      guarantorRelationship: json['guarantor_relationship'],
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
