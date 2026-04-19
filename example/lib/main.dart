// example/lib/main.dart
import 'dart:ui' as ui show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter_topo_canvas/flutter_topo_canvas.dart';
import 'package:topology_view_icons/topology_view_icons.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_topo_canvas demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_topo_canvas'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Cloud network'),
              Tab(text: 'Switch relation'),
              Tab(text: 'Raw canvas'),
              Tab(text: 'Interactive'),
              Tab(text: 'Dynamic'),
              Tab(text: 'Hover debug'),
            ],
          ),
        ),
        body: const TabBarView(children: [
          CloudNetworkDemo(),
          SwitchRelationDemo(),
          RawCanvasDemo(),
          InteractiveDemo(),
          DynamicDemo(),
          HoverDebugDemo(),
        ]),
      ),
    );
  }
}

class CloudNetworkDemo extends StatelessWidget {
  const CloudNetworkDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const CloudNetworkView(
      domains: [
        CloudDomain(
          name: 'root',
          isRoot: true,
          networks: [
            CloudNetwork(name: 'vpc-a'),
            CloudNetwork(name: 'vpc-b'),
            CloudNetwork(name: 'vpc-c', isAbnormal: true),
          ],
        ),
        CloudDomain(
          name: 'edge',
          networks: [
            CloudNetwork(name: 'edge-1'),
            CloudNetwork(name: 'edge-2'),
          ],
        ),
      ],
      connections: [
        CloudEdge(fromNetworkName: 'vpc-a', toNetworkName: 'edge-1'),
        CloudEdge(fromNetworkName: 'vpc-b', toNetworkName: 'edge-2'),
      ],
    );
  }
}

class SwitchRelationDemo extends StatelessWidget {
  const SwitchRelationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const SwitchRelationView(
      switches: [
        SwitchNode(name: 'core-1'),
        SwitchNode(name: 'core-2'),
        SwitchNode(name: 'agg-1'),
        SwitchNode(name: 'agg-2'),
        SwitchNode(name: 'tor-1'),
        SwitchNode(name: 'tor-2'),
        SwitchNode(name: 'tor-err', isAbnormal: true),
        SwitchNode(name: 'tor-4'),
      ],
      connections: [
        SwitchEdge(fromSwitchName: 'core-1', toSwitchName: 'agg-1'),
        SwitchEdge(fromSwitchName: 'core-2', toSwitchName: 'agg-2'),
        SwitchEdge(fromSwitchName: 'agg-1', toSwitchName: 'tor-1'),
        SwitchEdge(fromSwitchName: 'agg-1', toSwitchName: 'tor-2'),
        SwitchEdge(fromSwitchName: 'agg-2', toSwitchName: 'tor-err'),
        SwitchEdge(fromSwitchName: 'agg-2', toSwitchName: 'tor-4'),
        // Back-edge exercising cycle handling:
        SwitchEdge(fromSwitchName: 'tor-2', toSwitchName: 'core-1'),
      ],
      colorful: true,
    );
  }
}

class RawCanvasDemo extends StatelessWidget {
  const RawCanvasDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopologyCanvas<String, String>(
      nodes: [
        TopoNode(id: 'a', data: 'Alpha'),
        TopoNode(id: 'b', data: 'Beta'),
        TopoNode(id: 'c', data: 'Gamma'),
      ],
      edges: [
        TopoEdge(id: 'ab', fromNodeId: 'a', toNodeId: 'b', data: ''),
        TopoEdge(id: 'bc', fromNodeId: 'b', toNodeId: 'c', data: ''),
      ],
      layout: HierarchicalLayout(rootNodeId: 'a'),
      nodeRenderer: _CircleNodeRenderer(),
      edgeRenderer: AnimatedLineRenderer<String>(),
    );
  }
}

class _CircleNodeRenderer extends NodeRenderer<String> {
  const _CircleNodeRenderer();

  @override
  Size sizeFor(TopoNode<String> node) => const Size(60, 60);

  @override
  Widget build(BuildContext context, TopoNode<String> node, RenderContext rc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.teal,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(node.id.toUpperCase(),
              style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(node.data),
      ],
    );
  }
}

/// Tab 4 — external [TopoCanvasController] drives fit/reset from outside the
/// canvas, and [SwitchRelationView.onSwitchTap] drives a selection banner.
class InteractiveDemo extends StatefulWidget {
  const InteractiveDemo({super.key});

