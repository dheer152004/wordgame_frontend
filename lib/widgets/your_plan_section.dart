import 'package:flutter/material.dart';
import '../models/content_models.dart';
import '../screens/flash_cards_screen.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  late Future<List<ApiCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = BackendApi.instance.fetchCategories();
  }

  Future<void> _reloadCategories() async {
    setState(() {
      _categoriesFuture = BackendApi.instance.fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApiCategory>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Categories', style: AppTextStyles.sectionTitle),
                ),
                if (snapshot.connectionState == ConnectionState.done)
                  TextButton(
                    onPressed: _reloadCategories,
                    child: const Text('Refresh'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState != ConnectionState.done)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              _ErrorState(
                message: snapshot.error.toString(),
                onRetry: _reloadCategories,
              )
            else if ((snapshot.data ?? const []).isEmpty)
              const _EmptyState()
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth =
                      (constraints.maxWidth - AppSpacing.cardGap) / 2;

                  return Wrap(
                    spacing: AppSpacing.cardGap,
                    runSpacing: AppSpacing.cardGap,
                    children: [
                      for (
                        var index = 0;
                        index < snapshot.data!.length;
                        index++
                      )
                        SizedBox(
                          width: cardWidth,
                          child: _CategoryCard(
                            data: _CategoryCardData.fromCategory(
                              snapshot.data![index],
                              index,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FlashCardsScreen(
                                    categoryName: snapshot.data![index].name,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _CategoryCardData {
  final String title;
  final String label;
  final String examples;
  final Color color;
  final IconData icon;

  const _CategoryCardData({
    required this.title,
    required this.label,
    required this.examples,
    required this.color,
    required this.icon,
  });

  factory _CategoryCardData.fromCategory(ApiCategory category, int index) {
    final palettes = [
      AppColors.planCardYellow,
      AppColors.planCardBlue,
      AppColors.planCardPink,
      const Color(0xFFD8C7A6),
      const Color(0xFFC6E7D9),
      const Color(0xFFC9D8FF),
      const Color(0xFFEAD6FF),
      const Color(0xFFFFD7E1),
    ];

    final icons = [
      Icons.bolt_rounded,
      Icons.brush_rounded,
      Icons.auto_awesome_rounded,
      Icons.place_rounded,
      Icons.public_rounded,
      Icons.sports_esports_rounded,
      Icons.work_rounded,
      Icons.favorite_rounded,
    ];

    return _CategoryCardData(
      title: category.name,
      label: '${category.wordCount} words',
      examples: 'Tap to open the live deck\nSynced from the backend',
      color: palettes[index % palettes.length],
      icon: icons[index % icons.length],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final _CategoryCardData data;
  final VoidCallback onTap;

  const _CategoryCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: data.color,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IntensityTag(label: data.label),
            const SizedBox(height: 12),
            Text(data.title, style: AppTextStyles.planCardTitle),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                data.examples,
                style: AppTextStyles.planCardDetail,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.28),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: AppColors.textPrimary, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Could not load categories.'),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.planCardDetail),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: const Text('No categories were returned by the backend.'),
    );
  }
}

/// Reusable intensity/tag pill
class _IntensityTag extends StatelessWidget {
  final String label;

  const _IntensityTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(label, style: AppTextStyles.tagText),
    );
  }
}
