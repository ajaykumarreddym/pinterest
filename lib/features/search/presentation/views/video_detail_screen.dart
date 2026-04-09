import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/design_systems/spacing/app_spacing.dart';
import 'package:pinterest/core/design_systems/typography/app_typography.dart';
import 'package:pinterest/features/search/domain/entities/search_video.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';
import 'package:pinterest/features/search/presentation/widgets/video_result_card.dart';

/// Video detail screen showing the video thumbnail, user info,
/// and related videos in a "More like this" section.
class VideoDetailScreen extends ConsumerWidget {
  const VideoDetailScreen({super.key, required this.video});

  final SearchVideo video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedVideosProvider(video.userName));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // Video thumbnail with play overlay and back button
          SliverToBoxAdapter(
            child: _VideoHeader(video: video),
          ),

          // User info row
          SliverToBoxAdapter(
            child: _UserRow(video: video),
          ),

          // "More like this" header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
              child: Center(
                child: Text(
                  'More like this',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
          ),

          // Related videos grid
          relatedAsync.when(
            data: (relatedVideos) {
              if (relatedVideos.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'No related videos found',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.gridGutter,
                  crossAxisSpacing: AppSpacing.gridGutter,
                  childCount: relatedVideos.length,
                  itemBuilder: (context, index) {
                    final relatedVideo = relatedVideos[index];
                    return GestureDetector(
                      onTap: () => context.push(
                        '/video-detail',
                        extra: relatedVideo,
                      ),
                      child: VideoResultCard(video: relatedVideo),
                    );
                  },
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.pinterestRed,
                  ),
                ),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ),
          ),

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }
}

class _VideoHeader extends StatefulWidget {
  const _VideoHeader({required this.video});

  final SearchVideo video;

  @override
  State<_VideoHeader> createState() => _VideoHeaderState();
}

class _VideoHeaderState extends State<_VideoHeader> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  Future<void> _initVideoPlayer() async {
    final videoUrl = widget.video.bestVideoUrl;
    if (videoUrl == null) {
      setState(() => _hasError = true);
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
    );
    _controller = controller;

    try {
      await controller.initialize();
      controller.addListener(_onVideoUpdate);
      if (mounted) {
        setState(() => _isInitialized = true);
        await controller.play();
        // Hide controls after a short delay
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && controller.value.isPlaying) {
            setState(() => _showControls = false);
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
        _showControls = true;
      } else {
        controller.play();
        // Auto-hide controls after 3s
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && controller.value.isPlaying) {
            setState(() => _showControls = false);
          }
        });
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls && (_controller?.value.isPlaying ?? false)) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && (_controller?.value.isPlaying ?? false)) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32.r),
              bottomRight: Radius.circular(32.r),
            ),
            child: GestureDetector(
              onTap: _isInitialized ? _toggleControls : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video player or thumbnail fallback
                  if (_isInitialized && _controller != null)
                    AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  else if (_hasError)
                    _buildThumbnailFallback()
                  else
                    _buildLoadingState(),

                  // Play/Pause overlay
                  if (_showControls && _isInitialized)
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: AnimatedOpacity(
                        opacity: _showControls ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 64.w,
                          height: 64.w,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36.sp,
                          ),
                        ),
                      ),
                    ),

                  // Loading indicator before initialization
                  if (!_isInitialized && !_hasError)
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(12.w),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),

                  // Duration badge
                  Positioned(
                    bottom: AppSpacing.space4,
                    right: AppSpacing.space4,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _isInitialized && _controller != null
                            ? '${_formatDuration(_controller!.value.position.inSeconds)} / ${_formatDuration(widget.video.duration)}'
                            : _formatDuration(widget.video.duration),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Progress bar
                  if (_isInitialized && _controller != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _controller!,
                        allowScrubbing: true,
                        colors: const VideoProgressColors(
                          playedColor: AppColors.pinterestRed,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white10,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8.h,
          left: 12.w,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailFallback() {
    return CachedNetworkImage(
      imageUrl: widget.video.image,
      width: double.infinity,
      fit: BoxFit.fitWidth,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.surfaceDark,
        highlightColor: AppColors.surfaceVariantDark,
        child: Container(
          height: 400.h,
          color: AppColors.surfaceDark,
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        height: 400.h,
        color: AppColors.surfaceDark,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: widget.video.image,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: AppColors.surfaceDark,
            highlightColor: AppColors.surfaceVariantDark,
            child: Container(
              height: 400.h,
              color: AppColors.surfaceDark,
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            height: 400.h,
            color: AppColors.surfaceDark,
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.video});

  final SearchVideo video;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _avatarColor(video.id),
            ),
            alignment: Alignment.center,
            child: Text(
              video.userName.isNotEmpty
                  ? video.userName[0].toUpperCase()
                  : '?',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.space3),
          // Name
          Expanded(
            child: Text(
              video.userName,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Follow button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space5,
              vertical: AppSpacing.space3,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariantDark,
              borderRadius: AppBorders.full,
            ),
            child: Text(
              'Follow',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _avatarColor(int id) {
    const colors = [
      Color(0xFFE60023),
      Color(0xFF2D6A4F),
      Color(0xFF9B59B6),
      Color(0xFF1B4965),
      Color(0xFFE07A5F),
      Color(0xFF2A9D8F),
      Color(0xFF6D597A),
      Color(0xFFB56576),
    ];
    return colors[id % colors.length];
  }
}
