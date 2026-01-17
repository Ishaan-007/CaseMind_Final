import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'evidence_detail_screen.dart';

enum EvidenceCategory { audio, video, documents, physical }

class EvidenceItem {
  final String id;
  final String title;
  final EvidenceCategory category;
  final DateTime createdAt;
  final int sizeKB;

  EvidenceItem({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.sizeKB,
  });
}

class EvidenceTabScreen extends StatefulWidget {
  final String caseId;
  final String caseName;

  const EvidenceTabScreen({
    super.key,
    required this.caseId,
    required this.caseName,
  });

  @override
  State<EvidenceTabScreen> createState() => _EvidenceTabScreenState();
}

class _EvidenceTabScreenState extends State<EvidenceTabScreen> {
  static const Color headerBlue1 = Color(0xFF1D4ED8);
  static const Color headerBlue2 = Color(0xFF0B1220);
  static const Color surfaceBg = Color(0xFFF6F7FB);

  EvidenceCategory selected = EvidenceCategory.documents;

  final List<EvidenceItem> evidences = [
    EvidenceItem(
      id: "EV-1001",
      title: "CCTV_Footage_Station.mp4",
      category: EvidenceCategory.video,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      sizeKB: 54200,
    ),
    EvidenceItem(
      id: "EV-1002",
      title: "Witness_Audio.mp3",
      category: EvidenceCategory.audio,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      sizeKB: 7400,
    ),
    EvidenceItem(
      id: "EV-1003",
      title: "Medical_Report.pdf",
      category: EvidenceCategory.documents,
      createdAt: DateTime.now().subtract(const Duration(minutes: 55)),
      sizeKB: 560,
    ),
  ];

  Future<void> _uploadEvidence(EvidenceCategory category) async {
    FileType type = FileType.custom;
    List<String> allowed = [];

    switch (category) {
      case EvidenceCategory.audio:
        allowed = ["mp3", "wav"];
        break;
      case EvidenceCategory.video:
        allowed = ["mp4"];
        break;
      case EvidenceCategory.documents:
        allowed = ["pdf", "jpg", "jpeg", "png"];
        break;
      case EvidenceCategory.physical:
        // Physical evidence -> we’ll allow image upload as proof
        allowed = ["jpg", "jpeg", "png"];
        break;
    }

    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: type,
      allowedExtensions: allowed,
    );

    if (res == null) return;

