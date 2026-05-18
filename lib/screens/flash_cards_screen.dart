import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/content_models.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';

class FlashCardsScreen extends StatefulWidget {
  final String? categoryName;

  const FlashCardsScreen({super.key, this.categoryName});

  @override
  State<FlashCardsScreen> createState() => _FlashCardsScreenState();
}

class _FlashCardsScreenState extends State<FlashCardsScreen> {
  final List<ApiCategory> _categories = [];
  List<ApiWord> _words = [];

  bool _loadingCategories = true;
  bool _loadingWords = false;
  String? _selectedCategory;
  String? _errorMessage;

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final categories = await BackendApi.instance.fetchCategories();
      if (!mounted) {
        return;
      }

      setState(() {
        _categories
          ..clear()
          ..addAll(categories);
        _loadingCategories = false;
        _selectedCategory =
            widget.categoryName ??
            (categories.isNotEmpty ? categories.first.name : null);
      });

      if (_selectedCategory != null) {
        await _loadWords(_selectedCategory!);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingCategories = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _loadWords(String categoryName) async {
    setState(() {
      _loadingWords = true;
      _errorMessage = null;
      _currentIndex = 0;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });

    try {
      final words = await BackendApi.instance.fetchWordsByCategory(
        categoryName,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _words = words;
        _loadingWords = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingWords = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _selectCategory(String categoryName) {
    if (_selectedCategory == categoryName) {
      return;
    }

    setState(() {
      _selectedCategory = categoryName;
    });
    _loadWords(categoryName);
  }

  void _advanceCard() {
    if (_words.isEmpty) {
      return;
    }

    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  Future<void> _showWordDetails(ApiWord word) async {
    try {
      final detail = await BackendApi.instance.fetchWordById(word.id);
      if (!mounted) {
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _WordDetailSheet(word: detail);
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _shareWord(ApiWord word) async {
    final shareText = StringBuffer()
      ..writeln('Klug word card')
      ..writeln(word.word)
      ..writeln(word.meaning)
      ..writeln('Category: ${word.categoryName}')
      ..writeln(
        word.primaryExample.isNotEmpty ? 'Example: ${word.primaryExample}' : '',
      );

    if (word.memeImageUrl.isNotEmpty) {
      shareText
        ..writeln()
        ..writeln(word.memeImageUrl);
    }

    await Share.share(
      shareText.toString().trim(),
      subject: '${word.word} - Klug',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeThreshold = screenWidth * 0.28;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 6),
                  const Text('Flash Cards', style: AppTextStyles.sectionTitle),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Browse live categories from the backend and swipe through words.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 18),
              Expanded(child: _buildDeck(swipeThreshold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    if (_loadingCategories) {
      return const SizedBox(
        height: 46,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _categories.isEmpty) {
      return _InlineError(message: _errorMessage!);
    }

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category.name == _selectedCategory;
          return ChoiceChip(
            label: Text('${category.name} · ${category.wordCount}'),
            selected: selected,
            onSelected: (_) => _selectCategory(category.name),
            labelStyle: TextStyle(
              color: selected ? Colors.black : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: AppColors.surfaceAlt,
            selectedColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(color: Colors.white.withAlpha(18)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeck(double swipeThreshold) {
    if (_loadingWords) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedCategory == null) {
      return const Center(
        child: Text('No categories were returned by the backend.'),
      );
    }

    if (_words.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 42,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              'No words found for $_selectedCategory',
              style: AppTextStyles.planCardDetail,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _loadWords(_selectedCategory!),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final currentWord = _words[_currentIndex.clamp(0, _words.length - 1)];
    final nextWord = _words.length > 1
        ? _words[(_currentIndex + 1) % _words.length]
        : null;
    final thirdWord = _words.length > 2
        ? _words[(_currentIndex + 2) % _words.length]
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth * 0.94;
        final cardHeight = constraints.maxHeight;
        final effectiveCardHeight = (cardHeight - 38).clamp(0.0, cardHeight);

        return ClipRect(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (thirdWord != null)
                RepaintBoundary(
                  child: _StackCardBackdrop(
                    word: thirdWord,
                    width: cardWidth * 0.88,
                    height: effectiveCardHeight * 0.82,
                    scale: 0.90,
                    rotation: -0.08,
                    offset: const Offset(0, 18),
                  ),
                ),
              if (nextWord != null)
                RepaintBoundary(
                  child: _StackCardBackdrop(
                    word: nextWord,
                    width: cardWidth * 0.94,
                    height: effectiveCardHeight * 0.88,
                    scale: 0.96,
                    rotation: -0.03,
                    offset: const Offset(0, 8),
                  ),
                ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showWordDetails(currentWord),
                onPanStart: (_) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _dragOffset += details.delta;
                  });
                },
                onPanEnd: (details) {
                  final shouldSwipe =
                      _dragOffset.dx.abs() > swipeThreshold ||
                      details.velocity.pixelsPerSecond.dx.abs() > 700;

                  if (shouldSwipe) {
                    _advanceCard();
                  } else {
                    setState(() {
                      _dragOffset = Offset.zero;
                      _isDragging = false;
                    });
                  }
                },
                child: RepaintBoundary(
                  child: Transform.translate(
                    offset: _dragOffset,
                    child: Transform.rotate(
                      angle: _dragOffset.dx / 920,
                      child: Center(
                        child: _SwipeCard(
                          word: currentWord,
                          width: cardWidth,
                          height: effectiveCardHeight,
                          progress: (_dragOffset.dx.abs() / swipeThreshold)
                              .clamp(0.0, 1.0),
                          isDragging: _isDragging,
                          onShareWord: _shareWord,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SwipeCard extends StatelessWidget {
  final ApiWord word;
  final double width;
  final double height;
  final double progress;
  final bool isDragging;
  final Future<void> Function(ApiWord word) onShareWord;

  const _SwipeCard({
    required this.word,
    required this.width,
    required this.height,
    required this.progress,
    required this.isDragging,
    required this.onShareWord,
  });

  @override
  Widget build(BuildContext context) {
    final likeOpacity = progress;
    final nopeOpacity = progress;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactFactor = (height / 420).clamp(0.86, 1.0);
        final imageSize = (height * 0.58).clamp(230.0, 320.0);
        final wordFontSize = 36 * compactFactor;
        final meaningFontSize = 18 * compactFactor;
        final exampleFontSize = 15 * compactFactor;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(110),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
            border: Border.all(color: Colors.white.withAlpha(18)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              children: [
                Positioned(
                  left: -60,
                  top: -60,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.challengeCard.withAlpha(210),
                    ),
                  ),
                ),
                Positioned(
                  right: -40,
                  bottom: -30,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.planCardBlue.withAlpha(46),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CategoryPill(label: word.categoryName),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Share word',
                                  onPressed: () => onShareWord(word),
                                  icon: const Icon(Icons.share_outlined),
                                  color: AppColors.textPrimary,
                                ),
                                Icon(
                                  isDragging
                                      ? Icons.swipe_rounded
                                      : Icons.touch_app_rounded,
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _CardImage(
                          imageUrl: word.memeImageUrl,
                          size: imageSize,
                        ),
                        const SizedBox(height: 4),
                        const SizedBox(height: 8),
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.1,
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: wordFontSize),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          word.meaning,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: meaningFontSize),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withAlpha(16),
                            ),
                          ),
                          child: Text(
                            word.primaryExample.isNotEmpty
                                ? word.primaryExample
                                : 'Tap to view full details',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: exampleFontSize,
                              height: 1.45,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _SwipeBadge(
                              label: 'NOPE',
                              backgroundColor: Colors.white.withAlpha(204),
                              foregroundColor: const Color(0xFFE36A5C),
                              opacity: nopeOpacity,
                            ),
                            const SizedBox(width: 12),
                            _SwipeBadge(
                              label: 'LIKE',
                              backgroundColor: Colors.white.withAlpha(204),
                              foregroundColor: const Color(0xFF2AB67A),
                              opacity: likeOpacity,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StackCardBackdrop extends StatelessWidget {
  final ApiWord word;
  final double width;
  final double height;
  final double scale;
  final double rotation;
  final Offset offset;

  const _StackCardBackdrop({
    required this.word,
    required this.width,
    required this.height,
    required this.scale,
    required this.rotation,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: 0.55,
            child: _BackdropCard(word: word, width: width, height: height),
          ),
        ),
      ),
    );
  }
}

class _BackdropCard extends StatelessWidget {
  final ApiWord word;
  final double width;
  final double height;

  const _BackdropCard({
    required this.word,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            Positioned(
              left: -45,
              top: -45,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.challengeCard.withAlpha(230),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryPill(label: word.categoryName),
                  const Spacer(),
                  Text(
                    word.word,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    word.meaning,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;

  const _CategoryPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(16)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SwipeBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final double opacity;

  const _SwipeBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: foregroundColor.withAlpha(46)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: foregroundColor,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _CardImage({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 42,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : const Icon(
                Icons.image_not_supported_outlined,
                size: 42,
                color: AppColors.textSecondary,
              ),
      ),
    );
  }
}

class _WordDetailSheet extends StatelessWidget {
  final ApiWord word;

  const _WordDetailSheet({required this.word});

  Future<void> _shareWord(BuildContext context) async {
    final shareText = StringBuffer()
      ..writeln('Klug word card')
      ..writeln(word.word)
      ..writeln(word.meaning)
      ..writeln('Category: ${word.categoryName}')
      ..writeln(
        word.primaryExample.isNotEmpty ? 'Example: ${word.primaryExample}' : '',
      );

    if (word.memeImageUrl.isNotEmpty) {
      shareText
        ..writeln()
        ..writeln(word.memeImageUrl);
    }

    await Share.share(
      shareText.toString().trim(),
      subject: '${word.word} - Klug',
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share sheet opened.')));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _CategoryPill(label: word.categoryName),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _shareWord(context),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(word.meaning, style: AppTextStyles.planCardDetail),
                const SizedBox(height: 18),
                if (word.memeImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        word.memeImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                if (word.examples.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final example in word.examples) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withAlpha(14)),
                      ),
                      child: Text(
                        example,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Text(message, style: AppTextStyles.planCardDetail),
    );
  }
}
