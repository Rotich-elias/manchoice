import '../models/deposit.dart';
import 'api_service.dart';

class DepositRepository {
  final ApiService _apiService = ApiService();

  // Get deposit status for a loan
  Future<Map<String, dynamic>> getDepositStatus(int loanId) async {
    try {
      final response = await _apiService.get('/loans/$loanId/deposit/status');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'deposit_required': data['deposit_required'] ?? true,
          'deposit_amount': double.parse(data['deposit_amount']?.toString() ?? '0'),
          'deposit_paid': double.parse(data['deposit_paid']?.toString() ?? '0'),
          'remaining_deposit': double.parse(data['remaining_deposit']?.toString() ?? '0'),
          'is_deposit_paid': data['is_deposit_paid'] ?? false,
          'deposit_paid_at': data['deposit_paid_at'],
          'deposits': data['deposits'] != null
              ? (data['deposits'] as List).map((e) => Deposit.fromJson(e)).toList()
              : <Deposit>[],
        };
      }
      throw Exception('Failed to get deposit status');
    } catch (e) {
      throw Exception('Failed to fetch deposit status: $e');
    }
  }

  // Initiate M-PESA deposit payment
  Future<Map<String, dynamic>> initiateMpesaPayment({
    required int loanId,
    required String phoneNumber,
    double? amount,
  }) async {
    try {
      final response = await _apiService.post(
        '/loans/$loanId/deposit/mpesa',
        data: {
          'phone_number': phoneNumber,
          if (amount != null) 'amount': amount,
        },
      );

      if (response.data['success'] == true) {
        return {
          'deposit_id': response.data['data']['deposit_id'],
          'transaction_id': response.data['data']['transaction_id'],
          'amount': response.data['data']['amount'],
          'phone_number': response.data['data']['phone_number'],
          'remaining_after_payment': response.data['data']['remaining_after_payment'],
          'message': response.data['message'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to initiate payment');
    } catch (e) {
      throw Exception('Failed to initiate M-PESA payment: $e');
    }
  }

  // Verify M-PESA deposit payment
  Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    try {
      final response = await _apiService.post(
        '/deposits/verify',
        data: {'transaction_id': transactionId},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'deposit': data['deposit'] != null ? Deposit.fromJson(data['deposit']) : null,
          'loan': data['loan'],
          'is_deposit_fully_paid': data['is_deposit_fully_paid'] ?? false,
          'message': response.data['message'],
        };
      }
      throw Exception(response.data['message'] ?? 'Payment verification failed');
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Get all deposits for a loan
  Future<List<Deposit>> getLoanDeposits(int loanId) async {
    try {
      final response = await _apiService.get('/loans/$loanId/deposits');

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((e) => Deposit.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch loan deposits: $e');
    }
  }

  // Record cash deposit payment (admin only)
  Future<Deposit> recordCashPayment({
    required int loanId,
    required double amount,
    required String phoneNumber,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/deposits/cash',
        data: {
          'loan_id': loanId,
          'amount': amount,
          'phone_number': phoneNumber,
          'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return Deposit.fromJson(response.data['data']['deposit']);
      }
      throw Exception(response.data['message'] ?? 'Failed to record payment');
    } catch (e) {
      throw Exception('Failed to record cash payment: $e');
    }
  }

  // Get all deposits (admin only)
  Future<List<Deposit>> getAllDeposits({
    int page = 1,
    String? status,
    int? loanId,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (status != null) queryParams['status'] = status;
      if (loanId != null) queryParams['loan_id'] = loanId;

      final response = await _apiService.get(
        '/deposits',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => Deposit.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch deposits: $e');
    }
  }
}
