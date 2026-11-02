import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nroq/widgets/categories_section.dart';

void main() {
  testWidgets('loads the next category page near the end of home scroll', (
    WidgetTester tester,
  ) async {
    final cachedAt = DateTime.now().toIso8601String();
    SharedPreferences.setMockInitialValues({
      'word_categories_random_page_v2_0_16': _cachedPage(
        cachedAt: cachedAt,
        categories: List.generate(16, (index) => _category(index + 1)),
        currentPage: 0,
        totalPages: 2,
        hasMore: true,
      ),
      'word_categories_random_page_v2_1_16': _cachedPage(
        cachedAt: cachedAt,
        categories: [_category(17)],
        currentPage: 1,
        totalPages: 2,
        hasMore: false,
      ),
    });

    final categoriesKey = GlobalKey<CategoriesSectionState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification &&
                  notification.depth == 0 &&
                  notification.metrics.axis == Axis.vertical &&
                  notification.metrics.extentAfter <= 400) {
                categoriesKey.currentState?.loadNextPage();
              }
              return false;
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 500),
                  CategoriesSection(key: categoriesKey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Category 17'), findsNothing);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1800),
    );
    await tester.pumpAndSettle();

    expect(find.text('Category 17'), findsOneWidget);
  });
}

String _cachedPage({
  required String cachedAt,
  required List<Map<String, Object>> categories,
  required int currentPage,
  required int totalPages,
  required bool hasMore,
}) => jsonEncode({
  'cachedAt': cachedAt,
  'categories': categories,
  'currentPage': currentPage,
  'totalPages': totalPages,
  'pageSize': 16,
  'totalCategories': 17,
  'hasMore': hasMore,
  'paginationToken': 'test-pagination-token',
});

Map<String, Object> _category(int id) => {
  'id': id,
  'name': 'Category $id',
  'imageUrl': '',
  'description': 'Description for category $id',
  'isActive': true,
  'wordCount': id,
};
