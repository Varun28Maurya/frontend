import 'package:flutter/material.dart';
import '../routes.dart';
import '../layout/app_header.dart';
import '../components/logout.dart';

// Owner Screens
import '../pages/owner/dashboard/owner_dashboard.dart';
import '../pages/owner/projects/owner_projects.dart';
import '../pages/owner/approvals/owner_approvals.dart';
import '../pages/owner/chat/owner_chat.dart';
import '../pages/owner/docs/owner_docs.dart';

class OwnerNav extends StatefulWidget {
  final int initialIndex;
  const OwnerNav({super.key, this.initialIndex = 0});

  @override
  State<OwnerNav> createState() => _OwnerNavState();
}

class _OwnerNavState extends State<OwnerNav> {
  bool isOffline = false;
  late int currentIndex;

  final List<Widget> pages = const [
    OwnerDashboardPage(),
    OwnerProjectsPage(),
    OwnerApprovalsPage(),
    OwnerChatPage(),
    OwnerDocsPage(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _goToIndex(int index) {
    // ✅ Smooth tab switching
    setState(() => currentIndex = index);

    // ❌ Don't navigate here
    // Navigator.pushReplacementNamed(...) => removed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppHeader(
        isOffline: isOffline,
        onToggleOffline: () => setState(() => isOffline = !isOffline),
        onReadAloud: () {},
        onNotifications: () {},
        onProfile: () => Navigator.pushNamed(context, AppRoutes.profile),
        onSettings: () => Navigator.pushNamed(context, AppRoutes.settings),
        onLogout: () async => await logout(context),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),

          // ✅ Keeps page state alive + smooth switching
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _goToIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: "Dashboard"),
          NavigationDestination(icon: Icon(Icons.apartment), label: "Projects"),
          NavigationDestination(icon: Icon(Icons.approval), label: "Approvals"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Chat"),
          NavigationDestination(icon: Icon(Icons.folder), label: "Docs"),
        ],
      ),
    );
  }
}
