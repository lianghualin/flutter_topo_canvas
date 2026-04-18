import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/topo_types.dart';
import '../core/render_context.dart';
import 'node_renderer.dart';

/// Renders a node as an SVG asset plus a text label beneath it.
///
/// The asset path and label text are caller-provided callbacks on the node —
/// swap asset per node to express normal/abnormal state (e.g. return
/// `switch_float_err.svg` when `node.data.isAbnormal`).
///
/// [package] scopes the asset lookup to a specific Flutter package (use
/// `'flutter_topo_canvas'` when referencing the built-in SVGs, or leave null
/// for app-local assets).
class IconNodeRenderer<T> extends NodeRenderer<T> {
  final String Function(TopoNode<T> node) assetPath;
  final String Function(TopoNode<T> node) label;
  final Size size;
  final bool hoverFloat;
  final String? package;
  final TextStyle? labelStyle;

  const IconNodeRenderer({
    required this.assetPath,
    required this.label,
    this.size = const Size(80, 80),
    this.hoverFloat = true,
    this.package,
    this.labelStyle,
  });

  @override
  Size sizeFor(TopoNode<T> node) => size;

  @override
  Widget build(BuildContext context, TopoNode<T> node, RenderContext rc) {
    final float = hoverFloat && rc.isHovered ? -6.0 : 0.0;
    return SizedBox(
      width: size.width,
      height: size.height + 24, // room for the label
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            transform: Matrix4.translationValues(0, float, 0),
            child: SvgPicture.asset(
              assetPath(node),
              package: package,
              width: size.width,
              height: size.height,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label(node),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle ??
                const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
