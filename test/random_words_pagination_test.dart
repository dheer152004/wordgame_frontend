import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nroq/services/backend_api.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(
      envString: 'BACKEND_API_BASE_URL=https://test.example',
    );
  });

  test('sends and persists the page-zero pagination token', () async {
    final requests = <Uri>[];
    final api = BackendApi.withClient(
      MockClient((request) async {
        requests.add(request.url);
        final page = int.parse(request.url.queryParameters['page']!);
        return http.Response(
          jsonEncode(_response(page: page, token: 'random-token')),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await api.fetchRandomWords(page: 0, size: 10);
    await api.fetchRandomWords(page: 1, size: 10);

    expect(requests, hasLength(2));
    expect(requests[0].path, '/api/words/random');
    expect(requests[0].queryParameters, {'page': '0', 'size': '10'});
    expect(requests[1].queryParameters, {
      'page': '1',
      'size': '10',
      'paginationToken': 'random-token',
    });

    final preferences = await SharedPreferences.getInstance();
    final storedToken =
        jsonDecode(
              preferences.getString('random_words_pagination_token_v1_10')!,
            )
            as Map<String, dynamic>;
    expect(storedToken['token'], 'random-token');
    expect(DateTime.tryParse(storedToken['cachedAt'] as String), isNotNull);
  });

  test('refreshes an expired token before loading a later page', () async {
    final requests = <Uri>[];
    SharedPreferences.setMockInitialValues({
      'random_words_pagination_token_v1_10': jsonEncode({
        'token': 'expired-token',
        'cachedAt': DateTime.now()
            .subtract(const Duration(minutes: 31))
            .toIso8601String(),
      }),
    });
    final api = BackendApi.withClient(
      MockClient((request) async {
        requests.add(request.url);
        final page = int.parse(request.url.queryParameters['page']!);
        return http.Response(
          jsonEncode(_response(page: page, token: 'renewed-token')),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await api.fetchRandomWords(page: 1, size: 10);

    expect(requests, hasLength(2));
    expect(requests[0].queryParameters['page'], '0');
    expect(requests[1].queryParameters['page'], '1');
    expect(requests[1].queryParameters['paginationToken'], 'renewed-token');
  });

  test(
    'serves previously fetched random-word pages from local cache',
    () async {
      var requestCount = 0;
      final api = BackendApi.withClient(
        MockClient((request) async {
          requestCount++;
          final page = int.parse(request.url.queryParameters['page']!);
          return http.Response(
            jsonEncode(_response(page: page, token: 'cached-token')),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      await api.fetchRandomWords(page: 0, size: 10);
      await api.fetchRandomWords(page: 1, size: 10);
      await api.fetchRandomWords(page: 1, size: 10);

      expect(requestCount, 2);
    },
  );
}

Map<String, Object> _response({required int page, required String token}) => {
  'paginationToken': token,
  'isRandom': true,
  'totalWords': 20,
  'words': [
    {
      'id': page + 1,
      'word': 'Word ${page + 1}',
      'meaning': 'Meaning ${page + 1}',
      'wordImageUrl': '',
      'categoryName': '',
      'examples': <String>[],
    },
  ],
  'totalPages': 2,
  'hasMore': page == 0,
  'pageSize': 10,
  'currentPage': page,
};
