/// Model representing a word category from the backend API
/// Contains metadata about a category like name, image, and word count
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

/// Reference model for words related to the main word
/// Used to link words that have semantic or contextual relationships
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

/// Reference model for categories where a word also appears
/// Tracks cross-category word presence for multi-category words
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

/// Main word model containing all word data from backend API
/// Includes word metadata, examples, images, and relationships to other words
/// Supports multiple word types: ACRONYM, NOUN, VERB, ADJECTIVE, etc.
class ApiWord {
  final int id; // Unique word identifier
  final int? categoryId; // Category the word belongs to
  final String word; // The word itself
  final String wordType; // Type: ACRONYM, NOUN, VERB, etc.
  final String
  expandedForm; // Expansion for acronyms (e.g., MOU → Memorandum of Understanding)
  final String partOfSpeech; // Grammatical role: NOUN, VERB, ADJECTIVE, etc.
  final String meaning; // Primary definition
  final String wordImageUrl; // Main image URL
  final String categoryName; // Category name
  final List<String> examples; // Usage examples
  final String audioUrl; // Audio pronunciation URL
  final List<String> images; // Multiple images for visual learning
  final String description; // Detailed description
  final List<String> facts; // Interesting facts about the word
  final List<String> quizModes; // Available quiz types: IMAGE, TEXT, etc.
  final List<RelatedWordRef> relatedWords; // Semantically related words
  final List<AlsoAppearsInRef>
  alsoAppearsIn; // Other categories containing this word
  final int? displayOrder; // Order for sorting within category
  final DateTime? created; // Creation timestamp
  final DateTime? updated; // Last update timestamp
  final Map<String, dynamic>
  sourceAndCredits; // Attribution info and source details

  const ApiWord({
    required this.id,
    this.categoryId,
    required this.word,
    this.wordType = '',
    this.expandedForm = '',
    this.partOfSpeech = '',
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

  /// Parses JSON response from backend API into ApiWord object
  /// Safely handles type conversions and null values with fallbacks
  factory ApiWord.fromJson(Map<String, dynamic> json) {
    // Parse examples list, ensuring all entries are strings
    final rawExamples = json['examples'];
    final examples = rawExamples is List
        ? rawExamples.map((entry) => entry.toString()).toList()
        : <String>[];

    // Parse images list with fallback to empty list
    final rawImages = json['images'];
    final images = rawImages is List
        ? rawImages.map((entry) => entry.toString()).toList()
        : <String>[];

    // Parse facts/learning points
    final rawFacts = json['facts'];
    final facts = rawFacts is List
        ? rawFacts.map((entry) => entry.toString()).toList()
        : <String>[];

    // Parse available quiz modes
    final rawQuizModes = json['quizModes'];
    final quizModes = rawQuizModes is List
        ? rawQuizModes.map((entry) => entry.toString()).toList()
        : <String>[];

    // Parse related words with flexible ID field handling
    final rawRelatedWords = json['relatedWordIds'];
    final relatedWords = rawRelatedWords is List
        ? rawRelatedWords.map(RelatedWordRef.fromDynamic).toList()
        : <RelatedWordRef>[];

    // Parse categories where word also appears
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

    // Parse source and attribution information
    final sourceAndCreditsRaw = json['source&credits'];
    final sourceAndCredits = sourceAndCreditsRaw is Map
        ? Map<String, dynamic>.from(sourceAndCreditsRaw)
        : <String, dynamic>{};

    /// Helper to safely parse ISO datetime strings
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
      wordType: json['wordType']?.toString() ?? '',
      expandedForm: json['expandedForm']?.toString() ?? '',
      partOfSpeech: json['partOfSpeech']?.toString() ?? '',
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

  /// Returns the first example if available, empty string otherwise
  String get primaryExample => examples.isNotEmpty ? examples.first : '';
}

/// Model for user-saved words with personal notes
/// Represents a word that a user has bookmarked and annotated
class SavedWord {
  final int savedWordId; // Unique saved word record ID
  final int wordId; // Reference to original ApiWord
  final String word; // The word text
  final String meaning; // Word definition
  final String wordImageUrl; // Associated image
  final String categoryName; // Category name
  final String notes; // User's personal notes

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

  /// Converts SavedWord to ApiWord for displaying in word detail view
  /// Note: Returns minimal ApiWord with only essential fields
  ApiWord toApiWord() {
    return ApiWord(
      id: wordId,
      word: word,
      meaning: meaning,
      wordImageUrl: wordImageUrl,
      categoryName: categoryName,
      examples: const [],
      wordType: '',
      expandedForm: '',
      partOfSpeech: '',
    );
  }
}

/// Safely converts various types to integer
/// Handles int, String, and num types with fallback to 0
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

/// Safely converts various types to nullable integer
/// Handles int, String, and num types, returns null if conversion fails
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

/// Safely converts various types to boolean
/// Handles bool, String ('true'/'false'), and numeric types
/// Returns fallback value if conversion cannot be determined
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
