import 'profile_models.dart';

class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? displayName;
  final List<int> acceptedDocuments;
  final String platform;

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.acceptedDocuments,
    required this.platform,
    this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'acceptedDocuments': acceptedDocuments,
      'platform': platform,
      if (displayName != null && displayName!.trim().isNotEmpty)
        'displayName': displayName,
    };
  }
}

class RegistrationResult {
  final String email;
  final bool emailVerified;
  final UserProfile? user;

  const RegistrationResult({
    required this.email,
    required this.emailVerified,
    required this.user,
  });

  factory RegistrationResult.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString() ?? '';

    return RegistrationResult(
      email: json['email']?.toString() ?? '',
      emailVerified: json['emailVerified'] != false,
      user: token.isNotEmpty ? UserProfile.fromJson(json) : null,
    );
  }
}

// class UserProfile {
//   final String token;
//   final int id;
//   final String username;
//   final String email;
//   final String displayName;
//   final String avatarUrl;
//   final int totalXp;
//   final int level;
//   final int currentStreak;

//   const UserProfile({
//     required this.token,
//     required this.id,
//     required this.username,
//     required this.email,
//     required this.displayName,
//     required this.avatarUrl,
//     required this.totalXp,
//     required this.level,
//     required this.currentStreak,
//   });

//   factory UserProfile.fromJson(Map<String, dynamic> json) {
//     return UserProfile(
//       token: json['token']?.toString() ?? '',
//       id: _readInt(json['id']),
//       username: json['username']?.toString() ?? '',
//       email: json['email']?.toString() ?? '',
//       displayName: json['displayName']?.toString() ?? '',
//       avatarUrl: json['avatarUrl']?.toString() ?? '',
//       totalXp: _readInt(json['totalXp']),
//       level: _readInt(json['level']),
//       currentStreak: _readInt(json['currentStreak']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'token': token,
//       'id': id,
//       'username': username,
//       'email': email,
//       'displayName': displayName,
//       'avatarUrl': avatarUrl,
//       'totalXp': totalXp,
//       'level': level,
//       'currentStreak': currentStreak,
//     };
//   }

//   String get greetingName =>
//       displayName.trim().isNotEmpty ? displayName : username;
// }
