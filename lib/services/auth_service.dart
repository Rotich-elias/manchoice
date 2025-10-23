import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
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

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String pin,
    required String pinConfirmation,
  }) async {
    try {
      // Clear any existing photo paths from previous users
      await _clearStoredPhotoPaths();

      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'pin': pin,
          'pin_confirmation': pinConfirmation,
        },
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
    } catch (e) {
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
