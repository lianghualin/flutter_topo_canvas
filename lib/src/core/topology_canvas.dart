import 'package:flutter/material.dart';
import '../layout/topology_layout.dart';
import '../renderers/node_renderer.dart';
import '../renderers/edge_renderer.dart';
import '../renderers/group_renderer.dart';
import '../util/svg_cache.dart';
import '../util/viewport_math.dart';
import 'topo_types.dart';
import 'topo_controller.dart';
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
  Map<String, Offset> _positions = const {};
  late AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _runLayout();
    SvgCache.preloadBuiltInAssets();
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
      viewport: const Size(800, 600), // replaced in Task 17 when viewport known
    );
    _positions = {...computed, ...explicit};
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final contentBounds = boundsOfPositions(_positions);

        return Stack(
          children: [
            _buildEdgeLayer(contentBounds, viewport),
            _buildGroupLayer(contentBounds, viewport),
            _buildNodeLayer(viewport),
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
      ),
    );
  }

  Widget _buildNodeLayer(Size viewport) {
    return Stack(
      children: [
        for (final node in widget.nodes)
          Positioned(
            left: (_positions[node.id]?.dx ?? 0) -
                widget.nodeRenderer.sizeFor(node).width / 2,
            top: (_positions[node.id]?.dy ?? 0) -
                widget.nodeRenderer.sizeFor(node).height / 2,
            child: GestureDetector(
              onTap: () => widget.onNodeTap?.call(node.id),
              child: widget.nodeRenderer.build(
                context,
                node,
                RenderContext(
                  animationValue: _ticker.value,
                  scale: 1.0,
                  isHovered: false,
                  transform: Matrix4.identity(),
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

  _EdgePainter({
    required this.edges,
    required this.positions,
    required this.renderer,
    required this.animationValue,
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
      renderer.paint(canvas, edge, from, to, rc);
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

  _GroupPainter({
    required this.groups,
    required this.positions,
    required this.nodeSizes,
    required this.renderer,
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
        center: pos,
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
