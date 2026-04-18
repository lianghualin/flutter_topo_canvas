# flutter_topo_canvas

[![pub.dev](https://img.shields.io/pub/v/flutter_topo_canvas.svg)](https://pub.dev/packages/flutter_topo_canvas)

A generic topology canvas with pluggable layouts and renderers. Ships two ready-made presets (`CloudNetworkView`, `SwitchRelationView`) and a low-level `TopologyCanvas` for custom use.

## Features

- **Generic core** — `TopologyCanvas<TNode, TEdge>` takes any node/edge data.
- **Pluggable layout** — abstract `TopologyLayout`; built-in `HierarchicalLayout` (handles cycles) and `EllipseGroupLayout`.
- **Pluggable renderers** — `NodeRenderer`, `EdgeRenderer`, `GroupRenderer` interfaces; built-in icon + animated-line + ellipse-group renderers.
- **Pan / zoom / fit-view** — via `InteractiveViewer`, with a default toolbar and an imperative `TopoCanvasController`.
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
  onNetworkTap: (name) => debugPrint('tapped $name'),
);
```

## Quickstart — SwitchRelationView

```dart
SwitchRelationView(
  switches: const [
    SwitchNode(name: 'core-1'),
    SwitchNode(name: 'agg-1'),
    SwitchNode(name: 'tor-1'),
  ],
  connections: const [
    SwitchEdge(fromSwitchName: 'core-1', toSwitchName: 'agg-1'),
    SwitchEdge(fromSwitchName: 'agg-1', toSwitchName: 'tor-1'),
  ],
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

## Extending

Implement one of:

- `TopologyLayout` — your own positioning algorithm.
- `NodeRenderer<T>` — custom widget per node.
- `EdgeRenderer<T>` — custom line, curve, or animated effect.
- `GroupRenderer` — different boundary shape (rectangle, hull, etc.).

See `example/lib/main.dart` tab 3 for a `_CircleNodeRenderer` custom node.

## Migrating from legacy packages

This package supersedes:

- `network_topoview` → use `CloudNetworkView`. Types: `DomainInfo` → `CloudDomain`, `NetworkInfo` → `CloudNetwork`, `NetworkConnection` → `CloudEdge`.
- `onenetwork_topoview` → use `SwitchRelationView`. Types: `SwitchInfo` → `SwitchNode`, `ConnectionInfo` → `SwitchEdge`.
- `flutter_topology_view` (v1) → use the low-level `TopologyCanvas` with `HierarchicalLayout`.

## License

MIT
