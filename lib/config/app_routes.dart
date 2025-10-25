import 'package:get/get.dart';
import 'package:manschoice/bindings/profile_binding.dart';
import 'package:manschoice/screens/profile_screen.dart';
import 'package:manschoice/screens/splash_screen.dart';
import 'package:manschoice/screens/login_screen.dart';
import 'package:manschoice/screens/signup_screen.dart';
import 'package:manschoice/screens/signup_screen_simple.dart';
import 'package:manschoice/screens/dashboard_screen.dart';
import 'package:manschoice/screens/new_loan_application_screen.dart';
import 'package:manschoice/screens/my_loans_screen.dart';
import 'package:manschoice/screens/part_requests_screen.dart';
import 'package:manschoice/screens/payments_screen.dart';
import 'package:manschoice/screens/payment_history_screen.dart';
import 'package:manschoice/screens/products_screen.dart';
import 'package:manschoice/screens/cart_screen.dart';
import 'package:manschoice/screens/support_screen.dart';
import 'package:manschoice/screens/registration_fee_payment_screen.dart';
import 'package:manschoice/screens/registration_fee_status_screen.dart';
import 'package:manschoice/screens/deposit_payment_screen.dart';

class AppRoutes {
  static final routes = <GetPage>[
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/signup', page: () => const SignupScreenSimple()),
    GetPage(name: '/signup-full', page: () => const SignupScreen()), // Full loan application form
    GetPage(name: '/registration-fee', page: () => const RegistrationFeePaymentScreen()),
    GetPage(name: '/registration-fee-status', page: () => const RegistrationFeeStatusScreen()),
    GetPage(name: '/dashboard', page: () => const DashboardScreen()),
    GetPage(name: '/loan-application', page: () => const NewLoanApplicationScreen()), // Unified loan application
    GetPage(name: '/new-loan-application', page: () => const NewLoanApplicationScreen()), // Keep both routes for compatibility
    GetPage(name: '/my-loans', page: () => const MyLoansScreen()),
    GetPage(name: '/deposit-payment', page: () => const DepositPaymentScreen()), // For paying loan deposit
    GetPage(name: '/payments', page: () => const PaymentsScreen()), // For making payments (requires loan)
    GetPage(name: '/payment-history', page: () => const PaymentHistoryScreen()), // For viewing payment history
    GetPage(name: '/products', page: () => const ProductsScreen()),
    GetPage(name: '/cart', page: () => const CartScreen()),
    GetPage(name: '/part-requests', page: () => const PartRequestsScreen()),
    GetPage(name: '/support', page: () => SupportScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen(), binding: ProfileBinding()),
  ];
}
