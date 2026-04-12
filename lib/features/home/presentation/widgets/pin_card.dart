import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/extensions/string_ext.dart';
import 'package:pinterest/core/services/social_share/share_service.dart';
import 'package:pinterest/core/ui/atoms/app_toast.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/presentation/providers/saved_pins_providers.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_long_press_overlay.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_options_bottom_sheet.dart';
import 'package:pinterest/router/route_names.dart';

class PinCard extends ConsumerStatefulWidget {
  const PinCard({super.key, required this.photo, this.heroTagPrefix = 'pin'});

  final Photo photo;
  final String heroTagPrefix;

  @override
  ConsumerState<PinCard> createState() => _PinCardState();
}

class _PinCardState extends ConsumerState<PinCard> {
  final _imageKey = GlobalKey();

  void _onLongPress([Offset? globalPressPosition]) {
    HapticFeedback.mediumImpact();

    final renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final cardRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );

    final pressPos = globalPressPosition ??
        Offset(position.dx + size.width / 2, position.dy + size.height / 2);

    showPinLongPressOverlay(
      context: context,
      photo: widget.photo,
      cardRect: cardRect,
      pressPosition: pressPos,
      actions: [
        PinAction(
          icon: Icons.push_pin_outlined,
          label: 'Save',
          onTap: () async {
            final nowSaved = await ref
                .read(savedPinsProvider.notifier)
                .togglePin(widget.photo);
            if (mounted) {
              AppToast.success(
                context,
                message: nowSaved ? 'Pin saved' : 'Pin unsaved',
              );
            }
          },
          iconRotation: math.pi / 4,
        ),
        PinAction(
          icon: Icons.share,
          label: 'Share',
          onTap: () {
            ref.read(shareServiceProvider).shareImage(
                  imageUrl: widget.photo.src.medium,
                  text: widget.photo.alt.isNotEmpty
                      ? widget.photo.alt
                      : 'Check out this pin!',
                );
          },
        ),
        PinAction(
          icon: Icons.image_search_rounded,
          label: 'Search image',
          onTap: () {
            context.push(RoutePaths.imageSearch, extra: widget.photo);
          },
        ),
        PinAction(
          icon: null,
          svgAsset: 'assets/icons/whatsapp.svg',
          label: 'Send on WhatsApp',
          onTap: () {
            final text = widget.photo.alt.isNotEmpty
                ? widget.photo.alt
                : 'Check out this pin!';
            final url = widget.photo.url;
            final whatsappUrl = Uri.parse(
              'https://wa.me/?text=${Uri.encodeComponent('$text\n$url')}',
            );
            launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.photo.width / widget.photo.height;
    final cardWidth = (MediaQuery.sizeOf(context).width - 12.w) / 2;
    final cardHeight = cardWidth / aspectRatio;
    final isSaved = ref.watch(isPinSavedProvider(widget.photo.id));

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteNames.pinDetail,
          pathParameters: {'id': widget.photo.id.toString()},
        );
      },
      onLongPressStart: (details) => _onLongPress(details.globalPosition),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlays
          Hero(
            tag: '${widget.heroTagPrefix}_${widget.photo.id}',
            child: ClipRRect(
              borderRadius: AppBorders.pinCard,
              child: SizedBox(
                key: _imageKey,
                height: cardHeight.clamp(150.h, 350.h),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.photo.src.medium,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: widget.photo.avgColor.toColor(),
                        highlightColor:
                            widget.photo.avgColor.toColor().withValues(alpha: 0.5),
                        child: Container(
                          color: widget.photo.avgColor.toColor(),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceDark,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.iconDefault,
                        ),
                      ),
                      fadeInDuration: const Duration(milliseconds: 200),
                    ),
                    // Save button overlay — top right
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: GestureDetector(
                        onTap: () async {
                          final nowSaved = await ref
                              .read(savedPinsProvider.notifier)
                              .togglePin(widget.photo);
                          if (mounted) {
                            AppToast.success(
                              context,
                              message: nowSaved ? 'Pin saved' : 'Pin unsaved',
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSaved
                                ? AppColors.backgroundDark.withValues(alpha: 0.7)
                                : AppColors.pinterestRed,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            isSaved ? 'Saved' : 'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Photographer overlay — bottom left
                    if (widget.photo.photographer.isNotEmpty)
                      Positioned(
                        bottom: 8.h,
                        left: 8.w,
                        right: 36.w,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 10.r,
                              backgroundColor:
                                  AppColors.surfaceVariantDark,
                              child: Text(
                                widget.photo.photographer[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                widget.photo.photographer,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // "..." menu button outside card, bottom-right
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => showPinOptionsBottomSheet(
                context: context,
                photo: widget.photo,
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 4.h, right: 2.w),
                child: Icon(
                  Icons.more_horiz,
                  color: AppColors.textSecondaryDark,
                  size: 18.sp,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
