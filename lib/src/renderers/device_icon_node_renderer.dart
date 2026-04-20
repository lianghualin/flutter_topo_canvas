import 'dart:ui' as ui show ImageFilter;
import 'package:flutter/material.dart';
import 'package:topology_view_icons/topology_view_icons.dart';
import '../core/topo_types.dart';
import '../core/render_context.dart';
import 'node_renderer.dart';

/// Renders a node as a canvas-drawn topology icon from `topology_view_icons`
/// plus a text label. No assets, no SVG parsing — scales crisply at any zoom.
///
/// Callers map each node's data to a [TopoDeviceType] via [deviceType] and to
/// an error flag via [isError]. [style] is fixed per renderer instance.
///
/// On hover, the icon lifts by [liftDistance] and a silhouette-shaped drop
/// shadow grows in underneath — parameters tuned via the example app's
/// "Hover debug" tab. Set [hoverFloat] to `false` to disable both effects.
class DeviceIconNodeRenderer<T> extends NodeRenderer<T> {
  final TopoDeviceType Function(TopoNode<T> node) deviceType;
  final bool Function(TopoNode<T> node) isError;
  final String Function(TopoNode<T> node) label;

  /// Optional: when true for a node, the whole node (icon + label) is
  /// rendered at [externalOpacity] to de-emphasize it. Useful for showing
  /// context-only switches from neighbouring domains. Null = never external.
  final bool Function(TopoNode<T> node)? isExternal;
  final double externalOpacity;

  final Size size;
  final TopoIconStyle style;
  final bool hoverFloat;
  final double liftDistance;
  final double shadowBlur;
  final double shadowOffset;
  final double shadowOpacity;
  final TextStyle? labelStyle;

  const DeviceIconNodeRenderer({
    required this.deviceType,
    required this.label,
    required this.isError,
    this.isExternal,
    this.externalOpacity = 0.5,
    this.size = const Size(80, 80),
    this.style = TopoIconStyle.lnm,
    this.hoverFloat = true,
    this.liftDistance = 2.0,
    this.shadowBlur = 3.0,
    this.shadowOffset = 0.0,
    this.shadowOpacity = 0.20,
    this.labelStyle,
  });

  @override
  Size sizeFor(TopoNode<T> node) => size;

  @override
  Widget build(BuildContext context, TopoNode<T> node, RenderContext rc) {
    final widget = _DeviceIconNodeWidget(
      deviceType: deviceType(node),
      isError: isError(node),
      label: label(node),
      size: size,
      style: style,
      hoverFloat: hoverFloat,
      liftDistance: liftDistance,
      shadowBlur: shadowBlur,
      shadowOffset: shadowOffset,
      shadowOpacity: shadowOpacity,
      labelStyle: labelStyle,
    );
    final external = isExternal?.call(node) ?? false;
    return external
        ? Opacity(opacity: externalOpacity, child: widget)
        : widget;
  }
}

class _DeviceIconNodeWidget extends StatefulWidget {
  final TopoDeviceType deviceType;
  final bool isError;
  final String label;
  final Size size;
  final TopoIconStyle style;
  final bool hoverFloat;
  final double liftDistance;
  final double shadowBlur;
  final double shadowOffset;
  final double shadowOpacity;
  final TextStyle? labelStyle;

  const _DeviceIconNodeWidget({
    required this.deviceType,
    required this.isError,
    required this.label,
    required this.size,
    required this.style,
    required this.hoverFloat,
    required this.liftDistance,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.shadowOpacity,
    required this.labelStyle,
  });

  @override
  State<_DeviceIconNodeWidget> createState() => _DeviceIconNodeWidgetState();
}

class _DeviceIconNodeWidgetState extends State<_DeviceIconNodeWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.hoverFloat;
    final target = enabled && _hovered ? -widget.liftDistance : 0.0;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height + 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: target),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                final progress = !enabled || widget.liftDistance == 0
                    ? (_hovered && enabled ? 1.0 : 0.0)
                    : (-value / widget.liftDistance).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, value),
                  child: _SilhouetteShadow(
                    progress: progress,
                    blur: widget.shadowBlur,
                    offset: widget.shadowOffset,
                    opacity: widget.shadowOpacity,
                    child: child!,
                  ),
                );
              },
              child: CustomPaint(
                size: widget.size,
                painter: TopoIconPainter(
                  deviceType: widget.deviceType,
                  isError: widget.isError,
                  style: widget.style,
                ),
              ),
            ),
            // Translucent plate keeps the label legible when an edge line
            // passes through the label zone (edges run from node-centre to
            // node-centre, so downlinks cross directly under the icon).
            // The negative translate pulls the plate up into the icon's
            // internal bottom padding so the label reads as part of the icon
            // rather than floating below it. `height: 1.0` collapses the
            // font's line-box whitespace.
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.85),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.labelStyle ??
                      const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        height: 1.0,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SilhouetteShadow extends StatelessWidget {
  final double progress;
  final double blur;
  final double offset;
  final double opacity;
  final Widget child;

  const _SilhouetteShadow({
    required this.progress,
    required this.blur,
    required this.offset,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    final b = blur * t;
    final dy = offset * t;
    final op = opacity * t;
    if (op <= 0 || (b <= 0 && dy <= 0)) return child;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, dy),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: b, sigmaY: b),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                // ignore: deprecated_member_use
                Colors.black.withOpacity(op),
                BlendMode.srcIn,
              ),
              child: child,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
