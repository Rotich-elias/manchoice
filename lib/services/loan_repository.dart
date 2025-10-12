import '../config/api_config.dart';
import '../models/loan.dart';
import 'api_service.dart';

class LoanRepository {
  final ApiService _apiService = ApiService();

  // Get all loans
  Future<List<Loan>> getAllLoans({
    int page = 1,
    int? customerId,
    String? status,
    bool? overdue,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (customerId != null) queryParams['customer_id'] = customerId;
      if (status != null) queryParams['status'] = status;
      if (overdue != null) queryParams['overdue'] = overdue.toString();

      final response = await _apiService.get(
        ApiConfig.loans,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => Loan.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch loans: $e');
    }
  }

  // Get loan by ID
  Future<Loan?> getLoanById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.loans}/$id');

      if (response.data['success'] == true) {
        return Loan.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch loan: $e');
    }
  }

  // Create loan
  Future<Loan?> createLoan({
    required int customerId,
    required double principalAmount,
    double? interestRate,
    int? durationDays,
    DateTime? dueDate,
    String? purpose,
    String? notes,
    // Photo paths
    String? bikePhotoPath,
    String? logbookPhotoPath,
    String? passportPhotoPath,
    String? idPhotoPath,
    String? nextOfKinIdPhotoPath,
    String? guarantorIdPhotoPath,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loans,
        data: {
          'customer_id': customerId,
          'principal_amount': principalAmount,
          if (interestRate != null) 'interest_rate': interestRate,
          if (durationDays != null) 'duration_days': durationDays,
          if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T')[0],
          if (purpose != null) 'purpose': purpose,
          if (notes != null) 'notes': notes,
          // Photo paths
          if (bikePhotoPath != null) 'bike_photo_path': bikePhotoPath,
          if (logbookPhotoPath != null) 'logbook_photo_path': logbookPhotoPath,
          if (passportPhotoPath != null) 'passport_photo_path': passportPhotoPath,
          if (idPhotoPath != null) 'id_photo_path': idPhotoPath,
          if (nextOfKinIdPhotoPath != null) 'next_of_kin_id_photo_path': nextOfKinIdPhotoPath,
          if (guarantorIdPhotoPath != null) 'guarantor_id_photo_path': guarantorIdPhotoPath,
        },
      );

      if (response.data['success'] == true) {
        return Loan.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create loan: $e');
    }
  }

  // Update loan
  Future<Loan?> updateLoan({
    required int id,
    double? principalAmount,
    double? interestRate,
    int? durationDays,
    DateTime? dueDate,
    String? purpose,
    String? notes,
    String? status,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.loans}/$id',
        data: {
          if (principalAmount != null) 'principal_amount': principalAmount,
          if (interestRate != null) 'interest_rate': interestRate,
          if (durationDays != null) 'duration_days': durationDays,
          if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T')[0],
          if (purpose != null) 'purpose': purpose,
          if (notes != null) 'notes': notes,
          if (status != null) 'status': status,
        },
      );

      if (response.data['success'] == true) {
        return Loan.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update loan: $e');
    }
  }

  // Approve loan
  Future<Loan?> approveLoan(int id) async {
    try {
      final response = await _apiService.post('${ApiConfig.loans}/$id/approve');

      if (response.data['success'] == true) {
        return Loan.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to approve loan: $e');
    }
  }

  // Reject loan
  Future<Loan?> rejectLoan(int id, String rejectionReason) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.loans}/$id/reject',
        data: {'rejection_reason': rejectionReason},
      );

      if (response.data['success'] == true) {
        return Loan.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to reject loan: $e');
    }
  }

  // Delete loan
  Future<bool> deleteLoan(int id) async {
    try {
      final response = await _apiService.delete('${ApiConfig.loans}/$id');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete loan: $e');
    }
  }
}
