import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Imperative control for a [TopologyCanvas].
///
/// Canvas attaches handlers for viewport-altering operations (fit, refresh);
/// the controller tracks the canvas's current scale and offset so callers can
/// read them without prying into canvas state.
class TopoCanvasController extends ChangeNotifier {
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  VoidCallback? _fitViewHandler;
  VoidCallback? _refreshHandler;

  double get currentScale => _scale;
  Offset get currentOffset => _offset;

  /// Requests a fit-to-viewport. No-op if no canvas is attached.
  void fitView() => _fitViewHandler?.call();

  /// Requests a re-layout (e.g. after data change). No-op if no canvas is attached.
  void refresh() => _refreshHandler?.call();

  /// Resets zoom to 1.0. Also notifies listeners.
  void resetZoom() {
    _scale = 1.0;
    notifyListeners();
  }

  /// Zooms to [scale]. Notifies listeners.
  void zoomTo(double scale) {
    _scale = scale;
    notifyListeners();
  }

  /// Called by the canvas when the viewport changes through pan/zoom gestures.
  /// Does NOT notify listeners — pan/zoom happens every frame during a gesture
  /// and listener-driven rebuilds would thrash.
  void updateViewport({required double scale, required Offset offset}) {
    _scale = scale;
    _offset = offset;
  }

  /// Canvas calls this in `initState` / `didChangeDependencies`.
  @internal
  void attachFitViewHandler(VoidCallback handler) => _fitViewHandler = handler;

  /// Canvas calls this in `initState` / `didChangeDependencies`.
  @internal
  void attachRefreshHandler(VoidCallback handler) => _refreshHandler = handler;

  @internal
  void detach() {
    _fitViewHandler = null;
    _refreshHandler = null;
  }
}
