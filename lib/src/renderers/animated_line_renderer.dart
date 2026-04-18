import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import '../core/render_context.dart';
import 'edge_renderer.dart';

/// Paints an edge as a line with a dual-direction flow animation.
///
/// The flow is conveyed by a set of moving dots along the line, offset by
/// [rc.animationValue] (expected 0..1 looping). Set [colorful] to cycle a
/// rainbow hue along the line.
class AnimatedLineRenderer<T> extends EdgeRenderer<T> {
  final bool colorful;
  final double flowSpeed;
  final double strokeWidth;
  final Color color;
  final double dotSpacing;
  final double dotRadius;

  const AnimatedLineRenderer({
    this.colorful = false,
    this.flowSpeed = 2.0,
    this.strokeWidth = 2.0,
    this.color = const Color(0xFF2196F3),
    this.dotSpacing = 16,
    this.dotRadius = 2.5,
  });

  @override
  void paint(
    Canvas canvas,
    TopoEdge<T> edge,
    Offset from,
    Offset to,
    RenderContext rc,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth / rc.scale.clamp(0.2, 10.0)
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, linePaint);

    _drawFlowDots(canvas, from, to, rc);
  }

  void _drawFlowDots(Canvas canvas, Offset a, Offset b, RenderContext rc) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length < 1) return;

    final ux = dx / length;
    final uy = dy / length;
    final phase = (rc.animationValue * flowSpeed) % 1.0;
    var t = phase * dotSpacing;

    final dotPaint = Paint()..style = PaintingStyle.fill;
    var hue = 0.0;

    while (t < length) {
      final px = a.dx + ux * t;
      final py = a.dy + uy * t;

      if (colorful) {
        dotPaint.color = HSVColor.fromAHSV(1, hue % 360, 0.9, 0.9).toColor();
        hue += 40;
      } else {
        dotPaint.color = color;
      }

      canvas.drawCircle(Offset(px, py), dotRadius, dotPaint);
      t += dotSpacing;
    }
  }
}
