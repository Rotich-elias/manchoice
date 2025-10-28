import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/deposit.dart';
import '../models/loan.dart';

/// Service to handle deposit-related notifications and alerts
class DepositNotificationService {
  /// Show rejection notification when deposit is rejected
  static void showRejectionNotification({
    required Deposit deposit,
    Loan? loan,
  }) {
    Get.snackbar(
      'Deposit Payment Rejected',
      deposit.rejectionReason ?? 'Your payment was rejected. Please retry with a valid M-PESA code.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      isDismissible: true,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          if (loan != null) {
            Get.toNamed('/deposit-status', arguments: {
              'status': 'rejected',
              'deposit': deposit,
              'loan': loan,
              'deposit_amount': deposit.amount,
              'rejection_reason': deposit.rejectionReason,
            });
          }
        },
        child: const Text(
          'View Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Show rejection limit warning
  static void showRejectionLimitWarning({
    required int rejectionCount,
    required int loanId,
  }) {
    final remainingAttempts = 3 - rejectionCount;

    Get.snackbar(
      'Payment Rejection Warning',
      remainingAttempts > 0
          ? 'You have $remainingAttempts attempt(s) remaining before your account is locked.'
          : 'Rejection limit reached. Please contact support.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: remainingAttempts > 0 ? Colors.orange.shade700 : Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      isDismissible: true,
      icon: Icon(
        remainingAttempts > 0 ? Icons.warning : Icons.block,
        color: Colors.white,
      ),
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          if (remainingAttempts <= 0) {
            Get.toNamed('/support');
          }
        },
        child: Text(
          remainingAttempts > 0 ? 'Dismiss' : 'Contact Support',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Show success notification when deposit is verified
  static void showVerificationSuccessNotification({
    required Deposit deposit,
    Loan? loan,
  }) {
    Get.snackbar(
      'Payment Verified',
      'Your deposit payment has been successfully verified!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          if (loan != null) {
            Get.toNamed('/deposit-status', arguments: {
              'status': 'completed',
              'deposit': deposit,
              'loan': loan,
              'deposit_amount': deposit.amount,
            });
          }
        },
        child: const Text(
          'View Loan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Show pending verification reminder
  static void showPendingVerificationReminder({
    required Deposit deposit,
    Loan? loan,
  }) {
    Get.snackbar(
      'Payment Pending Verification',
      'Your payment is awaiting admin verification. This usually takes a few hours.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      icon: const Icon(Icons.hourglass_empty, color: Colors.white),
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // Close snackbar
          if (loan != null) {
            Get.toNamed('/deposit-status', arguments: {
              'status': 'pending',
              'deposit': deposit,
              'loan': loan,
              'deposit_amount': deposit.amount,
            });
          }
        },
        child: const Text(
          'View Status',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Show dialog for rejection limit reached
  static Future<void> showRejectionLimitDialog({
    required BuildContext context,
    required int rejectionCount,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red.shade700, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Rejection Limit Reached',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your deposit payment has been rejected $rejectionCount times.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'To continue, please contact our support team who will assist you with your payment.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red.shade900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              Get.toNamed('/support');
            },
            icon: const Icon(Icons.support_agent, size: 18),
            label: const Text('Contact Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
