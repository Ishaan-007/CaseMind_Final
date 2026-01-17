import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:investigation_assistant_app_frontend/screens/case_graph_screen.dart';
import 'package:investigation_assistant_app_frontend/screens/evidence_tab_screen.dart';
import 'package:investigation_assistant_app_frontend/screens/timeline_screen.dart';
import 'package:investigation_assistant_app_frontend/screens/upload_fir_screen.dart';

class CaseDashboardScreen extends StatelessWidget {
  final String caseId;
  final String caseName;
  final String caseDocId;
  final String caseSummary;

  const CaseDashboardScreen({
    super.key,
    required this.caseId,
    required this.caseName,
    required this.caseDocId,
    required this.caseSummary,
  });

  static const Color headerBlue1 = Color(0xFF1D4ED8);
  static const Color headerBlue2 = Color(0xFF0B1220);
  static const Color surfaceBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,

      // Floating 3D chatbot button
      floatingActionButton: _KhojMitraFab(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KhojMitraChatScreen()),
          );
        },
      ),

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
              // Top Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            caseId,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            caseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
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
                    )
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // White main panel
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Case Summary box with glowing bulb
                        _CaseSummaryCard(summary: caseSummary),

                        const SizedBox(height: 18),

                        Text(
                          "Case Actions",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 5 action cards
                        _ActionCard(
                          title: "UPLOAD FIR",
                          subtitle: "Add FIR document and extract key details",
                          icon: Icons.upload_file_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadFirScreen(
                                  caseId: caseId,
                                  caseName: caseName,
                                  caseDocId: caseDocId,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: "UPLOAD EVIDENCE",
                          subtitle: "Add documents, photos, audio, video",
                          icon: Icons.folder_copy_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EvidenceTabScreen(caseId: caseId, caseName: caseName),
                            ),
                          ),
                        ),
                        _ActionCard(
                          title: "GENERATE TIMELINE",
                          subtitle: "Build event sequence from FIR + evidence",
                          icon: Icons.timeline_outlined,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TimelineScreen(
                                  caseId: caseId,
                                  caseName: caseName,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionCard(
                          title: "BUILD CASE GRAPH",
                          subtitle: "Connect suspects, witnesses, locations, evidence",
                          icon: Icons.hub_outlined,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CaseGraphScreen(graphJson: {
  "nodes": [
    { "id": "CASE002", "type": "Case" },

    { "id": "Ayesha Khan", "type": "Person" },
    { "id": "Ravi Sharma", "type": "Person" },
    { "id": "Inspector Patil", "type": "Person" },

    { "id": "Andheri Station", "type": "Location" },
    { "id": "Platform 3", "type": "Location" },

    { "id": "iPhone 13", "type": "Object" },
    { "id": "IMEI 356938035643809", "type": "Identifier" },

    { "id": "EVID010_CCTV", "type": "Evidence" },
    { "id": "EVID011_Bill", "type": "Evidence" },
    { "id": "EVID012_WitnessAudio", "type": "Evidence" },

    { "id": "Event_Theft", "type": "Event" },
    { "id": "Event_SuspectSeen", "type": "Event" },

    { "id": "Time_19_40", "type": "Time" },
    { "id": "Time_19_45", "type": "Time" }
  ],

  "edges": [
    { "source": "Ayesha Khan", "target": "CASE002", "relation": "IS_VICTIM_OF" },
    { "source": "Ravi Sharma", "target": "CASE002", "relation": "IS_SUSPECT_IN" },
    { "source": "Inspector Patil", "target": "CASE002", "relation": "INVESTIGATES" },

    { "source": "Andheri Station", "target": "CASE002", "relation": "IS_LOCATION_OF_INCIDENT" },
    { "source": "Platform 3", "target": "Andheri Station", "relation": "PART_OF" },

    { "source": "Ayesha Khan", "target": "iPhone 13", "relation": "OWNS" },
    { "source": "iPhone 13", "target": "IMEI 356938035643809", "relation": "HAS_IMEI" },

    { "source": "EVID010_CCTV", "target": "Ravi Sharma", "relation": "SHOWS_PERSON" },
    { "source": "EVID010_CCTV", "target": "Platform 3", "relation": "RECORDED_AT" },

    { "source": "EVID011_Bill", "target": "iPhone 13", "relation": "DOCUMENTS_OWNERSHIP_FOR" },
    { "source": "EVID011_Bill", "target": "Ayesha Khan", "relation": "REGISTERS_TO" },

    { "source": "EVID012_WitnessAudio", "target": "Event_SuspectSeen", "relation": "SUPPORTS_EVENT" },

    { "source": "Event_SuspectSeen", "target": "Time_19_40", "relation": "OCCURRED_AT" },
    { "source": "Event_SuspectSeen", "target": "Ravi Sharma", "relation": "INVOLVES_PERSON" },
    { "source": "Event_SuspectSeen", "target": "Platform 3", "relation": "AT_LOCATION" },

    { "source": "Event_Theft", "target": "Time_19_45", "relation": "OCCURRED_AT" },
    { "source": "Event_Theft", "target": "Ayesha Khan", "relation": "INVOLVES_PERSON" },
    { "source": "Event_Theft", "target": "iPhone 13", "relation": "INVOLVES_OBJECT" },
    { "source": "Event_Theft", "target": "CASE002", "relation": "PART_OF_CASE" },

    { "source": "EVID010_CCTV", "target": "Event_Theft", "relation": "SUPPORTS_EVENT" }
  ]
},),
                            ),
                          ),
                        ),
                        _ActionCard(
                          title: "COURT NARRATIVE",
                          subtitle: "Generate court-ready case story with citations",
                          icon: Icons.article_outlined,
                          onTap: () => _showSnack(context, "Court Narrative clicked"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ------------------- Case Summary Card -------------------

class _CaseSummaryCard extends StatelessWidget {
  final String summary;

  const _CaseSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFEFF4FF),
          ],
        ),
        border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glowing bulb icon
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
                  color: const Color(0xFF6EE7FF).withOpacity(0.6),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Case Summary",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0B1220),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  style: GoogleFonts.poppins(
                    fontSize: 13.2,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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

// ------------------- Action Cards -------------------

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1D4ED8), Color(0xFF0B1220)],
                ),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.2,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0B1220),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.2,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}

// ------------------- 3D Chatbot Floating Button -------------------

class _KhojMitraFab extends StatelessWidget {
  final VoidCallback onTap;

  const _KhojMitraFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6EE7FF), Color(0xFF1D4ED8)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFF6EE7FF).withOpacity(0.55),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 30),
      ),
    );
  }
}

// ------------------- Chat Screen (Functional) -------------------

class KhojMitraChatScreen extends StatefulWidget {
  const KhojMitraChatScreen({super.key});

  @override
  State<KhojMitraChatScreen> createState() => _KhojMitraChatScreenState();
}

class _KhojMitraChatScreenState extends State<KhojMitraChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text": "Hi, I’m KHOJMITRA 👋\nAsk me anything about this case."
    }
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();

      // Demo response (replace later with your Groq/LLM API)
      _messages.add({
        "role": "bot",
        "text":
            "Noted. I can help you with FIR sections, timeline, contradictions, and evidence gaps.\n\n(Backend AI response will come here.)"
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        title: Text(
          "KHOJMITRA",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF1D4ED8) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: GoogleFonts.poppins(
                        color: isUser ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input box
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, -10),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.poppins(),
                    decoration: InputDecoration(
                      hintText: "Ask KHOJMITRA...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Color(0xFF1D4ED8),
                          width: 1.2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6EE7FF), Color(0xFF1D4ED8)],
                    ),
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}