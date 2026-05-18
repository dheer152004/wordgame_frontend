class QuizQuestion {
  final int questionId;
  final int wordId;
  final String word;
  final List<String> options;
  final int points;

  const QuizQuestion({
    required this.questionId,
    required this.wordId,
    required this.word,
    required this.options,
    required this.points,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = rawOptions is List
        ? rawOptions.map((entry) => entry.toString()).toList()
        : <String>[];

    return QuizQuestion(
      questionId: _readInt(json['questionId']),
      wordId: _readInt(json['wordId']),
      word: json['word']?.toString() ?? '',
      options: options,
      points: _readInt(json['points']),
    );
  }
}

class QuizAnswerSubmission {
  final int questionId;
  final String selectedOption;
  final int timeTakenMs;

  const QuizAnswerSubmission({
    required this.questionId,
    required this.selectedOption,
    required this.timeTakenMs,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOption': selectedOption,
      'timeTakenMs': timeTakenMs,
    };
  }
}

class QuizSubmissionDetail {
  final int questionId;
  final String word;
  final bool isCorrect;
  final String correctAnswer;
  final String yourAnswer;
  final String explanation;
  final int pointsEarned;

  const QuizSubmissionDetail({
    required this.questionId,
    required this.word,
    required this.isCorrect,
    required this.correctAnswer,
    required this.yourAnswer,
    required this.explanation,
    required this.pointsEarned,
  });

  factory QuizSubmissionDetail.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionDetail(
      questionId: _readInt(json['questionId']),
      word: json['word']?.toString() ?? '',
      isCorrect: _readBool(json['isCorrect']),
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      yourAnswer: json['yourAnswer']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      pointsEarned: _readInt(json['pointsEarned']),
    );
  }
}

class QuizSubmissionResult {
  final int score;
  final int totalPossible;
  final int percentage;
  final int xpEarned;
  final int newTotalXp;
  final int newLevel;
  final int currentStreak;
  final String message;
  final List<QuizSubmissionDetail> details;

  const QuizSubmissionResult({
    required this.score,
    required this.totalPossible,
    required this.percentage,
    required this.xpEarned,
    required this.newTotalXp,
    required this.newLevel,
    required this.currentStreak,
    required this.message,
    required this.details,
  });

  factory QuizSubmissionResult.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['details'];
    final details = rawDetails is List
        ? rawDetails
              .whereType<Map>()
              .map(
                (entry) => QuizSubmissionDetail.fromJson(
                  Map<String, dynamic>.from(entry),
                ),
              )
              .toList()
        : <QuizSubmissionDetail>[];

    return QuizSubmissionResult(
      score: _readInt(json['score']),
      totalPossible: _readInt(json['totalPossible']),
      percentage: _readInt(json['percentage']),
      xpEarned: _readInt(json['xpEarned']),
      newTotalXp: _readInt(json['newTotalXp']),
      newLevel: _readInt(json['newLevel']),
      currentStreak: _readInt(json['currentStreak']),
      message: json['message']?.toString() ?? '',
      details: details,
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

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }

  if (value is String) {
    return value.toLowerCase() == 'true';
  }

  if (value is num) {
    return value != 0;
  }

  return false;
}
