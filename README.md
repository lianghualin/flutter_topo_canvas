# flutter_topo_canvas

[![pub.dev](https://img.shields.io/pub/v/flutter_topo_canvas.svg)](https://pub.dev/packages/flutter_topo_canvas)

A generic topology canvas with pluggable layouts and renderers. Ships two ready-made presets (`CloudNetworkView`, `SwitchRelationView`) and a low-level `TopologyCanvas` for custom use.

## Features

- **Generic core** — `TopologyCanvas<TNode, TEdge>` takes any node/edge data.
- **Pluggable layout** — abstract `TopologyLayout`; built-in `HierarchicalLayout` (handles cycles) and `EllipseGroupLayout`.
- **Pluggable renderers** — `NodeRenderer`, `EdgeRenderer`, `GroupRenderer` interfaces; built-in icon + animated-line + ellipse-group renderers.
- **Canvas-drawn device icons** — `DeviceIconNodeRenderer` uses [`topology_view_icons`](https://pub.dev/packages/topology_view_icons). No asset bundling, crisp at any zoom.
- **Tunable icon size on presets** — pass `iconSize` to `CloudNetworkView` / `SwitchRelationView` without dropping to the low-level canvas.
- **External-domain fading** — flag a `SwitchNode` as `isExternal` to render it at 50% opacity and visually separate context-only neighbours from the primary domain.
- **Readable labels** — labels sit on a translucent plate flush against the icon, so animated edge lines passing through don't obscure the text.
- **Hover-float + silhouette shadow** — configurable lift and drop-shadow on pointer hover (web/desktop). Tunable per renderer.
- **Pan / zoom / fit-view** — via `InteractiveViewer`, with a default toolbar and an imperative `TopoCanvasController`. Fit-view frames the full visual content, including group ellipses.
- **Decorative groups** — optional boundaries around node subsets. Toggle on/off without affecting layout.

## Quickstart — CloudNetworkView

```dart
CloudNetworkView(
  domains: const [
    CloudDomain(
      name: 'root',
      isRoot: true,
      networks: [
        CloudNetwork(name: 'vpc-a'),
        CloudNetwork(name: 'vpc-b', isAbnormal: true),
      ],
    ),
  ],
  connections: const [
    CloudEdge(fromNetworkName: 'vpc-a', toNetworkName: 'vpc-b'),
  ],
  iconSize: const Size(80, 48),  // default; tweak to taste
  onNetworkTap: (name) => debugPrint('tapped $name'),
);
```

## Quickstart — SwitchRelationView

```dart
SwitchRelationView(
  switches: const [
    SwitchNode(name: 'core-1'),
    SwitchNode(name: 'agg-1'),
    // Rendered at 50% opacity — context from a neighbouring domain.
    SwitchNode(name: 'tor-1', isExternal: true),
  ],
  connections: const [
    SwitchEdge(fromSwitchName: 'core-1', toSwitchName: 'agg-1'),
    SwitchEdge(fromSwitchName: 'agg-1', toSwitchName: 'tor-1'),
  ],
  iconSize: const Size(60, 60),  // default; tweak to taste
  colorful: true,
);
```

## Low-level canvas

```dart
TopologyCanvas<MyNode, MyEdge>(
  nodes: nodes,
  edges: edges,
  layout: const HierarchicalLayout(rootNodeId: 'root'),
  nodeRenderer: MyNodeRenderer(),
  edgeRenderer: const AnimatedLineRenderer<MyEdge>(),
  onNodeTap: (id) => ...,
);
```

## Device icons (`DeviceIconNodeRenderer`)

Draw any of the device shapes from [`topology_view_icons`](https://pub.dev/packages/topology_view_icons) without bundling SVGs.

```dart
TopologyCanvas<MyNode, MyEdge>(
  nodes: nodes,
  edges: edges,
  layout: const HierarchicalLayout(rootNodeId: 'root'),
  nodeRenderer: DeviceIconNodeRenderer<MyNode>(
    deviceType:  (n) => TopoDeviceType.switch_,
    isError:     (n) => n.data.down,
    isExternal:  (n) => n.data.foreignDomain,  // optional — 50% opacity when true
    label:       (n) => n.data.name,
    size:        const Size(60, 60),
    style:       TopoIconStyle.lnm,
    hoverFloat:    true,
    liftDistance:  2.0,   // px up on hover
    shadowBlur:    3.0,   // sigma at peak
    shadowOffset:  0.0,   // y-drop at peak
    shadowOpacity: 0.20,  // at peak, linearly scaled by hover progress
    externalOpacity: 0.5, // override the fade amount if you like
  ),
  edgeRenderer: const AnimatedLineRenderer<MyEdge>(),
);
```

Available `TopoDeviceType` values include `switch_`, `router`, `firewall`, `server`, `network` (cloud), and more — see the [topology_view_icons docs](https://pub.dev/packages/topology_view_icons).

## Controlling the canvas

Attach a `TopoCanvasController` to drive fit-view, reset-zoom, or refresh from outside the widget.

```dart
final controller = TopoCanvasController();

// ...
SwitchRelationView(
  controller: controller,
  switches: switches,
  connections: connections,
);

// Later:
controller.fitView();       // recenter + auto-zoom to content
controller.resetZoom();     // snap back to 100%
controller.refresh();       // recompute layout (e.g. after data change)
```

Dispose the controller when you own it: `controller.dispose()` in your `State.dispose`.

## Extending

Implement one of:

- `TopologyLayout` — your own positioning algorithm.
- `NodeRenderer<T>` — custom widget per node.
- `EdgeRenderer<T>` — custom line, curve, or animated effect.
- `GroupRenderer` — different boundary shape (rectangle, hull, etc.).

Minimal custom node renderer:

```dart
class CircleNodeRenderer extends NodeRenderer<String> {
  const CircleNodeRenderer();

  @override
  Size sizeFor(TopoNode<String> node) => const Size(60, 60);

  @override
  Widget build(BuildContext context, TopoNode<String> node, RenderContext rc) {
    return Container(
      width: 60, height: 60,
      decoration: const BoxDecoration(
        color: Colors.teal, shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(node.id, style: const TextStyle(color: Colors.white)),
    );
  }
}
```

See `example/lib/main.dart` — six tabs demonstrate both presets (with live icon-size sliders and per-switch `isExternal` toggles), the raw canvas, an external controller, dynamic data mutation, and a hover-effect tuning panel.

## Migrating from legacy packages

This package supersedes:

- `network_topoview` → use `CloudNetworkView`. Types: `DomainInfo` → `CloudDomain`, `NetworkInfo` → `CloudNetwork`, `NetworkConnection` → `CloudEdge`.
- `onenetwork_topoview` → use `SwitchRelationView`. Types: `SwitchInfo` → `SwitchNode`, `ConnectionInfo` → `SwitchEdge`.
- `flutter_topology_view` (v1) → use the low-level `TopologyCanvas` with `HierarchicalLayout`.

## License

MIT
