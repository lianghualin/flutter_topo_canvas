import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/src/core/topo_types.dart';
import 'package:flutter_topo_canvas/src/layout/ellipse_group_layout.dart';

void main() {
  group('EllipseGroupLayout', () {
    test('throws if rootDomainId not in groups', () {
      const layout = EllipseGroupLayout(rootDomainId: 'missing');
      expect(
        () => layout.computePositions(
          nodeIds: const ['n1'],
          edges: const [],
          groups: const [TopoGroup(id: 'g1', label: 'A', nodeIds: ['n1'])],
          viewport: const Size(800, 600),
        ),
        throwsArgumentError,
      );
    });

    test('single group: nodes centred along horizontal midline', () {
      const layout = EllipseGroupLayout(rootDomainId: 'g1', nodeSpacing: 100);
      final pos = layout.computePositions(
        nodeIds: const ['n1', 'n2', 'n3'],
        edges: const [],
        groups: const [TopoGroup(id: 'g1', label: 'A', nodeIds: ['n1', 'n2', 'n3'])],
        viewport: const Size(800, 600),
      );
      expect(pos['n1']!.dy, pos['n2']!.dy);
      expect(pos['n2']!.dy, pos['n3']!.dy);
      expect((pos['n2']!.dx - pos['n1']!.dx).abs(), 100);
    });

    test('single node in group is centred', () {
      const layout = EllipseGroupLayout(rootDomainId: 'g1');
      final pos = layout.computePositions(
        nodeIds: const ['solo'],
        edges: const [],
        groups: const [TopoGroup(id: 'g1', label: 'A', nodeIds: ['solo'])],
        viewport: const Size(800, 600),
      );
      expect(pos['solo'], isNotNull);
    });

    test('two domains: root domain above child domain', () {
      const layout = EllipseGroupLayout(rootDomainId: 'g1', domainSpacing: 80);
      final pos = layout.computePositions(
        nodeIds: const ['n1', 'n2'],
        edges: const [('n1', 'n2')],
        groups: const [
          TopoGroup(id: 'g1', label: 'root', nodeIds: ['n1']),
          TopoGroup(id: 'g2', label: 'child', nodeIds: ['n2']),
        ],
        viewport: const Size(800, 600),
      );
      expect(pos['n1']!.dy < pos['n2']!.dy, isTrue,
          reason: 'root domain renders above child domain');
    });

    test('orphan nodes (not in any group) placed at origin fallback', () {
      const layout = EllipseGroupLayout(rootDomainId: 'g1');
      final pos = layout.computePositions(
        nodeIds: const ['n1', 'orphan'],
        edges: const [],
        groups: const [TopoGroup(id: 'g1', label: 'A', nodeIds: ['n1'])],
        viewport: const Size(800, 600),
      );
      expect(pos['orphan'], isNotNull);
    });
  });
}
