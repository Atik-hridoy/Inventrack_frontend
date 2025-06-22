import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AuthApiService {
  static String get baseUrl => ApiService.baseUrl;

  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static String? getAuthToken() => _authToken;

  /// Register a new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required String role,
  }) async {
    return await ApiService.post(
      'accounts/register/', // <-- fixed: only one 'accounts' and trailing slash
      {
        'username': username,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
        'role': role,
      },
    );
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url =
        Uri.parse('${ApiService.baseUrl}/accounts/login/'); // trailing slash

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final contentType = response.headers['content-type'] ?? '';

      if (contentType.contains('application/json')) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        if (response.statusCode == 200) {
          return {'success': true, 'data': decoded};
        } else {
          return {
            'success': false,
            'error': decoded['detail'] ?? decoded['error'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: unexpected response (HTML or plain text)',
          'rawResponse': response.body,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network or parsing error: ${e.toString()}',
      };
    }
  }

  /// Update user profile and add to history
  static Future<bool> updateProfileHistory({
    required String username,
    required String email,
    required String phone,
    required String street,
    required String house,
    required String district,
    required String nickname,
  }) async {
    final data = {
      'username': username,
      'email': email,
      'phone': phone,
      'street': street,
      'house': house,
      'district': district,
      'nickname': nickname,
    };
    final token = getAuthToken();
    final response = await ApiService.post(
      'accounts/history/',
      data,
      additionalHeaders:
          token != null ? {'Authorization': 'Bearer $token'} : null,
      debug: true,
    );
    return response['success'] == true;
  }
}
