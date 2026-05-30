import 'dart:async';

import 'package:flutter/material.dart';
import '../models/word_Content_models.dart';
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
    _categoriesFuture = BackendApi.instance.fetchCategories(forceRefresh: true);
  }

  Future<void> _reloadCategories() async {
    setState(() {
      _categoriesFuture = BackendApi.instance.fetchCategories(
        forceRefresh: true,
      );
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
  final String imageUrl;
  final Color color;
  final IconData icon;

  const _CategoryCardData({
    required this.title,
    required this.label,
    required this.examples,
    required this.imageUrl,
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
      examples: category.description.trim().isNotEmpty
          ? category.description.trim()
          : 'Tap to open the live deck\nSynced from the backend',
      imageUrl: _resolveCategoryImageUrl(category.imageUrl),
      color: palettes[index % palettes.length],
      icon: icons[index % icons.length],
    );
  }

  static String _resolveCategoryImageUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) {
      return trimmed;
    }

    final base = Uri.tryParse(BackendApi.instance.baseUrl);
    if (base == null) {
      return trimmed;
    }

    final resolved = base.resolve(trimmed);
    return resolved.toString();
  }
}

class _CategoryCard extends StatefulWidget {
  final _CategoryCardData data;
  final VoidCallback onTap;

  const _CategoryCard({required this.data, required this.onTap});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  static const Duration _previewHoldDuration = Duration(milliseconds: 700);

  Timer? _previewTimer;
  bool _suppressNextTap = false;

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _previewTimer?.cancel();
    _previewTimer = Timer(_previewHoldDuration, _openPreview);
  }

  void _handleTapUp(TapUpDetails details) {
    _previewTimer?.cancel();
  }

  void _handleTapCancel() {
    _previewTimer?.cancel();
    _suppressNextTap = false;
  }

  void _handleTap() {
    if (_suppressNextTap) {
      _suppressNextTap = false;
      return;
    }

    widget.onTap();
  }

  Future<void> _openPreview() async {
    if (!mounted) {
      return;
    }

    _suppressNextTap = true;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Category details',
      barrierColor: Colors.black.withAlpha(190),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.92,
              heightFactor: 0.88,
              child: _CategoryDetailSheet(
                data: widget.data,
                onOpenCategory: () {
                  Navigator.of(dialogContext).pop();
                  widget.onTap();
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = Tween<double>(begin: 0.94, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(scale: scale, child: child),
        );
      },
    );

    if (mounted) {
      _suppressNextTap = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.imageUrl.isNotEmpty) {
      return _buildImageCard();
    }

    return _buildColorCard();
  }

  Widget _buildColorCard() {
    final textColor = _idealTextColor(widget.data.color);
    final tagColors = _TagColors.forBackground(widget.data.color);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(widget.data.color, Colors.white, 0.18)!,
              widget.data.color,
              Color.lerp(widget.data.color, Colors.black, 0.10)!,
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Colors.white.withAlpha(18)),
          boxShadow: [
            BoxShadow(
              color: widget.data.color.withAlpha(70),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IntensityTag(
              label: widget.data.label,
              backgroundColor: tagColors.background,
              foregroundColor: tagColors.foreground,
            ),
            const SizedBox(height: 12),
            Text(
              widget.data.title,
              style: AppTextStyles.planCardTitle.copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.data.examples,
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
                  widget.data.icon,
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

  Widget _buildImageCard() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Colors.white.withAlpha(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.data.imageUrl,
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, __, ___) => _buildImageFallback(),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  // Left-to-right fade so text remains readable on image cards.
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withAlpha(176),
                      Colors.black.withAlpha(112),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _IntensityTag(
                      label: widget.data.label,
                      backgroundColor: Colors.black.withAlpha(66),
                      foregroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.data.title,
                      style: AppTextStyles.planCardTitle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        widget.data.examples,
                        style: AppTextStyles.planCardDetail.copyWith(
                          color: Colors.white.withAlpha(220),
                        ),
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
                          color: Colors.white.withAlpha(24),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(24)),
                        ),
                        child: Icon(
                          widget.data.icon,
                          color: Colors.white,
                          size: 22,
                        ),
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

  Widget _buildImageFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(widget.data.color, Colors.white, 0.18)!,
            widget.data.color,
            Color.lerp(widget.data.color, Colors.black, 0.10)!,
          ],
        ),
      ),
    );
  }
}

class _CategoryDetailSheet extends StatelessWidget {
  final _CategoryCardData data;
  final VoidCallback onOpenCategory;

  const _CategoryDetailSheet({
    required this.data,
    required this.onOpenCategory,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = _idealTextColor(data.color);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.white.withAlpha(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (data.imageUrl.isNotEmpty)
                        Image.network(
                          data.imageUrl,
                          fit: BoxFit.cover,
                          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                          errorBuilder: (_, __, ___) => _detailFallback(data),
                        )
                      else
                        _detailFallback(data),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withAlpha(32),
                              Colors.black.withAlpha(180),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Material(
                          color: Colors.black.withAlpha(120),
                          shape: const CircleBorder(),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'Close',
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _IntensityTag(
                              label: data.label,
                              backgroundColor: Colors.black.withAlpha(90),
                              foregroundColor: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              data.title,
                              style: AppTextStyles.sectionTitle.copyWith(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${data.label} • ${data.title}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Expanded(
                          child: _DetailStatChip(
                            icon: Icons.menu_book_rounded,
                            label: 'Words',
                            value: data.label,
                            accentColor: data.color,
                            textColor: textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DetailStatChip(
                            icon: Icons.check_circle_outline_rounded,
                            label: 'State',
                            value: 'Live',
                            accentColor: data.color,
                            textColor: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Full Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data.examples,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onOpenCategory,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Open category deck'),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailStatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final Color textColor;

  const _DetailStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(24),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _detailFallback(_CategoryCardData data) {
  return Container(
    color: data.color,
    alignment: Alignment.center,
    child: Icon(data.icon, size: 72, color: _idealTextColor(data.color)),
  );
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
      child: const Text('No categories were returned by the server.'),
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
