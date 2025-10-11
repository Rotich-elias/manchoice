# Flutter Backend Integration Guide

## Overview

This guide explains how to connect your Flutter app to the Laravel backend API.

## ✅ What's Been Set Up

### 1. API Configuration (`lib/config/api_config.dart`)
- Base URL configuration
- API endpoints
- Timeouts and headers

### 2. API Service (`lib/services/api_service.dart`)
- HTTP client (Dio) with interceptors
- Token management
- Error handling
- GET, POST, PUT, DELETE methods

### 3. Authentication Service (`lib/services/auth_service.dart`)
- Register
- Login
- Logout
- Get current user

### 4. Data Models
- `lib/models/user.dart` - User model
- `lib/models/customer_api.dart` - Customer model (matching backend)
- `lib/models/loan.dart` - Loan model
- `lib/models/payment.dart` - Payment model

### 5. Repository Classes
- `lib/services/customer_repository.dart` - Customer CRUD operations
- `lib/services/loan_repository.dart` - Loan CRUD operations
- `lib/services/payment_repository.dart` - Payment & M-PESA operations

## 🔧 Configuration Steps

### Step 1: Update API Base URL

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Choose the right URL for your setup:

  // For Android Emulator:
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // For iOS Simulator:
  // static const String baseUrl = 'http://localhost:8000/api';

  // For Physical Device (use your computer's IP):
  // static const String baseUrl = 'http://192.168.1.100:8000/api';
}
```

**Finding your computer's IP:**
```bash
# Linux/Mac
ifconfig | grep "inet " | grep -v 127.0.0.1

# Windows
ipconfig
```

### Step 2: Ensure Backend is Running

```bash
cd /home/smith/Desktop/myproject/manchoice-backend
./artisan.sh serve --host=0.0.0.0 --port=8000
```

The server must be accessible from your device/emulator.

## 📱 Usage Examples

### Authentication

#### Register New User
```dart
import 'package:manchoice/services/auth_service.dart';

final authService = AuthService();

Future<void> registerUser() async {
  final result = await authService.register(
    name: 'John Doe',
    email: 'john@example.com',
    password: 'password123',
    passwordConfirmation: 'password123',
  );

  if (result['success']) {
    final user = result['user'];
    final token = result['token'];
    print('User registered: ${user.name}');
    print('Token: $token');
  } else {
    print('Error: ${result['message']}');
  }
}
```

#### Login
```dart
Future<void> loginUser() async {
  final result = await authService.login(
    email: 'john@example.com',
    password: 'password123',
  );

  if (result['success']) {
    final user = result['user'];
    print('Logged in as: ${user.name}');
    // Navigate to home screen
  } else {
    print('Error: ${result['message']}');
  }
}
```

#### Logout
```dart
Future<void> logoutUser() async {
  await authService.logout();
  // Navigate to login screen
}
```

### Customer Operations

```dart
import 'package:manchoice/services/customer_repository.dart';

final customerRepo = CustomerRepository();

// Get all customers
Future<void> fetchCustomers() async {
  try {
    final customers = await customerRepo.getAllCustomers();
    print('Found ${customers.length} customers');
  } catch (e) {
    print('Error: $e');
  }
}

