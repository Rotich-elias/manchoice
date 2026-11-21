import 'package:dio/dio.dart';
import '../config/payment_config.dart';
import '../models/deposit.dart';
import '../utils/phone_utils.dart';
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
          'rejection_count': data['rejection_count'] ?? 0,
          'has_reached_rejection_limit':
              data['has_reached_rejection_limit'] ?? false,
          'can_retry': data['can_retry'] ?? true,
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
          'phone_number': PhoneUtils.toLocalFormat(phoneNumber),
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
    } on DioException catch (e) {
      // Pass through the full response data for popup handling
      if (e.response?.data != null) {
        throw e.response!.data;
      }
      throw Exception('Failed to initiate M-PESA payment: ${e.message}');
    } catch (e) {
      throw Exception('Failed to initiate M-PESA payment: $e');
    }
  }

  // Submit manual deposit payment with M-PESA code
  Future<Map<String, dynamic>> submitManualPayment({
    required int loanId,
    required String phoneNumber,
    required String mpesaCode,
    required double amount,
  }) async {
    try {
      final response = await _apiService.post(
        '/deposits/manual',
        data: {
          'loan_id': loanId,
          'phone_number': PhoneUtils.toLocalFormat(phoneNumber),
          'mpesa_code': mpesaCode,
          'amount': amount,
        },
      );

      if (response.data['success'] == true) {
        return {
          'deposit': response.data['data']['deposit'] != null
              ? Deposit.fromJson(response.data['data']['deposit'])
              : null,
          'status': response.data['data']['status'],
          'message': response.data['message'],
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to submit payment');
    } catch (e) {
      throw Exception('Failed to submit payment: $e');
    }
  }

  // Verify a deposit payment (admin/staff only on the backend).
  Future<Map<String, dynamic>> verifyPayment(
    int depositId, {
    String status = 'completed',
    String? rejectionReason,
  }) async {
    try {
      final response = await _apiService.post(
        '/deposits/$depositId/verify',
        data: {
          'status': status,
          if (rejectionReason != null) 'rejection_reason': rejectionReason,
        },
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

  // Get rejection history for a loan (all rejected deposits)
  Future<List<Deposit>> getRejectionHistory(int loanId) async {
    try {
      final response = await _apiService.get(
        '/loans/$loanId/deposits/rejected',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((e) => Deposit.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // If endpoint doesn't exist yet, fall back to filtering local deposits
      try {
        final allDeposits = await getLoanDeposits(loanId);
        return allDeposits.where((d) => d.isRejected || d.isFailed).toList();
      } catch (e2) {
        throw Exception('Failed to fetch rejection history: $e');
      }
    }
  }

  // Get total rejection count for a loan
  Future<int> getRejectionCount(int loanId) async {
    try {
      final rejectedDeposits = await getRejectionHistory(loanId);
      return rejectedDeposits.length;
    } catch (e) {
      return 0;
    }
  }

  // Check if loan has reached rejection limit
  Future<bool> hasReachedRejectionLimit(int loanId) async {
    try {
      final count = await getRejectionCount(loanId);
      return count >= PaymentConfig.maxDepositRejections;
    } catch (e) {
      return false;
    }
  }

  // Get latest deposit status with rejection info
  Future<Map<String, dynamic>> getDepositStatusWithRejectionInfo(int loanId) async {
    try {
      final statusData = await getDepositStatus(loanId);
      final serverCount = statusData['rejection_count'];
      final rejectionCount = serverCount is int
          ? serverCount
          : await getRejectionCount(loanId);
      final serverFlag = statusData['has_reached_rejection_limit'];
      final hasReachedLimit = serverFlag is bool
          ? serverFlag
          : rejectionCount >= PaymentConfig.maxDepositRejections;

      return {
        ...statusData,
        'rejection_count': rejectionCount,
        'has_reached_rejection_limit': hasReachedLimit,
        'can_retry': !hasReachedLimit,
      };
    } catch (e) {
      throw Exception('Failed to fetch deposit status with rejection info: $e');
    }
  }
}
