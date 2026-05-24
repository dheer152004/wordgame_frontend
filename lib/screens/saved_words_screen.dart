import 'package:flutter/material.dart';

import '../models/word_Content_models.dart';
import '../screens/word_sheet_details.dart';
import '../services/backend_api.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_action_buttons.dart';

class SavedWordsScreen extends StatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  late Future<List<SavedWord>> _savedWordsFuture;

  @override
  void initState() {
    super.initState();
    _savedWordsFuture = BackendApi.instance.fetchSavedWords();
  }

  Future<void> _reloadSavedWords() async {
    setState(() {
      _savedWordsFuture = BackendApi.instance.fetchSavedWords();
    });

    await _savedWordsFuture;
  }

  Future<void> _openSavedWord(SavedWord savedWord) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDetailSheet(word: savedWord.toApiWord()),
      ),
    );

    if (mounted) {
      await _reloadSavedWords();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<SavedWord>>(
          future: _savedWordsFuture,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final error = snapshot.error;
            final savedWords = snapshot.data ?? const <SavedWord>[];

            return RefreshIndicator(
              onRefresh: _reloadSavedWords,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: _HeaderCard(
                        totalCount: savedWords.length,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  if (isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _EmptyStateCard(
                          title: 'Could not load saved words',
                          message: error.toString(),
                          actionLabel: 'Retry',
                          onAction: _reloadSavedWords,
                        ),
                      ),
                    )
                  else if (savedWords.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _EmptyStateCard(
                          title: 'No saved words yet',
                          message:
                              'Tap the bookmark on a word to build your saved reel.',
                          actionLabel: 'Back to profile',
                          onAction: null,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      sliver: SliverLayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.crossAxisExtent;
                          final crossAxisCount = width >= 720
                              ? 3
                              : width >= 520
                              ? 2
                              : 1;

                          return SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: crossAxisCount == 1
                                      ? 1.9
                                      : 0.78,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final savedWord = savedWords[index];
                              return _SavedWordCard(
                                savedWord: savedWord,
                                onTap: () => _openSavedWord(savedWord),
                              );
                            }, childCount: savedWords.length),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final int totalCount;
  final VoidCallback onBack;

  const _HeaderCard({required this.totalCount, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceAlt,
            AppColors.surface,
            AppColors.surfaceSoft.withAlpha(220),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBackIconButton(onPressed: onBack),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Saved Words',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withAlpha(12)),
                ),
                child: Text(
                  '$totalCount saved',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Your bookmarked words appear here as a visual gallery. Open any card for the full meaning, notes, and actions.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedWordCard extends StatelessWidget {
  final SavedWord savedWord;
  final VoidCallback onTap;

  const _SavedWordCard({required this.savedWord, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: Colors.white.withAlpha(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.card),
                        ),
                        child: savedWord.memeImageUrl.isNotEmpty
                            ? Image.network(
                                savedWord.memeImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _imageFallback(),
                              )
                            : _imageFallback(),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _pill(
                        savedWord.categoryName.isNotEmpty
                            ? savedWord.categoryName
                            : 'Saved',
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        savedWord.word,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        savedWord.meaning,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        savedWord.notes.isNotEmpty
                            ? 'Note: ${savedWord.notes}'
                            : 'No personal note added',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.surfaceSoft,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 44,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(110),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function()? onAction;

  const _EmptyStateCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Colors.white.withAlpha(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction == null
                    ? () => Navigator.of(context).pop()
                    : () {
                        onAction!();
                      },
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
