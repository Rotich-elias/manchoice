import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_theme.dart';
import 'config/app_routes.dart';
import 'screens/main_page.dart';

void main() {
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
      initialRoute: '/dashboard', // Skip directly to dashboard for testing
      getPages: [
        GetPage(name: '/', page: () => const MainPage()),
        ...AppRoutes.routes,
      ],
    );
  }
}
