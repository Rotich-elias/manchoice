import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/loan.dart';
import '../services/payment_repository.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final TextEditingController _transactionCodeController =
      TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final PaymentRepository _paymentRepository = PaymentRepository();

  bool _isSubmitting = false;
  String _selectedPaymentMethod = 'mpesa';

  // Get loan data from navigation arguments
  Loan? _loan;
  final String mpesaPaybill = "247247"; // TODO: Replace with actual paybill number

  @override
  void initState() {
    super.initState();
    // Get loan data passed from previous screen
    _loan = Get.arguments as Loan?;
  }

  // TODO: Fetch from database
  final List<Map<String, dynamic>> paymentHistory = [
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 500.0,
      'status': 'paid',
      'transactionCode': 'QAX1B2C3D4',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'amount': 500.0,
      'status': 'paid',
      'transactionCode': 'QAX2C3D4E5',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'amount': 500.0,
      'status': 'missed',
      'transactionCode': null,
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'amount': 500.0,
      'status': 'paid',
      'transactionCode': 'QAX3D4E5F6',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'amount': 500.0,
      'status': 'paid',
      'transactionCode': 'QAX4E5F6G7',
    },
  ];

  // TODO: Fetch from database
  final List<Map<String, dynamic>> upcomingPayments = [
    {
      'date': DateTime.now().add(const Duration(days: 5)),
      'amount': 500.0,
      'description': 'Daily installment payment due',
    },
    {
      'date': DateTime.now().add(const Duration(days: 6)),
      'amount': 500.0,
      'description': 'Daily installment payment due',
    },
    {
      'date': DateTime.now().add(const Duration(days: 7)),
      'amount': 500.0,
      'description': 'Daily installment payment due',
    },
  ];

  double get remainingBalance => _loan?.balance ?? 0;
  double get paymentProgress => _loan?.paymentProgress ?? 0;
  double get totalLoanAmount => _loan?.totalAmount ?? 0;
  double get amountPaid => _loan?.amountPaid ?? 0;
  String get productName => _loan?.purpose ?? 'Loan';
  DateTime get nextPaymentDue => _loan?.dueDate ?? DateTime.now();

  @override
  void dispose() {
    _transactionCodeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error if no loan data
    if (_loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payments')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('No loan data available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Installments'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showFullPaymentHistory(context);
            },
            tooltip: 'View Full History',
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Get.snackbar(
                'Statement',
                'Statement generation will be implemented',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            tooltip: 'Download Statement',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Summary Card
              _buildLoanSummaryCard(context),

              const SizedBox(height: 16),

              // Visual Progress Bar
              _buildProgressSection(context),

              const SizedBox(height: 24),

              // Make Payment Section
              _buildMakePaymentSection(context),

              const SizedBox(height: 24),

              // Daily Payment Tracker
              _buildPaymentTrackerSection(context),

              const SizedBox(height: 24),

              // Reminders & Notifications
              _buildRemindersSection(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.two_wheeler,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Loan Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      productName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Loan',
                  'KES ${_formatCurrency(totalLoanAmount)}',
                  Icons.account_balance_wallet,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Amount Paid',
                  'KES ${_formatCurrency(amountPaid)}',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Remaining',
                  'KES ${_formatCurrency(remainingBalance)}',
                  Icons.pending,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Balance',
                  'KES ${_formatCurrency(remainingBalance)}',
                  Icons.account_balance,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white38),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Payment Due',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(nextPaymentDue),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_daysUntil(nextPaymentDue)} days left',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repayment Progress',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${paymentProgress.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: paymentProgress / 100,
              minHeight: 12,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KES ${_formatCurrency(amountPaid)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'KES ${_formatCurrency(totalLoanAmount)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMakePaymentSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payment,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Make Payment',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // M-PESA Paybill Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/mpesa_logo.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.phone_android,
                          color: Colors.green,
                          size: 24,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lipa na M-PESA',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Follow these steps to pay:',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildPaymentStep('1', 'Go to M-PESA menu'),
                _buildPaymentStep('2', 'Select Lipa na M-PESA'),
                _buildPaymentStep('3', 'Select Paybill'),
                _buildPaymentStep('4', 'Enter Business No: $mpesaPaybill'),
                _buildPaymentStep('5', 'No: Your Phone Number'),
                _buildPaymentStep(
                  '6',
                  'Enter Amount: Any amount towards your balance',
                ),
                _buildPaymentStep('7', 'Enter M-PESA PIN'),
                const SizedBox(height: 16),

                // Paybill Number Display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paybill Number',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mpesaPaybill,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                  letterSpacing: 2,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: mpesaPaybill));
                          Get.snackbar(
                            'Copied!',
                            'Paybill number copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.copy, color: Colors.green),
                        tooltip: 'Copy Paybill',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // After Payment Section
          Text(
            'After Payment - Submit Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Payment Method Selector
          DropdownButtonFormField<String>(
            initialValue: _selectedPaymentMethod,
            decoration: InputDecoration(
              labelText: 'Payment Method',
              prefixIcon: const Icon(Icons.payment),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'mpesa', child: Text('M-PESA')),
              DropdownMenuItem(value: 'cash', child: Text('Cash')),
              DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value ?? 'mpesa';
              });
            },
          ),
          const SizedBox(height: 16),

          // Amount Input
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount Paid',
              hintText: 'Enter amount paid',
              prefixIcon: const Icon(Icons.attach_money),
              prefixText: 'KES ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: 'Balance: KES ${_formatCurrency(remainingBalance)}',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 16),

          // Transaction Code Input
          TextField(
            controller: _transactionCodeController,
            decoration: InputDecoration(
              labelText: _selectedPaymentMethod == 'mpesa'
                  ? 'M-PESA Transaction Code'
                  : 'Receipt/Reference Number',
              hintText: _selectedPaymentMethod == 'mpesa'
                  ? 'e.g., QAX1B2C3D4'
                  : 'Enter receipt number',
              prefixIcon: const Icon(Icons.confirmation_number),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              helperText: _selectedPaymentMethod == 'mpesa'
                  ? 'Enter the M-PESA confirmation code you received via SMS'
                  : 'Enter your payment receipt or reference number',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),

          // Confirm Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : () {
                _confirmPayment(context);
              },
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Payment for Approval'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green,
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPaymentTrackerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  _showFullPaymentHistory(context);
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Recent Payments List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paymentHistory.length > 5 ? 5 : paymentHistory.length,
          itemBuilder: (context, index) {
            final payment = paymentHistory[index];
            return _buildPaymentItem(context, payment);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentItem(BuildContext context, Map<String, dynamic> payment) {
    final bool isPaid = payment['status'] == 'paid';
    final date = payment['date'] as DateTime;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check : Icons.close,
              color: isPaid ? Colors.green : Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Payment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPaid ? 'Paid' : 'Missed',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isPaid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isPaid && payment['transactionCode'] != null)
                  Text(
                    'Code: ${payment['transactionCode']}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${_formatCurrency(payment['amount'])}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPaid ? Colors.green : Colors.red,
                ),
              ),
              if (isPaid)
                Text(
                  '✅ Paid',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.green),
                )
              else
                Text(
                  '❌ Missed',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: Theme.of(context).colorScheme.secondary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Reminders & Notifications',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SMS Reminder Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.sms, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMS Reminders Active',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'You will receive automatic SMS reminders',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Upcoming Payments
          Text(
            'Upcoming Payments',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...upcomingPayments.map((payment) {
            return _buildUpcomingPaymentItem(context, payment);
          }),

          const SizedBox(height: 16),

          // Notification Settings
          OutlinedButton.icon(
            onPressed: () {
              Get.snackbar(
                'Notification Settings',
                'Notification preferences will be implemented',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Notification Settings'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPaymentItem(
    BuildContext context,
    Map<String, dynamic> payment,
  ) {
    final date = payment['date'] as DateTime;
    final daysUntil = _daysUntil(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  payment['description'],
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KES ${_formatCurrency(payment['amount'])}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'in $daysUntil days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPayment(BuildContext context) async {
    final transactionCode = _transactionCodeController.text.trim();
    final amountText = _amountController.text.trim();

    // Validation
    if (amountText.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the amount paid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (amount > remainingBalance) {
      Get.snackbar(
        'Warning',
        'Amount exceeds remaining balance. Your payment will be adjusted to KES ${_formatCurrency(remainingBalance)}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }

    if (transactionCode.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the transaction/receipt code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Submit payment to API
    setState(() {
      _isSubmitting = true;
    });

    try {
      final payment = await _paymentRepository.createPayment(
        loanId: _loan!.id,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        mpesaReceiptNumber: transactionCode,
        notes: 'Payment submitted by customer via mobile app',
      );

      setState(() {
        _isSubmitting = false;
      });

      if (!context.mounted) return;

      if (payment != null) {
        // Show success message
        Get.dialog(
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.orange, size: 32),
                SizedBox(width: 12),
                Text('Payment Submitted!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your payment has been submitted successfully and is awaiting admin approval.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your loan balance will be updated once the admin approves your payment.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow('Transaction Code:', transactionCode),
                _buildDetailRow(
                  'Amount:',
                  'KES ${_formatCurrency(amount)}',
                ),
                _buildDetailRow(
                  'Payment Method:',
                  _selectedPaymentMethod.toUpperCase(),
                ),
                _buildDetailRow(
                  'Date:',
                  DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.now()),
                ),
                _buildDetailRow(
                  'Status:',
                  'Pending Approval',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  _transactionCodeController.clear();
                  _amountController.clear();
                  Get.back(); // Go back to previous screen
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to submit payment. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!context.mounted) return;

      Get.snackbar(
        'Error',
        'Failed to submit payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showFullPaymentHistory(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Full Payment History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: paymentHistory.length,
                itemBuilder: (context, index) {
                  return _buildPaymentItem(context, paymentHistory[index]);
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }
}
