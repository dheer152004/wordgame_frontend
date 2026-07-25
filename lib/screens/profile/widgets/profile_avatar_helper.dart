import '../../../../models/profile_models.dart';
import '../../../../services/backend_api.dart';

class ProfileAvatarHelper {
  static const String diceBearApiRoot = 'https://api.dicebear.com/9.x';
  static const List<String> diceBearAvatarStyles = <String>[
    'adventurer',
    'avataaars',
    'big-ears',
    'bottts',
    'fun-emoji',
    'identicon',
    'lorelei',
    'micah',
    'pixel-art',
    'shapes',
  ];

  static String avatarSeed(UserProfile? profile) {
    if (profile == null) {
      return 'guest';
    }

    final displayName = profile.displayName.trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final username = profile.username.trim();
    if (username.isNotEmpty) {
      return username;
    }

    return 'user-${profile.id}';
  }

  static String buildDiceBearAvatarUrl({
    required String style,
    required String seed,
  }) {
    final uri = Uri.parse(
      '$diceBearApiRoot/$style/png',
    ).replace(queryParameters: <String, String>{'seed': seed, 'size': '128'});
    return uri.toString();
  }

  static String? diceBearStyleFromUrl(String value) {
    if (value.trim().isEmpty || !value.contains('api.dicebear.com')) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.pathSegments.length < 3) {
      return null;
    }

    return uri.pathSegments[1];
  }

  static String resolveAvatarUrl(
    UserProfile? profile,
    UserProfile? currentUser,
  ) {
    final profileAvatar = normalizeLegacyAvatarUrl(
      profile?.avatarUrl.trim() ?? '',
      profile ?? currentUser,
      currentUser: currentUser,
    );

    if (profileAvatar.isNotEmpty) {
      final trimmed = profileAvatar;
      if (trimmed.startsWith('/')) {
        return '${BackendApi.instance.baseUrl}$trimmed';
      }
      if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
        return '${BackendApi.instance.baseUrl}/$trimmed';
      }
      return profileAvatar;
    }

    return '';
  }

  static UserProfile mergeAvatarPreference(
    UserProfile fetchedProfile,
    UserProfile? currentUser,
  ) {
    final normalizedFetchedAvatar = normalizeLegacyAvatarUrl(
      fetchedProfile.avatarUrl,
      fetchedProfile,
      currentUser: currentUser,
    );

    if (normalizedFetchedAvatar != fetchedProfile.avatarUrl) {
      return fetchedProfile.copyWith(avatarUrl: normalizedFetchedAvatar);
    }

    return fetchedProfile;
  }

  static bool isLegacyUiAvatarUrl(String value) {
    return value.contains('ui-avatars.com');
  }

  static String normalizeLegacyAvatarUrl(
    String value,
    UserProfile? sourceProfile, {
    required UserProfile? currentUser,
  }) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    if (isLegacyUiAvatarUrl(trimmed)) {
      return buildDiceBearAvatarUrl(
        style: 'adventurer',
        seed: avatarSeed(sourceProfile ?? currentUser),
      );
    }

    return trimmed;
  }
}
