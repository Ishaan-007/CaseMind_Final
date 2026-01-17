import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

// 🔹 FULL FIXED CODE FOR UPLOAD FIR SCREEN WITH AUDIO SUPPORT

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType

class UploadFirScreen extends StatefulWidget {
  final String caseId;
  final String caseName;
  final String caseDocId;

  const UploadFirScreen({
    super.key,
    required this.caseId,
    required this.caseName,
    required this.caseDocId,
  });

  @override
  State<UploadFirScreen> createState() => _UploadFirScreenState();
}

class _UploadFirScreenState extends State<UploadFirScreen> {
  // ---- UI colors ----
  static const Color headerBlue1 = Color(0xFF1D4ED8);
  static const Color headerBlue2 = Color(0xFF0B1220);
  static const Color surfaceBg = Color(0xFFF6F7FB);
  static const Color accentCyan = Color(0xFF6EE7FF);

  // ---- Upload mode ----
  UploadMode _mode = UploadMode.text;

  // ---- FIR editor text ----
  final TextEditingController _firEditor = TextEditingController();

  // ---- Selected file info ----
  String? _pickedFileName;
  int? _pickedFileSizeKB;
  String? _pickedFilePath;   // 👈 store full path

  // ---- API response state ----
  bool _loading = false;
  Map<String, dynamic>? _apiData;
  String? _error;

  // ⚠️ Replace this with your FastAPI endpoint
  final String apiUrl = "http://192.168.124.36:8000/fir/analyze";

  @override
  void dispose() {
    _firEditor.dispose();
    super.dispose();
  }

