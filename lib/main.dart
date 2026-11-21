import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'config/payment_config.dart';
import 'services/cart_service.dart';
import 'config/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize Firebase on mobile (phone auth doesn't work on web)
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  // Keep payment/paybill values in sync with the backend when available.
  await PaymentConfig.loadFromBackend();

  // Register the shared cart once so every screen sees the same instance.
  Get.put(CartService(), permanent: true);

  runApp(const PlumerApp());
}

class PlumerApp extends StatelessWidget {
  const PlumerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Man\'s Choice Enterprise',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switches based on system preference
      initialRoute: '/login', // Start with login screen
      getPages: [
        ...AppRoutes.routes,
      ],
    );
  }
}
