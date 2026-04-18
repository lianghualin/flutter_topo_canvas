import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_topo_canvas/src/util/viewport_math.dart';

void main() {
  group('boundsOfPositions', () {
    test('returns Rect.zero for empty input', () {
      expect(boundsOfPositions(const {}), Rect.zero);
    });

    test('returns zero-size rect for a single point', () {
      final r = boundsOfPositions(const {'n1': Offset(10, 20)});
      expect(r, const Rect.fromLTWH(10, 20, 0, 0));
    });

    test('returns bounding rect for multiple points', () {
      final r = boundsOfPositions(const {
        'n1': Offset(0, 0),
        'n2': Offset(100, 50),
        'n3': Offset(-10, 80),
      });
      expect(r, const Rect.fromLTWH(-10, 0, 110, 80));
    });
  });

  group('fitViewScale', () {
    test('computes scale that fits content into viewport with padding', () {
      final scale = fitViewScale(
        contentSize: const Size(400, 200),
        viewportSize: const Size(800, 600),
        padding: 40,
      );
      // viewport inner = 720 x 520. Content fits by width: 720/400 = 1.8
      //                                    by height: 520/200 = 2.6
      // use smaller: 1.8
      expect(scale, closeTo(1.8, 0.001));
    });

    test('returns 1.0 when content is empty', () {
      final scale = fitViewScale(
        contentSize: Size.zero,
        viewportSize: const Size(800, 600),
      );
      expect(scale, 1.0);
    });

    test('clamps to maxScale when content is very small', () {
      final scale = fitViewScale(
        contentSize: const Size(10, 10),
        viewportSize: const Size(800, 600),
        maxScale: 2.0,
      );
      expect(scale, 2.0);
    });
  });

  group('fitViewOffset', () {
    test('centres content within viewport at given scale', () {
      final offset = fitViewOffset(
        contentBounds: const Rect.fromLTWH(0, 0, 400, 200),
        viewportSize: const Size(800, 600),
        scale: 1.0,
      );
      // translate so content centre (200, 100) lands at viewport centre (400, 300)
      expect(offset, const Offset(200, 200));
    });
  });

  group('clampScale', () {
    test('clamps within [min, max]', () {
      expect(clampScale(0.05, 0.1, 5.0), 0.1);
      expect(clampScale(10.0, 0.1, 5.0), 5.0);
      expect(clampScale(1.5, 0.1, 5.0), 1.5);
    });
  });
}
