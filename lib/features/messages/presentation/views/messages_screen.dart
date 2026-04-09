import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/messages/presentation/providers/messages_providers.dart';
import 'package:pinterest/features/messages/presentation/widgets/messages_tab.dart';
import 'package:pinterest/features/messages/presentation/widgets/updates_tab.dart';

/// Inbox screen with Updates and Messages tabs (Pinterest-style).
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(inboxTabIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(context, ref, activeTab),
            Expanded(
              child: IndexedStack(
                index: activeTab,
                children: const [
                  UpdatesTab(),
                  MessagesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, WidgetRef ref, int activeTab) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space5,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        children: [
          _TabButton(
            label: context.tr('messages.updatesTab'),
            isActive: activeTab == 0,
            onTap: () =>
                ref.read(inboxTabIndexProvider.notifier).state = 0,
          ),
          SizedBox(width: AppSpacing.space3),
          _TabButton(
            label: context.tr('messages.messagesTab'),
            isActive: activeTab == 1,
            onTap: () =>
                ref.read(inboxTabIndexProvider.notifier).state = 1,
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // Filter / settings placeholder
            },
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppColors.textPrimaryDark,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pinterest-style pill tab button.
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.space5,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.textPrimaryDark
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isActive
                ? AppColors.backgroundDark
                : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }
}
