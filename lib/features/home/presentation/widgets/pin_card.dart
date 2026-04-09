import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:pinterest/core/extensions/string_ext.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/presentation/widgets/pin_long_press_overlay.dart';
import 'package:pinterest/router/route_names.dart';

class PinCard extends StatefulWidget {
  const PinCard({super.key, required this.photo});

  final Photo photo;

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
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
          onTap: () {},
          iconRotation: math.pi / 4,
        ),
        PinAction(
          icon: Icons.share,
          label: 'Share',
          onTap: () {},
        ),
        PinAction(
          icon: Icons.image_search_rounded,
          label: 'Search image',
          onTap: () {},
        ),
        PinAction(
          icon: null,
          svgAsset: 'assets/icons/whatsapp.svg',
          label: 'Send on WhatsApp',
          onTap: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.photo.width / widget.photo.height;
    final cardWidth = (MediaQuery.sizeOf(context).width - 12.w) / 2;
    final cardHeight = cardWidth / aspectRatio;

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
          // Image
          Hero(
            tag: 'pin_${widget.photo.id}',
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
                  ],
                ),
              ),
            ),
          ),
          // "..." menu button outside card, bottom-right
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _onLongPress,
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