  // -------------------- FILE PICKERS --------------------

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["jpg", "jpeg", "png"],
    );
    if (res == null) return;
    final file = res.files.single;

    setState(() {
      _pickedFileName = file.name;
      _pickedFileSizeKB = (file.size / 1024).round();
      _pickedFilePath = file.path;
    });
  }

  Future<void> _pickAudio() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["mp3", "wav", "m4a"],
    );
    if (res == null) return;
    final file = res.files.single;

    setState(() {
      _pickedFileName = file.name;
      _pickedFileSizeKB = (file.size / 1024).round();
      _pickedFilePath = file.path;
    });
  }

  // -------------------- API CALL --------------------
  Future<void> _uploadAndAnalyzeFir() async {
    if (_mode == UploadMode.text && _firEditor.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter FIR text", style: GoogleFonts.poppins())),
      );
      return;
    }

    if ((_mode == UploadMode.image || _mode == UploadMode.audio) &&
        _pickedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a file first", style: GoogleFonts.poppins())),
      );
      return;
    }

    setState(() {
      _loading = true;
      _apiData = null;
      _error = null;
    });

    try {
      final request = http.MultipartRequest("POST", Uri.parse(apiUrl));

      // 🔹 Text mode
      if (_mode == UploadMode.text) {
        request.fields["fir_text"] = _firEditor.text.trim();
      }

      // 🔹 Image mode
      if (_mode == UploadMode.image) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "fir_image",
            _pickedFilePath!,
            contentType: MediaType("image", "jpeg"), // or png if file extension is png
          ),
        );
      }

      // 🔹 Audio mode
      if (_mode == UploadMode.audio) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "fir_audio",
            _pickedFilePath!,
            contentType: MediaType("audio", "mpeg"), // mp3
          ),
        );
      }

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200) {
  final data = jsonDecode(resp.body);

  setState(() {
    _apiData = data;
    _loading = false;
  });

  // 🔹 Save FIR under the specific case document
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Use the caseDocId passed from the dashboard
      await FirebaseFirestore.instance
          .collection("officers")
          .doc(uid)
          .collection("cases")
          .doc(widget.caseDocId)
          .collection("firs")
          .add({
        "uploadedAt": FieldValue.serverTimestamp(),
        "uploadMode": _mode.toString().split('.').last,
        "apiResponse": data, // full JSON response from your FastAPI
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("FIR saved successfully", style: GoogleFonts.poppins())),
      );
    }
  } catch (e) {
    print("Error saving FIR to Firebase: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save FIR in Firebase: $e", style: GoogleFonts.poppins())),
    );
  }
}
 else {
        setState(() {
          _error = "API Error ${resp.statusCode}\n${resp.body}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network error: $e";
        _loading = false;
      });
    }
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            _TopBar(
              title: "Upload FIR",
              subtitle: "${widget.caseId} • ${widget.caseName}",
              onBack: () => Navigator.pop(context),
            ),

            // Upload box + analysis
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UploadFirBox(
                      mode: _mode,
                      fileName: _pickedFileName,
                      fileSizeKB: _pickedFileSizeKB,
                      onModeChanged: (m) {
                        setState(() {
                          _mode = m;
                          _pickedFileName = null;
                          _pickedFileSizeKB = null;
                        });
                      },
                      onPickImage: _pickImage,
                      onPickAudio: _pickAudio,
                      editor: _firEditor,
                      onAnalyzePressed: _uploadAndAnalyzeFir,
                    ),

                    const SizedBox(height: 18),

                    // Loading / Error / Data UI
                    if (_loading) _LoadingAnalysisCard(),
                    if (_error != null) _ErrorCard(error: _error!),
                    if (_apiData != null) ...[
                      _FirSummaryCard(
                        caseType: _apiData!["case_type"] ?? "—",
                        dateTime: _apiData!["date_time_of_incident"] ?? "—",
                        location: _apiData!["location"] ?? "—",
                        summary: _apiData!["case_summary"] ?? "—",
                      ),
                      const SizedBox(height: 14),
                      _BnsSectionsCard(bnsSections: _apiData!["bns_sections"] ?? []),
                      const SizedBox(height: 14),
                      _InvestigationPlanCard(plan: _apiData!["investigation_plan"] ?? []),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- MODE ENUM --------------------
// enum UploadMode { text, image, audio }

// // 🔹 Other widgets like _TopBar, _UploadFirBox, _ModeButton, _FirSummaryCard, _BnsSectionsCard, _InvestigationPlanCard, _LoadingAnalysisCard, _ErrorCard remain unchanged


// -------------------- MODE ENUM --------------------

enum UploadMode { text, image, audio }

// -------------------- TOP BAR --------------------

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

// -------------------- UPLOAD BOX --------------------

class _UploadFirBox extends StatelessWidget {
  final UploadMode mode;
  final ValueChanged<UploadMode> onModeChanged;
  final VoidCallback onPickImage;
  final VoidCallback onPickAudio;

  final TextEditingController editor;
  final VoidCallback onAnalyzePressed;

  final String? fileName;
  final int? fileSizeKB;

  const _UploadFirBox({
    required this.mode,
    required this.onModeChanged,
    required this.onPickImage,
    required this.onPickAudio,
    required this.editor,
    required this.onAnalyzePressed,
    this.fileName,
    this.fileSizeKB,
  });

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF1D4ED8);
    const Color cyan = Color(0xFF6EE7FF);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [cyan, blue]),
                ),
                child: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upload FIR",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0B1220),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Choose a method to provide FIR input",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Mode Toggle (clean + compact)
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  selected: mode == UploadMode.text,
                  label: "Text",
                  icon: Icons.text_fields_rounded,
                  onTap: () => onModeChanged(UploadMode.text),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  selected: mode == UploadMode.image,
                  label: "Image",
                  icon: Icons.image_outlined,
                  onTap: () => onModeChanged(UploadMode.image),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  selected: mode == UploadMode.audio,
                  label: "Audio",
                  icon: Icons.mic_none_rounded,
                  onTap: () => onModeChanged(UploadMode.audio),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Upload Zone (compact)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFF3F6FF),
              border: Border.all(color: blue.withOpacity(0.18)),
            ),
            child: _buildModeUI(context),
          ),

          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onAnalyzePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                mode == UploadMode.text ? "Analyze FIR (API)" : "Upload to Analyze",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  color: mode == UploadMode.text ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeUI(BuildContext context) {
    if (mode == UploadMode.text) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Type FIR manually",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: const Color(0xFF0B1220),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: editor,
            maxLines: 5,
            style: GoogleFonts.poppins(fontSize: 13),
            decoration: InputDecoration(
              hintText: "Write FIR here...",
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.2),
              ),
            ),
          ),
        ],
      );
    }

    if (mode == UploadMode.image) {
      return Column(
        children: [
          const Icon(Icons.image_outlined, size: 34, color: Colors.black54),
          const SizedBox(height: 6),
          Text(
            "Upload FIR image",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            "JPG / JPEG / PNG",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPickImage,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text("Choose Image", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          if (fileName != null) ...[
            const SizedBox(height: 8),
            Text(
              "$fileName • ${fileSizeKB ?? 0} KB",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
            )
          ]
        ],
      );
    }

    // audio
    return Column(
      children: [
        const Icon(Icons.mic_none_rounded, size: 34, color: Colors.black54),
        const SizedBox(height: 6),
        Text(
          "Upload FIR audio",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          "MP3 only",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onPickAudio,
          icon: const Icon(Icons.upload_file_outlined),
          label: Text("Choose MP3", style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        if (fileName != null) ...[
          const SizedBox(height: 8),
          Text(
            "$fileName • ${fileSizeKB ?? 0} KB",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
          )
        ]
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeButton({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0xFF1D4ED8) : const Color(0xFFF3F4F6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : Colors.black54),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final UploadMode mode;
  final ValueChanged<UploadMode> onModeChanged;

  const _ModePill({
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String text, UploadMode m, IconData icon) {
      final selected = mode == m;
      return InkWell(
        onTap: () => onModeChanged(m),
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? const Color(0xFF1D4ED8) : Colors.grey.shade100,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : Colors.black54),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip("Text", UploadMode.text, Icons.text_fields_rounded),
        const SizedBox(width: 6),
        chip("Image", UploadMode.image, Icons.image_outlined),
        const SizedBox(width: 6),
        chip("Audio", UploadMode.audio, Icons.mic_none_rounded),
      ],
    );
  }
}

// -------------------- FIR SUMMARY CARD --------------------

class _FirSummaryCard extends StatelessWidget {
  final String caseType;
  final String dateTime;
  final String location;
  final String summary;

  const _FirSummaryCard({
    required this.caseType,
    required this.dateTime,
    required this.location,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      title: "FIR Summary",
      icon: Icons.lightbulb_outline_rounded,
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetaRow(label: "Case Type", value: caseType),
          _MetaRow(label: "Incident Time", value: dateTime),
          _MetaRow(label: "Location", value: location),
          const SizedBox(height: 10),
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
    );
  }
}

// -------------------- BNS SECTIONS --------------------

class _BnsSectionsCard extends StatelessWidget {
  final List bnsSections;

  const _BnsSectionsCard({required this.bnsSections});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      title: "BNS Sections",
      icon: Icons.gavel_outlined,
      child: (bnsSections.isEmpty)
          ? Text("No sections detected", style: GoogleFonts.poppins(color: Colors.black54))
          : Column(
              children: List.generate(bnsSections.length, (i) {
                final item = bnsSections[i];
                final section = item["section"] ?? "—";
                final reason = item["reason"] ?? "—";

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1D4ED8).withOpacity(0.12)),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 8),
                    collapsedIconColor: Colors.black54,
                    iconColor: const Color(0xFF1D4ED8),
                    title: Text(
                      section,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0B1220),
                      ),
                    ),
                    children: [
                      Text(
                        reason,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }
}

// -------------------- INVESTIGATION PLAN --------------------

class _InvestigationPlanCard extends StatelessWidget {
  final List plan;

  const _InvestigationPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      title: "Investigation Plan",
      icon: Icons.checklist_outlined,
      child: (plan.isEmpty)
          ? Text("No plan available", style: GoogleFonts.poppins(color: Colors.black54))
          : Column(
              children: List.generate(plan.length, (i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 26,
                        width: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1D4ED8).withOpacity(0.12),
                        ),
                        child: Center(
                          child: Text(
                            "${i + 1}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1D4ED8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          plan[i].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }
}

// -------------------- SHARED CARDS --------------------

class _GlassCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool glow;

  const _GlassCard({
    required this.title,
    required this.icon,
    required this.child,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final glowShadow = glow
        ? [
            BoxShadow(
              color: const Color(0xFF6EE7FF).withOpacity(0.35),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ]
        : <BoxShadow>[];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          ...glowShadow,
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6EE7FF), Color(0xFF1D4ED8)],
                  ),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
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

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.black54,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- LOADING + ERROR --------------------

class _LoadingAnalysisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Fetching FIR analysis from API...",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.red.withOpacity(0.08),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Text(
        error,
        style: GoogleFonts.poppins(
          color: Colors.red.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// -------------------- MINI FLOATING KHOJMITRA --------------------

class _KhojMitraMiniFab extends StatelessWidget {
  final VoidCallback onTap;

  const _KhojMitraMiniFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6EE7FF), Color(0xFF1D4ED8)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFF6EE7FF).withOpacity(0.55),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
      ),
    );
  }
}

// -------------------- CHATBOT WINDOW --------------------

class KhojMitraChatScreen extends StatefulWidget {
  const KhojMitraChatScreen({super.key});

  @override
  State<KhojMitraChatScreen> createState() => _KhojMitraChatScreenState();
}

class _KhojMitraChatScreenState extends State<KhojMitraChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hi, I’m KHOJMITRA 👋\nAsk me anything about this FIR."}
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
      _messages.add({
        "role": "bot",
        "text": "Got it. (Integrate your FastAPI/Groq response here.)"
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
        title: Text("KHOJMITRA", style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
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
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        borderSide: const BorderSide(color: Color(0xFF1D4ED8), width: 1.2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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