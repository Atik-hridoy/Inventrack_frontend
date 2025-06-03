import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/repositories/product_repository.dart';
import 'features/product/controllers/product_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductController(ProductRepository()),
      child: const InventrackApp(),
    ),
  );
}
