## 1.1.0 — 2026-04-20

**Added**
- `iconSize` parameter on `CloudNetworkView` (default `Size(80, 48)`) and `SwitchRelationView` (default `Size(60, 60)`) for tuning icon size without dropping to the low-level canvas. Defaults are smaller than the previous internal constants — diagrams look tighter out of the box.
- `isExternal` on `SwitchNode` and a matching `isExternal` predicate + `externalOpacity` on `DeviceIconNodeRenderer`. Switches flagged external render at 50% opacity to indicate they belong to a neighbouring domain shown for context only.
- `GroupRenderer.visualBounds(group, nodeUnion)` — reports the rect the renderer actually paints. Default returns the input; `EllipseGroupRenderer` overrides it to account for its 40-px inflation.
- `contentBounds(...)` helper in `viewport_math.dart`, unioning per-node rects with each group's `visualBounds`.

**Changed**
- Label under `DeviceIconNodeRenderer` now sits on a translucent white plate (85% opacity, rounded corners) and is pulled flush against the icon, so edge lines passing through the label zone no longer obscure the text.
- Example app's Cloud network and Switch relation tabs now carry a live icon-size slider; Switch relation also has a `FilterChip` row to toggle `isExternal` per switch.

**Fixed**
- `fitView` now frames the full visual content — including group ellipses and node icon rects — instead of just node centre points. Previously the root ellipse in `CloudNetworkView` could be clipped and labels at the ellipse's horizontal edges could sit outside the ring after an auto-fit.

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
