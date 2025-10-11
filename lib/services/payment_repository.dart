import '../config/api_config.dart';
import '../models/payment.dart';
import 'api_service.dart';

class PaymentRepository {
  final ApiService _apiService = ApiService();

  // Get all payments
  Future<List<Payment>> getAllPayments({int page = 1}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.payments,
        queryParameters: {'page': page},
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => Payment.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch payments: $e');
    }
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.payments}/$id');

      if (response.data['success'] == true) {
        return Payment.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch payment: $e');
    }
  }

  // Create payment
  Future<Payment?> createPayment({
    required int loanId,
    required double amount,
    required String paymentMethod,
    DateTime? paymentDate,
    String? phoneNumber,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.payments,
        data: {
          'loan_id': loanId,
          'amount': amount,
          'payment_method': paymentMethod,
          if (paymentDate != null)
            'payment_date': paymentDate.toIso8601String().split('T')[0],
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return Payment.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Initiate M-PESA STK Push
  Future<Map<String, dynamic>?> initiateMpesaPayment({
    required int loanId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.mpesaStkPush,
        data: {
          'loan_id': loanId,
          'phone_number': phoneNumber,
          'amount': amount,
        },
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to initiate M-PESA payment: $e');
    }
  }

  // Check M-PESA payment status
  Future<Payment?> checkMpesaPaymentStatus(String checkoutRequestId) async {
    try {
      final response = await _apiService.post(
        ApiConfig.mpesaCheckStatus,
        data: {'checkout_request_id': checkoutRequestId},
      );

      if (response.data['success'] == true) {
        return Payment.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to check payment status: $e');
    }
  }

  // Reverse payment
  Future<bool> reversePayment(int id) async {
    try {
      final response = await _apiService.post('${ApiConfig.payments}/$id/reverse');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to reverse payment: $e');
    }
  }

  // Delete payment
  Future<bool> deletePayment(int id) async {
    try {
      final response = await _apiService.delete('${ApiConfig.payments}/$id');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete payment: $e');
    }
  }
}
