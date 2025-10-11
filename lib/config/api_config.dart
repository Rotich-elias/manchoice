class ApiConfig {
  // Base URL for the API
  // Change this based on your device type:

  // Option 1: For Physical Device (RECOMMENDED - Current network IP)
  static const String baseUrl = 'http://192.168.100.65:8000/api';

  // Option 2: For Android Emulator, uncomment the line below:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Option 3: For iOS Simulator, uncomment the line below:
  // static const String baseUrl = 'http://localhost:8000/api';

  // Option 4: For Chrome/Web, uncomment the line below:
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
