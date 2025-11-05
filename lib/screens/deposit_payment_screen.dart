import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/loan.dart';
import '../models/deposit.dart';
import '../services/deposit_repository.dart';
import '../utils/payment_utils.dart';
import 'dart:async';

class DepositPaymentScreen extends StatefulWidget {
  const DepositPaymentScreen({super.key});

  @override
  State<DepositPaymentScreen> createState() => _DepositPaymentScreenState();
}

class _DepositPaymentScreenState extends State<DepositPaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionCodeController =
      TextEditingController();
  final DepositRepository _depositRepository = DepositRepository();

  // ⚠️ IMPORTANT: Update this with your actual Safaricom M-PESA paybill number before going live!
  final String mpesaPaybill =
      "247247"; // TODO: Update with your production paybill number

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _payPartial = false;

  Loan? _loan;
  double _depositAmount = 0;
  double _depositPaid = 0;
  double _remainingDeposit = 0;
  bool _isDepositPaid = false;
  List<Deposit> _deposits = [];

  @override
  void initState() {
    super.initState();
    _loan = Get.arguments as Loan?;
    if (_loan != null) {
      _loadDepositStatus();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    _transactionCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadDepositStatus() async {
    if (_loan == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _depositRepository.getDepositStatus(_loan!.id);
      setState(() {
        _depositAmount = status['deposit_amount'] ?? 0;
        _depositPaid = status['deposit_paid'] ?? 0;
        _remainingDeposit = status['remaining_deposit'] ?? 0;
        _isDepositPaid = status['is_deposit_paid'] ?? false;
        _deposits = status['deposits'] ?? [];
        _isLoading = false;
      });

      if (_isDepositPaid) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load deposit status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitPayment() async {
    // Validate phone number
    if (_phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(_phoneController.text)) {
      Get.snackbar(
        'Error',
        'Please enter a valid phone number (0XXXXXXXXX)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate transaction code
    if (_transactionCodeController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the M-PESA transaction code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_transactionCodeController.text.length < 8) {
      Get.snackbar(
        'Error',
        'Transaction code seems too short. Please verify.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Validate amount
    final paymentAmount = _payPartial
        ? double.tryParse(_amountController.text)
        : _remainingDeposit;

    if (paymentAmount == null || paymentAmount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Round up to nearest 10 for M-Pesa (M-Pesa doesn't accept decimals)
    final roundedAmount = PaymentUtils.roundUpToNearestTen(paymentAmount);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _depositRepository.submitManualPayment(
        loanId: _loan!.id,
        phoneNumber: _phoneController.text,
        mpesaCode: _transactionCodeController.text,
        amount: roundedAmount,
      );

      setState(() {
        _isSubmitting = false;
      });

      Get.snackbar(
        'Payment Submitted',
        result['message'] ?? 'Your payment has been submitted for verification',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Show pending verification dialog
      _showPendingVerificationDialog();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _showPendingVerificationDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.blue.shade50,
        title: Row(
          children: [
            const Icon(Icons.pending_actions, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Payment Under Verification',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your deposit payment has been submitted and is awaiting admin verification.\n\n'
              'You will receive a notification once your payment is verified.\n\n'
              'This usually takes a few minutes to a few hours.',
              style: TextStyle(fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Check your deposit status in My Loans',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/my-loans'); // Go to my loans screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('View My Loans'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Deposit Paid Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your loan deposit has been fully paid.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Total Deposit: KES ${_depositAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your loan application is now ready for approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed('/my-loans');
            },
            child: const Text('View My Loans'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Deposit Payment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Loan Information Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Loan Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _loan?.loanNumber ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Loan Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'KES ${_loan?.totalAmount.toStringAsFixed(2) ?? '0.00'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Deposit Information Card
                  Card(
                    elevation: 4,
                    color: _isDepositPaid
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            _isDepositPaid
                                ? Icons.check_circle
                                : Icons.account_balance_wallet,
                            size: 64,
                            color: _isDepositPaid
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isDepositPaid
                                ? 'Deposit Paid'
                                : 'Deposit Required (10%)',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'KES ${_depositAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _isDepositPaid
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Progress indicator
                          if (!_isDepositPaid) ...[
                            LinearProgressIndicator(
                              value: _depositPaid / _depositAmount,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Paid: KES ${_depositPaid.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Remaining: KES ${_remainingDeposit.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const Text(
                              'Fully paid on',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              _loan?.depositPaidAt?.toString().split(' ')[0] ??
                                  'N/A',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment form (only if not fully paid)
                  if (!_isDepositPaid) ...[
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: Image.asset(
                                'assets/images/mpesa_logo.png',
                                width: 40,
                                height: 40,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.phone_android, size: 40),
                              ),
                              title: const Text('M-PESA'),
                              subtitle: const Text(
                                'Manual Payment - Pay via Paybill',
                              ),
                              trailing: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Partial payment option
                    SwitchListTile(
                      title: const Text('Pay Partial Amount'),
                      subtitle: const Text('Pay less than the full deposit'),
                      value: _payPartial,
                      onChanged: (value) {
                        setState(() {
                          _payPartial = value;
                          if (!value) {
                            _amountController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount field (if partial payment)
                    if (_payPartial) ...[
                      TextField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Payment Amount',
                          hintText: 'Enter amount',
                          prefixIcon: const Icon(Icons.money),
                          suffixText: 'KES',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: !_isSubmitting && !_isDepositPaid,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Phone Number Input
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'M-PESA Phone Number',
                        hintText: '0712345678',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      enabled: !_isSubmitting && !_isDepositPaid,
                    ),
                    const SizedBox(height: 16),

                    // M-PESA Transaction Code Input
                    TextField(
                      controller: _transactionCodeController,
                      decoration: InputDecoration(
                        labelText: 'M-PESA Transaction Code',
                        hintText: 'e.g., SH12XYZ789',
                        prefixIcon: const Icon(Icons.receipt),
                        helperText: 'Found in your M-PESA confirmation SMS',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      enabled: !_isSubmitting && !_isDepositPaid,
                    ),
                    const SizedBox(height: 24),

                    // M-Pesa amount display with rounding info
                    if (_payPartial && _amountController.text.isNotEmpty ||
                        !_payPartial) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.payments, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Amount to Pay via M-Pesa',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'KES ${PaymentUtils.roundUpToNearestTen(_payPartial ? (double.tryParse(_amountController.text) ?? 0) : _remainingDeposit).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            if ((_payPartial
                                    ? (double.tryParse(_amountController.text) ?? 0)
                                    : _remainingDeposit) !=
                                PaymentUtils.roundUpToNearestTen(_payPartial
                                    ? (double.tryParse(_amountController.text) ?? 0)
                                    : _remainingDeposit)) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Rounded from KES ${(_payPartial ? (double.tryParse(_amountController.text) ?? 0) : _remainingDeposit).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'M-Pesa requires amounts in whole tens',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Pay Button
                    ElevatedButton(
                      onPressed: _isSubmitting || _isDepositPaid
                          ? null
                          : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Submitting...'),
                              ],
                            )
                          : const Text(
                              'Submit Payment',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Important Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '• A 10% deposit is required for loan processing\n'
                            '• You can pay in full or make partial payments\n'
                            '• Go to M-PESA → Lipa na M-PESA → Paybill\n'
                            '• Enter Business No: $mpesaPaybill\n'
                            '• Enter Account No: 846828\n'
                            '• Enter the amount and complete payment\n'
                            '• Copy the M-PESA transaction code (e.g., SH12XYZ789)\n'
                            '• Enter the code below to submit for verification\n'
                            '• Your loan will be ready for approval once deposit is fully paid',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Payment History
                  if (_deposits.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _deposits.length,
                      itemBuilder: (context, index) {
                        final deposit = _deposits[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              deposit.isCompleted
                                  ? Icons.check_circle
                                  : deposit.isPending
                                  ? Icons.pending
                                  : Icons.error,
                              color: deposit.isCompleted
                                  ? Colors.green
                                  : deposit.isPending
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                            title: Text(
                              'KES ${deposit.amount.toStringAsFixed(2)}',
                            ),
                            subtitle: Text(
                              '${deposit.paymentMethod.toUpperCase()} - ${deposit.status}',
                            ),
                            trailing: Text(
                              deposit.paidAt?.toString().split(' ')[0] ??
                                  'Pending',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
