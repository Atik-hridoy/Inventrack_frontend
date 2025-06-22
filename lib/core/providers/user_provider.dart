// lib/core/providers/user_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_api_service.dart';

class UserProvider extends ChangeNotifier {
  String? _staffName;
  String? _email;
  String? _username; // <-- Add this
  String? _phone;
  String? _street;
  String? _house;
  String? _district;
  String? _nickname;
  int? _userId;

  String? get staffName => _staffName;
  String? get email => _email;
  String? get username => _username; // <-- Add this
  String? get phone => _phone;
  String? get street => _street;
  String? get house => _house;
  String? get district => _district;
  String? get nickname => _nickname;
  int? get userId => _userId;

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

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void setStreet(String street) {
    _street = street;
    notifyListeners();
  }

  void setHouse(String house) {
    _house = house;
    notifyListeners();
  }

  void setDistrict(String district) {
    _district = district;
    notifyListeners();
  }

  void setNickname(String nickname) {
    _nickname = nickname;
    notifyListeners();
  }

  void setUserId(int id) {
    _userId = id;
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
        if (user['id'] != null) setUserId(user['id']);
        setStaffName(user['first_name'] ?? user['username'] ?? '');
        setEmail(user['email']);
        setUsername(user['username'] ?? '');
        setPhone(user['phone'] ?? '');
        setStreet(user['street'] ?? '');
        setHouse(user['house'] ?? '');
        setDistrict(user['district'] ?? '');
        setNickname(user['nickname'] ?? '');
      }
    }
  }

  Future<bool> updateProfileHistory({
    required int userId,
    required String username,
    required String email,
    required String phone,
    required String street,
    required String house,
    required String district,
    required String nickname,
  }) async {
    final data = {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone': phone,
      'street': street,
      'house': house,
      'district': district,
      'nickname': nickname,
    };
    final response = await ApiService.post(
      'accounts/history/',
      data,
      debug: true,
    );
    return response['success'] == true;
  }

  Future<bool> updateProfile({
    required String username,
    required String email,
    required String phone,
    required String street,
    required String house,
    required String district,
    required String nickname,
  }) async {
    return await AuthApiService.updateProfileHistory(
      username: username,
      email: email,
      phone: phone,
      street: street,
      house: house,
      district: district,
      nickname: nickname,
    );
  }

  Future<bool> addProfileEditHistoryRecord({
    required String fieldChanged,
    required String oldValue,
    required String newValue,
  }) async {
    final data = {
      'field_changed': fieldChanged,
      'old_value': oldValue,
      'new_value': newValue,
    };
    final response = await ApiService.post(
      'profile/history/',
      data,
      debug: true,
    );
    return response['success'] == true;
  }

  Future<void> updateProfileWithHistory({
    required Map<String, dynamic> oldProfile,
    required Map<String, dynamic> newProfile,
  }) async {
    for (final key in newProfile.keys) {
      if (oldProfile[key] != newProfile[key]) {
        await addProfileEditHistoryRecord(
          fieldChanged: key,
          oldValue: oldProfile[key]?.toString() ?? '',
          newValue: newProfile[key]?.toString() ?? '',
        );
      }
    }
  }

  void clear() {
    _staffName = null;
    _email = null;
    _username = null; // <-- Clear username
    _phone = null;
    _street = null;
    _house = null;
    _district = null;
    _nickname = null;
    _userId = null;
    notifyListeners();
  }
}
