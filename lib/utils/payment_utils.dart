/// Utility functions for payment processing
class PaymentUtils {
  /// Rounds up any amount to the nearest ten
  /// This is required because M-Pesa does not allow decimal points
  ///
  /// Examples:
  /// - 151 → 160
  /// - 155 → 160
  /// - 154.20 → 160
  /// - 160 → 160
  static double roundUpToNearestTen(double amount) {
    int amountInt = amount.ceil();
    return ((amountInt + 9) ~/ 10 * 10).toDouble();
  }
}
