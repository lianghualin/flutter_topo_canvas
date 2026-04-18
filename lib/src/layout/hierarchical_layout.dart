import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import 'topology_layout.dart';

enum LayoutDirection { topDown, leftRight }

class HierarchicalLayout extends TopologyLayout {
  final String rootNodeId;
  final double levelGap;
  final double siblingGap;
  final LayoutDirection direction;

  const HierarchicalLayout({
    required this.rootNodeId,
    this.levelGap = 180,
    this.siblingGap = 120,
    this.direction = LayoutDirection.topDown,
  });

  @override
  Map<String, Offset> computePositions({
    required List<String> nodeIds,
    required List<(String, String)> edges,
    required List<TopoGroup> groups,
    required Size viewport,
  }) {
    if (!nodeIds.contains(rootNodeId)) {
      throw ArgumentError.value(
        rootNodeId,
        'rootNodeId',
        'rootNodeId must be present in nodeIds',
      );
    }

    final adjacency = _buildAdjacency(nodeIds, edges);
    final levels = _assignLevels(adjacency, rootNodeId);
    final levelGroups = _groupByLevel(levels);
    final orderedPerLevel = _orderBarycentre(levelGroups, adjacency, levels);
    return _assignCoordinates(orderedPerLevel);
  }

  Map<String, List<String>> _buildAdjacency(
    List<String> nodeIds,
    List<(String, String)> edges,
  ) {
    final adj = <String, List<String>>{for (final n in nodeIds) n: []};
    for (final (from, to) in edges) {
      adj[from]?.add(to);
      adj[to]?.add(from); // treat as undirected for level assignment
    }
    return adj;
  }

  /// BFS from root. Back-edges (to already-levelled nodes) are ignored for
  /// level assignment but the edge itself still renders.
  Map<String, int> _assignLevels(
    Map<String, List<String>> adjacency,
    String root,
  ) {
    final levels = <String, int>{root: 0};
    final queue = <String>[root];
    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      for (final neighbour in adjacency[node] ?? const <String>[]) {
        if (!levels.containsKey(neighbour)) {
          levels[neighbour] = levels[node]! + 1;
          queue.add(neighbour);
        }
      }
    }
    // disconnected nodes get level 0 (local roots) for Task 11
    for (final n in adjacency.keys) {
      levels.putIfAbsent(n, () => 0);
    }
    return levels;
  }

  Map<int, List<String>> _groupByLevel(Map<String, int> levels) {
    final out = <int, List<String>>{};
    for (final entry in levels.entries) {
      out.putIfAbsent(entry.value, () => []).add(entry.key);
    }
    return out;
  }

  List<List<String>> _orderBarycentre(
    Map<int, List<String>> levelGroups,
    Map<String, List<String>> adjacency,
    Map<String, int> levels,
  ) {
    final sortedLevels = levelGroups.keys.toList()..sort();
    final orderedPerLevel = <List<String>>[
      for (final lvl in sortedLevels) List.of(levelGroups[lvl]!)..sort(),
    ];

    // Two passes: top-down then bottom-up, sorting each level by the mean
    // position index of each node's neighbours in the adjacent level.
    for (var pass = 0; pass < 2; pass++) {
      for (var i = 1; i < orderedPerLevel.length; i++) {
        _sortByBarycentre(
          orderedPerLevel[i],
          orderedPerLevel[i - 1],
          adjacency,
        );
      }
      for (var i = orderedPerLevel.length - 2; i >= 0; i--) {
        _sortByBarycentre(
          orderedPerLevel[i],
          orderedPerLevel[i + 1],
          adjacency,
        );
      }
    }
    return orderedPerLevel;
  }

  void _sortByBarycentre(
    List<String> level,
    List<String> reference,
    Map<String, List<String>> adjacency,
  ) {
    final refIndex = {
      for (var i = 0; i < reference.length; i++) reference[i]: i.toDouble(),
    };
    level.sort((a, b) {
      final ba = _barycentre(a, adjacency, refIndex);
      final bb = _barycentre(b, adjacency, refIndex);
      return ba.compareTo(bb);
    });
  }

  double _barycentre(
    String node,
    Map<String, List<String>> adjacency,
    Map<String, double> refIndex,
  ) {
    final neighbours = adjacency[node] ?? const <String>[];
    final indices = [
      for (final n in neighbours)
        if (refIndex.containsKey(n)) refIndex[n]!,
    ];
    if (indices.isEmpty) return double.infinity;
    return indices.reduce((a, b) => a + b) / indices.length;
  }

  Map<String, Offset> _assignCoordinates(List<List<String>> levels) {
    final out = <String, Offset>{};
    for (var lvl = 0; lvl < levels.length; lvl++) {
      final nodes = levels[lvl];
      final totalWidth = (nodes.length - 1) * siblingGap;
      final startX = -totalWidth / 2;
      for (var i = 0; i < nodes.length; i++) {
        final x = startX + i * siblingGap;
        final y = lvl * levelGap;
        final offset = direction == LayoutDirection.topDown
            ? Offset(x, y)
            : Offset(y, x);
        out[nodes[i]] = offset;
      }
    }
    return out;
  }
}
