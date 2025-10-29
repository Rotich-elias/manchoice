class ApiConfig {
  // Environment detection
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // Base URLs
  static const String _devBaseUrl = 'http://192.168.100.60:8000/api';

  // ⚠️ IMPORTANT: Update this with your production backend URL before deploying!
  // This URL will be used when building release APK/AAB
  static const String _prodBaseUrl = 'https://manschoice.co.ke/api';

  // Example: 'https://api.manchoice.com/api'
  // Example: 'https://manchoice.herokuapp.com/api'
  //
  // To build for production with this URL:
  // flutter build apk --release
  // flutter build appbundle --release

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
  static const String partRequests = '/part-requests';

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

  // Storage URL for images
  static String get storageUrl {
    final base = baseUrl.replaceAll('/api', '');
    return '$base/storage';
  }

  // Helper to get full image URL
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path; // Already full URL
    return '$storageUrl/$path';
  }
}
