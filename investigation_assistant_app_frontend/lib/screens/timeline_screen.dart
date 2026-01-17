import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineScreen extends StatelessWidget {
  final String caseId;
  final String caseName;

  const TimelineScreen({
    super.key,
    required this.caseId,
    required this.caseName,
  });

  static const Color headerBlue1 = Color(0xFF1D4ED8);
  static const Color headerBlue2 = Color(0xFF0B1220);
  static const Color surfaceBg = Color(0xFFF6F7FB);
  static const Color accentCyan = Color(0xFF6EE7FF);

  // Demo timeline data (later you will fetch from API)
  List<Map<String, String>> get timelineData => [
        {
          "event": "Complaint registered and FIR drafted based on the incident details.",
          "time_range": "18:10",
          "source": "FIR",
          "confidence": "high"
        },
        {
          "event": "Witness saw a person standing near the complainant.",
          "time_range": "20:25",
          "source": "Evidence",
          "confidence": "medium"
        },
        {
          "event": "CCTV footage captured movement near the incident location.",
          "time_range": "20:40",
          "source": "CCTV",
          "confidence": "high"
        },
        {
          "event": "Suspect description partially matches witness statement.",
          "time_range": "21:05",
          "source": "Inference",
          "confidence": "low"
        },
        {
          "event": "Mobile location data indicates device presence near Bandra bandstand.",
          "time_range": "21:20",
          "source": "Digital Evidence",
          "confidence": "medium"
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [headerBlue1, headerBlue2],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                title: "Case Timeline",
                subtitle: "$caseId • $caseName",
                onBack: () => Navigator.pop(context),
              ),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  decoration: const BoxDecoration(
                    color: surfaceBg,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card (mini summary)
                      _TimelineHeaderCard(),

                      const SizedBox(height: 14),

                      Text(
                        "Events",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: timelineData.length,
                          itemBuilder: (context, index) {
                            final item = timelineData[index];
                            return _TimelineTile(
                              index: index + 1,
                              event: item["event"] ?? "",
                              time: item["time_range"] ?? "",
                              source: item["source"] ?? "",
                              confidence: item["confidence"] ?? "medium",
                              isLast: index == timelineData.length - 1,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== Top Bar ===================

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.14),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
            ),
            child: const Icon(Icons.person_outline_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// =================== Header Card ===================

class _TimelineHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEFF4FF)],
        ),
        border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF6EE7FF), Color(0xFF1D4ED8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6EE7FF).withOpacity(0.55),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.timeline_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chronological View",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: const Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "This timeline shows key events extracted from FIR and evidence sources, arranged in time order.",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.2,
                    height: 1.3,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================== Timeline Tile ===================

class _TimelineTile extends StatelessWidget {
  final int index;
  final String event;
  final String time;
  final String source;
  final String confidence;
  final bool isLast;

  const _TimelineTile({
    required this.index,
    required this.event,
    required this.time,
    required this.source,
    required this.confidence,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _confidenceChip(confidence);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left timeline line + node
          SizedBox(
            width: 38,
            child: Column(
              children: [
                _GlowingNode(index: index),
                if (!isLast)
                  Container(
                    height: 86,
                    width: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF6EE7FF).withOpacity(0.9),
                          const Color(0xFF1D4ED8).withOpacity(0.35),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Event card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                border: Border.all(color: Colors.black.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: time + chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFF1D4ED8).withOpacity(0.10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF1D4ED8)),
                            const SizedBox(width: 6),
                            Text(
                              time,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.2,
                                color: const Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      chip,
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    event,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      height: 1.35,
                      color: const Color(0xFF0B1220),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.source_outlined, size: 16, color: Colors.black45),
                      const SizedBox(width: 6),
                      Text(
                        "Source: ",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.2,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          source,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.2,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _confidenceChip(String c) {
    Color bg;
    Color fg;
    IconData icon;

    switch (c.toLowerCase()) {
      case "high":
        bg = const Color(0xFF10B981).withOpacity(0.12);
        fg = const Color(0xFF10B981);
        icon = Icons.verified_rounded;
        break;
      case "low":
        bg = const Color(0xFFEF4444).withOpacity(0.12);
        fg = const Color(0xFFEF4444);
        icon = Icons.error_outline_rounded;
        break;
      default:
        bg = const Color(0xFFF59E0B).withOpacity(0.12);
        fg = const Color(0xFFF59E0B);
        icon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            c.toUpperCase(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingNode extends StatelessWidget {
  final int index;

  const _GlowingNode({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6EE7FF), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6EE7FF).withOpacity(0.55),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          index.toString().padLeft(2, "0"),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}