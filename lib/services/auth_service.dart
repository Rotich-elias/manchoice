import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'cart_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Clear all stored photo paths from loan application
  Future<void> _clearStoredPhotoPaths() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all photo paths from SharedPreferences
      await prefs.remove('bike_photo_path');
      await prefs.remove('logbook_photo_path');
      await prefs.remove('passport_photo_path');
      await prefs.remove('id_photo_front_path');
      await prefs.remove('id_photo_back_path');
      await prefs.remove('kin_id_front_photo_path');
      await prefs.remove('kin_id_back_photo_path');
      await prefs.remove('kin_passport_photo_path');
      await prefs.remove('guarantor_id_front_photo_path');
      await prefs.remove('guarantor_id_back_photo_path');
      await prefs.remove('guarantor_passport_photo_path');
    } catch (e) {
      // Silently fail if clearing fails
    }
  }

  // Lookup customer by ID number or phone
  Future<Map<String, dynamic>> lookupCustomer({
    String? phone,
    String? idNumber,
  }) async {
    try {
      // Validate that at least one parameter is provided
      if ((phone == null || phone.isEmpty) && (idNumber == null || idNumber.isEmpty)) {
        return {
          'success': false,
          'message': 'Please provide either phone number or ID number',
        };
      }

      final Map<String, dynamic> data = {};
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }
      if (idNumber != null && idNumber.isNotEmpty) {
        data['id_number'] = idNumber;
      }

      final response = await _apiService.post(
        ApiConfig.lookupCustomer,
        data: data,
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'customer': response.data['data'],
          'message': response.data['message'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Customer not found',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String pin,
    required String pinConfirmation,
    bool acceptedTerms = true,
    int? customerId,  // Optional: link to existing customer
    bool claimExisting = false,  // Whether claiming existing customer record
  }) async {
    try {
      // Clear any existing photo paths from previous users
      await _clearStoredPhotoPaths();

      final Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
        'email': email,
        'pin': pin,
        'pin_confirmation': pinConfirmation,
        'accepted_terms': acceptedTerms,
      };

      // Add customer linking fields if provided
      if (customerId != null) {
        data['customer_id'] = customerId;
        data['claim_existing'] = claimExisting;
      }

      final response = await _apiService.post(
        ApiConfig.register,
        data: data,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['access_token'];
        final user = User.fromJson(data['user']);

        // Save token
        await _apiService.saveToken(token);

        // Switch to user's cart (start with empty cart for new user)
        try {
          final cartService = Get.find<CartService>();
          await cartService.switchToUserCart(user.id.toString());
        } catch (e) {
          // CartService might not be initialized, that's okay
        }

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String phone,
    required String pin,
  }) async {
    try {
      // Clear any existing photo paths from previous users
      await _clearStoredPhotoPaths();

      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'phone': phone,
          'pin': pin,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['access_token'];
        final user = User.fromJson(data['user']);

        // Save token
        await _apiService.saveToken(token);

        // Switch to user's cart
        try {
          final cartService = Get.find<CartService>();
          await cartService.switchToUserCart(user.id.toString());
        } catch (e) {
          // CartService might not be initialized, that's okay
        }

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Login failed',
      };
    } on DioException catch (e) {
      // Handle 402 Payment Required - Registration fee not verified
      print('AuthService - DioException caught. Status: ${e.response?.statusCode}');
      print('AuthService - Response data: ${e.response?.data}');

      if (e.response?.statusCode == 402) {
        final responseData = e.response?.data;
        print('AuthService - 402 Response: $responseData');
        print('AuthService - requires_registration_fee value: ${responseData?['requires_registration_fee']}');
        print('AuthService - registration_fee_status value: ${responseData?['registration_fee_status']}');

        if (responseData != null && responseData['requires_registration_fee'] == true) {
          final result = {
            'success': false,
            'requires_registration_fee': true,
            'registration_fee_status': responseData['registration_fee_status'],
            'payment_status': responseData['data']?['payment_status'],
            'user_phone': responseData['data']?['user']?['phone'],
            'message': responseData['message'],
          };
          print('AuthService - Returning registration fee result: $result');
          return result;
        } else {
          print('AuthService - 402 but requires_registration_fee is not true or responseData is null');
        }
      }

      // Handle other errors
      print('AuthService - Returning error result');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? e.message ?? 'Login failed',
      };
    } catch (e) {
      print('AuthService - General exception: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      await _apiService.post(ApiConfig.logout);
      await _apiService.removeToken();
      // Clear all stored photo paths
      await _clearStoredPhotoPaths();

      // Clear cart data for current user
      try {
        final cartService = Get.find<CartService>();
        await cartService.onLogout();
      } catch (e) {
        // CartService might not be initialized, that's okay
      }

      return true;
    } catch (e) {
      // Even if the request fails, remove token locally
      await _apiService.removeToken();
      // Clear all stored photo paths
      await _clearStoredPhotoPaths();

      // Clear cart data for current user
      try {
        final cartService = Get.find<CartService>();
        await cartService.onLogout();
      } catch (e) {
        // CartService might not be initialized, that's okay
      }

      return false;
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConfig.user);

      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _apiService.isAuthenticated;
  }

  // Mark profile as completed
  Future<Map<String, dynamic>> completeProfile({
    required int customerId,
  }) async {
    try {
      final response = await _apiService.post(
        '${ApiConfig.baseUrl}/complete-profile',
        data: {
          'customer_id': customerId,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(response.data['data']),
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Failed to complete profile',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
