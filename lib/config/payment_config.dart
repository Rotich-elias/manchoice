/// Business payment settings.
///
/// Values can be overridden at build time, e.g.:
///   flutter build apk --release \
///     --dart-define=MPESA_PAYBILL=123456 \
///     --dart-define=MPESA_ACCOUNT=987654 \
///     --dart-define=LOAN_INTEREST_PERCENT=30 \
///     --dart-define=REGISTRATION_FEE=300
///
/// Keeping these in one place avoids mismatched paybill/account numbers
/// across the payment, deposit and checkout screens.
class PaymentConfig {
  static const String paybillNumber =
      String.fromEnvironment('MPESA_PAYBILL', defaultValue: '247247');

  static const String accountNumber =
      String.fromEnvironment('MPESA_ACCOUNT', defaultValue: '846828');

  static const int interestPercent =
      int.fromEnvironment('LOAN_INTEREST_PERCENT', defaultValue: 30);

  static const double interestRate = interestPercent / 100;

  static const int _registrationFeeInt =
      int.fromEnvironment('REGISTRATION_FEE', defaultValue: 300);

  static double get registrationFee => _registrationFeeInt.toDouble();

  static const String supportPhone =
      String.fromEnvironment('SUPPORT_PHONE', defaultValue: '0110846828');
}
