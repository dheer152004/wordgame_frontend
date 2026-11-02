import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nroq/models/word_Content_models.dart';
import 'package:nroq/services/recent_category_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('keeps at most 15 categories in most-recent-first order', () async {
    for (var id = 1; id <= 16; id++) {
      await RecentCategoryStore.record(_category(id));
    }

    final categories = await RecentCategoryStore.load();

    expect(categories, hasLength(15));
    expect(categories.first.id, 16);
    expect(categories.last.id, 2);
  });

  test(
    'moves an already explored category to the front without duplicates',
    () async {
      await RecentCategoryStore.record(_category(1));
      await RecentCategoryStore.record(_category(2));
      await RecentCategoryStore.record(_category(1));

      final categories = await RecentCategoryStore.load();

      expect(categories.map((category) => category.id), [1, 2]);
    },
  );

  test('replaces category details while preserving recent order', () async {
    await RecentCategoryStore.record(_category(1));
    await RecentCategoryStore.replace([
      _category(1, name: 'Updated category'),
      _category(2),
    ]);

    final categories = await RecentCategoryStore.load();

    expect(categories.map((category) => category.id), [1, 2]);
    expect(categories.first.name, 'Updated category');
  });
}

ApiCategory _category(int id, {String? name}) => ApiCategory(
  id: id,
  name: name ?? 'Category $id',
  imageUrl: '',
  description: '',
  isActive: true,
  wordCount: id,
);
