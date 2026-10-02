import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/profile_models.dart';
import 'session_store.dart';

enum SessionRefreshResult { refreshed, invalid, unavailable }

class AuthSessionManager {
  AuthSessionManager._();

  static final AuthSessionManager instance = AuthSessionManager._();
  static final ValueNotifier<int> sessionExpired = ValueNotifier<int>(0);

  final http.Client _refreshClient = http.Client();
  Future<SessionRefreshResult>? _refreshInFlight;

  Future<UserProfile?> restoreSession() async {
    final user = await SessionStore.restoreUser();
    final refreshToken = await SessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      if (user != null) await SessionStore.clear();
      return null;
    }

    final accessToken = await SessionStore.readToken() ?? '';
    final result = await _refreshOnce(notifyOnInvalid: false);
    if (result == SessionRefreshResult.refreshed) {
      if (user != null) return SessionStore.restoreUser();
      return _fetchProfile();
    }
    if (result == SessionRefreshResult.invalid) return null;
    return user?.copyWith(token: accessToken, refreshToken: refreshToken);
  }

  Future<SessionRefreshResult> refreshAfterUnauthorized(
    String failedAccessToken,
  ) async {
    final latestToken = await SessionStore.readToken();
    if (latestToken != null && latestToken != failedAccessToken) {
      return SessionRefreshResult.refreshed;
    }
    return _refreshOnce(notifyOnInvalid: true);
  }

  Future<SessionRefreshResult> _refreshOnce({
    required bool notifyOnInvalid,
  }) async {
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) return activeRefresh;

    final operation = _refreshFromStorage(notifyOnInvalid: notifyOnInvalid);
    _refreshInFlight = operation;
    try {
      return await operation;
    } finally {
      if (identical(_refreshInFlight, operation)) _refreshInFlight = null;
    }
  }

  Future<SessionRefreshResult> _refreshFromStorage({
    required bool notifyOnInvalid,
  }) async {
    final refreshToken = await SessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession(notify: notifyOnInvalid);
      return SessionRefreshResult.invalid;
    }

    try {
      final response = await _refreshClient
          .post(
            Uri.parse('${AppConfig.backendApiBaseUrl}/api/auth/refresh'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _expireSession(notify: notifyOnInvalid);
        return SessionRefreshResult.invalid;
      }
      if (response.statusCode != 200) return SessionRefreshResult.unavailable;

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = payload['token'] as String?;
      final nextRefreshToken = payload['refreshToken'] as String?;
      if (accessToken == null ||
          accessToken.isEmpty ||
          nextRefreshToken == null ||
          nextRefreshToken.isEmpty) {
        await _expireSession(notify: notifyOnInvalid);
        return SessionRefreshResult.invalid;
      }

      await SessionStore.saveTokens(accessToken, nextRefreshToken);
      return SessionRefreshResult.refreshed;
    } catch (_) {
      return SessionRefreshResult.unavailable;
    }
  }

  Future<void> _expireSession({required bool notify}) async {
    await SessionStore.clear();
    if (notify) sessionExpired.value++;
  }

  Future<UserProfile?> _fetchProfile() async {
    final accessToken = await SessionStore.readToken();
    if (accessToken == null || accessToken.isEmpty) return null;

    try {
      final response = await _refreshClient
          .get(
            Uri.parse('${AppConfig.backendApiBaseUrl}/api/user/profile'),
            headers: {'Authorization': 'Bearer $accessToken'},
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _expireSession(notify: false);
        return null;
      }
      if (response.statusCode != 200) return null;

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final user = UserProfile.fromJson(payload);
      await SessionStore.saveUser(user);
      return SessionStore.restoreUser();
    } catch (_) {
      return null;
    }
  }
}
