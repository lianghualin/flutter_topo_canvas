import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/src/core/topo_types.dart';

void main() {
  group('TopoNode', () {
    test('constructs with id and data, position optional', () {
      final node = TopoNode<String>(id: 'n1', data: 'hello');
      expect(node.id, 'n1');
      expect(node.data, 'hello');
      expect(node.position, isNull);
    });

    test('position stores Offset when provided', () {
      final node = TopoNode<int>(id: 'n1', data: 42, position: const Offset(10, 20));
      expect(node.position, const Offset(10, 20));
    });
  });

  group('TopoEdge', () {
    test('constructs with from/to node ids', () {
      final edge = TopoEdge<String>(id: 'e1', fromNodeId: 'a', toNodeId: 'b', data: 'link');
      expect(edge.id, 'e1');
      expect(edge.fromNodeId, 'a');
      expect(edge.toNodeId, 'b');
    });
  });

  group('TopoGroup', () {
    test('holds label and node ids with abnormal flag', () {
      final group = TopoGroup(
        id: 'g1',
        label: 'domain-a',
        nodeIds: ['n1', 'n2'],
        isAbnormal: true,
      );
      expect(group.nodeIds, ['n1', 'n2']);
      expect(group.isAbnormal, isTrue);
    });

    test('isAbnormal defaults to false', () {
      final group = TopoGroup(id: 'g1', label: 'd', nodeIds: ['n1']);
      expect(group.isAbnormal, isFalse);
    });
  });
}
