import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/pinterest_loader.dart';
import 'package:pinterest/features/auth/data/datasources/user_profile_datasource.dart';
import 'package:pinterest/features/auth/domain/entities/user_profile.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_topics_step.dart';
import 'package:pinterest/features/home/presentation/providers/home_providers.dart';
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
        builder: (_) => PreferencesPage(
          profileDatasource: ref.read(userProfileDatasourceProvider),
          onPreferencesChanged: () {
            ref.invalidate(forYouPhotosProvider);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Preferences Full Page
// ─────────────────────────────────────────────────────────

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({
    super.key,
    required this.profileDatasource,
    required this.onPreferencesChanged,
  });

  final UserProfileDatasource profileDatasource;
  final VoidCallback onPreferencesChanged;

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  late Set<String> _selectedCategories;
  late Set<String> _originalCategories;

  @override
  void initState() {
    super.initState();
    final saved = widget.profileDatasource.getSelectedTopics();
    _selectedCategories = saved.toSet();
    _originalCategories = saved.toSet();
  }

  bool get _hasChanges =>
      !_setEquals(_selectedCategories, _originalCategories);

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  void _toggle(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _applyChanges() async {
    final profile = widget.profileDatasource.getProfile();
    final updated = (profile ?? const UserProfile()).copyWith(
      selectedTopics: _selectedCategories.toList(),
    );
    await widget.profileDatasource.saveProfile(updated);
    widget.onPreferencesChanged();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimaryDark,
            size: 20.w,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          context.tr('home.yourTopPicks'),
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Apply button in the app bar (enabled only when changes exist)
          if (_hasChanges && _selectedCategories.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: _applyChanges,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.pinterestRed,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    context.tr('home.applyPreferences'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Subtitle ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            child: Text(
              context.tr('home.selectPreferencesSubtitle'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
                fontSize: 14.sp,
              ),
            ),
          ),

          // ── Selected count ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            child: Text(
              '${_selectedCategories.length} selected',
              style: TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Topics grid ──
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 0.80,
              ),
              itemCount: kTopics.length,
              itemBuilder: (context, index) {
                final topic = kTopics[index];
                final isSelected =
                    _selectedCategories.contains(topic.category);
                return _PreferenceTopicCard(
                  topic: topic,
                  isSelected: isSelected,
                  onTap: () => _toggle(topic.category),
                );
              },
            ),
          ),

          // ── Bottom Apply button ──
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed:
                    _hasChanges && _selectedCategories.isNotEmpty
                        ? _applyChanges
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pinterestRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF2A2A2A),
                  disabledForegroundColor: const Color(0xFF6A6A6A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  _hasChanges
                      ? context.tr('home.applyPreferences')
                      : context.tr('home.preferencesUpToDate'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Preference Topic Card
// ─────────────────────────────────────────────────────────

class _PreferenceTopicCard extends StatelessWidget {
  const _PreferenceTopicCard({
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  final TopicItem topic;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: isSelected
                    ? Border.all(
                        color: AppColors.pinterestRed,
                        width: 2.5,
                      )
                    : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      isSelected ? 13.r : 16.r,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: topic.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.surfaceVariantDark,
                        highlightColor: AppColors.surfaceDark,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariantDark,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariantDark,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textTertiaryDark,
                          size: 24.w,
                        ),
                      ),
                    ),
                  ),

                  // Dark overlay when selected
                  if (isSelected)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13.r),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.30),
                      ),
                    ),

                  // Checkmark circle
                  if (isSelected)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        width: 26.w,
                        height: 26.w,
                        decoration: const BoxDecoration(
                          color: AppColors.pinterestRed,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16.w,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            topic.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: isSelected
                  ? AppColors.textPrimaryDark
                  : AppColors.textSecondaryDark,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
