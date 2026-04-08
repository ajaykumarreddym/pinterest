import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_button.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// A list of common countries for the country selector.
const _kCountries = [
  'Afghanistan',
  'Argentina',
  'Australia',
  'Bangladesh',
  'Brazil',
  'Canada',
  'China',
  'Egypt',
  'France',
  'Germany',
  'India',
  'Indonesia',
  'Italy',
  'Japan',
  'Kenya',
  'Malaysia',
  'Mexico',
  'Netherlands',
  'Nigeria',
  'Pakistan',
  'Philippines',
  'Russia',
  'Saudi Arabia',
  'Singapore',
  'South Africa',
  'South Korea',
  'Spain',
  'Sri Lanka',
  'Thailand',
  'Turkey',
  'United Arab Emirates',
  'United Kingdom',
  'United States',
  'Vietnam',
];

/// Signup step 4 — Country/region selection.
///
/// Shows "What is your country or region?" title, subtitle,
/// a tappable country row with chevron, and a "Next" button.
class SignupCountryStep extends StatefulWidget {
  const SignupCountryStep({
    super.key,
    required this.onNext,
  });

  final ValueChanged<String> onNext;

  @override
  State<SignupCountryStep> createState() => _SignupCountryStepState();
}

class _SignupCountryStepState extends State<SignupCountryStep> {
  String _selectedCountry = 'India';

  void _showCountryPicker() {
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      isScrollControlled: true,
      builder: (_) => _CountryPickerSheet(
        selected: _selectedCountry,
        onSelected: (country) {
          setState(() => _selectedCountry = country);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16.h),

          // ── Title ──
          Text(
            context.tr('auth.whatsYourCountry'),
            textAlign: TextAlign.center,
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),

          // ── Subtitle ──
          Text(
            context.tr('auth.countrySubtitle'),
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 32.h),

          // ── Country row ──
          GestureDetector(
            onTap: _showCountryPicker,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Text(
                    _selectedCountry,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textPrimaryDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondaryDark,
                    size: 24.w,
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // ── Next button ──
          AppButton(
            label: context.tr('general.next'),
            onPressed: () => widget.onNext(_selectedCountry),
            backgroundColor: AppColors.pinterestRed,
            foregroundColor: AppColors.textPrimaryDark,
            height: 42.h,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Country picker bottom sheet
// ─────────────────────────────────────────────────────────
class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  String _query = '';

  List<String> get _filtered => _query.isEmpty
      ? _kCountries
      : _kCountries
            .where(
              (c) => c.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            SizedBox(height: 16.h),
            // ── Search field ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                cursorColor: AppColors.textPrimaryDark,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Search country',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiaryDark,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textTertiaryDark,
                    size: 20.w,
                  ),
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // ── Country list ──
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  final isSelected = country == widget.selected;
                  return ListTile(
                    title: Text(
                      country,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: AppColors.pinterestRed,
                            size: 20.w,
                          )
                        : null,
                    onTap: () => widget.onSelected(country),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
