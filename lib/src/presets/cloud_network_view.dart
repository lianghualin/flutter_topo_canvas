import 'package:flutter/material.dart';
import '../core/topo_types.dart';
import '../core/topo_controller.dart';
import '../core/topology_canvas.dart';
import '../layout/ellipse_group_layout.dart';
import '../layout/hierarchical_layout.dart';
import '../layout/topology_layout.dart';
import '../renderers/animated_line_renderer.dart';
import '../renderers/device_icon_node_renderer.dart';
import '../renderers/ellipse_group_renderer.dart';
import 'preset_data.dart';
import 'package:topology_view_icons/topology_view_icons.dart';

/// Preset replacing `network_topoview.NetworkTopologyView`. Renders cloud-shaped
/// network nodes grouped into domain ellipses.
class CloudNetworkView extends StatelessWidget {
  final List<CloudDomain> domains;
  final List<CloudEdge> connections;
  final bool showGroups;
  final void Function(String networkName)? onNetworkTap;
  final bool showToolbar;
  final List<Widget>? toolbarExtras;
  final TopoCanvasController? controller;
  final Size iconSize;

  const CloudNetworkView({
    super.key,
    required this.domains,
    required this.connections,
    this.showGroups = true,
    this.onNetworkTap,
    this.showToolbar = true,
    this.toolbarExtras,
    this.controller,
    this.iconSize = const Size(80, 48),
  });

  @override
  Widget build(BuildContext context) {
    final nodes = <TopoNode<CloudNetwork>>[];
    final groups = <TopoGroup>[];
    String? rootDomainName;

    for (final domain in domains) {
      if (domain.isRoot) rootDomainName = domain.name;
      groups.add(TopoGroup(
        id: domain.name,
        label: domain.name,
        nodeIds: domain.networks.map((n) => n.name).toList(),
        isAbnormal: domain.isAbnormal,
      ));
      for (final net in domain.networks) {
        nodes.add(TopoNode(id: net.name, data: net));
      }
    }

    rootDomainName ??= domains.isEmpty ? 'root' : domains.first.name;

    final edges = [
      for (var i = 0; i < connections.length; i++)
        TopoEdge<CloudEdge>(
          id: 'e$i',
          fromNodeId: connections[i].fromNetworkName,
          toNodeId: connections[i].toNetworkName,
          data: connections[i],
        ),
    ];

    final TopologyLayout layout = showGroups
        ? EllipseGroupLayout(rootDomainId: rootDomainName)
        : HierarchicalLayout(
            rootNodeId: domains.isNotEmpty && domains.first.networks.isNotEmpty
                ? domains.first.networks.first.name
                : 'root',
          );

    return TopologyCanvas<CloudNetwork, CloudEdge>(
      nodes: nodes,
      edges: edges,
      groups: showGroups ? groups : const [],
      layout: layout,
      nodeRenderer: DeviceIconNodeRenderer<CloudNetwork>(
        deviceType: (_) => TopoDeviceType.network,
        isError: (n) => n.data.isAbnormal,
        label: (n) => n.data.name,
        size: iconSize,
      ),
      edgeRenderer: const AnimatedLineRenderer<CloudEdge>(),
      groupRenderer: showGroups ? const EllipseGroupRenderer() : null,
      onNodeTap: onNetworkTap,
      showToolbar: showToolbar,
      toolbarExtras: toolbarExtras,
      controller: controller,
    );
  }
}
