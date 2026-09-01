import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:word_frontend/services/backend_api.dart';

import '../models/word_Content_models.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'flash_cards_screen.dart';

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
  bool _loadingDetails = false;
  ApiWord? _detailWord;

  @override
  void initState() {
    super.initState();
    _detailWord = widget.word;
    _loadSavedState();
    _loadWordDetails();
  }

  Future<void> _loadWordDetails() async {
    setState(() {
      _loadingDetails = true;
    });

    try {
      final detail = await BackendApi.instance.fetchWordById(widget.word.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _detailWord = detail;
        _loadingDetails = false;
      });
    } catch (error) {
      debugPrint('Error loading word details: $error');
      if (mounted) {
        setState(() {
          _loadingDetails = false;
        });
      }
    }
  }

  Future<void> _openWordSheet(int wordId, String wordLabel) async {
    final relatedWord = ApiWord(
      id: wordId,
      word: wordLabel,
      meaning: '',
      wordImageUrl: '',
      categoryName: '',
      examples: const [],
      wordType: '',
      expandedForm: '',
      partOfSpeech: '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WordDetailSheet(word: relatedWord),
    );
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
    final word = _detailWord ?? widget.word;
    try {
      final shareText = StringBuffer()
        ..writeln('Word: ${word.word}')
        ..writeln('Meaning: ${word.meaning}')
        ..writeln('Category: ${word.categoryName}');

      if (word.primaryExample.isNotEmpty) {
        shareText.writeln('Example: ${word.primaryExample}');
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
    final word = _detailWord ?? widget.word;
    final relatedWords = word.relatedWords;
    final similarWords = word.alsoAppearsIn;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use theme colors
    final sheetBackground = isDark ? DarkColors.surface : LightColors.surface;
    final cardBackground = isDark ? DarkColors.card : LightColors.card;
    final softPanel = isDark ? DarkColors.surfaceSoft : LightColors.surfaceSoft;
    final textPrimary = isDark
        ? DarkColors.textPrimary
        : LightColors.textPrimary;
    final textSecondary = isDark
        ? DarkColors.textSecondary
        : LightColors.textSecondary;
    final dividerColor = isDark ? DarkColors.divider : LightColors.divider;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: sheetBackground,
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
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? DarkColors.cardAlt
                            : LightColors.cardAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Text(
                        word.categoryName.isNotEmpty
                            ? word.categoryName
                            : 'General',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _shareWord(context),
                      icon: Icon(Icons.share_outlined, color: textPrimary),
                      label: Text(
                        'Share',
                        style: TextStyle(color: textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
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
                              ? (isDark
                                    ? DarkColors.primary
                                    : LightColors.primary)
                              : textPrimary,
                        ),
                        tooltip: 'Listen to pronunciation',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  word.meaning,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: textSecondary,
                  ),
                ),
                if (word.wordType.isNotEmpty ||
                    word.partOfSpeech.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (word.wordType.isNotEmpty)
                        Chip(
                          label: Text(
                            word.wordType,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: softPanel,
                          side: BorderSide(color: dividerColor),
                        ),
                      if (word.partOfSpeech.isNotEmpty)
                        Chip(
                          label: Text(
                            word.partOfSpeech,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: softPanel,
                          side: BorderSide(color: dividerColor),
                        ),
                    ],
                  ),
                ],
                if (word.expandedForm.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: softPanel,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expanded Form',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          word.expandedForm,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (word.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    word.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                if (_loadingDetails &&
                    word.wordImageUrl.isEmpty &&
                    word.images.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (word.images.isNotEmpty) ...[
                  SizedBox(
                    height: 210,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: word.images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final imageUrl = word.images[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              imageUrl,
                              width: 210,
                              height: 210,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.prefer,
                              errorBuilder: (_, __, ___) => Container(
                                width: 210,
                                height: 210,
                                color: softPanel,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: textSecondary,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (word.wordImageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        word.wordImageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (_, __, ___) => Container(
                          color: softPanel,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: textSecondary,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (word.facts.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Facts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final fact in word.facts) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: softPanel,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Text(
                        fact,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
                if (widget.word.examples.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Examples',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final example in word.examples) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: softPanel,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: dividerColor),
                      ),
                      child: Text(
                        example,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ],
                if (relatedWords.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Related Words',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: relatedWords
                        .map(
                          (related) => ActionChip(
                            onPressed: () {
                              _openWordSheet(
                                related.wordId,
                                related.word.isNotEmpty
                                    ? related.word
                                    : 'Word ${related.wordId}',
                              );
                            },
                            label: Text(
                              related.word.isNotEmpty
                                  ? related.word
                                  : 'Word ${related.wordId}',
                            ),
                            backgroundColor: softPanel,
                            side: BorderSide(color: dividerColor),
                            labelStyle: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (similarWords.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Also Appears In',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: similarWords
                        .map(
                          (item) => ActionChip(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FlashCardsScreen(
                                    categoryId: item.categoryId,
                                    categoryName: item.categoryName,
                                  ),
                                ),
                              );
                            },
                            label: Text(
                              item.categoryName.isNotEmpty
                                  ? '${item.categoryName} · Word ${item.wordId}'
                                  : 'Word ${item.wordId}',
                            ),
                            backgroundColor: softPanel,
                            side: BorderSide(color: dividerColor),
                            labelStyle: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (word.sourceAndCredits.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Source & Credits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: softPanel,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in word.sourceAndCredits.entries) ...[
                          Text(
                            '${entry.key}: ${entry.value}',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Save this word',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a short note',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        enabled: !_isSavingWord,
                        maxLines: 3,
                        minLines: 2,
                        style: TextStyle(color: textPrimary),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: softPanel,
                          labelText: 'Notes',
                          hintText: 'Why are you saving this word?',
                          labelStyle: TextStyle(color: textSecondary),
                          hintStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 10,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDark
                                  ? DarkColors.primary
                                  : LightColors.primary,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: dividerColor),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSavingWord ? null : _toggleSavedWord,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? DarkColors.primary
                                : LightColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isSavingWord
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
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
