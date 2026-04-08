import 'package:cached_network_image/cached_network_image.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';

/// User profile screen with Pins/Boards/Collages tabs.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Get Clerk user data (if signed in)
    final clerkAuth = ClerkAuth.of(context);
    final user = clerkAuth.user;
    final isGuest = !clerkAuth.isSignedIn;

    // Priority: Clerk API name → local profile name → fallback
    final localProfile = ref.read(userProfileDatasourceProvider).getProfile();
    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : (localProfile?.name?.isNotEmpty == true
            ? localProfile!.name!
            : (isGuest ? 'Guest' : 'User'));
    final initials = _getInitials(displayName);
    final email = user?.email ?? localProfile?.email;
    final avatarUrl = user?.imageUrl;
    final hasAvatar = user?.hasImage == true && avatarUrl != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Profile header with user info
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              child: Column(
                children: [
                  // Top row: avatar + tabs + settings
                  Row(
                    children: [
                      // Avatar
                      _buildAvatar(hasAvatar, avatarUrl, initials),
                      const Spacer(),
                      // Tab bar
                      SizedBox(
                        width: 240.w,
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: AppColors.textPrimaryDark,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelColor: AppColors.textPrimaryDark,
                          unselectedLabelColor: AppColors.textSecondaryDark,
                          labelStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: TextStyle(fontSize: 14.sp),
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(text: context.tr('profile.pins')),
                            Tab(text: context.tr('profile.boards')),
                            Tab(text: context.tr('profile.collages')),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Settings
                      IconButton(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: AppColors.textPrimaryDark,
                          size: 24.sp,
                        ),
                        onPressed: () {
                          // TODO: Navigate to settings
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // User name
                  Text(
                    displayName,
                    style: TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  if (email != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],

                  SizedBox(height: 8.h),

                  // Followers / following placeholder
                  Text(
                    '0 ${context.tr('profile.pins').toLowerCase()}',
                    style: TextStyle(
                      color: AppColors.textTertiaryDark,
                      fontSize: 12.sp,
                    ),
                  ),

                  if (isGuest) ...[
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 36.h,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref.read(authProvider.notifier).logout(
                                context: context,
                              );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.dividerDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          context.tr('auth.logIn'),
                          style: TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Filter row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantDark,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.grid_view,
                      color: AppColors.textPrimaryDark,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildChip(context.tr('profile.favourites'), Icons.star),
                  SizedBox(width: 8.w),
                  _buildChip(context.tr('profile.createdByYou'), null),
                  const Spacer(),
                  Icon(
                    Icons.add,
                    color: AppColors.textPrimaryDark,
                    size: 24.sp,
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pins tab
                  _buildPinsGrid(),
                  // Boards tab
                  Center(
                    child: Text(
                      context.tr('profile.noBoardsYet'),
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                  // Collages tab
                  Center(
                    child: Text(
                      context.tr('profile.noCollagesYet'),
                      style: const TextStyle(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool hasAvatar, String? avatarUrl, String initials) {
    if (hasAvatar && avatarUrl != null) {
      return CircleAvatar(
        radius: 32.r,
        backgroundColor: AppColors.surfaceVariantDark,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            width: 64.w,
            height: 64.w,
            fit: BoxFit.cover,
            placeholder: (_, __) => CircleAvatar(
              radius: 32.r,
              backgroundColor: AppColors.pinterestRed,
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => _buildInitialsAvatar(initials),
          ),
        ),
      );
    }
    return _buildInitialsAvatar(initials);
  }

  Widget _buildInitialsAvatar(String initials) {
    return CircleAvatar(
      radius: 32.r,
      backgroundColor: AppColors.pinterestRed,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _buildChip(String label, IconData? icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textPrimaryDark, size: 14.sp),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8.r),
          ),
        );
      },
    );
  }
}
