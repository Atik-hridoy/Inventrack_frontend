import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'config/app_theme.dart';

class InventrackApp extends StatelessWidget {
  const InventrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventrack',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: AppRoutes.routes,
    );
  }
}
