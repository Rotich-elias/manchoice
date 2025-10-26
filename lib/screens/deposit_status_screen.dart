import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/loan.dart';
import '../models/deposit.dart';

class DepositStatusScreen extends StatelessWidget {
  const DepositStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get deposit status from route arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String status = args['status'] ?? 'not_submitted';
    final Deposit? deposit = args['deposit'];
    final Loan? loan = args['loan'];
    final double depositAmount = args['deposit_amount'] ?? 0.0;
    final String? rejectionReason = args['rejection_reason'];

    // Debug logging
    print('========== DepositStatusScreen ==========');
    print('Raw arguments: $args');
    print('Status: "$status" (type: ${status.runtimeType})');
    print('Deposit: $deposit');
    print('Loan ID: ${loan?.id}');
    print('Status == "rejected": ${status == 'rejected'}');
    print('Status == "failed": ${status == 'failed'}');
    print('================================================');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Deposit Payment Status'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
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
              _buildStatusMessage(status, deposit, depositAmount, rejectionReason),
              const SizedBox(height: 32),
              _buildStatusDetails(status, deposit, depositAmount, rejectionReason),
              const Spacer(),
              _buildActionButtons(status, loan),
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

    if (status == 'pending' || status == 'pending_verification') {
      icon = Icons.pending_actions;
      color = Colors.orange;
    } else if (status == 'rejected' || status == 'failed') {
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (status == 'completed') {
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else {
      icon = Icons.payment;
      color = Colors.blue;
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

    if (status == 'pending' || status == 'pending_verification') {
      title = 'Payment Pending Verification';
      color = Colors.orange.shade700;
    } else if (status == 'rejected' || status == 'failed') {
      title = 'Payment Rejected';
      color = Colors.red.shade700;
    } else if (status == 'completed') {
      title = 'Payment Verified';
      color = Colors.green.shade700;
    } else {
      title = 'Deposit Payment Required';
      color = Colors.blue.shade700;
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

  Widget _buildStatusMessage(String status, Deposit? deposit, double depositAmount, String? rejectionReason) {
    String message;

    if (status == 'pending' || status == 'pending_verification') {
      message = 'Your deposit payment has been submitted and is awaiting admin verification. This usually takes a few hours.';
    } else if (status == 'rejected' || status == 'failed') {
      message = rejectionReason ?? 'Your previous payment was rejected. Please make a new payment with a valid M-PESA transaction code.';
    } else if (status == 'completed') {
      message = 'Your deposit payment has been successfully verified. Your loan is now active!';
    } else {
      message = 'Please complete your deposit payment to activate your loan.';
    }

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

  Widget _buildStatusDetails(String status, Deposit? deposit, double depositAmount, String? rejectionReason) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildDetailRow(
              'Deposit Amount',
              'KES ${depositAmount.toStringAsFixed(2)}',
              Icons.money,
              Colors.green,
            ),
            if (status == 'pending' || status == 'pending_verification') ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Status',
                'Awaiting Verification',
                Icons.hourglass_empty,
                Colors.orange,
              ),
              if (deposit?.mpesaReceiptNumber != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  'M-PESA Code',
                  deposit!.mpesaReceiptNumber!,
                  Icons.receipt,
                  Colors.blue,
                ),
              ],
              if (deposit?.createdAt != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  'Submitted',
                  _formatDate(deposit!.createdAt),
                  Icons.calendar_today,
                  Colors.grey,
                ),
              ],
            ],
            if ((status == 'rejected' || status == 'failed') && rejectionReason != null) ...[
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
                            rejectionReason,
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
            if (status == 'completed' && deposit?.paidAt != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Verified At',
                _formatDate(deposit!.paidAt!),
                Icons.check_circle,
                Colors.green,
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

  Widget _buildActionButtons(String status, Loan? loan) {
    print('_buildActionButtons called with status: "$status", loan: ${loan?.id}');
    print('Should show retry button: ${(status == 'rejected' || status == 'failed')}');

    return Column(
      children: [
        if (status == 'not_submitted' || status == 'rejected' || status == 'failed') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print('Retry Payment button clicked for loan: ${loan?.id}');
                // Navigate back to deposit payment screen
                Get.back();
                if (loan != null) {
                  Get.toNamed('/deposit-payment', arguments: loan);
                }
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
                (status == 'rejected' || status == 'failed') ? 'Retry Payment' : 'Pay Deposit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        if (status == 'pending' || status == 'pending_verification') ...[
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
            child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed('/support');
              },
              icon: const Icon(Icons.support_agent),
              label: const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.blue.shade700),
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        if (status == 'completed') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.offAllNamed('/my-loans');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View My Loans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'Back',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
