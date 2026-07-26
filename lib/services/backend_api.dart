import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/auth_models.dart';
import '../models/profile_models.dart';
import '../models/word_Content_models.dart';
import '../models/quiz_models.dart';
import 'session_store.dart';

class BackendException implements Exception {
  final String message;

  const BackendException(this.message);

  @override
  String toString() => message;
}

class RandomWordsPage {
  final List<ApiWord> words;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final bool hasMore;

  const RandomWordsPage({
    required this.words,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.hasMore,
  });
}

class BackendApi {
  BackendApi._();

  static final BackendApi instance = BackendApi._();

  String get baseUrl => AppConfig.backendApiBaseUrl;
  static const Duration _cacheTtl = Duration(hours: 6);
  static const String _categoriesCacheKey = 'word_frontend_categories_cache';
  static const String _wordDetailCachePrefix = 'word_frontend_word_detail_v2_';
  static const String _ipLocationLookupBestEffortUrl = 'https://ipinfo.io/json';
  static const String _ipLocationLookupPrimaryUrl = 'https://ipwho.is/';
  static const String _ipLocationLookupFallbackUrl = 'https://ipapi.co/json/';

  final http.Client _client = http.Client();
  List<ApiCategory>? _cachedCategories;
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

  Future<UserProfile> login(LoginRequest request) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      return UserProfile.fromJson(payload);
    }

    throw const BackendException('Unexpected login response from server.');
  }

  Future<UserProfile?> register(RegisterRequest request) async {
    final response = await _client.post(
      _uri('/api/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode(request.toJson()),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic> && payload.containsKey('token')) {
      return UserProfile.fromJson(payload);
    }

    return null;
  }

  Future<UserProfile> fetchUserProfile() async {
    final response = await _client.get(
      _uri('/api/user/profile'),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      return UserProfile.fromJson(payload);
    }

    throw const BackendException('Unexpected profile response from server.');
  }

  Future<List<UserConsent>> fetchUserConsents() async {
    final response = await _client.get(
      _uri('/api/users/me/consents'),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    final items = payload is Map<String, dynamic> && payload['consents'] is List
        ? List<dynamic>.from(payload['consents'] as List)
        : _asList(payload);

    return items
        .whereType<Map>()
        .map((entry) => UserConsent.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<UserProfile> updateUserProfile({
    required String displayName,
    required String avatarUrl,
    required String bio,
    required String location,
  }) async {
    final response = await _client.put(
      _uri('/api/user/profile'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({
        'displayName': displayName,
        'bio': bio,
        'location': location,
      }),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      return UserProfile.fromJson(payload);
    }

    throw const BackendException('Unexpected profile update response.');
  }

  Future<UserProfile> updateUserProfileFromIp({
    required String displayName,
    required String avatarUrl,
    required String bio,
  }) async {
    final location = await fetchLocationFromIp();
    return updateUserProfile(
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      location: location,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _client.put(
      _uri('/api/user/profile/change-password'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    _decodeResponse(response);
  }

  Future<void> saveWord({required int wordId, String notes = ''}) async {
    final response = await _client.post(
      _uri('/api/user/saved-words'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({'wordId': wordId, 'notes': notes}),
    );

    _decodeResponse(response);
  }

  Future<void> removeSavedWord(int wordId) async {
    final response = await _client.delete(
      _uri('/api/user/saved-words/$wordId'),
      headers: await _headers(authenticated: true),
    );

    _decodeResponse(response);
  }

  Future<UserProfile> uploadUserAvatarFromUrl(String avatarUrl) async {
    final trimmedAvatarUrl = avatarUrl.trim();
    if (trimmedAvatarUrl.isEmpty) {
      throw const BackendException('Avatar URL is required.');
    }

    final downloadResponse = await _client.get(Uri.parse(trimmedAvatarUrl));
    if (downloadResponse.statusCode < 200 ||
        downloadResponse.statusCode >= 300) {
      throw BackendException(
        'Unable to read avatar image (${downloadResponse.statusCode}).',
      );
    }

    final contentType = _avatarContentType(
      downloadResponse.headers['content-type'],
      trimmedAvatarUrl,
    );
    if (contentType == null) {
      throw const BackendException('Only image files are allowed.');
    }

    final request = http.MultipartRequest(
      'POST',
      _uri('/api/user/profile/avatar'),
    );
    final headers = await _headers(authenticated: true);
    headers.remove('Content-Type');
    request.headers.addAll(headers);
    request.files.add(
      http.MultipartFile.fromBytes(
        'avatar',
        downloadResponse.bodyBytes,
        filename: 'avatar.png',
        contentType: contentType,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      return UserProfile.fromJson(payload);
    }

    throw const BackendException('Unexpected avatar upload response.');
  }

  /// Fetch avatar bytes using authenticated headers when available.
  Future<Uint8List> fetchAvatarBytes(String avatarUrl) async {
    final trimmed = avatarUrl.trim();
    if (trimmed.isEmpty) {
      throw const BackendException('Avatar URL is empty.');
    }

    Uri uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      uri = _uri(trimmed);
    }

    // Use auth headers when available.
    final headers = await _headers(authenticated: true);
    // Remove content-type to allow image responses
    headers.remove('Content-Type');

    final response = await _client.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendException(
        'Unable to fetch avatar (${response.statusCode}).',
      );
    }

    return response.bodyBytes;
  }

  /// Returns the count of saved words for the authenticated user.
  Future<int> fetchSavedWordsCount() async {
    final response = await _client.get(
      _uri('/api/user/saved-words/count'),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    if (payload is Map<String, dynamic>) {
      final value = payload['count'] ?? payload['total'] ?? payload['saved'];
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
    }

    if (payload is int) {
      return payload;
    }

    if (payload is String) {
      return int.tryParse(payload) ?? 0;
    }

    throw const BackendException('Unexpected saved-words count response.');
  }

  Future<List<SavedWord>> fetchSavedWords() async {
    final response = await _client.get(
      _uri('/api/user/saved-words'),
      headers: await _headers(authenticated: true),
    );

    final decoded = _decodeResponseObject(response);
    final content = _asList(decoded);

    return content
        .whereType<Map>()
        .map((entry) => SavedWord.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  MediaType? _avatarContentType(String? contentTypeHeader, String avatarUrl) {
    final normalizedHeader = contentTypeHeader?.split(';').first.trim();
    if (normalizedHeader != null && normalizedHeader.startsWith('image/')) {
      return MediaType.parse(normalizedHeader);
    }

    final uri = Uri.tryParse(avatarUrl);
    final path = uri?.path.toLowerCase() ?? avatarUrl.toLowerCase();
    if (path.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
      return MediaType('image', 'jpeg');
    }
    if (path.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (path.endsWith('.gif')) {
      return MediaType('image', 'gif');
    }
    if (path.endsWith('.svg')) {
      return MediaType('image', 'svg+xml');
    }

    return null;
  }

  Future<String> fetchLocationFromIp() async {
    final providers = <String>[
      _ipLocationLookupBestEffortUrl,
      _ipLocationLookupPrimaryUrl,
      _ipLocationLookupFallbackUrl,
    ];

    Map<String, dynamic>? decoded;
    for (final provider in providers) {
      try {
        decoded = await _fetchIpGeoJson(provider);
        break;
      } catch (_) {
        continue;
      }
    }

    if (decoded == null) {
      throw const BackendException('Unable to determine location from IP.');
    }

    final detectedIp =
        decoded['ip']?.toString() ??
        decoded['query']?.toString() ??
        decoded['ip_address']?.toString() ??
        '';

    final location = _formatIpLocation(decoded);
    if (location.isEmpty) {
      throw const BackendException('Location not available from IP lookup.');
    }

    if (detectedIp.isNotEmpty) {
      debugPrint('Detected public IP: $detectedIp');
    }
    debugPrint('Resolved location from IP: $location');

    return location;
  }

  Future<Map<String, dynamic>> _fetchIpGeoJson(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendException(
        'Unable to determine location from IP (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const BackendException('Unexpected IP location response.');
    }

    final success = decoded['success'];
    if (success is bool && !success) {
      throw const BackendException('IP geolocation provider returned failure.');
    }

    return decoded;
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

  Future<RandomWordsPage> fetchWordsByCategory(
    String categoryName, {
    int page = 0,
    int size = 10,
    bool forceRefresh = false,
  }) async {
    final response = await _client.get(
      _uri(
        '/api/words/category/${Uri.encodeComponent(categoryName)}?page=$page&size=$size',
      ),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    final items = _asWordList(payload);
    final payloadMap = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};

    final words = items
        .whereType<Map>()
        .map((entry) => ApiWord.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    final currentPage = _readIntValue(payloadMap['currentPage'], page);
    final totalPages = _readIntValue(payloadMap['totalPages'], currentPage + 1);
    final pageSize = _readIntValue(payloadMap['pageSize'], size);
    final hasMore = _readBoolValue(
      payloadMap['hasMore'],
      fallback: currentPage + 1 < totalPages,
    );

    return RandomWordsPage(
      words: words,
      currentPage: currentPage,
      totalPages: totalPages,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  Future<RandomWordsPage> fetchWordsByCategoryId(
    int categoryId, {
    int page = 0,
    int size = 10,
    bool forceRefresh = false,
  }) async {
    final response = await _client.get(
      _uri('/api/words/category/$categoryId?page=$page&size=$size'),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    final items = _asWordList(payload);
    final payloadMap = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};

    final words = items
        .whereType<Map>()
        .map((entry) => ApiWord.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    final currentPage = _readIntValue(payloadMap['currentPage'], page);
    final totalPages = _readIntValue(payloadMap['totalPages'], currentPage + 1);
    final pageSize = _readIntValue(payloadMap['pageSize'], size);
    final hasMore = _readBoolValue(
      payloadMap['hasMore'],
      fallback: currentPage + 1 < totalPages,
    );

    return RandomWordsPage(
      words: words,
      currentPage: currentPage,
      totalPages: totalPages,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  Future<RandomWordsPage> fetchRandomWords({
    int page = 0,
    int size = 10,
  }) async {
    final response = await _client.get(
      _uri('/api/words/random?page=$page&size=$size'),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    final items = _asWordList(payload);
    final payloadMap = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};

    final words = items
        .whereType<Map>()
        .map((entry) => ApiWord.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    final currentPage = _readIntValue(payloadMap['currentPage'], page);
    final totalPages = _readIntValue(payloadMap['totalPages'], currentPage + 1);
    final pageSize = _readIntValue(payloadMap['pageSize'], size);
    final hasMore = _readBoolValue(
      payloadMap['hasMore'],
      fallback: currentPage + 1 < totalPages,
    );

    return RandomWordsPage(
      words: words,
      currentPage: currentPage,
      totalPages: totalPages,
      pageSize: pageSize,
      hasMore: hasMore,
    );
  }

  Future<RandomWordsPage> searchWords(
    String query, {
    int page = 0,
    int size = 10,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const RandomWordsPage(
        words: [],
        currentPage: 0,
        totalPages: 0,
        pageSize: 0,
        hasMore: false,
      );
    }

    final response = await _client.get(
      _uri(
        '/api/words/search?q=${Uri.encodeComponent(trimmedQuery)}&page=$page&size=$size',
      ),
      headers: await _headers(authenticated: true),
    );

    final payload = _decodeResponse(response);
    final items = _asWordList(payload);
    final payloadMap = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};

    final words = items
        .whereType<Map>()
        .map((entry) => ApiWord.fromJson(Map<String, dynamic>.from(entry)))
        .toList();

    final currentPage = _readIntValue(payloadMap['currentPage'], page);
    final totalPages = _readIntValue(payloadMap['totalPages'], currentPage + 1);
    final pageSize = _readIntValue(payloadMap['pageSize'], size);
    final hasMore = _readBoolValue(
      payloadMap['hasMore'],
      fallback: currentPage + 1 < totalPages,
    );

    return RandomWordsPage(
      words: words,
      currentPage: currentPage,
      totalPages: totalPages,
      pageSize: pageSize,
      hasMore: hasMore,
    );
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

  Map<String, dynamic> _decodeResponseObject(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage =
          'Request failed with status ${response.statusCode}.';

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic> &&
              decoded.containsKey('message')) {
            errorMessage = decoded['message'].toString();
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
      return const {};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const BackendException('Unexpected response from server.');
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

  int _readIntValue(Object? value, int fallback) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }

    return fallback;
  }

  bool _readBoolValue(Object? value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
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

    return fallback;
  }

  Map<String, dynamic> itemToJson(Object item) {
    if (item is ApiCategory) {
      return {
        'id': item.id,
        'name': item.name,
        'imageUrl': item.imageUrl,
        'description': item.description,
        'isActive': item.isActive,
        'wordCount': item.wordCount,
      };
    }

    if (item is ApiWord) {
      return {
        'id': item.id,
        'categoryId': item.categoryId,
        'word': item.word,
        'meaning': item.meaning,
        'wordImageUrl': item.wordImageUrl,
        'categoryName': item.categoryName,
        'examples': item.examples,
        'audioUrl': item.audioUrl,
        'images': item.images,
        'description': item.description,
        'facts': item.facts,
        'quizModes': item.quizModes,
        'relatedWordIds': item.relatedWords
            .map((related) => {'wordId': related.wordId, 'word': related.word})
            .toList(),
        'alsoAppearsIn': item.alsoAppearsIn
            .map(
              (entry) => {
                'categoryId': entry.categoryId,
                'wordId': entry.wordId,
                'categoryName': entry.categoryName,
              },
            )
            .toList(),
        'displayOrder': item.displayOrder,
        'created': item.created?.toIso8601String(),
        'updated': item.updated?.toIso8601String(),
        'source&credits': item.sourceAndCredits,
      };
    }

    throw ArgumentError('Unsupported cache item type: ${item.runtimeType}');
  }

  String _formatIpLocation(Map<String, dynamic> json) {
    final city = json['city']?.toString().trim() ?? '';
    final region =
        json['region']?.toString().trim() ??
        json['region_name']?.toString().trim() ??
        '';
    final country =
        json['country_name']?.toString().trim() ??
        json['country']?.toString().trim() ??
        '';

    final parts = <String>[];
    if (city.isNotEmpty) {
      parts.add(city);
    }
    if (region.isNotEmpty && region != city) {
      parts.add(region);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }

    return parts.join(', ');
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
