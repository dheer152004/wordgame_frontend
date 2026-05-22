class ApiCategory {
  final int id;
  final String name;
  final int wordCount;

  const ApiCategory({
    required this.id,
    required this.name,
    required this.wordCount,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      wordCount: _readInt(json['wordCount']),
    );
  }
}

class ApiWord {
  final int id;
  final String word;
  final String meaning;
  final String memeImageUrl;
  final String categoryName;
  final List<String> examples;
  final String audioUrl;

  const ApiWord({
    required this.id,
    required this.word,
    required this.meaning,
    required this.memeImageUrl,
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
      memeImageUrl: json['memeImageUrl']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      examples: examples,
      audioUrl: json['audioUrl']?.toString() ?? '',
    );
  }

  String get primaryExample => examples.isNotEmpty ? examples.first : '';
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
