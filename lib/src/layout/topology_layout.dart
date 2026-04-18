import 'package:flutter/material.dart';
import '../core/topo_types.dart';

/// Computes screen positions for nodes in a topology.
///
/// Implementations must handle arbitrary graphs, including cycles. They must
/// not crash on disconnected components. Return value is keyed by node id;
/// every id in [nodeIds] must appear in the result.
abstract class TopologyLayout {
  const TopologyLayout();

  /// Whether this layout depends on the viewport size (true causes re-layout
  /// on viewport resize). Defaults to false — most layouts use relative
  /// coordinates and the canvas pan/zooms to fit.
  bool get isViewportDependent => false;

  /// Compute node positions.
  ///
  /// [nodeIds] — every node in the canvas.
  /// [edges] — `(from, to)` pairs, directed.
  /// [groups] — optional groupings; layouts that don't consume groups should ignore.
  /// [viewport] — current viewport size; ignore unless [isViewportDependent].
  Map<String, Offset> computePositions({
    required List<String> nodeIds,
    required List<(String, String)> edges,
    required List<TopoGroup> groups,
    required Size viewport,
  });
}
