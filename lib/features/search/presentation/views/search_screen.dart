import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/utils/debouncer.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_card.dart';
import 'package:pinterest/features/home/presentation/widgets/shimmer_grid.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';

/// Search/Explore screen with live search via Pexels API.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));
  final _focusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(searchPhotosProvider.notifier).search('');
    _focusNode.unfocus();
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
    super.build(context);

    final query = ref.watch(searchQueryProvider);
    final searchState = ref.watch(searchPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantDark,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.search,
                      color: AppColors.iconDefault,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: _onSearchChanged,
                        style: TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 16.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr('search.searchForIdeas'),
                          hintStyle: TextStyle(
                            color: AppColors.textTertiaryDark,
                            fontSize: 16.sp,
                          ),
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
                    if (query.isNotEmpty)
                      GestureDetector(
                        onTap: _clearSearch,
                        child: Icon(
                          Icons.close,
                          color: AppColors.iconDefault,
                          size: 20.sp,
                        ),
                      )
                    else
                      Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.iconDefault,
                        size: 22.sp,
                      ),
                    SizedBox(width: 16.w),
                  ],
                ),
              ),
            ),

            // Results
            Expanded(child: _buildBody(query, searchState)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(String query, AsyncValue searchState) {
    // Empty state — show explore categories
    if (query.isEmpty) {
      return _buildExploreContent();
    }

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
                SizedBox(height: 12.h),
                Text(
                  '${context.tr('search.noResultsFor')} "$query"',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return MasonryGridView.count(
          controller: _scrollController,
          crossAxisCount: 2,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          padding: EdgeInsets.all(4.w),
          itemCount: photos.length,
          itemBuilder: (context, index) => PinCard(photo: photos[index], heroTagPrefix: 'search'),
        );
      },
      loading: () => const ShimmerGrid(),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('errors.somethingWentWrong'),
              style: TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => ref
                  .read(searchPhotosProvider.notifier)
                  .search(query),
              child: Text(
                context.tr('general.retry'),
                style: TextStyle(
                  color: AppColors.pinterestRed,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreContent() {
    final categories = [
      _Category(context.tr('categories.wallpapers'), Color(0xFF1B3A4B)),
      _Category(context.tr('categories.nature'), Color(0xFF2D6A4F)),
      _Category(context.tr('categories.architecture'), Color(0xFF3D405B)),
      _Category(context.tr('categories.travel'), Color(0xFFE07A5F)),
      _Category(context.tr('categories.fashion'), Color(0xFF81B29A)),
      _Category(context.tr('categories.food'), Color(0xFFF2CC8F)),
      _Category(context.tr('categories.animals'), Color(0xFF6D597A)),
      _Category(context.tr('categories.art'), Color(0xFFBC4749)),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              context.tr('search.ideasForYou'),
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return GestureDetector(
                onTap: () {
                  _searchController.text = cat.name;
                  _onSearchChanged(cat.name);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cat.color,
                        cat.color.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.all(12.w),
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Category {
  const _Category(this.name, this.color);
  final String name;
  final Color color;
}
