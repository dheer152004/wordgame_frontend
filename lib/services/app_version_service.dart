import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';

class AppUpdateNotice {
  const AppUpdateNotice({
    required this.latestVersion,
    required this.forceUpdate,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.storeUrl,
  });

  final String latestVersion;
  final bool forceUpdate;
  final String title;
  final String message;
  final String buttonText;
  final String storeUrl;
}

class AppVersionService {
  AppVersionService._();

  static final AppVersionService instance = AppVersionService._();
  final http.Client _client = http.Client();

  Future<AppUpdateNotice?> checkForUpdate() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return null;
    }

    try {
      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'IOS'
          : 'ANDROID';
      final packageInfo = await PackageInfo.fromPlatform();
      final uri = Uri.parse(
        '${AppConfig.backendApiBaseUrl}/api/v1/app/version',
      ).replace(queryParameters: {'platform': platform});
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final latestVersion = payload['latestVersion'] as String;
      final minimumVersion = payload['minimumVersion'] as String;
      final installedVersion = packageInfo.version;
      if (compareVersions(installedVersion, latestVersion) >= 0) return null;

      final forceUpdate =
          payload['forceUpdate'] == true ||
          compareVersions(installedVersion, minimumVersion) < 0;
      return AppUpdateNotice(
        latestVersion: latestVersion,
        forceUpdate: forceUpdate,
        title: payload['title'] as String,
        message: payload['message'] as String,
        buttonText: payload['buttonText'] as String,
        storeUrl: payload['storeUrl'] as String,
      );
    } catch (error) {
      debugPrint('Unable to check app version: $error');
      return null;
    }
  }

  Future<bool> isInstalledVersionAtLeast(String requiredVersion) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return false;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    return compareVersions(packageInfo.version, requiredVersion) >= 0;
  }

  static int compareVersions(String left, String right) {
    final leftParts = left.split('.').map((part) => int.tryParse(part) ?? 0);
    final rightParts = right.split('.').map((part) => int.tryParse(part) ?? 0);
    final leftVersion = leftParts.toList();
    final rightVersion = rightParts.toList();
    final length = leftVersion.length > rightVersion.length
        ? leftVersion.length
        : rightVersion.length;

    for (var index = 0; index < length; index++) {
      final leftPart = index < leftVersion.length ? leftVersion[index] : 0;
      final rightPart = index < rightVersion.length ? rightVersion[index] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }
    return 0;
  }
}
