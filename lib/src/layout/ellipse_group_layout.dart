import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import 'hierarchical_layout.dart';
import 'topology_layout.dart';

/// Lays out nodes grouped into domains (ellipses). Each domain is a mega-node
/// in an outer hierarchical layout; nodes inside each domain sit on the
/// ellipse's horizontal midline, evenly spaced.
///
/// Inter-domain edges between nodes are routed directly node-to-node by the
/// canvas — this layout only computes positions.
class EllipseGroupLayout extends TopologyLayout {
  final String rootDomainId;
  final double domainSpacing;
  final double nodeSpacing;
  final double ellipseHeight;

  const EllipseGroupLayout({
    required this.rootDomainId,
    this.domainSpacing = 80,
    this.nodeSpacing = 180,
    this.ellipseHeight = 200,
  });

  @override
  Map<String, Offset> computePositions({
    required List<String> nodeIds,
    required List<(String, String)> edges,
    required List<TopoGroup> groups,
    required Size viewport,
  }) {
    if (!groups.any((g) => g.id == rootDomainId)) {
      throw ArgumentError.value(
        rootDomainId,
        'rootDomainId',
        'rootDomainId must match the id of a group in groups',
      );
    }

    final domainEdges = _deriveDomainEdges(groups, edges);
    final domainIds = groups.map((g) => g.id).toList();
    final domainPositions = HierarchicalLayout(
      rootNodeId: rootDomainId,
      levelGap: ellipseHeight + domainSpacing,
      siblingGap: 400, // generous gap between domain centres
    ).computePositions(
      nodeIds: domainIds,
      edges: domainEdges,
      groups: const [],
      viewport: viewport,
    );

    final out = <String, Offset>{};
    for (final group in groups) {
      final centre = domainPositions[group.id] ?? Offset.zero;
      final n = group.nodeIds.length;
      if (n == 0) continue;

      if (n == 1) {
        out[group.nodeIds.first] = centre;
        continue;
      }

      final totalWidth = (n - 1) * nodeSpacing;
      final startX = centre.dx - totalWidth / 2;
      for (var i = 0; i < n; i++) {
        out[group.nodeIds[i]] = Offset(startX + i * nodeSpacing, centre.dy);
      }
    }

    // Orphans: any nodeId not placed by a group gets origin fallback.
    for (final id in nodeIds) {
      out.putIfAbsent(id, () => Offset.zero);
    }

    return out;
  }

  /// Derives domain-to-domain edges from node-level edges that cross group
  /// boundaries. Self-loops (both endpoints in the same domain) are dropped.
  List<(String, String)> _deriveDomainEdges(
    List<TopoGroup> groups,
    List<(String, String)> nodeEdges,
  ) {
    final nodeToDomain = <String, String>{};
    for (final g in groups) {
      for (final n in g.nodeIds) {
        nodeToDomain[n] = g.id;
      }
    }
    final seen = <String>{};
    final out = <(String, String)>[];
    for (final (from, to) in nodeEdges) {
      final da = nodeToDomain[from];
      final db = nodeToDomain[to];
      if (da == null || db == null || da == db) continue;
      final key = da.compareTo(db) < 0 ? '$da->$db' : '$db->$da';
      if (seen.add(key)) out.add((da, db));
    }
    return out;
  }
}
