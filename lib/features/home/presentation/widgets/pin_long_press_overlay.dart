import 'dart:math' as math;

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
    this.iconRotation,
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  /// If non-null, renders an SVG instead of the [icon].
  final String? svgAsset;

  /// Optional rotation in radians applied to the icon.
  final double? iconRotation;
}

/// Shows the Pinterest-style long press overlay using [Overlay] so it
/// bypasses GoRouter's navigator entirely — no risk of "popped last page".
void showPinLongPressOverlay({
  required BuildContext context,
  required Photo photo,
  required Rect cardRect,
  required Offset pressPosition,
  required List<PinAction> actions,
}) {
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _PinLongPressOverlay(
      photo: photo,
      cardRect: cardRect,
      pressPosition: pressPosition,
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
    required this.pressPosition,
    required this.actions,
    required this.onDismiss,
  });

  final Photo photo;
  final Rect cardRect;
  final Offset pressPosition;
  final List<PinAction> actions;
  final VoidCallback onDismiss;

  @override
  State<_PinLongPressOverlay> createState() => _PinLongPressOverlayState();
}

class _PinLongPressOverlayState extends State<_PinLongPressOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _indicatorScaleAnim;

  int? _hoveredIndex;
  bool _isDragging = false;
  bool _dismissed = false;

  // Arc configuration
  static const double _startAngleDeg = -155;
  static const double _endAngleDeg = -45;
  static final double _arcRadius = 110.w;
  static final double _btnSize = 52.w;
  static final double _btnSizeHovered = 64.w;
  static final double _indicatorSize = 44.w;

  static const double _startAngle = _startAngleDeg * math.pi / 180;
  static const double _endAngle = _endAngleDeg * math.pi / 180;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _indicatorScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
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
  ///   Pin (far-left)   Share (upper-center)
  ///                    Search (right, upper-middle)
  ///                    Send (right, below search)
  ///
  /// Y positions use a clamped vertical unit so buttons stay in
  /// the upper portion of the card for tall images and don't
  /// overlap on short ones.
  List<Offset> _getButtonPositions() {
    final px = widget.pressPosition.dx;
    final py = widget.pressPosition.dy;
    final count = widget.actions.length;
    final step = (_endAngle - _startAngle) / (count - 1);
    final xMul = _isLeftColumn ? 1.0 : -1.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final half = _btnSize / 2;

    // Calculate raw arc positions
    final raw = List.generate(count, (i) {
      final angle = _startAngle + step * i;
      return Offset(
        px + _arcRadius * math.cos(angle) * xMul,
        py + _arcRadius * math.sin(angle),
      );
    });

    // Find bounding extents of all buttons
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    for (final pos in raw) {
      minX = math.min(minX, pos.dx);
      maxX = math.max(maxX, pos.dx);
      minY = math.min(minY, pos.dy);
    }

    // Shift the entire arc uniformly so all buttons stay on screen
    var shiftX = 0.0;
    var shiftY = 0.0;
    if (minX - half < 0) {
      shiftX = half - minX;
    } else if (maxX + half > screenWidth) {
      shiftX = screenWidth - half - maxX;
    }
    if (minY - half < 0) {
      shiftY = half - minY;
    }

    return raw.map((pos) => pos + Offset(shiftX, shiftY)).toList();
  }

  int? _hitTest(Offset globalPos) {
    final positions = _getButtonPositions();
    int? closest;
    double minDist = double.infinity;
    for (var i = 0; i < positions.length; i++) {
      final d = (globalPos - positions[i]).distance;
      if (d <= _btnSize && d < minDist) {
        closest = i;
        minDist = d;
      }
    }
    return closest;
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
    final press = widget.pressPosition;

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
                      color: Color.lerp(
                        Colors.transparent,
                        const Color(0x88000000),
                        _fadeAnim.value,
                      )!,
                    ),
                  ),

                  // ── Pin image
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

                  // ── Grey circle indicator at press position
                  Positioned(
                    left: press.dx - _indicatorSize / 2,
                    top: press.dy - _indicatorSize / 2,
                    child: ScaleTransition(
                      scale: _indicatorScaleAnim,
                      child: Container(
                        width: _indicatorSize,
                        height: _indicatorSize,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  // ── Arc action buttons
                  ..._buildArcButtons(),

                  // ── Floating label on opposite side
                  _buildFloatingLabel(),

                  // ── "..." dots highlighted
                  Positioned(
                    left: rect.right - 20.w,
                    top: rect.bottom + 4.h,
                    child: Opacity(
                      opacity: _fadeAnim.value,
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Whether the card is in the left column of the masonry grid.
  bool get _isLeftColumn {
    final screenWidth = MediaQuery.of(context).size.width;
    return widget.cardRect.center.dx < screenWidth / 2;
  }

  List<Widget> _buildArcButtons() {
    final positions = _getButtonPositions();
    final widgets = <Widget>[];
    Widget? hoveredWidget;

    for (var i = 0; i < widget.actions.length; i++) {
      final action = widget.actions[i];
      final pos = positions[i];
      final isHovered = _hoveredIndex == i && _isDragging;
      final size = isHovered ? _btnSizeHovered : _btnSize;
      final half = size / 2;

      final btn = Positioned(
        left: pos.dx - half,
        top: pos.dy - half,
        child: Opacity(
          opacity: _fadeAnim.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isHovered ? Colors.white : const Color(0xFF3A3A3A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: isHovered ? 14 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildButtonIcon(action, isHovered: isHovered),
          ),
        ),
      );

      if (isHovered) {
        hoveredWidget = btn;
      } else {
        widgets.add(btn);
      }
    }

    if (hoveredWidget != null) widgets.add(hoveredWidget);

    return widgets;
  }

  /// Builds the floating label that appears on the opposite side of the
  /// screen from the card when a button is hovered during drag.
  Widget _buildFloatingLabel() {
    if (_hoveredIndex == null || !_isDragging) {
      return const SizedBox.shrink();
    }

    final action = widget.actions[_hoveredIndex!];
    final r = widget.cardRect;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLeft = _isLeftColumn;

    // Position label in the center of the opposite column
    final labelCenterX = isLeft
        ? r.right + (screenWidth - r.right) / 2
        : r.left / 2;

    // Vertically center with the card
    final labelCenterY = r.top + r.height * 0.5;

    return Positioned(
      left: labelCenterX - 80.w,
      top: labelCenterY - 18.h,
      width: 160.w,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Text(
            action.label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonIcon(PinAction action, {required bool isHovered}) {
    final color = isHovered ? Colors.black : Colors.white;
    final size = isHovered ? 24.sp : 20.sp;

    Widget icon;
    if (action.svgAsset != null) {
      icon = SvgPicture.asset(
        action.svgAsset!,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else {
      icon = Icon(action.icon, color: color, size: size);
    }

    if (action.iconRotation != null) {
      icon = Transform.rotate(angle: action.iconRotation!, child: icon);
    }

    return icon;
  }

}
