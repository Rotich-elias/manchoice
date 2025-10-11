import '../config/api_config.dart';
import '../models/customer_api.dart';
import 'api_service.dart';

class CustomerRepository {
  final ApiService _apiService = ApiService();

  // Get all customers
  Future<List<CustomerApi>> getAllCustomers({int page = 1}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.customers,
        queryParameters: {'page': page},
      );

      if (response.data['success'] == true) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => CustomerApi.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch customers: $e');
    }
  }

  // Get customer by ID
  Future<CustomerApi?> getCustomerById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.customers}/$id');

      if (response.data['success'] == true) {
        return CustomerApi.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch customer: $e');
    }
  }

  // Create customer
  Future<CustomerApi?> createCustomer({
    required String name,
    required String phone,
    String? email,
    String? idNumber,
    String? address,
    String? businessName,
    double? creditLimit,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.customers,
        data: {
          'name': name,
          'phone': phone,
          if (email != null) 'email': email,
          if (idNumber != null) 'id_number': idNumber,
          if (address != null) 'address': address,
          if (businessName != null) 'business_name': businessName,
          if (creditLimit != null) 'credit_limit': creditLimit,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return CustomerApi.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  // Update customer
  Future<CustomerApi?> updateCustomer({
    required int id,
    String? name,
    String? phone,
    String? email,
    String? idNumber,
    String? address,
    String? businessName,
    double? creditLimit,
    String? status,
    String? notes,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConfig.customers}/$id',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (idNumber != null) 'id_number': idNumber,
          if (address != null) 'address': address,
          if (businessName != null) 'business_name': businessName,
          if (creditLimit != null) 'credit_limit': creditLimit,
          if (status != null) 'status': status,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.data['success'] == true) {
        return CustomerApi.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(int id) async {
    try {
      final response = await _apiService.delete('${ApiConfig.customers}/$id');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  // Get customer statistics
  Future<Map<String, dynamic>?> getCustomerStats(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.customers}/$id/stats');

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch customer stats: $e');
    }
  }
}
