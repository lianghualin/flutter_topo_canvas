import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import '../core/topo_controller.dart';
import '../core/topology_canvas.dart';
import '../layout/hierarchical_layout.dart';
import '../renderers/animated_line_renderer.dart';
import '../renderers/device_icon_node_renderer.dart';
import 'preset_data.dart';
import 'package:topology_view_icons/topology_view_icons.dart';

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
  final Size iconSize;

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
    this.iconSize = const Size(60, 60),
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
      nodeRenderer: DeviceIconNodeRenderer<SwitchNode>(
        deviceType: (_) => TopoDeviceType.switch_,
        isError: (n) => n.data.isAbnormal,
        isExternal: (n) => n.data.isExternal,
        label: (n) => n.data.name,
        size: iconSize,
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
