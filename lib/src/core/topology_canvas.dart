import 'package:flutter/material.dart';
import '../layout/topology_layout.dart';
import '../renderers/node_renderer.dart';
import '../renderers/edge_renderer.dart';
import '../renderers/group_renderer.dart';
import '../util/viewport_math.dart';
import 'topo_types.dart';
import 'topo_controller.dart';
import 'topo_toolbar.dart';
import 'render_context.dart';

class TopologyCanvas<TNode, TEdge> extends StatefulWidget {
  final List<TopoNode<TNode>> nodes;
  final List<TopoEdge<TEdge>> edges;
  final List<TopoGroup> groups;

  final TopologyLayout layout;
  final NodeRenderer<TNode> nodeRenderer;
  final EdgeRenderer<TEdge> edgeRenderer;
  final GroupRenderer? groupRenderer;

  final TopoCanvasController? controller;
  final bool showToolbar;
  final List<Widget>? toolbarExtras;

  final void Function(String nodeId)? onNodeTap;
  final void Function(String edgeId)? onEdgeTap;

  final double minScale;
  final double maxScale;
  final bool autoFitOnFirstBuild;

  const TopologyCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.groups = const [],
    required this.layout,
    required this.nodeRenderer,
    required this.edgeRenderer,
    this.groupRenderer,
    this.controller,
    this.showToolbar = true,
    this.toolbarExtras,
    this.onNodeTap,
    this.onEdgeTap,
    this.minScale = 0.1,
    this.maxScale = 5.0,
    this.autoFitOnFirstBuild = true,
  });

  @override
  State<TopologyCanvas<TNode, TEdge>> createState() =>
      _TopologyCanvasState<TNode, TEdge>();
}

