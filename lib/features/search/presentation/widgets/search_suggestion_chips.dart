import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// A single search suggestion chip data.
class SearchSuggestion {
  const SearchSuggestion({
    required this.label,
    required this.imageUrl,
    required this.color,
  });

  final String label;
  final String imageUrl;
  final Color color;
}

/// Horizontal scrollable row of suggestion chips with thumbnails.
///
/// Replicates the Pinterest search results chip bar (e.g. "Recipes",
/// "Healthy", "Pictures") shown below the search bar.
class SearchSuggestionChips extends StatelessWidget {
  const SearchSuggestionChips({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  final List<SearchSuggestion> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => SizedBox(width: AppSpacing.space3),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return GestureDetector(
            onTap: () => onTap(suggestion.label),
            child: Container(
              decoration: BoxDecoration(
                color: suggestion.color,
                borderRadius: AppBorders.chip,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      bottomLeft: Radius.circular(20.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: suggestion.imageUrl,
                      width: 44.w,
                      height: 44.h,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 44.w,
                        height: 44.h,
                        color: suggestion.color,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                    child: Text(
                      suggestion.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