  @override
  State<InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<InteractiveDemo> {
  final _controller = TopoCanvasController();
  String? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selected == null
                        ? 'Tap a switch to select it'
                        : 'Selected: $_selected',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _controller.fitView,
                  icon: const Icon(Icons.center_focus_strong),
                  label: const Text('Fit'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _controller.resetZoom,
                  icon: const Icon(Icons.zoom_out_map),
                  label: const Text('Reset zoom'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _selected == null
                      ? null
                      : () => setState(() => _selected = null),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SwitchRelationView(
            controller: _controller,
            showToolbar: false,
            switches: const [
              SwitchNode(name: 'gw'),
              SwitchNode(name: 'core-1'),
              SwitchNode(name: 'core-2'),
              SwitchNode(name: 'leaf-a'),
              SwitchNode(name: 'leaf-b'),
              SwitchNode(name: 'leaf-c', isAbnormal: true),
            ],
            connections: const [
              SwitchEdge(fromSwitchName: 'gw', toSwitchName: 'core-1'),
              SwitchEdge(fromSwitchName: 'gw', toSwitchName: 'core-2'),
              SwitchEdge(fromSwitchName: 'core-1', toSwitchName: 'leaf-a'),
              SwitchEdge(fromSwitchName: 'core-1', toSwitchName: 'leaf-b'),
              SwitchEdge(fromSwitchName: 'core-2', toSwitchName: 'leaf-c'),
            ],
            onSwitchTap: (name) => setState(() => _selected = name),
          ),
        ),
      ],
    );
  }
}

/// Tab 5 — mutating the data list forces the layout to recompute on rebuild,
/// so add/remove just calls setState with fresh lists.
class DynamicDemo extends StatefulWidget {
  const DynamicDemo({super.key});

  @override
  State<DynamicDemo> createState() => _DynamicDemoState();
}

class _DynamicDemoState extends State<DynamicDemo> {
  final List<SwitchNode> _switches = [
    const SwitchNode(name: 'core'),
    const SwitchNode(name: 'sw-1'),
  ];
  final List<SwitchEdge> _edges = [
    const SwitchEdge(fromSwitchName: 'core', toSwitchName: 'sw-1'),
  ];
  int _counter = 1;

  void _addSwitch() {
    _counter++;
    final name = 'sw-$_counter';
    setState(() {
      _switches.add(SwitchNode(name: name));
      _edges.add(SwitchEdge(fromSwitchName: 'core', toSwitchName: name));
    });
  }

  void _removeLast() {
    if (_switches.length <= 1) return;
    final name = _switches.removeLast().name;
    setState(() {
      _edges.removeWhere(
        (e) => e.fromSwitchName == name || e.toSwitchName == name,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_switches.length} switches, ${_edges.length} edges',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _addSwitch,
                  icon: const Icon(Icons.add),
                  label: const Text('Add switch'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _switches.length > 1 ? _removeLast : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove last'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SwitchRelationView(
            switches: List.unmodifiable(_switches),
            connections: List.unmodifiable(_edges),
            rootSwitchName: 'core',
          ),
        ),
      ],
    );
  }
}

/// Tab 6 — isolates the hover-float animation *outside* any TopologyCanvas, so
/// we can tell whether a failure is in the animation technique itself or in
/// how the canvas routes pointer events.
class HoverDebugDemo extends StatefulWidget {
  const HoverDebugDemo({super.key});

  @override
  State<HoverDebugDemo> createState() => _HoverDebugDemoState();
}

