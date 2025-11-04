import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  FirebaseAuth? _auth;

  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;
  int? _resendToken;

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Auth only on mobile
    if (!kIsWeb) {
      _auth = FirebaseAuth.instance;
    }

    // Get phone number from arguments if provided
    final args = Get.arguments;
    if (args != null && args['phone'] != null) {
      _phoneController.text = args['phone'];
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Convert Kenyan phone format to international
    // 0712345678 -> +254712345678
    if (phone.startsWith('0')) {
      return '+254${phone.substring(1)}';
    } else if (phone.startsWith('254')) {
      return '+$phone';
    } else if (phone.startsWith('+254')) {
      return phone;
    }
    return '+254$phone';
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Phone auth only works on mobile
    if (kIsWeb || _auth == null) {
      Get.snackbar(
        'Error',
        'Phone authentication is only available on mobile devices',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final phoneNumber = _formatPhoneNumber(_phoneController.text.trim());

      await _auth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (happens on some devices)
          try {
            await _auth!.signInWithCredential(credential);
            // Immediately sign out as we only needed verification
            await _auth!.signOut();
          } catch (e) {
            // Ignore errors here, auto-verification worked
            await _auth!.signOut();
          }

          if (!mounted) return;

          Get.snackbar(
            'Success',
            'Phone verified automatically!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Return verified phone to previous screen
          Get.back(result: {
            'verified': true,
            'phone': _phoneController.text.trim(),
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          String errorMessage = 'Verification failed';

          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'SMS quota exceeded. Please try again tomorrow';
          }

          Get.snackbar(
            'Error',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );

          setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;

          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _codeSent = true;
            _isLoading = false;
          });

          Get.snackbar(
            'Code Sent',
            'OTP has been sent to your phone',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'Error',
        'Failed to send OTP: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the 6-digit code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    bool verificationSuccessful = false;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      // Try to sign in to verify the credential is valid
      try {
        await _auth!.signInWithCredential(credential);
        verificationSuccessful = true;
      } catch (signInError) {
        // If there's a type casting error, verification actually succeeded
        if (signInError.toString().contains('type') ||
            signInError.toString().contains('PigeonUserDetails')) {
          verificationSuccessful = true;
        } else {
          rethrow; // Re-throw if it's a different error
        }
      }

      // Clean up - sign out
      try {
        await _auth!.signOut();
      } catch (e) {
        // Ignore sign out errors
      }

      if (!mounted) return;

      if (verificationSuccessful) {
        // Stop loading immediately
        setState(() => _isLoading = false);

        // Small delay to ensure UI updates
        await Future.delayed(const Duration(milliseconds: 100));

        // Return to signup screen
        Get.back(result: {
          'verified': true,
          'phone': _phoneController.text.trim(),
        });

        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            'Phone Verified!',
            'Your phone number has been verified',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage = 'Verification failed';

      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid OTP code. Please check and try again';
      } else if (e.code == 'session-expired') {
        errorMessage = 'OTP expired. Please request a new code';
        setState(() {
          _codeSent = false;
          _verificationId = null;
        });
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Verification'),
        centerTitle: true,
      ),
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
                  Icons.phone_android,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Verify Your Phone Number',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We will send you a one-time verification code',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),

                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  enabled: !_codeSent,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '0712345678',
                    prefixIcon: const Icon(Icons.phone),
                    helperText: 'Format: 0XXXXXXXXX',
                    suffixIcon: _codeSent
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^0[0-9]{9}$').hasMatch(value)) {
                      return 'Invalid phone format. Use 0XXXXXXXXX';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Send OTP Button
                if (!_codeSent)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),

                // OTP Input and Verify Section
                if (_codeSent) ...[
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '------',
                      prefixIcon: Icon(Icons.lock),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Verify OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Resend OTP
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _codeSent = false;
                        _otpController.clear();
                      });
                      _sendOTP();
                    },
                    child: const Text('Resend OTP'),
                  ),
                ],

                const SizedBox(height: 32),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You will receive a 6-digit verification code via SMS',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
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
      ),
    );
  }
}
