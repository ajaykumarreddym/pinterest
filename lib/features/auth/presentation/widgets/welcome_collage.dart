import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinterest/core/design_systems/colors/app_colors.dart';
import 'package:shimmer/shimmer.dart';

/// The image collage displayed on the Pinterest Welcome/Landing screen.
///
/// Recreates the exact Pinterest layout: two side columns with images
/// peeking from edges and a large elevated center card.
///
/// Each image has a subtle continuous "breathing" (scale pulse) animation.
/// The center image starts first, then others follow with staggered delays.
class WelcomeCollage extends StatefulWidget {
  const WelcomeCollage({super.key});

  @override
  State<WelcomeCollage> createState() => _WelcomeCollageState();
}

class _WelcomeCollageState extends State<WelcomeCollage>
    with TickerProviderStateMixin {
  // Curated images matching Pinterest's welcome screen aesthetic.
  static const _imgInterior =
      'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=400';
  static const _imgSneakers =
      'https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg?auto=compress&cs=tinysrgb&w=400';
  static const _imgFashion =
      'https://images.pexels.com/photos/2887766/pexels-photo-2887766.jpeg?auto=compress&cs=tinysrgb&w=600';
  static const _imgPortrait =
      'https://images.pexels.com/photos/5906919/pexels-photo-5906919.jpeg?auto=compress&cs=tinysrgb&w=600';
  static const _imgFood =
      'https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?auto=compress&cs=tinysrgb&w=400';
  static const _imgDecor =
      'https://images.pexels.com/photos/6707628/pexels-photo-6707628.jpeg?auto=compress&cs=tinysrgb&w=400';

  static const _imageCount = 6;
  static const _breathDuration = Duration(milliseconds: 1300);
  static const _staggerDelay = Duration(milliseconds: 200);

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scales;

  // Image indices: 0=interior, 1=food, 2=sneakers, 3=portrait, 4=decor, 5=center
  // Start order: center first, then spreading outward.
  static const _startOrder = [5, 3, 0, 2, 1, 4];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _imageCount,
      (_) => AnimationController(vsync: this, duration: _breathDuration),
    );
    _scales = _controllers
        .map(
          (c) => Tween<double>(begin: 1.0, end: 1.04).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
        )
        .toList();

    _startStaggered();
  }

  Future<void> _startStaggered() async {
    for (final idx in _startOrder) {
      _controllers[idx].repeat(reverse: true);
      await Future.delayed(_staggerDelay);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final gap = 8.w;
        final r = 16.r;

        // Column widths (side columns ~28%, center ~60%)
        final centerW = w * 0.55;
        final centerLeft = w * 0.20;

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── LEFT COLUMN ──

            // Top-left: interior room — 40% width, visible from top
            Positioned(
              left: 0,
              top: 0,
              width: w * 0.40,
              height: h * 0.42,
              child: _BreathingImage(
                scale: _scales[0],
                child: _CollageImage(
                  url: _imgInterior,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(r),
                  ),
                ),
              ),
            ),

            // Bottom-left: food — 20% vertical gap from room image
            Positioned(
              left: 0,
              top: h * 0.58,
              width: w * 0.35,
              height: h * 0.40,
              child: _BreathingImage(
                scale: _scales[1],
                child: _CollageImage(
                  url: _imgFood,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(r),
                    bottomRight: Radius.circular(r),
                  ),
                ),
              ),
            ),

            // ── RIGHT COLUMN ──

            // Top-right: sneakers — bleeds top & right edges
            Positioned(
              right: 0,
              top: -30,
              width: w * 0.40,
              height: h * 0.22,
              child: _BreathingImage(
                scale: _scales[2],
                child: _CollageImage(
                  url: _imgSneakers,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(r),
                  ),
                ),
              ),
            ),

            // Mid-right: beauty portrait — bleeds right edge
            Positioned(
              right: 40,
              top: h * 0.22 + gap * 10,
              width: w * 0.30,
              height: h * 0.25,
              child: _BreathingImage(
                scale: _scales[3],
                child: _CollageImage(
                  url: _imgPortrait,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(r),
                    bottomLeft: Radius.circular(r),
                    bottomRight: Radius.circular(r),
                    topRight: Radius.circular(r),
                  ),
                ),
              ),
            ),

            // Bottom-right: decor/vases — bleeds right edge
            Positioned(
              right: 0,
              top: h * 0.56 + gap * 10,
              width: w * 0.30,
              height: h * 0.20,
              child: _BreathingImage(
                scale: _scales[4],
                child: _CollageImage(
                  url: _imgDecor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(r),
                    bottomLeft: Radius.circular(r),
                  ),
                ),
              ),
            ),

            // ── CENTER CARD (hero, elevated with white card backing) ──
            Positioned(
              left: centerLeft,
              top: h * 0.20,
              width: centerW + 5,
              height: h * 0.58,
              child: _BreathingImage(
                scale: _scales[5],
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _CollageImage(
                    url: _imgFashion,
                    borderRadius: BorderRadius.circular(17.r),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Wraps a child with a continuous scale (breathing) animation.
class _BreathingImage extends StatelessWidget {
  const _BreathingImage({required this.scale, required this.child});

  final Animation<double> scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: scale, child: child);
  }
}

class _CollageImage extends StatelessWidget {
  const _CollageImage({required this.url, required this.borderRadius});

  final String url;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: AppColors.surfaceDark,
          highlightColor: AppColors.surfaceVariantDark,
          child: Container(color: AppColors.surfaceDark),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceVariantDark,
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textTertiaryDark,
            size: 32.w,
          ),
        ),
      ),
    );
  }
}
