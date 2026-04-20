import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import 'group_renderer.dart';

enum LabelPosition { top, bottom, inside }

/// Paints a group boundary as an ellipse, colored by [TopoGroup.isAbnormal].
class EllipseGroupRenderer extends GroupRenderer {
  final double strokeWidth;
  final LabelPosition labelPosition;
  final Color normalColor;
  final Color abnormalColor;
  final TextStyle labelStyle;

  const EllipseGroupRenderer({
    this.strokeWidth = 3.0,
    this.labelPosition = LabelPosition.top,
    this.normalColor = const Color(0xFF448AFF), // blueAccent
    this.abnormalColor = const Color(0xFFE53935), // red
    this.labelStyle = const TextStyle(
      fontSize: 18,
      color: Colors.black54,
      fontFamily: 'Schyler',
    ),
  });

  /// Inflation applied to the node-union rect before drawing the ellipse.
  static const _inflation = 40.0;

  @override
  Rect visualBounds(TopoGroup group, Rect nodeUnion) =>
      nodeUnion.inflate(_inflation + strokeWidth / 2);

  @override
  void paint(Canvas canvas, TopoGroup group, Rect bounds) {
    final paint = Paint()
      ..color = group.isAbnormal ? abnormalColor : normalColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Inflate slightly so the ellipse encloses the nodes rather than overlapping.
    final inflated = bounds.inflate(_inflation);
    canvas.drawOval(inflated, paint);

    final tp = TextPainter(
      text: TextSpan(text: group.label, style: labelStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final labelOffset = switch (labelPosition) {
      LabelPosition.top => Offset(
          inflated.center.dx - tp.width / 2,
          inflated.top + 8,
        ),
      LabelPosition.bottom => Offset(
          inflated.center.dx - tp.width / 2,
          inflated.bottom - tp.height - 8,
        ),
      LabelPosition.inside => Offset(
          inflated.center.dx - tp.width / 2,
          inflated.center.dy - tp.height / 2,
        ),
    };
    tp.paint(canvas, labelOffset);
  }
}
