// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_topo_canvas/flutter_topo_canvas.dart';

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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_topo_canvas'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Cloud network'),
            Tab(text: 'Switch relation'),
            Tab(text: 'Raw canvas'),
          ]),
        ),
        body: const TabBarView(children: [
          CloudNetworkDemo(),
          SwitchRelationDemo(),
          RawCanvasDemo(),
        ]),
      ),
    );
  }
}

class CloudNetworkDemo extends StatelessWidget {
  const CloudNetworkDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CloudNetworkView(
      domains: const [
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
      connections: const [
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
    return SwitchRelationView(
      switches: const [
        SwitchNode(name: 'core-1'),
        SwitchNode(name: 'core-2'),
        SwitchNode(name: 'agg-1'),
        SwitchNode(name: 'agg-2'),
        SwitchNode(name: 'tor-1'),
        SwitchNode(name: 'tor-2'),
        SwitchNode(name: 'tor-err', isAbnormal: true),
        SwitchNode(name: 'tor-4'),
      ],
      connections: const [
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
    return TopologyCanvas<String, String>(
      nodes: const [
        TopoNode(id: 'a', data: 'Alpha'),
        TopoNode(id: 'b', data: 'Beta'),
        TopoNode(id: 'c', data: 'Gamma'),
      ],
      edges: const [
        TopoEdge(id: 'ab', fromNodeId: 'a', toNodeId: 'b', data: ''),
        TopoEdge(id: 'bc', fromNodeId: 'b', toNodeId: 'c', data: ''),
      ],
      layout: const HierarchicalLayout(rootNodeId: 'a'),
      nodeRenderer: const _CircleNodeRenderer(),
      edgeRenderer: const AnimatedLineRenderer<String>(),
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
