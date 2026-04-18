import 'package:flutter/material.dart';

/// Narrow window exposed to node/edge/group renderers.
///
/// Hides the canvas's internal state so renderers can't accidentally rely on
/// implementation details. Only contains what renderers legitimately need.
@immutable
class RenderContext {
  final double animationValue;
  final double scale;
  final bool isHovered;
  final Matrix4 transform;
  final VoidCallback repaintTrigger;

  const RenderContext({
    required this.animationValue,
    required this.scale,
    required this.isHovered,
    required this.transform,
    required this.repaintTrigger,
  });
}
