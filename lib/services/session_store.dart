import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_models.dart';

class SessionStore {
  static const String _userKey = 'word_auth_user';
  static const String _usernameKey = 'word_login_username';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _deviceIdKey = 'auth_device_id';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static UserProfile? _currentUser;

  static Future<void> saveUser(UserProfile user) async {
    final UserProfile profile;
    if (user.token.isNotEmpty && user.refreshToken.isNotEmpty) {
      await saveTokens(user.token, user.refreshToken);
      profile = user;
    } else {
      profile = user.copyWith(
        token: await readToken() ?? '',
        refreshToken: await readRefreshToken() ?? '',
      );
    }
    _currentUser = profile;
    final preferences = await SharedPreferences.getInstance();
    final persistedUser = profile.copyWith(avatarUrl: '');
    await preferences.setString(_userKey, jsonEncode(persistedUser.toJson()));
  }

  static Future<UserProfile?> restoreUser() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_userKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final user = UserProfile.fromJson(decoded).copyWith(avatarUrl: '');
      final accessToken = await readToken();
      final refreshToken = await readRefreshToken();
      _currentUser = user.copyWith(
        token: accessToken ?? '',
        refreshToken: refreshToken ?? '',
      );
      return _currentUser;
    }

    return null;
  }

  static Future<String?> readToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  static Future<String?> readRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw ArgumentError('Both authentication tokens are required.');
    }
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    _currentUser = _currentUser?.copyWith(
      token: accessToken,
      refreshToken: refreshToken,
    );
  }

  static Future<String> getOrCreateDeviceId() async {
    final existing = await _secureStorage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final random = Random.secure();
    final deviceId = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    await _secureStorage.write(key: _deviceIdKey, value: deviceId);
    return deviceId;
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
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
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

  static const String _onboardingKey = 'word_onboarding_complete';

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
    await preferences.remove('word_app_cache');
  }

  static Future<void> clearHistory() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('word_activity_history');
  }
}