class _TopologyCanvasState<TNode, TEdge>
    extends State<TopologyCanvas<TNode, TEdge>>
    with SingleTickerProviderStateMixin {
  // The InteractiveViewer child is a 4000×4000 SizedBox; drawing happens in a
  // sub-tree positioned at this offset so that negative-coordinate content
  // still falls within the child. `_fitView` must compensate for this shift.
  static const _innerOrigin = Offset(2000, 2000);

  Map<String, Offset> _positions = const {};
  late AnimationController _ticker;
  final TransformationController _xform = TransformationController();
  Size _lastViewport = const Size(800, 600);

  late final TopoCanvasController _ownedController;

  TopoCanvasController get _effectiveController =>
      widget.controller ?? _ownedController;

  @override
  void initState() {
    super.initState();
    _ownedController = widget.controller ?? TopoCanvasController();
    _ticker = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _runLayout();

    _effectiveController.attachFitViewHandler(_fitView);
    _effectiveController.attachRefreshHandler(() => setState(_runLayout));

    if (widget.autoFitOnFirstBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitView());
    }
  }

  @override
  void didUpdateWidget(covariant TopologyCanvas<TNode, TEdge> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_layoutInputsChanged(oldWidget)) _runLayout();
  }

  bool _layoutInputsChanged(TopologyCanvas<TNode, TEdge> old) {
    if (old.layout != widget.layout) return true;
    if (old.nodes.length != widget.nodes.length) return true;
    if (old.edges.length != widget.edges.length) return true;
    if (old.groups.length != widget.groups.length) return true;
    final oldIds = old.nodes.map((n) => n.id).toSet();
    final newIds = widget.nodes.map((n) => n.id).toSet();
    return !oldIds.containsAll(newIds);
  }

  void _runLayout() {
    final explicit = <String, Offset>{
      for (final n in widget.nodes)
        if (n.position != null) n.id: n.position!,
    };

    final computed = widget.layout.computePositions(
      nodeIds: widget.nodes.map((n) => n.id).toList(),
      edges: widget.edges.map((e) => (e.fromNodeId, e.toNodeId)).toList(),
      groups: widget.groups,
      viewport: _lastViewport,
    );
    _positions = {...computed, ...explicit};
  }

  void _fitView() {
    final bounds = boundsOfPositions(_positions);
    if (bounds == Rect.zero) return;

    final scale = fitViewScale(
      contentSize: bounds.size,
      viewportSize: _lastViewport,
    );
    final baseOffset = fitViewOffset(
      contentBounds: bounds,
      viewportSize: _lastViewport,
      scale: scale,
    );
    // Compensate for the inner-origin shift: nodes drawn at content-coord (px,py)
    // land on the child at (_innerOrigin + (px,py)); the raw matrix translation
    // must cancel out scale*_innerOrigin so content-centre maps to view-centre.
    final offset = baseOffset - _innerOrigin * scale;

    _xform.value = Matrix4.identity()
      ..translateByDouble(offset.dx, offset.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
    _effectiveController.updateViewport(scale: scale, offset: offset);
  }

  @override
  void dispose() {
    _effectiveController.detach();
    if (widget.controller == null) _ownedController.dispose();
    _ticker.dispose();
    _xform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _lastViewport = Size(constraints.maxWidth, constraints.maxHeight);
        final contentBounds = boundsOfPositions(_positions);

        final viewer = InteractiveViewer(
          transformationController: _xform,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          boundaryMargin: const EdgeInsets.all(2000),
          constrained: false,
          onInteractionUpdate: (_) {
            final m = _xform.value;
            _effectiveController.updateViewport(
              scale: m.getMaxScaleOnAxis(),
              offset: Offset(m.getTranslation().x, m.getTranslation().y),
            );
          },
          child: SizedBox(
            width: 4000,
            height: 4000,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Each layer fills the 4000×4000 space so pointer events
                // reach descendants at any in-bounds coordinate. Content
                // positions are shifted by _innerOrigin *inside* each layer
                // rather than via a wrapping Positioned, because a
                // position-shifted wrapper with a small size silently drops
                // hit-tests for pointers that fall outside its own rect.
                Positioned.fill(
                    child: _buildEdgeLayer(contentBounds, _lastViewport)),
                Positioned.fill(
                    child: _buildGroupLayer(contentBounds, _lastViewport)),
                Positioned.fill(child: _buildNodeLayer(_lastViewport)),
              ],
            ),
          ),
        );

        return Stack(
          children: [
            viewer,
            if (widget.showToolbar)
              TopoToolbar(
                controller: _effectiveController,
                extras: widget.toolbarExtras ?? const [],
              ),
          ],
        );
      },
    );
  }

  Widget _buildEdgeLayer(Rect contentBounds, Size viewport) {
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        return CustomPaint(
          size: viewport,
          painter: _EdgePainter<TEdge>(
            edges: widget.edges,
            positions: _positions,
            renderer: widget.edgeRenderer,
            animationValue: _ticker.value,
            originShift: _innerOrigin,
          ),
        );
      },
    );
  }

  Widget _buildGroupLayer(Rect contentBounds, Size viewport) {
    if (widget.groupRenderer == null || widget.groups.isEmpty) {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      size: viewport,
      painter: _GroupPainter(
        groups: widget.groups,
        positions: _positions,
        nodeSizes: {
          for (final n in widget.nodes)
            n.id: widget.nodeRenderer.sizeFor(n),
        },
        renderer: widget.groupRenderer!,
        originShift: _innerOrigin,
      ),
    );
  }

  Widget _buildNodeLayer(Size viewport) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final node in widget.nodes)
          Positioned(
            left: _innerOrigin.dx +
                (_positions[node.id]?.dx ?? 0) -
                widget.nodeRenderer.sizeFor(node).width / 2,
            top: _innerOrigin.dy +
                (_positions[node.id]?.dy ?? 0) -
                widget.nodeRenderer.sizeFor(node).height / 2,
            child: GestureDetector(
              onTap: () => widget.onNodeTap?.call(node.id),
              child: widget.nodeRenderer.build(
                context,
                node,
                RenderContext(
                  animationValue: _ticker.value,
                  scale: _xform.value.getMaxScaleOnAxis(),
                  isHovered: false,
                  transform: _xform.value,
                  repaintTrigger: () => setState(() {}),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _EdgePainter<T> extends CustomPainter {
  final List<TopoEdge<T>> edges;
  final Map<String, Offset> positions;
  final EdgeRenderer<T> renderer;
  final double animationValue;
  final Offset originShift;

  _EdgePainter({
    required this.edges,
    required this.positions,
    required this.renderer,
    required this.animationValue,
    required this.originShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rc = RenderContext(
      animationValue: animationValue,
      scale: 1.0,
      isHovered: false,
      transform: Matrix4.identity(),
      repaintTrigger: () {},
    );
    for (final edge in edges) {
      final from = positions[edge.fromNodeId];
      final to = positions[edge.toNodeId];
      if (from == null || to == null) continue;
      renderer.paint(canvas, edge, from + originShift, to + originShift, rc);
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter<T> oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.edges != edges;
}

class _GroupPainter extends CustomPainter {
  final List<TopoGroup> groups;
  final Map<String, Offset> positions;
  final Map<String, Size> nodeSizes;
  final GroupRenderer renderer;
  final Offset originShift;

  _GroupPainter({
    required this.groups,
    required this.positions,
    required this.nodeSizes,
    required this.renderer,
    required this.originShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final group in groups) {
      final bounds = _boundsOfGroup(group);
      if (bounds == null) continue;
      renderer.paint(canvas, group, bounds);
    }
  }

  Rect? _boundsOfGroup(TopoGroup group) {
    Rect? acc;
    for (final id in group.nodeIds) {
      final pos = positions[id];
      final size = nodeSizes[id] ?? const Size(80, 80);
      if (pos == null) continue;
      final nodeRect = Rect.fromCenter(
        center: pos + originShift,
        width: size.width,
        height: size.height,
      );
      acc = acc?.expandToInclude(nodeRect) ?? nodeRect;
    }
    return acc;
  }

  @override
  bool shouldRepaint(covariant _GroupPainter oldDelegate) =>
      oldDelegate.groups != groups || oldDelegate.positions != positions;
}
