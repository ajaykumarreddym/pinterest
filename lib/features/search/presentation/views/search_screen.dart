import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/search/presentation/providers/search_explore_notifier.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';
import 'package:pinterest/features/search/presentation/widgets/featured_board_card.dart';
import 'package:pinterest/features/search/presentation/widgets/popular_category_section.dart';
import 'package:pinterest/features/search/presentation/widgets/taste_carousel.dart';
import 'package:pinterest/features/search/presentation/widgets/camera_search.dart';
import 'package:pinterest/router/route_names.dart';

/// Pinterest search home / explore screen.
///
/// Shows the search bar at top, "Per your taste" hero carousel,
/// "Explore featured boards" section, and "Popular on Pinterest" sections.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _navigateToResults(String query) {
    context.push(
      '${RoutePaths.searchResults}?q=${Uri.encodeComponent(query)}',
    );
  }

  Future<void> _onCameraSearch() async {
    final imagePath = await CameraSearchService.pickSearchImage(context);
    if (imagePath != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CameraSearchResultsScreen(imagePath: imagePath),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final exploreState = ref.watch(searchExploreProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar (tappable, navigates to results)
            _SearchBarTappable(
              onTap: () => _navigateToResults(''),
           
            ),
            // Explore content
            Expanded(
              child: exploreState.when(
                data: (data) => _ExploreContent(
                  data: data,
                  onCategoryTap: _navigateToResults,
                ),
                loading: () => const _ExploreShimmerLoading(),
                error: (error, _) => _ExploreError(
                  onRetry: () =>
                      ref.read(searchExploreProvider.notifier).refresh(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tappable search bar that navigates to the search results screen.
class _SearchBarTappable extends StatelessWidget {
  const _SearchBarTappable({
    required this.onTap,

  });

  final VoidCallback onTap;
 

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.space4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantDark,
            borderRadius: AppBorders.searchBar,
          ),
          child: Row(
            children: [
              SizedBox(width: AppSpacing.space5),
              Icon(
                Icons.search,
                color: AppColors.iconDefault,
                size: 22.sp,
              ),
              SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Text(
                  context.tr('search.searchForIdeas'),
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main explore content when data is loaded.
class _ExploreContent extends StatelessWidget {
  const _ExploreContent({
    required this.data,
    required this.onCategoryTap,
  });

  final SearchExploreData data;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero taste carousel
          if (data.tasteCards.isNotEmpty) ...[
            TasteCarousel(
              cards: data.tasteCards,
              onCardTap: (index) {
                onCategoryTap(data.tasteCards[index].title);
              },
            ),
            SizedBox(height: AppSpacing.space7),
          ],

          // Featured boards section
          if (data.featuredBoards.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
              child: Text(
                context.tr('search.exploreFeaturedBoards'),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
              child: Text(
                context.tr('search.bringInspiration'),
                style: AppTypography.h2.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space4),
            SizedBox(
              height: 240.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.space5),
                itemCount: data.featuredBoards.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: AppSpacing.space4),
                itemBuilder: (context, index) {
                  return FeaturedBoardCard(
                    board: data.featuredBoards[index],
                    onTap: () =>
                        onCategoryTap(data.featuredBoards[index].title),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.space7),
          ],

          // Popular on Pinterest sections
          for (final category in data.popularCategories) ...[
            PopularCategorySection(
              category: category,
              onTap: () => onCategoryTap(category.title),
            ),
            SizedBox(height: AppSpacing.space7),
          ],

          SizedBox(height: AppSpacing.space10),
        ],
      ),
    );
  }
}

/// Shimmer loading state for the explore screen.
class _ExploreShimmerLoading extends StatelessWidget {
  const _ExploreShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceDark,
        highlightColor: AppColors.surfaceVariantDark,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
              child: Container(
                height: 360.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: AppBorders.lg,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space7),
            // Section title placeholder
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
              child: Container(
                height: 14.h,
                width: 120.w,
                color: AppColors.surfaceDark,
              ),
            ),
            SizedBox(height: AppSpacing.space3),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
              child: Container(
                height: 24.h,
                width: 250.w,
                color: AppColors.surfaceDark,
              ),
            ),
            SizedBox(height: AppSpacing.space4),
            // Board cards placeholder
            SizedBox(
              height: 160.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.space5),
                itemCount: 3,
                separatorBuilder: (_, __) =>
                    SizedBox(width: AppSpacing.space4),
                itemBuilder: (_, __) => Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: AppBorders.lg,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.space7),
            // Category placeholders
            for (var i = 0; i < 3; i++) ...[
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.space5),
                child: Container(
                  height: 14.h,
                  width: 100.w,
                  color: AppColors.surfaceDark,
                ),
              ),
              SizedBox(height: AppSpacing.space3),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.space5),
                child: Container(
                  height: 20.h,
                  width: 180.w,
                  color: AppColors.surfaceDark,
                ),
              ),
              SizedBox(height: AppSpacing.space3),
              SizedBox(
                height: 130.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.space5),
                  itemCount: 4,
                  separatorBuilder: (_, __) =>
                      SizedBox(width: AppSpacing.space1),
                  itemBuilder: (_, __) => Container(
                    width: 130.w,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: AppBorders.sm,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.space7),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state for explore content.
class _ExploreError extends StatelessWidget {
  const _ExploreError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            onPressed: onRetry,
            child: Text(
              context.tr('general.retry'),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.pinterestRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
