import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:word_frontend/services/backend_api.dart';

import '../models/word_Content_models.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class WordDetailSheet extends StatefulWidget {
  final ApiWord word;

  const WordDetailSheet({required this.word, super.key});

  @override
  State<WordDetailSheet> createState() => _WordDetailSheetState();
}

class _WordDetailSheetState extends State<WordDetailSheet> {
  final AudioService _audioService = AudioService();
  final TextEditingController _notesController = TextEditingController();
  bool _isPlayingAudio = false;
  bool _isSavingWord = false;
  bool _isAlreadySaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      final savedWords = await BackendApi.instance.fetchSavedWords();
      if (!mounted) {
        return;
      }

      final matchingSavedWord = savedWords.where(
        (savedWord) => savedWord.wordId == widget.word.id,
      );

      setState(() {
        final savedWord = matchingSavedWord.isNotEmpty
            ? matchingSavedWord.first
            : null;
        _isAlreadySaved = savedWord != null;
        if (savedWord != null) {
          _notesController.text = savedWord.notes;
        }
      });
    } catch (error) {
      debugPrint('Error checking saved word state: $error');
    }
  }

  Future<void> _playPronunciation() async {
    setState(() {
      _isPlayingAudio = true;
    });

    try {
      await _audioService.speak(widget.word.word);

      while (_audioService.isPlaying) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      debugPrint('Error playing pronunciation: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
        });
      }
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _audioService.stop();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
    if (mounted) {
      setState(() {
        _isPlayingAudio = false;
      });
    }
  }

  Future<void> _toggleSavedWord() async {
    if (_isSavingWord) {
      return;
    }

    setState(() {
      _isSavingWord = true;
    });

    try {
      if (_isAlreadySaved) {
        await BackendApi.instance.removeSavedWord(widget.word.id);
      } else {
        await BackendApi.instance.saveWord(
          wordId: widget.word.id,
          notes: _notesController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _isAlreadySaved = !_isAlreadySaved;
        if (_isAlreadySaved) {
          _notesController.clear();
        }
      });
    } catch (e) {
      debugPrint('Error toggling saved word: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating saved word: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingWord = false;
        });
      }
    }
  }

  Future<void> _shareWord(BuildContext context) async {
    try {
      final shareText = StringBuffer()
        ..writeln('Word: ${widget.word.word}')
        ..writeln('Meaning: ${widget.word.meaning}')
        ..writeln('Category: ${widget.word.categoryName}');

      if (widget.word.primaryExample.isNotEmpty) {
        shareText.writeln('Example: ${widget.word.primaryExample}');
      }

      shareText
        ..writeln()
        ..writeln('Get more exciting words on KLUG');

      await Share.share(
        shareText.toString().trim(),
        subject: '${widget.word.word} - Klug',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Word shared successfully!')),
      );
    } catch (e) {
      debugPrint('Error sharing word: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryPill(label: widget.word.categoryName),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _shareWord(context),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.word.word,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: IconButton(
                        onPressed: _isPlayingAudio
                            ? _stopPlayback
                            : _playPronunciation,
                        icon: Icon(
                          _isPlayingAudio
                              ? Icons.stop_circle
                              : Icons.volume_up_outlined,
                          color: _isPlayingAudio
                              ? AppColors.planCardBlue
                              : AppColors.textPrimary,
                        ),
                        tooltip: 'Listen to pronunciation',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(widget.word.meaning, style: AppTextStyles.planCardDetail),
                const SizedBox(height: 18),
                if (widget.word.wordImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        widget.word.wordImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceAlt,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textSecondary,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.word.examples.isNotEmpty) ...[
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
                  for (final example in widget.word.examples) ...[
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
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withAlpha(14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Save this word',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add a short note',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        enabled: !_isSavingWord,
                        maxLines: 3,
                        minLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Why are you saving this word?',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),

                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSavingWord ? null : _toggleSavedWord,
                          icon: _isSavingWord
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.background,
                                  ),
                                )
                              : Icon(
                                  _isAlreadySaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_add_outlined,
                                ),
                          label: Text(
                            _isSavingWord
                                ? 'Saving...'
                                : _isAlreadySaved
                                ? 'Saved'
                                : 'Save word',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _audioService.stop();
    super.dispose();
  }
}
