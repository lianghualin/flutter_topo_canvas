import 'package:flutter/material.dart';
import '../core/topo_types.dart';

/// Paints a visual boundary around the nodes in a group.
///
/// [bounds] is the canvas-space rectangle that encloses all nodes belonging
/// to [group], pre-computed by the canvas from node positions + sizes.
abstract class GroupRenderer {
  const GroupRenderer();

  void paint(Canvas canvas, TopoGroup group, Rect bounds);
}
