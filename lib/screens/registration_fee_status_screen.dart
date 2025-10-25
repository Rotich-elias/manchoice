import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegistrationFeeStatusScreen extends StatelessWidget {
  const RegistrationFeeStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get payment status from route arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String status = args['status'] ?? 'not_submitted';
    final Map<String, dynamic> paymentStatus = args['payment_status'] ?? {};
    final String? userPhone = args['user_phone'];

    // Debug logging
    print('RegistrationFeeStatusScreen - Status: $status');
    print('RegistrationFeeStatusScreen - User Phone: $userPhone');
    print('RegistrationFeeStatusScreen - Payment Status: $paymentStatus');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusIcon(status),
              const SizedBox(height: 32),
              _buildStatusTitle(status),
              const SizedBox(height: 16),
              _buildStatusMessage(status, paymentStatus),
              const SizedBox(height: 32),
              _buildStatusDetails(status, paymentStatus),
              const Spacer(),
              _buildActionButtons(status, userPhone),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'pending_verification':
        icon = Icons.pending_actions;
        color = Colors.orange;
        break;
      case 'rejected':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case 'not_submitted':
      default:
        icon = Icons.payment;
        color = Colors.blue;
        break;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 64,
        color: color,
      ),
    );
  }

  Widget _buildStatusTitle(String status) {
    String title;
    Color color;

    switch (status) {
      case 'pending_verification':
        title = 'Payment Pending Verification';
        color = Colors.orange.shade700;
        break;
      case 'rejected':
        title = 'Payment Rejected';
        color = Colors.red.shade700;
        break;
      case 'not_submitted':
      default:
        title = 'Registration Fee Required';
        color = Colors.blue.shade700;
        break;
    }

    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatusMessage(String status, Map<String, dynamic> paymentStatus) {
    String message = paymentStatus['message'] ?? 'Please complete your registration fee payment.';

    return Text(
      message,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatusDetails(String status, Map<String, dynamic> paymentStatus) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDetailRow(
              'Registration Fee',
              'KES ${(paymentStatus['fee_amount'] ?? 300.0).toStringAsFixed(2)}',
              Icons.money,
              Colors.green,
            ),
            if (status == 'pending_verification') ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Status',
                'Awaiting Verification',
                Icons.hourglass_empty,
                Colors.orange,
              ),
              if (paymentStatus['mpesa_code'] != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  'M-PESA Code',
                  paymentStatus['mpesa_code'],
                  Icons.receipt,
                  Colors.blue,
                ),
              ],
              if (paymentStatus['submitted_at'] != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  'Submitted',
                  _formatDate(paymentStatus['submitted_at']),
                  Icons.calendar_today,
                  Colors.grey,
                ),
              ],
            ],
            if (status == 'rejected' && paymentStatus['rejection_reason'] != null) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            paymentStatus['rejection_reason'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(String status, String? userPhone) {
    return Column(
      children: [
        if (status == 'not_submitted' || status == 'rejected') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Pass user phone to pre-fill the form
                Get.offAllNamed('/registration-fee', arguments: {
                  'phone': userPhone,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                status == 'rejected' ? 'Retry Payment' : 'Pay Registration Fee',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        if (status == 'pending_verification') ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your payment will be verified by our admin team within a few hours.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Get.offAllNamed('/registration-fee');
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue.shade700),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Check Payment Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Get.offAllNamed('/login');
          },
          child: const Text(
            'Back to Login',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      DateTime dateTime = date is DateTime ? date : DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date.toString();
    }
  }
}
