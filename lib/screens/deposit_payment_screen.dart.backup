import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/loan.dart';
import '../models/deposit.dart';
import '../services/deposit_repository.dart';
import 'dart:async';

class DepositPaymentScreen extends StatefulWidget {
  const DepositPaymentScreen({super.key});

  @override
  State<DepositPaymentScreen> createState() => _DepositPaymentScreenState();
}

class _DepositPaymentScreenState extends State<DepositPaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final DepositRepository _depositRepository = DepositRepository();

  bool _isLoading = false;
  bool _isProcessing = false;
  bool _payPartial = false;

  Loan? _loan;
  double _depositAmount = 0;
  double _depositPaid = 0;
  double _remainingDeposit = 0;
  bool _isDepositPaid = false;
  List<Deposit> _deposits = [];

  String? _transactionId;
  Timer? _verificationTimer;
  int _verificationAttempts = 0;

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
    _verificationTimer?.cancel();
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

  Future<void> _initiatePayment() async {
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

    if (_payPartial) {
      if (_amountController.text.isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter payment amount',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        Get.snackbar(
          'Error',
          'Please enter a valid amount',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (amount > _remainingDeposit) {
        Get.snackbar(
          'Error',
          'Amount exceeds remaining deposit',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await _depositRepository.initiateMpesaPayment(
        loanId: _loan!.id,
        phoneNumber: _phoneController.text,
        amount: _payPartial ? double.parse(_amountController.text) : null,
      );

      setState(() {
        _transactionId = result['transaction_id'];
        _isProcessing = false;
      });

      Get.snackbar(
        'Payment Initiated',
        result['message'] ?? 'Check your phone to complete payment',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // Start polling for payment verification
      _startPaymentVerification();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startPaymentVerification() {
    _verificationAttempts = 0;
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _verifyPayment();
      _verificationAttempts++;

      // Stop after 12 attempts (60 seconds)
      if (_verificationAttempts >= 12) {
        timer.cancel();
        Get.snackbar(
          'Verification Timeout',
          'Payment verification timed out. You can manually verify later.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    });
  }

  Future<void> _verifyPayment() async {
    if (_transactionId == null) return;

    try {
      final result = await _depositRepository.verifyPayment(_transactionId!);
      if (result['is_deposit_fully_paid'] == true) {
        _verificationTimer?.cancel();
        setState(() {
          _isDepositPaid = true;
        });
        await _loadDepositStatus(); // Refresh status
        _showSuccessDialog();
      } else {
        // Partial payment successful, refresh status
        await _loadDepositStatus();
        _verificationTimer?.cancel();
        Get.snackbar(
          'Partial Payment Successful',
          'Payment recorded. Remaining deposit: KES ${_remainingDeposit.toStringAsFixed(2)}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        setState(() {
          _transactionId = null;
          _amountController.clear();
        });
      }
    } catch (e) {
      // Silently fail during verification polling
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
      appBar: AppBar(
        title: const Text('Loan Deposit Payment'),
      ),
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
                    color: _isDepositPaid ? Colors.green.shade50 : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            _isDepositPaid ? Icons.check_circle : Icons.account_balance_wallet,
                            size: 64,
                            color: _isDepositPaid ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isDepositPaid ? 'Deposit Paid' : 'Deposit Required (10%)',
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
                              color: _isDepositPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Progress indicator
                          if (!_isDepositPaid) ...[
                            LinearProgressIndicator(
                              value: _depositPaid / _depositAmount,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
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
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            Text(
                              _loan?.depositPaidAt?.toString().split(' ')[0] ?? 'N/A',
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
                              subtitle: const Text('Pay via M-PESA STK Push'),
                              trailing: const Icon(Icons.check_circle, color: Colors.green),
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
                        enabled: !_isProcessing && !_isDepositPaid,
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
                      enabled: !_isProcessing && !_isDepositPaid,
                    ),
                    const SizedBox(height: 24),

                    // Payment Status
                    if (_transactionId != null) ...[
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Waiting for payment...',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Transaction: $_transactionId',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Pay Button
                    ElevatedButton(
                      onPressed: _isProcessing || _isDepositPaid ? null : _initiatePayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
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
                                Text('Processing...'),
                              ],
                            )
                          : Text(
                              _payPartial
                                  ? 'Pay KES ${_amountController.text.isEmpty ? "0.00" : _amountController.text}'
                                  : 'Pay Full Deposit (KES ${_remainingDeposit.toStringAsFixed(2)})',
                              style: const TextStyle(fontSize: 18),
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
                          const Text(
                            '• A 10% deposit is required for loan processing\n'
                            '• You can pay in full or make partial payments\n'
                            '• You will receive an M-PESA prompt on your phone\n'
                            '• Enter your M-PESA PIN to complete payment\n'
                            '• Your loan will be ready for approval once deposit is fully paid',
                            style: TextStyle(fontSize: 14),
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
                            title: Text('KES ${deposit.amount.toStringAsFixed(2)}'),
                            subtitle: Text(
                              '${deposit.paymentMethod.toUpperCase()} - ${deposit.status}',
                            ),
                            trailing: Text(
                              deposit.paidAt?.toString().split(' ')[0] ?? 'Pending',
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
