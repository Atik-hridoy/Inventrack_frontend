// lib/core/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserProvider extends ChangeNotifier {
  String? _staffName;
  String? _email;
  String? get staffName => _staffName;
  String? get email => _email;

  void setStaffName(String name) {
    _staffName = name;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
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
      }
    }
  }

  void clear() {
    _staffName = null;
    _email = null;
    notifyListeners();
  }
}
