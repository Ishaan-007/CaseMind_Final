import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Overview"),
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: "Notifications",
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ✅ Drawer menu (side menu)
      drawer: const _CaseDrawer(),

      // Floating chatbot icon
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CaseChatAssistantScreen()),
          );
        },
        backgroundColor: cs.primary,
        child: const Icon(Icons.smart_toy_outlined),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Case Header Card
          _HeaderCaseCard(
            caseName: "Case: Theft at Sector 21",
            caseId: "CASE-2026-0148",
            status: "Under Investigation",
          ),

          const SizedBox(height: 14),

          // Quick Stats
          Row(
            children: const [
              Expanded(child: _StatTile(title: "Evidence", value: "12")),
              SizedBox(width: 10),
              Expanded(child: _StatTile(title: "Suspects", value: "3")),
              SizedBox(width: 10),
              Expanded(child: _StatTile(title: "Witnesses", value: "5")),
              SizedBox(width: 10),
              Expanded(child: _StatTile(title: "Pending", value: "7")),
            ],
          ),

          const SizedBox(height: 14),

          // FIR Summary Card
          _InfoCard(
            title: "FIR Summary",
            icon: Icons.description_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Complainant reported theft of a mobile phone near the metro gate at 9:15 PM. "
                  "Suspected pickpocketing in crowded area. CCTV and witness statements pending.",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FirScreen()),
                      );
                    },
                    child: const Text("View FIR"),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 14),

          // BNS Sections
          _InfoCard(
            title: "Detected BNS Sections",
            icon: Icons.gavel_outlined,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _ChipBadge(label: "BNS 303", type: BadgeType.neutral),
                _ChipBadge(label: "BNS 305", type: BadgeType.neutral),
                _ChipBadge(label: "Needs Review", type: BadgeType.review),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Actions
          _InfoCard(
            title: "Quick Actions",
            icon: Icons.bolt_outlined,
            child: Row(
              children: [
                Expanded(
                  child: _PrimaryActionButton(
                    label: "Upload Evidence",
                    icon: Icons.upload_file_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EvidenceScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PrimaryActionButton(
                    label: "Generate Plan",
                    icon: Icons.checklist_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InvestigationPlanScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // AI Alerts / Contradictions
          _InfoCard(
            title: "AI Alerts",
            icon: Icons.warning_amber_rounded,
            child: Column(
              children: const [
                _AlertTile(
                  title: "Potential inconsistency in witness timing",
                  subtitle: "Witness A says 9:10 PM, CCTV shows 9:22 PM.",
                  severity: AlertSeverity.danger,
                ),
                SizedBox(height: 10),
                _AlertTile(
                  title: "Missing evidence: CCTV request not uploaded",
                  subtitle: "Add CCTV request letter or station entry proof.",
                  severity: AlertSeverity.review,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recent Evidence Preview
          _InfoCard(
            title: "Recent Evidence",
            icon: Icons.folder_copy_outlined,
            child: Column(
              children: const [
                _EvidenceMiniTile(
                  title: "CCTV Snapshot - Gate 2",
                  subtitle: "Image • 10 Jan 2026 • Pending AI review",
                  status: BadgeType.review,
                ),
                SizedBox(height: 10),
                _EvidenceMiniTile(
                  title: "Witness Statement - Person B",
                  subtitle: "Document • 10 Jan 2026 • Verified",
                  status: BadgeType.verified,
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // spacing for FAB
        ],
      ),
    );
  }
}

class _CaseDrawer extends StatelessWidget {
  const _CaseDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const _DrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    title: "Home (Case Overview)",
                    icon: Icons.home_outlined,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    title: "Evidence",
                    icon: Icons.folder_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EvidenceScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    title: "Timeline",
                    icon: Icons.timeline_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TimelineScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    title: "Insights & Gaps",
                    icon: Icons.psychology_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InsightsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    title: "Connections Graph",
                    icon: Icons.hub_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ConnectionsScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    title: "Investigation Simulator",
                    icon: Icons.alt_route_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SimulatorScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    title: "Court Narrative",
                    icon: Icons.article_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CourtNarrativeScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerItem(
              title: "Settings",
              icon: Icons.settings_outlined,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: cs.primary, size: 34),
          const SizedBox(height: 10),
          Text(
            "Case Assist",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "AI Investigation Workspace",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
      dense: true,
    );
  }
}

// -------------------- UI COMPONENTS --------------------

class _HeaderCaseCard extends StatelessWidget {
  final String caseName;
  final String caseId;
  final String status;

  const _HeaderCaseCard({
    required this.caseName,
    required this.caseId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caseName,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                caseId,
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              _ChipBadge(label: status, type: BadgeType.neutral),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
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

enum BadgeType { neutral, verified, review, danger }

class _ChipBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const _ChipBadge({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.verified:
        bg = Colors.green.withOpacity(0.15);
        fg = Colors.green.shade700;
        break;
      case BadgeType.review:
        bg = Colors.amber.withOpacity(0.18);
        fg = Colors.amber.shade800;
        break;
      case BadgeType.danger:
        bg = Colors.red.withOpacity(0.14);
        fg = Colors.red.shade700;
        break;
      default:
        bg = cs.primary.withOpacity(0.12);
        fg = cs.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withOpacity(0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum AlertSeverity { danger, review }

class _AlertTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final AlertSeverity severity;

  const _AlertTile({
    required this.title,
    required this.subtitle,
    required this.severity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color borderColor = severity == AlertSeverity.danger
        ? Colors.red.withOpacity(0.35)
        : Colors.amber.withOpacity(0.45);

    final Color iconColor =
        severity == AlertSeverity.danger ? Colors.red : Colors.amber.shade800;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _EvidenceMiniTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final BadgeType status;

  const _EvidenceMiniTile({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.insert_drive_file_outlined),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        _ChipBadge(
          label: status == BadgeType.verified
              ? "Verified"
              : status == BadgeType.review
                  ? "Review"
                  : "Neutral",
          type: status,
        )
      ],
    );
  }
}

// -------------------- PLACEHOLDER SCREENS --------------------

class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Evidence")),
      body: const Center(child: Text("Evidence Screen")),
    );
  }
}

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timeline")),
      body: const Center(child: Text("Timeline Screen")),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Insights & Gaps")),
      body: const Center(child: Text("Insights Screen")),
    );
  }
}

class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connections Graph")),
      body: const Center(child: Text("Connections Screen")),
    );
  }
}

class SimulatorScreen extends StatelessWidget {
  const SimulatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Investigation Simulator")),
      body: const Center(child: Text("Simulator Screen")),
    );
  }
}

class CourtNarrativeScreen extends StatelessWidget {
  const CourtNarrativeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Court Narrative")),
      body: const Center(child: Text("Court Narrative Screen")),
    );
  }
}

class InvestigationPlanScreen extends StatelessWidget {
  const InvestigationPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Investigation Plan")),
      body: const Center(child: Text("Plan Screen")),
    );
  }
}

class FirScreen extends StatelessWidget {
  const FirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FIR")),
      body: const Center(child: Text("FIR Screen")),
    );
  }
}

class CaseChatAssistantScreen extends StatelessWidget {
  const CaseChatAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Case Q&A Assistant")),
      body: const Center(child: Text("Chatbot Screen")),
    );
  }
}