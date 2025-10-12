import 'package:get/get.dart';
import 'package:manschoice/bindings/profile_binding.dart';
import 'package:manschoice/screens/profile_screen.dart';
import 'package:manschoice/screens/splash_screen.dart';
import 'package:manschoice/screens/login_screen.dart';
import 'package:manschoice/screens/signup_screen.dart';
import 'package:manschoice/screens/signup_screen_simple.dart';
import 'package:manschoice/screens/dashboard_screen.dart';
import 'package:manschoice/screens/loan_application_screen.dart';
import 'package:manschoice/screens/loan_application_screen_simple.dart';
import 'package:manschoice/screens/new_loan_application_screen.dart';
import 'package:manschoice/screens/my_loans_screen.dart';
import 'package:manschoice/screens/payments_screen.dart';
import 'package:manschoice/screens/products_screen.dart';
import 'package:manschoice/screens/cart_screen.dart';
import 'package:manschoice/screens/support_screen.dart';

class AppRoutes {
  static final routes = <GetPage>[
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/login', page: () => const LoginScreen()),
    GetPage(name: '/signup', page: () => const SignupScreenSimple()),
    GetPage(name: '/signup-full', page: () => const SignupScreen()), // Full loan application form
    GetPage(name: '/dashboard', page: () => const DashboardScreen()),
    GetPage(name: '/loan-application', page: () => const LoanApplicationScreenSimple()),
    GetPage(name: '/loan-application-full', page: () => const LoanApplicationScreen()), // Full loan application form
    GetPage(name: '/new-loan-application', page: () => const NewLoanApplicationScreen()), // New comprehensive loan application
    GetPage(name: '/my-loans', page: () => const MyLoansScreen()),
    GetPage(name: '/payments', page: () => const PaymentsScreen()),
    GetPage(name: '/products', page: () => const ProductsScreen()),
    GetPage(name: '/cart', page: () => const CartScreen()),
    GetPage(name: '/support', page: () => const SupportScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen(), binding: ProfileBinding()),
  ];
}