    setState(() {
      for (final f in res.files) {
        evidences.insert(
          0,
          EvidenceItem(
            id: "EV-${DateTime.now().millisecondsSinceEpoch}",
            title: f.name,
            category: category,
            createdAt: DateTime.now(),
            sizeKB: (f.size / 1024).round(),
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          "Evidence uploaded successfully",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

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
                title: "Evidence",
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
                  child: Column(
                    children: [
                      _UploadPanel(
                        selected: selected,
                        onSelect: (c) => setState(() => selected = c),
                        onUpload: () => _uploadEvidence(selected),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Text(
                            "All Evidence",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${evidences.length} items",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: evidences.length,
                          itemBuilder: (context, i) {
                            final e = evidences[i];
                            return _EvidenceCard(
                              item: e,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EvidenceDetailScreen(
                                      evidence: e,
                                      // later replace with API response
                                      mockResponse: demoEvidenceResponse,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
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

// ---------- Upload Panel ----------

class _UploadPanel extends StatelessWidget {
  final EvidenceCategory selected;
  final ValueChanged<EvidenceCategory> onSelect;
  final VoidCallback onUpload;

  const _UploadPanel({
    required this.selected,
    required this.onSelect,
    required this.onUpload,
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
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [cyan, blue]),
                ),
                child: const Icon(Icons.upload_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Upload Evidence",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0B1220),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Select category and upload files",
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

          Row(
            children: [
              Expanded(
                child: _CategoryChip(
                  label: "Audio",
                  icon: Icons.graphic_eq_rounded,
                  selected: selected == EvidenceCategory.audio,
                  onTap: () => onSelect(EvidenceCategory.audio),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CategoryChip(
                  label: "Video",
                  icon: Icons.videocam_outlined,
                  selected: selected == EvidenceCategory.video,
                  onTap: () => onSelect(EvidenceCategory.video),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CategoryChip(
                  label: "Documents",
                  icon: Icons.description_outlined,
                  selected: selected == EvidenceCategory.documents,
                  onTap: () => onSelect(EvidenceCategory.documents),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CategoryChip(
                  label: "Physical",
                  icon: Icons.inventory_2_outlined,
                  selected: selected == EvidenceCategory.physical,
                  onTap: () => onSelect(EvidenceCategory.physical),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFF3F6FF),
              border: Border.all(color: blue.withOpacity(0.16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.black54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _hintText(selected),
                    style: GoogleFonts.poppins(
                      fontSize: 12.2,
                      height: 1.25,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                "Upload",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hintText(EvidenceCategory c) {
    switch (c) {
      case EvidenceCategory.audio:
        return "Supported: MP3, WAV • Best for witness statements and call recordings.";
      case EvidenceCategory.video:
        return "Supported: MP4 • Best for CCTV footage and incident recordings.";
      case EvidenceCategory.documents:
        return "Supported: PDF, JPG, PNG • Reports, forms, screenshots, scanned pages.";
      case EvidenceCategory.physical:
        return "Upload images of physical evidence (JPG/PNG) • Example: weapon, item, scene photo.";
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                fontSize: 12.5,
                color: selected ? Colors.white : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Evidence Card ----------

class _EvidenceCard extends StatelessWidget {
  final EvidenceItem item;
  final VoidCallback onTap;

  const _EvidenceCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cat = _catStyle(item.category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: const Color(0xFF0B1220),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        cat.label,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: cat.fg,
                        ),
                      ),
                      Text(
                        " • ${item.sizeKB} KB",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  _CategoryVisual _catStyle(EvidenceCategory c) {
    switch (c) {
      case EvidenceCategory.audio:
        return _CategoryVisual(
          label: "AUDIO",
          fg: const Color(0xFF8B5CF6),
          bg: const Color(0xFF8B5CF6).withOpacity(0.12),
          icon: Icons.graphic_eq_rounded,
        );
      case EvidenceCategory.video:
        return _CategoryVisual(
          label: "VIDEO",
          fg: const Color(0xFF22C55E),
          bg: const Color(0xFF22C55E).withOpacity(0.12),
          icon: Icons.videocam_outlined,
        );
      case EvidenceCategory.documents:
        return _CategoryVisual(
          label: "DOCUMENT",
          fg: const Color(0xFF0EA5E9),
          bg: const Color(0xFF0EA5E9).withOpacity(0.12),
          icon: Icons.description_outlined,
        );
      case EvidenceCategory.physical:
        return _CategoryVisual(
          label: "PHYSICAL",
          fg: const Color(0xFFF59E0B),
          bg: const Color(0xFFF59E0B).withOpacity(0.12),
          icon: Icons.inventory_2_outlined,
        );
    }
  }
}

class _CategoryVisual {
  final String label;
  final Color fg;
  final Color bg;
  final IconData icon;

  _CategoryVisual({
    required this.label,
    required this.fg,
    required this.bg,
    required this.icon,
  });
}

// ---------- TopBar ----------

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

// ---------- MOCK RESPONSE (same as your JSON) ----------

const Map<String, dynamic> demoEvidenceResponse = {
  "key_findings": [
    "A lone female pedestrian was ambushed and robbed of her shoulder bag by a male suspect.",
    "The suspect approached from the left side, emerging from behind a concrete barrier, indicating a possible opportunistic or planned ambush.",
    "The robbery was swift and involved the snatching of the victim's bag while she was walking.",
    "The victim displayed immediate shock and distress after the incident."
  ],
  "extracted_entities": {
    "victims": [
      {
        "description":
            "Female, red hair (possibly dyed), mid-30s to 40s, wearing a black leather jacket, light blue jeans, and a white high-neck top. She was carrying a brown shoulder bag.",
        "role": "victim"
      }
    ],
    "suspects": [
      {
        "description":
            "Male, wearing a black hooded jacket and a black baseball cap. Appears to have a beard. Agile and quick in his movements.",
        "role": "suspect"
      }
    ],
    "witnesses": [],
    "locations": [
      {
        "description":
            "An outdoor concrete path or bridge, possibly a pedestrian overpass. Features include an old, somewhat dilapidated concrete railing on the left with visible graffiti. In the background, there are bare trees, white buildings, and a general residential/urban park setting. Weather appears overcast.",
        "type": "outdoor pathway/bridge"
      }
    ],
    "objects": [
      {"description": "Brown shoulder bag", "status": "stolen", "owner": "victim"},
      {"description": "Black leather jacket", "status": "worn", "owner": "victim"},
      {"description": "Light blue jeans", "status": "worn", "owner": "victim"},
      {"description": "White high-neck top", "status": "worn", "owner": "victim"},
      {"description": "Black hooded jacket", "status": "worn", "owner": "suspect"},
      {"description": "Black baseball cap", "status": "worn", "owner": "suspect"}
    ]
  },
  "inferred_timeline_events": [
    {
      "timestamp_start": "00:00",
      "timestamp_end": "00:03",
      "event_description":
          "The victim is walking alone on a concrete path, appearing preoccupied.",
      "link_to_fir": "Contextual setup for the robbery."
    },
    {
      "timestamp_start": "00:03",
      "timestamp_end": "00:04",
      "event_description":
          "A male suspect emerges from behind a barrier and approaches the victim from her left side.",
      "link_to_fir": "Initiation of the robbery attempt."
    },
    {
      "timestamp_start": "00:04",
      "timestamp_end": "00:05",
      "event_description":
          "The suspect lunges and successfully snatches the victim's brown shoulder bag.",
      "link_to_fir": "Direct act of robbery (theft by force/snatching)."
    },
    {
      "timestamp_start": "00:05",
      "timestamp_end": "00:06",
      "event_description": "The suspect flees the scene with the stolen bag.",
      "link_to_fir": "Completion of the robbery and escape."
    },
    {
      "timestamp_start": "00:06",
      "timestamp_end": "00:09",
      "event_description":
          "The victim reacts with visible shock and distress, covering her mouth with her hands.",
      "link_to_fir": "Victim's immediate post-robbery reaction."
    }
  ],
  "confidence_level": "high"
};