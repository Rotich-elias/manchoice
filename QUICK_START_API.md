# Quick Start: Connect Flutter to Backend

## ⚡ 5-Minute Setup

### Step 1: Update API URL

Edit `lib/config/api_config.dart` and change the `baseUrl`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

**For Physical Device:**
Find your computer's IP address and use it:
```bash
# Run this command on your computer:
hostname -I | awk '{print $1}'
```

Then use:
```dart
static const String baseUrl = 'http://YOUR_IP_HERE:8000/api';
```

### Step 2: Start Backend Server

Open terminal and run:
```bash
cd /home/smith/Desktop/myproject/manchoice-backend
./artisan.sh serve --host=0.0.0.0 --port=8000
```

Keep this terminal open!

### Step 3: Test Connection

Add this to your Flutter app (e.g., in a button):

```dart
import 'package:manchoice/services/auth_service.dart';

final authService = AuthService();

Future<void> testApi() async {
  try {
    final result = await authService.login(
      email: 'admin@manschoice.com',
      password: 'password123',
    );

    if (result['success']) {
      print('✅ Connected! User: ${result['user'].name}');
    } else {
      print('❌ Error: ${result['message']}');
    }
  } catch (e) {
    print('❌ Connection failed: $e');
  }
}
```

**Or use the Test Screen:**

1. Copy `lib/test_backend_connection.dart`
2. Add route in your app
3. Navigate to test screen
4. Tap "Run Connection Test"

## 📱 Example: Login Screen

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

  Future<void> _login() async {
    final result = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
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
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔍 Troubleshooting

### "Connection refused" error?
- ✅ Backend server is running? Check terminal
- ✅ Using correct IP address?
- ✅ Phone and computer on same WiFi?

### "401 Unauthorized" error?
- Token expired, login again

### "Network error" on device?
- Check firewall
- Make sure backend uses `--host=0.0.0.0`
- Phone and computer must be on same network

## 📚 Full Documentation

See `BACKEND_INTEGRATION_GUIDE.md` for:
- Complete API usage examples
- All available methods
- Error handling
- M-PESA integration
- And more!

## ✅ Ready to Go!

You now have:
- ✅ API Service configured
- ✅ Authentication ready
- ✅ Customer, Loan, Payment repositories
- ✅ Models matching backend
- ✅ Error handling
- ✅ Token management

Start building your screens using the repositories! 🚀

## Test Credentials

```
Email: admin@manschoice.com
Password: password123
```
