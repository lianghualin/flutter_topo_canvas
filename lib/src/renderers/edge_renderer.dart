import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import '../core/render_context.dart';

/// Paints a single edge onto the canvas.
abstract class EdgeRenderer<T> {
  const EdgeRenderer();

  /// Paints [edge] from [from] to [to] using [canvas]. The renderer owns all
  /// styling (colour, stroke, animation) — read animation state from [rc].
  void paint(
    Canvas canvas,
    TopoEdge<T> edge,
    Offset from,
    Offset to,
    RenderContext rc,
  );
}
