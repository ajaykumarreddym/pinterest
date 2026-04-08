import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/core/ui/atoms/app_button.dart';
import 'package:pinterest/core/ui/atoms/app_text_field.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Signup step 2 — Birthday picker with CupertinoPicker wheels.
///
/// Shows "Hey [name] ✎" greeting, "Enter your birthdate" title,
/// day/month/year picker wheels, and info text.
class SignupBirthdayStep extends StatefulWidget {
  const SignupBirthdayStep({
    super.key,
    required this.nameController,
    required this.onNext,
    required this.onNameUpdated,
    required this.onDateChanged,
    required this.selectedDate,
  });

  final TextEditingController nameController;
  final VoidCallback onNext;
  final VoidCallback onNameUpdated;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime selectedDate;

  @override
  State<SignupBirthdayStep> createState() => _SignupBirthdayStepState();
}

class _SignupBirthdayStepState extends State<SignupBirthdayStep> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  final int _startYear = 1920;
  late final int _endYear;

  /// The last-saved name value. Empty until user taps "Set".
  String _savedName = '';

  @override
  void initState() {
    super.initState();
    _endYear = DateTime.now().year;
    _selectedDay = widget.selectedDate.day;
    _selectedMonth = widget.selectedDate.month;
    _selectedYear = widget.selectedDate.year;

    _dayController =
        FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _yearController =
        FixedExtentScrollController(initialItem: _selectedYear - _startYear);

    widget.nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onNameChanged);
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onNameChanged() => setState(() {});

  /// Whether the name has been set at least once.
  bool get _hasBeenSet => _savedName.isNotEmpty;

  /// Whether the button should be enabled.
  bool get _isButtonEnabled {
    final current = widget.nameController.text.trim();
    if (current.isEmpty) return false;
    return current != _savedName;
  }

  void _handleSetName() {
    final name = widget.nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _savedName = name);
    FocusScope.of(context).unfocus();
    widget.onNameUpdated();
  }

  void _notifyDateChanged() {
    final maxDay = _daysInMonth(_selectedMonth, _selectedYear);
    if (_selectedDay > maxDay) _selectedDay = maxDay;
    widget.onDateChanged(
      DateTime(_selectedYear, _selectedMonth, _selectedDay),
    );
  }

  int _daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          // ── Name field + Update button ──
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: widget.nameController,
                  hint: context.tr('auth.enterYourNameHere'),
                  borderRadius: 16.r,
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _handleSetName : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F5F5F),
                    foregroundColor: AppColors.textPrimaryDark,
                    disabledBackgroundColor: const Color(0xFF3A3A3A),
                    disabledForegroundColor: const Color(0xFF7A7A7A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  child: Text(
                    _hasBeenSet
                        ? context.tr('auth.updateName')
                        : context.tr('auth.set'),
                    style: AppTypography.labelMedium.copyWith(
                      color: _isButtonEnabled
                          ? AppColors.textPrimaryDark
                          : const Color(0xFF7A7A7A),
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // ── Title ──
          Text(
            context.tr('auth.enterYourBirthdate'),
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),

          // ── Date picker wheels ──
          SizedBox(
            height: 200.h,
            child: Row(
              children: [
                // Day
                Expanded(child: _buildWheel(_dayWheel())),
                // Month
                Expanded(flex: 2, child: _buildWheel(_monthWheel())),
                // Year
                Expanded(child: _buildWheel(_yearWheel())),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // ── Info text ──
          Text(
            context.tr('auth.birthdateInfoTitle'),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            context.tr('auth.birthdateInfoSubtitle'),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiaryDark,
              fontSize: 13.sp,
            ),
          ),

          const Spacer(),

          // ── Next button ──
          AppButton(
            label: context.tr('general.next'),
            onPressed: widget.onNext,
            backgroundColor: AppColors.pinterestRed,
            foregroundColor: AppColors.textPrimaryDark,
            height: 42.h,
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildWheel(Widget child) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          pickerTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textPrimaryDark,
            fontSize: 18.sp,
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _dayWheel() {
    final maxDay = _daysInMonth(_selectedMonth, _selectedYear);

    return CupertinoPicker(
      scrollController: _dayController,
      itemExtent: 40.h,
      selectionOverlay: _selectionOverlay(),
      onSelectedItemChanged: (index) {
        setState(() => _selectedDay = index + 1);
        _notifyDateChanged();
      },
      children: List.generate(maxDay, (i) => _pickerItem('${i + 1}')),
    );
  }

  Widget _monthWheel() {
    return CupertinoPicker(
      scrollController: _monthController,
      itemExtent: 40.h,
      selectionOverlay: _selectionOverlay(),
      onSelectedItemChanged: (index) {
        setState(() => _selectedMonth = index + 1);
        _notifyDateChanged();
      },
      children: _months.map(_pickerItem).toList(),
    );
  }

  Widget _yearWheel() {
    final yearCount = _endYear - _startYear + 1;

    return CupertinoPicker(
      scrollController: _yearController,
      itemExtent: 40.h,
      selectionOverlay: _selectionOverlay(),
      onSelectedItemChanged: (index) {
        setState(() => _selectedYear = _startYear + index);
        _notifyDateChanged();
      },
      children: List.generate(
        yearCount,
        (i) => _pickerItem('${_startYear + i}'),
      ),
    );
  }

  Widget _selectionOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textTertiaryDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }

  Widget _pickerItem(String text) {
    return Center(
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimaryDark,
          fontSize: 18.sp,
        ),
      ),
    );
  }
}
