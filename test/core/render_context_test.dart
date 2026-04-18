import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/src/core/render_context.dart';

void main() {
  group('RenderContext', () {
    test('exposes animation value, scale, hover, transform', () {
      var repaintCount = 0;
      final rc = RenderContext(
        animationValue: 0.5,
        scale: 1.2,
        isHovered: true,
        transform: Matrix4.identity(),
        repaintTrigger: () => repaintCount++,
      );

      expect(rc.animationValue, 0.5);
      expect(rc.scale, 1.2);
      expect(rc.isHovered, isTrue);
      expect(rc.transform, Matrix4.identity());

      rc.repaintTrigger();
      expect(repaintCount, 1);
    });
  });
}
