import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_models.dart';

class SessionStore {
  static const String _userKey = 'word_frontend_auth_user';
  static const String _usernameKey = 'word_frontend_login_username';
  static UserProfile? _currentUser;

  static Future<void> saveUser(UserProfile user) async {
    _currentUser = user;
    final preferences = await SharedPreferences.getInstance();
    final persistedUser = user.copyWith(avatarUrl: '');
    await preferences.setString(_userKey, jsonEncode(persistedUser.toJson()));
  }

  static Future<UserProfile?> restoreUser() async {
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
      _currentUser = UserProfile.fromJson(decoded).copyWith(avatarUrl: '');
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

  static Future<void> saveLoginUsername(String username) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_usernameKey, username);
  }

  static Future<String?> getLoginUsername() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_usernameKey);
  }

  static Future<void> clearLoginUsername() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_usernameKey);
  }

  static const String _onboardingKey = 'word_frontend_onboarding_complete';

  static Future<bool> hasSeenOnboarding() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_onboardingKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_onboardingKey, true);
  }

  // Lightweight helpers for UI quick actions. These keys are app-local
  // and no-op if not present.
  static Future<void> clearCache() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('word_frontend_app_cache');
  }

  static Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('word_frontend_activity_history');
  }
}
