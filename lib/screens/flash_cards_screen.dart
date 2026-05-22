import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/word_Content_models.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/custom_native_ad.dart';
import '../widgets/swipe_feature.dart';
import 'word_sheet_details.dart';

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

  late Timer _sessionTimer;
  late DateTime _sessionStartTime;
  bool _videoAdShown = false;
  final InterstitialAdManager _adManager = InterstitialAdManager();
  final RewardedVideoAdManager _rewardedAdManager = RewardedVideoAdManager();

  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _cleanCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _adManager.loadInterstitialAd();
    _rewardedAdManager.loadRewardedAd();
    _startSessionTimer();
  }

  void _startSessionTimer() {
    _sessionStartTime = DateTime.now();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsedSeconds = DateTime.now()
          .difference(_sessionStartTime)
          .inSeconds;
      if (elapsedSeconds >= 150 && !_videoAdShown) {
        _videoAdShown = true;
        _showVideoAd();
        timer.cancel();
      }
    });
  }

  void _showVideoAd() {
    if (_rewardedAdManager.isAdReady) {
      _rewardedAdManager.showRewardedAd(
        onUserEarnedReward: (amount, type) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('You earned $amount $type')));
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      final categories = await BackendApi.instance.fetchCategories();
      if (!mounted) return;

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
      if (!mounted) return;
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
      if (!mounted) return;

      setState(() {
        _words = words;
        _loadingWords = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingWords = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _selectCategory(String categoryName) {
    if (_selectedCategory == categoryName) return;
    setState(() {
      _selectedCategory = categoryName;
    });
    _loadWords(categoryName);
  }

  void _advanceCard() {
    if (_words.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  Future<void> _showWordDetails(ApiWord word) async {
    try {
      final detail = await BackendApi.instance.fetchWordById(word.id);
      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => WordDetailSheet(word: detail),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _shareWord(ApiWord word) async {
    try {
      final RenderRepaintBoundary? boundary =
          _cleanCardKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary != null && boundary.attached) {
        final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        final ByteData? byteData = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        final Uint8List pngBytes = byteData!.buffer.asUint8List();

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/klug_card_${word.word}.png');
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: 'Check out this word from Klug!',
          subject: '${word.word} - Klug',
        );
      }
    } catch (e) {
      debugPrint('Error sharing card: $e');
      final shareText = StringBuffer()
        ..writeln('Klug word card')
        ..writeln(word.word)
        ..writeln(word.meaning)
        ..writeln('Category: ${word.categoryName}');

      await Share.share(
        shareText.toString().trim(),
        subject: '${word.word} - Klug',
      );
    }
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
                'Browse categories and swipe through words',
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
      return InlineError(message: _errorMessage!);
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
        final effectiveCardHeight = ((cardWidth * 1.35) - 20).clamp(
          0.0,
          cardHeight,
        );

        return ClipRect(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -5000,
                top: -5000,
                child: SizedBox(
                  width: cardWidth,
                  height: effectiveCardHeight,
                  child: RepaintBoundary(
                    key: _cleanCardKey,
                    child: SwipeCard(
                      word: currentWord,
                      width: cardWidth,
                      height: effectiveCardHeight,
                      progress: 0,
                      isDragging: false,
                      onShareWord: _shareWord,
                    ),
                  ),
                ),
              ),
              if (thirdWord != null)
                RepaintBoundary(
                  child: StackCardBackdrop(
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
                  child: StackCardBackdrop(
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
                  key: _cardKey,
                  child: Transform.translate(
                    offset: _dragOffset,
                    child: Transform.rotate(
                      angle: _dragOffset.dx / 920,
                      child: Center(
                        child: SwipeCard(
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
