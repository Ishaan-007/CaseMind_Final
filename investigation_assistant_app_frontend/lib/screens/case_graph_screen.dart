import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class CaseGraphScreen extends StatefulWidget {
  final dynamic graphJson; // Can pass Map OR JSON string

  const CaseGraphScreen({super.key, required this.graphJson});

  @override
  State<CaseGraphScreen> createState() => _CaseGraphScreenState();
}

class _CaseGraphScreenState extends State<CaseGraphScreen> {
  final Graph graph = Graph()..isTree = false;
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  final Map<String, Node> nodeMap = {};
  Map<String, dynamic> graphData = {};

  @override
  void initState() {
    super.initState();

    builder
      ..siblingSeparation = (20)
      ..levelSeparation = (35)
      ..subtreeSeparation = (30)
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;

    parseAndBuildGraph();
  }

  void parseAndBuildGraph() {
    // If user passes String JSON, decode it
    if (widget.graphJson is String) {
      graphData = jsonDecode(widget.graphJson);
    } else {
      graphData = widget.graphJson as Map<String, dynamic>;
    }

    final nodes = (graphData["nodes"] ?? []) as List<dynamic>;
    final edges = (graphData["edges"] ?? []) as List<dynamic>;

    // Create nodes
    for (final n in nodes) {
      final id = n["id"].toString();
      final type = (n["type"] ?? "Unknown").toString();

      nodeMap[id] = Node.Id(id);
      graph.addNode(nodeMap[id]!);
    }

    // Create edges
    for (final e in edges) {
      final src = e["source"].toString();
      final tgt = e["target"].toString();

      if (nodeMap.containsKey(src) && nodeMap.containsKey(tgt)) {
        graph.addEdge(
          nodeMap[src]!,
          nodeMap[tgt]!,
          paint: Paint()
            ..color = const Color(0xFF5EA7FF).withOpacity(0.65)
            ..strokeWidth = 2,
        );
      }
    }

    setState(() {});
  }

  // Node colors by type
  Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case "case":
        return const Color(0xFF00E5FF); // cyan
      case "person":
        return const Color(0xFF7C4DFF); // purple
      case "evidence":
        return const Color(0xFFFFC107); // amber
      case "location":
        return const Color(0xFF00C853); // green
      case "object":
        return const Color(0xFFFF5252); // red
      case "identifier":
        return const Color(0xFFFF7043); // orange
      case "event":
        return const Color(0xFF29B6F6); // blue
      case "time":
        return const Color(0xFFB0BEC5); // grey
      default:
        return const Color(0xFF90CAF9);
    }
  }

  IconData typeIcon(String type) {
    switch (type.toLowerCase()) {
      case "case":
        return Icons.folder_open_rounded;
      case "person":
        return Icons.person_rounded;
      case "evidence":
        return Icons.description_rounded;
      case "location":
        return Icons.location_on_rounded;
      case "object":
        return Icons.phone_android_rounded;
      case "identifier":
        return Icons.confirmation_number_rounded;
      case "event":
        return Icons.bolt_rounded;
      case "time":
        return Icons.schedule_rounded;
      default:
        return Icons.circle;
    }
  }

  String getNodeType(String id) {
    final nodes = (graphData["nodes"] ?? []) as List<dynamic>;
    final found = nodes.firstWhere(
      (n) => n["id"].toString() == id,
      orElse: () => {"type": "Unknown"},
    );
    return found["type"].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07152B), // dark blue
      appBar: AppBar(
        backgroundColor: const Color(0xFF07152B),
        elevation: 0,
        title: const Text(
          "Evidence Network",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: graphData.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                // Graph
                InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(80),
                  minScale: 0.05,
                  maxScale: 2.5,
                  child: GraphView(
                    graph: graph,
                    algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                    paint: Paint()
                      ..color = const Color(0xFF5EA7FF).withOpacity(0.6)
                      ..strokeWidth = 2
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      final id = node.key!.value as String;
                      final type = getNodeType(id);
                      return buildNodeCard(id, type);
                    },
                  ),
                ),

                // Legend chip bar
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2447).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          legendChip("Case", typeColor("Case")),
                          legendChip("Person", typeColor("Person")),
                          legendChip("Evidence", typeColor("Evidence")),
                          legendChip("Location", typeColor("Location")),
                          legendChip("Event", typeColor("Event")),
                          legendChip("Time", typeColor("Time")),
                          legendChip("Object", typeColor("Object")),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget legendChip(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.55)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.92),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNodeCard(String id, String type) {
    final color = typeColor(type);

    return GestureDetector(
      onTap: () {
        // Optional: show node info
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF0B2447),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Type: $type",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Tip: Zoom and emphasize connections for fast case understanding.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.35),
              const Color(0xFF0B2447).withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.55), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.20),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.55)),
              ),
              child: Icon(typeIcon(type), color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                id,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}