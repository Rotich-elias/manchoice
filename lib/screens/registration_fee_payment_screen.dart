import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/registration_fee_repository.dart';
import '../models/registration_fee.dart';
import 'dart:async';

class RegistrationFeePaymentScreen extends StatefulWidget {
  const RegistrationFeePaymentScreen({super.key});

  @override
  State<RegistrationFeePaymentScreen> createState() =>
      _RegistrationFeePaymentScreenState();
}

class _RegistrationFeePaymentScreenState
    extends State<RegistrationFeePaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final RegistrationFeeRepository _feeRepository = RegistrationFeeRepository();

  bool _isLoading = false;
  bool _isProcessing = false;
  bool _feePaid = false;
  double _feeAmount = 300.00;
  RegistrationFee? _registrationFee;
  String? _transactionId;
  Timer? _verificationTimer;
  int _verificationAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadFeeStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFeeStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _feeRepository.getStatus();
      setState(() {
        _feePaid = status['fee_paid'] ?? false;
        _feeAmount = status['amount'] ?? 300.00;
        _registrationFee = status['registration_fee'];
        _isLoading = false;
      });

      // If already paid, navigate to dashboard
      if (_feePaid) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load fee status: $e',
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

    setState(() {
      _isProcessing = true;
    });

    try {
      final result =
          await _feeRepository.initiateMpesaPayment(_phoneController.text);
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
      final result = await _feeRepository.verifyPayment(_transactionId!);
      if (result['fee_paid'] == true) {
        _verificationTimer?.cancel();
        setState(() {
          _feePaid = true;
          _registrationFee = result['registration_fee'];
        });
        _showSuccessDialog();
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
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your registration fee has been paid successfully.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: KES ${_feeAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_registrationFee?.mpesaReceiptNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                'Receipt: ${_registrationFee!.mpesaReceiptNumber}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed('/dashboard');
            },
            child: const Text('Continue to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Fee Payment'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Fee Information Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet,
                            size: 64,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Registration Fee',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'KES ${_feeAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'This is a one-time registration fee required to activate your account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Method Card
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
                            trailing: const Icon(Icons.check_circle,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

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
                    enabled: !_isProcessing && !_feePaid,
                  ),
                  const SizedBox(height: 24),

                  // Payment Status
                  if (_transactionId != null && !_feePaid) ...[
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                    onPressed:
                        _isProcessing || _feePaid ? null : _initiatePayment,
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
                            _feePaid
                                ? 'Payment Complete'
                                : 'Pay KES ${_feeAmount.toStringAsFixed(2)}',
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
                          '• You will receive an M-PESA prompt on your phone\n'
                          '• Enter your M-PESA PIN to complete payment\n'
                          '• You will receive a confirmation SMS\n'
                          '• Your account will be activated immediately',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
