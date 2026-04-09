import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_card.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';

/// Pinterest-style visual search screen.
///
/// The original image is displayed large at top. As the user scrolls,
/// it collapses into a small centered thumbnail that stays pinned,
/// and the similar images grid fills the screen.
class ImageSearchScreen extends ConsumerStatefulWidget {
  const ImageSearchScreen({super.key, required this.photo});

  final Photo photo;

  @override
  ConsumerState<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends ConsumerState<ImageSearchScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = widget.photo.alt.isNotEmpty
          ? widget.photo.alt
          : widget.photo.photographer;
      ref.read(searchPhotosProvider.notifier).search(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchPhotosProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchPhotosProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Collapsing image header
          SliverPersistentHeader(
            pinned: true,
            delegate: _CollapsingImageDelegate(
              photo: widget.photo,
              topPadding: topPadding,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),

          // ── Drag handle
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.textTertiaryDark,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),

          // ── Similar images grid
          searchState.when(
            data: (photos) {
              final filtered =
                  photos.where((p) => p.id != widget.photo.id).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No similar images found',
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4.w,
                  crossAxisSpacing: 4.w,
                  childCount: filtered.length,
                  itemBuilder: (context, index) {
                    return PinCard(photo: filtered[index]);
                  },
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: SizedBox(
                height: 200.h,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.pinterestRed,
                  ),
                ),
              ),
            ),
            error: (_, __) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Failed to load similar images',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────

/// Persistent header delegate that:
/// - Expanded: shows the full-width image with close/menu buttons
/// - Collapsed: shows a small centered rounded thumbnail
class _CollapsingImageDelegate extends SliverPersistentHeaderDelegate {
  _CollapsingImageDelegate({
    required this.photo,
    required this.topPadding,
    required this.onClose,
  });

  final Photo photo;
  final double topPadding;
  final VoidCallback onClose;

  // Collapsed: small thumbnail + safe area
  double get _collapsedHeight => topPadding + 56.h;

  // Expanded: large image area
  double get _expandedHeight => 420.h + topPadding;

  // Thumbnail size when collapsed
  static final double _thumbSize = 40.w;

  @override
  double get maxExtent => _expandedHeight;

  @override
  double get minExtent => _collapsedHeight;

  @override
  bool shouldRebuild(covariant _CollapsingImageDelegate oldDelegate) =>
      photo != oldDelegate.photo;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    // 0.0 = fully expanded, 1.0 = fully collapsed
    final t = (shrinkOffset / range).clamp(0.0, 1.0);

    final screenWidth = MediaQuery.sizeOf(context).width;

    // Interpolate image dimensions
    final imageWidth = lerpDouble(screenWidth, _thumbSize, t)!;
    final imageHeight = lerpDouble(_expandedHeight - topPadding, _thumbSize, t)!;
    final borderRadius = lerpDouble(0, _thumbSize / 2, t)!;

    // Interpolate position: from left-edge to center
    final imageLeft = lerpDouble(0, (screenWidth - _thumbSize) / 2, t)!;
    final imageTop = lerpDouble(topPadding, topPadding + 8.h, t)!;

    // Controls (close + menu) fade out as we collapse
    final controlsOpacity = (1.0 - t * 3).clamp(0.0, 1.0);

    // Down arrow fades in when collapsed
    final arrowOpacity = ((t - 0.7) / 0.3).clamp(0.0, 1.0);

    return Container(
      color: AppColors.backgroundDark,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Image (transitions from full-width to small centered thumb)
          Positioned(
            left: imageLeft,
            top: imageTop,
            width: imageWidth,
            height: imageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CachedNetworkImage(
                imageUrl: photo.src.large,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surfaceDark,
                  highlightColor: AppColors.surfaceVariantDark,
                  child: Container(color: AppColors.surfaceDark),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceDark,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),

          // ── Close button (fades out on collapse)
          if (controlsOpacity > 0)
            Positioned(
              top: topPadding + 8.h,
              left: 16.w,
              child: Opacity(
                opacity: controlsOpacity,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: const BoxDecoration(
                      color: AppColors.overlayDark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),

          // ── Menu button (fades out on collapse)
          if (controlsOpacity > 0)
            Positioned(
              top: topPadding + 8.h,
              right: 16.w,
              child: Opacity(
                opacity: controlsOpacity,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.overlayDark,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),

          // ── Down arrow (fades in on collapse, acts as back)
          if (arrowOpacity > 0)
            Positioned(
              top: topPadding + 8.h,
              left: 16.w,
              child: Opacity(
                opacity: arrowOpacity,
                child: GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textPrimaryDark,
                    size: 28.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
