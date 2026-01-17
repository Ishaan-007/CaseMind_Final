import 'dart:math';
import 'package:flutter/material.dart';

class CaseGraphScreen extends StatelessWidget {
  const CaseGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF071427), // deep navy background
      appBar: AppBar(
        backgroundColor: const Color(0xFF071427),
        elevation: 0,
        title: const Text("Case Network"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Stack(
            children: [
              // Graph canvas
              Positioned.fill(
                child: CustomPaint(
                  painter: _GraphPainter(nodes: _hardcodedNodes()),
                ),
              ),

              // Legend (bottom)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: _LegendBar(primary: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               DATA MODELS                                  */
/* -------------------------------------------------------------------------- */

enum NodeType { caseNode, person, object, location, time, document }

class GraphNode {
  final String id;
  final String title;
  final String subtitle;
  final NodeType type;
  final Offset pos;

  GraphNode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.pos,
  });
}

class GraphEdge {
  final String from;
  final String to;
  final String label;

  GraphEdge({required this.from, required this.to, required this.label});
}

/* -------------------------------------------------------------------------- */
/*                          HARD-CODED FIR GRAPH DATA                          */
/* -------------------------------------------------------------------------- */

class _GraphData {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  _GraphData(this.nodes, this.edges);
}

/// Based on your FIR screenshot (Lost mobile report):
/// - Case: Lost report (Other Documents)
/// - Complainant: MD shariful haque
/// - Mobile: Mi A3 6GB 128GB (2 IMEIs)
/// - Location: Bandra bandstand
/// - Time: 03/11/2019 16:00
/// - Document: Digitally signed report (DS Brihan Mumbai Police)
_GraphData _hardcodedNodes() {
  // Canvas size is relative; painter scales to available size.
  // Use normalized coordinates (0..1) for responsiveness.
  Offset n(double x, double y) => Offset(x, y);

  final nodes = <GraphNode>[
    GraphNode(
      id: "case",
      title: "CASE 2208-2019",
      subtitle: "Lost Report • Bandra PS",
      type: NodeType.caseNode,
      pos: n(0.50, 0.12),
    ),

    GraphNode(
      id: "complainant",
      title: "MD Shariful Haque",
      subtitle: "Complainant",
      type: NodeType.person,
      pos: n(0.20, 0.32),
    ),

    GraphNode(
      id: "device",
      title: "Mobile: Mi A3",
      subtitle: "6GB/128GB • 2 IMEIs",
      type: NodeType.object,
      pos: n(0.80, 0.32),
    ),

    GraphNode(
      id: "location",
      title: "Bandra Bandstand",
      subtitle: "Place of loss",
      type: NodeType.location,
      pos: n(0.20, 0.56),
    ),

    GraphNode(
      id: "time",
      title: "03/11/2019",
      subtitle: "16:00 hrs",
      type: NodeType.time,
      pos: n(0.80, 0.56),
    ),

    GraphNode(
      id: "doc",
      title: "GMP Digital Report",
      subtitle: "Digitally Signed",
      type: NodeType.document,
      pos: n(0.50, 0.78),
    ),
  ];

  final edges = <GraphEdge>[
    GraphEdge(from: "case", to: "complainant", label: "filed by"),
    GraphEdge(from: "case", to: "device", label: "lost item"),
    GraphEdge(from: "case", to: "location", label: "reported at"),
    GraphEdge(from: "case", to: "time", label: "occurred on"),
    GraphEdge(from: "case", to: "doc", label: "generated report"),
    GraphEdge(from: "device", to: "doc", label: "details in"),
    GraphEdge(from: "complainant", to: "doc", label: "identity in"),
  ];

  return _GraphData(nodes, edges);
}

/* -------------------------------------------------------------------------- */
/*                               GRAPH PAINTER                                */
/* -------------------------------------------------------------------------- */

class _GraphPainter extends CustomPainter {
  final _GraphData nodes;
  _GraphPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final n in nodes.nodes) n.id: n};

    // Background subtle grid
    _drawGrid(canvas, size);

    // Draw edges first (behind nodes)
    for (final e in nodes.edges) {
      final a = nodeMap[e.from]!;
      final b = nodeMap[e.to]!;
      final pa = _scale(a.pos, size);
      final pb = _scale(b.pos, size);

      _drawCurvedEdge(canvas, pa, pb, e.label);
    }

    // Draw nodes on top
    for (final n in nodes.nodes) {
      _drawNode(canvas, size, n);
    }
  }

  Offset _scale(Offset p, Size size) {
    return Offset(p.dx * size.width, p.dy * size.height);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    const gap = 40.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawCurvedEdge(Canvas canvas, Offset a, Offset b, String label) {
    final edgePaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.35)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // curve control point (push curve outward)
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;

    // perpendicular offset for curve
    final norm = sqrt(dx * dx + dy * dy).clamp(1, 999999);
    final off = Offset(-dy / norm, dx / norm) * 18; // was 28

    final control = mid + off;

    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(control.dx, control.dy, b.dx, b.dy);

    // glow
    final glow = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.12)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, glow);

    canvas.drawPath(path, edgePaint);

    // Arrow head
    _drawArrow(canvas, control, b);

    // Edge label near the midpoint
    _drawEdgeLabel(canvas, label, mid + off * 0.2);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final angle = atan2(to.dy - from.dy, to.dx - from.dx);
    const arrowSize = 8.0;

    final p1 = to;
    final p2 = Offset(
      to.dx - arrowSize * cos(angle - pi / 6),
      to.dy - arrowSize * sin(angle - pi / 6),
    );
    final p3 = Offset(
      to.dx - arrowSize * cos(angle + pi / 6),
      to.dy - arrowSize * sin(angle + pi / 6),
    );

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawEdgeLabel(Canvas canvas, String label, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.65),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: pos,
        width: tp.width + 18,
        height: tp.height + 10,
      ),
      const Radius.circular(999),
    );

    final bg = Paint()..color = Colors.black.withOpacity(0.25);
    canvas.drawRRect(rect, bg);

    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  void _drawNode(Canvas canvas, Size size, GraphNode node) {
    final center = _scale(node.pos, size);

    final nodeSize = node.type == NodeType.caseNode
    ? const Size(210, 68)   // was 240x76
    : const Size(185, 62);  // was 210x70

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: nodeSize.width, height: nodeSize.height),
      const Radius.circular(18),
    );

    final (bg, border, icon, iconColor) = _styleForType(node.type);

    // glow
    final glowPaint = Paint()
      ..color = border.withOpacity(0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRRect(rect, glowPaint);

    // card
    final cardPaint = Paint()..color = bg;
    canvas.drawRRect(rect, cardPaint);

    // border
    final borderPaint = Paint()
      ..color = border.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rect, borderPaint);

    // icon circle
    final iconCircle = Offset(rect.left + 38, rect.center.dy);
    final circlePaint = Paint()..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(iconCircle, 20, circlePaint);

    // icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 20,
          fontFamily: icon.fontFamily,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(canvas, Offset(iconCircle.dx - 10, iconCircle.dy - 12));

    // title + subtitle
    final titlePainter = TextPainter(
      text: TextSpan(
        text: node.title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.92),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      maxLines: 1,
      ellipsis: "...",
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: nodeSize.width - 88);

    final subPainter = TextPainter(
      text: TextSpan(
        text: node.subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.70),
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      maxLines: 1,
      ellipsis: "...",
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: nodeSize.width - 88);

    final textX = rect.left + 70;
    titlePainter.paint(canvas, Offset(textX, rect.top + 18));
    subPainter.paint(canvas, Offset(textX, rect.top + 40));
  }

  (Color, Color, IconData, Color) _styleForType(NodeType t) {
    switch (t) {
      case NodeType.caseNode:
        return (
          const Color(0xFF0B2A4A).withOpacity(0.85),
          const Color(0xFF2FA4A9),
          Icons.folder_open_rounded,
          const Color(0xFF2FA4A9),
        );
      case NodeType.person:
        return (
          const Color(0xFF122B44).withOpacity(0.88),
          const Color(0xFF7C4DFF),
          Icons.person_rounded,
          const Color(0xFFB39DFF),
        );
      case NodeType.object:
        return (
          const Color(0xFF122B44).withOpacity(0.88),
          const Color(0xFFFFB300),
          Icons.phone_iphone_rounded,
          const Color(0xFFFFD54F),
        );
      case NodeType.location:
        return (
          const Color(0xFF122B44).withOpacity(0.88),
          const Color(0xFF00C853),
          Icons.location_on_rounded,
          const Color(0xFF69F0AE),
        );
      case NodeType.time:
        return (
          const Color(0xFF122B44).withOpacity(0.88),
          const Color(0xFF90A4AE),
          Icons.schedule_rounded,
          const Color(0xFFCFD8DC),
        );
      case NodeType.document:
        return (
          const Color(0xFF122B44).withOpacity(0.88),
          const Color(0xFF42A5F5),
          Icons.description_rounded,
          const Color(0xFF90CAF9),
        );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* -------------------------------------------------------------------------- */
/*                                  LEGEND                                    */
/* -------------------------------------------------------------------------- */

class _LegendBar extends StatelessWidget {
  final Color primary;
  const _LegendBar({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 8,
        children: const [
          _LegendChip(color: Color(0xFF2FA4A9), label: "Case"),
          _LegendChip(color: Color(0xFFB39DFF), label: "Person"),
          _LegendChip(color: Color(0xFFFFD54F), label: "Object"),
          _LegendChip(color: Color(0xFF69F0AE), label: "Location"),
          _LegendChip(color: Color(0xFFCFD8DC), label: "Time"),
          _LegendChip(color: Color(0xFF90CAF9), label: "Document"),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendChip({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}