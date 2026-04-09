import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/features/create/presentation/widgets/create_bottom_sheet.dart';
import 'package:pinterest/features/home/presentation/providers/home_providers.dart';
import 'package:pinterest/router/route_names.dart';

final currentTabIndexProvider = StateProvider<int>((ref) => 0);

/// Shell scaffold with Pinterest-style bottom navigation bar.
class ShellScaffold extends ConsumerWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    RoutePaths.home,
    RoutePaths.search,
    RoutePaths.create,
    RoutePaths.messages,
    RoutePaths.profile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: _PinterestBottomNav(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context, ref),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) return i;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, WidgetRef ref) {
    if (index == 2) {
      // Create tab — show bottom sheet instead of navigating
      showCreateBottomSheet(context);
      return;
    }
    final currentIndex = _calculateSelectedIndex(context);
    if (index == 0 && currentIndex == 0) {
      // Already on Home — refresh the feed
      ref.read(forYouPhotosProvider.notifier).refresh();
      return;
    }
    context.go(_tabs[index]);
  }
}

class _PinterestBottomNav extends StatelessWidget {
  const _PinterestBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(
            color: AppColors.dividerDark,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.search,
                activeIcon: Icons.search,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.add,
                activeIcon: Icons.add,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56.w,
        height: 50.h,
        child: Center(
          child: Icon(
            isActive ? activeIcon : icon,
            color: isActive
                ? AppColors.bottomNavActive
                : AppColors.bottomNavInactive,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}
