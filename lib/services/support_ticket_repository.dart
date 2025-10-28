import '../models/support_ticket.dart';
import 'api_service.dart';

class SupportTicketRepository {
  final ApiService _apiService = ApiService();

  /// Submit a new support ticket
  Future<Map<String, dynamic>> submitTicket({
    required String type,
    required String subject,
    required String message,
    String priority = 'medium',
    String? contactEmail,
    String? contactPhone,
  }) async {
    try {
      final response = await _apiService.post(
        '/support-tickets',
        data: {
          'type': type,
          'subject': subject,
          'message': message,
          'priority': priority,
          if (contactEmail != null) 'contact_email': contactEmail,
          if (contactPhone != null) 'contact_phone': contactPhone,
        },
      );

      if (response.data['success'] == true) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to submit ticket');
      }
    } catch (e) {
      throw Exception('Error submitting ticket: $e');
    }
  }

  /// Get all support tickets for the current user
  Future<List<SupportTicket>> getUserTickets({String? status}) async {
    try {
      String endpoint = '/support-tickets';
      if (status != null) {
        endpoint += '?status=$status';
      }

      final response = await _apiService.get(endpoint);

      if (response.data['success'] == true) {
        final List<dynamic> ticketsJson = response.data['data'] as List<dynamic>;
        return ticketsJson
            .map((json) => SupportTicket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load tickets');
      }
    } catch (e) {
      throw Exception('Error loading tickets: $e');
    }
  }

  /// Get a single ticket by ID
  Future<SupportTicket> getTicketById(int id) async {
    try {
      final response = await _apiService.get('/support-tickets/$id');

      if (response.data['success'] == true) {
        final Map<String, dynamic> ticketJson =
            response.data['data'] as Map<String, dynamic>;
        return SupportTicket.fromJson(ticketJson);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load ticket');
      }
    } catch (e) {
      throw Exception('Error loading ticket: $e');
    }
  }

  /// Submit a deposit rejection dispute ticket
  Future<Map<String, dynamic>> submitDepositRejectionDispute({
    required int loanId,
    required int depositId,
    required String rejectionReason,
    required String disputeMessage,
    String? contactPhone,
  }) async {
    try {
      final subject = 'Deposit Rejection Dispute - Loan #$loanId';
      final message = '''
Dispute Type: Deposit Payment Rejection
Loan ID: $loanId
Deposit ID: $depositId
Rejection Reason: $rejectionReason

Customer's Message:
$disputeMessage

The customer is disputing the rejection of their deposit payment and requests a review.
''';

      return await submitTicket(
        type: 'deposit_dispute',
        subject: subject,
        message: message,
        priority: 'high',
        contactPhone: contactPhone,
      );
    } catch (e) {
      throw Exception('Error submitting deposit dispute: $e');
    }
  }

  /// Submit a rejection limit reached support request
  Future<Map<String, dynamic>> submitRejectionLimitSupport({
    required int loanId,
    required int rejectionCount,
    required String customerMessage,
    String? contactPhone,
  }) async {
    try {
      final subject = 'Rejection Limit Reached - Loan #$loanId';
      final message = '''
Issue Type: Rejection Limit Reached
Loan ID: $loanId
Total Rejections: $rejectionCount

Customer's Message:
$customerMessage

The customer has reached the rejection limit and needs assistance to complete their deposit payment.
''';

      return await submitTicket(
        type: 'rejection_limit',
        subject: subject,
        message: message,
        priority: 'high',
        contactPhone: contactPhone,
      );
    } catch (e) {
      throw Exception('Error submitting rejection limit support request: $e');
    }
  }
}
