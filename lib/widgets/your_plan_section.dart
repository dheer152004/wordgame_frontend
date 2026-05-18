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
      const Color(0xFFF6D94A),
      const Color(0xFF8CE7FF),
      const Color(0xFFFF92D6),
      const Color(0xFFB9E7FF),
      const Color(0xFFB7A7FF),
      const Color(0xFFFFC66C),
      const Color(0xFF8FE4C6),
      const Color(0xFFE8D7FF),
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
    final textColor = _idealTextColor(data.color);
    final tagColors = _TagColors.forBackground(data.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(data.color, Colors.white, 0.18)!,
              data.color,
              Color.lerp(data.color, Colors.black, 0.10)!,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Colors.white.withAlpha(18)),
          boxShadow: [
            BoxShadow(
              color: data.color.withAlpha(70),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IntensityTag(
              label: data.label,
              backgroundColor: tagColors.background,
              foregroundColor: tagColors.foreground,
            ),
            const SizedBox(height: 12),
            Text(
              data.title,
              style: AppTextStyles.planCardTitle.copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                data.examples,
                style: AppTextStyles.planCardDetail.copyWith(color: textColor),
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
                  color: Colors.white.withAlpha(
                    textColor == Colors.white ? 24 : 38,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(14)),
                ),
                child: Icon(
                  data.icon,
                  color: textColor == Colors.white
                      ? Colors.white
                      : Colors.black,
                  size: 22,
                ),
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
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(16)),
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
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: const Text('No categories were returned by the backend.'),
    );
  }
}

/// Reusable intensity/tag pill
class _IntensityTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _IntensityTag({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.tag),
        border: Border.all(color: foregroundColor.withAlpha(30)),
      ),
      child: Text(
        label,
        style: AppTextStyles.tagText.copyWith(color: foregroundColor),
      ),
    );
  }
}

Color _idealTextColor(Color background) {
  return background.computeLuminance() > 0.62 ? Colors.black : Colors.white;
}

class _TagColors {
  final Color background;
  final Color foreground;

  const _TagColors({required this.background, required this.foreground});

  factory _TagColors.forBackground(Color background) {
    final isBright = background.computeLuminance() > 0.62;
    return _TagColors(
      background: isBright
          ? Colors.white.withAlpha(210)
          : Colors.black.withAlpha(54),
      foreground: isBright ? Colors.black : Colors.white,
    );
  }
}
