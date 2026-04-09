import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/auth/data/datasources/user_profile_datasource.dart';
import 'package:pinterest/features/auth/domain/entities/user_profile.dart';
import 'package:pinterest/features/auth/presentation/widgets/signup_topics_step.dart';
import 'package:pinterest/features/home/presentation/providers/pin_filter_service.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Full-screen "Tune your home feed" page with tabbed sections:
/// Pins (Your top picks), Interests, Reported, See less.
class TuneHomeFeedPage extends ConsumerStatefulWidget {
  const TuneHomeFeedPage({
    super.key,
    required this.profileDatasource,
    required this.onPreferencesChanged,
  });

  final UserProfileDatasource profileDatasource;
  final VoidCallback onPreferencesChanged;

  @override
  ConsumerState<TuneHomeFeedPage> createState() => _TuneHomeFeedPageState();
}

class _TuneHomeFeedPageState extends ConsumerState<TuneHomeFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Set<String> _selectedCategories;
  late Set<String> _originalCategories;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final saved = widget.profileDatasource.getSelectedTopics();
    _selectedCategories = saved.toSet();
    _originalCategories = saved.toSet();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _done() async {
    if (_hasChanges && _selectedCategories.isNotEmpty) {
      final profile = widget.profileDatasource.getProfile();
      final updated = (profile ?? const UserProfile()).copyWith(
        selectedTopics: _selectedCategories.toList(),
      );
      await widget.profileDatasource.saveProfile(updated);
      widget.onPreferencesChanged();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
          context.tr('home.refineRecommendations'),
          style: TextStyle(
            color: AppColors.textPrimaryDark,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: _done,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: _hasChanges
                      ? AppColors.pinterestRed
                      : AppColors.surfaceVariantDark,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: _hasChanges
                        ? Colors.white
                        : AppColors.textSecondaryDark,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.textPrimaryDark,
          unselectedLabelColor: AppColors.textTertiaryDark,
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          indicatorColor: AppColors.textPrimaryDark,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 2.5,
          dividerColor: Colors.transparent,
          labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
          tabs: [
            Tab(text: context.tr('home.yourTopPicks')),
            Tab(text: context.tr('home.tabInterests')),
            Tab(text: context.tr('home.tabReported')),
            Tab(text: context.tr('home.tabSeeLess')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TopPicksTab(
            selectedCategories: _selectedCategories,
            onToggle: _toggle,
          ),
          _InterestsTab(
            selectedCategories: _selectedCategories,
            onToggle: _toggle,
          ),
          _ReportedTab(
            filterService: ref.read(pinFilterServiceProvider),
          ),
          _SeeLessTab(
            filterService: ref.read(pinFilterServiceProvider),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 1: Your Top Picks — topic grid with images
// ─────────────────────────────────────────────────────────

class _TopPicksTab extends StatelessWidget {
  const _TopPicksTab({
    required this.selectedCategories,
    required this.onToggle,
  });

  final Set<String> selectedCategories;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 4.h),
          child: Text(
            context.tr('home.selectPreferencesSubtitle'),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 14.sp,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
          child: Text(
            '${selectedCategories.length} selected',
            style: TextStyle(
              color: AppColors.textTertiaryDark,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
                  selectedCategories.contains(topic.category);
              return _TopicCard(
                topic: topic,
                isSelected: isSelected,
                onTap: () => onToggle(topic.category),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 2: Interests — chip/pill layout
// ─────────────────────────────────────────────────────────

class _InterestsTab extends StatelessWidget {
  const _InterestsTab({
    required this.selectedCategories,
    required this.onToggle,
  });

  final Set<String> selectedCategories;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select topics you\'re interested in to get better recommendations.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: kTopics.map((topic) {
              final isSelected =
                  selectedCategories.contains(topic.category);
              return GestureDetector(
                onTap: () => onToggle(topic.category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.pinterestRed
                        : AppColors.surfaceVariantDark,
                    borderRadius: BorderRadius.circular(24.r),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: const Color(0xFF444444),
                            width: 1,
                          ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        topic.label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimaryDark,
                          fontSize: 14.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 3: Reported — shows reported pins with images
// ─────────────────────────────────────────────────────────

class _ReportedTab extends StatelessWidget {
  const _ReportedTab({required this.filterService});

  final PinFilterService filterService;

  @override
  Widget build(BuildContext context) {
    final reportedPins = filterService.getReportedPins();

    if (reportedPins.isEmpty) {
      return _EmptyState(
        icon: Icons.flag_outlined,
        title: context.tr('home.noReportedPins'),
        description: context.tr('home.reportedPinsDesc'),
      );
    }

    final entries = reportedPins.entries.toList();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final pinId = entries[index].key;
        final imageUrl = entries[index].value;
        return _PinTile(
          pinId: pinId,
          imageUrl: imageUrl,
          label: 'Pin #$pinId reported',
          icon: Icons.block_outlined,
          trailingIcon: Icons.check_circle_outline,
          trailingColor: AppColors.pinterestRed,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab 4: See less — shows hidden pins with images
// ─────────────────────────────────────────────────────────

class _SeeLessTab extends StatelessWidget {
  const _SeeLessTab({required this.filterService});

  final PinFilterService filterService;

  @override
  Widget build(BuildContext context) {
    final hiddenPins = filterService.getHiddenPins();

    if (hiddenPins.isEmpty) {
      return _EmptyState(
        icon: Icons.visibility_off_outlined,
        title: context.tr('home.noHiddenPins'),
        description: context.tr('home.hiddenPinsDesc'),
      );
    }

    final entries = hiddenPins.entries.toList();

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final pinId = entries[index].key;
        final imageUrl = entries[index].value;
        return _PinTile(
          pinId: pinId,
          imageUrl: imageUrl,
          label: 'Pin #$pinId hidden',
          icon: Icons.visibility_off_outlined,
          trailingIcon: Icons.remove_circle_outline,
          trailingColor: AppColors.textTertiaryDark,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared pin tile with image thumbnail and navigation
// ─────────────────────────────────────────────────────────

class _PinTile extends StatelessWidget {
  const _PinTile({
    required this.pinId,
    required this.imageUrl,
    required this.label,
    required this.icon,
    required this.trailingIcon,
    required this.trailingColor,
  });

  final int pinId;
  final String imageUrl;
  final String label;
  final IconData icon;
  final IconData trailingIcon;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/pin/$pinId'),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantDark,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Pin image thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.surfaceDark,
                        highlightColor: AppColors.surfaceVariantDark,
                        child: Container(
                          width: 48.w,
                          height: 48.w,
                          color: AppColors.surfaceDark,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 48.w,
                        height: 48.w,
                        color: AppColors.surfaceDark,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiaryDark,
                          size: 20.sp,
                        ),
                      ),
                    )
                  : Container(
                      width: 48.w,
                      height: 48.w,
                      color: AppColors.surfaceDark,
                      child: Icon(
                        icon,
                        color: AppColors.textTertiaryDark,
                        size: 20.sp,
                      ),
                    ),
            ),
            SizedBox(width: 12.w),
            // Pin label
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ),
            // Trailing icon
            Icon(
              trailingIcon,
              color: trailingColor,
              size: 20.sp,
            ),
            SizedBox(width: 4.w),
            // Chevron for navigation
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiaryDark,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Empty state widget
// ─────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.textTertiaryDark,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 13.sp,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Topic Card (for Your Top Picks grid)
// ─────────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  const _TopicCard({
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
                  if (isSelected)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13.r),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.30),
                      ),
                    ),
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
