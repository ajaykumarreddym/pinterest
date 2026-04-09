import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/create/presentation/views/create_board_screen.dart';
import 'package:pinterest/features/create/presentation/views/create_collage_screen.dart';
import 'package:pinterest/features/create/presentation/views/create_pin_screen.dart';

/// Shows the "Start creating now" bottom sheet with Pin, Collage, Board.
void showCreateBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => const _CreateSheet(),
  );
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppBorders.bottomSheet,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.space6, 0, AppSpacing.space6, AppSpacing.space5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button + Title
              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacing.space4, bottom: AppSpacing.space5,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    Text(
                      'Start creating now',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.space3),

              // Options row: Pin, Collage, Board
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CreateOption(
                    icon: Icons.push_pin_outlined,
                    label: 'Pin',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const CreatePinScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: AppSpacing.space7),
                  _CreateOption(
                    icon: Icons.auto_awesome_mosaic_outlined,
                    label: 'Collage',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const CreateCollageScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: AppSpacing.space7),
                  _CreateOption(
                    icon: Icons.dashboard_outlined,
                    label: 'Board',
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).push<void>(
                        MaterialPageRoute(
                          builder: (_) => const CreateBoardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.space5),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  const _CreateOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: AppBorders.lg,
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 28.sp,
            ),
          ),
          SizedBox(height: AppSpacing.space3),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
