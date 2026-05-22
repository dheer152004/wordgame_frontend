import 'package:flutter/material.dart';
import '../models/word_Content_models.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class SwipeCard extends StatelessWidget {
  final ApiWord word;
  final double width;
  final double height;
  final double progress;
  final bool isDragging;
  final Future<void> Function(ApiWord word) onShareWord;

  const SwipeCard({
    required this.word,
    required this.width,
    required this.height,
    required this.progress,
    required this.isDragging,
    required this.onShareWord,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactFactor = (height / 420).clamp(0.6, 1.0);
        final imageSize = (height * 0.50).clamp(240.0, 360.0);
        final wordFontSize = (28 * compactFactor).clamp(16.0, 34.0);
        final meaningFontSize = (14 * compactFactor).clamp(11.0, 16.0);

        final horizontalPadding = height < 500 ? 10.0 : 12.0;
        final verticalPadding = height < 500 ? 8.0 : 10.0;

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
                      color: AppColors.challengeCard.withAlpha(120),
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
                      color: AppColors.planCardBlue.withAlpha(25),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      verticalPadding,
                      horizontalPadding,
                      6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CategoryPill(label: word.categoryName),
                            Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: IconButton(
                                    tooltip: 'Share word',
                                    onPressed: () => onShareWord(word),
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      size: 18,
                                    ),
                                    color: AppColors.textPrimary,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                Icon(
                                  isDragging
                                      ? Icons.swipe_rounded
                                      : Icons.touch_app_rounded,
                                  color: AppColors.textPrimary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        CardImage(imageUrl: word.memeImageUrl, size: imageSize),
                        SizedBox(height: height < 500 ? 12 : 20),
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.1,
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: wordFontSize),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          word.meaning,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: meaningFontSize),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
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

class StackCardBackdrop extends StatelessWidget {
  final ApiWord word;
  final double width;
  final double height;
  final double scale;
  final double rotation;
  final Offset offset;

  const StackCardBackdrop({
    required this.word,
    required this.width,
    required this.height,
    required this.scale,
    required this.rotation,
    required this.offset,
    Key? key,
  }) : super(key: key);

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
            child: BackdropCard(word: word, width: width, height: height),
          ),
        ),
      ),
    );
  }
}

class BackdropCard extends StatelessWidget {
  final ApiWord word;
  final double width;
  final double height;

  const BackdropCard({
    required this.word,
    required this.width,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
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
                  color: AppColors.challengeCard.withAlpha(100),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryPill(label: word.categoryName),
                  const SizedBox(height: 12),
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
