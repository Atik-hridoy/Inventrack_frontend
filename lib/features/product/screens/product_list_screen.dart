import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import 'package:inventrack_frontend/core/services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = ProductApiService.getProductFeed().then((map) {
      if (map['success'] == true && map['data'] != null) {
        final List<dynamic> productList =
            map['data'] is List ? map['data'] : (map['data']['products'] ?? []);
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(map['error'] ?? 'Failed to load products');
      }
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _products = ProductApiService.getProductFeed().then((map) {
        final List<dynamic> productList = map['products'] ?? [];
        return productList.map((json) => Product.fromJson(json)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Inventory")),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshProducts,
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Text(product.name[0].toUpperCase()),
                  ),
                  title: Text(product.name),
                  subtitle:
                      Text('SKU: ${product.sku}\nQty: ${product.quantity}'),
                  trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                  isThreeLine: true,
                  onTap: () {
                    // TODO: Navigate to details/edit screen
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
