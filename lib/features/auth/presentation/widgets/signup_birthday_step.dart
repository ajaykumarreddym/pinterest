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
    required this.email,
    required this.onNext,
    required this.onNameUpdated,
    required this.onDateChanged,
    required this.selectedDate,
  });

  final TextEditingController nameController;
  final String email;
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

  /// The prefilled name extracted from the email (part before @).
  late String _prefillName;

  /// The last-saved name value.
  String _savedName = '';

  /// Whether the name has been initially prefilled.
  bool _hasPrefilled = false;

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

    // Prefill name from email (part before @)
    _prefillName = _extractNameFromEmail(widget.email);
    if (widget.nameController.text.isEmpty && _prefillName.isNotEmpty) {
      widget.nameController.text = _prefillName;
      _savedName = _prefillName;
      _hasPrefilled = true;
    } else if (widget.nameController.text.isNotEmpty) {
      _savedName = widget.nameController.text.trim();
      _hasPrefilled = true;
    }

    widget.nameController.addListener(_onNameChanged);
  }

  /// Extracts the local part of the email before '@'.
  String _extractNameFromEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex > 0) {
      return email.substring(0, atIndex);
    }
    return email;
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

  /// Whether the name value has changed from the saved value.
  bool get _isNameChanged {
    final current = widget.nameController.text.trim();
    if (current.isEmpty) return false;
    return current != _savedName;
  }

  /// Whether the Update button should be enabled.
  bool get _isUpdateButtonEnabled => _isNameChanged;

  /// Whether the user is at least 14 years old based on selected date.
  bool get _isAgeValid {
    final now = DateTime.now();
    final birthdate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    final age = now.year - birthdate.year;
    final hasHadBirthdayThisYear = now.month > birthdate.month ||
        (now.month == birthdate.month && now.day >= birthdate.day);
    final actualAge = hasHadBirthdayThisYear ? age : age - 1;
    return actualAge >= 14;
  }

  /// Whether the Next button should be enabled.
  bool get _isNextEnabled {
    // Name must be set and age must be >= 14
    return _hasPrefilled && _savedName.isNotEmpty && _isAgeValid;
  }

  void _handleSetName() {
    final name = widget.nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _savedName = name);
    _hasPrefilled = true;
    FocusScope.of(context).unfocus();
    widget.onNameUpdated();
  }

  void _notifyDateChanged() {
    final maxDay = _daysInMonth(_selectedMonth, _selectedYear);
    if (_selectedDay > maxDay) _selectedDay = maxDay;
    widget.onDateChanged(
      DateTime(_selectedYear, _selectedMonth, _selectedDay),
    );
    // Trigger rebuild to re-evaluate age validity
    setState(() {});
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
                  onPressed: _isUpdateButtonEnabled ? _handleSetName : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinterestRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF3A3A3A),
                    disabledForegroundColor: const Color(0xFF7A7A7A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                  ),
                  child: Text(
                    context.tr('auth.updateName'),
                    style: AppTypography.labelMedium.copyWith(
                      color: _isUpdateButtonEnabled
                          ? Colors.white
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

          // ── Age warning ──
          if (!_isAgeValid)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                context.tr('auth.mustBe14OrOlder'),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.pinterestRed,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

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
            isEnabled: _isNextEnabled,
            backgroundColor: AppColors.pinterestRed,
            foregroundColor: AppColors.textPrimaryDark,
            disabledBackgroundColor: const Color(0xFF5F5F5F),
            disabledForegroundColor: const Color(0xFF9B9B9B),
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
