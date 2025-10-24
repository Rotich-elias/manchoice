class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool profileCompleted;
  final int? customerId;
  final String? emailVerifiedAt;
  final bool registrationFeePaid;
  final double? registrationFeeAmount;
  final DateTime? registrationFeePaidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileCompleted = false,
    this.customerId,
    this.emailVerifiedAt,
    this.registrationFeePaid = false,
    this.registrationFeeAmount,
    this.registrationFeePaidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileCompleted: json['profile_completed'] ?? false,
      customerId: json['customer_id'],
      emailVerifiedAt: json['email_verified_at'],
      registrationFeePaid: json['registration_fee_paid'] ?? false,
      registrationFeeAmount: json['registration_fee_amount'] != null
          ? double.parse(json['registration_fee_amount'].toString())
          : null,
      registrationFeePaidAt: json['registration_fee_paid_at'] != null
          ? DateTime.parse(json['registration_fee_paid_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_completed': profileCompleted,
      'customer_id': customerId,
      'email_verified_at': emailVerifiedAt,
      'registration_fee_paid': registrationFeePaid,
      'registration_fee_amount': registrationFeeAmount,
      'registration_fee_paid_at': registrationFeePaidAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
