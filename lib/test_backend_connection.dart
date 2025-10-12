import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/customer_repository.dart';
import 'services/loan_repository.dart';

class BackendConnectionTest extends StatefulWidget {
  const BackendConnectionTest({super.key});

  @override
  State<BackendConnectionTest> createState() => _BackendConnectionTestState();
}

class _BackendConnectionTestState extends State<BackendConnectionTest> {
  final _authService = AuthService();
  final _customerRepo = CustomerRepository();
  final _loanRepo = LoanRepository();

  String _status = 'Not tested';
  bool _isLoading = false;
  Color _statusColor = Colors.grey;

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
      _statusColor = Colors.orange;
    });

    try {
      // Test 1: Login
      setState(() => _status = '1/3 Testing authentication...');
      final loginResult = await _authService.login(
        phone: '0712345678',
        pin: '1234',
      );

      if (!loginResult['success']) {
        throw Exception('Login failed: ${loginResult['message']}');
      }

      // Test 2: Fetch customers
      setState(() => _status = '2/3 Fetching customers...');
      final customers = await _customerRepo.getAllCustomers();

      // Test 3: Fetch loans
      setState(() => _status = '3/3 Fetching loans...');
      final loans = await _loanRepo.getAllLoans();

      // Success!
      setState(() {
        _status =
            '''✅ Backend Connected Successfully!

User: ${loginResult['user'].name}
Customers: ${customers.length}
Loans: ${loans.length}

All API endpoints are working!''';
        _statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _status =
            '''❌ Connection Failed

Error: $e

Troubleshooting:
1. Make sure backend is running
2. Check API base URL in api_config.dart
3. For Android emulator, use 10.0.2.2
4. For physical device, use computer's IP''';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backend Connection Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              _statusColor == Colors.green
                  ? Icons.check_circle
                  : _statusColor == Colors.red
                  ? Icons.error
                  : Icons.cloud,
              size: 80,
              color: _statusColor,
            ),
            SizedBox(height: 24),
            Text(
              'Backend API Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  _status,
                  style: TextStyle(fontSize: 14, color: _statusColor),
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runTests,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(Icons.play_arrow),
              label: Text(_isLoading ? 'Testing...' : 'Run Connection Test'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this to your routes or main.dart to test:
/*
import 'test_backend_connection.dart';

// In your routes:
'/test-backend': (context) => BackendConnectionTest(),

// Or navigate directly:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => BackendConnectionTest()),
);
*/
