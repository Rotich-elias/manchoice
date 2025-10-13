import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/loan_repository.dart';
import '../models/user.dart';
import '../models/loan.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final LoanRepository _loanRepository = LoanRepository();

  User? _currentUser;
  Loan? _activeLoan;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadActiveLoan();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      // Silently fail - user will see default name
    }
  }

  Future<void> _loadActiveLoan() async {
    try {
      // Try to get active loan first
      final activeLoans = await _loanRepository.getAllLoans(status: 'active');

      if (activeLoans.isNotEmpty) {
        if (mounted) {
          setState(() {
            _activeLoan = activeLoans.first;
          });
        }
        return;
      }

      // If no active loan, try approved
      final approvedLoans = await _loanRepository.getAllLoans(status: 'approved');
      if (approvedLoans.isNotEmpty && mounted) {
        setState(() {
          _activeLoan = approvedLoans.first;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _activeLoan = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _activeLoan = null;
        });
      }
    }
  }

  String get userName => _currentUser?.name ?? 'User';
  String get userPhone => _currentUser?.phone ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'lib/assets/images/logo.jpg',
                height: 32,
                width: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Dashboard'),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          // Notification bell icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Get.snackbar(
                    'Payment Reminders',
                    'No payment reminders at this time',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    colorText: Theme.of(context).colorScheme.onPrimary,
                  );
                },
              ),
              // Notification badge (optional - shows count)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card with user's name
              Card(
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'lib/assets/images/logo.jpg',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back,',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.9),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MAN\'S CHOICE ENTERPRISE',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary
                                        .withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Loan Summary (if exists)
              if (_activeLoan != null) ...[
                _buildLoanSummaryCard(context),
                const SizedBox(height: 24),
              ],

              // Main Menu Section
              Text(
                'Main Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),

              // Menu Cards
              _buildMenuCard(
                context,
                icon: Icons.receipt_long,
                title: 'My Loans',
                subtitle: 'View loan status and payment history',
                color: Colors.blue,
                onTap: () => Get.toNamed('/my-loans'),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.person_add,
                title: 'Complete Profile',
                subtitle: 'Complete your profile to apply for financing',
                color: Colors.orange,
                onTap: () => Get.toNamed('/new-loan-application'),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.payment,
                title: 'My Payments / Installments',
                subtitle: 'View and manage your payments',
                color: Colors.green,
                onTap: () => Get.toNamed('/payment-history'),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.shopping_bag,
                title: 'Products (Spares)',
                subtitle: 'Browse available spare parts',
                color: Colors.orange,
                onTap: () => Get.toNamed('/products'),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.person,
                title: 'Account Profile',
                subtitle: 'View and edit your profile',
                color: Colors.purple,
                onTap: () => Get.toNamed('/profile'),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                context,
                icon: Icons.support_agent,
                title: 'Support / Help',
                subtitle: 'Get help and contact support',
                color: Colors.red,
                onTap: () => Get.toNamed('/support'),
              ),
              const SizedBox(height: 24),

              // Quick Stats Section
              Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      value: _activeLoan != null
                          ? 'KES ${NumberFormat('#,##0.00').format(_activeLoan!.totalAmount)}'
                          : 'KES 0',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.pending_actions,
                      title: 'Balance',
                      value: _activeLoan != null
                          ? 'KES ${NumberFormat('#,##0.00').format(_activeLoan!.balance)}'
                          : 'KES 0',
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
                      value: _activeLoan != null
                          ? 'KES ${NumberFormat('#,##0.00').format(_activeLoan!.amountPaid)}'
                          : 'KES 0',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Next Due',
                      value: _activeLoan != null && _activeLoan!.dueDate != null
                          ? DateFormat('MMM dd').format(_activeLoan!.dueDate!)
                          : 'N/A',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  userPhone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Dashboard'),
            onTap: () {
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Get.back();
              Get.toNamed('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('My Loans'),
            onTap: () {
              Get.back();
              Get.toNamed('/my-loans');
            },
          ),
          ListTile(
            leading: const Icon(Icons.motorcycle),
            title: const Text('My Motorcycle'),
            onTap: () {
              Get.back();
              Get.snackbar(
                'My Motorcycle',
                'Feature coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Get.back();
              Get.snackbar(
                'Settings',
                'Feature coming soon',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Get.back();
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Get.back();
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoanSummaryCard(BuildContext context) {
    if (_activeLoan == null) return const SizedBox.shrink();

    final currencyFormat = NumberFormat.currency(symbol: 'KES ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade600,
              Colors.green.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Loan',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                        ),
                        Text(
                          _activeLoan!.loanNumber,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
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
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Outstanding Balance
            Text(
              'Outstanding Balance',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              currencyFormat.format(_activeLoan!.balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _activeLoan!.paymentProgress / 100,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_activeLoan!.paymentProgress.toStringAsFixed(1)}% paid',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
                Text(
                  currencyFormat.format(_activeLoan!.amountPaid),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white38),
            const SizedBox(height: 12),

            // Due Date & Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_activeLoan!.dueDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Payment Due',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            dateFormat.format(_activeLoan!.dueDate!),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed('/payments', arguments: _activeLoan);
                  },
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
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

  Future<void> _handleLogout(BuildContext context) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog

              // Show loading
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              // Call logout API
              await _authService.logout();

              Get.back(); // Close loading
              Get.offAllNamed('/login'); // Navigate to login and clear stack

              Get.snackbar(
                'Logged Out',
                'You have been successfully logged out',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MAN\'S CHOICE ENTERPRISE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Credit Management System'),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'For support, contact us at:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Text('info@manschoice.co.ke'),
            const Text('+254 700 000 000'),
          ],
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
}
