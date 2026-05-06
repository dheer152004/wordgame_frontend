import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <_CategoryCardData>[
      const _CategoryCardData(
        title: 'GenZ Slangs',
        label: 'Trending',
        examples: 'Rizz\nSus\nSlay',
        color: AppColors.planCardYellow,
        icon: Icons.bolt_rounded,
      ),
      const _CategoryCardData(
        title: 'Cosmetic',
        label: 'Popular',
        examples: 'Esterch\nBronzer\nFacial',
        color: AppColors.planCardBlue,
        icon: Icons.brush_rounded,
      ),
      const _CategoryCardData(
        title: 'Gen Alpha Slangs',
        label: 'New',
        examples: 'Skibidi\nSigma\nOhio',
        color: AppColors.planCardPink,
        icon: Icons.auto_awesome_rounded,
      ),
      const _CategoryCardData(
        title: 'Regional slang',
        label: 'India + Global',
        examples: 'Mumbai tapori\nDelhi street lingo\nLocal flavor',
        color: Color(0xFFD8C7A6),
        icon: Icons.place_rounded,
      ),
      const _CategoryCardData(
        title: 'Internet phrases',
        label: 'Memes',
        examples: 'Based\nRatio\nNo cap',
        color: Color(0xFFC6E7D9),
        icon: Icons.public_rounded,
      ),
      const _CategoryCardData(
        title: 'Gaming slang',
        label: 'Meta',
        examples: 'Nerf\nBuff\nGG',
        color: Color(0xFFC9D8FF),
        icon: Icons.sports_esports_rounded,
      ),
      const _CategoryCardData(
        title: 'Workplace jargon',
        label: 'Corporate',
        examples: 'Circle back\nBandwidth\nAction items',
        color: Color(0xFFEAD6FF),
        icon: Icons.work_rounded,
      ),
      const _CategoryCardData(
        title: 'Dating terms',
        label: 'Relationships',
        examples: 'Ghosting\nBreadcrumbing\nSituationship',
        color: Color(0xFFFFD7E1),
        icon: Icons.favorite_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - AppSpacing.cardGap) / 2;

            return Wrap(
              spacing: AppSpacing.cardGap,
              runSpacing: AppSpacing.cardGap,
              children: [
                for (final category in categories)
                  SizedBox(
                    width: cardWidth,
                    child: _CategoryCard(data: category),
                  ),
              ],
            );
          },
        ),
      ],
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
}

class _CategoryCard extends StatelessWidget {
  final _CategoryCardData data;

  const _CategoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
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
