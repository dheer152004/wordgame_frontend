import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/auth_models.dart';
import '../models/content_models.dart';
import '../models/quiz_models.dart';
import 'session_store.dart';

class BackendException implements Exception {
  final String message;

  const BackendException(this.message);

  @override
  String toString() => message;
}

class BackendApi {
  BackendApi._();

  static final BackendApi instance = BackendApi._();

  String get baseUrl => AppConfig.backendApiBaseUrl;
  static const Duration _cacheTtl = Duration(hours: 6);
  static const String _categoriesCacheKey = 'word_frontend_categories_cache';
  static const String _wordDetailCachePrefix = 'word_frontend_word_detail_';
  static const String _categoryWordsCachePrefix =
      'word_frontend_category_words_';

  final http.Client _client = http.Client();
  List<ApiCategory>? _cachedCategories;
  final Map<String, List<ApiWord>> _cachedWordsByCategory = {};
  final Map<int, ApiWord> _cachedWordById = {};

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _jsonHeaders => const {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _headers({bool authenticated = false}) async {
    if (!authenticated) {
      return _jsonHeaders;
    }

    final authHeaders = await SessionStore.authorizationHeaders();
    return {..._jsonHeaders, ...authHeaders};
  }

  Future<AuthUser> login(LoginRequest request) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      return AuthUser.fromJson(payload);
    }

