import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';

/// A reusable outlined text field atom matching the Pinterest login design.
///
/// The label sits **inside** the bordered container (top-left) with the
/// hint text below it — exactly like the Pinterest app. The label never
/// floats onto the border.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.borderRadius,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final String? label;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final double? borderRadius;
  final AutovalidateMode? autovalidateMode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  bool _hasFocus = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  Color get _borderColor {
    if (_errorText != null) return AppColors.pinterestRed;
    if (_hasFocus) return AppColors.textPrimaryDark;
    if (widget.controller.text.isNotEmpty) return AppColors.textPrimaryDark;
    return AppColors.textSecondaryDark;
  }

  double get _borderWidth {
    if (_hasFocus || _errorText != null) return 1.5.w;
    if (widget.controller.text.isNotEmpty) return 1.5.w;
    return 1.w;
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? 16.r;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _borderColor, width: _borderWidth),
          ),
          padding: EdgeInsets.only(
            left: 16.w,
            right: widget.suffixIcon != null ? 4.w : 16.w,
            top: widget.label != null ? 4.h : 12.h,
            bottom: widget.label != null ? 0 : 8.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Label (always visible inside the field) ──
                    if (widget.label != null)
                      Text(
                        widget.label!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontSize: 12.sp,
                        ),
                      ),
                    // ── Text input (no border — the Container provides it) ──
                    // Wrap in Theme to override the global
                    // inputDecorationTheme (which sets filled: true and
                    // an OutlineInputBorder that causes the inner curve).
                    Theme(
                      data: Theme.of(context).copyWith(
                        inputDecorationTheme: const InputDecorationTheme(
                          filled: false,
                          border: InputBorder.none,
                        ),
                      ),
                      child: TextFormField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        obscureText: widget.obscureText,
                        keyboardType: widget.keyboardType,
                        onChanged: widget.onChanged,
                        autovalidateMode: widget.autovalidateMode,
                        cursorColor: AppColors.textPrimaryDark,
                        showCursor: _hasFocus,
                        validator: (value) {
                          final error = widget.validator?.call(value);
                          // Update border color based on validation result.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _errorText != error) {
                              setState(() => _errorText = error);
                            }
                          });
                          return error;
                        },
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                          fontSize: 14.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.hint,
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textTertiaryDark,
                            fontSize: 14.sp,
                          ),
                          filled: false,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                            top: 1.h,
                            bottom: 4.h,
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 0,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.suffixIcon != null) widget.suffixIcon!,
            ],
          ),
        ),
        // ── Error text below the container ──
        if (_errorText != null) ...[
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              _errorText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.pinterestRed,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
