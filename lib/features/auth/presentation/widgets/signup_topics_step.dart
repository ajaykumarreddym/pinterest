import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_button.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// A topic/interest item for the picker grid.
class TopicItem {
  const TopicItem({
    required this.label,
    required this.imageUrl,
    required this.category,
  });

  /// Display label shown below the image.
  final String label;

  /// Image URL for the card thumbnail.
  final String imageUrl;

  /// Pexels search keyword used for the "For you" feed.
  final String category;
}

/// Hard-coded topics matching the Pinterest signup screen.
const kTopics = [
  TopicItem(
    label: 'Cute greetings',
    category: 'greeting cards',
    imageUrl:
        'https://images.pexels.com/photos/1643456/pexels-photo-1643456.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Photography',
    category: 'photography',
    imageUrl:
        'https://images.pexels.com/photos/1983037/pexels-photo-1983037.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Cute animals',
    category: 'cute animals',
    imageUrl:
        'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Small spaces',
    category: 'small spaces interior',
    imageUrl:
        'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Plants',
    category: 'plants',
    imageUrl:
        'https://images.pexels.com/photos/1084199/pexels-photo-1084199.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Home renovation',
    category: 'home renovation',
    imageUrl:
        'https://images.pexels.com/photos/1457842/pexels-photo-1457842.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Classroom ideas',
    category: 'classroom education',
    imageUrl:
        'https://images.pexels.com/photos/5212345/pexels-photo-5212345.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Hair inspiration',
    category: 'hairstyle',
    imageUrl:
        'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Cars',
    category: 'cars',
    imageUrl:
        'https://images.pexels.com/photos/3752169/pexels-photo-3752169.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'DIY projects',
    category: 'diy crafts',
    imageUrl:
        'https://images.pexels.com/photos/1109197/pexels-photo-1109197.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Anime and comics',
    category: 'anime',
    imageUrl:
        'https://images.pexels.com/photos/2832382/pexels-photo-2832382.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Home décor',
    category: 'home decor',
    imageUrl:
        'https://images.pexels.com/photos/1648776/pexels-photo-1648776.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Relaxation',
    category: 'relaxation spa',
    imageUrl:
        'https://images.pexels.com/photos/3188/love-romantic-bath-candlelight.jpg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Trainers',
    category: 'sneakers shoes',
    imageUrl:
        'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Nail trends',
    category: 'nail art',
    imageUrl:
        'https://images.pexels.com/photos/3997391/pexels-photo-3997391.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Outfit ideas',
    category: 'outfit fashion',
    imageUrl:
        'https://images.pexels.com/photos/1536619/pexels-photo-1536619.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Cooking',
    category: 'cooking food',
    imageUrl:
        'https://images.pexels.com/photos/1640774/pexels-photo-1640774.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
  TopicItem(
    label: 'Workouts',
    category: 'workout fitness',
    imageUrl:
        'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=400',
  ),
];

/// Result from topic selection — contains both display images and
/// category labels for Pexels search.
class TopicSelectionResult {
  const TopicSelectionResult({
    required this.imageUrls,
    required this.categories,
  });

  /// Image URLs for the confirmation collage.
  final List<String> imageUrls;

  /// Category labels used as Pexels search queries.
  final List<String> categories;
}

/// Minimum topics a user must pick before "Next" becomes active.
const _kMinTopics = 3;

/// Signup step 5 — Topic/interest selection grid.
///
/// Shows "What are you in the mood to do?" title, subtitle,
/// a 3-column grid of topic cards, and a "Next" button (disabled
/// until at least [_kMinTopics] are selected).
class SignupTopicsStep extends StatefulWidget {
  const SignupTopicsStep({
    super.key,
    required this.onNext,
  });

  final ValueChanged<TopicSelectionResult> onNext;

  @override
  State<SignupTopicsStep> createState() => _SignupTopicsStepState();
}

class _SignupTopicsStepState extends State<SignupTopicsStep> {
  final _selected = <int>{};

  bool get _canProceed => _selected.length >= _kMinTopics;

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) {
        _selected.remove(index);
      } else {
        _selected.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.h),

        // ── Title ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            context.tr('auth.whatAreYouInTheMood'),
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 8.h),

        // ── Subtitle ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            context.tr('auth.pickTopicsSubtitle'),
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // ── Grid ──
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 0.82,
            ),
            itemCount: kTopics.length,
            itemBuilder: (context, index) {
              final topic = kTopics[index];
              final isSelected = _selected.contains(index);
              return _TopicCard(
                topic: topic,
                isSelected: isSelected,
                onTap: () => _toggle(index),
                index: index,
              );
            },
          ),
        ),

        // ── Next button ──
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: AppButton(
            label: context.tr('general.next'),
            onPressed: () {
              final imageUrls =
                  _selected.map((i) => kTopics[i].imageUrl).toList();
              final categories =
                  _selected.map((i) => kTopics[i].category).toList();
              widget.onNext(TopicSelectionResult(
                imageUrls: imageUrls,
                categories: categories,
              ));
            },
            isEnabled: _canProceed,
            backgroundColor: AppColors.pinterestRed,
            foregroundColor: AppColors.textPrimaryDark,
            disabledBackgroundColor: const Color(0xFF5F5F5F),
            disabledForegroundColor: const Color(0xFF9B9B9B),
            height: 42.h,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Topic card
// ─────────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  final TopicItem topic;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Square image ──
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedNetworkImage(
                    imageUrl: topic.imageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
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

                // ── Checkmark circle (bottom-right) ──
                if (isSelected)
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.textPrimaryDark,
                        size: 16.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // ── Label ──
          Text(
            topic.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
