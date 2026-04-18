import 'package:flutter/foundation.dart';

// -------- CloudNetworkView data ------------------------------------------

@immutable
class CloudNetwork {
  final String name;
  final bool isAbnormal;

  const CloudNetwork({required this.name, this.isAbnormal = false});
}

@immutable
class CloudDomain {
  final String name;
  final List<CloudNetwork> networks;
  final bool isRoot;

  const CloudDomain({
    required this.name,
    required this.networks,
    this.isRoot = false,
  });

  bool get isAbnormal => networks.any((n) => n.isAbnormal);
}

@immutable
class CloudEdge {
  final String fromNetworkName;
  final String toNetworkName;

  const CloudEdge({
    required this.fromNetworkName,
    required this.toNetworkName,
  });
}

// -------- SwitchRelationView data ----------------------------------------

@immutable
class SwitchNode {
  final String name;
  final bool isAbnormal;

  const SwitchNode({required this.name, this.isAbnormal = false});
}

@immutable
class SwitchEdge {
  final String fromSwitchName;
  final String toSwitchName;

  const SwitchEdge({
    required this.fromSwitchName,
    required this.toSwitchName,
  });
}
