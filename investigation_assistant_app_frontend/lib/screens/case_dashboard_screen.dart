import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:investigation_assistant_app_frontend/screens/case_graph_screen.dart';
import 'package:investigation_assistant_app_frontend/screens/evidence_tab_screen.dart';
import 'package:investigation_assistant_app_frontend/screens/timeline_screen.dart';
import 'package:investigation_assistant_app_frontend/screens/upload_fir_screen.dart';

class CaseDashboardScreen extends StatefulWidget {
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

  @override
  State<CaseDashboardScreen> createState() => _CaseDashboardScreenState();
}

class _CaseDashboardScreenState extends State<CaseDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String? _generatedSummary;
  bool _isLoadingSummary = true;

  static const Color headerBlue1 = Color(0xFF1D4ED8);
  static const Color headerBlue2 = Color(0xFF0B1220);
  static const Color surfaceBg = Color(0xFFF6F7FB);

  @override
  void initState() {
    super.initState();
    _generateSummaryFromFIRs();
  }

  Future<void> _generateSummaryFromFIRs() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoadingSummary = false);
        return;
      }

      // Fetch all FIRs for this case
      final firsSnapshot = await _firestore
          .collection("officers")
          .doc(user.uid)
          .collection("cases")
          .doc(widget.caseDocId)
          .collection("firs")
          .get();

      if (firsSnapshot.docs.isEmpty) {
        setState(() {
          _generatedSummary = widget.caseSummary;
          _isLoadingSummary = false;
        });
        return;
      }

      // Extract all case data from FIRs
      Map<String, dynamic> caseData = {};
      for (var doc in firsSnapshot.docs) {
        final firData = doc.data();
        if (firData.containsKey('apiResponse')) {
          caseData.addAll(firData['apiResponse'] as Map<String, dynamic>);
        }
      }

      // Generate summary from case data using AI
      final summaryText = _generateSummaryText(caseData);

      setState(() {
        _generatedSummary = summaryText;
        _isLoadingSummary = false;
      });
    } catch (e) {
      print("Error generating summary: $e");
      setState(() {
        _generatedSummary = widget.caseSummary;
        _isLoadingSummary = false;
      });
    }
  }

  String _generateSummaryText(Map<String, dynamic> caseData) {
    // Extract case_summary directly from the API response
    if (caseData.containsKey('case_summary')) {
      final summary = caseData['case_summary'];
      if (summary != null && summary.toString().isNotEmpty) {
        return summary.toString();
      }
    }

    // Fall back to default if case_summary not found
    return "Review FIR details, verify evidence, and build a consistent timeline for court readiness.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,

      // Floating 3D chatbot button
      floatingActionButton: _KhojMitraFab(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KhojMitraChatScreen(
                caseDocId: widget.caseDocId,
              ),
            ),
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
                            widget.caseId,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            widget.caseName,
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
                        _CaseSummaryCard(
                          summary: _generatedSummary ?? widget.caseSummary,
                          isLoading: _isLoadingSummary,
                        ),

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
                                  caseId: widget.caseId,
                                  caseName: widget.caseName,
                                  caseDocId: widget.caseDocId,
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
                              builder: (_) => EvidenceTabScreen(caseId: widget.caseId, caseName: widget.caseName),
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
                                  caseId: widget.caseId,
                                  caseName: widget.caseName,
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
                              builder: (_) => CaseGraphScreen(),
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
  final bool isLoading;

  const _CaseSummaryCard({
    required this.summary,
    this.isLoading = false,
  });

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
                if (isLoading)
                  Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Generating summary...",
                        style: GoogleFonts.poppins(
                          fontSize: 13.2,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                else
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
  final String caseDocId;

  const KhojMitraChatScreen({
    super.key,
    required this.caseDocId,
  });

  @override
  State<KhojMitraChatScreen> createState() => _KhojMitraChatScreenState();
}

class _KhojMitraChatScreenState extends State<KhojMitraChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, String>> _messages = [
    {
      "role": "bot",
      "text": "Hi, I’m KHOJMITRA 👋\nAsk me anything about this case."
    }
  ];

  bool _isLoading = false;
  final String _qaApiUrl = "http://192.168.124.36:8000/qa/ask";

  Future<Map<String, dynamic>> _fetchCaseData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      final firsSnapshot = await _firestore
          .collection("officers")
          .doc(user.uid)
          .collection("cases")
          .doc(widget.caseDocId)
          .collection("firs")
          .get();

      Map<String, dynamic> caseData = {};

      for (var doc in firsSnapshot.docs) {
        final firData = doc.data();
        if (firData.containsKey('apiResponse')) {
          caseData.addAll(firData['apiResponse'] as Map<String, dynamic>);
        }
      }

      return caseData.isEmpty ? {"note": "No FIR data available yet"} : caseData;
    } catch (e) {
      print("Error fetching case data: $e");
      rethrow;
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
      _isLoading = true;
    });

    try {
      final caseData = await _fetchCaseData();

      final requestBody = {
        "case_data": caseData,
        "question": text,
      };

      final response = await http.post(
        Uri.parse(_qaApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final answer = responseData["answer"] ?? "No answer received";

        setState(() {
          _messages.add({
            "role": "bot",
            "text": answer,
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Error: Failed to get response (${response.statusCode}). Please try again.",
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "bot",
          "text": "Error: $e",
        });
        _isLoading = false;
      });
    }
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
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator
                if (_isLoading && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Thinking...",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

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