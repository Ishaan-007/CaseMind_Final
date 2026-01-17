import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investigation_assistant_app_frontend/screens/case_dashboard_screen.dart';

class ActiveCasesScreen extends StatefulWidget {
  const ActiveCasesScreen({super.key});

  @override
  State<ActiveCasesScreen> createState() => _ActiveCasesScreenState();
}

class _ActiveCasesScreenState extends State<ActiveCasesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, String>> _cases = [];
  List<Map<String, String>> _filteredCases = [];
  bool _isLoading = true;

  // Colors (you can tweak easily)
  static const Color headerBlue1 = Color(0xFF1D4ED8); // nicer royal blue
  static const Color headerBlue2 = Color(0xFF0B1220); // deep navy
  static const Color surfaceBg = Color(0xFFF6F7FB);

  @override
  void initState() {
    super.initState();
    _loadCasesFromFirebase();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase().trim();
      setState(() {
        _filteredCases = _cases.where((c) {
          return c["id"]!.toLowerCase().contains(query) ||
              c["name"]!.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  Future<void> _loadCasesFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final snapshot = await _firestore
          .collection('officers')
          .doc(user.uid)
          .collection('cases')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _cases = snapshot.docs
            .map((doc) => {
              "id": doc['caseId'] as String? ?? "",
              "name": doc['caseName'] as String? ?? "",
              "docId": doc.id, // Store Firestore document ID
            })
            .toList();
        _filteredCases = List.from(_cases);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCaseToFirebase(String caseId, String caseName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('officers')
          .doc(user.uid)
          .collection('cases')
          .add({
        'caseId': caseId,
        'caseName': caseName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadCasesFromFirebase();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Case added successfully",
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error adding case: $e",
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Fully functional add-case dialog
  void _showAddCaseDialog() {
    final idController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            "Add New Case",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: idController,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: "Case ID",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Enter Case ID";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: "Case Name",
                    labelStyle: GoogleFonts.poppins(),
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Enter Case Name";
                    return null;
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  _addCaseToFirebase(
                    idController.text.trim(),
                    nameController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: headerBlue1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "Add",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openProfileSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              CircleAvatar(
                radius: 28,
                backgroundColor: headerBlue1.withOpacity(0.12),
                child: const Icon(Icons.person, size: 30, color: headerBlue1),
              ),
              const SizedBox(height: 10),
              Text(
                "Ishaan",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Officer Account",
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text("Settings", style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: Text("Logout", style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,

      // ✅ Premium floating + button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCaseDialog,
        backgroundColor: headerBlue1,
        icon: const Icon(Icons.add),
        label: Text(
          "Add Case",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 25, 90, 159), Color.fromARGB(255, 35, 162, 230)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: Row(
                  children: [
                    // App Logo area
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.14),
                        border: Border.all(color: Colors.white.withOpacity(0.22)),
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "CaseMind",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Hello Ishaan",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Text(
                        //   "Active cases dashboard",
                        //   style: GoogleFonts.poppins(
                        //     color: Colors.white.withOpacity(0.75),
                        //     fontSize: 11.5,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(width: 10),

                    InkWell(
                      onTap: _openProfileSheet,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.14),
                          border: Border.all(color: Colors.white.withOpacity(0.22)),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "See your active cases",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // MAIN WHITE AREA
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
                      // Search bar (improved)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(fontSize: 14.5),
                          decoration: InputDecoration(
                            icon: Icon(Icons.search_rounded,
                                color: Colors.grey.shade700),
                            hintText: "Search cases",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Case Cards
                      Expanded(
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.blue.shade700,
                                  ),
                                ),
                              )
                            : _filteredCases.isEmpty
                                ? Center(
                                    child: Text(
                                      "No cases found",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: _filteredCases.length,
                                itemBuilder: (context, index) {
                                  final c = _filteredCases[index];
                                  return _ModernCaseCard(
                                    caseId: c["id"]!,
                                    caseName: c["name"]!,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CaseDashboardScreen(
                                            caseId: c["id"]!,
                                            caseName: c["name"]!,
                                            caseDocId: c["docId"]!,
                                            caseSummary:
                                                "This case involves ${c["name"]}. Review FIR details, verify evidence, and build a consistent timeline for court readiness.",
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- Better Case Card -------------------

class _ModernCaseCard extends StatelessWidget {
  final String caseId;
  final String caseName;
  final VoidCallback onTap;

  const _ModernCaseCard({
    required this.caseId,
    required this.caseName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
            Color.fromARGB(255, 8, 23, 53),    // #081735
            Color.fromARGB(255, 61, 99, 202),  // #3D63CA
          ]
,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
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
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.14),
                border: Border.all(color: Colors.white.withOpacity(0.20)),
              ),
              child: const Icon(Icons.folder_open_rounded, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    caseId,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    caseName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}