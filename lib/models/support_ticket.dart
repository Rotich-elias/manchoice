class SupportTicket {
  final int id;
  final String ticketNumber;
  final String type;
  final String subject;
  final String message;
  final String priority;
  final String status;
  final String? adminResponse;
  final String? contactEmail;
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.type,
    required this.subject,
    required this.message,
    required this.priority,
    required this.status,
    this.adminResponse,
    this.contactEmail,
    this.contactPhone,
    required this.createdAt,
    this.resolvedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int,
      ticketNumber: json['ticket_number'] as String,
      type: json['type'] as String,
      subject: json['subject'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      adminResponse: json['admin_response'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'type': type,
      'subject': subject,
      'message': message,
      'priority': priority,
      'status': status,
      'admin_response': adminResponse,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }

  // Helper methods
  String get typeLabel {
    switch (type) {
      case 'bug':
        return 'Bug Report';
      case 'feature_request':
        return 'Feature Request';
      case 'help':
        return 'Help/Support';
      case 'complaint':
        return 'Complaint';
      case 'feedback':
        return 'Feedback';
      default:
        return 'Other';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  bool get isResolved => status == 'resolved' || status == 'closed';
  bool get hasResponse => adminResponse != null && adminResponse!.isNotEmpty;
}
