import '../models/registration_fee.dart';
import 'api_service.dart';

class RegistrationFeeRepository {
  final ApiService _apiService = ApiService();

  // Get registration fee status for current user
  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await _apiService.get('/registration-fee/status');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'fee_paid': data['fee_paid'] ?? false,
          'amount': double.parse(data['amount']?.toString() ?? '300'),
          'registration_fee': data['registration_fee'] != null
              ? RegistrationFee.fromJson(data['registration_fee'])
              : null,
        };
      }
      throw Exception('Failed to get registration fee status');
    } catch (e) {
      throw Exception('Failed to fetch registration fee status: $e');
    }
  }

  // Initiate M-PESA payment for registration fee
  Future<Map<String, dynamic>> initiateMpesaPayment(String phoneNumber) async {
    try {
      final response = await _apiService.post(
        '/registration-fee/mpesa',
        data: {'phone_number': phoneNumber},
      );

      if (response.data['success'] == true) {
        return {
          'transaction_id': response.data['data']['transaction_id'],
          'amount': response.data['data']['amount'],
          'phone_number': response.data['data']['phone_number'],
          'message': response.data['message'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to initiate payment');
    } catch (e) {
      throw Exception('Failed to initiate M-PESA payment: $e');
    }
  }

  // Submit manual payment with transaction ID
  Future<Map<String, dynamic>> submitManualPayment({
    required String phoneNumber,
    required String transactionId,
    required double amount,
  }) async {
    try {
      final response = await _apiService.post(
        '/registration-fee/manual',
        data: {
          'phone_number': phoneNumber,
          'mpesa_code': transactionId,
          'amount': amount,
        },
      );

      if (response.data['success'] == true) {
        return {
          'status': response.data['data']['status'],
          'registration_fee': response.data['data']['registration_fee'] != null
              ? RegistrationFee.fromJson(response.data['data']['registration_fee'])
              : null,
          'message': response.data['message'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to submit payment');
    } catch (e) {
      throw Exception('Failed to submit payment: $e');
    }
  }

  // Verify M-PESA payment
  Future<Map<String, dynamic>> verifyPayment(String transactionId) async {
    try {
      final response = await _apiService.post(
        '/registration-fee/verify',
        data: {'transaction_id': transactionId},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        return {
          'status': data['status'],
          'fee_paid': data['fee_paid'] ?? false,
          'registration_fee': data['registration_fee'] != null
              ? RegistrationFee.fromJson(data['registration_fee'])
              : null,
          'message': response.data['message'],
        };
      }
      throw Exception(response.data['message'] ?? 'Payment verification failed');
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }

  // Record cash payment (admin only)
  Future<RegistrationFee> recordCashPayment({
    required int userId,
    required String phoneNumber,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/registration-fee/cash',
        data: {
          'user_id': userId,
          'phone_number': phoneNumber,
          'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return RegistrationFee.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to record payment');
    } catch (e) {
      throw Exception('Failed to record cash payment: $e');
    }
  }

  // Get all registration fees (admin only)
  Future<List<RegistrationFee>> getAllRegistrationFees({
    int page = 1,
    String? status,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        '/registration-fees',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => RegistrationFee.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch registration fees: $e');
    }
  }
}
