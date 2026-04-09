import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/utils/debouncer.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_card.dart';
import 'package:pinterest/features/home/presentation/widgets/shimmer_grid.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';
import 'package:pinterest/features/search/presentation/widgets/search_filter_bottom_sheet.dart';
import 'package:pinterest/features/search/presentation/widgets/search_suggestion_chips.dart';

/// Pinterest search results screen.
///
/// Shows the back arrow, search bar with query text, filter icon,
/// suggestion chips, and the masonry results grid.
class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.initialQuery,
  });

  final String initialQuery;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final TextEditingController _searchController;
  final _scrollController = ScrollController();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = widget.initialQuery;
      if (widget.initialQuery.isNotEmpty) {
        ref.read(searchPhotosProvider.notifier).search(widget.initialQuery);
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchPhotosProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    _debouncer.call(() {
      ref.read(searchPhotosProvider.notifier).search(query.trim());
    });
  }

  void _onSuggestionTap(String suggestion) {
    final currentQuery = ref.read(searchQueryProvider);
    final combinedQuery = '$currentQuery $suggestion'.trim();
    _searchController.text = combinedQuery;
    ref.read(searchQueryProvider.notifier).state = combinedQuery;
    ref.read(searchPhotosProvider.notifier).search(combinedQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchPhotosProvider);
    final currentFilter = ref.watch(searchFilterProvider);
    final query = ref.watch(searchQueryProvider);

    // Generate suggestion chips based on query
    final suggestions = _getSuggestionsForQuery(query);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with back button and filter
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space3,
              ),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimaryDark,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: AppSpacing.space3),
                  // Search input
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariantDark,
                        borderRadius: AppBorders.searchBar,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: AppSpacing.space5),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              onChanged: _onSearchChanged,
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.textPrimaryDark,
                              ),
                              
                              decoration: InputDecoration(
                                hintText:
                                    context.tr('search.searchForIdeas'),
                                hintStyle: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textTertiaryDark,
                                ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                ref
                                    .read(searchPhotosProvider.notifier)
                                    .search(value.trim());
                              },
                            ),
                          ),
                          SizedBox(width: AppSpacing.space3),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.space3),
                  // Filter icon
                  GestureDetector(
                    onTap: () => showSearchFilterBottomSheet(
                      context: context,
                      currentFilter: currentFilter,
                      onFilterSelected: (filter) {
                        ref.read(searchFilterProvider.notifier).state = filter;
                      },
                    ),
                    child: Icon(
                      Icons.tune,
                      color: AppColors.textPrimaryDark,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            // Suggestion chips
            if (suggestions.isNotEmpty) ...[
              SearchSuggestionChips(
                suggestions: suggestions,
                onTap: _onSuggestionTap,
              ),
              SizedBox(height: AppSpacing.space3),
            ],

            // Results grid
            Expanded(
              child: _buildResults(searchState, query),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(AsyncValue searchState, String query) {
    return searchState.when(
      data: (photos) {
        if (photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  color: AppColors.textTertiaryDark,
                  size: 48.sp,
                ),
                SizedBox(height: AppSpacing.space4),
                Text(
                  '${context.tr('search.noResultsFor')} "$query"',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          controller: _scrollController,
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.gridGutter,
          crossAxisSpacing: AppSpacing.gridGutter,
          padding: EdgeInsets.all(4.w),
          itemCount: photos.length,
          itemBuilder: (context, index) =>
              PinCard(photo: photos[index], heroTagPrefix: 'search'),
        );
      },
      loading: () => const ShimmerGrid(),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('errors.somethingWentWrong'),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space4),
            TextButton(
              onPressed: () =>
                  ref.read(searchPhotosProvider.notifier).search(query),
              child: Text(
                context.tr('general.retry'),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.pinterestRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SearchSuggestion> _getSuggestionsForQuery(String query) {
    final lowerQuery = query.toLowerCase();

    // Map of query keywords to suggestion data
    final suggestionMap = <String, List<SearchSuggestion>>{
      'food': [
        SearchSuggestion(
          label: 'Recipes',
          imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFFE60023),
        ),
        SearchSuggestion(
          label: 'Healthy',
          imageUrl: 'https://images.pexels.com/photos/1435904/pexels-photo-1435904.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF2D6A4F),
        ),
        SearchSuggestion(
          label: 'Pictures',
          imageUrl: 'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF3D405B),
        ),
      ],
      'drawing': [
        SearchSuggestion(
          label: 'Cute',
          imageUrl: 'https://images.pexels.com/photos/159823/kids-girl-pencil-drawing-159823.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFFE60023),
        ),
        SearchSuggestion(
          label: 'Sketches',
          imageUrl: 'https://images.pexels.com/photos/4348401/pexels-photo-4348401.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF9B59B6),
        ),
        SearchSuggestion(
          label: 'Ideas',
          imageUrl: 'https://images.pexels.com/photos/1762851/pexels-photo-1762851.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF3D405B),
        ),
        SearchSuggestion(
          label: 'Kids',
          imageUrl: 'https://images.pexels.com/photos/1148998/pexels-photo-1148998.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF2D6A4F),
        ),
      ],
    };

    // Find matching suggestions for query
    for (final entry in suggestionMap.entries) {
      if (lowerQuery.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default generic suggestions
    if (query.isNotEmpty) {
      return [
        SearchSuggestion(
          label: 'Ideas',
          imageUrl: 'https://images.pexels.com/photos/1762851/pexels-photo-1762851.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF3D405B),
        ),
        SearchSuggestion(
          label: 'Aesthetic',
          imageUrl: 'https://images.pexels.com/photos/1287145/pexels-photo-1287145.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF9B59B6),
        ),
        SearchSuggestion(
          label: 'Inspiration',
          imageUrl: 'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=100',
          color: const Color(0xFF2D6A4F),
        ),
      ];
    }

    return [];
  }
}
