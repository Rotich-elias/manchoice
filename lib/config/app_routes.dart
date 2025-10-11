import 'package:get/get.dart';
import 'package:manchoice/bindings/profile_binding.dart';
import 'package:manchoice/screens/profile_screen.dart';
import 'package:manchoice/screens/splash_screen.dart';
import 'package:manchoice/screens/login_screen.dart';
import 'package:manchoice/screens/signup_screen.dart';
import 'package:manchoice/screens/signup_screen_simple.dart';
import 'package:manchoice/screens/dashboard_screen.dart';
import 'package:manchoice/screens/loan_application_screen.dart';
import 'package:manchoice/screens/payments_screen.dart';
import 'package:manchoice/screens/products_screen.dart';
import 'package:manchoice/screens/support_screen.dart';

class AppRoutes {
  static final routes = <GetPage>[
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/signup', page: () => const SignupScreenSimple()),
    GetPage(name: '/signup-full', page: () => const SignupScreen()), // Full loan application form
    GetPage(name: '/dashboard', page: () => const DashboardScreen()),
    GetPage(name: '/loan-application', page: () => const LoanApplicationScreen()),
    GetPage(name: '/payments', page: () => const PaymentsScreen()),
    GetPage(name: '/products', page: () => const ProductsScreen()),
    GetPage(name: '/support', page: () => const SupportScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen(), binding: ProfileBinding()),
  ];
}
