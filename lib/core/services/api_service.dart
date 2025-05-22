import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'http://10.0.2.2:8000/api/'; // Localhost for emulator

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url);
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, body: data);
  }
}
