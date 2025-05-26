import 'package:flutter/material.dart';

class AuthController with ChangeNotifier {
  // Example: Track loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Example: Track authentication status
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Example: Store error messages
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Simulated login method
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Dummy authentication logic
    if (username == 'admin' && password == 'admin123') {
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      _isAuthenticated = false;
      _errorMessage = 'Invalid username or password';
    }

    _setLoading(false);
    notifyListeners();
  }

  // Simulated logout method
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
