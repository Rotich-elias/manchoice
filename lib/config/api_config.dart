class ApiConfig {
  // Environment detection
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // Base URLs
  static const String _devBaseUrl = 'http://192.168.100.66:8000/api';

  // TODO: Update this with your production backend URL after deployment
  static const String _prodBaseUrl = 'https://your-backend-url.com/api';
  // Example: 'https://api.manchoice.com/api'
  // Example: 'https://manchoice-api.herokuapp.com/api'

  // Auto-select base URL based on environment
  static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;

  // Alternative URLs for different devices (Development only)
  // Uncomment and use these if needed during development:

  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // For iOS Simulator or Chrome/Web:
  // static const String baseUrl = 'http://localhost:8000/api';

  // API Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';

  static const String customers = '/customers';
  static const String loans = '/loans';
  static const String payments = '/payments';
  static const String products = '/products';

  static const String mpesaStkPush = '/mpesa/stk-push';
  static const String mpesaCheckStatus = '/mpesa/check-status';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
