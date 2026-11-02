import 'package:flutter/material.dart';

import '../models/word_Content_models.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';

class RecentCategoriesSection extends StatelessWidget {
  final List<ApiCategory> categories;
  final ValueChanged<ApiCategory> onCategoryTap;
  final VoidCallback onSeeAll;

  const RecentCategoriesSection({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: AppThemeColors.textSecondary(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Recently Explored',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppThemeColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _RecentCategoryCard(
                category: category,
                onTap: () => onCategoryTap(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentCategoryCard extends StatelessWidget {
  final ApiCategory category;
  final VoidCallback onTap;

  const _RecentCategoryCard({required this.category, required this.onTap});

  String _imageUrl() {
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
    final imageUrl = _imageUrl();
    return SizedBox(
      width: 144,
      child: Material(
        color: AppThemeColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
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
                      Colors.black.withAlpha(20),
                      Colors.black.withAlpha(190),
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
                      maxLines: 1,
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
      ),
    );
  }
}
