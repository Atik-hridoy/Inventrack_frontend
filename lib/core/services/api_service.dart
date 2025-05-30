// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Configuration - Set your base URL here
  static String get baseUrl {
    if (kIsWeb) {
      // For Flutter Web, use your machine's LAN IP (not localhost or 127.0.0.1)
      return 'http://192.168.0.103:8000/api'; // <-- Replace with your real LAN IP
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Default headers for JSON API
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Main POST method with complete error handling
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? additionalHeaders,
    bool debug = true,
  }) async {
    try {
      // Build the complete URL
      final url =
          Uri.parse('$baseUrl/${endpoint.replaceAll(RegExp(r'^/|/$'), '')}');
      if (debug) print('🌐 API Request: POST $url');

      // Prepare headers
      final headers = {...defaultHeaders, ...?additionalHeaders};
      if (debug) print('📤 Request Headers: $headers');

      // Encode data
      final encodedData = jsonEncode(data);
      if (debug) print('📦 Request Body: $encodedData');

      // Make the request with timeouts
      final response = await http
          .post(
        url,
        headers: headers,
        body: encodedData,
      )
          .timeout(receiveTimeout, onTimeout: () {
        throw const SocketException('Request timed out');
      });

      if (debug) {
        print('📥 Response Status: ${response.statusCode}');
        print('📦 Response Body: ${response.body}');
      }

      // Process the response
      return _processResponse(response, debug: debug);
    } on SocketException catch (e) {
      return _buildErrorResponse('Network error: ${e.message}');
    } on FormatException catch (e) {
      return _buildErrorResponse('Data parsing error: ${e.message}');
    } on HttpException catch (e) {
      return _buildErrorResponse('HTTP error: ${e.message}');
    } catch (e) {
      return _buildErrorResponse('Unexpected error: ${e.toString()}');
    }
  }

  /// Processes all types of responses (JSON, HTML, plain text)
  static Map<String, dynamic> _processResponse(
    http.Response response, {
    bool debug = true,
  }) {
    try {
      // Handle HTML responses (Django debug pages)
      if (_isHtmlResponse(response)) {
        if (debug) print('⚠️ Received HTML response instead of JSON');
        return _buildErrorResponse(
          'Server error (${response.statusCode})',
          statusCode: response.statusCode,
          rawResponse: _truncate(response.body, 200),
        );
      }

      // Handle empty responses
      if (response.body.isEmpty) {
        return _buildErrorResponse(
          'Empty server response',
          statusCode: response.statusCode,
        );
      }

      // Try decoding JSON
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      // Successful response (2xx status code)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': decoded,
          'statusCode': response.statusCode,
        };
      }

      // Error response
      return _parseErrorResponse(decoded, response.statusCode);
    } catch (e) {
      // Fallback for non-JSON responses
      return _buildErrorResponse(
        'Invalid response format: ${_truncate(response.body, 200)}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Checks if response is HTML
  static bool _isHtmlResponse(http.Response response) {
    final contentType = response.headers['content-type']?.toLowerCase();
    return contentType?.contains('text/html') == true;
  }

  /// Parses error responses consistently
  static Map<String, dynamic> _parseErrorResponse(
    dynamic decoded,
    int statusCode,
  ) {
    // Handle Django REST framework error format
    if (decoded is Map) {
      return _buildErrorResponse(
        decoded['error'] ?? decoded['detail'] ?? decoded.toString(),
        statusCode: statusCode,
        errors: decoded['errors'],
      );
    }

    return _buildErrorResponse(
      decoded.toString(),
      statusCode: statusCode,
    );
  }

  /// Standard error response format
  static Map<String, dynamic> _buildErrorResponse(
    String message, {
    int? statusCode,
    dynamic errors,
    String? rawResponse,
  }) {
    return {
      'success': false,
      'error': message,
      'statusCode': statusCode,
      if (errors != null) 'errors': errors,
      if (rawResponse != null) 'rawResponse': rawResponse,
    };
  }

  /// Helper to truncate long strings for logging
  static String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// GET method with similar robust handling
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    bool debug = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      if (debug) print('🌐 API Request: GET $url');

      final response = await http.get(
        url,
        headers: {...defaultHeaders, ...?headers},
      ).timeout(receiveTimeout);

      return _processResponse(response, debug: debug);
    } catch (e) {
      return _buildErrorResponse(e.toString());
    }
  }
}

/// A simple Auth API service for login and registration.
class AuthApiService {
  static String get baseUrl => '${ApiService.baseUrl}/accounts';

  /// Registers a new user.
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String role, // Add this
  }) async {
    final url = Uri.parse('$baseUrl/register/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'confirm_password': confirmPassword,
          'role': role, // Send role to backend
        }),
      );
      final data = _decodeResponse(response);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['error'] ??
              data['message'] ??
              data['errors']?.toString() ??
              'Registration failed'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Could not connect to the server.'};
    }
  }

  /// Logs in a user.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = _decodeResponse(response);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? data['detail'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Could not connect to the server.'};
    }
  }

  static dynamic _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {};
    }
  }
}

class ProductApiService {
  static String get baseUrl => '${ApiService.baseUrl}/inventory';

  /// Fetches all products for the feed (list all).
  static Future<Map<String, dynamic>> getProductFeed() async {
    // This matches your Django endpoint: path('list/', ProductListView.as_view(), name='product-list')
    return await ApiService.get('inventory/list/');
  }

  /// Creates a new product (cross-platform: supports web and mobile).
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String sku,
    required double price,
    required int quantity,
    String? imageBase64, // For web
    File? imageFile, // For mobile
  }) async {
    final url = Uri.parse('$baseUrl/create/');
    try {
      if (kIsWeb) {
        // Web: Send as JSON with base64 image
        Map<String, dynamic> body = {
          'name': name,
          'sku': sku,
          'price': price,
          'quantity': quantity,
        };
        if (imageBase64 != null) {
          body['image_base64'] = imageBase64;
        }
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        final data = AuthApiService._decodeResponse(response);
        if (response.statusCode == 201 || response.statusCode == 200) {
          return {'success': true, 'data': data};
        } else {
          return {
            'success': false,
            'error': data['error'] ??
                data['message'] ??
                data['errors']?.toString() ??
                'Failed to create product'
          };
        }
      } else {
        // Mobile: Send as multipart/form-data
        var request = http.MultipartRequest('POST', url);
        request.fields['name'] = name;
        request.fields['sku'] = sku;
        request.fields['price'] = price.toString();
        request.fields['quantity'] = quantity.toString();

        if (imageFile != null) {
          request.files
              .add(await http.MultipartFile.fromPath('image', imageFile.path));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final data = AuthApiService._decodeResponse(response);
        if (response.statusCode == 201 || response.statusCode == 200) {
          return {'success': true, 'data': data};
        } else {
          return {
            'success': false,
            'error': data['error'] ??
                data['message'] ??
                data['errors']?.toString() ??
                'Failed to create product'
          };
        }
      }
    } catch (e) {
      return {'success': false, 'error': 'Could not connect to the server.'};
    }
  }
}
