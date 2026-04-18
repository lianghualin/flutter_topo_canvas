import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import '../core/topo_controller.dart';
import '../core/topology_canvas.dart';
import '../layout/hierarchical_layout.dart';
import '../renderers/animated_line_renderer.dart';
import '../renderers/icon_node_renderer.dart';
import 'preset_data.dart';

/// Preset replacing `onenetwork_topoview.NetworkTopologyView`. Renders switches
/// connected in a graph. Handles cycles via HierarchicalLayout.
class SwitchRelationView extends StatelessWidget {
  final List<SwitchNode> switches;
  final List<SwitchEdge> connections;
  final bool colorful;
  final bool hoverFloat;
  final String? rootSwitchName;
  final void Function(String switchName)? onSwitchTap;
  final bool showToolbar;
  final List<Widget>? toolbarExtras;
  final TopoCanvasController? controller;

  const SwitchRelationView({
    super.key,
    required this.switches,
    required this.connections,
    this.colorful = false,
    this.hoverFloat = true,
    this.rootSwitchName,
    this.onSwitchTap,
    this.showToolbar = true,
    this.toolbarExtras,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final nodes = [
      for (final s in switches) TopoNode<SwitchNode>(id: s.name, data: s),
    ];
    final edges = [
      for (var i = 0; i < connections.length; i++)
        TopoEdge<SwitchEdge>(
          id: 'e$i',
          fromNodeId: connections[i].fromSwitchName,
          toNodeId: connections[i].toSwitchName,
          data: connections[i],
        ),
    ];

    final root = rootSwitchName ?? (switches.isNotEmpty ? switches.first.name : 'root');

    return TopologyCanvas<SwitchNode, SwitchEdge>(
      nodes: nodes,
      edges: edges,
      layout: HierarchicalLayout(rootNodeId: root),
      nodeRenderer: IconNodeRenderer<SwitchNode>(
        assetPath: (n) => n.data.isAbnormal
            ? 'assets/images/switch_float_err.svg'
            : 'assets/images/switch_float.svg',
        label: (n) => n.data.name,
        package: 'flutter_topo_canvas',
        hoverFloat: hoverFloat,
      ),
      edgeRenderer: AnimatedLineRenderer<SwitchEdge>(colorful: colorful),
      onNodeTap: onSwitchTap,
      showToolbar: showToolbar,
      toolbarExtras: toolbarExtras,
      controller: controller,
    );
  }
}
