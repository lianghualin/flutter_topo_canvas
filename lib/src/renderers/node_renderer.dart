import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import '../core/render_context.dart';

/// Draws a single node.
abstract class NodeRenderer<T> {
  const NodeRenderer();

  /// The widget to display at the node's position.
  Widget build(BuildContext context, TopoNode<T> node, RenderContext rc);

  /// Bounding size of the node's visual. Used by layouts that need per-node
  /// sizing (e.g. barycenter sibling-gap widening).
  Size sizeFor(TopoNode<T> node);
}
