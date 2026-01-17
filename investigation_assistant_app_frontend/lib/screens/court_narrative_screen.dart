import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class CourtNarrativeScreen extends StatefulWidget {
  final String caseId;
  final String caseName;

  // This is the response from API
  final String narrativeText;

  const CourtNarrativeScreen({
    super.key,
    required this.caseId,
    required this.caseName,
    required this.narrativeText,
  });

  @override
  State<CourtNarrativeScreen> createState() => _CourtNarrativeScreenState();
}

class _CourtNarrativeScreenState extends State<CourtNarrativeScreen> {
  static const Color headerBlue1 = Color(0xFF1D4ED8);
  static const Color headerBlue2 = Color(0xFF0B1220);
  static const Color surfaceBg = Color(0xFFF6F7FB);

  bool _expanded = false;

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
                title: "Court Narrative",
                subtitle: "${widget.caseId} • ${widget.caseName}",
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
                    padding: const EdgeInsets.only(bottom: 20),
                    children: [
                      _NarrativeHeaderCard(
                        onCopy: _copyNarrative,
                        onExport: _exportNarrative,
                      ),
                      const SizedBox(height: 14),

                      _NarrativeCard(
                        text: widget.narrativeText,
                        expanded: _expanded,
                        onToggle: () => setState(() => _expanded = !_expanded),
                      ),

                      const SizedBox(height: 14),

                      _TipCard(),
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

  void _copyNarrative() async {
    await Clipboard.setData(ClipboardData(text: widget.narrativeText));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          "Narrative copied to clipboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _exportNarrative() {
    // Later connect PDF/DOCX export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          "Export feature will be connected to PDF/DOCX",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// =================== TOP BAR ===================

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

// =================== HEADER CARD ===================

class _NarrativeHeaderCard extends StatelessWidget {
  final VoidCallback onCopy;
  final VoidCallback onExport;

  const _NarrativeHeaderCard({
    required this.onCopy,
    required this.onExport,
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
            child: const Icon(Icons.gavel_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Court-ready Narrative",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: const Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Generated from FIR + Evidence with clear structure.",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.2,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            children: [
              _IconActionButton(
                icon: Icons.copy_rounded,
                tooltip: "Copy",
                onTap: onCopy,
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Icons.download_rounded,
                tooltip: "Export",
                onTap: onExport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFF1D4ED8).withOpacity(0.10),
          ),
          child: Icon(icon, color: const Color(0xFF1D4ED8)),
        ),
      ),
    );
  }
}

// =================== NARRATIVE CARD ===================

class _NarrativeCard extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _NarrativeCard({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = expanded ? text : _shorten(text, 520);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFEFF4FF)],
        ),
        border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Narrative",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  color: const Color(0xFF0B1220),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color(0xFF1D4ED8).withOpacity(0.10),
                  ),
                  child: Text(
                    expanded ? "Show Less" : "Read More",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _shorten(String s, int max) {
    if (s.length <= max) return s;
    return "${s.substring(0, max)}...";
  }
}

// =================== TIP CARD ===================

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF59E0B).withOpacity(0.14),
            ),
            child: const Icon(Icons.tips_and_updates_outlined, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tip: Always verify timeline and evidence references before final export.",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.2,
                height: 1.3,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}