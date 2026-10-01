import 'package:flutter/material.dart';
import '../../../models/word_Content_models.dart';
import '../../../services/audio_service.dart';
import '../../../services/backend_api.dart';
import '../../../theme/app_theme.dart';

class WordOfTheDayCard extends StatefulWidget {
  final ValueChanged<ApiWord> onWordTap;

  const WordOfTheDayCard({super.key, required this.onWordTap});

  @override
  State<WordOfTheDayCard> createState() => _WordOfTheDayCardState();
}

class _WordOfTheDayCardState extends State<WordOfTheDayCard> {
  final AudioService _audioService = AudioService();
  late final Future<ApiWord> _wordOfTheDay;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _wordOfTheDay = BackendApi.instance.fetchWordOfTheDay();
  }

  Future<void> _togglePronunciation(ApiWord? word) async {
    if (_isPlayingAudio) {
      await _audioService.stop();
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
      return;
    }

    if (word == null || word.word.trim().isEmpty) return;

    setState(() => _isPlayingAudio = true);
    try {
      await _audioService.speak(word.word);
      while (_audioService.isPlaying) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (error) {
      debugPrint('Error playing word pronunciation: $error');
    } finally {
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiWord>(
      future: _wordOfTheDay,
      builder: (context, snapshot) {
        final compact = MediaQuery.sizeOf(context).width < 400;
        final horizontalPadding = compact ? 16.0 : 20.0;
        final imageSize = compact ? 120.0 : 144.0;
        final columnGap = compact ? 10.0 : 14.0;
        final word = snapshot.data;
        final imageUrl = word != null && word.images.isNotEmpty
            ? word.images.first.imageUrl.trim()
            : '';

        return Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: Colors.white.withAlpha(16)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -30,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFBFDBFE).withAlpha(28),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WORD OF THE DAY',
                            style: TextStyle(
                              color: Color.fromARGB(179, 255, 255, 255),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  word?.word ??
                                      (snapshot.hasError
                                          ? 'Unavailable'
                                          : 'Loading...'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: compact ? 24 : 28,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: _isPlayingAudio
                                    ? 'Stop pronunciation'
                                    : 'Listen to pronunciation',
                                onPressed: word == null
                                    ? null
                                    : () => _togglePronunciation(word),
                                icon: Icon(
                                  _isPlayingAudio
                                      ? Icons.stop_circle_outlined
                                      : Icons.volume_up_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            word?.meaning ??
                                (snapshot.hasError
                                    ? 'Could not load today\'s word.'
                                    : 'Loading today\'s word...'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.greetingDate.copyWith(
                              fontSize: 13,
                              color: Colors.white.withAlpha(220),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Material(
                              color: Colors.white.withAlpha(38),
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'Open word flashcard',
                                onPressed: word == null
                                    ? null
                                    : () => widget.onWordTap(word),
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 21,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: columnGap),
                    // Image rounded
                    SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                imageUrl,
                                width: imageSize,
                                height: imageSize,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.white.withAlpha(20),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white54,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(20),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.image_outlined,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
