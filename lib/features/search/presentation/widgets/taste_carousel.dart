import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Data for one "Per your taste" carousel page.
class TasteCard {
  const TasteCard({
    required this.title,
    required this.imageUrl,
    this.creatorName,
    this.creatorAvatarUrl,
  });

  final String title;
  final String imageUrl;
  final String? creatorName;
  final String? creatorAvatarUrl;
}

/// Full-width "Per your taste" hero carousel with page indicator dots.
class TasteCarousel extends StatefulWidget {
  const TasteCarousel({
    super.key,
    required this.cards,
    this.onCardTap,
  });

  final List<TasteCard> cards;
  final ValueChanged<int>? onCardTap;

  @override
  State<TasteCarousel> createState() => _TasteCarouselState();
}

class _TasteCarouselState extends State<TasteCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Carousel
        SizedBox(
          height: 360.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return GestureDetector(
                onTap: () => widget.onCardTap?.call(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.space2),
                  child: ClipRRect(
                    borderRadius: AppBorders.lg,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        CachedNetworkImage(
                          imageUrl: card.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Shimmer.fromColors(
                            baseColor: AppColors.surfaceDark,
                            highlightColor: AppColors.surfaceVariantDark,
                            child: Container(color: AppColors.surfaceDark),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceVariantDark,
                          ),
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                        // Content overlay
                        Positioned(
                          left: AppSpacing.space5,
                          right: AppSpacing.space5,
                          bottom: AppSpacing.space7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr('search.perYourTaste'),
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                              SizedBox(height: AppSpacing.space1),
                              Text(
                                card.title,
                                style: AppTypography.h2.copyWith(
                                  color: AppColors.textPrimaryDark,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Creator avatar
                        if (card.creatorAvatarUrl != null)
                          Positioned(
                            left: AppSpacing.space5,
                            bottom: AppSpacing.space5,
                            child: CircleAvatar(
                              radius: 16.r,
                              backgroundImage: CachedNetworkImageProvider(
                                card.creatorAvatarUrl!,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppSpacing.space4),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cards.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isActive ? 8.w : 6.w,
              height: isActive ? 8.w : 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.textPrimaryDark
                    : AppColors.textTertiaryDark,
              ),
            );
          }),
        ),
      ],
    );
  }
}
