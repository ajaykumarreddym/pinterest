import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/constants/asset_constants.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Signup step 6 — "Great picks!" confirmation screen.
///
/// Shows a red progress bar at the top, "Great picks!" title,
/// a card collage of the selected topic images, and the Pinterest
/// logo. Auto-navigates to home after a brief delay.
class SignupConfirmationStep extends StatefulWidget {
  const SignupConfirmationStep({
    super.key,
    required this.selectedTopicImages,
    required this.onComplete,
  });

  /// Image URLs from the topics the user selected.
  final List<String> selectedTopicImages;

  /// Called after the delay to navigate to home.
  final VoidCallback onComplete;

  @override
  State<SignupConfirmationStep> createState() =>
      _SignupConfirmationStepState();
}

class _SignupConfirmationStepState extends State<SignupConfirmationStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward().then((_) {
        if (mounted) widget.onComplete();
      });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.selectedTopicImages;
    // Pick up to 3 images for the collage (center, left peek, right peek).
    final centerImage = images.isNotEmpty ? images[0] : '';
    final leftImage = images.length > 1 ? images[1] : '';
    final rightImage = images.length > 2 ? images[2] : '';

    return Column(
      children: [
        // ── Progress bar ──
        AnimatedBuilder(
          animation: _progressController,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.pinterestRed,
              ),
              minHeight: 3.h,
            );
          },
        ),

        const Spacer(flex: 2),

        // ── Title ──
        Text(
          context.tr('auth.greatPicks'),
          style: AppTypography.h1.copyWith(
            color: AppColors.textPrimaryDark,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 32.h),

        // ── Image collage ──
        SizedBox(
          height: 300.h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Left peek image
              if (leftImage.isNotEmpty)
                Positioned(
                  left: -20.w,
                  child: Transform.rotate(
                    angle: -0.08,
                    child: _CollageImage(
                      imageUrl: leftImage,
                      width: 140.w,
                      height: 200.h,
                    ),
                  ),
                ),

              // Right peek image
              if (rightImage.isNotEmpty)
                Positioned(
                  right: -20.w,
                  child: Transform.rotate(
                    angle: 0.08,
                    child: _CollageImage(
                      imageUrl: rightImage,
                      width: 140.w,
                      height: 200.h,
                    ),
                  ),
                ),

              // Center image (on top)
              _CollageImage(
                imageUrl: centerImage,
                width: 220.w,
                height: 280.h,
              ),
            ],
          ),
        ),

        const Spacer(flex: 3),

        // ── Pinterest logo ──
        Container(
          width: 56.w,
          height: 56.w,
          decoration: const BoxDecoration(
            color: AppColors.pinterestRed,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(12.w),
          child: SvgPicture.asset(
            AssetConstants.pinterestLogo,
            colorFilter: const ColorFilter.mode(
              AppColors.textPrimaryDark,
              BlendMode.srcIn,
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }
}

class _CollageImage extends StatelessWidget {
  const _CollageImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl.isEmpty
            ? Container(color: AppColors.surfaceVariantDark)
            : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.surfaceVariantDark,
                  highlightColor: AppColors.surfaceDark,
                  child: Container(color: AppColors.surfaceVariantDark),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceVariantDark,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textTertiaryDark,
                    size: 24.w,
                  ),
                ),
              ),
      ),
    );
  }
}
