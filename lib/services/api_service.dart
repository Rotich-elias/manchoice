import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  String? _token;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.headers,
      ),
    );

    // Add interceptors for logging and token injection
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers if available
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          developer.log(
            'REQUEST[${options.method}] => PATH: ${options.path}',
            name: 'ApiService',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            name: 'ApiService',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          developer.log(
            'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            name: 'ApiService',
            error: e.message,
          );
          return handler.next(e);
        },
      ),
    );
  }

  // Get token from storage
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to storage
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Remove token from storage
  Future<void> removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await loadToken();
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await loadToken();
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await loadToken();
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await loadToken();
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(DioException error) {
    String errorMessage = 'An error occurred';

    if (error.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Receive timeout';
    } else if (error.type == DioExceptionType.badResponse) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final data = error.response!.data;

        switch (statusCode) {
          case 400:
            errorMessage = data['message'] ?? 'Bad request';
            break;
          case 401:
            errorMessage = 'Unauthorized';
            break;
          case 403:
            errorMessage = 'Forbidden';
            break;
          case 404:
            errorMessage = 'Not found';
            break;
          case 422:
            // Validation errors
            if (data['errors'] != null) {
              final errors = data['errors'] as Map<String, dynamic>;
              errorMessage = errors.values.first[0];
            } else {
              errorMessage = data['message'] ?? 'Validation failed';
            }
            break;
          case 500:
            errorMessage = 'Server error';
            break;
          default:
            errorMessage = data['message'] ?? 'An error occurred';
        }
      }
    } else if (error.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection';
    }

    return errorMessage;
  }

  // Check if user is authenticated
  bool get isAuthenticated => _token != null;
}
