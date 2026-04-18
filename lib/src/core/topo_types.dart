import 'package:flutter/material.dart';

/// A node in the topology graph, keyed by [id] with generic [data] payload.
///
/// [position] is optional. If null, the `TopologyLayout` assigned to the
/// canvas computes it. If set, the layout MUST honour it verbatim.
@immutable
class TopoNode<T> {
  final String id;
  final T data;
  final Offset? position;

  const TopoNode({
    required this.id,
    required this.data,
    this.position,
  });
}

/// A directed edge from [fromNodeId] to [toNodeId] with generic [data] payload.
@immutable
class TopoEdge<T> {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final T data;

  const TopoEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.data,
  });
}

/// A visual grouping of nodes. Decorative only — does not affect layout
/// unless the chosen layout explicitly consumes groups (e.g. `EllipseGroupLayout`).
@immutable
class TopoGroup {
  final String id;
  final String label;
  final List<String> nodeIds;
  final bool isAbnormal;

  const TopoGroup({
    required this.id,
    required this.label,
    required this.nodeIds,
    this.isAbnormal = false,
  });
}
