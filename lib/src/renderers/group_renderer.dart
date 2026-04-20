import 'package:flutter/material.dart';
import '../core/topo_types.dart';

/// Paints a visual boundary around the nodes in a group.
///
/// [bounds] is the canvas-space rectangle that encloses all nodes belonging
/// to [group], pre-computed by the canvas from node positions + sizes.
abstract class GroupRenderer {
  const GroupRenderer();

  void paint(Canvas canvas, TopoGroup group, Rect bounds);

  /// Returns the rect this renderer actually paints for [group], given a
  /// [nodeUnion] rect covering the group's nodes. Fit-view unions these across
  /// groups so the viewport frames the full visual boundary, not just nodes.
  /// Default: no extra inflation — override if the renderer draws outside.
  Rect visualBounds(TopoGroup group, Rect nodeUnion) => nodeUnion;
}
