import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/src/core/topo_controller.dart';

void main() {
  group('TopoCanvasController', () {
    late TopoCanvasController c;

    setUp(() => c = TopoCanvasController());

    test('starts at scale 1.0 and zero offset', () {
      expect(c.currentScale, 1.0);
      expect(c.currentOffset, Offset.zero);
    });

    test('zoomTo updates scale and notifies', () {
      var notifications = 0;
      c.addListener(() => notifications++);
      c.zoomTo(2.0);
      expect(c.currentScale, 2.0);
      expect(notifications, 1);
    });

    test('resetZoom returns scale to 1.0', () {
      c.zoomTo(3.0);
      c.resetZoom();
      expect(c.currentScale, 1.0);
    });

    test('fitView dispatches the request to attached canvas', () {
      var fitCalled = 0;
      c.attachFitViewHandler(() => fitCalled++);
      c.fitView();
      expect(fitCalled, 1);
    });

    test('refresh dispatches to attached canvas', () {
      var refreshCalled = 0;
      c.attachRefreshHandler(() => refreshCalled++);
      c.refresh();
      expect(refreshCalled, 1);
    });

    test('fitView and refresh are no-ops when no canvas attached', () {
      expect(c.fitView, returnsNormally);
      expect(c.refresh, returnsNormally);
    });

    test('updateViewport updates current scale and offset without notify', () {
      var notifications = 0;
      c.addListener(() => notifications++);
      c.updateViewport(scale: 1.5, offset: const Offset(10, 20));
      expect(c.currentScale, 1.5);
      expect(c.currentOffset, const Offset(10, 20));
      expect(notifications, 0);
    });
  });
}
