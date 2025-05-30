import 'package:flutter/material.dart';
import 'package:inventrack_frontend/core/services/api_service.dart';
import '../../../data/models/product.dart';

class ProductFeedScreen extends StatefulWidget {
  const ProductFeedScreen({super.key});

  @override
  State<ProductFeedScreen> createState() => _ProductFeedScreenState();
}

class _ProductFeedScreenState extends State<ProductFeedScreen> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = ProductApiService.getProductFeed().then((map) {
      if (map['success'] == true && map['data'] != null) {
        final data = map['data'];
        List<dynamic> productList = [];
        if (data is List) {
          productList = data;
        } else if (data is Map && data['products'] is List) {
          productList = data['products'];
        }
        return productList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(map['error'] ?? 'Failed to load products');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Feed")),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 columns like Amazon
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68, // Card height/width ratio
              ),
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Navigate to product details
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: p.image.isNotEmpty
                              ? Image.network(
                                  p.image,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.image_not_supported,
                                          size: 80),
                                )
                              : Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image,
                                      size: 80, color: Colors.grey),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'SKU: ${p.sku}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blueGrey),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Qty: ${p.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
