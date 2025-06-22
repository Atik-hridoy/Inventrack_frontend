import 'package:flutter/material.dart';
import 'package:inventrack_frontend/features/auth/screens/forgot_password_screen.dart';
import 'package:inventrack_frontend/features/auth/screens/register_screen.dart';
import 'package:inventrack_frontend/features/product/screens/product_feed_screen.dart';
import 'package:inventrack_frontend/features/product/screens/product_list_screen.dart';
import 'package:inventrack_frontend/features/product/screens/add_product_screen.dart';
import 'package:inventrack_frontend/features/product/screens/edit_product_screen.dart';
import 'package:inventrack_frontend/features/stock/stock_management_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/accounts/user_account_screen.dart'; // <-- Add this import

class AppRoutes {
  static final routes = <String, WidgetBuilder>{
    '/': (context) => const LoginScreen(),
    '/product-feed': (context) => const ProductFeedScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    '/register': (context) => const RegisterScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    '/product-list': (context) => const ProductListScreen(),
    '/add-product': (context) => const AddProductScreen(),
    '/account': (context) => const UserAccountScreen(), // <-- Add this route
    '/edit-product': (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args == null || args is! Map<String, dynamic>) {
        // Handle error or show a fallback screen
        return const Scaffold(
          body: Center(child: Text('No product data provided')),
        );
      }
      return EditProductScreen(product: args);
    },
    '/stock-management': (context) => const StockManagementScreen(),
    // Add more routes as needed
  };
}
