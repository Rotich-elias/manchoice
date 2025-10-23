import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/loan.dart';
import '../models/loan_item.dart';
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
    List<LoanItemRequest>? items,
    // Photo paths
    String? bikePhotoPath,
    String? logbookPhotoPath,
    String? passportPhotoPath,
    String? idPhotoFrontPath,
    String? idPhotoBackPath,
    String? nextOfKinIdFrontPath,
    String? nextOfKinIdBackPath,
    String? nextOfKinPassportPhotoPath,
    String? guarantorIdFrontPath,
    String? guarantorIdBackPath,
    String? guarantorPassportPhotoPath,
    String? guarantorBikePhotoPath,
    String? guarantorLogbookPhotoPath,
  }) async {
    try {
      // Create FormData for multipart file upload
      final formData = FormData.fromMap({
        'customer_id': customerId,
        'principal_amount': principalAmount,
        if (interestRate != null) 'interest_rate': interestRate,
        if (durationDays != null) 'duration_days': durationDays,
        if (dueDate != null) 'due_date': dueDate.toIso8601String().split('T')[0],
        if (purpose != null) 'purpose': purpose,
        if (notes != null) 'notes': notes,
      });

      // Add loan items as JSON string if provided
      if (items != null && items.isNotEmpty) {
        for (int i = 0; i < items.length; i++) {
          formData.fields.add(MapEntry('items[$i][product_id]', items[i].productId.toString()));
          formData.fields.add(MapEntry('items[$i][quantity]', items[i].quantity.toString()));
        }
      }

      // Add photo files (not paths)
      if (bikePhotoPath != null) {
        formData.files.add(MapEntry('bike_photo', await MultipartFile.fromFile(bikePhotoPath, filename: bikePhotoPath.split('/').last)));
      }
      if (logbookPhotoPath != null) {
        formData.files.add(MapEntry('logbook_photo', await MultipartFile.fromFile(logbookPhotoPath, filename: logbookPhotoPath.split('/').last)));
      }
      if (passportPhotoPath != null) {
        formData.files.add(MapEntry('passport_photo', await MultipartFile.fromFile(passportPhotoPath, filename: passportPhotoPath.split('/').last)));
      }
      if (idPhotoFrontPath != null) {
        formData.files.add(MapEntry('id_photo_front', await MultipartFile.fromFile(idPhotoFrontPath, filename: idPhotoFrontPath.split('/').last)));
      }
      if (idPhotoBackPath != null) {
        formData.files.add(MapEntry('id_photo_back', await MultipartFile.fromFile(idPhotoBackPath, filename: idPhotoBackPath.split('/').last)));
      }
      if (nextOfKinIdFrontPath != null) {
        formData.files.add(MapEntry('next_of_kin_id_front', await MultipartFile.fromFile(nextOfKinIdFrontPath, filename: nextOfKinIdFrontPath.split('/').last)));
      }
      if (nextOfKinIdBackPath != null) {
        formData.files.add(MapEntry('next_of_kin_id_back', await MultipartFile.fromFile(nextOfKinIdBackPath, filename: nextOfKinIdBackPath.split('/').last)));
      }
      if (nextOfKinPassportPhotoPath != null) {
        formData.files.add(MapEntry('next_of_kin_passport_photo', await MultipartFile.fromFile(nextOfKinPassportPhotoPath, filename: nextOfKinPassportPhotoPath.split('/').last)));
      }
      if (guarantorIdFrontPath != null) {
        formData.files.add(MapEntry('guarantor_id_front', await MultipartFile.fromFile(guarantorIdFrontPath, filename: guarantorIdFrontPath.split('/').last)));
      }
      if (guarantorIdBackPath != null) {
        formData.files.add(MapEntry('guarantor_id_back', await MultipartFile.fromFile(guarantorIdBackPath, filename: guarantorIdBackPath.split('/').last)));
      }
      if (guarantorPassportPhotoPath != null) {
        formData.files.add(MapEntry('guarantor_passport_photo', await MultipartFile.fromFile(guarantorPassportPhotoPath, filename: guarantorPassportPhotoPath.split('/').last)));
      }
      if (guarantorBikePhotoPath != null) {
        formData.files.add(MapEntry('guarantor_bike_photo', await MultipartFile.fromFile(guarantorBikePhotoPath, filename: guarantorBikePhotoPath.split('/').last)));
      }
      if (guarantorLogbookPhotoPath != null) {
        formData.files.add(MapEntry('guarantor_logbook_photo', await MultipartFile.fromFile(guarantorLogbookPhotoPath, filename: guarantorLogbookPhotoPath.split('/').last)));
      }

      final response = await _apiService.post(
        ApiConfig.loans,
        data: formData,
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
