import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/word_Content_models.dart';

class RecentCategoryStore {
  static const String _storageKey = 'recent_explored_categories';
  static const int maxCategories = 15;

  static Future<List<ApiCategory>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedCategories = preferences.getStringList(_storageKey) ?? [];
    return encodedCategories
        .map(
          (encoded) => ApiCategory.fromJson(
            Map<String, dynamic>.from(jsonDecode(encoded) as Map),
          ),
        )
        .toList();
  }

  static Future<void> record(ApiCategory category) async {
    final categories = await load();
    categories.removeWhere((item) => item.id == category.id);
    categories.insert(0, category);
    await replace(categories);
  }

  static Future<void> replace(List<ApiCategory> categories) async {
    final uniqueCategories = <ApiCategory>[];
    final seenIds = <int>{};
    for (final category in categories) {
      if (seenIds.add(category.id)) {
        uniqueCategories.add(category);
      }
      if (uniqueCategories.length == maxCategories) {
        break;
      }
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey,
      uniqueCategories.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
