import '../services/api_service.dart';

/// Business payment settings.
///
/// Build-time defaults can be overridden, e.g.:
///   flutter build apk --release \
///     --dart-define=MPESA_PAYBILL=123456 \
///     --dart-define=MPESA_ACCOUNT=987654 \
///     --dart-define=LOAN_INTEREST_PERCENT=30 \
///     --dart-define=REGISTRATION_FEE=300
///
/// On startup these are refreshed from the backend's public
/// `GET /config/business` endpoint so the app can never drift from the
/// server's paybill, interest or fee rules. Falls back silently offline.
class PaymentConfig {
  static String paybillNumber =
      const String.fromEnvironment('MPESA_PAYBILL', defaultValue: '247247');

  static String accountNumber =
      const String.fromEnvironment('MPESA_ACCOUNT', defaultValue: '846828');

  static int interestPercent =
      const int.fromEnvironment('LOAN_INTEREST_PERCENT', defaultValue: 30);

  static double get interestRate => interestPercent / 100;

  static double registrationFee = const int.fromEnvironment(
    'REGISTRATION_FEE',
    defaultValue: 300,
  ).toDouble();

  static String supportPhone =
      const String.fromEnvironment('SUPPORT_PHONE', defaultValue: '0110846828');

  static double depositPercent =
      const int.fromEnvironment('LOAN_DEPOSIT_PERCENT', defaultValue: 10)
          .toDouble();

  static int penaltyCapDays =
      const int.fromEnvironment('LATE_PENALTY_CAP_DAYS', defaultValue: 14);

  static int maxDepositRejections =
      const int.fromEnvironment('DEPOSIT_REJECTION_LIMIT', defaultValue: 3);

  static bool _loaded = false;

  /// Fetch canonical values from the backend once per app launch.
  static Future<void> loadFromBackend() async {
    if (_loaded) return;
    try {
      final response = await ApiService()
          .get('/config/business')
          .timeout(const Duration(seconds: 3));
      final payload = response.data;
      final data = payload is Map ? payload['data'] : null;
      if (data is! Map) return;

      paybillNumber = _string(data['paybill_number']) ?? paybillNumber;
      accountNumber = _string(data['account_number']) ?? accountNumber;
      supportPhone = _string(data['support_phone']) ?? supportPhone;
      interestPercent = _int(data['interest_percent']) ?? interestPercent;
      registrationFee = _double(data['registration_fee']) ?? registrationFee;
      depositPercent = _double(data['deposit_percent']) ?? depositPercent;
      penaltyCapDays = _int(data['penalty_cap_days']) ?? penaltyCapDays;
      maxDepositRejections =
          _int(data['max_deposit_rejections']) ?? maxDepositRejections;
      _loaded = true;
    } catch (_) {
      // Offline / older backend: keep build-time defaults and try again later.
    }
  }

  static String? _string(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _int(dynamic value) {
    final number = _double(value);
    return number?.round();
  }

  static double? _double(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }
}
