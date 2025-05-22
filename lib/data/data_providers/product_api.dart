import 'package:http/http.dart' as http;
import '../../core/services/api_service.dart';

class ProductApi {
  static Future<http.Response> getProducts() async {
    return await ApiService.get('products/');
  }
}
