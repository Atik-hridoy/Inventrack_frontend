import 'package:flutter/material.dart';
import 'package:inventrack_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:inventrack_frontend/features/auth/screens/register_screen.dart';
import 'package:inventrack_frontend/features/product/screens/product_feed_screen.dart';
import 'package:inventrack_frontend/features/product/screens/product_list_screen.dart';
import 'package:inventrack_frontend/features/product/screens/add_product_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const LoginScreen(),
    '/product-feed': (context) => const ProductFeedScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/register': (context) => const RegisterScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/product-list': (context) => const ProductListScreen(),
    '/add-product': (context) => const AddProductScreen(),
    // Add more routes as needed' // Assuming this is the same screen for adding products
  };
}
