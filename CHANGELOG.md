## 1.0.0 — 2026-04-19

First public-quality release.

**Added**
- `DeviceIconNodeRenderer<T>` — canvas-drawn device icons backed by [`topology_view_icons`](https://pub.dev/packages/topology_view_icons). No asset bundling; crisp at any zoom.
- Hover-float effect with silhouette-shaped drop shadow on `DeviceIconNodeRenderer`. Configurable via `liftDistance`, `shadowBlur`, `shadowOffset`, `shadowOpacity`, and `hoverFloat` master toggle.
- Pointer cursor changes to click on hover as a clickability affordance.
- Re-exports for `TopoDeviceType` and `TopoIconStyle` from the barrel so consumers don't need a second import.

**Changed**
- `CloudNetworkView` and `SwitchRelationView` now render through `DeviceIconNodeRenderer` instead of bundled SVG assets. Drop 4 placeholder SVGs from the package.
- Example app expanded to six tabs: both presets, raw canvas, external controller, dynamic data mutation, and a live hover-effect tuner.

**Fixed**
- `TopologyCanvas` pointer hit-testing: the internal `SizedBox(1, 1)` wrapper around content was silently dropping all tap and hover events on nodes. Replaced with `Positioned.fill` layers; inner-origin shift moved into per-item coordinates. Fit-view math is unchanged.
- `fitView` now compensates for the inner-origin shift so auto-centering works from a cold start.

## 0.1.0 — 2026-04-18

- Initial release.
- `TopologyCanvas<TNode, TEdge>` generic canvas with pluggable layouts and renderers.
- Built-in layouts: `HierarchicalLayout` (cycle-safe), `EllipseGroupLayout`.
- Built-in renderers: `IconNodeRenderer`, `AnimatedLineRenderer`, `EllipseGroupRenderer`.
- Presets: `CloudNetworkView`, `SwitchRelationView`.
- Supersedes `flutter_topology_view`, `network_topoview`, `onenetwork_topoview`.
