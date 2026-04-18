import 'package:flutter/material.dart';
import 'topo_controller.dart';

/// The default toolbar overlaid on a [TopologyCanvas].
///
/// Contains fit-view, reset-zoom, refresh buttons, plus any [extras] the
/// caller supplies (typically a legend button). Sits top-right by default.
class TopoToolbar extends StatelessWidget {
  final TopoCanvasController controller;
  final List<Widget> extras;

  const TopoToolbar({
    super.key,
    required this.controller,
    this.extras = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: 12,
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Fit view',
                icon: const Icon(Icons.center_focus_strong),
                onPressed: controller.fitView,
              ),
              IconButton(
                tooltip: 'Reset zoom',
                icon: const Icon(Icons.zoom_out_map),
                onPressed: controller.resetZoom,
              ),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: controller.refresh,
              ),
              ...extras,
            ],
          ),
        ),
      ),
    );
  }
}
