import 'package:flutter/material.dart';

import '../../../models/word_Content_models.dart';
import '../../../theme/app_theme.dart';
import '../../word_sheet_details.dart';

class HomeSearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearching;
  final bool isLoadingMore;
  final bool hasSearched;
  final bool hasMore;
  final String? searchError;
  final List<ApiWord> searchResults;
  final VoidCallback onSearch;
  final VoidCallback onLoadMore;
  final VoidCallback onClear;
  final VoidCallback onClose;

  const HomeSearchSection({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearching,
    required this.isLoadingMore,
    required this.hasSearched,
    required this.hasMore,
    required this.searchError,
    required this.searchResults,
    required this.onSearch,
    required this.onLoadMore,
    required this.onClear,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.cardSmall),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Search words',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
                tooltip: 'Close search',
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Try “serendipity”',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
              ),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, _) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    color: AppColors.textSecondary,
                    onPressed: onClear,
                  );
                },
              ),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSearch,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.challengeCard,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (isSearching)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (searchError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Text(
                searchError!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            )
          else if (hasSearched && searchResults.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: const Text(
                'No words found for that search.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          else if (searchResults.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Results for “${searchController.text.trim()}”',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length + (hasMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == searchResults.length) {
                      return SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onLoadMore,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: Colors.white.withAlpha(24)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoadingMore
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Load more results'),
                        ),
                      );
                    }

                    final word = searchResults[index];
                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => WordDetailSheet(word: word),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    word.word,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    word.meaning,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
