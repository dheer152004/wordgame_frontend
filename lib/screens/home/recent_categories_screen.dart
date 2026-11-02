import 'package:flutter/material.dart';

import '../../models/word_Content_models.dart';
import '../../services/backend_api.dart';
import '../../theme/app_theme.dart';

class RecentCategoriesScreen extends StatelessWidget {
  final List<ApiCategory> categories;
  final ValueChanged<ApiCategory> onCategoryTap;

  const RecentCategoriesScreen({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  String _imageUrl(ApiCategory category) {
    final rawUrl = category.imageUrl.trim();
    if (rawUrl.isEmpty) {
      return '';
    }

    final parsed = Uri.tryParse(rawUrl);
    if (parsed != null && parsed.hasScheme) {
      return rawUrl;
    }
    return Uri.parse(BackendApi.instance.baseUrl).resolve(rawUrl).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      appBar: AppBar(
        title: const Text('Recently Explored'),
        backgroundColor: AppThemeColors.background(context),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.cardGap,
          mainAxisSpacing: AppSpacing.cardGap,
          childAspectRatio: 1.45,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          final imageUrl = _imageUrl(category);
          return Material(
            color: AppThemeColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.card),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onCategoryTap(category);
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(12),
                          Colors.black.withAlpha(200),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.planCardTitle.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${category.wordCount} words',
                          style: AppTextStyles.planCardDetail.copyWith(
                            color: Colors.white.withAlpha(220),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
