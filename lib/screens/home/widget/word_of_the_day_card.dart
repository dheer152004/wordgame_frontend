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
              colors: [
                Color.fromARGB(255, 22, 46, 231),
                Color.fromARGB(255, 33, 20, 146),
                Color.fromARGB(255, 204, 206, 230),
              ],
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
                    color: const Color.fromARGB(255, 142, 57, 57).withAlpha(20),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: 28,
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
                                  color: const Color.fromARGB(255, 32, 13, 198),
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
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: Material(
                              color: const Color.fromARGB(255, 0, 0, 0).withAlpha(38),
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'Open word flashcard',
                                onPressed: word == null
                                    ? null
                                    : () => widget.onWordTap(word),
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color.fromARGB(255, 22, 1, 1),
                                  size: 21,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Image rounded
                    SizedBox(
                      width: 144,
                      height: 144,
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                imageUrl,
                                width: 144,
                                height: 144,
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
