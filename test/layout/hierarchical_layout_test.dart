import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/src/core/topo_types.dart';
import 'package:flutter_topo_canvas/src/layout/hierarchical_layout.dart';

void main() {
  group('HierarchicalLayout', () {
    test('throws if rootNodeId not in node list', () {
      final layout = HierarchicalLayout(rootNodeId: 'missing');
      expect(
        () => layout.computePositions(
          nodeIds: const ['a', 'b'],
          edges: const [('a', 'b')],
          groups: const [],
          viewport: const Size(800, 600),
        ),
        throwsArgumentError,
      );
    });

    test('single-node tree: root at origin', () {
      final layout = HierarchicalLayout(rootNodeId: 'a');
      final pos = layout.computePositions(
        nodeIds: const ['a'],
        edges: const [],
        groups: const [],
        viewport: const Size(800, 600),
      );
      expect(pos['a'], Offset.zero);
    });

    test('three-level chain: each child is one levelGap below parent', () {
      final layout = HierarchicalLayout(
        rootNodeId: 'a',
        levelGap: 100,
        siblingGap: 80,
      );
      final pos = layout.computePositions(
        nodeIds: const ['a', 'b', 'c'],
        edges: const [('a', 'b'), ('b', 'c')],
        groups: const [],
        viewport: const Size(800, 600),
      );
      expect(pos['a']!.dy, 0);
      expect(pos['b']!.dy, 100);
      expect(pos['c']!.dy, 200);
    });

    test('siblings at same level share y and are separated by siblingGap', () {
      final layout = HierarchicalLayout(
        rootNodeId: 'a',
        levelGap: 100,
        siblingGap: 80,
      );
      final pos = layout.computePositions(
        nodeIds: const ['a', 'b', 'c'],
        edges: const [('a', 'b'), ('a', 'c')],
        groups: const [],
        viewport: const Size(800, 600),
      );
      expect(pos['b']!.dy, 100);
      expect(pos['c']!.dy, 100);
      expect((pos['b']!.dx - pos['c']!.dx).abs(), 80);
    });

    test('graph with cycle: layout completes without hanging', () {
      final layout = HierarchicalLayout(rootNodeId: 'a');
      final pos = layout.computePositions(
        nodeIds: const ['a', 'b', 'c'],
        edges: const [('a', 'b'), ('b', 'c'), ('c', 'a')],
        groups: const [],
        viewport: const Size(800, 600),
      );
      expect(pos.length, 3);
      expect(pos['a'], isNotNull);
      expect(pos['b'], isNotNull);
      expect(pos['c'], isNotNull);
    });

    test('self-loop on root is ignored for level assignment', () {
      final layout = HierarchicalLayout(rootNodeId: 'a');
      final pos = layout.computePositions(
        nodeIds: const ['a', 'b'],
        edges: const [('a', 'a'), ('a', 'b')],
        groups: const [],
        viewport: const Size(800, 600),
      );
      expect(pos['a']!.dy, 0);
      expect(pos['b']!.dy, layout.levelGap);
    });

    test('large cycle does not crash', () {
      final ids = List<String>.generate(10, (i) => 'n$i');
      final edges = <(String, String)>[
        for (var i = 0; i < ids.length; i++) (ids[i], ids[(i + 1) % ids.length]),
      ];
      final layout = HierarchicalLayout(rootNodeId: 'n0');
      final pos = layout.computePositions(
        nodeIds: ids,
        edges: edges,
        groups: const [],
        viewport: const Size(800, 600),
      );
      expect(pos.length, 10);
    });
  });
}
