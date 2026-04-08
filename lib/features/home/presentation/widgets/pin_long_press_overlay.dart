import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:pinterest/core/design_systems/borders/app_borders.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';

/// Action button data for the long-press radial menu.
class PinAction {
  const PinAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.svgAsset,
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  /// If non-null, renders an SVG instead of the [icon].
  final String? svgAsset;
}

/// Shows the Pinterest-style long press overlay using [Overlay] so it
/// bypasses GoRouter's navigator entirely — no risk of "popped last page".
void showPinLongPressOverlay({
  required BuildContext context,
  required Photo photo,
  required Rect cardRect,
  required List<PinAction> actions,
}) {
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _PinLongPressOverlay(
      photo: photo,
      cardRect: cardRect,
      actions: actions,
      onDismiss: () {
        entry.remove();
      },
    ),
  );

  Overlay.of(context).insert(entry);
}

// ─────────────────────────────────────────────────────────────────

class _PinLongPressOverlay extends StatefulWidget {
  const _PinLongPressOverlay({
    required this.photo,
    required this.cardRect,
    required this.actions,
    required this.onDismiss,
  });

  final Photo photo;
  final Rect cardRect;
  final List<PinAction> actions;
  final VoidCallback onDismiss;

  @override
  State<_PinLongPressOverlay> createState() => _PinLongPressOverlayState();
}

class _PinLongPressOverlayState extends State<_PinLongPressOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _btnScaleAnim;

  int? _hoveredIndex;
  bool _isDragging = false;
  bool _dismissed = false;

  // Button metrics
  static final double _btnSize = 50.w;
  static final double _btnSizeHovered = 62.w;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _btnScaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Four buttons positioned to match real Pinterest exactly:
  ///   Pin (far-left, center)  Share (upper, center-left)
  ///                           Search (right, above center)
  ///                           Send (right, below center)
  ///
  /// Positions use card WIDTH as the unit for both X and Y spacing
  /// so the cluster stays proportional regardless of card height.
  List<Offset> _getButtonPositions() {
    final r = widget.cardRect;
    final w = r.width;
    final cy = r.center.dy;

    return [
      // Pin — far left edge, vertically centered
      Offset(r.left + w * 0.10, cy),
      // Share — upper area, about 40% from left
      Offset(r.left + w * 0.40, cy - w * 0.38),
      // Search — right of center, slightly above center
      Offset(r.left + w * 0.78, cy - w * 0.14),
      // Send/WhatsApp — right of center, below center
      Offset(r.left + w * 0.78, cy + w * 0.28),
    ];
  }

  int? _hitTest(Offset globalPos) {
    final positions = _getButtonPositions();
    for (var i = 0; i < positions.length; i++) {
      final d = (globalPos - positions[i]).distance;
      if (d <= _btnSize * 0.9) return i;
    }
    return null;
  }

  void _onPointerMove(Offset globalPos) {
    final hit = _hitTest(globalPos);
    if (hit != _hoveredIndex) {
      if (hit != null) HapticFeedback.selectionClick();
      setState(() {
        _hoveredIndex = hit;
        _isDragging = true;
      });
    }
  }

  void _onPointerUp() {
    if (_dismissed) return;
    if (_hoveredIndex != null) {
      HapticFeedback.lightImpact();
      final action = widget.actions[_hoveredIndex!];
      _safeDismiss();
      action.onTap();
    } else {
      _safeDismiss();
    }
  }

  void _safeDismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rect = widget.cardRect;

    return Listener(
      onPointerMove: (e) => _onPointerMove(e.position),
      onPointerUp: (_) => _onPointerUp(),
      behavior: HitTestBehavior.translucent,
      child: GestureDetector(
        onTap: _safeDismiss,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return SizedBox.expand(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Dimmed background
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black
                          .withValues(alpha: 0.75 * _fadeAnim.value),
                    ),
                  ),

                  // ── Pin image with subtle border glow
                  Positioned(
                    left: rect.left,
                    top: rect.top,
                    width: rect.width,
                    height: rect.height,
                    child: Opacity(
                      opacity: _fadeAnim.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: AppBorders.pinCard,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: AppBorders.pinCard,
                          child: CachedNetworkImage(
                            imageUrl: widget.photo.src.medium,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Action buttons
                  ..._buildButtons(),

                  // ── "..." more button below card center
                  _buildMoreButton(rect),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildButtons() {
    final positions = _getButtonPositions();
    final widgets = <Widget>[];

    for (var i = 0; i < widget.actions.length; i++) {
      final action = widget.actions[i];
      final pos = positions[i];
      final isHovered = _hoveredIndex == i && _isDragging;
      final size = isHovered ? _btnSizeHovered : _btnSize;

      widgets.add(
        Positioned(
          left: pos.dx - size / 2,
          top: pos.dy - size / 2,
          child: Transform.scale(
            scale: _btnScaleAnim.value,
            child: Opacity(
              opacity: _fadeAnim.value,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circle button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: isHovered
                          ? Colors.white
                          : const Color(0xFF3A3A3A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: isHovered ? 14 : 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _buildButtonIcon(
                      action,
                      isHovered: isHovered,
                    ),
                  ),

                  // Label — only visible when dragged over
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: isHovered ? 1.0 : 0.0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 120),
                      offset:
                          isHovered ? Offset.zero : const Offset(0, -0.4),
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.35),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            action.label,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _buildButtonIcon(PinAction action, {required bool isHovered}) {
    final color = isHovered ? Colors.black : Colors.white;
    final size = isHovered ? 24.sp : 20.sp;

    if (action.svgAsset != null) {
      return SvgPicture.asset(
        action.svgAsset!,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return Icon(action.icon, color: color, size: size);
  }

  Widget _buildMoreButton(Rect rect) {
    return Positioned(
      left: rect.center.dx - 18.w,
      top: rect.bottom + 10.h,
      child: Transform.scale(
        scale: _btnScaleAnim.value,
        child: Opacity(
          opacity: _fadeAnim.value,
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}
