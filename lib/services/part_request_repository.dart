import 'package:dio/dio.dart';
import '../models/part_request.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class PartRequestRepository {
  final ApiService _apiService = ApiService();

  /// Get all part requests for the authenticated user
  Future<List<PartRequest>> getMyRequests() async {
    try {
      final response = await _apiService.get(ApiConfig.partRequests);

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => PartRequest.fromJson(json)).toList();
      }

      throw Exception('Failed to fetch part requests');
    } catch (e) {
      throw Exception('Failed to fetch part requests: $e');
    }
  }

  /// Submit a new part request
  Future<PartRequest?> createRequest({
    required String partName,
    String? description,
    String? motorcycleModel,
    String? year,
    required int quantity,
    double? budget,
    required String urgency,
    String? imagePath,
  }) async {
    try {
      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'part_name': partName,
        'description': description,
        'motorcycle_model': motorcycleModel,
        'year': year,
        'quantity': quantity,
        'budget': budget,
        'urgency': urgency,
      });

      // Add image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              imagePath,
              filename: imagePath.split('/').last,
            ),
          ),
        );
      }

      final response = await _apiService.post(
        ApiConfig.partRequests,
        data: formData,
      );

      if (response.data['success'] == true) {
        return PartRequest.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'Failed to create part request');
    } catch (e) {
      throw Exception('Failed to create part request: $e');
    }
  }

  /// Get a specific part request by ID
  Future<PartRequest?> getRequest(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.partRequests}/$id');

      if (response.data['success'] == true) {
        return PartRequest.fromJson(response.data['data']);
      }

      throw Exception('Failed to fetch part request');
    } catch (e) {
      throw Exception('Failed to fetch part request: $e');
    }
  }

  /// Cancel a part request
  Future<bool> cancelRequest(int id) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.partRequests}/$id/cancel',
      );

      if (response.data['success'] == true) {
        return true;
      }

      throw Exception(response.data['message'] ?? 'Failed to cancel part request');
    } catch (e) {
      throw Exception('Failed to cancel part request: $e');
    }
  }
}
