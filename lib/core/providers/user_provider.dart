// lib/core/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  String? _staffName;
  String? _email;
  String? _username; // <-- Add this

  String? get staffName => _staffName;
  String? get email => _email;
  String? get username => _username; // <-- Add this

  void setStaffName(String name) {
    _staffName = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setUsername(String username) {
    // <-- Add this
    _username = username;
    notifyListeners();
  }

  // Fetch user info from backend using token or email
  Future<void> fetchAndSetUserInfo({required String email}) async {
    final response = await ApiService.get('accounts/list/');
    if (response['success'] == true && response['data'] != null) {
      final users = response['data'] is List
          ? response['data']
          : (response['data']['users'] ?? []);
      final user = users.firstWhere(
        (u) => u['email'] == email,
        orElse: () => null,
      );
      if (user != null) {
        setStaffName(user['first_name'] ?? user['username'] ?? '');
        setEmail(user['email']);
        setUsername(user['username'] ?? ''); // <-- Set username
      }
    }
  }

  void clear() {
    _staffName = null;
    _email = null;
    _username = null; // <-- Clear username
    notifyListeners();
  }
}
