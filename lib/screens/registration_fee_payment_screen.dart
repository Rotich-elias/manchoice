import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/registration_fee_repository.dart';
import '../models/registration_fee.dart';

class RegistrationFeePaymentScreen extends StatefulWidget {
  const RegistrationFeePaymentScreen({super.key});

  @override
  State<RegistrationFeePaymentScreen> createState() =>
      _RegistrationFeePaymentScreenState();
}

class _RegistrationFeePaymentScreenState
    extends State<RegistrationFeePaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  final RegistrationFeeRepository _feeRepository = RegistrationFeeRepository();

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _feePaid = false;
  double _feeAmount = 300.00;
  RegistrationFee? _registrationFee;

  // Paybill Details
  final String _paybillNumber = '522533';
  final String _accountNumber = 'MANCHOICE';
  final double _amount = 300.00;

  @override
  void initState() {
    super.initState();
    // Check if phone number was passed as argument (for retry scenario)
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['phone'] != null) {
      _phoneController.text = args['phone'];
    }
    _loadFeeStatus();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _transactionIdController.dispose();
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

      // If already paid, show success and navigate
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

  Future<void> _submitPayment() async {
    // Validate phone number
    if (_phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your M-PESA phone number',
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

    // Validate transaction ID
    if (_transactionIdController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the M-PESA transaction code',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_transactionIdController.text.length < 8) {
      Get.snackbar(
        'Error',
        'Transaction code seems too short. Please verify.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _feeRepository.submitManualPayment(
        phoneNumber: _phoneController.text,
        transactionId: _transactionIdController.text,
        amount: _amount,
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
              'Your registration fee payment has been submitted and is awaiting admin verification.\n\n'
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
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You can close this screen and continue later',
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
              Get.offAllNamed('/home'); // Go to home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Okay, Got It'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.green.shade50,
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Payment Verified!',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your registration fee has been successfully verified.\n\n'
              'You can now proceed to create loan applications!',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/home'); // Navigate to home/dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Fee Payment'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card
                  Card(
                    color: Colors.blue.shade50,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(Icons.payment, size: 48, color: Colors.blue.shade700),
                          const SizedBox(height: 12),
                          const Text(
                            'Registration Fee',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'KES ${_amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'One-time payment to activate your account',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'How to Pay',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInstructionStep('1', 'Go to M-PESA on your phone'),
                          _buildInstructionStep('2', 'Select Lipa Na M-PESA'),
                          _buildInstructionStep('3', 'Select Paybill'),
                          _buildInstructionStep('4', 'Enter the details below'),
                          _buildInstructionStep('5', 'Enter your M-PESA PIN'),
                          _buildInstructionStep('6', 'Copy the transaction code from the SMS'),
                          _buildInstructionStep('7', 'Enter the code in the form below'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Paybill Details Card
                  Card(
                    color: Colors.green.shade50,
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.account_balance, color: Colors.green.shade700, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'M-PESA Paybill Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildPaybillDetail(
                            'Business Number',
                            _paybillNumber,
                            Icons.business,
                          ),
                          const Divider(height: 24),
                          _buildPaybillDetail(
                            'Account Number',
                            _accountNumber,
                            Icons.account_circle,
                          ),
                          const Divider(height: 24),
                          _buildPaybillDetail(
                            'Amount',
                            'KES ${_amount.toStringAsFixed(2)}',
                            Icons.money,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Form Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Submit Payment Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Phone Number Field
                          const Text(
                            'M-PESA Phone Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: '0712345678',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            enabled: !_isSubmitting,
                          ),
                          const SizedBox(height: 20),

                          // Transaction ID Field
                          const Text(
                            'M-PESA Transaction Code',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _transactionIdController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'e.g., SH12XYZ789',
                              prefixIcon: const Icon(Icons.receipt),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.paste),
                                onPressed: () async {
                                  final clipboardData =
                                      await Clipboard.getData('text/plain');
                                  if (clipboardData != null &&
                                      clipboardData.text != null) {
                                    _transactionIdController.text =
                                        clipboardData.text!.toUpperCase();
                                  }
                                },
                                tooltip: 'Paste from clipboard',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              helperText: 'Found in your M-PESA confirmation SMS',
                            ),
                            enabled: !_isSubmitting,
                          ),
                          const SizedBox(height: 24),

                          // Info Box
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Your payment will be verified by admin within a few hours',
                                    style: TextStyle(fontSize: 12, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitPayment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Submit Payment',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaybillDetail(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value));
                      Get.snackbar(
                        'Copied',
                        '$label copied to clipboard',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
