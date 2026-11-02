import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_models.dart';
import '../../models/quiz_models.dart';
import '../../models/word_Content_models.dart';
import '../../services/backend_api.dart';
import '../../services/recent_category_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/categories_section.dart';
import '../../widgets/recent_categories_section.dart';
import '../profile/widgets/profile_avatar_helper.dart';
import '../flash_cards_screen.dart';
import 'recent_categories_screen.dart';
import 'widget/word_of_the_day_card.dart';
import 'widget/home_bottom_nav.dart';
import 'widget/home_header.dart';
import 'widget/home_search_section.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<CategoriesSectionState> _categoriesSectionKey =
      GlobalKey<CategoriesSectionState>();
  UserProfile? _profile;
  Timer? _searchDebounceTimer;
  bool _showSearchBar = false;
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  bool _hasMore = false;
  bool _showCategoryResults = false;
  int _currentPage = 0;
  String? _searchError;
  List<ApiWord> _searchResults = [];
  List<ApiCategory> _categoryResults = [];
  List<ApiCategory> _recentCategories = [];
  bool _hasMoreCategories = false;
  int _categoryCurrentPage = 0;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _loadRecentCategories(refreshCategoryDetails: true);
  }

  Future<void> _loadRecentCategories({
    bool refreshCategoryDetails = false,
  }) async {
    try {
      final savedCategories = await RecentCategoryStore.load();
      var categories = savedCategories;
      if (refreshCategoryDetails && savedCategories.isNotEmpty) {
        try {
          final requestedIds = savedCategories
              .map((category) => category.id)
              .toSet();
          final categoriesById = <int, ApiCategory>{};
          var pageNumber = 0;
          var hasMore = true;
          while (hasMore && categoriesById.length < requestedIds.length) {
            final page = await BackendApi.instance.fetchCategoriesPage(
              page: pageNumber,
              size: 16,
            );
            for (final category in page.categories) {
              if (requestedIds.contains(category.id)) {
                categoriesById[category.id] = category;
              }
            }
            hasMore = page.hasMore && page.categories.isNotEmpty;
            pageNumber = page.currentPage + 1;
          }
          categories = savedCategories
              .map((category) => categoriesById[category.id] ?? category)
              .toList();
          await RecentCategoryStore.replace(categories);
        } catch (error, stackTrace) {
          debugPrint('Failed to refresh recent category details: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      if (mounted) {
        setState(() {
          _recentCategories = categories;
        });
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load recently explored categories: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _openCategory(ApiCategory category) async {
    try {
      await RecentCategoryStore.record(category);
      await _loadRecentCategories();
    } catch (error, stackTrace) {
      debugPrint('Failed to save recently explored category: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this recent category.')),
        );
      }
    }

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FlashCardsScreen(
          categoryId: category.id,
          categoryName: category.name,
        ),
      ),
    );
    await _loadRecentCategories();
  }

  void _showAllRecentCategories() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RecentCategoriesScreen(
          categories: _recentCategories,
          onCategoryTap: _openCategory,
        ),
      ),
    );
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await BackendApi.instance.fetchUserProfile();
      if (!mounted) {
        return;
      }

      final currentUser = _profile ?? widget.user;
      final avatarUrl = profile.avatarUrl.trim().isNotEmpty
          ? ProfileAvatarHelper.resolveAvatarUrl(profile, currentUser)
          : ProfileAvatarHelper.resolveAvatarUrl(currentUser, currentUser);
      setState(() {
        _profile = profile.copyWith(avatarUrl: avatarUrl);
      });
    } catch (_) {
      // Keep the profile passed during login visible if the refresh fails.
    }
  }

  void _applyQuizResult(QuizSubmissionResult result) {
    final currentProfile = _profile ?? widget.user;
    if (currentProfile == null) {
      return;
    }

    setState(() {
      _profile = currentProfile.copyWith(
        totalXp: result.newTotalXp,
        level: result.newLevel,
        currentStreak: result.currentStreak,
        longestStreak: result.longestStreak,
        lastQuizDate: result.lastActivityDate,
        lastActivityDate: result.lastActivityDate,
        streakUpdatedToday: result.streakUpdatedToday,
      );
    });
  }

  void _openWordOfTheDay(ApiWord word) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FlashCardsScreen(initialWord: word)),
    );
  }

  bool _handleHomeScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.depth == 0 &&
        notification.metrics.axis == Axis.vertical &&
        notification.metrics.extentAfter <= 400) {
      final categoriesState = _categoriesSectionKey.currentState;
      if (categoriesState != null) {
        unawaited(categoriesState.loadNextPage());
      }
    }
    return false;
  }

  Future<void> _performSearch({bool loadMore = false}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _hasMore = false;
        _searchError = null;
      });
      return;
    }

    if (loadMore && (!_hasMore || _isLoadingMore)) {
      return;
    }

    if (!loadMore) {
      setState(() {
        _isSearching = true;
        _isLoadingMore = false;
        _hasSearched = true;
        _searchError = null;
        _searchResults = [];
        _hasMore = false;
        _currentPage = 0;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _searchError = null;
      });
    }

    try {
      final page = loadMore ? _currentPage + 1 : 0;
      final pageResult = await BackendApi.instance.searchWords(
        query,
        page: page,
        size: 10,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (loadMore) {
          _searchResults.addAll(pageResult.words);
        } else {
          _searchResults = pageResult.words;
        }
        _hasMore = pageResult.hasMore;
        _currentPage = pageResult.currentPage;
      });

      if (_showCategoryResults && !loadMore) {
        await _performCategorySearch();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _searchError = error.toString();
        if (!loadMore) {
          _searchResults = [];
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchDebounceTimer?.cancel();
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _categoryResults = [];
      _hasSearched = false;
      _hasMore = false;
      _hasMoreCategories = false;
      _searchError = null;
    });
    _searchFocusNode.requestFocus();
  }

  Future<void> _performCategorySearch({bool loadMore = false}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _categoryResults = [];
        _hasMoreCategories = false;
        _categoryCurrentPage = 0;
      });
      return;
    }

    if (loadMore && (!_hasMoreCategories || _isLoadingMore)) {
      return;
    }

    if (!loadMore) {
      setState(() {
        _categoryResults = [];
        _categoryCurrentPage = 0;
        _hasMoreCategories = false;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final page = loadMore ? _categoryCurrentPage + 1 : 0;
      final pageResult = await BackendApi.instance.searchCategories(
        query,
        page: page,
        size: 10,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (loadMore) {
          _categoryResults.addAll(pageResult.categories);
        } else {
          _categoryResults = pageResult.categories;
        }
        _hasMoreCategories = pageResult.hasMore;
        _categoryCurrentPage = pageResult.currentPage;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _searchError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onQueryChanged(String value) {
    _searchDebounceTimer?.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _categoryResults = [];
        _hasSearched = false;
        _hasMore = false;
        _hasMoreCategories = false;
        _searchError = null;
        _isSearching = false;
        _isLoadingMore = false;
      });
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || !_showSearchBar) {
        return;
      }

      _performSearch();
    });
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
    });

    if (_showSearchBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  void _closeSearchBar() {
    setState(() {
      _showSearchBar = false;
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppThemeColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleHomeScroll,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      HomeHeader(
                        user: _profile ?? widget.user,
                        onSearchTap: _toggleSearchBar,
                        onProfileReturned: _fetchProfile,
                      ),
                      if (_showSearchBar) ...[
                        const SizedBox(height: 10),
                        HomeSearchSection(
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                          isSearching: _isSearching,
                          isLoadingMore: _isLoadingMore,
                          hasSearched: _hasSearched,
                          hasMore: _hasMore,
                          showCategoryResults: _showCategoryResults,
                          categoryResults: _categoryResults,
                          hasMoreCategories: _hasMoreCategories,
                          searchError: _searchError,
                          searchResults: _searchResults,
                          onSearch: _performSearch,
                          onQueryChanged: _onQueryChanged,
                          onLoadMore: () => _performSearch(loadMore: true),
                          onLoadMoreCategories: () =>
                              _performCategorySearch(loadMore: true),
                          onCategoryTap: _openCategory,
                          onToggleCategoryResults: (value) {
                            setState(() {
                              _showCategoryResults = value;
                            });
                            if (value) {
                              _performCategorySearch();
                            } else {
                              setState(() {
                                _categoryResults = [];
                                _hasMoreCategories = false;
                              });
                            }
                          },
                          onClear: _clearSearch,
                          onClose: _closeSearchBar,
                        ),
                        const SizedBox(height: 18),
                      ] else
                        const SizedBox(height: 4),
                      WordOfTheDayCard(onWordTap: _openWordOfTheDay),
                      const SizedBox(height: 32),
                      RecentCategoriesSection(
                        categories: _recentCategories,
                        onCategoryTap: _openCategory,
                        onSeeAll: _showAllRecentCategories,
                      ),
                      if (_recentCategories.isNotEmpty)
                        const SizedBox(height: 28),
                      CategoriesSection(
                        key: _categoriesSectionKey,
                        onCategoryTap: _openCategory,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            HomeBottomNav(
              user: _profile ?? widget.user,
              onProfileReturned: _fetchProfile,
              onQuizCompleted: _applyQuizResult,
            ),
          ],
        ),
      ),
    );
  }
}
