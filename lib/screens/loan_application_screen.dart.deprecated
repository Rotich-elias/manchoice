import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  // Product selection
  String? _selectedProductId;
  Map<String, dynamic>? _selectedProduct;
  File? _damagedPartImage;

  // Sample products (TODO: Fetch from backend/database)
  final List<Map<String, dynamic>> _products = [
    {
      'id': 'P001',
      'name': 'Brake Pads (Front)',
      'price': 2500.0,
      'requiresImage': true,
    },
    {
      'id': 'P002',
      'name': 'Engine Oil Filter',
      'price': 800.0,
      'requiresImage': false,
    },
    {
      'id': 'P003',
      'name': 'Chain Sprocket Kit',
      'price': 4500.0,
      'requiresImage': true,
    },
    {
      'id': 'P004',
      'name': 'Clutch Cable',
      'price': 600.0,
      'requiresImage': false,
    },
    {
      'id': 'P005',
      'name': 'Battery (12V)',
      'price': 3500.0,
      'requiresImage': true,
    },
    {
      'id': 'P006',
      'name': 'Rear Tire',
      'price': 4500.0,
      'requiresImage': false,
    },
    {
      'id': 'P007',
      'name': 'Front Tire',
      'price': 4000.0,
      'requiresImage': false,
    },
    {
      'id': 'P008',
      'name': 'Spark Plug',
      'price': 400.0,
      'requiresImage': false,
    },
    {
      'id': 'P009',
      'name': 'Side Mirror (Pair)',
      'price': 1200.0,
      'requiresImage': true,
    },
    {
      'id': 'P010',
      'name': 'Headlight Assembly',
      'price': 2800.0,
      'requiresImage': true,
    },
  ];

  // Loan terms
  final double _interestRate = 0.30; // 30% per month
  final double _minDailyPayment = 200.0; // Minimum KES 200 daily

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Calculate total payable amount (price + 30%)
  double get _totalPayable {
    if (_selectedProduct == null) return 0.0;
    double price = _selectedProduct!['price'];
    return price + (price * _interestRate);
  }

  // Calculate daily payment estimate
  double get _dailyPayment {
    if (_selectedProduct == null) return 0.0;
    // Assuming 30 days repayment period
    double daily = _totalPayable / 30;
    // Return minimum daily payment if calculated is less
    return daily < _minDailyPayment ? _minDailyPayment : daily;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _damagedPartImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _submitApplication() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if product is selected
    if (_selectedProduct == null) {
      Get.snackbar(
        'Product Required',
        'Please select a spare part',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Check if image is required but not uploaded
    if (_selectedProduct!['requiresImage'] == true &&
        _damagedPartImage == null) {
      Get.snackbar(
        'Image Required',
        'Please upload a photo of the damaged part',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Confirm Application'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loan Application Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow('Product', _selectedProduct!['name']),
              _buildSummaryRow(
                'Price',
                'KES ${_selectedProduct!['price'].toStringAsFixed(0)}',
              ),
              _buildSummaryRow('Interest Rate', '30% per month'),
              const Divider(),
              _buildSummaryRow(
                'Total Payable',
                'KES ${_totalPayable.toStringAsFixed(0)}',
                isBold: true,
              ),
              _buildSummaryRow(
                'Daily Payment',
                'KES ${_dailyPayment.toStringAsFixed(0)}',
                isBold: true,
              ),
              const Divider(),
              _buildSummaryRow(
                'Image Uploaded',
                _damagedPartImage != null ? 'Yes' : 'Not Required',
              ),
              if (_notesController.text.isNotEmpty)
                _buildSummaryRow('Notes', _notesController.text),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'By submitting, you agree to the loan terms and conditions.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _saveApplication();
            },
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 15 : 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _saveApplication() {
    // TODO: Save to local database or send to backend API
    // For now, simulate saving with a delay

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // Close loading

      // Show success dialog
      Get.dialog(
        AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Application Submitted Successfully!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your loan application has been received. We will review it and get back to you within 24-48 hours.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Application ID: LA${DateTime.now().millisecondsSinceEpoch}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Close success dialog
                Get.back(); // Return to dashboard
              },
              child: const Text('Go to Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close success dialog
                Get.toNamed('/payments'); // Go to payments screen
              },
              child: const Text('View Applications'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Spare Parts Loan'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo and Name
                Card(
                  elevation: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.motorcycle,
                          size: 50,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MAN\'S CHOICE ENTERPRISE',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Spare Parts Financing',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Product Selection Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Select Spare Part',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedProductId,
                          decoration: const InputDecoration(
                            labelText: 'Select Product *',
                            hintText: 'Choose a spare part',
                            prefixIcon: Icon(Icons.build_circle),
                            border: OutlineInputBorder(),
                          ),
                          items: _products.map((product) {
                            return DropdownMenuItem<String>(
                              value: product['id'] as String,
                              child: Text(
                                '${product['name']} - KES ${product['price'].toStringAsFixed(0)}',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedProductId = value;
                              _selectedProduct = _products.firstWhere(
                                (p) => p['id'] == value,
                              );
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a product';
                            }
                            return null;
                          },
                        ),
                        if (_selectedProduct != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Product Price:'),
                                    Text(
                                      'KES ${_selectedProduct!['price'].toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Loan Conditions Card
                if (_selectedProduct != null) ...[
                  Card(
                    elevation: 2,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Loan Terms & Calculation',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLoanDetailRow(
                            'Interest Rate:',
                            '30% per month',
                          ),
                          _buildLoanDetailRow(
                            'Minimum Daily Payment:',
                            'KES ${_minDailyPayment.toStringAsFixed(0)}',
                          ),
                          _buildLoanDetailRow(
                            'Repayment Period:',
                            '30 days (1 month)',
                          ),
                          const Divider(height: 24),
                          _buildLoanDetailRow(
                            'Total Payable Amount:',
                            'KES ${_totalPayable.toStringAsFixed(0)}',
                            isBold: true,
                            color: Colors.green.shade700,
                          ),
                          _buildLoanDetailRow(
                            'Daily Payment Estimate:',
                            'KES ${_dailyPayment.toStringAsFixed(0)}',
                            isBold: true,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 16,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Total = Price + 30% Interest',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Image Upload Card (if required)
                if (_selectedProduct != null &&
                    _selectedProduct!['requiresImage'] == true) ...[
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Image Verification *',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please upload a photo of the damaged part that needs replacement.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _damagedPartImage != null
                                      ? Colors.green
                                      : Colors.grey.shade400,
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade100,
                              ),
                              child: _damagedPartImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        _damagedPartImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload,
                                          size: 50,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Tap to upload photo',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          if (_damagedPartImage != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Image uploaded successfully',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Loan Purpose/Notes Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notes,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Additional Notes (Optional)',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText:
                                'Add any additional information or special requests...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitApplication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Submit Application',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                // Terms & Conditions
                TextButton(
                  onPressed: () {
                    _showTermsAndConditions();
                  },
                  child: const Text('View Full Terms & Conditions'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoanDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Loan Terms & Conditions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '1. Interest Rate',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Interest is charged at 30% per month on the principal loan amount.',
                ),
                const SizedBox(height: 12),
                const Text(
                  '2. Daily Payment Requirements',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Minimum daily payment of KES 200 is required. Failure to meet this may result in penalties.',
                ),
                const SizedBox(height: 12),
                const Text(
                  '3. Repayment Period',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Standard repayment period is 30 days (1 month) from the date of loan approval.',
                ),
                const SizedBox(height: 12),
                const Text(
                  '4. Collateral',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your motorcycle logbook serves as collateral for the loan.',
                ),
                const SizedBox(height: 12),
                const Text(
                  '5. Late Payment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Late payments may attract additional penalties and affect your credit rating.',
                ),
                const SizedBox(height: 12),
                const Text(
                  '6. Early Repayment',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You may repay your loan early without any penalties.',
                ),
                const SizedBox(height: 12),
                const Text(
                  '7. Product Verification',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'For certain products, photographic evidence of the damaged part may be required for verification.',
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'By submitting your application, you acknowledge that you have read and agree to these terms.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
