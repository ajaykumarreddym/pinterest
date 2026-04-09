import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/create/domain/entities/board.dart';
import 'package:pinterest/features/create/domain/entities/collage.dart';
import 'package:pinterest/features/create/presentation/providers/create_providers.dart';
import 'package:pinterest/features/home/presentation/providers/saved_pins_providers.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/router/route_names.dart';

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
                  _buildPinCount(),

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
                  _buildBoardsGrid(),
                  // Collages tab
                  _buildCollagesGrid(),
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

  Widget _buildPinCount() {
    final savedPins = ref.watch(savedPinsProvider);
    final count = savedPins.valueOrNull?.length ?? 0;
    return Text(
      '$count ${context.tr('profile.pins').toLowerCase()}',
      style: TextStyle(
        color: AppColors.textTertiaryDark,
        fontSize: 12.sp,
      ),
    );
  }

  Widget _buildPinsGrid() {
    final savedPins = ref.watch(savedPinsProvider);
    return savedPins.when(
      data: (pins) {
        if (pins.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.push_pin_outlined,
                  color: AppColors.textTertiaryDark,
                  size: 48.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No saved pins yet',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Save pins to see them here',
                  style: TextStyle(
                    color: AppColors.textTertiaryDark,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(4.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
          ),
          itemCount: pins.length,
          itemBuilder: (context, index) {
            final photo = pins[index];
            return GestureDetector(
              onTap: () {
                context.push('${RoutePaths.pinDetail}/${photo.id}');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: photo.src.small,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.surfaceDark,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.surfaceDark,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.pinterestRed,
        ),
      ),
      error: (_, __) => Center(
        child: Text(
          'Failed to load saved pins',
          style: TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBoardsGrid() {
    final boards = ref.watch(boardsProvider);
    if (boards.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.dashboard_outlined,
        title: context.tr('profile.noBoardsYet'),
        subtitle: 'Create boards to organize your pins',
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(8.w),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        return _BoardCard(board: board);
      },
    );
  }

  Widget _buildCollagesGrid() {
    final collages = ref.watch(collagesProvider);
    if (collages.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.auto_awesome_mosaic_outlined,
        title: context.tr('profile.noCollagesYet'),
        subtitle: 'Create collages from your images',
      );
    }
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
      ),
      itemCount: collages.length,
      itemBuilder: (context, index) {
        final collage = collages[index];
        return _CollageCard(collage: collage);
      },
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textTertiaryDark, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textTertiaryDark,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.board});

  final Board board;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantDark,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Cover thumbnail
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: board.coverImagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      File(board.coverImagePath),
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.dashboard_outlined,
                    color: AppColors.textTertiaryDark,
                    size: 24.sp,
                  ),
          ),
          SizedBox(width: 12.w),
          // Board info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  board.name,
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${board.pinIds.length} pins',
                  style: TextStyle(
                    color: AppColors.textTertiaryDark,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollageCard extends StatelessWidget {
  const _CollageCard({required this.collage});

  final Collage collage;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (collage.imagePaths.isNotEmpty)
            Image.file(
              File(collage.imagePaths.first),
              fit: BoxFit.cover,
            )
          else
            Container(color: AppColors.surfaceDark),
          // Overlay with title + count
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collage.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${collage.imagePaths.length} images',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
