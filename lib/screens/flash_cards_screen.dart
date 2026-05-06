import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FlashCardsScreen extends StatefulWidget {
  const FlashCardsScreen({super.key});

  @override
  State<FlashCardsScreen> createState() => _FlashCardsScreenState();
}

class _FlashCardsScreenState extends State<FlashCardsScreen> {
  final List<_FlashCardData> _cards = const [
    _FlashCardData(
      term: 'Rizz',
      meaning: 'Confidence or charm in flirting.',
      example: 'He pulled up with serious rizz.',
      category: 'Gen Z',
      color: Color(0xFFC5B8F8),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F60E.png',
    ),
    _FlashCardData(
      term: 'Skibidi',
      meaning: 'A playful internet phrase used as meme slang.',
      example: 'That edit was straight skibidi chaos.',
      category: 'Gen Alpha',
      color: Color(0xFFF5A0C8),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F92A.png',
    ),
    _FlashCardData(
      term: 'Tapori',
      meaning: 'Street-smart slang style often heard in Mumbai.',
      example: 'Boss, full tapori vibes today.',
      category: 'Regional',
      color: Color(0xFFF5A623),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F5FA.png',
    ),
    _FlashCardData(
      term: 'GG',
      meaning: 'Good game.',
      example: 'GG after a tight match.',
      category: 'Gaming',
      color: Color(0xFFA8D8F0),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F3AE.png',
    ),
    _FlashCardData(
      term: 'Buff',
      meaning: 'To make something stronger or more powerful.',
      example: 'They buffed the character in the latest patch.',
      category: 'Gaming',
      color: Color(0xFFC9D8FF),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F4AA.png',
    ),
    _FlashCardData(
      term: 'Circle back',
      meaning: 'Return to a topic later.',
      example: 'Let’s circle back after lunch.',
      category: 'Workplace',
      color: Color(0xFFEAD6FF),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F4BC.png',
    ),
    _FlashCardData(
      term: 'Bandwidth',
      meaning: 'Capacity to take on more work or tasks.',
      example: 'I do not have the bandwidth this week.',
      category: 'Workplace',
      color: Color(0xFFC6E7D9),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F4BB.png',
    ),
    _FlashCardData(
      term: 'Ghosting',
      meaning: 'Cutting off communication suddenly.',
      example: 'They ghosted after the first date.',
      category: 'Dating',
      color: Color(0xFFFFD7E1),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F47B.png',
    ),
    _FlashCardData(
      term: 'Breadcrumbing',
      meaning: 'Giving just enough attention to keep someone interested.',
      example: 'Breadcrumbing keeps the chat barely alive.',
      category: 'Dating',
      color: Color(0xFFD8C7A6),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F35E.png',
    ),
    _FlashCardData(
      term: 'No cap',
      meaning: 'For real; no exaggeration.',
      example: 'No cap, that was the best match tonight.',
      category: 'Internet',
      color: Color(0xFFE2F1FF),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F525.png',
    ),
    _FlashCardData(
      term: 'Based',
      meaning: 'Confidently true, unapologetic, or admired online.',
      example: 'That take was so based.',
      category: 'Internet',
      color: Color(0xFFF5E7B8),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F973.png',
    ),
    _FlashCardData(
      term: 'Flex',
      meaning: 'To show off something impressive.',
      example: 'Posting the trophy was a clear flex.',
      category: 'General',
      color: Color(0xFFD1D6FF),
      imageUrl: 'https://openmoji.org/data/color/png/618x618/1F4AF.png',
    ),
  ];

  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  _FlashCardData get _currentCard => _cards[_currentIndex];
  _FlashCardData? get _nextCard =>
      _currentIndex + 1 < _cards.length ? _cards[_currentIndex + 1] : null;
  _FlashCardData? get _thirdCard =>
      _currentIndex + 2 < _cards.length ? _cards[_currentIndex + 2] : null;

  void _advanceCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
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
                'Drag cards left or right to swipe through random words and phrases.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth;
                    final cardHeight = constraints.maxHeight;

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_thirdCard != null)
                          _StackCardBackdrop(
                            data: _thirdCard!,
                            width: cardWidth * 0.88,
                            height: cardHeight * 0.82,
                            scale: 0.90,
                            rotation: -0.08,
                            offset: const Offset(0, 18),
                          ),
                        if (_nextCard != null)
                          _StackCardBackdrop(
                            data: _nextCard!,
                            width: cardWidth * 0.94,
                            height: cardHeight * 0.88,
                            scale: 0.96,
                            rotation: -0.03,
                            offset: const Offset(0, 8),
                          ),
                        GestureDetector(
                          onPanStart: (_) {
                            setState(() => _isDragging = true);
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
                          child: Transform.translate(
                            offset: _dragOffset,
                            child: Transform.rotate(
                              angle: _dragOffset.dx / 900,
                              child: _SwipeCard(
                                data: _currentCard,
                                width: cardWidth,
                                height: cardHeight,
                                progress:
                                    (_dragOffset.dx.abs() / swipeThreshold)
                                        .clamp(0.0, 1.0),
                                isDragging: _isDragging,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeCard extends StatelessWidget {
  final _FlashCardData data;
  final double width;
  final double height;
  final double progress;
  final bool isDragging;

  const _SwipeCard({
    required this.data,
    required this.width,
    required this.height,
    required this.progress,
    required this.isDragging,
  });

  @override
  Widget build(BuildContext context) {
    final likeOpacity = progress;
    final nopeOpacity = progress;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
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
                  color: data.color.withOpacity(0.85),
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
                  color: data.color.withOpacity(0.18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CategoryPill(label: data.category),
                      const Icon(
                        Icons.swipe_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _CardImage(imageUrl: data.imageUrl),
                  const SizedBox(height: 14),
                  const Spacer(),
                  Text(
                    data.term,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.meaning,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.66),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      data.example,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _SwipeBadge(
                        label: 'NOPE',
                        backgroundColor: Colors.white.withOpacity(0.8),
                        foregroundColor: const Color(0xFFE36A5C),
                        opacity: nopeOpacity,
                      ),
                      const SizedBox(width: 12),
                      _SwipeBadge(
                        label: 'LIKE',
                        backgroundColor: Colors.white.withOpacity(0.8),
                        foregroundColor: const Color(0xFF2AB67A),
                        opacity: likeOpacity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Swipe left or right to browse the deck',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
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

class _StackCardBackdrop extends StatelessWidget {
  final _FlashCardData data;
  final double width;
  final double height;
  final double scale;
  final double rotation;
  final Offset offset;

  const _StackCardBackdrop({
    required this.data,
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
            child: _BackdropCard(data: data, width: width, height: height),
          ),
        ),
      ),
    );
  }
}

class _BackdropCard extends StatelessWidget {
  final _FlashCardData data;
  final double width;
  final double height;

  const _BackdropCard({
    required this.data,
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
            color: Colors.black.withOpacity(0.08),
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
                  color: data.color.withOpacity(0.9),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryPill(label: data.category),
                  const Spacer(),
                  Text(
                    data.term,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.meaning,
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
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(999),
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
          border: Border.all(color: foregroundColor.withOpacity(0.18)),
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

class _FlashCardData {
  final String term;
  final String meaning;
  final String example;
  final String category;
  final Color color;
  final String imageUrl;

  const _FlashCardData({
    required this.term,
    required this.meaning,
    required this.example,
    required this.category,
    required this.color,
    required this.imageUrl,
  });
}

class _CardImage extends StatelessWidget {
  final String imageUrl;

  const _CardImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 170,
        height: 170,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
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
      ),
    );
  }
}
