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

  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      if (displayName != null && displayName!.trim().isNotEmpty)
        'displayName': displayName,
    };
  }
}

class AuthUser {
  final String token;
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String avatarUrl;
  final int totalXp;
  final int level;
  final int currentStreak;

  const AuthUser({
    required this.token,
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.totalXp,
    required this.level,
    required this.currentStreak,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      token: json['token']?.toString() ?? '',
      id: _readInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      totalXp: _readInt(json['totalXp']),
      level: _readInt(json['level']),
      currentStreak: _readInt(json['currentStreak']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'totalXp': totalXp,
      'level': level,
      'currentStreak': currentStreak,
    };
  }

  String get greetingName =>
      displayName.trim().isNotEmpty ? displayName : username;
}

int _readInt(Object? value) {
  if (value is int) {
    return value;
  }

  if (value is String) {
    return int.tryParse(value) ?? 0;
  }

  if (value is num) {
    return value.toInt();
  }

  return 0;
}
