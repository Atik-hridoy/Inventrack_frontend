import 'package:http/http.dart' as http;


import 'dart:convert';

class ProductApi {
  static Future<Map<String, dynamic>> getProducts() async {
    return await ApiService.get('products/');
  }
}

class ApiService {
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response =
        await http.get(Uri.parse('https://127.0.0.1:8000/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
