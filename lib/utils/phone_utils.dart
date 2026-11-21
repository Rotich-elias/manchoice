/// Phone-number normalisation shared by all payment entry points.
class PhoneUtils {
  PhoneUtils._();

  /// Converts Kenyan local (07...) numbers to the international 254... format
  /// expected by Safaricom's STK Push API. Already-international numbers are
  /// returned unchanged.
  static String toMpesaFormat(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('254') && digits.length == 12) return digits;
    if (digits.startsWith('0') && digits.length == 10) {
      return '254${digits.substring(1)}';
    }
    return digits;
  }

  /// Converts an international number back to the local 07... format used by
  /// the backend's manual-payment endpoints.
  static String toLocalFormat(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('254') && digits.length == 12) {
      return '0${digits.substring(3)}';
    }
    return digits;
  }

  static bool isValidKenyanPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return RegExp(r'^(0|254)[0-9]{9}$').hasMatch(digits);
  }
}
