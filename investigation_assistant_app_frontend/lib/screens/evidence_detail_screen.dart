import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'evidence_tab_screen.dart';

class EvidenceDetailScreen extends StatelessWidget {
  final EvidenceItem evidence;
  final Map<String, dynamic> mockResponse;

  const EvidenceDetailScreen({
    super.key,
    required this.evidence,
    required this.mockResponse,
  });

  static const Color headerBlue1 = Color(0xFF1D4ED8);
  static const Color headerBlue2 = Color(0xFF0B1220);
  static const Color surfaceBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    final extracted = (mockResponse["extracted_entities"] ?? {}) as Map<String, dynamic>;
    final victims = (extracted["victims"] ?? []) as List;
    final suspects = (extracted["suspects"] ?? []) as List;
    final locations = (extracted["locations"] ?? []) as List;
    final objects = (extracted["objects"] ?? []) as List;
    final findings = (mockResponse["key_findings"] ?? []) as List;

    final timestamps = (mockResponse["inferred_timeline_events"] ?? []) as List;

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
                title: "Evidence Details",
                subtitle: evidence.title,
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
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 22),
                    children: [
                      _EvidenceHeaderCard(evidence: evidence),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: "Key Findings",
                        icon: Icons.lightbulb_outline_rounded,
                        child: Column(
                          children: findings
                              .map((f) => _Bullet(text: f.toString()))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: "Victims",
                        icon: Icons.person_outline_rounded,
                        child: victims.isEmpty
                            ? _EmptyText("No victims detected.")
                            : Column(
                                children: victims
                                    .map((v) => _EntityTile(
                                          title: "Victim",
                                          description: (v["description"] ?? "").toString(),
                                          color: const Color(0xFF0EA5E9),
                                        ))
                                    .toList(),
                              ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: "Suspects",
                        icon: Icons.person_search_outlined,
                        child: suspects.isEmpty
                            ? _EmptyText("No suspects detected.")
                            : Column(
                                children: suspects
                                    .map((s) => _EntityTile(
                                          title: "Suspect",
                                          description: (s["description"] ?? "").toString(),
                                          color: const Color(0xFFEF4444),
                                        ))
                                    .toList(),
                              ),
                      ),

                      const SizedBox(height: 14),

                      _SectionCard(
                        title: "Descriptions",
                        icon: Icons.description_outlined,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Locations",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (locations.isEmpty)
                              _EmptyText("No locations detected.")
                            else
                              ...locations.map((l) => _MiniCard(
                                    title: (l["type"] ?? "Location").toString(),
                                    subtitle: (l["description"] ?? "").toString(),
                                  )),

                            const SizedBox(height: 12),

                            Text(
                              "Objects",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (objects.isEmpty)
                              _EmptyText("No objects detected.")
                            else
                              ...objects.map((o) => _MiniCard(
                                    title: (o["description"] ?? "Object").toString(),
                                    subtitle:
                                        "Status: ${o["status"] ?? "-"} • Owner: ${o["owner"] ?? "-"}",
                                  )),
                          ],
                        ),
                      ),

                      // ONLY for VIDEO category
                      if (evidence.category == EvidenceCategory.video) ...[
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: "Timestamps",
                          icon: Icons.timer_outlined,
                          child: timestamps.isEmpty
                              ? _EmptyText("No timestamp events extracted.")
                              : Column(
                                  children: timestamps.map((t) {
                                    return _TimestampTile(
                                      start: (t["timestamp_start"] ?? "").toString(),
                                      end: (t["timestamp_end"] ?? "").toString(),
                                      event: (t["event_description"] ?? "").toString(),
                                      link: (t["link_to_fir"] ?? "").toString(),
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ================= UI Widgets =================

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

class _EvidenceHeaderCard extends StatelessWidget {
  final EvidenceItem evidence;

  const _EvidenceHeaderCard({required this.evidence});

  @override
  Widget build(BuildContext context) {
    final cat = _categoryStyle(evidence.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: cat.bg,
            ),
            child: Icon(cat.icon, color: cat.fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evidence.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${cat.label} • ${evidence.sizeKB} KB",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: cat.fg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _CatVisual _categoryStyle(EvidenceCategory c) {
    switch (c) {
      case EvidenceCategory.audio:
        return _CatVisual("AUDIO", const Color(0xFF8B5CF6),
            const Color(0xFF8B5CF6).withOpacity(0.12), Icons.graphic_eq_rounded);
      case EvidenceCategory.video:
        return _CatVisual("VIDEO", const Color(0xFF22C55E),
            const Color(0xFF22C55E).withOpacity(0.12), Icons.videocam_outlined);
      case EvidenceCategory.documents:
        return _CatVisual("DOCUMENT", const Color(0xFF0EA5E9),
            const Color(0xFF0EA5E9).withOpacity(0.12), Icons.description_outlined);
      case EvidenceCategory.physical:
        return _CatVisual("PHYSICAL", const Color(0xFFF59E0B),
            const Color(0xFFF59E0B).withOpacity(0.12), Icons.inventory_2_outlined);
    }
  }
}

class _CatVisual {
  final String label;
  final Color fg;
  final Color bg;
  final IconData icon;

  _CatVisual(this.label, this.fg, this.bg, this.icon);
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF1D4ED8).withOpacity(0.12),
                ),
                child: Icon(icon, color: const Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: const Color(0xFF0B1220),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1D4ED8).withOpacity(0.85),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.8,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntityTile extends StatelessWidget {
  final String title;
  final String description;
  final Color color;

  const _EntityTile({
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              height: 1.35,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MiniCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFF3F6FF),
        border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: const Color(0xFF0B1220),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 12.2,
              height: 1.35,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimestampTile extends StatelessWidget {
  final String start;
  final String end;
  final String event;
  final String link;

  const _TimestampTile({
    required this.start,
    required this.end,
    required this.event,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF22C55E).withOpacity(0.08),
        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: const Color(0xFF22C55E).withOpacity(0.15),
            ),
            child: Text(
              "$start–$end",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                fontSize: 11.5,
                color: const Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    height: 1.35,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Link: $link",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;

  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }
}