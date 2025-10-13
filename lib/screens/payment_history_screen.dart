import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/payment.dart';
import '../models/loan.dart';
import '../services/payment_repository.dart';
import '../services/loan_repository.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentRepository _paymentRepository = PaymentRepository();
  final LoanRepository _loanRepository = LoanRepository();

  List<Payment> _payments = [];
  Loan? _activeLoan;
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'all'; // all, pending, completed, failed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load payments
      final payments = await _paymentRepository.getAllPayments(
        status: _filterStatus == 'all' ? null : _filterStatus,
      );

      // Try to get active loan
      final loans = await _loanRepository.getAllLoans(
        status: 'active',
      );

      final activeLoan = loans.isNotEmpty ? loans.first : null;

      // If no active loan, try approved
      if (activeLoan == null) {
        final approvedLoans = await _loanRepository.getAllLoans(
          status: 'approved',
        );
        if (approvedLoans.isNotEmpty) {
          setState(() {
            _activeLoan = approvedLoans.first;
          });
        }
      } else {
        setState(() {
          _activeLoan = activeLoan;
        });
      }

      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payments: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          _buildFilterChips(),
          const Divider(height: 1),

          // Active Loan Summary (if exists)
          if (_activeLoan != null) _buildActiveLoanSummary(),

          // Payments List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _payments.isEmpty
                        ? _buildEmptyView()
                        : _buildPaymentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 'completed'),
            const SizedBox(width: 8),
            _buildFilterChip('Failed', 'failed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
        _loadData();
      },
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildActiveLoanSummary() {
    if (_activeLoan == null) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.all(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Loan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  Text(
                    _activeLoan!.loanNumber,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _activeLoan!.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white38),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outstanding Balance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(_activeLoan!.balance),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed('/my-loans');
                },
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('Make Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _activeLoan!.paymentProgress / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_activeLoan!.paymentProgress.toStringAsFixed(1)}% paid',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Payments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Payments Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterStatus == 'all'
                  ? 'You haven\'t made any payments yet.'
                  : 'No payments found with status: $_filterStatus',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/my-loans'),
              icon: const Icon(Icons.payment),
              label: const Text('Make a Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsList() {
    // Group payments by status (pending first, then completed, then failed)
    final pendingPayments = _payments.where((p) => p.status == 'pending').toList();
    final completedPayments = _payments.where((p) => p.status == 'completed').toList();
    final failedPayments = _payments.where((p) => p.status == 'failed' || p.status == 'reversed').toList();

    final groupedPayments = [
      ...pendingPayments,
      ...completedPayments,
      ...failedPayments,
    ];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedPayments.length,
        itemBuilder: (context, index) {
          final payment = groupedPayments[index];
          return _buildPaymentCard(payment);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    final statusColor = _getStatusColor(payment.status);
    final statusIcon = _getStatusIcon(payment.status);
    final methodIcon = _getPaymentMethodIcon(payment.paymentMethod);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showPaymentDetails(payment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Payment Method and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(methodIcon, size: 20, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        payment.paymentMethod.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          payment.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amount
              Text(
                currencyFormat.format(payment.amount),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
              ),
              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(payment.paymentDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Transaction ID
              if (payment.transactionId != null)
                Row(
                  children: [
                    Icon(
                      Icons.confirmation_number,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        payment.transactionId!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                  ],
                ),

              // Loan Reference
              if (payment.loan != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Loan: ${payment.loan!.loanNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'reversed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.cancel;
      case 'reversed':
        return Icons.undo;
      default:
        return Icons.info;
    }
  }

  IconData _getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'mpesa':
        return Icons.phone_android;
      case 'cash':
        return Icons.money;
      case 'bank_transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  void _showPaymentDetails(Payment payment) {
    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(payment.paymentMethod),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('Payment Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Amount', currencyFormat.format(payment.amount)),
              const Divider(),
              _buildDetailRow('Status', payment.status.toUpperCase()),
              _buildDetailRow('Payment Method', payment.paymentMethod.toUpperCase()),
              _buildDetailRow('Date', dateFormat.format(payment.paymentDate)),
              if (payment.transactionId != null) ...[
                const Divider(),
                _buildDetailRow('Transaction ID', payment.transactionId!),
              ],
              if (payment.mpesaReceiptNumber != null) ...[
                _buildDetailRow('M-PESA Receipt', payment.mpesaReceiptNumber!),
              ],
              if (payment.phoneNumber != null) ...[
                _buildDetailRow('Phone Number', payment.phoneNumber!),
              ],
              if (payment.loan != null) ...[
                const Divider(),
                _buildDetailRow('Loan Number', payment.loan!.loanNumber),
                _buildDetailRow('Loan Status', payment.loan!.status.toUpperCase()),
              ],
              if (payment.notes != null) ...[
                const Divider(),
                _buildDetailRow('Notes', payment.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
