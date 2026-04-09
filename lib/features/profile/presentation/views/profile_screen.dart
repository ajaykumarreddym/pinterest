import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/auth/presentation/providers/auth_providers.dart';
import 'package:pinterest/features/create/domain/entities/board.dart';
import 'package:pinterest/features/create/domain/entities/collage.dart';
import 'package:pinterest/features/create/presentation/providers/create_providers.dart';
import 'package:pinterest/features/create/presentation/views/create_board_screen.dart';
import 'package:pinterest/features/create/presentation/views/create_collage_screen.dart';
import 'package:pinterest/features/home/presentation/providers/saved_pins_providers.dart';
import 'package:pinterest/features/localization/presentation/extensions/localization_extension.dart';
import 'package:pinterest/features/settings/data/datasources/settings_local_datasource.dart';
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
  String _feedLayout = 'compact';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFeedLayout();
  }

  void _loadFeedLayout() {
    final saved = ref.read(settingsDatasourceProvider).getFeedLayout();
    setState(() => _feedLayout = saved);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final clerkAuth = ClerkAuth.of(context);
    final user = clerkAuth.user;
    final isGuest = !clerkAuth.isSignedIn;
    final localProfile = ref.read(userProfileDatasourceProvider).getProfile();
    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : (localProfile?.name?.isNotEmpty == true
            ? localProfile!.name!
            : (isGuest ? 'Guest' : 'User'));
    final initials = _getInitials(displayName);
    final avatarUrl = user?.imageUrl;
    final hasAvatar = user?.hasImage == true && avatarUrl != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header row: avatar + tabs
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.space5,
                AppSpacing.space5,
                AppSpacing.space5,
                0,
              ),
              child: Row(
                children: [
                  _buildAvatar(hasAvatar, avatarUrl, initials),
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.textPrimaryDark,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: AppColors.textPrimaryDark,
                      unselectedLabelColor: AppColors.textSecondaryDark,
                      labelStyle: AppTypography.labelMedium,
                      unselectedLabelStyle: AppTypography.bodyMedium,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: context.tr('profile.pins')),
                        Tab(text: context.tr('profile.boards')),
                        Tab(text: context.tr('profile.collages')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPinsTab(),
                  _buildBoardsTab(),
                  _buildCollagesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar ──

  Widget _buildAvatar(bool hasAvatar, String? avatarUrl, String initials) {
    return GestureDetector(
      onTap: () => context.push(RoutePaths.account),
      child: _buildAvatarContent(hasAvatar, avatarUrl, initials),
    );
  }

  Widget _buildAvatarContent(
    bool hasAvatar,
    String? avatarUrl,
    String initials,
  ) {
    if (hasAvatar && avatarUrl != null) {
      return CircleAvatar(
        radius: 24.r,
        backgroundColor: AppColors.surfaceVariantDark,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            width: 48.w,
            height: 48.w,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildInitialsAvatar(initials),
            errorWidget: (_, __, ___) => _buildInitialsAvatar(initials),
          ),
        ),
      );
    }
    return _buildInitialsAvatar(initials);
  }

  Widget _buildInitialsAvatar(String initials) {
    return CircleAvatar(
      radius: 24.r,
      backgroundColor: AppColors.pinterestRed,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
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

  // ── Shared Widgets ──

  Widget _buildSearchRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.space5,
        AppSpacing.space4,
        AppSpacing.space5,
        AppSpacing.space3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
              decoration: BoxDecoration(
                borderRadius: AppBorders.full,
                border: Border.all(color: AppColors.dividerDark),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: AppColors.textSecondaryDark,
                    size: 20.sp,
                  ),
                  SizedBox(width: AppSpacing.space3),
                  Text(
                    'Search your Pins',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiaryDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space4),
          Icon(Icons.add, color: AppColors.textPrimaryDark, size: 28.sp),
        ],
      ),
    );
  }

  Widget _buildChip(String label, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantDark,
        borderRadius: AppBorders.full,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.textPrimaryDark, size: 14.sp),
            SizedBox(width: AppSpacing.space2),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pins Tab ──

  Widget _buildPinsTab() {
    return Column(
      children: [
        _buildSearchRow(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showFeedLayoutSheet,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariantDark,
                    borderRadius: AppBorders.md,
                  ),
                  child: Icon(
                    Icons.grid_view,
                    color: AppColors.textPrimaryDark,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.space3),
              _buildChip(
                context.tr('profile.favourites'),
                icon: Icons.star,
              ),
              SizedBox(width: AppSpacing.space3),
              _buildChip(context.tr('profile.createdByYou')),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.space3),
        Expanded(child: _buildPinsGrid()),
      ],
    );
  }

  Widget _buildPinsGrid() {
    final savedPins = ref.watch(savedPinsProvider);
    return savedPins.when(
      data: (pins) {
        if (pins.isEmpty) {
          return Center(
            child: Text(
              'No saved pins yet',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          );
        }
        final crossAxisCount =
            _feedLayout == 'wide' ? 1 : (_feedLayout == 'standard' ? 2 : 3);
        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(AppSpacing.gridPadding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppSpacing.gridGutter,
                  mainAxisSpacing: AppSpacing.gridGutter,
                ),
                itemCount: pins.length,
                itemBuilder: (context, index) {
                  final photo = pins[index];
                  return GestureDetector(
                    onTap: () => context.push('/pin/${photo.id}'),
                    child: ClipRRect(
                      borderRadius: AppBorders.lg,
                      child: CachedNetworkImage(
                        imageUrl: photo.src.medium,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.surfaceDark),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceDark,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textTertiaryDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.space3),
              child: Text(
                '${pins.length} Pins saved',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.pinterestRed),
      ),
      error: (_, __) => Center(
        child: Text(
          'Failed to load saved pins',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  // ── Boards Tab ──

  Widget _buildBoardsTab() {
    final boards = ref.watch(boardsProvider);
    return Column(
      children: [
        _buildSearchRow(),
        Expanded(
          child: boards.isEmpty
              ? _buildBoardsEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.space3),
                  itemCount: boards.length,
                  itemBuilder: (context, index) =>
                      _BoardCard(board: boards[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildBoardsEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200.w,
              height: 200.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariantDark,
              ),
              child: Icon(
                Icons.dashboard_customize_outlined,
                size: 80.sp,
                color: AppColors.textTertiaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space7),
            Text(
              'Organise your ideas',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              'Pins are sparks of inspiration. Boards are where they live. Create boards to organise your Pins your way.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space7),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreateBoardScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinterestRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorders.full,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space7,
                  vertical: AppSpacing.space4,
                ),
              ),
              child: Text(
                'Create a board',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Collages Tab ──

  Widget _buildCollagesTab() {
    final collages = ref.watch(collagesProvider);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.space5,
            AppSpacing.space4,
            AppSpacing.space5,
            AppSpacing.space3,
          ),
          child: Row(
            children: [
              _buildChip(context.tr('profile.createdByYou')),
              SizedBox(width: AppSpacing.space3),
              _buildChip('In progress'),
            ],
          ),
        ),
        Expanded(
          child: collages.isEmpty
              ? _buildCollagesEmptyState()
              : GridView.builder(
                  padding: EdgeInsets.all(AppSpacing.gridPadding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.gridGutter,
                    mainAxisSpacing: AppSpacing.gridGutter,
                  ),
                  itemCount: collages.length,
                  itemBuilder: (context, index) =>
                      _CollageCard(collage: collages[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildCollagesEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200.w,
              height: 200.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceVariantDark,
              ),
              child: Icon(
                Icons.content_cut,
                size: 80.sp,
                color: AppColors.textTertiaryDark,
              ),
            ),
            SizedBox(height: AppSpacing.space7),
            Text(
              'Make your first collage',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space4),
            Text(
              'Snip and paste the best parts of your favourite Pins to create something completely new.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.space7),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CreateCollageScreen(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinterestRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorders.full,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.space7,
                  vertical: AppSpacing.space4,
                ),
              ),
              child: Text(
                'Create collage',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Feed Layout Bottom Sheet ──

  void _showFeedLayoutSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.space7,
                AppSpacing.space7,
                AppSpacing.space7,
                AppSpacing.space5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feed layout options',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                  SizedBox(height: AppSpacing.space5),
                  _buildLayoutOption('Wide', 'wide'),
                  SizedBox(height: AppSpacing.space5),
                  _buildLayoutOption('Standard', 'standard'),
                  SizedBox(height: AppSpacing.space5),
                  _buildLayoutOption('Compact', 'compact'),
                  SizedBox(height: AppSpacing.space7),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariantDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorders.full,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.space7,
                          vertical: AppSpacing.space3,
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutOption(String label, String value) {
    final isSelected = _feedLayout == value;
    return GestureDetector(
      onTap: () {
        setState(() => _feedLayout = value);
        ref.read(settingsDatasourceProvider).setFeedLayout(value);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check,
              color: AppColors.textPrimaryDark,
              size: 24.sp,
            ),
        ],
      ),
    );
  }
}

// ── Board Card ──

class _BoardCard extends StatelessWidget {
  const _BoardCard({required this.board});

  final Board board;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.space3),
      padding: EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantDark,
        borderRadius: AppBorders.lg,
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: AppBorders.md,
            ),
            child: board.coverImagePath.isNotEmpty
                ? ClipRRect(
                    borderRadius: AppBorders.md,
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
          SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  board.name,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSpacing.space2),
                Text(
                  '${board.pinIds.length} pins',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiaryDark,
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

// ── Collage Card ──

class _CollageCard extends StatelessWidget {
  const _CollageCard({required this.collage});

  final Collage collage;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorders.md,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.space3,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collage.title,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${collage.imagePaths.length} images',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
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
