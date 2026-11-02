import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nroq/services/backend_api.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'category_words_page_v1_7_0_10': jsonEncode({
        'words': [
          {
            'id': 42,
            'categoryId': 7,
            'word': 'Cache',
            'meaning': 'Stored response',
            'wordImageUrl': '',
            'categoryName': 'Testing',
            'examples': ['Read from local storage'],
          },
        ],
        'currentPage': 0,
        'totalPages': 3,
        'pageSize': 10,
        'hasMore': true,
      }),
    });
  });

  test(
    'returns a cached category words page without a server request',
    () async {
      final page = await BackendApi.instance.fetchWordsByCategoryId(7);

      expect(page.words, hasLength(1));
      expect(page.words.single.word, 'Cache');
      expect(page.currentPage, 0);
      expect(page.totalPages, 3);
      expect(page.hasMore, isTrue);
    },
  );
}
