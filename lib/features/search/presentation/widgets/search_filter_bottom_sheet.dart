import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Filter type for search results.
enum SearchFilterType { allPins, videos, boards, profiles }

/// Pinterest-style "Filter by" bottom sheet with radio options.
class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  final SearchFilterType currentFilter;
  final ValueChanged<SearchFilterType> onFilterSelected;

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SearchFilterType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppBorders.bottomSheet,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.space5),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textPrimaryDark,
                      size: 24.sp,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('search.filterBy'),
                      textAlign: TextAlign.center,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                  SizedBox(width: 24.sp),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.space7),
            // Filter options
            _FilterOption(
              label: context.tr('search.allPins'),
              selected: _selected == SearchFilterType.allPins,
              onTap: () => setState(() => _selected = SearchFilterType.allPins),
            ),
            _FilterOption(
              label: context.tr('search.videos'),
              selected: _selected == SearchFilterType.videos,
              onTap: () => setState(() => _selected = SearchFilterType.videos),
            ),
            _FilterOption(
              label: context.tr('search.boards'),
              selected: _selected == SearchFilterType.boards,
              onTap: () => setState(() => _selected = SearchFilterType.boards),
            ),
            _FilterOption(
              label: context.tr('search.profiles'),
              selected: _selected == SearchFilterType.profiles,
              onTap: () =>
                  setState(() => _selected = SearchFilterType.profiles),
            ),
            SizedBox(height: AppSpacing.space7),
            // Bottom buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space5),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selected = SearchFilterType.allPins);
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariantDark,
                          borderRadius: AppBorders.full,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.tr('search.clearAll'),
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        widget.onFilterSelected(_selected);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: _selected != widget.currentFilter
                              ? AppColors.textPrimaryDark
                              : AppColors.surfaceVariantDark,
                          borderRadius: AppBorders.full,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.tr('general.confirm'),
                          style: AppTypography.labelLarge.copyWith(
                            color: _selected != widget.currentFilter
                                ? AppColors.backgroundDark
                                : AppColors.textTertiaryDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.space5),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.linkBlue
                      : AppColors.textTertiaryDark,
                  width: selected ? 7.w : 2.w,
                ),
                color: selected ? Colors.transparent : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the search filter bottom sheet.
Future<void> showSearchFilterBottomSheet({
  required BuildContext context,
  required SearchFilterType currentFilter,
  required ValueChanged<SearchFilterType> onFilterSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SearchFilterBottomSheet(
      currentFilter: currentFilter,
      onFilterSelected: onFilterSelected,
    ),
  );
}
