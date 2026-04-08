import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/features/home/presentation/providers/home_providers.dart';
import 'package:pinterest/features/home/presentation/widgets/masonry_feed.dart';
import 'package:pinterest/features/home/presentation/widgets/shimmer_grid.dart';

final _homeTabProvider = StateProvider<int>((ref) => 1);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final selectedTab = ref.watch(_homeTabProvider);
    // "All" (0) = curated, "For you" (1) = topic-based search
    final photosAsync = selectedTab == 0
        ? ref.watch(homePhotosProvider)
        : ref.watch(forYouPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header: "All" / "For you" tabs
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _HeaderTab(
                    label: context.tr('home.all'),
                    isActive: selectedTab == 0,
                    onTap: () =>
                        ref.read(_homeTabProvider.notifier).state = 0,
                  ),
                  SizedBox(width: 16.w),
                  _HeaderTab(
                    label: context.tr('home.forYou'),
                    isActive: selectedTab == 1,
                    onTap: () =>
                        ref.read(_homeTabProvider.notifier).state = 1,
                  ),
                ],
              ),
            ),

            // Feed content
            Expanded(
              child: photosAsync.when(
                data: (photos) => MasonryFeed(
                  photos: photos,
                  onLoadMore: () {
                    if (selectedTab == 0) {
                      ref.read(homePhotosProvider.notifier).loadMore();
                    } else {
                      ref.read(forYouPhotosProvider.notifier).loadMore();
                    }
                  },
                  onRefresh: () {
                    if (selectedTab == 0) {
                      return ref.read(homePhotosProvider.notifier).refresh();
                    } else {
                      return ref.read(forYouPhotosProvider.notifier).refresh();
                    }
                  },
                ),
                loading: () => const ShimmerGrid(),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: AppColors.textTertiaryDark,
                          size: 48.sp,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          context.tr('errors.somethingWentWrong'),
                          style: TextStyle(
                            color: AppColors.textSecondaryDark,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textTertiaryDark,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: () => ref.invalidate(homePhotosProvider),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pinterestRed,
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Text(
                              context.tr('general.retry'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderTab extends StatelessWidget {
  const _HeaderTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.textPrimaryDark
                  : AppColors.textTertiaryDark,
              fontSize: 16.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3.h,
            width: isActive ? 20.w : 0,
            decoration: BoxDecoration(
              color: AppColors.textPrimaryDark,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
