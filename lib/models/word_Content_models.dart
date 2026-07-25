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

class RelatedWordRef {
  final int wordId;
  final String word;

  const RelatedWordRef({required this.wordId, required this.word});

  factory RelatedWordRef.fromJson(Map<String, dynamic> json) {
    return RelatedWordRef(
      wordId: _readInt(json['wordId'] ?? json['id']),
      word: json['word']?.toString() ?? '',
    );
  }

  factory RelatedWordRef.fromDynamic(Object? value) {
    if (value is Map) {
      return RelatedWordRef.fromJson(Map<String, dynamic>.from(value));
    }

    return RelatedWordRef(wordId: _readInt(value), word: '');
  }
}

class AlsoAppearsInRef {
  final int categoryId;
  final int wordId;
  final String categoryName;

  const AlsoAppearsInRef({
    required this.categoryId,
    required this.wordId,
    required this.categoryName,
  });

  factory AlsoAppearsInRef.fromJson(Map<String, dynamic> json) {
    return AlsoAppearsInRef(
      categoryId: _readInt(json['categoryId']),
      wordId: _readInt(json['wordId']),
      categoryName: json['categoryName']?.toString() ?? '',
    );
  }
}

class ApiWord {
  final int id;
  final int? categoryId;
  final String word;
  final String meaning;
  final String wordImageUrl;
  final String categoryName;
  final List<String> examples;
  final String audioUrl;
  final List<String> images;
  final String description;
  final List<String> facts;
  final List<String> quizModes;
  final List<RelatedWordRef> relatedWords;
  final List<AlsoAppearsInRef> alsoAppearsIn;
  final int? displayOrder;
  final DateTime? created;
  final DateTime? updated;
  final Map<String, dynamic> sourceAndCredits;

  const ApiWord({
    required this.id,
    this.categoryId,
    required this.word,
    required this.meaning,
    required this.wordImageUrl,
    required this.categoryName,
    required this.examples,
    this.audioUrl = '',
    this.images = const [],
    this.description = '',
    this.facts = const [],
    this.quizModes = const [],
    this.relatedWords = const [],
    this.alsoAppearsIn = const [],
    this.displayOrder,
    this.created,
    this.updated,
    this.sourceAndCredits = const {},
  });

  factory ApiWord.fromJson(Map<String, dynamic> json) {
    final rawExamples = json['examples'];
    final examples = rawExamples is List
        ? rawExamples.map((entry) => entry.toString()).toList()
        : <String>[];

    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.map((entry) => entry.toString()).toList()
        : <String>[];

    final rawFacts = json['facts'];
    final facts = rawFacts is List
        ? rawFacts.map((entry) => entry.toString()).toList()
        : <String>[];

    final rawQuizModes = json['quizModes'];
    final quizModes = rawQuizModes is List
        ? rawQuizModes.map((entry) => entry.toString()).toList()
        : <String>[];

    final rawRelatedWords = json['relatedWordIds'];
    final relatedWords = rawRelatedWords is List
        ? rawRelatedWords.map(RelatedWordRef.fromDynamic).toList()
        : <RelatedWordRef>[];

    final rawAlsoAppearsIn = json['alsoAppearsIn'];
    final alsoAppearsIn = rawAlsoAppearsIn is List
        ? rawAlsoAppearsIn
              .whereType<Map>()
              .map(
                (entry) =>
                    AlsoAppearsInRef.fromJson(Map<String, dynamic>.from(entry)),
              )
              .toList()
        : <AlsoAppearsInRef>[];

    final sourceAndCreditsRaw = json['source&credits'];
    final sourceAndCredits = sourceAndCreditsRaw is Map
        ? Map<String, dynamic>.from(sourceAndCreditsRaw)
        : <String, dynamic>{};

    DateTime? parseDate(Object? value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return ApiWord(
      id: _readInt(json['id']),
      categoryId: _readNullableInt(json['categoryId']),
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      wordImageUrl: json['wordImageUrl']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      examples: examples,
      audioUrl: json['audioUrl']?.toString() ?? '',
      images: images,
      description: json['description']?.toString() ?? '',
      facts: facts,
      quizModes: quizModes,
      relatedWords: relatedWords,
      alsoAppearsIn: alsoAppearsIn,
      displayOrder: _readNullableInt(json['displayOrder']),
      created: parseDate(json['created']),
      updated: parseDate(json['updated']),
      sourceAndCredits: sourceAndCredits,
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

int? _readNullableInt(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value.trim());
  }

  return null;
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
