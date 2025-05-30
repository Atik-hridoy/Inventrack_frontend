import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart'; // Make sure this import points to your model

class ProductApi {
  static Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1:8000/api/products/')); // Or use ApiService.get if you're using that
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
