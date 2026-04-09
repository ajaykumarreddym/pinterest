import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';

/// Pinterest-style message input bar at the bottom of chat detail.
class ChatInput extends StatefulWidget {
  const ChatInput({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space3,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(color: AppColors.dividerDark, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.textSecondaryDark,
                size: 24.sp,
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: AppColors.dividerDark,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr('messages.typeMessage'),
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                    filled: false,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSpacing.space3,
                    ),
                  ),
                  
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.space2),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _hasText
                  ? IconButton(
                      key: const ValueKey('send'),
                      onPressed: _handleSend,
                      icon: Icon(
                        Icons.send_rounded,
                        color: AppColors.pinterestRed,
                        size: 24.sp,
                      ),
                    )
                  : IconButton(
                      key: const ValueKey('more'),
                      onPressed: () {},
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.textSecondaryDark,
                        size: 24.sp,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
