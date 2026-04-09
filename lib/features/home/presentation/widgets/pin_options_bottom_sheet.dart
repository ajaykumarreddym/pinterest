import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/services/media/image_download_service.dart';
import 'package:pinterest/core/services/social_share/share_service.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/presentation/providers/home_providers.dart';
import 'package:pinterest/features/home/presentation/providers/pin_filter_service.dart';
import 'package:pinterest/features/home/presentation/providers/saved_pins_providers.dart';

/// Shows the Pinterest-style bottom sheet when tapping "..." on a pin card.
void showPinOptionsBottomSheet({
  required BuildContext context,
  required Photo photo,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useRootNavigator: true,
    barrierColor: const Color(0x88000000),
    builder: (_) => _PinOptionsSheet(photo: photo),
  );
}

class _PinOptionsSheet extends ConsumerWidget {
  const _PinOptionsSheet({required this.photo});

  final Photo photo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(isPinSavedProvider(photo.id));
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // ── Sheet body
        Container(
          margin: EdgeInsets.only(top: 60.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariantDark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Space for the overlapping image
              SizedBox(height: 90.h),

              // Description text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'This Pin is inspired by your recent activity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Menu items
              _MenuItem(
                icon: Transform.rotate(
                  angle: math.pi / 4,
                  child: Icon(
                    isSaved ? Icons.push_pin : Icons.push_pin_outlined,
                    color: isSaved ? const Color(0xFFE60023) : Colors.white,
                    size: 22.sp,
                  ),
                ),
                label: isSaved ? 'Saved' : 'Save',
                onTap: () async {
                  final nowSaved = await ref
                      .read(savedPinsProvider.notifier)
                      .togglePin(photo);
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppToast.success(
                      context,
                      message: nowSaved ? 'Pin saved' : 'Pin unsaved',
                    );
                  }
                },
              ),
              _MenuItem(
                icon: Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
                label: 'Share',
                onTap: () {
                  Navigator.pop(context);
                  ref.read(shareServiceProvider).shareImage(
                        imageUrl: photo.src.medium,
                        text: photo.alt.isNotEmpty
                            ? photo.alt
                            : 'Check out this pin!',
                      );
                },
              ),
              _MenuItem(
                icon: Icon(
                  Icons.download_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
                label: 'Download image',
                onTap: () async {
                  Navigator.pop(context);
                  AppToast.info(
                    context,
                    message: 'Downloading image...',
                  );
                  final success = await ref
                      .read(imageDownloadServiceProvider)
                      .downloadAndSaveToGallery(photo.src.original);
                  if (context.mounted) {
                    if (success) {
                      AppToast.success(
                        context,
                        message: 'Image saved to gallery',
                      );
                    } else {
                      AppToast.error(
                        context,
                        message: 'Failed to download image',
                      );
                    }
                  }
                },
              ),
              _MenuItem(
                icon: Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
                label: 'See less like this',
                onTap: () async {
                  await ref
                      .read(pinFilterServiceProvider)
                      .hidePin(photo.id);
                  ref.invalidate(homePhotosProvider);
                  ref.invalidate(forYouPhotosProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppToast.info(
                      context,
                      message: 'Got it! We\'ll show less like this.',
                    );
                  }
                },
              ),
              _MenuItem(
                icon: Icon(
                  Icons.block_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
                label: 'Report Pin',
                onTap: () async {
                  await ref
                      .read(pinFilterServiceProvider)
                      .reportPin(photo.id);
                  ref.invalidate(homePhotosProvider);
                  ref.invalidate(forYouPhotosProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppToast.info(
                      context,
                      message: 'Pin reported. Thanks for letting us know.',
                    );
                  }
                },
              ),

              SizedBox(height: bottomPadding + 12.h),
            ],
          ),
        ),

        // ── Overlapping pin image thumbnail
        Positioned(
          top: 10.h,
          child: Container(
            width: 120.w,
            height: 140.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: photo.src.medium,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // ── Close (X) button at top-left of sheet
        Positioned(
          top: 60.h + 12.h,
          left: 16.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Row(
          children: [
            SizedBox(width: 28.w, child: Center(child: icon)),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
