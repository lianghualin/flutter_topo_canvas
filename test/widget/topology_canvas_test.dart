import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/flutter_topo_canvas.dart';

void main() {
  testWidgets('TopologyCanvas renders two nodes and one edge', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: TopologyCanvas<String, String>(
            nodes: const [
              TopoNode(id: 'a', data: 'A'),
              TopoNode(id: 'b', data: 'B'),
            ],
            edges: const [
              TopoEdge(id: 'e1', fromNodeId: 'a', toNodeId: 'b', data: ''),
            ],
            layout: const HierarchicalLayout(rootNodeId: 'a'),
            nodeRenderer: IconNodeRenderer<String>(
              assetPath: (_) => 'assets/images/switch_float.svg',
              label: (n) => n.data,
              package: 'flutter_topo_canvas',
            ),
            edgeRenderer: const AnimatedLineRenderer<String>(),
            showToolbar: false,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('toolbar shows when showToolbar: true', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 400,
          height: 400,
          child: TopologyCanvas<String, String>(
            nodes: const [TopoNode(id: 'a', data: 'A')],
            edges: const [],
            layout: const HierarchicalLayout(rootNodeId: 'a'),
            nodeRenderer: IconNodeRenderer<String>(
              assetPath: (_) => 'assets/images/switch_float.svg',
              label: (n) => n.data,
              package: 'flutter_topo_canvas',
            ),
            edgeRenderer: const AnimatedLineRenderer<String>(),
            showToolbar: true,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
  });
}
