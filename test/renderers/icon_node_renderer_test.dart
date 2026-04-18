import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/src/core/topo_types.dart';
import 'package:flutter_topo_canvas/src/core/render_context.dart';
import 'package:flutter_topo_canvas/src/renderers/icon_node_renderer.dart';

void main() {
  group('IconNodeRenderer', () {
    testWidgets('renders asset path from assetPath callback', (tester) async {
      final renderer = IconNodeRenderer<String>(
        assetPath: (node) => node.data,
        label: (node) => 'L-${node.id}',
        package: 'flutter_topo_canvas',
      );
      const node = TopoNode<String>(id: 'n1', data: 'assets/images/switch_float.svg');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => renderer.build(
              ctx,
              node,
              _mkRc(),
            ),
          ),
        ),
      ));

      expect(find.text('L-n1'), findsOneWidget);
    });

    test('sizeFor returns configured size', () {
      final renderer = IconNodeRenderer<String>(
        assetPath: (_) => '',
        label: (_) => '',
        size: const Size(120, 90),
      );
      expect(renderer.sizeFor(const TopoNode(id: 'n1', data: 'x')), const Size(120, 90));
    });
  });
}

RenderContext _mkRc() => RenderContext(
      animationValue: 0,
      scale: 1,
      isHovered: false,
      transform: Matrix4.identity(),
      repaintTrigger: _noop,
    );

void _noop() {}
