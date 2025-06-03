import '../data_providers/product_api.dart';

class ProductRepository {
  Future<List<dynamic>> fetchProducts() async {
    final response = await ProductApiService.getProductFeed();
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['error'] ?? 'Failed to fetch products');
    }
  }

  Future<dynamic> createProduct({
    required String name,
    required String sku,
    required double price,
    required int quantity,
    String? imageBase64,
    dynamic imageFile,
  }) async {
    final response = await ProductApiService.createProduct(
      name: name,
      sku: sku,
      price: price,
      quantity: quantity,
      imageBase64: imageBase64,
      imageFile: imageFile,
    );
    if (response['success'] == true) {
      return response['data'];
    } else {
      throw Exception(response['error'] ?? 'Failed to create product');
    }
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required String sku,
    required double price,
    required int quantity,
  }) async {
    final response = await ProductApiService.updateProduct(
      id: id,
      name: name,
      sku: sku,
      price: price,
      quantity: quantity,
    );
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await ProductApiService.deleteProduct(id);
    if (response['success'] != true) {
      throw Exception(response['error'] ?? 'Failed to delete product');
    }
  }
}