import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pinterest-style loading indicator — 3 small dots in a triangular
/// arrangement that pulse in sequence. Use this instead of
/// CircularProgressIndicator for a pixel-perfect Pinterest look.
class PinterestLoader extends StatefulWidget {
  const PinterestLoader({
    super.key,
    this.dotSize,
    this.color,
  });

  /// Diameter of each dot. Defaults to `8.w`.
  final double? dotSize;

  /// Dot color. Defaults to a muted blue-grey.
  final Color? color;

  @override
  State<PinterestLoader> createState() => _PinterestLoaderState();
}

class _PinterestLoaderState extends State<PinterestLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.dotSize ?? 8.w;
    final color = widget.color ?? const Color(0xFF9AA0A6);
    final gap = size * 0.6;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: size * 2 + gap,
          height: size * 2 + gap,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(3, (i) {
              // Triangle positions: top-left, top-right, bottom-center
              final angle = (i * 2 * math.pi / 3) - math.pi / 2;
              final radius = size * 0.7;
              final dx = radius * math.cos(angle);
              final dy = radius * math.sin(angle);

              // Staggered pulse: each dot pulses at 1/3 offset
              final phase = ((_controller.value + i / 3) % 1.0);
              final scale = 0.6 + 0.4 * math.sin(phase * math.pi);
              final opacity = 0.4 + 0.6 * math.sin(phase * math.pi);

              return Positioned(
                left: (size * 2 + gap) / 2 + dx - size / 2,
                top: (size * 2 + gap) / 2 + dy - size / 2,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
