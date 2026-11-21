import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../config/payment_config.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePin = true;
  bool _isLoading = false;

  static String get _supportPhone => PaymentConfig.supportPhone;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _showForgotPinDialog() {
    final theme = Theme.of(context);
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: theme.colorScheme.primary,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text('Forgot your PIN?', style: theme.textTheme.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For security, PIN resets are handled by our support team.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text('Call or WhatsApp', style: theme.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _supportPhone,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Have your registered phone number ready when you contact us.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await _authService.login(
        phone: _phoneController.text.trim(),
        pin: _pinController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Get.offAllNamed('/dashboard');
        Get.snackbar(
          'Welcome!',
          'Login successful',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else if (result['requires_registration_fee'] == true) {
        Get.offAllNamed('/registration-fee-status', arguments: {
          'status': result['registration_fee_status'],
          'payment_status': result['payment_status'],
          'user_phone': result['user_phone'],
        });
      } else {
        Get.snackbar(
          'Login failed',
          result['message'] ?? 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        'Connection error',
        'Please check your internet connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, AppColors.ink]
                : [AppColors.goldSoft, AppColors.canvas],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Brand mark
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldDeep.withValues(alpha: 0.25),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 56,
                                backgroundColor: theme.colorScheme.surface,
                                child: ClipOval(
                                  child: Image.asset(
                                    'lib/assets/images/logo.jpg',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'MAN\'S CHOICE',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ENTERPRISE',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isDark ? AppColors.gold : AppColors.goldDeep,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '"Aiming the future, Together"',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Divider(color: theme.dividerColor),
                          const SizedBox(height: 24),

                          Text(
                            'Sign in to your account',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),

                          // Phone number
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                              hintText: '0712345678',
                              prefixIcon: Icon(Icons.phone_outlined),
                              helperText: 'Format: 0XXXXXXXXX',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!RegExp(r'^0[0-9]{9}$').hasMatch(value.trim())) {
                                return 'Invalid phone format. Use 0XXXXXXXXX';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PIN
                          TextFormField(
                            controller: _pinController,
                            obscureText: _obscurePin,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            decoration: InputDecoration(
                              labelText: '4-digit PIN',
                              hintText: 'Enter your PIN',
                              prefixIcon: const Icon(Icons.lock_outline),
                              counterText: '',
                              suffixIcon: IconButton(
                                tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
                                icon: Icon(
                                  _obscurePin
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePin = !_obscurePin,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your PIN';
                              }
                              if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
                                return 'PIN must be exactly 4 digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Sign in button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: theme.textTheme.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed('/signup'),
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _showForgotPinDialog,
                            child: const Text('Forgot PIN?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