// Create customer
Future<void> addCustomer() async {
  try {
    final customer = await customerRepo.createCustomer(
      name: 'Jane Doe',
      phone: '254712345678',
      email: 'jane@example.com',
      idNumber: '12345678',
      address: 'Nairobi, Kenya',
      creditLimit: 50000,
    );

    if (customer != null) {
      print('Customer created: ${customer.name}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Get customer by ID
Future<void> getCustomer(int id) async {
  try {
    final customer = await customerRepo.getCustomerById(id);
    if (customer != null) {
      print('Customer: ${customer.name}');
      print('Outstanding: ${customer.outstandingBalance}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

### Loan Operations

```dart
import 'package:manchoice/services/loan_repository.dart';

final loanRepo = LoanRepository();

// Create loan
Future<void> createLoan() async {
  try {
    final loan = await loanRepo.createLoan(
      customerId: 1,
      principalAmount: 20000,
      interestRate: 10,
      durationDays: 30,
      purpose: 'Business expansion',
    );

    if (loan != null) {
      print('Loan created: ${loan.loanNumber}');
      print('Total amount: KES ${loan.totalAmount}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Approve loan
Future<void> approveLoan(int loanId) async {
  try {
    final loan = await loanRepo.approveLoan(loanId);
    if (loan != null) {
      print('Loan approved: ${loan.status}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Get all loans
Future<void> fetchLoans() async {
  try {
    final loans = await loanRepo.getAllLoans();
    for (var loan in loans) {
      print('${loan.loanNumber}: KES ${loan.balance} remaining');
      if (loan.isOverdue) {
        print('  ⚠️  Overdue by ${loan.daysOverdue} days');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Get overdue loans only
Future<void> fetchOverdueLoans() async {
  try {
    final loans = await loanRepo.getAllLoans(overdue: true);
    print('Found ${loans.length} overdue loans');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Payment Operations

```dart
import 'package:manchoice/services/payment_repository.dart';

final paymentRepo = PaymentRepository();

// Record cash payment
Future<void> recordPayment() async {
  try {
    final payment = await paymentRepo.createPayment(
      loanId: 1,
      amount: 5000,
      paymentMethod: 'cash',
      paymentDate: DateTime.now(),
      notes: 'Cash payment',
    );

    if (payment != null) {
      print('Payment recorded: KES ${payment.amount}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

// Initiate M-PESA payment
Future<void> payWithMpesa() async {
  try {
    final result = await paymentRepo.initiateMpesaPayment(
      loanId: 1,
      phoneNumber: '254712345678',
      amount: 5000,
    );

    if (result != null) {
      final checkoutRequestId = result['checkout_request_id'];
      print('M-PESA prompt sent!');
      print('Checkout ID: $checkoutRequestId');

      // Wait a few seconds then check status
      await Future.delayed(Duration(seconds: 5));

      final payment = await paymentRepo.checkMpesaPaymentStatus(
        checkoutRequestId,
      );

      if (payment != null) {
        print('Payment status: ${payment.status}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## 🎨 UI Integration Example

### Login Screen Update

```dart
import 'package:flutter/material.dart';
import 'package:manchoice/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result['success']) {
        // Navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔍 Testing the Connection

### Quick Test
```dart
// Add this to your main.dart or a test screen
import 'package:manchoice/services/auth_service.dart';

Future<void> testConnection() async {
  final authService = AuthService();

  print('Testing backend connection...');

  try {
    final result = await authService.login(
      email: 'admin@manschoice.com',
      password: 'password123',
    );

    if (result['success']) {
      print('✅ Backend connected successfully!');
      print('User: ${result['user'].name}');
    } else {
      print('❌ Login failed: ${result['message']}');
    }
  } catch (e) {
    print('❌ Connection error: $e');
    print('Make sure the backend server is running!');
  }
}
```

## 🐛 Troubleshooting

### Connection Refused
**Problem**: `Connection refused` or `Failed host lookup`

**Solutions**:
1. Make sure backend is running: `./artisan.sh serve --host=0.0.0.0`
2. Use correct IP address in `api_config.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. Check firewall settings

### 401 Unauthorized
**Problem**: API returns 401 error

**Solutions**:
1. Token might be expired - login again
2. Check if token is being sent in headers
3. Clear app data and login again

### Network Error on Physical Device
**Problem**: Works on emulator but not on physical device

**Solutions**:
1. Ensure phone and computer are on same WiFi
2. Use computer's IP address, not `localhost`
3. Disable any VPN on phone or computer
4. Check if backend is bound to `0.0.0.0`, not `127.0.0.1`

## 🚀 Next Steps

1. Update `api_config.dart` with your IP address
2. Start the backend server
3. Test authentication flow
4. Implement screens using the repositories
5. Add error handling and loading states
6. Test M-PESA integration (requires real credentials)

## 📝 Notes

- The backend uses Bearer token authentication
- Token is automatically saved to SharedPreferences
- Token is automatically attached to all API requests
- All dates are in ISO 8601 format
- Amounts are in Kenyan Shillings (KES)

## 🔗 Resources

- Backend API Documentation: See `manchoice-backend/README.md`
- API Test Script: `manchoice-backend/test-api.sh`
- Backend Quick Start: `manchoice-backend/START_SERVER.md`

## Test Credentials

```
Email: admin@manschoice.com
Password: password123
```
