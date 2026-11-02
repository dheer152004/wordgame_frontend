import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nroq/services/backend_api.dart';

void main() {
  setUp(() {
    final now = DateTime.now().toIso8601String();
    SharedPreferences.setMockInitialValues({
      'word_categories_random_page_v2_0_16': _cachedPage(
        cachedAt: now,
        categories: [_categoryJson(1)],
        currentPage: 0,
        totalPages: 2,
        pageSize: 16,
        totalCategories: 2,
        hasMore: true,
      ),
      'word_categories_random_page_v2_1_16': _cachedPage(
        cachedAt: now,
        categories: [_categoryJson(2)],
        currentPage: 1,
        totalPages: 2,
        pageSize: 16,
        totalCategories: 2,
        hasMore: false,
      ),
    });
  });

  test(
    'reads category page and pagination metadata from local cache',
    () async {
      final page = await BackendApi.instance.fetchCategoriesPage(
        page: 0,
        size: 16,
      );

      expect(page.categories.map((category) => category.id), [1]);
      expect(page.currentPage, 0);
      expect(page.totalPages, 2);
      expect(page.pageSize, 16);
      expect(page.totalCategories, 2);
      expect(page.hasMore, isTrue);
      expect(page.paginationToken, 'test-pagination-token');
    },
  );

  test('fetches all cached pages for full-list category consumers', () async {
    final categories = await BackendApi.instance.fetchCategories();

    expect(categories.map((category) => category.id), [1, 2]);
  });
}

String _cachedPage({
  required String cachedAt,
  required List<Map<String, Object>> categories,
  required int currentPage,
  required int totalPages,
  required int pageSize,
  required int totalCategories,
  required bool hasMore,
}) => jsonEncode({
  'cachedAt': cachedAt,
  'categories': categories,
  'currentPage': currentPage,
  'totalPages': totalPages,
  'pageSize': pageSize,
  'totalCategories': totalCategories,
  'hasMore': hasMore,
  'paginationToken': 'test-pagination-token',
});

Map<String, Object> _categoryJson(int id) => {
  'id': id,
  'name': 'Category $id',
  'imageUrl': '',
  'description': '',
  'isActive': true,
  'wordCount': 0,
};
