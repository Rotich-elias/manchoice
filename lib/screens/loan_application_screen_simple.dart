import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/loan_repository.dart';
import '../services/customer_repository.dart';

class LoanApplicationScreenSimple extends StatefulWidget {
  const LoanApplicationScreenSimple({super.key});

  @override
  State<LoanApplicationScreenSimple> createState() =>
      _LoanApplicationScreenSimpleState();
}

class _LoanApplicationScreenSimpleState
    extends State<LoanApplicationScreenSimple> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _loanRepo = LoanRepository();
  final _customerRepo = CustomerRepository();

  int? _customerId;
  String _selectedDuration = '30'; // Default 30 days
  double _interestRate = 10.0; // Default 10%
  bool _isLoading = false;

  final List<String> _durationOptions = ['7', '14', '30', '60', '90'];
  final List<double> _interestOptions = [5.0, 10.0, 12.0, 15.0];

  @override
  void initState() {
    super.initState();
    _loadCustomerInfo();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerInfo() async {
    try {
      // Try to get customers and use the first one
      // In a real app, you'd get the current user's customer ID
      final customers = await _customerRepo.getAllCustomers();
      if (customers.isNotEmpty) {
        setState(() {
          _customerId = customers.first.id;
        });
      }
    } catch (e) {
      // Customer info will be loaded, or user needs to create customer profile first
    }
  }

  double get _totalAmount {
    if (_amountController.text.isEmpty) return 0.0;
    try {
      double principal = double.parse(_amountController.text);
      double interest = principal * (_interestRate / 100);
      return principal + interest;
    } catch (e) {
      return 0.0;
    }
  }

  double get _monthlyPayment {
    if (_totalAmount == 0) return 0.0;
    int days = int.parse(_selectedDuration);
    int months = (days / 30).ceil();
    return _totalAmount / (months > 0 ? months : 1);
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_customerId == null) {
      Get.snackbar(
        'Profile Required',
        'Please complete your customer profile first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loan = await _loanRepo.createLoan(
        customerId: _customerId!,
        principalAmount: double.parse(_amountController.text),
        interestRate: _interestRate,
        durationDays: int.parse(_selectedDuration),
        purpose: _purposeController.text.isEmpty
            ? null
            : _purposeController.text,
      );

      if (!mounted) return;

      if (loan != null) {
        // Show success message
        Get.dialog(
          AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text(
                  'Loan Application Submitted!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your loan application has been submitted for review.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Loan Number: ${loan.loanNumber}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${loan.status}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Return to dashboard
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Failed to submit loan application: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Loan'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Icon(
                  Icons.money,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loan Application Form',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Loan Amount
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Loan Amount (KES)',
                    hintText: 'Enter amount you need',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter loan amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) < 1000) {
                      return 'Minimum loan amount is KES 1,000';
                    }
                    return null;
                  },
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Duration
                DropdownButtonFormField<String>(
                  initialValue: _selectedDuration,
                  decoration: const InputDecoration(
                    labelText: 'Loan Duration',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: _durationOptions.map((String duration) {
                    return DropdownMenuItem<String>(
                      value: duration,
                      child: Text('$duration days'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedDuration = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Interest Rate
                DropdownButtonFormField<double>(
                  initialValue: _interestRate,
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate',
                    prefixIcon: Icon(Icons.percent),
                  ),
                  items: _interestOptions.map((double rate) {
                    return DropdownMenuItem<double>(
                      value: rate,
                      child: Text('$rate%'),
                    );
                  }).toList(),
                  onChanged: (double? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _interestRate = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Purpose
                TextFormField(
                  controller: _purposeController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Purpose (Optional)',
                    hintText: 'What will you use the loan for?',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 24),

                // Loan Summary Card
                if (_amountController.text.isNotEmpty)
                  Card(
                    elevation: 4,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Loan Summary',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            'Principal Amount',
                            'KES ${_amountController.text}',
                          ),
                          _buildSummaryRow(
                            'Interest ($_interestRate%)',
                            'KES ${(_totalAmount - (double.tryParse(_amountController.text) ?? 0)).toStringAsFixed(2)}',
                          ),
                          const Divider(),
                          _buildSummaryRow(
                            'Total Amount',
                            'KES ${_totalAmount.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                          _buildSummaryRow(
                            'Duration',
                            '$_selectedDuration days',
                          ),
                          _buildSummaryRow(
                            'Est. Monthly Payment',
                            'KES ${_monthlyPayment.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit Application',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Info Text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Your loan application will be reviewed within 24-48 hours.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