class _HoverDebugDemoState extends State<HoverDebugDemo> {
  double _lift = 2;
  double _blur = 8;
  double _offset = 4;
  double _opacity = 0.2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hover the two icons below. Each card shows its own '
            '_hovered flag and the live animated translate value.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'Lift distance',
            value: _lift,
            min: 0,
            max: 30,
            divisions: 30,
            display: (v) => '${v.toStringAsFixed(0)} px',
            onChanged: (v) => setState(() => _lift = v),
          ),
          _SliderRow(
            label: 'Shadow blur',
            value: _blur,
            min: 0,
            max: 30,
            divisions: 30,
            display: (v) => '${v.toStringAsFixed(0)} px',
            onChanged: (v) => setState(() => _blur = v),
          ),
          _SliderRow(
            label: 'Shadow offset',
            value: _offset,
            min: 0,
            max: 20,
            divisions: 20,
            display: (v) => '${v.toStringAsFixed(0)} px',
            onChanged: (v) => setState(() => _offset = v),
          ),
          _SliderRow(
            label: 'Shadow opacity',
            value: _opacity,
            min: 0,
            max: 1,
            divisions: 20,
            display: (v) => v.toStringAsFixed(2),
            onChanged: (v) => setState(() => _opacity = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TweenBuilderCard(
                  lift: _lift,
                  maxBlur: _blur,
                  maxOffset: _offset,
                  maxOpacity: _opacity,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _ControllerCard(
                  lift: _lift,
                  maxBlur: _blur,
                  maxOffset: _offset,
                  maxOpacity: _opacity,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) display;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value,
            label: display(value),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 70,
          child: Text(
            display(value),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

/// Mirrors the library's current `DeviceIconNodeRenderer` technique:
/// `TweenAnimationBuilder<double>` driven by a bool.
class _TweenBuilderCard extends StatefulWidget {
  final double lift;
  final double maxBlur;
  final double maxOffset;
  final double maxOpacity;
  const _TweenBuilderCard({
    required this.lift,
    required this.maxBlur,
    required this.maxOffset,
    required this.maxOpacity,
  });

  @override
  State<_TweenBuilderCard> createState() => _TweenBuilderCardState();
}

class _TweenBuilderCardState extends State<_TweenBuilderCard> {
  bool _hovered = false;
  double _lastValue = 0;

  @override
  Widget build(BuildContext context) {
    final target = _hovered ? -widget.lift : 0.0;
    return _DebugCard(
      title: 'TweenAnimationBuilder',
      hovered: _hovered,
      translate: _lastValue,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: SizedBox(
          width: 160,
          height: 160,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: target),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                // Stash latest value for the readout (post-frame to avoid
                // setState during build).
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (_lastValue != value) setState(() => _lastValue = value);
                });
                final progress = widget.lift == 0
                    ? (_hovered ? 1.0 : 0.0)
                    : (-value / widget.lift).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, value),
                  child: _ShadowWrap(
                    progress: progress,
                    maxBlur: widget.maxBlur,
                    maxOffset: widget.maxOffset,
                    maxOpacity: widget.maxOpacity,
                    child: child!,
                  ),
                );
              },
              child: const CustomPaint(
                size: Size(120, 120),
                painter: TopoIconPainter(
                  deviceType: TopoDeviceType.network,
                  isError: false,
                  style: TopoIconStyle.lnm,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Proposed fix: explicit `AnimationController` + `AnimatedBuilder` +
/// `Transform.translate`. This is the pattern Material's hover overlays use.
class _ControllerCard extends StatefulWidget {
  final double lift;
  final double maxBlur;
  final double maxOffset;
  final double maxOpacity;
  const _ControllerCard({
    required this.lift,
    required this.maxBlur,
    required this.maxOffset,
    required this.maxOpacity,
  });

  @override
  State<_ControllerCard> createState() => _ControllerCardState();
}

class _ControllerCardState extends State<_ControllerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _curve;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, _) {
        final translate = -widget.lift * _curve.value;
        return _DebugCard(
          title: 'AnimationController',
          hovered: _hovered,
          translate: translate,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _hovered = true);
              _ctrl.forward();
            },
            onExit: (_) {
              setState(() => _hovered = false);
              _ctrl.reverse();
            },
            child: SizedBox(
              width: 160,
              height: 160,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, translate),
                  child: _ShadowWrap(
                    progress: _curve.value,
                    maxBlur: widget.maxBlur,
                    maxOffset: widget.maxOffset,
                    maxOpacity: widget.maxOpacity,
                    child: const CustomPaint(
                      size: Size(120, 120),
                      painter: TopoIconPainter(
                        deviceType: TopoDeviceType.switch_,
                        isError: false,
                        style: TopoIconStyle.lnm,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DebugCard extends StatelessWidget {
  final String title;
  final bool hovered;
  final double translate;
  final Widget child;

  const _DebugCard({
    required this.title,
    required this.hovered,
    required this.translate,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                _Pill(
                  label: 'hovered',
                  value: hovered ? 'TRUE' : 'false',
                  color: hovered ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                _Pill(
                  label: 'translate',
                  value: '${translate.toStringAsFixed(1)} px',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Pill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: color,
        ),
      ),
    );
  }
}

/// Wraps [child] in a silhouette drop shadow whose blur, offset, and opacity
/// each scale linearly from 0 (at rest) up to their peak values at full hover.
/// Uses the icon's alpha channel (via [BlendMode.srcIn] + `ImageFilter.blur`)
/// so the shadow hugs the actual shape, not the widget's rectangular bounds.
class _ShadowWrap extends StatelessWidget {
  final double progress;
  final double maxBlur;
  final double maxOffset;
  final double maxOpacity;
  final Widget child;

  const _ShadowWrap({
    required this.progress,
    required this.maxBlur,
    required this.maxOffset,
    required this.maxOpacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    final blur = maxBlur * t;
    final dy = maxOffset * t;
    final opacity = maxOpacity * t;
    if (opacity <= 0 || (blur <= 0 && dy <= 0)) return child;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, dy),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                // ignore: deprecated_member_use
                Colors.black.withOpacity(opacity),
                BlendMode.srcIn,
              ),
              child: child,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
