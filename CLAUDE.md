# flutter_topo_canvas

Generic, pluggable topology-canvas Flutter package. Presets: `CloudNetworkView`, `SwitchRelationView`.

## Discuss before editing

When I ask "how can I fix X", "how should we do Y", or any question about approach, **present options with tradeoffs first and wait for me to pick a direction** — don't start editing code. Exceptions: single-line typos / obviously mechanical fixes, or when I've already said "go ahead" in the same turn.

## Example app: web-only

The `example/` app targets **web only** — no `android/`, `ios/`, `macos/`, `linux/`, or `windows/` folders. When re-scaffolding platform files, always run:

```
cd example && flutter create --platforms=web .
```

After `flutter create`, delete the generated `example/test/widget_test.dart` — it references a counter-app `MyApp` that does not exist here and will break `flutter test`.

## Run

```
cd example && flutter run -d chrome   # example app
flutter test                           # library tests (at repo root)
```

## Barrel export

All public symbols are re-exported from `lib/flutter_topo_canvas.dart`. When adding a new public type, add its export there — don't expose it only from `lib/src/...`.

## Layout conventions

- `rootNodeId` on layouts is required — layouts fail loudly rather than guessing a root.
- Groups are decorative unless the chosen layout explicitly consumes them (`EllipseGroupLayout` does; `HierarchicalLayout` ignores them).
