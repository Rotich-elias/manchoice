import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/loan.dart';
import '../services/loan_repository.dart';

class MyLoansScreen extends StatefulWidget {
  const MyLoansScreen({super.key});

  @override
  State<MyLoansScreen> createState() => _MyLoansScreenState();
}

class _MyLoansScreenState extends State<MyLoansScreen> {
  final LoanRepository _loanRepository = LoanRepository();
  List<Loan> _loans = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filterStatus = 'all'; // all, pending, approved, active, completed
  Loan? _activeLoan;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user's customer ID if available
      // For now, we'll fetch all loans for the authenticated user
      final loans = await _loanRepository.getAllLoans(
        status: _filterStatus == 'all' ? null : _filterStatus,
      );

      // Find active loan for quick overview
      Loan? activeLoan;
      try {
        final activeLoans = await _loanRepository.getAllLoans(status: 'active');
        if (activeLoans.isNotEmpty) {
          activeLoan = activeLoans.first;
        } else {
          final approvedLoans = await _loanRepository.getAllLoans(status: 'approved');
          if (approvedLoans.isNotEmpty) {
            activeLoan = approvedLoans.first;
          }
        }
      } catch (e) {
        // Ignore errors loading active loan
      }

      setState(() {
        _loans = loans;
        _activeLoan = activeLoan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load loans: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loans'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLoans,
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Overview Section
          if (_activeLoan != null && !_isLoading)
            _buildQuickOverview(),

          // Filter Chips
          _buildFilterChips(),
          const Divider(height: 1),

          // Loans List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorView()
                    : _loans.isEmpty
                        ? _buildEmptyView()
                        : _buildLoansList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/new-loan-application'),
        icon: const Icon(Icons.add),
        label: const Text('New Loan'),
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
            _buildFilterChip('Approved', 'approved'),
            const SizedBox(width: 8),
            _buildFilterChip('Active', 'active'),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 'completed'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
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
        _loadLoans();
      },
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
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
              'Error Loading Loans',
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
              onPressed: _loadLoans,
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
              'No Loans Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterStatus == 'all'
                  ? 'You haven\'t applied for any loans yet.'
                  : 'No loans found with status: $_filterStatus',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/new-loan-application'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Apply for a Loan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoansList() {
    return RefreshIndicator(
      onRefresh: _loadLoans,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _loans.length,
        itemBuilder: (context, index) {
          final loan = _loans[index];
          return _buildLoanCard(loan);
        },
      ),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusColor = _getStatusColor(loan.status);
    final statusIcon = _getStatusIcon(loan.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _showLoanDetails(loan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Loan Number and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      loan.loanNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          loan.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount Info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Principal',
                      currencyFormat.format(loan.principalAmount),
                      Icons.account_balance_wallet,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Total Amount',
                      currencyFormat.format(loan.totalAmount),
                      Icons.monetization_on,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'Paid',
                      currencyFormat.format(loan.amountPaid),
                      Icons.check_circle,
                      valueColor: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'Balance',
                      currencyFormat.format(loan.balance),
                      Icons.pending_actions,
                      valueColor: loan.balance > 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),

              // Payment Progress Bar
              if (loan.status == 'active' || loan.status == 'completed')
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Progress',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                        Text(
                          '${loan.paymentProgress.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: loan.paymentProgress / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          loan.paymentProgress >= 100 ? Colors.green : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),

              // Due Date and Overdue Warning
              if (loan.dueDate != null)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: loan.isOverdue ? Colors.red : Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Due: ${dateFormat.format(loan.dueDate!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: loan.isOverdue ? Colors.red : Theme.of(context).colorScheme.secondary,
                                fontWeight: loan.isOverdue ? FontWeight.bold : FontWeight.normal,
                              ),
                        ),
                        if (loan.isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${loan.daysOverdue} days overdue',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),

              // Interest Rate
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.percent,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Interest Rate: ${loan.interestRate}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),

              // View Details Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLoanDetails(loan),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.teal;
      case 'rejected':
        return Colors.red;
      case 'defaulted':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle_outline;
      case 'active':
        return Icons.play_circle_outline;
      case 'completed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'defaulted':
        return Icons.warning;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _showLoanDetails(Loan loan) {
    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    Get.dialog(
      AlertDialog(
        title: Text(loan.loanNumber),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', loan.status.toUpperCase()),
              const Divider(),
              _buildDetailRow('Principal Amount', currencyFormat.format(loan.principalAmount)),
              _buildDetailRow('Interest Rate', '${loan.interestRate}%'),
              _buildDetailRow('Total Amount', currencyFormat.format(loan.totalAmount)),
              const Divider(),
              _buildDetailRow('Amount Paid', currencyFormat.format(loan.amountPaid)),
              _buildDetailRow('Balance', currencyFormat.format(loan.balance)),
              _buildDetailRow('Payment Progress', '${loan.paymentProgress.toStringAsFixed(1)}%'),
              const Divider(),
              if (loan.disbursementDate != null)
                _buildDetailRow('Disbursement Date', dateFormat.format(loan.disbursementDate!)),
              if (loan.dueDate != null)
                _buildDetailRow('Due Date', dateFormat.format(loan.dueDate!)),
              if (loan.durationDays != null)
                _buildDetailRow('Duration', '${loan.durationDays} days'),
              if (loan.isOverdue)
                _buildDetailRow('Days Overdue', '${loan.daysOverdue} days', isWarning: true),
              if (loan.purpose != null) ...[
                const Divider(),
                _buildDetailRow('Purpose', loan.purpose!),
              ],
              if (loan.notes != null) ...[
                const Divider(),
                _buildDetailRow('Notes', loan.notes!),
              ],
              if (loan.customer != null) ...[
                const Divider(),
                _buildDetailRow('Customer', loan.customer!.name),
                _buildDetailRow('Phone', loan.customer!.phone),
              ],
            ],
          ),
        ),
        actions: [
          if (loan.balance > 0 && (loan.status == 'active' || loan.status == 'approved'))
            TextButton.icon(
              onPressed: () {
                Get.back();
                Get.toNamed('/payments', arguments: loan);
              },
              icon: const Icon(Icons.payment),
              label: const Text('Make Payment'),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWarning ? Colors.red : null,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: isWarning ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickOverview() {
    if (_activeLoan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Total Loan',
                  value: 'KES ${NumberFormat('#,##0.00').format(_activeLoan!.totalAmount)}',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Balance',
                  value: 'KES ${NumberFormat('#,##0.00').format(_activeLoan!.balance)}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.check_circle,
                  title: 'Paid',
                  value: 'KES ${NumberFormat('#,##0.00').format(_activeLoan!.amountPaid)}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Next Due',
                  value: _activeLoan!.dueDate != null
                      ? DateFormat('MMM dd').format(_activeLoan!.dueDate!)
                      : 'N/A',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
