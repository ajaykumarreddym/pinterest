import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/ui/atoms/pinterest_loader.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/home/presentation/providers/home_providers.dart';
import 'package:pinterest/features/home/presentation/views/tune_home_feed_page.dart';
import 'package:pinterest/features/home/presentation/widgets/masonry_feed.dart';
import 'package:pinterest/features/home/presentation/widgets/shimmer_grid.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

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
    final photosAsync = ref.watch(forYouPhotosProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: "For you" + filter icon ──
            Padding(
              padding: EdgeInsets.only(
                left: 14.w,
                right: 14.w,
                top: 6.h,
                bottom: 6.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "For you" label with underline — matches Pinterest
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('home.forYou'),
                        style: TextStyle(
                          color: AppColors.textPrimaryDark,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        width: 38.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      ),
                    ],
                  ),

                  // Filter icon — rounded square with crossed sliders
                  GestureDetector(
                    onTap: () => _openPreferencesPage(context),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.auto_fix_high,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Feed content ──
            Expanded(
              child: photosAsync.when(
                skipLoadingOnRefresh: true,
                data: (photos) => Stack(
                  children: [
                    MasonryFeed(
                      photos: photos,
                      onLoadMore: () {
                        ref.read(forYouPhotosProvider.notifier).loadMore();
                      },
                      onRefresh: () {
                        return ref
                            .read(forYouPhotosProvider.notifier)
                            .refresh();
                      },
                    ),
                    // Show Pinterest loader centered during refresh
                    if (photosAsync.isRefreshing)
                      const Positioned.fill(
                        child: Center(
                          child: PinterestLoader(),
                        ),
                      ),
                  ],
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
                          onTap: () => ref.invalidate(forYouPhotosProvider),
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

  void _openPreferencesPage(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (_) => TuneHomeFeedPage(
          profileDatasource: ref.read(userProfileDatasourceProvider),
          onPreferencesChanged: () {
            ref.invalidate(forYouPhotosProvider);
          },
        ),
      ),
    );
  }
}


