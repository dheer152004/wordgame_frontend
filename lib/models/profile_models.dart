class UserProfile {
  final String token;
  final int id;
  final String username;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String location;
  final int totalXp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int xpToNextLevel;
  final double levelProgress;
  final int totalWordsSaved;
  final int totalQuizzesCompleted;
  final double averageQuizScore;
  final int wordsMastered;
  final DateTime? lastActive;
  final DateTime? createdAt;
  final String lastQuizDate;
  final List<String> recentBadges;

  const UserProfile({
    required this.token,
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.location,
    required this.totalXp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.xpToNextLevel,
    required this.levelProgress,
    required this.totalWordsSaved,
    required this.totalQuizzesCompleted,
    required this.averageQuizScore,
    required this.wordsMastered,
    required this.lastActive,
    required this.createdAt,
    required this.lastQuizDate,
    required this.recentBadges,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      token: json['token']?.toString() ?? '',
      id: _readInt(json['id']),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      totalXp: _readInt(json['totalXp']),
      level: _readInt(json['level']),
      currentStreak: _readInt(json['currentStreak']),
      longestStreak: _readInt(json['longestStreak']),
      xpToNextLevel: _readInt(json['xpToNextLevel']),
      levelProgress: _readDouble(json['levelProgress']),
      totalWordsSaved: _readInt(json['totalWordsSaved']),
      totalQuizzesCompleted: _readInt(json['totalQuizzesCompleted']),
      averageQuizScore: _readDouble(json['averageQuizScore']),
      wordsMastered: _readInt(json['wordsMastered']),
      lastActive: _readDateTime(json['lastActive']),
      createdAt: _readDateTime(json['createdAt']),
      lastQuizDate: json['lastQuizDate']?.toString() ?? '',
      recentBadges: _readStringList(json['recentBadges']),
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
      'bio': bio,
      'location': location,
      'totalXp': totalXp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'xpToNextLevel': xpToNextLevel,
      'levelProgress': levelProgress,
      'totalWordsSaved': totalWordsSaved,
      'totalQuizzesCompleted': totalQuizzesCompleted,
      'averageQuizScore': averageQuizScore,
      'wordsMastered': wordsMastered,
      'lastActive': _dateToJson(lastActive),
      'createdAt': _dateToJson(createdAt),
      'lastQuizDate': lastQuizDate,
      'recentBadges': recentBadges,
    };
  }

  UserProfile copyWith({
    String? token,
    int? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? location,
    int? totalXp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    int? xpToNextLevel,
    double? levelProgress,
    int? totalWordsSaved,
    int? totalQuizzesCompleted,
    double? averageQuizScore,
    int? wordsMastered,
    DateTime? lastActive,
    DateTime? createdAt,
    String? lastQuizDate,
    List<String>? recentBadges,
  }) {
    return UserProfile(
      token: token ?? this.token,
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      levelProgress: levelProgress ?? this.levelProgress,
      totalWordsSaved: totalWordsSaved ?? this.totalWordsSaved,
      totalQuizzesCompleted:
          totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      averageQuizScore: averageQuizScore ?? this.averageQuizScore,
      wordsMastered: wordsMastered ?? this.wordsMastered,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      recentBadges: recentBadges ?? this.recentBadges,
    );
  }

  String get greetingName =>
      displayName.trim().isNotEmpty ? displayName : username;
}

class UserConsent {
  final int id;
  final int legalDocumentId;
  final String legalDocumentTitle;
  final String legalDocumentType;
  final String status;
  final DateTime? acceptedAt;
  final String acceptedFrom;
  final DateTime? withdrawnAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserConsent({
    required this.id,
    required this.legalDocumentId,
    required this.legalDocumentTitle,
    required this.legalDocumentType,
    required this.status,
    required this.acceptedAt,
    required this.acceptedFrom,
    required this.withdrawnAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserConsent.fromJson(Map<String, dynamic> json) {
    return UserConsent(
      id: _readInt(json['id']),
      legalDocumentId: _readInt(json['legalDocumentId']),
      legalDocumentTitle:
          json['legalDocumentTitle']?.toString() ??
          json['documentTitle']?.toString() ??
          '',
      legalDocumentType: json['legalDocumentType']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      acceptedAt: _readFlexibleDateTime(json['acceptedAt']),
      acceptedFrom: json['acceptedFrom']?.toString() ?? '',
      withdrawnAt: _readFlexibleDateTime(json['withdrawnAt']),
      createdAt: _readFlexibleDateTime(json['createdAt']),
      updatedAt: _readFlexibleDateTime(json['updatedAt']),
    );
  }
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

double _readDouble(Object? value) {
  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}

DateTime? _readDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }

  return null;
}

DateTime? _readFlexibleDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }

  if (value is List && value.length >= 3) {
    final year = _readInt(value[0]);
    final month = _readInt(value[1]);
    final day = _readInt(value[2]);
    final hour = value.length > 3 ? _readInt(value[3]) : 0;
    final minute = value.length > 4 ? _readInt(value[4]) : 0;
    final second = value.length > 5 ? _readInt(value[5]) : 0;
    final nanosecond = value.length > 6 ? _readInt(value[6]) : 0;
    final microsecond = (nanosecond / 1000).floor();

    try {
      return DateTime(year, month, day, hour, minute, second, microsecond);
    } catch (_) {
      return null;
    }
  }

  return null;
}

List<String> _readStringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }

  return const [];
}

String? _dateToJson(DateTime? value) {
  return value?.toIso8601String();
}
