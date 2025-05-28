import 'package:flutter/material.dart';
import 'package:inventrack_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:inventrack_frontend/features/auth/screens/register_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/register': (context) => const RegisterScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
  };
}
