// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_api_service.dart';

class ApiService {
  // Base URL depending on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://192.168.0.104:8000/api'; // Replace with your local IP
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  static const Duration timeout = Duration(seconds: 15);
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? additionalHeaders,
    bool debug = true,
  }) async {
    try {
      // Clean endpoint and ensure trailing slash
      String cleanedEndpoint = endpoint.replaceAll(RegExp(r'^/+|/+$'), '');
      final url = Uri.parse('$baseUrl/$cleanedEndpoint/');

      if (debug) print('🌐 POST $url');

      // Always try to add the auth token if available
      final token = AuthApiService.getAuthToken();
      String? tokenValue;
      if (token is String) {
        tokenValue = token;
      } else {
        tokenValue = null;
      }
      final headers = {
        ...defaultHeaders,
        if (tokenValue != null && tokenValue.isNotEmpty)
          'Authorization': 'Bearer $tokenValue',
        ...?additionalHeaders,
      };
      final encodedBody = jsonEncode(data);

      if (debug) {
        print('📤 Headers: $headers');
        print('📦 Body: $encodedBody');
      }

      final response = await http
          .post(url, headers: headers, body: encodedBody)
          .timeout(timeout);

      return _processResponse(response, debug: debug);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Generic GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    bool debug = true,
  }) async {
    try {
      String cleanedEndpoint = endpoint.replaceAll(RegExp(r'^/+|/+$'), '');
      final url = Uri.parse('$baseUrl/$cleanedEndpoint/');

      if (debug) print('🌐 GET $url');

      // Always try to add the auth token if available
      final token = AuthApiService.getAuthToken();
      String? tokenValue;
      if (token is String) {
        tokenValue = token;
      } else {
        tokenValue = null;
      }
      final mergedHeaders = {
        ...defaultHeaders,
        if (tokenValue != null && tokenValue.isNotEmpty)
          'Authorization': 'Bearer $tokenValue',
        ...?headers,
      };

      if (debug) print('📤 Headers: $mergedHeaders');

      final response =
          await http.get(url, headers: mergedHeaders).timeout(timeout);

      return _processResponse(response, debug: debug);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Process the HTTP response
  static Map<String, dynamic> _processResponse(
    http.Response response, {
    bool debug = true,
  }) {
    final status = response.statusCode;

    if (debug) {
      print('📥 Status: $status');
    }

    if (_isHtml(response)) {
      return _error('Received HTML instead of JSON', status,
          raw: response.body);
    }

    if (response.body.isEmpty) {
      return _error('Empty response', status);
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (status >= 200 && status < 300) {
        return {
          'success': true,
          'data': decoded,
          'statusCode': status,
        };
      } else {
        return _error(
          decoded['error'] ?? decoded['detail'] ?? 'Error occurred',
          status,
          errors: decoded,
        );
      }
    } catch (e) {
      return _error('Invalid JSON response', status);
    }
  }

  /// Detect HTML response
  static bool _isHtml(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    return contentType.toLowerCase().contains('text/html');
  }

  /// Standard error builder
  static Map<String, dynamic> _error(
    String message,
    int? statusCode, {
    dynamic errors,
    String? raw,
  }) {
    return {
      'success': false,
      'error': message,
      'statusCode': statusCode,
      if (errors != null) 'errors': errors,
      if (raw != null)
        'rawResponse': raw.substring(0, raw.length > 200 ? 200 : raw.length),
    };
  }

  /// Generic error handler
  static Map<String, dynamic> _handleError(dynamic e) {
    if (e is SocketException) {
      return _error('Network error: ${e.message}', null);
    } else if (e is TimeoutException) {
      return _error('Request timed out', null);
    } else {
      return _error('Unexpected error: ${e.toString()}', null);
    }
  }
}
