import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import '../renderers/group_renderer.dart';

/// Returns the full content-space bounding rect that fit-view should frame:
/// the union of every node's rect (centre ± half size) with every group's
/// [GroupRenderer.visualBounds]. This ensures groups whose renderer paints
/// outside the node rect (e.g. the ellipse's 40 px inflation) are not clipped.
///
/// Returns [Rect.zero] when [positions] is empty.
Rect contentBounds({
  required Map<String, Offset> positions,
  required Map<String, Size> nodeSizes,
  required List<TopoGroup> groups,
  required GroupRenderer? groupRenderer,
}) {
  if (positions.isEmpty) return Rect.zero;

  Rect? acc;
  Rect? rectForNode(String id) {
    final pos = positions[id];
    if (pos == null) return null;
    final size = nodeSizes[id] ?? Size.zero;
    return Rect.fromCenter(
      center: pos,
      width: size.width,
      height: size.height,
    );
  }

  for (final id in positions.keys) {
    final r = rectForNode(id);
    if (r == null) continue;
    acc = acc?.expandToInclude(r) ?? r;
  }

  if (groupRenderer != null) {
    for (final group in groups) {
      Rect? union;
      for (final id in group.nodeIds) {
        final r = rectForNode(id);
        if (r == null) continue;
        union = union?.expandToInclude(r) ?? r;
      }
      if (union == null) continue;
      final vb = groupRenderer.visualBounds(group, union);
      acc = acc?.expandToInclude(vb) ?? vb;
    }
  }

  return acc ?? Rect.zero;
}

/// Computes the axis-aligned bounding rectangle that encloses every offset in
/// [positions]. Returns [Rect.zero] when empty.
Rect boundsOfPositions(Map<String, Offset> positions) {
  if (positions.isEmpty) return Rect.zero;

  final offsets = positions.values;
  final first = offsets.first;
  double minX = first.dx, minY = first.dy, maxX = first.dx, maxY = first.dy;

  for (final o in offsets) {
    if (o.dx < minX) minX = o.dx;
    if (o.dy < minY) minY = o.dy;
    if (o.dx > maxX) maxX = o.dx;
    if (o.dy > maxY) maxY = o.dy;
  }
  return Rect.fromLTWH(minX, minY, maxX - minX, maxY - minY);
}

/// Returns the scale factor that fits [contentSize] into [viewportSize] minus
/// [padding] on all sides. Clamps to [maxScale] to avoid zooming in too far on
/// tiny content. Returns 1.0 for empty content.
double fitViewScale({
  required Size contentSize,
  required Size viewportSize,
  double padding = 40,
  double maxScale = 2.0,
}) {
  if (contentSize.isEmpty) return 1.0;

  final innerW = math.max(viewportSize.width - 2 * padding, 1);
  final innerH = math.max(viewportSize.height - 2 * padding, 1);

  final sx = innerW / contentSize.width;
  final sy = innerH / contentSize.height;
  final s = math.min(sx, sy);

  return math.min(s, maxScale);
}

/// Returns the translation that centres [contentBounds] within a viewport of
/// size [viewportSize] after scaling by [scale].
Offset fitViewOffset({
  required Rect contentBounds,
  required Size viewportSize,
  required double scale,
}) {
  final contentCentre = contentBounds.center * scale;
  final viewCentre = Offset(viewportSize.width / 2, viewportSize.height / 2);
  return viewCentre - contentCentre;
}

/// Clamps [value] to the inclusive range [min, max].
double clampScale(double value, double min, double max) {
  if (value < min) return min;
  if (value > max) return max;
  return value;
}
