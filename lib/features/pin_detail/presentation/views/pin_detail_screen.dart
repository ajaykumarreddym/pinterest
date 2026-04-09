import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/presentation/providers/saved_pins_providers.dart';
import 'package:pinterest/core/services/social_share/share_service.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_card.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_options_bottom_sheet.dart';
import 'package:pinterest/features/pin_detail/presentation/providers/pin_detail_providers.dart';

/// Pin detail screen showing full image, actions, and related pins.
class PinDetailScreen extends ConsumerWidget {
  const PinDetailScreen({super.key, required this.pinId});

  final String pinId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(pinId);
    if (id == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Text(
            context.tr('errors.pinNotFound'),
            style: const TextStyle(color: AppColors.textSecondaryDark),
          ),
        ),
      );
    }

    final photoAsync = ref.watch(pinDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: photoAsync.when(
        data: (photo) => _PinDetailContent(pinId: pinId, photo: photo),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.pinterestRed),
        ),
        error: (_, __) => Center(
          child: Text(
            context.tr('errors.failedToLoadPin'),
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}

/// Main content widget that displays the pin and its related photos.
class _PinDetailContent extends ConsumerWidget {
  const _PinDetailContent({required this.pinId, required this.photo});

  final String pinId;
  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch related photos based on the pin's alt text / description.
    final relatedAsync = ref.watch(
      relatedPhotosProvider((pinId: photo.id, query: photo.alt)),
    );

    return CustomScrollView(
      slivers: [
        // Image with back/share buttons
        SliverToBoxAdapter(
          child: _PinImage(pinId: pinId, photo: photo),
        ),

        // Action bar
        SliverToBoxAdapter(
          child: _ActionBar(photo: photo),
        ),

        // Photographer info + Follow
        SliverToBoxAdapter(
          child: _PhotographerRow(photo: photo),
        ),

        // Description / alt text
        if (photo.alt.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Text(
                photo.alt,
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
            ),
          ),

        // "More like this" header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
            child: Center(
              child: Text(
                context.tr('pinDetail.moreLikeThis'),
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        // Related pins masonry grid
        relatedAsync.when(
          data: (relatedPins) {
            if (relatedPins.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      context.tr('search.noResultsFor'),
                      style: TextStyle(
                        color: AppColors.textTertiaryDark,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childCount: relatedPins.length,
                itemBuilder: (context, index) {
                  return PinCard(photo: relatedPins[index], heroTagPrefix: 'related');
                },
              ),
            );
          },
          loading: () => SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.h),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.pinterestRed,
                ),
              ),
            ),
          ),
          error: (_, __) => const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          ),
        ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: 32.h)),
      ],
    );
  }
}

class _PinImage extends ConsumerWidget {
  const _PinImage({required this.pinId, required this.photo});

  final String pinId;
  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Rounded image
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
          child: Hero(
            tag: 'pin_$pinId',
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32.r),
                bottomRight: Radius.circular(32.r),
              ),
              child: CachedNetworkImage(
                imageUrl: photo.src.large,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surfaceDark,
                  highlightColor: AppColors.surfaceVariantDark,
                  child: Container(
                    height: 400.h,
                    color: AppColors.surfaceDark,
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 400.h,
                  color: AppColors.surfaceDark,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8.h,
          left: 16.w,
          child: _CircleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        // Share button
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8.h,
          right: 16.w,
          child: _CircleButton(
            icon: Icons.share_outlined,
            onTap: () {
              ref.read(shareServiceProvider).shareImage(
                    imageUrl: photo.src.medium,
                    text: photo.alt.isNotEmpty
                        ? photo.alt
                        : 'Check out this pin!',
                  );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isPinSavedProvider(photo.id));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Like / Save toggle
          _ActionIcon(
            icon: isSaved ? Icons.favorite : Icons.favorite_border,
            color: isSaved ? const Color(0xFFE60023) : null,
            onTap: () {
              ref.read(savedPinsProvider.notifier).togglePin(photo);
            },
          ),
          SizedBox(width: 20.w),
          // Share
          _ActionIcon(
            icon: Icons.share_outlined,
            onTap: () {
              ref.read(shareServiceProvider).shareImage(
                imageUrl: photo.src.medium,
                text: photo.alt.isNotEmpty
                    ? photo.alt
                    : 'Check out this pin!',
              );
            },
          ),
          SizedBox(width: 20.w),
          // More options
          _ActionIcon(
            icon: Icons.more_horiz,
            onTap: () => showPinOptionsBottomSheet(
              context: context,
              photo: photo,
            ),
          ),
          const Spacer(),
          // Save button
          GestureDetector(
            onTap: () {
              ref.read(savedPinsProvider.notifier).togglePin(photo);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                color: AppColors.pinterestRed,
                borderRadius: AppBorders.button,
              ),
              child: Text(
                context.tr('general.save'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotographerRow extends StatelessWidget {
  const _PhotographerRow({required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.surfaceVariantDark,
            child: Text(
              photo.photographer.isNotEmpty
                  ? photo.photographer[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // Name
          Expanded(
            child: Text(
              photo.photographer,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: AppColors.overlayDark,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20.sp,
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: color ?? AppColors.textPrimaryDark,
        size: 24.sp,
      ),
    );
  }
}
