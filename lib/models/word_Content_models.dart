class ApiCategory {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final bool isActive;
  final int wordCount;

  const ApiCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.isActive,
    required this.wordCount,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: _readBool(json['isActive'], fallback: true),
      wordCount: _readInt(json['wordCount']),
    );
  }
}

class ApiWord {
  final int id;
  final String word;
  final String meaning;
  final String wordImageUrl;
  final String categoryName;
  final List<String> examples;
  final String audioUrl;

  const ApiWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.wordImageUrl,
    required this.categoryName,
    required this.examples,
    this.audioUrl = '',
  });

  factory ApiWord.fromJson(Map<String, dynamic> json) {
    final rawExamples = json['examples'];
    final examples = rawExamples is List
        ? rawExamples.map((entry) => entry.toString()).toList()
        : <String>[];

    return ApiWord(
      id: _readInt(json['id']),
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      wordImageUrl: json['wordImageUrl']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      examples: examples,
      audioUrl: json['audioUrl']?.toString() ?? '',
    );
  }

  String get primaryExample => examples.isNotEmpty ? examples.first : '';
}

class SavedWord {
  final int savedWordId;
  final int wordId;
  final String word;
  final String meaning;
  final String wordImageUrl;
  final String categoryName;
  final String notes;

  const SavedWord({
    required this.savedWordId,
    required this.wordId,
    required this.word,
    required this.meaning,
    required this.wordImageUrl,
    required this.categoryName,
    required this.notes,
  });

  factory SavedWord.fromJson(Map<String, dynamic> json) {
    return SavedWord(
      savedWordId: _readInt(json['savedWordId']),
      wordId: _readInt(json['wordId']),
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      wordImageUrl: json['wordImageUrl']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }

  ApiWord toApiWord() {
    return ApiWord(
      id: wordId,
      word: word,
      meaning: meaning,
      wordImageUrl: wordImageUrl,
      categoryName: categoryName,
      examples: const [],
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

bool _readBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
  }

  if (value is num) {
    return value != 0;
  }

  return fallback;
}
