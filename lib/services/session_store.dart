import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_models.dart';

class SessionStore {
  static const String _userKey = 'word_frontend_auth_user';
  static AuthUser? _currentUser;

  static Future<void> saveUser(AuthUser user) async {
    _currentUser = user;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<AuthUser?> restoreUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      _currentUser = AuthUser.fromJson(decoded);
      return _currentUser;
    }

    return null;
  }

  static Future<String?> readToken() async {
    final user = _currentUser ?? await restoreUser();
    return user?.token.isNotEmpty == true ? user!.token : null;
  }

  static Future<Map<String, String>> authorizationHeaders() async {
    final token = await readToken();
    if (token == null || token.isEmpty) {
      return const {};
    }

    return {'Authorization': 'Bearer $token'};
  }

  static Future<void> clear() async {
    _currentUser = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_userKey);
  }
}
