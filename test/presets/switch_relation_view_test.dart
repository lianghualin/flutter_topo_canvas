import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/flutter_topo_canvas.dart';

void main() {
  testWidgets('SwitchRelationView renders switches', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: SwitchRelationView(
            switches: [
              SwitchNode(name: 'sw-1'),
              SwitchNode(name: 'sw-2'),
              SwitchNode(name: 'sw-err', isAbnormal: true),
            ],
            connections: [
              SwitchEdge(fromSwitchName: 'sw-1', toSwitchName: 'sw-2'),
              SwitchEdge(fromSwitchName: 'sw-2', toSwitchName: 'sw-err'),
            ],
            showToolbar: false,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('sw-1'), findsOneWidget);
    expect(find.text('sw-2'), findsOneWidget);
    expect(find.text('sw-err'), findsOneWidget);
  });

  testWidgets('SwitchRelationView survives a graph with a cycle', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: SwitchRelationView(
            switches: [
              SwitchNode(name: 'a'),
              SwitchNode(name: 'b'),
              SwitchNode(name: 'c'),
            ],
            connections: [
              SwitchEdge(fromSwitchName: 'a', toSwitchName: 'b'),
              SwitchEdge(fromSwitchName: 'b', toSwitchName: 'c'),
              SwitchEdge(fromSwitchName: 'c', toSwitchName: 'a'),
            ],
            showToolbar: false,
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('c'), findsOneWidget);
  });
}
