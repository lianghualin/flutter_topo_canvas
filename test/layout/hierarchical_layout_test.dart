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
  });
}
