import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/flutter_topo_canvas.dart';

void main() {
  testWidgets('CloudNetworkView renders domain networks', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: CloudNetworkView(
            domains: const [
              CloudDomain(
                name: 'root',
                isRoot: true,
                networks: [CloudNetwork(name: 'net-a'), CloudNetwork(name: 'net-b')],
              ),
            ],
            connections: const [CloudEdge(fromNetworkName: 'net-a', toNetworkName: 'net-b')],
            showToolbar: false,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('net-a'), findsOneWidget);
    expect(find.text('net-b'), findsOneWidget);
  });

  testWidgets('showGroups: false hides domain ellipse but still renders nodes',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: CloudNetworkView(
            domains: const [
              CloudDomain(
                name: 'root',
                isRoot: true,
                networks: [CloudNetwork(name: 'n1')],
              ),
            ],
            connections: const [],
            showGroups: false,
            showToolbar: false,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('n1'), findsOneWidget);
  });
}
