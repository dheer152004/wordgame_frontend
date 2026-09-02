import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/profile_models.dart';
import '../../models/word_Content_models.dart';
import '../../services/backend_api.dart';
import '../../theme/app_theme.dart';
import '../../widgets/categories_section.dart';
import '../flash_cards_screen.dart';
import 'widget/daily_challenge_card.dart';
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
  bool _hasMoreCategories = false;
  int _categoryCurrentPage = 0;

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    HomeHeader(
                      user: widget.user,
                      onSearchTap: _toggleSearchBar,
                    ),
                    if (_showSearchBar) ...[
                      const SizedBox(height: 24),
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
                        onCategoryTap: (category) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FlashCardsScreen(
                                categoryId: category.id,
                                categoryName: category.name,
                              ),
                            ),
                          );
                        },
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
                    ],
                    const DailyChallengeCard(),
                    const SizedBox(height: 24),
                    const CategoriesSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            HomeBottomNav(user: widget.user),
          ],
        ),
      ),
    );
  }
}