    throw const BackendException('Unexpected login response from server.');
  }

  Future<AuthUser?> register(RegisterRequest request) async {
    final response = await _client.post(
      _uri('/api/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic> && payload.containsKey('token')) {
      return AuthUser.fromJson(payload);
    }

    return null;
  }

  Future<List<ApiCategory>> fetchCategories({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _readCachedList<ApiCategory>(
        _categoriesCacheKey,
        (json) => ApiCategory.fromJson(json),
        memoryCache: _cachedCategories,
      );
      if (cached != null) {
        _cachedCategories = cached;
        return cached;
      }
    }

    final response = await _client.get(
      _uri('/api/categories'),
      headers: await _headers(authenticated: true),
    );
    final payload = _decodeResponse(response);
    final items = _asList(payload);

    final categories = items
        .whereType<Map>()
        .map((entry) => ApiCategory.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    _cachedCategories = categories;
    await _writeCachedList(
      _categoriesCacheKey,
      categories.map((item) => itemToJson(item)).toList(),
    );
    return categories;
  }

  Future<List<ApiWord>> fetchWordsByCategory(
    String categoryName, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKeyForCategory(categoryName);
    if (!forceRefresh) {
      final cached = _cachedWordsByCategory[cacheKey];
      if (cached != null) {
        return cached;
      }

      final persisted = await _readCachedList<ApiWord>(
        cacheKey,
        (json) => ApiWord.fromJson(json),
      );
      if (persisted != null) {
        _cachedWordsByCategory[cacheKey] = persisted;
        return persisted;
      }
    }

    final response = await _client.get(
      _uri('/api/words/category/${Uri.encodeComponent(categoryName)}'),
      headers: await _headers(authenticated: true),
    );
    final payload = _decodeResponse(response);
    final items = _asWordList(payload);

    final words = items
        .whereType<Map>()
        .map((entry) => ApiWord.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    _cachedWordsByCategory[cacheKey] = words;
    await _writeCachedList(
      cacheKey,
      words.map((item) => itemToJson(item)).toList(),
    );
    return words;
  }

  Future<ApiWord> fetchWordById(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final memoryCached = _cachedWordById[id];
      if (memoryCached != null) {
        return memoryCached;
      }

      final persisted = await _readCachedObject(
        _wordDetailCachePrefix + id.toString(),
        (json) => ApiWord.fromJson(json),
      );
      if (persisted != null) {
        _cachedWordById[id] = persisted;
        return persisted;
      }
    }

    final response = await _client.get(
      _uri('/api/words/$id'),
      headers: await _headers(authenticated: true),
    );
    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      final word = ApiWord.fromJson(payload);
      _cachedWordById[id] = word;
      await _writeCachedObject(
        _wordDetailCachePrefix + id.toString(),
        itemToJson(word),
      );
      return word;
    }

    throw const BackendException('Unexpected word response from server.');
  }

  Future<String> hello() async {
    final response = await _client.get(
      _uri('/api/test/hello'),
      headers: await _headers(authenticated: true),
    );
    final payload = _decodeResponse(response);
    if (payload is String) {
      return payload;
    }

    return payload.toString();
  }

  Future<List<QuizQuestion>> fetchQuizToday({bool forceRefresh = false}) async {
    final response = await _client.get(
      _uri('/api/quiz/today'),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    return _asList(payload)
        .whereType<Map>()
        .map((entry) => QuizQuestion.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<dynamic> fetchQuizTodayAvailability() async {
    final response = await _client.get(
      _uri('/api/quiz/today/available'),
      headers: await _headers(authenticated: true),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> fetchQuizStatus() async {
    final response = await _client.get(
      _uri('/api/quiz/status'),
      headers: await _headers(authenticated: true),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> fetchQuizStats() async {
    final response = await _client.get(
      _uri('/api/quiz/stats'),
      headers: await _headers(authenticated: true),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> fetchQuizHistory() async {
    final response = await _client.get(
      _uri('/api/quiz/history'),
      headers: await _headers(authenticated: true),
    );
    return _decodeResponse(response);
  }

  Future<QuizSubmissionResult> submitQuizAnswers(
    List<QuizAnswerSubmission> answers,
  ) async {
    final response = await _client.post(
      _uri('/api/quiz/submit'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({
        'answers': answers.map((answer) => answer.toJson()).toList(),
      }),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      return QuizSubmissionResult.fromJson(payload);
    }

    throw const BackendException('Unexpected quiz submission response.');
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage =
          'Request failed with status ${response.statusCode}.';

      // Try to parse JSON error response
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('message')) {
            errorMessage = decoded['message'];
          } else {
            errorMessage = response.body;
          }
        } catch (_) {
          errorMessage = response.body;
        }
      }

      throw BackendException(errorMessage);
    }

    if (response.body.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      for (final key in ['data', 'result', 'content', 'payload']) {
        final nested = decoded[key];
        if (nested != null) {
          return nested;
        }
      }
    }

    return decoded;
  }

  List<dynamic> _asList(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      for (final key in ['data', 'items', 'content', 'result']) {
        final nested = payload[key];
        if (nested is List) {
          return nested;
        }
      }
    }

    return const [];
  }

  List<dynamic> _asWordList(dynamic payload) {
    final list = _asList(payload);
    if (list.isNotEmpty) {
      return list;
    }

    if (payload is Map<String, dynamic>) {
      final nestedWords = payload['words'];
      if (nestedWords is List) {
        return nestedWords;
      }

      final nestedData = payload['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedWordsFromData = nestedData['words'];
        if (nestedWordsFromData is List) {
          return nestedWordsFromData;
        }
      }
    }

    return const [];
  }

  String _cacheKeyForCategory(String categoryName) {
    return '$_categoryWordsCachePrefix${categoryName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
  }

  Map<String, dynamic> itemToJson(Object item) {
    if (item is ApiCategory) {
      return {'id': item.id, 'name': item.name, 'wordCount': item.wordCount};
    }

    if (item is ApiWord) {
      return {
        'id': item.id,
        'word': item.word,
        'meaning': item.meaning,
        'memeImageUrl': item.memeImageUrl,
        'categoryName': item.categoryName,
        'examples': item.examples,
      };
    }

    throw ArgumentError('Unsupported cache item type: ${item.runtimeType}');
  }

  Future<List<T>?> _readCachedList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson, {
    List<T>? memoryCache,
  }) async {
    if (memoryCache != null && memoryCache.isNotEmpty) {
      return memoryCache;
    }

    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final timestamp = _readTimestamp(decoded['cachedAt']);
    if (timestamp == null || DateTime.now().difference(timestamp) > _cacheTtl) {
      return null;
    }

    final items = decoded['items'];
    if (items is! List) {
      return null;
    }

    return items
        .whereType<Map>()
        .map((entry) => fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<T?> _readCachedObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final timestamp = _readTimestamp(decoded['cachedAt']);
    if (timestamp == null || DateTime.now().difference(timestamp) > _cacheTtl) {
      return null;
    }

    final item = decoded['item'];
    if (item is Map<String, dynamic>) {
      return fromJson(item);
    }

    return null;
  }

  Future<void> _writeCachedList(
    String key,
    List<Map<String, dynamic>> items,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode({
        'cachedAt': DateTime.now().toIso8601String(),
        'items': items,
      }),
    );
  }

  Future<void> _writeCachedObject(String key, Map<String, dynamic> item) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode({'cachedAt': DateTime.now().toIso8601String(), 'item': item}),
    );
  }

  DateTime? _readTimestamp(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
