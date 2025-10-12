import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String pin,
    required String pinConfirmation,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'name': name,
          'phone': phone,
          'pin': pin,
          'pin_confirmation': pinConfirmation,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['access_token'];

        // Save token
        await _apiService.saveToken(token);

        return {
          'success': true,
          'user': User.fromJson(data['user']),
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

        // Save token
        await _apiService.saveToken(token);

        return {
          'success': true,
          'user': User.fromJson(data['user']),
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
      return true;
    } catch (e) {
      // Even if the request fails, remove token locally
      await _apiService.removeToken();
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
